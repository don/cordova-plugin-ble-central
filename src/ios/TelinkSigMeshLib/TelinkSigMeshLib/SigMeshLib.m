/********************************************************************************************************
 * @file     SigMeshLib.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/8/15
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

#import "SigMeshLib.h"
#import "SDKLibCommand.h"
#import "SigLowerTransportLayer.h"

@interface SigMeshLib ()<SigMessageDelegate>
/// The Network Layer handler.
@property (nonatomic,strong) SigNetworkManager *networkManager;
@end

@implementation SigMeshLib

static SigMeshLib *shareLib = nil;

+ (SigMeshLib *)share {
    static dispatch_once_t tempOnce=0;
    dispatch_once(&tempOnce, ^{
        shareLib = [[SigMeshLib alloc] init];
        shareLib.isReceiveSegmentPDUing = NO;
        shareLib.sourceOfReceiveSegmentPDU = 0;
        shareLib.commands = [NSMutableArray array];
        shareLib.dataSource = SigDataSource.share;
        shareLib.sendBeaconType = AppSendBeaconType_auto;
        [shareLib config];
        [shareLib initDelegate];
    });
    return shareLib;
}

- (void)initDelegate {
    _delegate = shareLib;
}

- (instancetype)init{
    if (self = [super init]) {
        [self config];
    }
    return self;
}

- (SigNetworkManager *)networkManager {
    return SigNetworkManager.share;
}

- (void)config{
    _defaultTtl = 10;
    _incompleteMessageTimeout = 15.0;
    _receiveSegmentMessageTimeout = 15.0;
    _acknowledgmentTimerInterval = 0.150;
    _transmissionTimerInterval = 0.200;
    _retransmissionLimit = 20;
    _networkTransmitIntervalSteps = 0b11111;
    _networkTransmitInterval = (_networkTransmitIntervalSteps + 1) * 10 / 1000.0;//单位ms
    _queue = dispatch_queue_create("SigMeshLib.queue(消息收发队列)", DISPATCH_QUEUE_SERIAL);
    _delegateQueue = dispatch_queue_create("SigMeshLib.delegateQueue", DISPATCH_QUEUE_SERIAL);
}

- (void)setNetworkTransmitIntervalSteps:(UInt8)networkTransmitIntervalSteps {
    if (networkTransmitIntervalSteps > 0b11111) {
        TeLogDebug(@"networkTransmitIntervalSteps range:0~0b11111! Set to default value 0b11111.");
        networkTransmitIntervalSteps = 0b11111;
    }
    _networkTransmitIntervalSteps = networkTransmitIntervalSteps;
    _networkTransmitInterval = (_networkTransmitIntervalSteps + 1) * 10 / 1000.0;//单位ms
}

#pragma mark - Receive Mesh Messages

- (void)bearerDidDeliverData:(NSData *)data type:(SigPduType)type {
    if (self.networkManager == nil) {
        TeLogDebug(@"self.networkManager == nil");
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        [weakSelf.networkManager handleIncomingPdu:data ofType:type];
    });
}

- (void)receiveNetworkPdu:(SigNetworkPdu *)networkPdu {
    /* 用于接收到segment pdu时，如果存在应用层的重试，则在该地方修正一下重试定时器的时间。注意：当前直接callback解密后的networkPdu，方便后期新增一些优化的逻辑代码 */
    if (networkPdu.isSegmented) {
        if (_receiveSegmentTimer == nil) {
            TeLogDebug(@"==========RxBusy标志开始");
            __weak typeof(self) weakSelf = self;
            _receiveSegmentTimer = [BackgroundTimer scheduledTimerWithTimeInterval:_receiveSegmentMessageTimeout repeats:NO block:^(BackgroundTimer * _Nonnull t) {
                [weakSelf cleanReceiveSegmentBusyStatus];
            }];
        }
        self.isReceiveSegmentPDUing = networkPdu.isSegmented;
        self.sourceOfReceiveSegmentPDU = networkPdu.source;
        if (self.commands && self.commands.count) {
            SDKLibCommand *command = self.commands.firstObject;
            [self retrySendSDKLibCommand:command];
        }
    }
}

- (void)cleanReceiveSegmentBusyStatus {
    TeLogDebug(@"");
    if (self.isReceiveSegmentPDUing) {
        TeLogDebug(@"==========RxBusy标志清除");
        self.isReceiveSegmentPDUing = NO;
        self.sourceOfReceiveSegmentPDU = 0;
        if (_receiveSegmentTimer) {
            [_receiveSegmentTimer invalidate];
            _receiveSegmentTimer = nil;
        }
        [self.networkManager.lowerTransportLayer.incompleteSegments removeAllObjects];
        [self.networkManager.lowerTransportLayer.acknowledgmentTimers removeAllObjects];
    }
}

