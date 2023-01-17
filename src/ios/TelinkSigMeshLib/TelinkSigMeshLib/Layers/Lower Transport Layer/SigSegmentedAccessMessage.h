/********************************************************************************************************
 * @file     SigSegmentedAccessMessage.h
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

#import "SigSegmentedMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class SigUpperTransportPdu;

@interface SigSegmentedAccessMessage : SigSegmentedMessage
/// Application Key Flag
@property (nonatomic,assign) BOOL AKF;
/// The Application Key identifier.
/// This field is set to `nil` if the message is signed with a
/// Device Key instead.
@property (nonatomic,assign) UInt8 aid;
/// The size of Transport MIC: 4 or 8 bytes.
@property (nonatomic,assign) UInt8 transportMicSize;
/// The sequence number used to encode this message.
@property (nonatomic,assign) UInt32 sequence;

@property (nonatomic,assign) UInt8 opCode;

/// Creates a Segment of an Access Message from a Network PDU that contains
/// a segmented access message. If the PDU is invalid, the
/// init returns `nil`.
///
/// - parameter networkPdu: The received Network PDU with segmented
///                         Upper Transport message.
- (instancetype)initFromSegmentedPdu:(SigNetworkPdu *)networkPdu;

- (instancetype)initFromUpperTransportPdu:(SigUpperTransportPdu *)pdu usingNetworkKey:(SigNetkeyModel *)networkKey ivIndex:(SigIvIndex *)ivIndex offset:(UInt8)offset;

/// Creates a Segment of an Access Message object from the Upper Transport PDU
/// with given segment offset.
///
/// - parameter pdu: The segmented Upper Transport PDU.
/// - parameter networkKey: The Network Key to encrypt the PCU with.
/// - parameter offset: The segment offset.
- (instancetype)initFromUpperTransportPdu:(SigUpperTransportPdu *)pdu usingNetworkKey:(SigNetkeyModel *)networkKey offset:(UInt8)offset;

- (NSData *)transportPdu;

@end

NS_ASSUME_NONNULL_END
