/********************************************************************************************************
 * @file     SigAccessLayer.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/9/16
 *
 * @par     Copyright (c) [2021], Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
 *
 *          Licensed under the Apache License, Version 2.0 (the "License");
 *          you may not use this file except in compliance with the License.
 *          You may obtain a copy of the License at
 *
 *              http://www.apache.org/licenses/LICENSE-2.0
 *
 *          Unless required by applicable law or agreed to in writing, software
 *          distributed under the License is distributed on an "AS IS" BASIS,
 *          WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *          See the License for the specific language governing permissions and
 *          limitations under the License.
 *******************************************************************************************************/

#import "SigAccessLayer.h"
#import "SigAccessPdu.h"
#import "SigUpperTransportLayer.h"
#import "SigLowerTransportLayer.h"

/// The transaction object is used for Transaction Messages,
/// for example `GenericLevelSet`.
@interface SigTransaction : NSObject
/// Last used Transaction Identifier.
@property (nonatomic,assign) UInt8 lastTid;
/// The timestamp of the last transaction message sent.
@property (nonatomic,strong) NSDate *timestamp;
@end
@implementation SigTransaction
/// Returns the last used TID.
- (instancetype)init{
    if (self = [super init]) {
        _lastTid = arc4random()%(0xff+1);
    }
    return self;
}
- (UInt8)currentTid {
    _timestamp = [NSDate date];
    return _lastTid;
}
/// Returns the next TID.
- (UInt8)nextTid {
    if (_lastTid < 255) {
        _lastTid = _lastTid + 1;
    } else {
        _lastTid = 0;
    }
    _timestamp = [NSDate date];
    return _lastTid;
}
/// Whether the transaction can be continued.
- (BOOL)isActive {
    // A transaction may last up to 6 seconds.
    return _timestamp.timeIntervalSinceNow > -6.0;
}
@end

@interface SigAcknowledgmentContext : NSObject
@property (nonatomic,strong) SigAcknowledgedMeshMessage *request;
@property (nonatomic,assign) UInt16 source;
@property (nonatomic,assign) UInt16 destination;
@property (nonatomic,strong) BackgroundTimer *timeoutTimer;
@property (nonatomic,strong,nullable) BackgroundTimer *retryTimer;
@end
@implementation SigAcknowledgmentContext
- (instancetype)initForRequest:(SigAcknowledgedMeshMessage *)request sentFromSource:(UInt16)source toDestination:(UInt16)destination repeatAfterDelay:(NSTimeInterval)delay repeatBlock:(void (^ _Nonnull)(void))repeatBlock timeout:(NSTimeInterval)timeout timeoutBlock:(void (^ _Nonnull)(void))timeoutBlock {
    if (self = [super init]) {
        _request = request;
        _source = source;
        _destination = destination;
        __weak typeof(self) weakSelf = self;
        _timeoutTimer = [BackgroundTimer scheduledTimerWithTimeInterval:timeout repeats:NO block:^(BackgroundTimer * _Nonnull t) {
            [weakSelf invalidate];
            if (timeoutBlock) {
                timeoutBlock();
            }
        }];
        [self initializeRetryTimerWithDelay:delay callback:repeatBlock];
    }
    return self;
}

/// Invalidates the timers.
- (void)invalidate {
//    if (_timeoutTimer) {
//        [_timeoutTimer invalidate];
//    }
    if (_retryTimer) {
        [_retryTimer invalidate];
        _retryTimer = nil;
    }
}

- (void)initializeRetryTimerWithDelay:(NSTimeInterval)delay callback:(void (^ _Nonnull)(void))callback {
    __weak typeof(self) weakSelf = self;
    if (_retryTimer) {
        [_retryTimer invalidate];
        _retryTimer = nil;
    }
    _retryTimer = [BackgroundTimer scheduledTimerWithTimeInterval:delay repeats:NO block:^(BackgroundTimer * _Nonnull t) {
        if (weakSelf.retryTimer) {
            if (callback) {
                callback();
            }
            [weakSelf initializeRetryTimerWithDelay:t.interval * 2 callback:callback];
        } else {
            return;
        }
    }];
}

