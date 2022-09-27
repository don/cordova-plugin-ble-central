/********************************************************************************************************
 * @file     SigAccessPdu.m
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

#import "SigAccessPdu.h"
#import "SigUpperTransportPdu.h"

@implementation SigAccessPdu

- (BOOL)isSegmented {
    if (_message == nil) {
        return NO;
    }
//新增判断：SigTelinkExtendBearerMode_extendGATTOnly模式只对直连节点发送DLE长包，非直连节点发送短包。
    if (SigMeshLib.share.dataSource.telinkExtendBearerMode == SigTelinkExtendBearerMode_extendGATTOnly && _destination.address != SigMeshLib.share.dataSource.unicastAddressOfConnected) {
        return _accessPdu.length > kUnsegmentedMessageLowerTransportPDUMaxLength || _message.isSegmented;
    } else {
        return _accessPdu.length > SigMeshLib.share.dataSource.defaultUnsegmentedMessageLowerTransportPDUMaxLength || _message.isSegmented;
    }
}

- (int)segmentsCount {
    if (_message == nil) {
        return 0;
    }
    if (![self isSegmented]) {
        return 1;
    }
    switch (_message.security) {
        case SigMeshMessageSecurityLow:
            if (SigMeshLib.share.dataSource.telinkExtendBearerMode == SigTelinkExtendBearerMode_extendGATTOnly && _destination.address != SigMeshLib.share.dataSource.unicastAddressOfConnected) {
                return 1 + (int)((_accessPdu.length + 3) / (kUnsegmentedMessageLowerTransportPDUMaxLength - 3));
            } else {
                return 1 + (int)((_accessPdu.length + 3) / (SigMeshLib.share.dataSource.defaultUnsegmentedMessageLowerTransportPDUMaxLength - 3));
            }
            break;
        case SigMeshMessageSecurityHigh:
            if (SigMeshLib.share.dataSource.telinkExtendBearerMode == SigTelinkExtendBearerMode_extendGATTOnly && _destination.address != SigMeshLib.share.dataSource.unicastAddressOfConnected) {
                return 1 + (int)((_accessPdu.length + 7) / (kUnsegmentedMessageLowerTransportPDUMaxLength - 3));
            } else {
                return 1 + (int)((_accessPdu.length + 7) / (SigMeshLib.share.dataSource.defaultUnsegmentedMessageLowerTransportPDUMaxLength - 3));
            }
            break;
        default:
            break;
    }
}

- (instancetype)init {
    if (self = [super init]) {
        _isAccessMessage = SigLowerTransportPduType_accessMessage;
    }
    return self;
}

- (instancetype)initFromUpperTransportPdu:(SigUpperTransportPdu *)pdu {
    if (self = [super init]) {
        _isAccessMessage = SigLowerTransportPduType_accessMessage;
        _message = nil;
        _localElement = nil;
        _userInitiated = NO;
        _source = pdu.source;
        _destination = [[SigMeshAddress alloc] initWithAddress:pdu.destination];
        _accessPdu = pdu.accessPdu;
        
        SigOpCodeAndParametersModel *model = [[SigOpCodeAndParametersModel alloc] initWithOpCodeAndParameters:pdu.accessPdu];
        if (model == nil) {
            return nil;
        }
        _opCode = model.opCode;
        _parameters = model.parameters;        
    }
    return self;
}

- (instancetype)initFromMeshMessage:(SigMeshMessage *)message sentFromLocalElement:(SigElementModel *)localElement toDestination:(SigMeshAddress *)destination userInitiated:(BOOL)userInitiated {
    if (self = [super init]) {
        _isAccessMessage = SigLowerTransportPduType_accessMessage;
        _message = message;
        _localElement = localElement;
        _userInitiated = userInitiated;
        _source = localElement.unicastAddress;
        _destination = destination;
        
        _opCode = message.opCode;
        if (message.parameters != nil) {
            _parameters = message.parameters;
        } else {
            _parameters = [NSData data];
        }
        
        NSMutableData *mData = [NSMutableData dataWithData:[SigHelper.share getOpCodeDataWithUInt32Opcode:_opCode]];
        [mData appendData:_parameters];
        _accessPdu = mData;        
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Access PDU, source:(0x%04X)->destination: (0x%04X) Op Code: (0x%X), accessPdu=%@", _source, _destination.address, (unsigned int)_opCode,[LibTools convertDataToHexStr:_accessPdu]];
}

@end
