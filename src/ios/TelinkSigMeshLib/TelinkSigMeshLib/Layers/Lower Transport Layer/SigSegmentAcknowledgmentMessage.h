/********************************************************************************************************
 * @file     SigSegmentAcknowledgmentMessage.h
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

@class SigSegmentedMessage;

@interface SigSegmentAcknowledgmentMessage : SigLowerTransportPdu

/// Message Op Code.
@property (nonatomic,assign) UInt8 opCode;
/// The OBO field shall be set to 0 by a node that is directly addressed by the received message and shall be set to 1 by a Friend node that is acknowledging this message on behalf of a Low Power node.
@property (nonatomic,assign) BOOL isOnBehalfOfLowPowerNode;
/// The BlockAck field shall be set to indicate the segments received. The least significant bit, bit 0, shall represent segment 0; and the most significant bit, bit 31, shall represent segment 31. If bit n is set to 1, then segment n is being acknowledged. If bit n is set to 0, then segment n is not being acknowledged. Any bits for segments larger than SegN shall be set to 0 and ignored upon receipt.
@property (nonatomic,assign) UInt32 blockAck;
@property (nonatomic,assign) UInt16 sequenceZero;
@property (nonatomic,assign) UInt8 segmentOffset;
@property (nonatomic,assign) UInt8 lastSegmentNumber;

- (instancetype)initBusySegmentAcknowledgmentMessageWithNetworkPdu:(SigNetworkPdu *)networkPdu;

/// Creates the Segmented Acknowledgement Message from the given Network PDU.
/// If the PDU is not valid, it will return `nil`.
///
/// - parameter networkPdu: The Network PDU received.
- (instancetype)initFromNetworkPdu:(SigNetworkPdu *)networkPdu;

/// Creates the ACK for given array of segments. At least one of
/// segments must not be `nil`.
///
/// - parameter segments: The list of segments to be acknowledged.
- (instancetype)initForSegments:(NSArray <SigSegmentedMessage *>*)segments;

/// Returns whether the segment with given index has been received.
///
/// - parameter m: The segment number.
/// - returns: `True`, if the segment of the given number has been
///            acknowledged, `false` otherwise.
- (BOOL)isSegmentReceived:(int)m;

/// Returns whether all segments have been received.
///
/// - parameter segments: The array of segments received and expected.
/// - returns: `True` if all segments were received, `false` otherwise.
- (BOOL)areAllSegmentsReceivedOfSegments:(NSArray <SigSegmentedMessage *>*)segments;

/// Returns whether all segments have been received.
///
/// - parameter lastSegmentNumber: The number of the last expected
///             segments (segN).
/// - returns: `True` if all segments were received, `false` otherwise.
- (BOOL)areAllSegmentsReceivedLastSegmentNumber:(UInt8)lastSegmentNumber;

/// Whether the source Node is busy and the message should be cancelled, or not.
- (BOOL)isBusy;

- (NSData *)transportPdu;

@end

NS_ASSUME_NONNULL_END