@end

@interface SigAccessLayer ()
@property (nonatomic,strong) SigNetworkManager *networkManager;
/// A map of current transactions.
///
/// The key is a value combined from the source and destination addresses.
@property (nonatomic,strong) NSMutableDictionary <NSNumber *,SigTransaction *>*transactions;
/// This array contains information about the expected acknowledgments for acknowledged mesh messages that have been sent, and for which the response has not been received yet.
@property (nonatomic,strong) NSMutableArray <SigAcknowledgmentContext *>*reliableMessageContexts;
@end

@implementation SigAccessLayer

- (instancetype)init {
    if (self = [super init]) {
        _transactions = [NSMutableDictionary dictionary];
        _reliableMessageContexts = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithNetworkManager:(SigNetworkManager *)networkManager {
    if (self = [super init]) {
        _networkManager = networkManager;
        _transactions = [NSMutableDictionary dictionary];
        _reliableMessageContexts = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    TeLogWarn(@"_reliableMessageContexts=%@",_reliableMessageContexts);
    [_transactions removeAllObjects];
    NSArray *reliableMessageContexts = [NSArray arrayWithArray:_reliableMessageContexts];
    for (SigAcknowledgmentContext *model in reliableMessageContexts) {
        [model invalidate];
    }
    [_reliableMessageContexts removeAllObjects];
}

- (void)handleUpperTransportPdu:(SigUpperTransportPdu *)upperTransportPdu sentWithSigKeySet:(SigKeySet *)keySet {
    SigAccessPdu *accessPdu = [[SigAccessPdu alloc] initFromUpperTransportPdu:upperTransportPdu];
    if (accessPdu == nil) {
        TeLogError(@"handleUpperTransportPdu fail.");
        return;
    }
    // If a response to a sent request has been received, cancel the context.
    SigAcknowledgedMeshMessage *request = nil;
    NSInteger index = 0;
    BOOL exist = NO;
    for (int i=0; i<_reliableMessageContexts.count; i++) {
        SigAcknowledgmentContext *model = _reliableMessageContexts[i];
        if (model.source == upperTransportPdu.destination && model.request.responseOpCode == accessPdu.opCode) {
            index = i;
            exist = YES;
            break;
        }
    }
    if ([SigHelper.share isUnicastAddress:upperTransportPdu.destination] && exist) {
        SigAcknowledgmentContext *context = _reliableMessageContexts[index];
        request = context.request;
        [context invalidate];
        [_reliableMessageContexts removeObjectAtIndex:index];
    }
//    TeLogInfo(@"receieved:%@",accessPdu);
    [self handleAccessPdu:accessPdu sendWithSigKeySet:keySet asResponseToRequest:request];
}

- (void)sendMessage:(SigMeshMessage *)message fromElement:(SigElementModel *)element toDestination:(SigMeshAddress *)destination withTtl:(UInt8)initialTtl usingApplicationKey:(SigAppkeyModel *)applicationKey command:(SDKLibCommand *)command {
    // Should the TID be updated?
    SigMeshMessage *m = message;
    if ([message isKindOfClass:[SigGenericMessage class]]) {
        SigGenericMessage *genericMessage = (SigGenericMessage *)message;
        if (command.tidPosition != 0 && command.tid != 0) {
            genericMessage.tid = command.tid;
        }
        if ([genericMessage isTransactionMessage] && genericMessage.tid == 0) {
            UInt32 k = [self getKeyForElement:element andDestination:destination];
            _transactions[@(k)] = _transactions[@(k)] == nil ? [[SigTransaction alloc] init] : _transactions[@(k)];
            // Should the last transaction be continued?
            if (command.hadRetryCount > 0) {
                genericMessage.tid = [_transactions[@(k)] currentTid];
            } else {
                // If not, start a new transaction by setting a new TID value.
                genericMessage.tid = [_transactions[@(k)] nextTid];
            }
            m = genericMessage;
        }
//        TeLogVerbose(@"sending message TID=0x%x",genericMessage.tid);
    } else if ([message isKindOfClass:[SigIniMeshMessage class]] && command.tidPosition != 0) {
        if (command.tidPosition != 0) {
            UInt8 tid = command.tid;
            if (tid == 0) {
                UInt32 k = [self getKeyForElement:element andDestination:destination];
                _transactions[@(k)] = _transactions[@(k)] == nil ? [[SigTransaction alloc] init] : _transactions[@(k)];
                if (command.hadRetryCount > 0) {
                    tid = [_transactions[@(k)] currentTid];
                } else {
                    tid = [_transactions[@(k)] nextTid];
                }
            }
            NSMutableData *mData = [NSMutableData dataWithData:message.parameters];
            [mData replaceBytesInRange:NSMakeRange(command.tidPosition-1, 1) withBytes:&tid length:1];
            message.parameters = mData;
            m = message;
        }
    }
    SigAccessPdu *pdu = [[SigAccessPdu alloc] initFromMeshMessage:m sentFromLocalElement:element toDestination:destination userInitiated:YES];
    SigAccessKeySet *keySet = [[SigAccessKeySet alloc] initWithApplicationKey:applicationKey];
    TeLogInfo(@"Sending message:%@->%@",message.class,pdu);
    
    _networkManager.accessLayer.accessPdu = pdu;
    [_networkManager.upperTransportLayer sendAccessPdu:pdu withTtl:initialTtl usingKeySet:keySet command:command];
}

- (void)sendSigConfigMessage:(SigConfigMessage *)message toDestination:(UInt16)destination withTtl:(UInt16)initialTtl command:(SDKLibCommand *)command {
    SigElementModel *element = SigMeshLib.share.dataSource.curLocationNodeModel.elements.firstObject;
    SigNodeModel *node = [SigMeshLib.share.dataSource getNodeWithAddress:destination];
    SigNetkeyModel *networkKey = node.getNetworkKeys.firstObject;
    if (networkKey == nil) {
        networkKey = SigMeshLib.share.dataSource.curNetkeyModel;
    }
    // ConfigNetKeyDelete must not be signed using the key that is being deleted.
    if ([message isMemberOfClass:[SigConfigNetKeyDelete class]]) {
        SigConfigNetKeyDelete *netKeyDelete = (SigConfigNetKeyDelete *)message;
        if (netKeyDelete.networkKeyIndex == networkKey.index) {
            networkKey = node.getNetworkKeys.lastObject;
        }
    }
    SigMeshAddress *meshAddress = [[SigMeshAddress alloc] initWithAddress:destination];
    SigAccessPdu *pdu = [[SigAccessPdu alloc] initFromMeshMessage:message sentFromLocalElement:element toDestination:meshAddress userInitiated:YES];
    TeLogInfo(@"Sending %@ %@",message,pdu);
    SigDeviceKeySet *keySet = [[SigDeviceKeySet alloc] initWithNetworkKey:networkKey node:node];
    
    _networkManager.accessLayer.accessPdu = pdu;
    [_networkManager.upperTransportLayer sendAccessPdu:pdu withTtl:initialTtl usingKeySet:keySet command:command];
}

- (void)replyToMessageSentToOrigin:(UInt16)origin withMeshMessage:(SigMeshMessage *)message fromElement:(SigElementModel *)element toDestination:(UInt16)destination usingKeySet:(SigKeySet *)keySet command:(SDKLibCommand *)command {
    TeLogInfo(@"Replying with %@ from: %@, to: 0x%x",message,element,destination);
    SigMeshAddress *meshAddress = [[SigMeshAddress alloc] initWithAddress:destination];
    SigAccessPdu *pdu = [[SigAccessPdu alloc] initFromMeshMessage:message sentFromLocalElement:element toDestination:meshAddress userInitiated:NO];
    
    // If the message is sent in response to a received message that was sent to
    // a Unicast Address, the node should transmit the response message with a random
    // delay between 20 and 50 milliseconds. If the message is sent in response to a
    // received message that was sent to a group address or a virtual address, the node
    // should transmit the response message with a random delay between 20 and 500
    // milliseconds. This reduces the probability of multiple nodes responding to this
    // message at exactly the same time, and therefore increases the probability of
    // message delivery rather than message collisions.
    float delay = [SigHelper.share isUnicastAddress:origin] ? [SigHelper.share getRandomfromA:0.020 toB:0.050] : [SigHelper.share getRandomfromA:0.020 toB:0.500];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TeLogInfo(@"Sending %@",pdu);
        UInt8 ttl = element.getParentNode.defaultTTL;
        if (![SigHelper.share isRelayedTTL:ttl]) {
            ttl = weakSelf.networkManager.defaultTtl;
        }
        [weakSelf.networkManager.upperTransportLayer sendAccessPdu:pdu withTtl:ttl usingKeySet:keySet command:command];
    });
}

- (void)cancelSigMessageHandle:(SigMessageHandle *)handle {
//    TeLogInfo(@"Cancelling messages with op code:0x%x, sent from:0x%x to:0x%x",(unsigned int)handle.opCode,handle.source,handle.destination);
    NSArray *reliableMessageContexts = [NSArray arrayWithArray:_reliableMessageContexts];
    for (SigAcknowledgmentContext *model in reliableMessageContexts) {
        if (model.request.opCode == handle.opCode && model.source == handle.source &&
        model.destination == handle.destination) {
            [model invalidate];
            [_reliableMessageContexts removeObject:model];
            break;
        }
    }
    [_networkManager.upperTransportLayer cancelHandleSigMessageHandle:handle];
    [_networkManager.lowerTransportLayer cancelTXSendingSegmentedWithDestination:handle.destination];
}

- (void)handleAccessPdu:(SigAccessPdu *)accessPdu sendWithSigKeySet:(SigKeySet *)keySet asResponseToRequest:(SigAcknowledgedMeshMessage *)request {
    SigNodeModel *localNode = SigMeshLib.share.dataSource.curLocationNodeModel;
    if (localNode == nil) {
        TeLogError(@"localNode error.");
        return;
    }
    
    SigMeshMessage *receiveMessage = [self decodeSigAccessPdu:accessPdu];
    if (receiveMessage == nil) {
        SigUnknownMessage *unknownMessage = [[SigUnknownMessage alloc] initWithParameters:accessPdu.parameters];
        unknownMessage.opCode = accessPdu.opCode;
        receiveMessage = unknownMessage;
    }
    [_networkManager notifyAboutNewMessage:receiveMessage fromSource:accessPdu.source toDestination:accessPdu.destination.address];
}

- (UInt32)getKeyForElement:(SigElementModel *)element andDestination:(SigMeshAddress *)destination {
    return (UInt32)((element.unicastAddress) << 16) | (UInt32)(destination.address);
}

- (void)removeAllTimeoutTimerInreliableMessageContexts {
    TeLogInfo(@"============9.3.AccessError.timeout");
    NSArray *reliableMessageContexts = [NSArray arrayWithArray:_reliableMessageContexts];
    for (SigAcknowledgmentContext *context in reliableMessageContexts) {
        if (context.timeoutTimer == nil) {
            [_reliableMessageContexts removeObject:context];
        }
    }
}

/// This method tries to decode the Access PDU into a Message.
/// The Model Handler must support the opcode and specify to which type should the message be decoded.
/// @param accessPdu The Access PDU received.
/// @returns The decoded message, or `nil`, if the message is not supported or invalid.
- (SigMeshMessage *)decodeSigAccessPdu:(SigAccessPdu *)accessPdu {
    Class MessageType = [SigHelper.share getMeshMessageWithOpCode:accessPdu.opCode];
    if (MessageType != nil) {
        SigMeshMessage *msg = [[MessageType alloc] initWithParameters:accessPdu.parameters];
        return msg;
    }
    return nil;
}

@end
