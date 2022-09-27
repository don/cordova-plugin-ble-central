/********************************************************************************************************
 * @file     SigAccessMessage.h
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

#import "SigLowerTransportPdu.h"

NS_ASSUME_NONNULL_BEGIN

@class SigSegmentedAccessMessage,SigUpperTransportPdu;

@interface SigAccessMessage : SigLowerTransportPdu

/// Application Key Flag
@property (nonatomic,assign) BOOL AKF;

/// 6-bit Application Key identifier. This field is set to `nil`
/// if the message is signed with a Device Key instead.
@property (nonatomic,assign) UInt8 aid;
/// The sequence number used to encode this message.
@property (nonatomic,assign) UInt32 sequence;
/// The size of Transport MIC: 4 or 8 bytes.
@property (nonatomic,assign) UInt8 transportMicSize;

/// Creates an Access Message from a Network PDU that contains
/// an unsegmented access message. If the PDU is invalid, the
/// init returns `nil`.
///
/// - parameter networkPdu: The received Network PDU with unsegmented
///                         Upper Transport message.
- (instancetype)initFromUnsegmentedPdu:(SigNetworkPdu *)networkPdu;

/// Creates an Access Message object from the given list of segments.
///
/// - parameter segments: List of ordered segments.
- (instancetype)initFromSegments:(NSArray <SigSegmentedAccessMessage *>*)segments;

/// Creates an Access Message object from the Upper Transport PDU.
///
/// - parameter pdu: The Upper Transport PDU.
/// - parameter networkKey: The Network Key to encrypt the PCU with.
- (instancetype)initFromUnsegmentedUpperTransportPdu:(SigUpperTransportPdu *)pdu usingNetworkKey:(SigNetkeyModel *)networkKey;

- (NSData *)transportPdu;

@end

NS_ASSUME_NONNULL_END