- (void)updateOnlineStatusWithDeviceAddress:(UInt16)address deviceState:(DeviceState)state bright100:(UInt8)bright100 temperature100:(UInt8)temperature100{
    SigTelinkOnlineStatusMessage *message = [[SigTelinkOnlineStatusMessage alloc] initWithAddress:address state:state brightness:bright100 temperature:temperature100];
    SDKLibCommand *command = [self getCommandWithReceiveMessage:message fromSource:address];
    BOOL shouldCallback = NO;
    if (![command.responseSourceArray containsObject:@(address)]) {
        shouldCallback = YES;
        [command.responseSourceArray addObject:@(address)];
    }
    if (command.responseSourceArray.count >= command.responseMaxCount) {
        [self commandResponseFinishWithCommand:command];
    }
    __weak typeof(self) weakSelf = self;
    //all response message callback in this code.
    if (shouldCallback && command && command.responseAllMessageCallBack) {
        dispatch_async(dispatch_get_main_queue(), ^{
            command.responseAllMessageCallBack(address, weakSelf.dataSource.curLocationNodeModel.address, message);
        });
    }
    if (SigPublishManager.share.discoverOutlineNodeCallback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SigPublishManager.share.discoverOutlineNodeCallback(@(address));
        });
    }
    if ([self.delegateForDeveloper respondsToSelector:@selector(didReceiveMessage:sentFromSource:toDestination:)]) {
        [self.delegateForDeveloper didReceiveMessage:message sentFromSource:address toDestination:weakSelf.dataSource.curLocationNodeModel.address];
    }
}

#pragma mark - Send Mesh Messages

- (SigMessageHandle *)sendMeshMessage:(SigMeshMessage *)message fromLocalElement:(nullable SigElementModel *)localElement toDestination:(SigMeshAddress *)destination usingApplicationKey:(SigAppkeyModel *)applicationKey command:(SDKLibCommand *)command {
    UInt8 ttl = localElement.getParentNode.defaultTTL;
    if (![SigHelper.share isRelayedTTL:ttl]) {
        ttl = self.networkManager.defaultTtl;
    }
    return [self sendMeshMessage:message fromLocalElement:localElement toDestination:destination withTtl:ttl usingApplicationKey:applicationKey command:command];
}

- (SigMessageHandle *)sendMeshMessage:(SigMeshMessage *)message fromLocalElement:(nullable SigElementModel *)localElement toDestination:(SigMeshAddress *)destination withTtl:(UInt8)initialTtl usingApplicationKey:(SigAppkeyModel *)applicationKey command:(SDKLibCommand *)command {
#ifndef TESTMODE
    if (!SigBearer.share.isOpen) {
        TeLogError(@"Send fail! Mesh Network is disconnected!");
        return nil;
    }
#endif

    if (self.networkManager == nil || self.dataSource == nil) {
        TeLogError(@"Send fail! Mesh Network not created");
        return nil;
    }
    if (self.dataSource.curLocationNodeModel == nil || self.dataSource.curLocationNodeModel.elements.firstObject == nil) {
        TeLogError(@"Send fail! Local Provisioner has no Unicast Address assigned.");
        return nil;
    }
    SigNodeModel *localNode = self.dataSource.curLocationNodeModel;
    SigElementModel *source = localNode.elements.firstObject;
    if (source.getParentNode != localNode) {
        TeLogError(@"Send fail! The Element does not belong to the local Node.");
        return nil;
    }
    if (![SigHelper.share isRelayedTTL:initialTtl]) {
        TeLogError(@"Send fail! TTL value %d is invalid.",initialTtl);
        return nil;
    }
    
    [self handleResponseMaxCommands];
    command.source = source;
    command.destination = destination;
    command.initialTtl = initialTtl;
    command.curAppkey = applicationKey;
    command.commandType = SigCommandType_meshMessage;
    [self addCommandToCacheListWithCommand:command];
    SigMessageHandle *messageHandle = [[SigMessageHandle alloc] initForSDKLibCommand:command usingManager:self];
    command.messageHandle = messageHandle;
    if (self.commands && self.commands.count == 1) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(_queue, ^{
            [weakSelf.networkManager sendMeshMessage:message fromElement:source toDestination:destination withTtl:initialTtl usingApplicationKey:applicationKey command:command];
        });
    } else {
        TeLogInfo(@"The current command has been added to the queue, and there are %d %@ ahead. Please wait until the previous command processing is completed.",self.commands.count-1,self.commands.count-1>1?@"commands":@"command");
    }
    return messageHandle;
}

