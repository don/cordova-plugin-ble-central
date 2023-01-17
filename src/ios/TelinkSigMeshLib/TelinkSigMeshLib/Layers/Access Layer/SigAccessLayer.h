/********************************************************************************************************
 * @file     SigAccessLayer.h
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

@class SigNetworkManager,SigUpperTransportPdu,SigAccessPdu;

@interface SigAccessLayer : NSObject
@property (nonatomic, strong) SigAccessPdu *accessPdu;

- (instancetype)initWithNetworkManager:(SigNetworkManager *)networkManager;

/// This method handles the Upper Transport PDU and reads the Opcode.
/// If the Opcode is supported, a message object is created and sent to the delegate. Otherwise, a generic MeshMessage object is created for the app to handle.
/// @param upperTransportPdu The decoded Upper Transport PDU.
/// @param keySet The keySet that the message was encrypted with.
- (void)handleUpperTransportPdu:(SigUpperTransportPdu *)upperTransportPdu sentWithSigKeySet:(SigKeySet *)keySet;

/// Sends the MeshMessage to the destination. The message is encrypted using given Application Key and a Network Key bound to it.
/// Before sending, this method updates the transaction identifier (TID) for message extending `TransactionMessage`.
///
/// @param message The Mesh Message to send.
/// @param element The source Element.
/// @param destination The destination Address. This can be any valid mesh Address.
/// @param initialTtl The initial TTL (Time To Live) value of the message. If `nil`, the default Node TTL will be used.
/// @param applicationKey The Application Key to sign the message with.
/// @param command The command of the message.
- (void)sendMessage:(SigMeshMessage *)message fromElement:(SigElementModel *)element toDestination:(SigMeshAddress *)destination withTtl:(UInt8)initialTtl usingApplicationKey:(SigAppkeyModel *)applicationKey command:(SDKLibCommand *)command;

/// Sends the ConfigMessage to the destination. The message is encrypted using the Device Key which belongs to the target Node, and first Network Key known to this Node.
/// @param message The Mesh Config Message to send.
/// @param destination The destination address. This must be a Unicast Address.
/// @param initialTtl The initial TTL (Time To Live) value of the message. If `nil`, the default Node TTL will be used.
/// @param command The command of the message.
- (void)sendSigConfigMessage:(SigConfigMessage *)message toDestination:(UInt16)destination withTtl:(UInt16)initialTtl command:(SDKLibCommand *)command;

/// Replies to the received message, which was sent with the given key set, with the given message.
/// @param origin The destination address of the message that the reply is for.
/// @param message The response message to be sent.
/// @param element The source Element.
/// @param destination The destination address. This must be a Unicast Address.
/// @param keySet The set of keys that the message was encrypted with.
/// @param command The command of the message.
- (void)replyToMessageSentToOrigin:(UInt16)origin withMeshMessage:(SigMeshMessage *)message fromElement:(SigElementModel *)element toDestination:(UInt16)destination usingKeySet:(SigKeySet *)keySet command:(SDKLibCommand *)command;

/// Cancels sending the message with the given handle.
/// @param handle The message handle.
- (void)cancelSigMessageHandle:(SigMessageHandle *)handle;

/// This method delivers the received PDU to all Models that support it and are subscribed to the message destination address.
///
/// In general, each Access PDU should be consumed only by one Model in an Element. For example, Generic OnOff Client may send Generic OnOff Set message to the corresponding Server, which can decode it, change its state and reply with Generic OnOff Status message, that will be consumed by the Client.
///
/// However, nothing stop the developers to reuse the same opcode in multiple Models. For example, there may be a Log Model on an Element, which accepts all opcodes supported by other Models on this Element, and logs the received data. The Log Models, instead of decoding the received Access PDU to Generic OnOff Set message, it may decode it as some "Message X" type.
///
/// This method will make sure that each Model will receive a message decoded to the type specified in `messageTypes` in its `ModelDelegate`, but the manager's delegate will be notified with the first message only.
///
/// @param accessPdu The Access PDU received.
/// @param keySet The set of keys that the message was encrypted with.
/// @param request The previosly sent request message, that the received message responds to, or `nil`, if no request has been sent.
- (void)handleAccessPdu:(SigAccessPdu *)accessPdu sendWithSigKeySet:(SigKeySet *)keySet asResponseToRequest:(SigAcknowledgedMeshMessage *)request;

@end

NS_ASSUME_NONNULL_END
