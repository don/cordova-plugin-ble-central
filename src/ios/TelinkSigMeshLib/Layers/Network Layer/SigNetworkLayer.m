/********************************************************************************************************
 * @file     SigNetworkLayer.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/9/9
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

#import "SigNetworkLayer.h"
#import "SigNetworkManager.h"
#import "SigMeshLib.h"
#import "SigLowerTransportLayer.h"
#import "SigLowerTransportPdu.h"
#import "SigControlMessage.h"
#import "SigSegmentAcknowledgmentMessage.h"

@interface SigNetworkLayer ()
@property (nonatomic,assign) NSInteger networkTransmitCount;
//@property (nonatomic,strong) SigNetkeyModel *proxyNetworkKey;
@property (nonatomic,strong) NSMutableArray <BackgroundTimer *>*networkTransmitTimers;
@end

@implementation SigNetworkLayer

- (NSMutableArray<BackgroundTimer *> *)networkTransmitTimers {
    if (!_networkTransmitTimers) {
        _networkTransmitTimers = [NSMutableArray array];
    }
    return _networkTransmitTimers;
}

- (instancetype)initWithNetworkManager:(SigNetworkManager *)networkManager {
    if (self = [super init]) {
        _networkManager = networkManager;
        _meshNetwork = networkManager.manager.dataSource;
//        _defaults = [NSUserDefaults standardUserDefaults];
//        _networkMessageCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)handleIncomingPdu:(NSData *)pdu ofType:(SigPduType)type {
    if (_networkManager.manager.dataSource == nil) {
        TeLogError(@"this networkManager has not data.");
        return;
    }
    if (type == SigPduType_provisioningPdu) {
        TeLogError(@"Provisioning is handled using ProvisioningManager.");
        return;
    }
    
//    // Secure Network Beacons can repeat whenever the device connects to a new Proxy.
//    if (type != SigPduType_meshBeacon) {
//        // Ensure the PDU has not been handled already.
//        if ([_networkMessageCache objectForKey:pdu] != nil) {
//            TeLogDebug(@"PDU has already been handled.");
//            return;
//        }
//        [_networkMessageCache setObject:[[NSNull alloc] init] forKey:pdu];
//    }
    
    // Try decoding the PDU.
    switch (type) {
        case SigPduType_networkPdu:
            {
//                TeLogDebug(@"receive networkPdu");
                //两个不同netkey进行解包（fast provision需要）:先使用mesh的networkKey进行解密，再使用当前networkLayer特定networkKey和ivIndex进行解密。
                SigNetworkPdu *networkPdu = [SigNetworkPdu decodePdu:pdu pduType:SigPduType_networkPdu forMeshNetwork:_meshNetwork];
                if (!networkPdu && _networkKey && _ivIndex) {
                    networkPdu = [SigNetworkPdu decodePdu:pdu pduType:SigPduType_networkPdu usingNetworkKey:_networkKey ivIndex:_ivIndex];
                }
                if (networkPdu == nil) {
                    TeLogDebug(@"decodePdu fail.");
                    return;
                }
                [_networkManager.lowerTransportLayer handleNetworkPdu:networkPdu];
//                [SigMeshLib.share receiveNetworkPdu:networkPdu];
            }
            break;
        case SigPduType_meshBeacon:
            {
//                TeLogVerbose(@"receive meshBeacon");
                UInt8 tem = 0;
                Byte *pduByte = (Byte *)pdu.bytes;
                memcpy(&tem, pduByte, 1);
                SigBeaconType beaconType = tem;
                if (beaconType == SigBeaconType_secureNetwork) {
                    SigSecureNetworkBeacon *beaconPdu = [SigSecureNetworkBeacon decodePdu:pdu forMeshNetwork:_meshNetwork];
                    if (beaconPdu != nil) {
                        [self handleSecureNetworkBeacon:beaconPdu];
                        return;
                    }
                } else if (beaconType == SigBeaconType_unprovisionedDevice) {
                    SigUnprovisionedDeviceBeacon *unprovisionedBeacon = [SigUnprovisionedDeviceBeacon decodeWithPdu:pdu forMeshNetwork:_meshNetwork];
                    if (unprovisionedBeacon != nil) {
                        [self handleUnprovisionedDeviceBeacon:unprovisionedBeacon];
                        return;
                    }
                } else if (beaconType == SigBeaconType_meshPrivateBeacon) {
                    SigMeshPrivateBeacon *privateBeacon = [SigMeshPrivateBeacon decodePdu:pdu forMeshNetwork:_meshNetwork];
                    if (privateBeacon != nil) {
                        [self handleMeshPrivateBeacon:privateBeacon];
                        return;
                    }
                }
                TeLogError(@"Invalid or unsupported beacon type.");
            }
            break;
        case SigPduType_proxyConfiguration:
            {
//                TeLogVerbose(@"receive proxyConfiguration");
                SigNetworkPdu *proxyPdu = [SigNetworkPdu decodePdu:pdu pduType:type forMeshNetwork:_meshNetwork];
                if (proxyPdu == nil) {
                    TeLogInfo(@"Failed to decrypt proxy PDU");
                    return;
                }
//                TeLogVerbose(@"%@ received",proxyPdu);
                [self handleSigProxyConfigurationPdu:proxyPdu];
            }
            break;
        default:
            TeLogDebug(@"pdu not handle.");
            break;
    }
}

- (void)sendLowerTransportPdu:(SigLowerTransportPdu *)pdu ofType:(SigPduType)type withTtl:(UInt8)ttl ivIndex:(SigIvIndex *)ivIndex {
    _ivIndex = ivIndex;
    _networkKey = pdu.networkKey;
    
    // Get the current sequence number for local Provisioner's source address.
    UInt32 sequence = (UInt32)[SigMeshLib.share.dataSource getCurrentProvisionerIntSequenceNumber];
    // As the sequence number was just used, it has to be incremented.
    [SigMeshLib.share.dataSource updateCurrentProvisionerIntSequenceNumber:sequence+1];

//    TeLogDebug(@"pdu,sequence=0x%x,ttl=%d",sequence,ttl);
    SigNetworkPdu *networkPdu = [[SigNetworkPdu alloc] initWithEncodeLowerTransportPdu:pdu pduType:type withSequence:sequence andTtl:ttl ivIndex:ivIndex];
    pdu.networkPdu = networkPdu;
    
    // Loopback interface.
    if ([self shouldLoopback:networkPdu]) {
        //==========telink not need this==========//
//        [self handleIncomingPdu:networkPdu.pduData ofType:type];
        //==========telink not need this==========//
        if ([self isLocalUnicastAddress:networkPdu.destination]) {
            // No need to send messages targetting local Unicast Addresses.
            TeLogVerbose(@"No need to send messages targetting local Unicast Addresses.");
            return;
        }
        [SigBearer.share sendBlePdu:networkPdu ofType:type];
    }else{
        [SigBearer.share sendBlePdu:networkPdu ofType:type];
    }

    // SDK need use networkTransmit in gatt provision.
    SigNetworktransmitModel *networkTransmit = _meshNetwork.curLocationNodeModel.networkTransmit;
    if (type == SigPduType_networkPdu && networkTransmit != nil && networkTransmit.networkTransmitCount > 1 && !SigBearer.share.isProvisioned) {
        self.networkTransmitCount = networkTransmit.networkTransmitCount;
        __block NSInteger count = networkTransmit.networkTransmitCount;
        __weak typeof(self) weakSelf = self;
        BackgroundTimer *timer = [BackgroundTimer scheduledTimerWithTimeInterval:networkTransmit.networkTransmitIntervalSteps repeats:YES block:^(BackgroundTimer * _Nonnull t) {
            [SigBearer.share sendBlePdu:networkPdu ofType:type];
            count -= 1;
            if (count == 0) {
                [weakSelf.networkTransmitTimers removeObject:t];
                if (t) {
                    [t invalidate];
                }
            }
        }];
        [self.networkTransmitTimers addObject:timer];
    }
}

- (void)sendLowerTransportPdu:(SigLowerTransportPdu *)pdu ofType:(SigPduType)type withTtl:(UInt8)ttl {
    if ([pdu isMemberOfClass:[SigSegmentAcknowledgmentMessage class]]) {
        if (SigBearer.share.isSending) {
            self.lastNeedSendAckMessage = (SigSegmentAcknowledgmentMessage *)pdu;
            return;
        } else {
            self.lastNeedSendAckMessage = nil;
        }
    }
    
    _ivIndex = SigMeshLib.share.dataSource.curNetkeyModel.ivIndex;
    _networkKey = pdu.networkKey;
    if (pdu.ivIndex == nil) {
        pdu.ivIndex = _ivIndex;
    }
    
    // Get the current sequence number for local Provisioner's source address.
    UInt32 sequence = (UInt32)[SigMeshLib.share.dataSource getCurrentProvisionerIntSequenceNumber];
    // As the sequnce number was just used, it has to be incremented.
    [SigMeshLib.share.dataSource updateCurrentProvisionerIntSequenceNumber:sequence+1];

//    TeLogVerbose(@"pdu,sequence=0x%x,ttl=%d",sequence,ttl);
//    SigNetworkPdu *networkPdu = [[SigNetworkPdu alloc] initWithEncodeLowerTransportPdu:pdu pduType:type withSequence:sequence andTtl:ttl];
    if (pdu.networkKey == nil || pdu.ivIndex == nil) {
        TeLogError(@"networkKey or ivIndex error!!!");
    }
    SigNetworkPdu *networkPdu = [[SigNetworkPdu alloc] initWithEncodeLowerTransportPdu:pdu pduType:type withSequence:sequence andTtl:ttl ivIndex:pdu.ivIndex];
    pdu.networkPdu = networkPdu;
    // Loopback interface.
    if ([self shouldLoopback:networkPdu]) {
        //==========telink not need this==========//
//        [self handleIncomingPdu:networkPdu.pduData ofType:type];
        //==========telink not need this==========//
        if ([self isLocalUnicastAddress:networkPdu.destination]) {
            // No need to send messages targetting local Unicast Addresses.
            TeLogError(@"No need to send messages targetting local Unicast Addresses.");
            return;
        }
        [SigBearer.share sendBlePdu:networkPdu ofType:type];
    }else{
        [SigBearer.share sendBlePdu:networkPdu ofType:type];
    }
    if (self.lastNeedSendAckMessage) {
        //发包过程中收到segment的结束包，优先把当前包发送完成，再发送ack包。
        TeLogDebug(@"==========灵活处理中间的ack数据包。")
        SigNodeModel *provisionerNode = SigMeshLib.share.dataSource.curLocationNodeModel;
        UInt8 ttl = provisionerNode.defaultTTL;
        if (ttl < 2) {
            ttl = 10;
        }
        [self sendLowerTransportPdu:self.lastNeedSendAckMessage ofType:SigPduType_networkPdu withTtl:ttl];
    }
    
    // SDK need use networkTransmit in gatt provision.
    SigNetworktransmitModel *networkTransmit = _meshNetwork.curLocationNodeModel.networkTransmit;
    if (type == SigPduType_networkPdu && networkTransmit != nil && networkTransmit.networkTransmitCount > 1 && !SigBearer.share.isProvisioned) {
        self.networkTransmitCount = networkTransmit.networkTransmitCount;
        __block NSInteger count = networkTransmit.networkTransmitCount;
        __weak typeof(self) weakSelf = self;
        BackgroundTimer *timer = [BackgroundTimer scheduledTimerWithTimeInterval:networkTransmit.networkTransmitIntervalSteps repeats:YES block:^(BackgroundTimer * _Nonnull t) {
            [SigBearer.share sendBlePdu:networkPdu ofType:type];
            count -= 1;
            if (count == 0) {
                [weakSelf.networkTransmitTimers removeObject:t];
                if (t) {
                    [t invalidate];
                }
            }
        }];
        [self.networkTransmitTimers addObject:timer];
    }
}

/// This method tries to send the Proxy Configuration Message.
///
/// The Proxy Filter object will be informed about the success or a failure.
///
/// - parameter message: The Proxy Confifuration message to be sent.
- (void)sendSigProxyConfigurationMessage:(SigProxyConfigurationMessage *)message {
//    SigNetkeyModel *networkKey = _proxyNetworkKey;
    SigNetkeyModel *networkKey = _meshNetwork.curNetkeyModel;

    // If the Provisioner does not have a Unicast Address, just use a fake one
    // to configure the Proxy Server. This allows sniffing the network without
    // an option to send messages.
    UInt16 source = _meshNetwork.curLocationNodeModel.address != 0 ? _meshNetwork.curLocationNodeModel.address : MeshAddress_maxUnicastAddress;
    SigControlMessage *pdu = [[SigControlMessage alloc] initFromProxyConfigurationMessage:message sentFromSource:source usingNetworkKey:networkKey];
    pdu.ivIndex = SigMeshLib.share.dataSource.curNetkeyModel.ivIndex;
    TeLogInfo(@"Sending %@%@ from: 0x%x to: 0000,ivIndex=0x%x",message,message.parameters,source,pdu.ivIndex.index);
    [self sendLowerTransportPdu:pdu ofType:SigPduType_proxyConfiguration withTtl:0];
    [_networkManager notifyAboutDeliveringMessage:(SigMeshMessage *)message fromLocalElement:SigMeshLib.share.dataSource.curLocationNodeModel.elements.firstObject toDestination:pdu.destination];
}

#pragma mark - private

- (void)handleUnprovisionedDeviceBeacon:(SigUnprovisionedDeviceBeacon *)unprovisionedDeviceBeacon {
    // TODO: Handle Unprovisioned Device Beacon.
}

- (void)handleMeshPrivateBeacon:(SigMeshPrivateBeacon *)meshPrivateBeacon {
    SigNetkeyModel *networkKey = meshPrivateBeacon.networkKey;
    if (meshPrivateBeacon.ivIndex < networkKey.ivIndex.index || ABS(meshPrivateBeacon.ivIndex-networkKey.ivIndex.index) > 42) {
        TeLogError(@"Discarding mesh private beacon (ivIndex: 0x%x, expected >= 0x%x)",(unsigned int)meshPrivateBeacon.ivIndex,(unsigned int)networkKey.ivIndex.index);
        if (SigMeshLib.share.dataSource.getCurrentProvisionerIntSequenceNumber >= 0xc00000) {
            SigMeshPrivateBeacon *beacon = [[SigMeshPrivateBeacon alloc] initWithKeyRefreshFlag:NO ivUpdateActive:YES ivIndex:networkKey.ivIndex.index+1 randomData:[LibTools createRandomDataWithLength:13] usingNetworkKey:networkKey];
            SigMeshLib.share.meshPrivateBeacon = beacon;
        } else {
            SigMeshPrivateBeacon *beacon = [[SigMeshPrivateBeacon alloc] initWithKeyRefreshFlag:NO ivUpdateActive:NO ivIndex:networkKey.ivIndex.index randomData:[LibTools createRandomDataWithLength:13] usingNetworkKey:networkKey];
            SigMeshLib.share.meshPrivateBeacon = beacon;
        }
        if ([_networkManager.manager.delegateForDeveloper respondsToSelector:@selector(didReceiveSigMeshPrivateBeaconMessage:)]) {
            [_networkManager.manager.delegateForDeveloper didReceiveSigMeshPrivateBeaconMessage:meshPrivateBeacon];
        }
        return;
    }
    SigMeshLib.share.meshPrivateBeacon = meshPrivateBeacon;
    SigIvIndex *ivIndex = [[SigIvIndex alloc] initWithIndex:meshPrivateBeacon.ivIndex updateActive:meshPrivateBeacon.ivUpdateActive];
    networkKey.ivIndex = ivIndex;
    TeLogVerbose(@"receive mesh private Beacon, ivIndex=0x%x,updateActive=%d",ivIndex.index,ivIndex.updateActive);

    // If the Key Refresh Procedure is in progress, and the new Network Key
    // has already been set, the key erfresh flag indicates switching to phase 2.
    if (networkKey.phase == distributingKeys && meshPrivateBeacon.keyRefreshFlag) {
        networkKey.phase = finalizing;
    }
    // If the Key Refresh Procedure is in phase 2, and the key refresh flag is
    // set to false.
    if (networkKey.phase == finalizing && !meshPrivateBeacon.keyRefreshFlag) {
        networkKey.oldKey = nil;//This will set the phase to .normalOperation.
    }

    if (meshPrivateBeacon.ivIndex > SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.index) {
        if (meshPrivateBeacon.ivUpdateActive) {
            if (SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.index != meshPrivateBeacon.ivIndex - 1) {
                SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.updateActive = NO;
                SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.index = meshPrivateBeacon.ivIndex - 1;
                [SigMeshLib.share.dataSource updateIvIndexString:[NSString stringWithFormat:@"%08X",(unsigned int)meshPrivateBeacon.ivIndex - 1]];
            }
        } else {
            SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.updateActive = meshPrivateBeacon.ivUpdateActive;
            SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.index = meshPrivateBeacon.ivIndex;
            [SigMeshLib.share.dataSource updateIvIndexString:[NSString stringWithFormat:@"%08X",(unsigned int)meshPrivateBeacon.ivIndex]];
        }
    }

    if (meshPrivateBeacon.keyRefreshFlag) {
        SigMeshLib.share.dataSource.curNetkeyModel.key = meshPrivateBeacon.networkKey.key;
    }
    if ([_networkManager.manager.delegate respondsToSelector:@selector(didReceiveSigMeshPrivateBeaconMessage:)]) {
        [_networkManager.manager.delegate didReceiveSigMeshPrivateBeaconMessage:meshPrivateBeacon];
    }
    if ([_networkManager.manager.delegateForDeveloper respondsToSelector:@selector(didReceiveSigMeshPrivateBeaconMessage:)]) {
        [_networkManager.manager.delegateForDeveloper didReceiveSigMeshPrivateBeaconMessage:meshPrivateBeacon];
    }
}

/// This method handles the Secure Network Beacon. It will set the proper IV Index and IV Update Active flag for the Network Key that matches Network ID and change the Key Refresh Phase based on the key refresh flag specified in the beacon.
/// @param secureNetworkBeacon The Secure Network Beacon received.
- (void)handleSecureNetworkBeacon:(SigSecureNetworkBeacon *)secureNetworkBeacon {
    SigNetkeyModel *networkKey = secureNetworkBeacon.networkKey;
    if (secureNetworkBeacon.ivIndex < networkKey.ivIndex.index || ABS(secureNetworkBeacon.ivIndex-networkKey.ivIndex.index) > 42) {
        TeLogError(@"Discarding secure network beacon (ivIndex: 0x%x, expected >= 0x%x)",(unsigned int)secureNetworkBeacon.ivIndex,(unsigned int)networkKey.ivIndex.index);
        if (SigMeshLib.share.dataSource.getCurrentProvisionerIntSequenceNumber >= 0xc00000) {
            SigSecureNetworkBeacon *beacon = [[SigSecureNetworkBeacon alloc] initWithKeyRefreshFlag:NO ivUpdateActive:YES networkId:networkKey.networkId ivIndex:networkKey.ivIndex.index+1 usingNetworkKey:networkKey];
            SigMeshLib.share.secureNetworkBeacon = beacon;
        } else {
            SigSecureNetworkBeacon *beacon = [[SigSecureNetworkBeacon alloc] initWithKeyRefreshFlag:NO ivUpdateActive:NO networkId:networkKey.networkId ivIndex:networkKey.ivIndex.index usingNetworkKey:networkKey];
            SigMeshLib.share.secureNetworkBeacon = beacon;
        }
        if ([_networkManager.manager.delegateForDeveloper respondsToSelector:@selector(didReceiveSigSecureNetworkBeaconMessage:)]) {
            [_networkManager.manager.delegateForDeveloper didReceiveSigSecureNetworkBeaconMessage:secureNetworkBeacon];
        }
        return;
    }
    SigMeshLib.share.secureNetworkBeacon = secureNetworkBeacon;
    SigIvIndex *ivIndex = [[SigIvIndex alloc] initWithIndex:secureNetworkBeacon.ivIndex updateActive:secureNetworkBeacon.ivUpdateActive];
    networkKey.ivIndex = ivIndex;
    TeLogVerbose(@"receive secure Network Beacon, ivIndex=0x%x,updateActive=%d",ivIndex.index,ivIndex.updateActive);

    // If the Key Refresh Procedure is in progress, and the new Network Key
    // has already been set, the key erfresh flag indicates switching to phase 2.
    if (networkKey.phase == distributingKeys && secureNetworkBeacon.keyRefreshFlag) {
        networkKey.phase = finalizing;
    }
    // If the Key Refresh Procedure is in phase 2, and the key refresh flag is
    // set to false.
    if (networkKey.phase == finalizing && !secureNetworkBeacon.keyRefreshFlag) {
        networkKey.oldKey = nil;//This will set the phase to .normalOperation.
    }
    
    if (secureNetworkBeacon.ivIndex > SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.index) {
        if (secureNetworkBeacon.ivUpdateActive) {
            if (SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.index != secureNetworkBeacon.ivIndex - 1) {
                SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.updateActive = NO;
                SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.index = secureNetworkBeacon.ivIndex - 1;
                [SigMeshLib.share.dataSource updateIvIndexString:[NSString stringWithFormat:@"%08X",(unsigned int)secureNetworkBeacon.ivIndex - 1]];
            }
        } else {
            SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.updateActive = secureNetworkBeacon.ivUpdateActive;
            SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.index = secureNetworkBeacon.ivIndex;
            [SigMeshLib.share.dataSource updateIvIndexString:[NSString stringWithFormat:@"%08X",(unsigned int)secureNetworkBeacon.ivIndex]];
        }
    }
    if (secureNetworkBeacon.keyRefreshFlag) {
        SigMeshLib.share.dataSource.curNetkeyModel.key = secureNetworkBeacon.networkKey.key;
    }
    if ([_networkManager.manager.delegate respondsToSelector:@selector(didReceiveSigSecureNetworkBeaconMessage:)]) {
        [_networkManager.manager.delegate didReceiveSigSecureNetworkBeaconMessage:secureNetworkBeacon];
    }
    if ([_networkManager.manager.delegateForDeveloper respondsToSelector:@selector(didReceiveSigSecureNetworkBeaconMessage:)]) {
        [_networkManager.manager.delegateForDeveloper didReceiveSigSecureNetworkBeaconMessage:secureNetworkBeacon];
    }

//    [self updateProxyFilterUsingNetworkKey:networkKey];
}

/// Handles the received Proxy Configuration PDU.
///
/// This method parses the payload and instantiates a message class.
/// The message is passed to the `ProxyFilter` for processing.
///
/// - parameter proxyPdu: The received Proxy Configuration PDU.
- (void)handleSigProxyConfigurationPdu:(SigNetworkPdu *)proxyPdu {
    NSData *payload = proxyPdu.transportPdu;
    if (payload.length <= 1) {
        TeLogError(@"payload.length <= 1");
        return;
    }
    SigControlMessage *controlMessage = [[SigControlMessage alloc] initFromNetworkPdu:proxyPdu];
    if (controlMessage == nil) {
        TeLogError(@"controlMessage == nil");
        return;
    }
//    TeLogInfo(@"%@ receieved (decrypted using key: %@)",controlMessage,controlMessage.networkKey);
    SigFilterStatus *filterStatus = [[SigFilterStatus alloc] init];
    if (controlMessage.opCode == filterStatus.opCode) {
        SigFilterStatus *message = [[SigFilterStatus alloc] initWithParameters:controlMessage.upperTransportPdu];
//        TeLogVerbose(@"%@ received SigFilterStatus data:%@ from: 0x%x to: 0x%x",message,controlMessage.upperTransportPdu,proxyPdu.source,proxyPdu.destination);
        if ([_networkManager.manager.delegate respondsToSelector:@selector(didReceiveSigProxyConfigurationMessage:sentFromSource:toDestination:)]) {
            [_networkManager.manager.delegate didReceiveSigProxyConfigurationMessage:message sentFromSource:proxyPdu.source toDestination:proxyPdu.destination];
        }
        if ([_networkManager.manager.delegateForDeveloper respondsToSelector:@selector(didReceiveSigProxyConfigurationMessage:sentFromSource:toDestination:)]) {
            [_networkManager.manager.delegateForDeveloper didReceiveSigProxyConfigurationMessage:message sentFromSource:proxyPdu.source toDestination:proxyPdu.destination];
        }
    }else{
        TeLogInfo(@"Unsupported proxy configuration message (opcode: 0x%x)",controlMessage.opCode);
    }
}

/// Returns whether the given Address is an address of a local Element.
///
/// - parameter address: The Address to check.
/// - returns: `True` if the address is a Unicast Address and belongs to
///            one of the local Node's elements; `false` otherwise.
- (BOOL)isLocalUnicastAddress:(UInt16)address {
    return [_meshNetwork.curLocationNodeModel hasAllocatedAddr:address];
}

/// Returns whether the PDU should loop back for local processing.
///
/// - parameter networkPdu: The PDU to check.
- (BOOL)shouldLoopback:(SigNetworkPdu *)networkPdu {
    UInt16 address = networkPdu.destination;
    return [SigHelper.share isGroupAddress:address] || [SigHelper.share isVirtualAddress:address] || [self isLocalUnicastAddress:address];
}

@end