- (SigMessageHandle *)sendConfigMessage:(SigConfigMessage *)message toDestination:(UInt16)destination command:(SDKLibCommand *)command {
    UInt8 ttl = self.dataSource.curLocationNodeModel.defaultTTL;
    if (![SigHelper.share isRelayedTTL:ttl]) {
        ttl = self.networkManager.defaultTtl;
    }
    return [self sendConfigMessage:message toDestination:destination withTtl:ttl command:command];
}

- (SigMessageHandle *)sendConfigMessage:(SigConfigMessage *)message toDestination:(UInt16)destination withTtl:(UInt8)initialTtl command:(SDKLibCommand *)command {
#ifndef TESTMODE
    if (!SigBearer.share.isOpen) {
        TeLogError(@"Send fail! Mesh Network is disconnected!");
        return nil;
    }
#endif
    if (self.dataSource == nil) {
        TeLogError(@"Send fail! Mesh Network not created");
        return nil;
    }
    if (self.dataSource.curLocationNodeModel == nil || self.dataSource.curLocationNodeModel.address == 0) {
        TeLogError(@"Send fail! Local Provisioner has no Unicast Address assigned.");
        return nil;
    }
    if (![SigHelper.share isUnicastAddress:destination]) {
        TeLogError(@"Send fail! Address: 0x%x is not a Unicast Address.",destination);
        return nil;
    }
    if (![SigHelper.share isRelayedTTL:initialTtl]) {
        TeLogError(@"Send fail! TTL value %d is invalid.",initialTtl);
        return nil;
    }
    
    [self handleResponseMaxCommands];
    command.source = self.dataSource.curLocationNodeModel.elements.firstObject;
    command.destination = [[SigMeshAddress alloc] initWithAddress:destination];
    command.initialTtl = initialTtl;
    command.commandType = SigCommandType_configMessage;
    [self addCommandToCacheListWithCommand:command];
    SigMessageHandle *messageHandle = [[SigMessageHandle alloc] initForSDKLibCommand:command usingManager:self];
    command.messageHandle = messageHandle;
    if (self.commands && self.commands.count == 1) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(_queue, ^{
            [weakSelf.networkManager sendConfigMessage:message toDestination:destination withTtl:initialTtl command:command];
        });
    } else {
        TeLogInfo(@"The current command has been added to the queue, and there are %d %@ ahead. Please wait until the previous command processing is completed.",self.commands.count-1,self.commands.count-1>1?@"commands":@"command");
    }
    return messageHandle;
}

- (SigMessageHandle *)sendSigProxyConfigurationMessage:(SigProxyConfigurationMessage *)message command:(SDKLibCommand *)command {
#ifndef TESTMODE
    if (!SigBearer.share.isOpen) {
        TeLogError(@"Send fail! Mesh Network is disconnected!");
        return nil;
    }
#endif
    if (self.dataSource == nil) {
        TeLogError(@"Send fail! Mesh Network not created");
        return nil;
    }
    
    [self handleResponseMaxCommands];
    command.commandType = SigCommandType_proxyConfigurationMessage;
    [self addCommandToCacheListWithCommand:command];
    SigMessageHandle *messageHandle = [[SigMessageHandle alloc] initForSDKLibCommand:command usingManager:self];
    command.messageHandle = messageHandle;
    if (self.commands && self.commands.count == 1) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(_queue, ^{
            [weakSelf.networkManager sendSigProxyConfigurationMessage:message];
        });
    } else {
        TeLogInfo(@"The current command has been added to the queue, and there are %d %@ ahead. Please wait until the previous command processing is completed.",self.commands.count-1,self.commands.count-1>1?@"commands":@"command");
    }
    return messageHandle;
}

