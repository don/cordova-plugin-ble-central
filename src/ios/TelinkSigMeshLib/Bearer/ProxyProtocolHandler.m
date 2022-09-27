/********************************************************************************************************
 * @file     ProxyProtocolHandler.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/8/28
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

#import "ProxyProtocolHandler.h"

@interface ProxyProtocolHandler ()
@property (nonatomic,strong) NSMutableData *buffer;
@property (nonatomic,assign) SigPduType bufferType;
@end

@implementation ProxyProtocolHandler

- (SigPduType)getPduTypeFromeData:(NSData *)data {
    SigPduType type = 0;
    if (data && data.length > 0) {
        UInt8 value = 0;
        [data getBytes:&value range:NSMakeRange(0, 1)];
        value = value & 0b00111111;
        switch (value) {
            case 0:
                type = SigPduType_networkPdu;
                break;
            case 1:
                type = SigPduType_meshBeacon;
                break;
            case 2:
                type = SigPduType_proxyConfiguration;
                break;
            case 3:
                type = SigPduType_provisioningPdu;
                break;

            default:
                break;
        }
    }
    return type;
}

- (SAR)getSAPFromeData:(NSData *)data {
    SAR tem = 0;
    if (data && data.length > 0) {
        UInt8 value = 0;
        [data getBytes:&value range:NSMakeRange(0, 1)];
        tem = value >> 6;
    }
    return tem;
}

- (UInt8)getSARValueWithSAR:(SAR)sar {
    return (UInt8)(sar << 6);
}

/// Segments the given data with given message type to 1+ messages where all but the last one are of the MTU size and the last one is MTU size or smaller.
///
/// This method implements the Proxy Protocol from Bluetooth Mesh specification.
///
/// - parameters:
///   - data:        The data to be semgneted.
///   - messageType: The data type.
///   - mtu:         The maximum size of a packet to be sent.
- (NSArray <NSData *>*)segmentWithData:(NSData *)data messageType:(SigPduType)messageType mtu:(NSInteger)mtu {
    NSMutableArray *packets = [NSMutableArray array];
    if (data.length <= mtu-1) {
        // Whole data can fit into a single packet.
        NSMutableData *mData = [NSMutableData data];
        UInt8 singlePacket = [self getSARValueWithSAR:SAR_completeMessage] | messageType;
        [mData appendBytes:&singlePacket length:1];
        [mData appendData:data];
        [packets addObject:mData];
    }else{
        // Data needs to be segmented.
        NSInteger count = ceil(data.length / (float)(mtu - 1));
        for (int i=0; i<count; i++) {
            SAR sar = SAR_firstSegment;
            NSData *packetData = nil;
            if (i > 0) {
                if (i == count - 1) {
                    sar = SAR_lastSegment;
                } else {
                    sar = SAR_continuation;
                }
            }
            if (i == count - 1) {
                packetData = [data subdataWithRange:NSMakeRange(i * (mtu - 1), data.length - (i * (mtu - 1)))];
            } else {
                packetData = [data subdataWithRange:NSMakeRange(i * (mtu - 1), mtu - 1)];
            }
            UInt8 packetHeader = [self getSARValueWithSAR:sar] | messageType;
            NSMutableData *mData = [NSMutableData data];
            [mData appendBytes:&packetHeader length:1];
            [mData appendData:packetData];
            [packets addObject:mData];
        }
    }
    return packets;
}

/// This method consumes the given data. If the data were segmented, they are buffored until the last segment is received.
/// This method returns the message and its type when the last segment (or the only one) has been received, otherwise it returns `nil`.
///
/// The packets must be delivered in order. If a new message is received while the previous one is still reassembled, the old one will be disregarded. Invalid messages are disregarded.
///
/// - parameter data: The data received.
/// - returns: The message and its type, or `nil`, if more data are expected.
- (SigPudModel *)reassembleData:(NSData *)data {
    if (!data || data.length == 0) {
        return nil;
    }

    SAR sar = [self getSAPFromeData:data];
    SigPduType messageType = [self getPduTypeFromeData:data];
    
    // Ensure, that only complete message or the first segment may be processed if the buffer is empty.
    if ((_buffer == nil || _buffer.length == 0) && sar != SAR_completeMessage && sar != SAR_firstSegment) {
        return nil;
    }

    // If the new packet is a continuation/lastSegment, it should have the same message type as the current buffer.
    if (_bufferType != messageType && sar != SAR_completeMessage && sar != SAR_firstSegment) {
        return nil;
    }
    
    // If a new message was received while the old one was processed, disregard the old one.
    if (_buffer != nil && (sar == SAR_completeMessage || sar == SAR_firstSegment)) {
        _buffer = nil;
        _bufferType = 0;
    }

    // Save the message type and append newly received data.
    _bufferType = messageType;
    if (sar == SAR_completeMessage || sar == SAR_firstSegment) {
        _buffer = [NSMutableData data];
    }
    [_buffer appendData:[data subdataWithRange:NSMakeRange(1, data.length-1)]];
    
    // If the complete message was received, return it.
    if (sar == SAR_completeMessage || sar == SAR_lastSegment) {
        SigPudModel *model = [[SigPudModel alloc] init];
        model.pduType = messageType;
        model.pduData = _buffer;
        _buffer = nil;
        _bufferType = 0;
        return model;
    }

    // Otherwise, just return nil.
    return nil;
}

@end
