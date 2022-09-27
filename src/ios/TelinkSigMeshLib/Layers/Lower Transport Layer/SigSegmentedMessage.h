/********************************************************************************************************
 * @file     SigSegmentedMessage.h
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

@interface SigSegmentedMessage : SigLowerTransportPdu
/// The Mesh Message that is being sent, or `nil`, when the message
/// was received.
@property (nonatomic,strong,nullable) SigMeshMessage *message;
/// The local Element used to send the message.
@property (nonatomic,strong,nullable) SigElementModel *localElement;
/// Whether sending this message has been initiated by the user.
@property (nonatomic,assign) BOOL userInitiated;
/// 13 least significant bits of SeqAuth.
@property (nonatomic,assign) UInt16 sequenceZero;
/// This field is set to the segment number (zero-based)
/// of the segment m of this Upper Transport PDU.
@property (nonatomic,assign) UInt8 segmentOffset;
/// This field is set to the last segment number (zero-based)
/// of this Upper Transport PDU.
@property (nonatomic,assign) UInt8 lastSegmentNumber;

/// Returns whether the message is composed of only a single
/// segment. Single segment messages are used to send short,
/// acknowledged messages. The maximum size of payload of upper
/// transport control PDU is 8 bytes.
- (BOOL)isSingleSegment;

/// Returns the `segmentOffset` as `Int`.
- (int)index;

/// Returns the expected number of segments for this message.
- (int)count;

@end

NS_ASSUME_NONNULL_END