- (NSError *)sendTelinkApiGetOnlineStatueFromUUIDWithMessage:(SigMeshMessage *)message command:(SDKLibCommand *)command {
#ifndef TESTMODE
    if (!SigBearer.share.isOpen) {
        TeLogError(@"Send fail! Mesh Network is disconnected!");
        return nil;
    }
#endif
    if (self.dataSource == nil) {
        TeLogError(@"Send fail! Mesh Network not created");
        return [NSError errorWithDomain:kSigMeshLibNoCreateMeshNetworkErrorMessage code:kSigMeshLibNoCreateMeshNetworkErrorCode userInfo:nil];
    }
    
    [self handleResponseMaxCommands];
    [self addCommandToCacheListWithCommand:command];
    CBCharacteristic *onlineStatusCharacteristic = [SigBluetooth.share getCharacteristicWithUUIDString:kOnlineStatusCharacteristicsID OfPeripheral:SigBearer.share.getCurrentPeripheral];
    if (onlineStatusCharacteristic != nil) {
        uint8_t buffer[1]={1};
        NSData *data = [NSData dataWithBytes:buffer length:1];
        [SigBearer.share.getCurrentPeripheral writeValue:data forCharacteristic:onlineStatusCharacteristic type:CBCharacteristicWriteWithResponse];
        if (command.retryCount) {
            __weak typeof(self) weakSelf = self;
            BackgroundTimer *timer = [BackgroundTimer scheduledTimerWithTimeInterval:command.timeout repeats:YES block:^(BackgroundTimer * _Nonnull t) {
                if (command.hadRetryCount < command.retryCount) {
                    command.hadRetryCount ++;
                    TeLogDebug(@"command.curMeshMessage=%@,retry count=%d",command.curMeshMessage,command.hadRetryCount);
                    [SigBearer.share.getCurrentPeripheral writeValue:data forCharacteristic:onlineStatusCharacteristic type:CBCharacteristicWriteWithResponse];
                } else {
                    [weakSelf commandTimeoutWithCommand:command];
                }
            }];
            command.retryTimer = timer;
        }
        return nil;
    }else{
        return [NSError errorWithDomain:kSigMeshLibNoFoundOnlineStatusCharacteristicErrorMessage code:kSigMeshLibNoFoundOnlineStatusCharacteristicErrorCode userInfo:nil];
    }
}

- (void)cancelSigMessageHandle:(SigMessageHandle *)messageId {
    if (self.networkManager == nil) {
        TeLogError(@"Send fail! Error: Mesh Network not created.");
        return;
    }
    SDKLibCommand *command = [self getCommandWithSendMessageOpCode:messageId.opCode];
    [self commandResponseFinishWithCommand:command];
}

- (void)addCommandToCacheListWithCommand:(SDKLibCommand *)command {
    float oldTimeout = command.timeout;
    float newTimeout = [self getReliableIntervalWithDestination:command.destination.address responseMaxCount:command.responseMaxCount];
    command.timeout = MAX(oldTimeout, newTimeout);
    //command存储下来，超时或者失败，或者返回response时，从该地方拿到command，获取里面的callback，执行，再删除。
    [self.commands addObject:command];
    TeLogInfo(@"add command:%@,source=0x%X,destination=0x%X,retryCount=%d,responseMax=%d,timeout=%f,_commands.count = %d", command.curMeshMessage, command.source.unicastAddress, command.destination.address, command.retryCount, command.responseMaxCount, command.timeout, self.commands.count);
//    //存在response的指令需存储
//    if (command.responseAllMessageCallBack || command.resultCallback || (command.retryCount > 0 && command.responseMaxCount > 0)) {
//        float oldTimeout = command.timeout;
//        float newTimeout = [self getReliableIntervalWithDestination:command.destination.address responseMaxCount:command.responseMaxCount];
//        command.timeout = MAX(oldTimeout, newTimeout);
//        //command存储下来，超时或者失败，或者返回response时，从该地方拿到command，获取里面的callback，执行，再删除。
//        [self.commands addObject:command];
//    }
}

- (void)commandTimeoutWithCommand:(SDKLibCommand *)command {
    [self commandResponseFinishWithCommand:command];
    TeLogDebug(@"timeout command:%@-%@",command.curMeshMessage,command.curMeshMessage.parameters);
    NSError *error = [NSError errorWithDomain:kSigMeshLibCommandTimeoutErrorMessage code:kSigMeshLibCommandTimeoutErrorCode userInfo:nil];
    [self handleResultCallback:command error:error];
    
//    if (command.resultCallback && !command.hadReceiveAllResponse) {
//        TeLogDebug(@"timeout command:%@-%@",command.curMeshMessage,command.curMeshMessage.parameters);
//        NSError *error = [NSError errorWithDomain:kSigMeshLibCommandTimeoutErrorMessage code:kSigMeshLibCommandTimeoutErrorCode userInfo:nil];
//        command.resultCallback(NO, error);
//    }
}

- (void)commandResponseFinishWithCommand:(SDKLibCommand *)command {
    if (command.retryTimer) {
        [command.retryTimer invalidate];
        command.retryTimer = nil;
    }
    command.retryCount = 0;
    __weak typeof(self) weakSelf = self;
    if (command.commandType == SigCommandType_meshMessage || command.commandType == SigCommandType_configMessage) {
        dispatch_async(_queue, ^{
            if (command && command.messageHandle) {
                [weakSelf.networkManager cancelSigMessageHandle:command.messageHandle];
            }
        });
    }
    [self.commands removeObject:command];
    if ([self hadSendCommandsFinish]) {
        [self isBusyNow];
    }
}

