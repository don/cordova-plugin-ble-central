/********************************************************************************************************
 * @file     SigLowerTransportLayer.h
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

@class SigSegmentedMessage,SigUpperTransportPdu,SigNetkeyModel,SigSegmentAcknowledgmentMessage;

@interface SigLowerTransportLayer : NSObject

@property (nonatomic,strong) SigNetworkManager *networkManager;

//#prage mark out going segments

/// 缓存APP端发送到设备端的Segment数据包列表。The key is the `sequenceZero` of the message.
@property (nonatomic,strong) NSMutableDictionary <NSNumber *,NSMutableArray <SigSegmentedMessage *>*>*outgoingSegments;
/// 缓存APP端发送Segment数据包列表的定时器。The key is the `sequenceZero` of the message.（用于判断outgoingSegments的数据包是否有发送失败的，失败则再发送一次。）
@property (nonatomic,strong) NSMutableDictionary <NSNumber *,BackgroundTimer *>*segmentTransmissionTimers;
/// 缓存重发segment数据包的定时器。(设备端不返回这个Segment长包的接收情况，该定时器是segment发包和重发包的总超时定时器，该定时器执行则表示该segment包发送失败，设备端没收全APP发送的segment包。)
@property (nonatomic,strong) NSMutableDictionary <NSNumber *,BackgroundTimer *>*incompleteTimers;
/// An item is removed when a next message has been received from the same Node.
/// 缓存接收到的Segment Acknowlegment Messages。（设备端返回这个APP发送的Segment长包的接收情况，APP需要补充丢失的包或者停止重发segment数据包的定时器incompleteTimers）
@property (nonatomic,strong) NSMutableDictionary <NSNumber *,SigSegmentAcknowledgmentMessage *>*acknowledgments;

//#prage mark in going segments

/// 缓存接收到的segment数据包。（用于返回app接收到segment的情况，定时器）
@property (nonatomic,strong) NSMutableDictionary <NSNumber *,NSMutableArray <SigSegmentedMessage *>*>*incompleteSegments;
/// 缓存APP端向设备端发送Segment Acknowlegment Messages的定时器。(告诉设备端一个Segment长包中哪个包丢失了或者所有包都接收了。)
@property (nonatomic,strong) NSMutableDictionary <NSNumber *,BackgroundTimer *>*acknowledgmentTimers;

@property (nonatomic,strong) SigLowerTransportPdu *unSegmentLowerTransportPdu;


/// The initial TTL values.
///
/// The key is the `sequenceZero` of the message.
@property (nonatomic,strong) NSMutableDictionary <NSNumber *,NSNumber *>*segmentTtl;/*{NSNumber(uint16):NSNumber(uint8)}*/

- (instancetype)initWithNetworkManager:(SigNetworkManager *)networkManager;

/// This method handles the received Network PDU. If needed, it will reassembly
/// the message, send block acknowledgment to the sender, and pass the Upper
/// Transport PDU to the Upper Transport Layer.
///
/// - parameter networkPdu: The Network PDU received.
- (void)handleNetworkPdu:(SigNetworkPdu *)networkPdu;

- (void)sendUnsegmentedUpperTransportPdu:(SigUpperTransportPdu *)pdu withTtl:(UInt8)initialTtl usingNetworkKey:(SigNetkeyModel *)networkKey ivIndex:(SigIvIndex *)ivIndex;

/// This method tries to send the Upper Transport Message.
///
/// - parameters:
///   - pdu:        The unsegmented Upper Transport PDU to be sent.
///   - initialTtl: The initial TTL (Time To Live) value of the message.
///                 If `nil`, the default Node TTL will be used.
///   - networkKey: The Network Key to be used to encrypt the message on
///                 on Network Layer.
- (void)sendUnsegmentedUpperTransportPdu:(SigUpperTransportPdu *)pdu withTtl:(UInt8)initialTtl usingNetworkKey:(SigNetkeyModel *)networkKey;

- (void)sendSegmentedUpperTransportPdu:(SigUpperTransportPdu *)pdu withTtl:(UInt8)initialTtl usingNetworkKey:(SigNetkeyModel *)networkKey ivIndex:(SigIvIndex *)ivIndex;

/// This method tries to send the Upper Transport Message.
///
/// - parameter pdu:        The segmented Upper Transport PDU to be sent.
/// - parameter initialTtl: The initial TTL (Time To Live) value of the message.
///                         If `nil`, the default Node TTL will be used.
/// - parameter networkKey: The Network Key to be used to encrypt the message on
///                         on Network Layer.
- (void)sendSegmentedUpperTransportPdu:(SigUpperTransportPdu *)pdu withTtl:(UInt8)initialTtl usingNetworkKey:(SigNetkeyModel *)networkKey;

- (void)cancelTXSendingSegmentedWithDestination:(UInt16)destination;

/// Cancels sending segmented Upper Transoprt PDU.
///
/// - parameter pdu: The Upper Transport PDU.
- (void)cancelSendingSegmentedUpperTransportPdu:(SigUpperTransportPdu *)pdu;

@end

NS_ASSUME_NONNULL_END
