/********************************************************************************************************
 * @file     SigHearbeatMessage.m
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

#import "SigHearbeatMessage.h"
#import "SigControlMessage.h"

@implementation SigHearbeatMessage

- (instancetype)initFromControlMessage:(SigControlMessage *)message {
    if (self = [super init]) {
        _opCode = message.opCode;
        NSData *data = message.upperTransportPdu;
        if (_opCode != 0x0A || data.length != 3) {
            TeLogError(@"SigHearbeatMessage initFromControlMessage fail.");
            return nil;
        }
        Byte *dataByte = (Byte *)data.bytes;
        UInt8 tem = 0;
        memcpy(&tem, dataByte, 1);
        _initTtl = tem & 0x7F;
        UInt8 tem1 = 0,tem2 = 0;
        memcpy(&tem1, dataByte+1, 1);
        memcpy(&tem2, dataByte+2, 1);
        _features.value = ((UInt16)tem1 << 8) | (UInt16)tem2;
        _source = message.source;
        _destination = message.destination;
    }
    return self;
}

- (instancetype)initWithInitialTtl:(UInt8)ttl features:(SigFeatures)features fromSource:(UInt16)source targettingDestination:(UInt16)destination {
    if (self = [super init]) {
        _opCode = 0x0A;
        _initTtl = ttl;
        _features = features;
        _source = source;
        _destination = destination;
    }
    return self;
}

@end