- (void)handleResponseMaxCommands {
    NSArray *commands = [NSArray arrayWithArray:_commands];
    for (SDKLibCommand *com in commands) {
        if (com.responseMaxCount == 0 || com.responseMaxCount == 0xFF || com.hadReceiveAllResponse) {
            [self.commands removeObject:com];
        }
    }
}

- (BOOL)hadSendCommandsFinish {
    BOOL tem = YES;
    NSArray *commands = [NSArray arrayWithArray:_commands];
    for (SDKLibCommand *com in commands) {
        if (!com.hadReceiveAllResponse) {
            tem = NO;
            break;
        }
    }
    return tem;
}

/// cancel all commands and retry of commands and retry of segment PDU.
- (void)cleanAllCommandsAndRetry {
    TeLogDebug(@"清除commands cache.");
    NSArray *commands = [NSArray arrayWithArray:_commands];
    for (SDKLibCommand *com in commands) {
        [com.messageHandle cancel];
        [self.commands removeObject:com];
    }
}

- (void)cleanAllCommandsAndRetryWhenMeshDisconnected {
    NSArray *commands = [NSArray arrayWithArray:_commands];
    for (SDKLibCommand *com in commands) {
        [com.messageHandle cancel];
        [self.commands removeObject:com];
        if (com.resultCallback) {
            NSError *error = [NSError errorWithDomain:@"Mesh is disconnected!" code:-1 userInfo:nil];
            com.resultCallback(NO, error);
        }
    }
}

- (BOOL)isBusyNow {
    BOOL busy = ![self hadSendCommandsFinish];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyCommandIsBusyOrNot object:nil userInfo:@{kCommandIsBusyKey : @(busy)}];
    });
    return busy;
}

#define RELIABLE_INTERVAL_MS_MAX       (2000)
- (float)getReliableIntervalWithDestination:(UInt16)destination responseMaxCount:(NSInteger)responseMaxCount {
    int multiple = 1;
    if (self.dataSource.defaultUnsegmentedMessageLowerTransportPDUMaxLength > kUnsegmentedMessageLowerTransportPDUMaxLength) {
        multiple = 2;
    }
    if (destination == kMeshAddress_allNodes) {
        unsigned long maxNum = MAX(responseMaxCount, self.dataSource.curNodes.count);
        if (maxNum <= 50) {
            return 2.0 * multiple;
        } else if (maxNum <= 100) {
            return 3.0 * multiple;
        } else if (maxNum <= 150) {
            return 4.0 * multiple;
        } else {
            return 6.0 * multiple;
        }
    } else {
        if ([SigHelper.share isUnicastAddress:destination]) {
            SigNodeModel *node = [SigDataSource.share getNodeWithAddress:destination];
            if (node.features.lowPowerFeature != SigNodeFeaturesState_notSupported) {
                //LPN节点，需要修正有效重试间隔。
                return self.dataSource.defaultReliableIntervalOfLPN;
            }
        }
        
        if (responseMaxCount < 10) {
            return kCMDInterval * 4 * multiple;
        } else if (responseMaxCount <= 50) {
            return 2.0 * multiple;
        } else if (responseMaxCount <= 100) {
            return 3.0 * multiple;
        } else if (responseMaxCount <= 150) {
            return 4.0 * multiple;
        } else {
            return 6.0 * multiple;
        }
    }
}

#pragma mark - Helper methods for Bearer support

- (void)didDeliverData:(NSData *)data ofType:(SigPduType)type bearer:(SigBearer *)bearer{
    [self bearerDidDeliverData:data type:type];
}

#pragma mark - SigMessageDelegate

