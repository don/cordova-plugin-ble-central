/********************************************************************************************************
 * @file     SigUpperTransportPdu.m
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

#import "SigUpperTransportPdu.h"
#import "SigAccessMessage.h"
#import "OpenSSLHelper.h"
#import "SigAccessPdu.h"
#import "CBUUID+Hex.h"

@implementation SigUpperTransportPdu

- (instancetype)initFromLowerTransportAccessMessage:(SigAccessMessage *)accessMessage key:(NSData *)key ivIndex:(SigIvIndex *)ivIndex forVirtualGroup:(SigGroupModel *)virtualGroup {
    if (self = [super init]) {
//        TeLogDebug(@"accessMessage.upperTransportPdu=%@,length=%lu",[LibTools convertDataToHexStr:accessMessage.transportPdu],(unsigned long)accessMessage.transportPdu.length);
        NSInteger micSize = accessMessage.transportMicSize;
        NSInteger encryptedDataSize = accessMessage.upperTransportPdu.length - micSize;
        NSData *encryptedData = [accessMessage.upperTransportPdu subdataWithRange:NSMakeRange(0, encryptedDataSize)];
        NSData *mic = [accessMessage.upperTransportPdu subdataWithRange:NSMakeRange(encryptedDataSize, accessMessage.upperTransportPdu.length - encryptedDataSize)];
        
        // The nonce type is 0x01 for messages signed with Application Key and
        // 0x02 for messages signed using Device Key (Configuration Messages).
        UInt8 type = accessMessage.AKF ? 0x01 : 0x02;
        // ASZMIC is set to 1 for messages sent with high security
        // (64-bit TransMIC). This is possible only for Segmented Access Messages.
        UInt8 aszmic = micSize == 4 ? 0 : 1;
        UInt32 sequ32 = CFSwapInt32HostToBig(accessMessage.sequence);
        NSData *seq = [[NSData dataWithBytes:&sequ32 length:4] subdataWithRange:NSMakeRange(1, 3)];
        NSMutableData *nonce = [NSMutableData data];
        UInt8 tem1 = type;
        UInt8 tem2 = aszmic << 7;
        UInt16 tem3 = CFSwapInt16HostToBig(accessMessage.source);
        UInt16 tem4 = CFSwapInt16HostToBig(accessMessage.destination);
        UInt32 index = ivIndex.index;
        if (accessMessage.networkPduModel.ivi != (index & 0x01)) {
            if (index > 0) {
                index -= 1;
            }
        }
        UInt32 tem5 = CFSwapInt32HostToBig(index);
//        TeLogVerbose(@"解密使用IvIndex=0x%x",index);

        [nonce appendData:[NSData dataWithBytes:&tem1 length:1]];
        [nonce appendData:[NSData dataWithBytes:&tem2 length:1]];
        [nonce appendData:seq];
        [nonce appendData:[NSData dataWithBytes:&tem3 length:2]];
        [nonce appendData:[NSData dataWithBytes:&tem4 length:2]];
        [nonce appendData:[NSData dataWithBytes:&tem5 length:4]];

//            NSData *additionalData = virtualGroup?.address.virtualLabel?.data;
        NSData *additionalData = nil;
        NSData *decryptedData = [OpenSSLHelper.share calculateDecryptedCCM:encryptedData withKey:key nonce:nonce andMIC:mic withAdditionalData:additionalData];
        
        if (decryptedData == nil || decryptedData.length == 0) {
            TeLogError(@"calculateDecryptedCCM fail.");
            return nil;
        }else{
//            TeLogDebug(@"calculateDecryptedCCM success.");
        }
        _source = accessMessage.source;
        _destination = accessMessage.destination;
        _AKF = accessMessage.AKF;
        _aid = accessMessage.aid;
        _transportMicSize = accessMessage.transportMicSize;
        _transportPdu = accessMessage.upperTransportPdu;
        _accessPdu = decryptedData;
        _sequence = accessMessage.sequence;
        _message = nil;
        _userInitiated = NO;
    }
    return self;
}

- (instancetype)initFromLowerTransportAccessMessage:(SigAccessMessage *)accessMessage key:(NSData *)key forVirtualGroup:(SigGroupModel *)virtualGroup {
    if (self = [super init]) {
//        TeLogDebug(@"accessMessage.upperTransportPdu=%@,length=%lu",[LibTools convertDataToHexStr:accessMessage.transportPdu],(unsigned long)accessMessage.transportPdu.length);
        NSInteger micSize = accessMessage.transportMicSize;
        NSInteger encryptedDataSize = accessMessage.upperTransportPdu.length - micSize;
        NSData *encryptedData = [accessMessage.upperTransportPdu subdataWithRange:NSMakeRange(0, encryptedDataSize)];
        NSData *mic = [accessMessage.upperTransportPdu subdataWithRange:NSMakeRange(encryptedDataSize, accessMessage.upperTransportPdu.length - encryptedDataSize)];
        
        // The nonce type is 0x01 for messages signed with Application Key and
        // 0x02 for messages signed using Device Key (Configuration Messages).
        UInt8 type = accessMessage.AKF ? 0x01 : 0x02;
        // ASZMIC is set to 1 for messages sent with high security
        // (64-bit TransMIC). This is possible only for Segmented Access Messages.
        UInt8 aszmic = micSize == 4 ? 0 : 1;
        UInt32 sequ32 = CFSwapInt32HostToBig(accessMessage.sequence);
        NSData *seq = [[NSData dataWithBytes:&sequ32 length:4] subdataWithRange:NSMakeRange(1, 3)];
        NSMutableData *nonce = [NSMutableData data];
        UInt8 tem1 = type;
        UInt8 tem2 = aszmic << 7;
        UInt16 tem3 = CFSwapInt16HostToBig(accessMessage.source);
        UInt16 tem4 = CFSwapInt16HostToBig(accessMessage.destination);
        UInt32 index = accessMessage.networkKey.ivIndex.index;
        if (accessMessage.networkPduModel.ivi != (index & 0x01)) {
            if (index > 0) {
                index -= 1;
            }
        }
        UInt32 tem5 = CFSwapInt32HostToBig(index);
//        TeLogVerbose(@"解密使用IvIndex=0x%x",index);

        [nonce appendData:[NSData dataWithBytes:&tem1 length:1]];
        [nonce appendData:[NSData dataWithBytes:&tem2 length:1]];
        [nonce appendData:seq];
        [nonce appendData:[NSData dataWithBytes:&tem3 length:2]];
        [nonce appendData:[NSData dataWithBytes:&tem4 length:2]];
        [nonce appendData:[NSData dataWithBytes:&tem5 length:4]];

//            NSData *additionalData = virtualGroup?.address.virtualLabel?.data;
        NSData *additionalData = nil;
        NSData *decryptedData = [OpenSSLHelper.share calculateDecryptedCCM:encryptedData withKey:key nonce:nonce andMIC:mic withAdditionalData:additionalData];
        
        if (decryptedData == nil || decryptedData.length == 0) {
            TeLogError(@"calculateDecryptedCCM fail.");
            return nil;
        }else{
//            TeLogDebug(@"calculateDecryptedCCM success.");
        }
        _source = accessMessage.source;
        _destination = accessMessage.destination;
        _AKF = accessMessage.AKF;
        _aid = accessMessage.aid;
        _transportMicSize = accessMessage.transportMicSize;
        _transportPdu = accessMessage.upperTransportPdu;
        _accessPdu = decryptedData;
        _sequence = accessMessage.sequence;
        _message = nil;
        _userInitiated = NO;
    }
    return self;
}

- (instancetype)initFromLowerTransportAccessMessage:(SigAccessMessage *)accessMessage key:(NSData *)key {
    SigGroupModel *model = nil;
    return [self initFromLowerTransportAccessMessage:accessMessage key:key forVirtualGroup:model];
}

- (instancetype)initFromAccessPdu:(SigAccessPdu *)pdu usingKeySet:(SigKeySet *)keySet ivIndex:(SigIvIndex *)ivIndex sequence:(UInt32)sequence {
    if (self = [super init]) {
        _message = pdu.message;
        _localElement = pdu.localElement;
        _userInitiated = pdu.userInitiated;
        _source = pdu.localElement.unicastAddress;
        _destination = pdu.destination.address;
        _sequence = sequence;
        _accessPdu = pdu.accessPdu;
        _aid = keySet.aid;
        if ([keySet isMemberOfClass:[SigAccessKeySet class]]) {
            _AKF = YES;
        }
        SigMeshMessageSecurity security = pdu.message.security;
        
        // The nonce type is 0x01 for messages signed with Application Key and
        // 0x02 for messages signed using Device Key (Configuration Messages).
        UInt8 type = _AKF ? 0x01 : 0x02;
        // ASZMIC is set to 1 for messages that shall be sent with high security
        // (64-bit TransMIC). This is possible only for Segmented Access Messages.
//        UInt8 aszmic = security == SigMeshMessageSecurityHigh && (_accessPdu.length > 11 || pdu.isSegmented) ? 1 : 0;
        UInt8 aszmic = security == SigMeshMessageSecurityHigh ? 1 : 0;
        // SEQ is 24-bit value, in Big Endian.
        UInt32 sequenceBigDian = CFSwapInt32HostToBig(_sequence);
        NSData *sequenceData = [NSData dataWithBytes:&sequenceBigDian length:4];
        NSData *seq = [sequenceData subdataWithRange:NSMakeRange(1, 3)];

        NSMutableData *nonce = [NSMutableData data];
        UInt8 tem[2] = {type,aszmic << 7};
        NSData *temData = [NSData dataWithBytes:&tem length:2];
        UInt16 sourceBigDian = CFSwapInt16HostToBig(_source);
        NSData *sourceData = [NSData dataWithBytes:&sourceBigDian length:2];
        UInt16 destinationBigDian = CFSwapInt16HostToBig(_destination);
        NSData *destinationData = [NSData dataWithBytes:&destinationBigDian length:2];
        UInt32 ivIndexBigDian = CFSwapInt32HostToBig(ivIndex.index);
        NSData *ivIndexData = [NSData dataWithBytes:&ivIndexBigDian length:4];
        [nonce appendData:temData];
        [nonce appendData:seq];
        [nonce appendData:sourceData];
        [nonce appendData:destinationData];
        [nonce appendData:ivIndexData];

        _transportMicSize = aszmic == 0 ? 4 : 8;
        _transportPdu = [OpenSSLHelper.share calculateCCM:_accessPdu withKey:keySet.accessKey nonce:nonce andMICSize:_transportMicSize withAdditionalData:pdu.destination.virtualLabel.getData];
    }
    return self;
}

- (instancetype)initFromAccessPdu:(SigAccessPdu *)pdu usingKeySet:(SigKeySet *)keySet sequence:(UInt32)sequence {
    if (self = [super init]) {
        _message = pdu.message;
        _localElement = pdu.localElement;
        _userInitiated = pdu.userInitiated;
        _source = pdu.localElement.unicastAddress;
        _destination = pdu.destination.address;
        _sequence = sequence;
        _accessPdu = pdu.accessPdu;
        _aid = keySet.aid;
        if ([keySet isMemberOfClass:[SigAccessKeySet class]]) {
            _AKF = YES;
        }
        SigMeshMessageSecurity security = pdu.message.security;
        
        // The nonce type is 0x01 for messages signed with Application Key and
        // 0x02 for messages signed using Device Key (Configuration Messages).
        UInt8 type = _AKF ? 0x01 : 0x02;
        // ASZMIC is set to 1 for messages that shall be sent with high security
        // (64-bit TransMIC). This is possible only for Segmented Access Messages.
        UInt8 aszmic = security == SigMeshMessageSecurityHigh && (_accessPdu.length > 11 || pdu.isSegmented) ? 1 : 0;
        // SEQ is 24-bit value, in Big Endian.
        UInt32 sequenceBigDian = CFSwapInt32HostToBig(_sequence);
        NSData *sequenceData = [NSData dataWithBytes:&sequenceBigDian length:4];
        NSData *seq = [sequenceData subdataWithRange:NSMakeRange(1, 3)];

        SigIvIndex *ivIndex = keySet.networkKey.ivIndex;
        NSMutableData *nonce = [NSMutableData data];
        UInt8 tem[2] = {type,aszmic << 7};
        NSData *temData = [NSData dataWithBytes:&tem length:2];
        UInt16 sourceBigDian = CFSwapInt16HostToBig(_source);
        NSData *sourceData = [NSData dataWithBytes:&sourceBigDian length:2];
        UInt16 destinationBigDian = CFSwapInt16HostToBig(_destination);
        NSData *destinationData = [NSData dataWithBytes:&destinationBigDian length:2];
        UInt32 ivIndexBigDian = CFSwapInt32HostToBig(ivIndex.index);
        NSData *ivIndexData = [NSData dataWithBytes:&ivIndexBigDian length:4];
        [nonce appendData:temData];
        [nonce appendData:seq];
        [nonce appendData:sourceData];
        [nonce appendData:destinationData];
        [nonce appendData:ivIndexData];

        _transportMicSize = aszmic == 0 ? 4 : 8;
        _transportPdu = [OpenSSLHelper.share calculateCCM:_accessPdu withKey:keySet.accessKey nonce:nonce andMICSize:_transportMicSize withAdditionalData:pdu.destination.virtualLabel.getData];
    }
    return self;
}

+ (NSDictionary *)decodeAccessMessage:(SigAccessMessage *)accessMessage forMeshNetwork:(SigDataSource *)meshNetwork {
//    TeLogDebug(@"accessMessage.upperTransportPdu=%@,length=%d",[LibTools convertDataToHexStr:accessMessage.transportPdu],accessMessage.transportPdu.length);
    // Was the message signed using Application Key?
    UInt8 aid = accessMessage.aid;
    if (accessMessage.AKF) {
        // When the message was sent to a Virtual Address, the message must be decoded
        // with the Virtual Label as Additional Data.
        NSMutableArray <SigGroupModel *>*matchingGroups = [NSMutableArray array];
        if ([SigHelper.share isVirtualAddress:accessMessage.destination]) {
            // Find all groups with matching Virtual Address.
            NSArray *groups = [NSArray arrayWithArray:meshNetwork.groups];
            for (SigGroupModel *group in groups) {
                if (group.intAddress == accessMessage.destination) {
                    [matchingGroups addObject:group];
                    break;
                }
            }
        }
        if (matchingGroups.count == 0) {
            [matchingGroups addObject:(SigGroupModel *)[NSNull null]];
        }
        NSMutableArray *temAppKeys = [NSMutableArray arrayWithArray:meshNetwork.appKeys];
        if (meshNetwork.defaultAppKeyA) {
            [temAppKeys addObject:meshNetwork.defaultAppKeyA];
        }
        for (SigAppkeyModel *applicationKey in temAppKeys) {
            for (SigGroupModel *tem in matchingGroups) {
                SigGroupModel *group = tem;
                if ([group isMemberOfClass:[NSNull class]]) {
                    group = nil;
                }
                if (applicationKey.getDataKey && applicationKey.getDataKey.length > 0) {
                    SigUpperTransportPdu *pdu = [[SigUpperTransportPdu alloc] initFromLowerTransportAccessMessage:accessMessage key:applicationKey.getDataKey forVirtualGroup:group];
                    if (pdu == nil && meshNetwork.defaultIvIndexA) {
                        pdu = [[SigUpperTransportPdu alloc] initFromLowerTransportAccessMessage:accessMessage key:applicationKey.getDataKey ivIndex:meshNetwork.defaultIvIndexA forVirtualGroup:group];
                    }
                    if (aid == applicationKey.aid && pdu) {
                        SigAccessKeySet *keySet = [[SigAccessKeySet alloc] initWithApplicationKey:applicationKey];
                        return @{@"SigUpperTransportPdu":pdu,@"SigKeySet":keySet};
                    }
                }
                if (applicationKey.getDataOldKey && applicationKey.getDataOldKey.length > 0) {
                    SigUpperTransportPdu *oldPdu = [[SigUpperTransportPdu alloc] initFromLowerTransportAccessMessage:accessMessage key:applicationKey.getDataOldKey forVirtualGroup:group];
                    if (oldPdu == nil) {
                        oldPdu = [[SigUpperTransportPdu alloc] initFromLowerTransportAccessMessage:accessMessage key:applicationKey.getDataOldKey ivIndex:meshNetwork.defaultIvIndexA forVirtualGroup:group];
                    }
                    if (applicationKey.oldAid == applicationKey.aid && oldPdu) {
                        SigAccessKeySet *keySet = [[SigAccessKeySet alloc] initWithApplicationKey:applicationKey];
                        return @{@"SigUpperTransportPdu":oldPdu,@"SigKeySet":keySet};
                    }
                }
            }
        }
    }else{
        // Try decoding using source's Node Device Key. This should work if a status
        // message was sent as a response to a Config Message sent by this Provisioner.
        SigNodeModel *node = [meshNetwork getNodeWithAddress:accessMessage.source];
        NSData *deviceKey = [LibTools nsstringToHex:node.deviceKey];
//        TeLogVerbose(@"Try decoding using source's Node Device Key,deviceKey=%@",deviceKey);
        SigUpperTransportPdu *pdu = [[SigUpperTransportPdu alloc] initFromLowerTransportAccessMessage:accessMessage key:deviceKey];
        if (deviceKey && deviceKey.length > 0 && pdu) {
            SigDeviceKeySet *keySet = [[SigDeviceKeySet alloc] initWithNetworkKey:accessMessage.networkKey node:node];
            return @{@"SigUpperTransportPdu":pdu,@"SigKeySet":keySet};
        }
        // On the other hand, if another Provisioner is sending Config Messages,
        // they will be signed using the local Provisioner's Device Key instead.
        node = [meshNetwork getNodeWithAddress:accessMessage.destination];
        deviceKey = [LibTools nsstringToHex:node.deviceKey];
        pdu = [[SigUpperTransportPdu alloc] initFromLowerTransportAccessMessage:accessMessage key:deviceKey];
        if (deviceKey && deviceKey.length > 0 && pdu) {
            SigDeviceKeySet *keySet = [[SigDeviceKeySet alloc] initWithNetworkKey:accessMessage.networkKey node:node];
            return @{@"SigUpperTransportPdu":pdu,@"SigKeySet":keySet};
        }
    }
    TeLogError(@"Decryption failed.");
    return nil;
}

- (NSString *)description {
    return[NSString stringWithFormat:@"<%p> - Upper Transport PDU, source:(%04X)->destination: (%04X) Seq: (%08X), accessPdu: (%@), MIC size: (%d)bytes", self, _source,_destination,(unsigned int)_sequence,[LibTools convertDataToHexStr:_accessPdu],_transportMicSize];
}

@end
