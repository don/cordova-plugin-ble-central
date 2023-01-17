/********************************************************************************************************
 * @file     SigProxyConfigurationMessage.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/10/30
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

NS_ASSUME_NONNULL_BEGIN

///more detail:  Mesh_v1.0.pdf section 6.4~6.7
@interface SigProxyConfigurationMessage : SigBaseMeshMessage

/// The message Op Code.
@property (nonatomic,assign) UInt8 opCode;

@end


/// A type of a Proxy Configuration message which opcode is known
/// during compilation time.
@interface SigStaticProxyConfigurationMessage : SigProxyConfigurationMessage
@end


/// The base class for acknowledged messages.
///
/// An acknowledged message is transmitted and acknowledged by each
/// receiving element by responding to that message. The response is
/// typically a status message. If a response is not received within
/// an arbitrary time period, the message will be retransmitted
/// automatically until the timeout occurs.
@interface SigAcknowledgedProxyConfigurationMessage : SigProxyConfigurationMessage
/// The Op Code of the response message.
@property (nonatomic,assign) UInt8 responseOpCode;
@end


@interface SigStaticAcknowledgedProxyConfigurationMessage : SigAcknowledgedProxyConfigurationMessage
/// The Type of the response message.
@property (nonatomic,strong) SigStaticProxyConfigurationMessage *responseType;
@end


/// 6.5.1 Set Filter Type
/// - seeAlso: Mesh_v1.0.pdf (page.263)
@interface SigSetFilterType : SigStaticAcknowledgedProxyConfigurationMessage
/// The new filter type.
@property (nonatomic,assign) SigProxyFilerType filterType;

- (instancetype)initWithType:(SigProxyFilerType)type;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


/// 6.5.2 Add Addresses to Filter
/// - seeAlso: Mesh_v1.0.pdf (page.264)
@interface SigAddAddressesToFilter : SigStaticAcknowledgedProxyConfigurationMessage
/// List of addresses where N is the number of addresses in this message.
@property (nonatomic,strong) NSMutableArray <NSNumber *>*addresses;

- (instancetype)initWithAddresses:(NSArray <NSNumber *>*)addresses;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


/// 6.5.3 Remove Addresses from Filter
/// - seeAlso: Mesh_v1.0.pdf (page.264)
@interface SigRemoveAddressesFromFilter : SigStaticAcknowledgedProxyConfigurationMessage
/// List of addresses where N is the number of addresses in this message.
@property (nonatomic,strong) NSMutableArray <NSNumber *>*addresses;

- (instancetype)initWithAddresses:(NSArray <NSNumber *>*)addresses;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


/// 6.5.4 Filter Status
/// - seeAlso: Mesh_v1.0.pdf (page.264)
@interface SigFilterStatus : SigStaticProxyConfigurationMessage
/// White list or black list.
@property (nonatomic,assign) SigProxyFilerType filterType;
/// Number of addresses in the proxy filter list.
@property (nonatomic,assign) UInt16 listSize;

- (instancetype)initWithType:(SigProxyFilerType)type listSize:(UInt16)listSize;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


NS_ASSUME_NONNULL_END