- (void)didReceiveMessage:(SigMeshMessage *)message sentFromSource:(UInt16)source toDestination:(UInt16)destination {
    TeLogInfo(@"didReceiveMessage=%@,message.parameters=%@,source=0x%x,destination=0x%x", message, message.parameters, source,destination);
    SigNodeModel *node = [self.dataSource getNodeWithAddress:source];

    //根据设备是否打开了publish功能来判断是否给该设备添加监测离线的定时器。
    if (message.opCode == SigOpCode_lightCTLStatus || message.opCode == SigOpCode_lightHSLStatus || message.opCode == SigOpCode_lightLightnessStatus || message.opCode == SigOpCode_genericOnOffStatus) {
        if (node && node.hasOpenPublish) {
            [SigPublishManager.share startCheckOfflineTimerWithAddress:@(source)];
        }
    }
    
    SDKLibCommand *command = [self getCommandWithReceiveMessage:message fromSource:(UInt16)source];
    BOOL shouldCallback = NO;
    if (command && ![command.responseSourceArray containsObject:@(source)]) {
        shouldCallback = YES;
        //node may delete from SigDataSource, but no reset from mesh network.
        if (node) {
            [command.responseSourceArray addObject:@(source)];
        } else if (message.opCode > 0xFFFF) {//vendor model
            [command.responseSourceArray addObject:@(source)];
        }
    }
    //update status to SigDataSource before callback.
    [self.dataSource updateNodeStatusWithBaseMeshMessage:message source:source];
    //非直连设备断电，再上电后设备端会主动上报0x824E。
    if (message.opCode == SigOpCode_lightLightnessStatus) {
        if (SigPublishManager.share.discoverOnlineNodeCallback) {
            SigPublishManager.share.discoverOnlineNodeCallback(@(source));
        }
    }

    //all response message callback in this code.
    if (shouldCallback && command && command.responseAllMessageCallBack) {
        dispatch_async(dispatch_get_main_queue(), ^{
            command.responseAllMessageCallBack(source, destination, message);
        });
    }
    if (command.responseMaxCount != 0) {
//        if (command && command.responseSourceArray.count >= command.responseMaxCount) {
        //优化：当实际回调的response多于传入的responseMaxCount时，使用==判断即可实现只回调一次resultCallback。
        if (command && command.responseSourceArray.count == command.responseMaxCount) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self commandResponseFinishWithCommand:command];
                [self handleResultCallback:command error:nil];
//                if (command.resultCallback) {
//                    command.resultCallback(YES, nil);
//                }
            });
        }
    } else {
        //command.responseMaxCount = 0的command已经在didSend回调处处理了resultCallback，该处无需重复处理。
        command.hadReceiveAllResponse = YES;
        if (command.retryTimer) {
            [command.retryTimer invalidate];
            command.retryTimer = nil;
        }
    }

}

- (void)didSendMessage:(SigMeshMessage *)message fromLocalElement:(SigElementModel *)localElement toDestination:(UInt16)destination {
    TeLogInfo(@"didSendMessage=%@,class=%@,source=0x%x,destination=0x%x", message, message.class, localElement.unicastAddress, destination);
    SDKLibCommand *command = [self getCommandWithSendMessage:message];
    if (command.retryCount > 0 || (command.retryCount == 0 && command.responseMaxCount > 0)) {
        // 需要重试或者等待timeout
        [self retrySendSDKLibCommand:command];
    } else {
        // 无需重试，返回发送成功。
        BOOL shouldCallback = NO;
        if (command && (command.retryCount == 0 && command.responseMaxCount == 0)) {
            shouldCallback = YES;
        }
        if (command && destination == localElement.unicastAddress) {
            shouldCallback = YES;
        }
        if (command && shouldCallback) {
//            dispatch_async(dispatch_get_main_queue(), ^{
                [self commandResponseFinishWithCommand:command];
//            });
        }

        //send finished of noAckMessage callback in this code.
        if (shouldCallback) {
            [self handleResultCallback:command error:nil];
        }
    }
}

- (void)failedToSendMessage:(SigMeshMessage *)message fromLocalElement:(SigElementModel *)localElement toDestination:(UInt16)destination error:(NSError *)error {
    TeLogInfo(@"failedToSendMessage=%@,class=%@,source=0x%x,destination=0x%x", message, message.class, localElement.unicastAddress, destination);
    SDKLibCommand *command = [self getCommandWithSendMessage:message];
    if (command.retryCount > 0) {
        // 需要重试
        [self retrySendSDKLibCommand:command];
    } else {
        // 无需重试，返回发送成功。
        command.hadReceiveAllResponse = YES;
        [self handleResultCallback:command error:error];
    }
}

- (void)didReceiveSigProxyConfigurationMessage:(SigProxyConfigurationMessage *)message sentFromSource:(UInt16)source toDestination:(UInt16)destination {
    TeLogInfo(@"didReceiveSigProxyConfigurationMessage=%@,message.parameters=%@,source=0x%x,destination=0x%x", message, message.parameters, source,destination);
    SDKLibCommand *command = [self getCommandWithReceiveMessage:(SigMeshMessage *)message fromSource:source];
    [self commandResponseFinishWithCommand:command];

    //callback
    if (command && command.responseFilterStatusCallBack) {
        command.responseFilterStatusCallBack(source,destination,(SigFilterStatus *)message);
    }
    [self handleResultCallback:command error:nil];
}

