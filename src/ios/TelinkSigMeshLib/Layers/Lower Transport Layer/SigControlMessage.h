/********************************************************************************************************
 * @file     SigControlMessage.h
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

@class SigSegmentedAccessMessage,SigNetworkPdu;

@interface SigControlMessage : SigLowerTransportPdu

/// Message Op Code.
@property (nonatomic,assign) UInt8 opCode;

/// Creates an Control Message from a Network PDU that contains
/// an unsegmented control message. If the PDU is invalid, the
/// init returns `nil`.
///
/// - parameter networkPdu: The received Network PDU with unsegmented
///                         Upper Transport message.
- (instancetype)initFromNetworkPdu:(SigNetworkPdu *)networkPdu;

/// Creates an Control Message object from the given list of segments.
///
/// - parameter segments: List of ordered segments.
- (instancetype)initFromSegments:(NSArray <SigSegmentedAccessMessage *>*)segments;

/// Creates a Control Message from the given Proxy Configuration
/// message. The source should be set to the local Node address.
/// The given Network Key should be known to the Proxy Node.
///
/// - parameter message:    The message to be sent.
/// - parameter source:     The address of the local Node.
/// - parameter networkKey: The Network Key to signe the message with.
///                         The key should be known to the connected
///                         Proxy Node.
- (instancetype)initFromProxyConfigurationMessage:(SigProxyConfigurationMessage *)message sentFromSource:(UInt16)source usingNetworkKey:(SigNetkeyModel *)networkKey;

- (NSData *)transportPdu;

@end

NS_ASSUME_NONNULL_END
