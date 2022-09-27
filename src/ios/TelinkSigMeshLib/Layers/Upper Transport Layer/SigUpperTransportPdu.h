/********************************************************************************************************
 * @file     SigUpperTransportPdu.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SigAccessMessage,SigKeySet,SigAccessPdu;

@interface SigUpperTransportPdu : NSObject

/// The Mesh Message that is being sent, or `nil`, when the message
/// was received.
@property (nonatomic,strong) SigMeshMessage *message;
/// The local Element that is sending the message, or `nil` when the
/// message was received.
@property (nonatomic,strong) SigElementModel *localElement;
/// Whether sending this message has been initiated by the user.
@property (nonatomic,assign) BOOL userInitiated;
/// Source Address.
@property (nonatomic,assign) UInt16 source;
/// Destination Address.
@property (nonatomic,assign) UInt16 destination;
/// Application Key Flag
@property (nonatomic,assign) BOOL AKF;
/// 6-bit Application Key identifier. This field is set to `nil`
/// if the message is signed with a Device Key instead.
@property (nonatomic,assign) UInt8 aid;
/// The sequence number used to encode this message.
@property (nonatomic,assign) UInt32 sequence;
/// The size of Transport MIC: 4 or 8 bytes.
@property (nonatomic,assign) UInt8 transportMicSize;
/// The Access Layer data.
@property (nonatomic,strong) NSData *accessPdu;
/// The raw data of Upper Transport Layer PDU.
@property (nonatomic,strong) NSData *transportPdu;

- (instancetype)initFromLowerTransportAccessMessage:(SigAccessMessage *)accessMessage key:(NSData *)key;
- (instancetype)initFromLowerTransportAccessMessage:(SigAccessMessage *)accessMessage key:(NSData *)key forVirtualGroup:(SigGroupModel *)virtualGroup;
- (instancetype)initFromLowerTransportAccessMessage:(SigAccessMessage *)accessMessage key:(NSData *)key ivIndex:(SigIvIndex *)ivIndex forVirtualGroup:(SigGroupModel *)virtualGroup;
- (instancetype)initFromAccessPdu:(SigAccessPdu *)pdu usingKeySet:(SigKeySet *)keySet ivIndex:(SigIvIndex *)ivIndex sequence:(UInt32)sequence;
- (instancetype)initFromAccessPdu:(SigAccessPdu *)pdu usingKeySet:(SigKeySet *)keySet sequence:(UInt32)sequence;
+ (NSDictionary *)decodeAccessMessage:(SigAccessMessage *)accessMessage forMeshNetwork:(SigDataSource *)meshNetwork;//{@"SigUpperTransportPdu":SigUpperTransportPdu,@"SigKeySet":SigKeySet}

@end

NS_ASSUME_NONNULL_END