- (void)handleResultCallback:(SDKLibCommand *)command error:(NSError *)error {
    [self.commands removeObject:command];
    BOOL hasNextCommand = NO;
    if (self.commands && self.commands.count > 0) {
        hasNextCommand = YES;
    }
    if (command && command.resultCallback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                command.resultCallback(NO, error);
            } else {
                command.resultCallback(YES, nil);
            }
        });
    }
    if (hasNextCommand) {
        SDKLibCommand *nextCommand = self.commands.firstObject;
        __weak typeof(self) weakSelf = self;
        if (nextCommand.commandType == SigCommandType_meshMessage) {
            dispatch_async(_queue, ^{
                [weakSelf.networkManager sendMeshMessage:(SigMeshMessage *)nextCommand.curMeshMessage fromElement:nextCommand.source toDestination:nextCommand.destination withTtl:nextCommand.initialTtl usingApplicationKey:nextCommand.curAppkey command:nextCommand];
            });
        } else if (nextCommand.commandType == SigCommandType_configMessage) {
            dispatch_async(_queue, ^{
                [weakSelf.networkManager sendConfigMessage:(SigConfigMessage *)nextCommand.curMeshMessage toDestination:nextCommand.destination.address withTtl:nextCommand.initialTtl command:nextCommand];
            });
        } else if (nextCommand.commandType == SigCommandType_proxyConfigurationMessage) {
            dispatch_async(_queue, ^{
                [weakSelf.networkManager sendSigProxyConfigurationMessage:(SigProxyConfigurationMessage *)nextCommand.curMeshMessage];
            });
        }
    }
}

#pragma mark - Private

- (SDKLibCommand *)getCommandWithReceiveMessage:(SigMeshMessage *)message fromSource:(UInt16)source {
    SDKLibCommand *tem = nil;
    if ([message isKindOfClass:[SigConfigMessage class]]) {
        NSArray *commands = [NSArray arrayWithArray:_commands];
        for (SDKLibCommand *com in commands) {
            if ((((SigConfigMessage *)com.curMeshMessage).responseOpCode == message.opCode) && (![SigHelper.share isUnicastAddress:com.destination.address] || ([SigHelper.share isUnicastAddress:com.destination.address] && com.destination.address == source))) {
                tem = com;
                break;
            }
        }
    } else if ([message isKindOfClass:[SigGenericMessage class]]) {
        NSArray *commands = [NSArray arrayWithArray:_commands];
        for (SDKLibCommand *com in commands) {
            if ([SigHelper.share isAcknowledgedMessage:(SigMeshMessage *)com.curMeshMessage] && ((SigAcknowledgedGenericMessage *)com.curMeshMessage).responseOpCode == message.opCode  && (![SigHelper.share isUnicastAddress:com.destination.address] || ([SigHelper.share isUnicastAddress:com.destination.address] && com.destination.address == source))) {
                tem = com;
                break;
            }
        }
    } else if ([message isKindOfClass:[SigFilterStatus class]]) {
        NSArray *commands = [NSArray arrayWithArray:_commands];
        for (SDKLibCommand *com in commands) {
            if ([com.curMeshMessage isKindOfClass:[SigStaticAcknowledgedProxyConfigurationMessage class]]) {
                if (((SigStaticAcknowledgedProxyConfigurationMessage *)com.curMeshMessage).responseOpCode == message.opCode  && (![SigHelper.share isUnicastAddress:com.destination.address] || ([SigHelper.share isUnicastAddress:com.destination.address] && com.destination.address == source))) {
                    tem = com;
                    break;
                }
            }
        }
    } else if ([message isKindOfClass:[SigTelinkOnlineStatusMessage class]]){//私有定制onlineStatus回包
        NSArray *commands = [NSArray arrayWithArray:_commands];
        for (SDKLibCommand *com in commands) {
            if ([com.curMeshMessage isMemberOfClass:[SigGenericOnOffGet class]]) {
                tem = com;
                break;
            }
        }
    } else if ([message isKindOfClass:[SigUnknownMessage class]]) {//未定义的vendor回包
        NSArray *commands = [NSArray arrayWithArray:_commands];
        for (SDKLibCommand *com in commands) {
            if ((((SigIniMeshMessage *)com.curMeshMessage).responseOpCode == message.opCode || ((SigIniMeshMessage *)com.curMeshMessage).responseOpCode == ((message.opCode >> 16) & 0xFF))  && (![SigHelper.share isUnicastAddress:com.destination.address] || ([SigHelper.share isUnicastAddress:com.destination.address] && com.destination.address == source))) {
                tem = com;
                break;
            }
        }
    }
    return tem;
}

- (SDKLibCommand *)getCommandWithSendMessage:(SigMeshMessage *)message {
    SDKLibCommand *tem = nil;
    if ([message isKindOfClass:[SigConfigMessage class]]) {
        NSArray *commands = [NSArray arrayWithArray:_commands];
        for (SDKLibCommand *com in commands) {
            if (((SigConfigMessage *)com.curMeshMessage).opCode == message.opCode) {
                tem = com;
                break;
            }
        }
    } else if ([message isKindOfClass:[SigAcknowledgedGenericMessage class]]) {
        NSArray *commands = [NSArray arrayWithArray:_commands];
        for (SDKLibCommand *com in commands) {
            if (((SigAcknowledgedGenericMessage *)com.curMeshMessage).opCode == message.opCode) {
                tem = com;
                break;
            }
        }
    } else if ([message isKindOfClass:[SigIniMeshMessage class]]) {
        NSArray *commands = [NSArray arrayWithArray:_commands];
        for (SDKLibCommand *com in commands) {
            if (((SigIniMeshMessage *)com.curMeshMessage).opCode == message.opCode) {
                tem = com;
                break;
            }
        }
    } else if ([message isKindOfClass:[SigMeshMessage class]]) {
           NSArray *commands = [NSArray arrayWithArray:_commands];
           for (SDKLibCommand *com in commands) {
               if (((SigMeshMessage *)com.curMeshMessage).opCode == message.opCode) {
                   tem = com;
                   break;
               }
           }
    } else if ([message isKindOfClass:[SigProxyConfigurationMessage class]]) {
              NSArray *commands = [NSArray arrayWithArray:_commands];
              for (SDKLibCommand *com in commands) {
                  if (((SigProxyConfigurationMessage *)com.curMeshMessage).opCode == message.opCode) {
                      tem = com;
                      break;
                  }
              }
       }
    return tem;
}

- (SDKLibCommand *)getCommandWithSendMessageOpCode:(UInt32)sendOpCode {
    SDKLibCommand *tem = nil;
    NSArray *commands = [NSArray arrayWithArray:_commands];
    for (SDKLibCommand *com in commands) {
        if ([com.curMeshMessage isKindOfClass:[SigMeshMessage class]]) {
            if (((SigMeshMessage *)com.curMeshMessage).opCode == sendOpCode) {
                tem = com;
                break;
            }
        }
    }
    return tem;
}

- (void)retrySendSDKLibCommand:(SDKLibCommand *)command {
    __weak typeof(self) weakSelf = self;
    if (command && command.retryTimer) {
        [command.retryTimer invalidate];
        command.retryTimer = nil;
    }
    if (command.hadRetryCount >= command.retryCount) {
        // 重试完成，一个command.timeout没有足够response则报超时。
        BackgroundTimer *timer = [BackgroundTimer scheduledTimerWithTimeInterval:command.timeout repeats:NO block:^(BackgroundTimer * _Nonnull t) {
            [weakSelf commandTimeoutWithCommand:command];
        }];
        command.retryTimer = timer;
    } else {
        // 重试未完成，继续重试。
        BackgroundTimer *timer = [BackgroundTimer scheduledTimerWithTimeInterval:command.timeout repeats:NO block:^(BackgroundTimer * _Nonnull t) {
            if (command.hadRetryCount < command.retryCount) {
                command.hadRetryCount ++;
                TeLogDebug(@"command.curMeshMessage=%@,retry count=%d",command.curMeshMessage,command.hadRetryCount);
                dispatch_async(weakSelf.queue, ^{
                    [weakSelf.networkManager cancelSigMessageHandle:command.messageHandle];
                    if (command.commandType == SigCommandType_meshMessage) {
                        [weakSelf.networkManager sendMeshMessage:(SigMeshMessage *)command.curMeshMessage fromElement:command.source toDestination:command.destination withTtl:command.initialTtl usingApplicationKey:command.curAppkey command:command];
                    } else if (command.commandType == SigCommandType_configMessage) {
                        [weakSelf.networkManager sendConfigMessage:(SigConfigMessage *)command.curMeshMessage toDestination:command.destination.address withTtl:command.initialTtl command:command];
                    } else if (command.commandType == SigCommandType_proxyConfigurationMessage) {
                        [weakSelf.networkManager sendSigProxyConfigurationMessage:(SigProxyConfigurationMessage *)command.curMeshMessage];
                    }
                });
            } else {
                TeLogError(@"retry error!");
            }
        }];
        command.retryTimer = timer;
    }
}

@end
