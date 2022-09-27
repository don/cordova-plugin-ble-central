/********************************************************************************************************
 * @file     SigConfigMessage.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/8/15
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

#import "SigMeshMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class SigPublish,SigModelIDModel,SigNodeFeatures,SigConfigModelPublicationVirtualAddressSet;

@interface SigConfigMessage : SigStaticMeshMessage

/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;

/// Encodes given list of Key Indexes into a Data. As each Key Index is 12 bits long, a pair of them can fit 3 bytes. This method ensures that they are packed in compliance to the Bluetooth Mesh specification.
/// @param limit Maximim number of Key Indexes to encode.
/// @param indexes An array of 12-bit Key Indexes.
/// @returns Key Indexes encoded to a Data.
- (NSData *)encodeLimit:(int)limit indexes:(NSArray <NSNumber *>*)indexes;
- (NSData *)encodeIndexes:(NSArray <NSNumber *>*)indexes;

/// Decodes number of Key Indexes from the given Data from the given offset. This will decode as many Indexes as possible, until the end of data is reached.
/// @param limit Maximum number of Key Indexes to decode.
/// @param data The data from where the indexes should be read.
/// @param offset The offset from where to read the indexes.
/// @returns Decoded Key Indexes.
+ (NSArray <NSNumber *>*)decodeLimit:(int)limit indexesFromData:(NSData *)data atOffset:(int)offset;
+ (NSArray <NSNumber *>*)decodeIndexesFromData:(NSData *)data atOffset:(int)offset;

/// By default, all Config Messages will be sent as segmented to make them more reliable.
//- (BOOL)isSegmented;

@end


@interface SigConfigStatusMessage : SigConfigMessage
/// Operation status.
@property (nonatomic,assign) SigConfigMessageStatus status;
/// Returns whether the operation was successful or not.
@property (nonatomic,assign) BOOL isSuccess;
/// The status as String.
@property (nonatomic,strong,readonly) NSString *message;
@end

@interface SigAcknowledgedConfigMessage : SigConfigMessage
@end

@interface SigConfigNetKeyMessage : SigConfigMessage
/// The Network Key Index.
@property (nonatomic,assign) UInt16 networkKeyIndex;

/// Encodes Network Key Index in 2 bytes using Little Endian.
/// @returns Key Index encoded in 2 bytes.
- (NSData *)encodeNetKeyIndex;

/// Decodes the Network Key Index from 2 bytes at given offset.
/// There are no any checks whether the data at the given offset are valid, or even if the offset is not outside of the data range.
/// @param data The data from where the indexes should be read.
/// @param offset The offset from where to read the indexes.
/// @returns Decoded Key Index.
+ (UInt16)decodeNetKeyIndexFromData:(NSData *)data atOffset:(int)offset;

@end


@interface SigConfigAppKeyMessage : SigConfigMessage
/// Application Key Index.
@property (nonatomic,assign) UInt16 applicationKeyIndex;
@end


@interface SigConfigNetAndAppKeyMessage : SigConfigMessage
/// The Network Key Index.
@property (nonatomic,assign) UInt16 networkKeyIndex;
/// Application Key Index.
@property (nonatomic,assign) UInt16 applicationKeyIndex;

- (instancetype)initWithNetworkKeyIndex:(UInt16)networkKeyIndex applicationKeyIndex:(UInt16)applicationKeyIndex;

/// Encodes Network Key Index and Application Key Index in 3 bytes using Little Endian.
/// @returns Key Indexes encoded in 3 bytes.
- (NSData *)encodeNetAndAppKeyIndex;

/// Decodes the Network Key Index and Application Key Index from 3 bytes at given offset.
/// There are no any checks whether the data at the given offset are valid, or even if the offset is not outside of the data range.
/// @param data The data from where the indexes should be read.
/// @param offset The offset from where to read the indexes.
/// @returns Decoded Key Indexes.
+ (SigConfigNetAndAppKeyMessage *)decodeNetAndAppKeyIndexFromData:(NSData *)data atOffset:(int)offset;

@end


@interface SigConfigElementMessage : SigConfigMessage
/// The Unicast Address of the Model's parent Element.
@property (nonatomic,assign) UInt16 elementAddress;
@end


@interface SigConfigModelMessage : SigConfigElementMessage
/// The 16-bit Model identifier.
@property (nonatomic,assign) UInt16 modelIdentifier;
/// The 32-bit Model identifier.
@property (nonatomic,assign) UInt32 modelId;
@end


@interface SigConfigAnyModelMessage : SigConfigModelMessage
/// The Company identified, as defined in Assigned Numbers, or `nil`, if the Model is defined in Bluetooth Mesh Model Specification.
///
/// - seeAlso: https://www.bluetooth.com/specifications/assigned-numbers/company-identifiers/
@property (nonatomic,assign) UInt16 companyIdentifier;
@end


@interface SigConfigVendorModelMessage : SigConfigModelMessage
/// The Company identified, as defined in Assigned Numbers.
///
/// - seeAlso: https://www.bluetooth.com/specifications/assigned-numbers/company-identifiers/
@property (nonatomic,assign) UInt16 companyIdentifier;
@end


@interface SigConfigAddressMessage : SigConfigMessage
/// Value of the Address.
@property (nonatomic,assign,readonly) UInt16 address;
@end


@interface SigConfigVirtualLabelMessage : SigConfigMessage
/// Value of the 128-bt Virtual Label UUID.
@property (nonatomic,strong,readonly) CBUUID *virtualLabel;
@end


@interface SigConfigModelAppList : SigConfigStatusMessage
/// The 16-bit Model identifier.
@property (nonatomic,assign) UInt16 modelIdentifier;
/// The 32-bit Model identifier.
@property (nonatomic,assign) UInt32 modelId;
/// Application Key Indexes bound to the Model.
@property (nonatomic,strong) NSMutableArray <NSNumber *>*applicationKeyIndexes;//[KeyIndex]
@end


@interface SigConfigModelSubscriptionList : SigConfigStatusMessage
/// The 16-bit Model identifier.
@property (nonatomic,assign) UInt16 modelIdentifier;
/// The 32-bit Model identifier.
@property (nonatomic,assign) UInt32 modelId;
/// A list of Addresses.
@property (nonatomic,strong) NSMutableArray <NSNumber *>*addresses;//[Address]
@end


@interface SigCompositionDataPage : NSObject
/// Page number of the Composition Data to get.
@property (nonatomic,assign) UInt8 page;
/// Composition Data parameters as Data.
@property (nonatomic,strong) NSData *parameters;
@end

@interface SigPage0 : SigCompositionDataPage
/// The 16-bit Company Identifier (CID) assigned by the Bluetooth SIG.
/// The value of this property is obtained from node composition data.
@property (nonatomic,assign) UInt16 companyIdentifier;
/// The 16-bit vendor-assigned Product Identifier (PID).
/// The value of this property is obtained from node composition data.
@property (nonatomic,assign) UInt16 productIdentifier;
/// The 16-bit vendor-assigned Version Identifier (VID).
/// The value of this property is obtained from node composition data.
@property (nonatomic,assign) UInt16 versionIdentifier;
/// The minimum number of Replay Protection List (RPL) entries for this node.
/// The value of this property is obtained from node composition data.
@property (nonatomic,assign) UInt16 minimumNumberOfReplayProtectionList;
/// Node's features. See `NodeFeatures` for details.
@property (nonatomic,strong) SigNodeFeatures *features;
/// An array of node's elements.
@property (nonatomic,strong) NSMutableArray <SigElementModel *>*elements;

- (BOOL)isSegmented;
- (NSData *)parameters;

/// This initializer constructs the Page 0 of Composition Data from the given Node.
/// @param node  The Node to construct the Page 0 from.
- (instancetype)initWithNode:(SigNodeModel *)node;

/// This initializer should construct the message based on the received parameters.
/// @param parameters  The Access Layer parameters.
- (instancetype)initWithParameters:(NSData *)parameters;

@end

#pragma mark - detail message

#pragma mark opcode:0x00
@interface SigConfigAppKeyAdd : SigConfigNetAndAppKeyMessage
/// The 128-bit Application Key data.
@property (nonatomic,strong) NSData *key;
- (NSData *)parameters;
- (instancetype)initWithApplicationKey:(SigAppkeyModel *)applicationKey;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x01
@interface SigConfigAppKeyUpdate : SigConfigNetAndAppKeyMessage
/// The 128-bit Application Key data.
@property (nonatomic,strong) NSData *key;
- (NSData *)parameters;
- (instancetype)initWithApplicationKey:(SigAppkeyModel *)applicationKey;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x02
@interface SigConfigCompositionDataStatus : SigConfigMessage
/// The Composition Data page.
@property (nonatomic,strong) SigCompositionDataPage *page;
- (NSData *)parameters;
- (instancetype)initWithReportPage:(SigCompositionDataPage *)page;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x03
@interface SigConfigModelPublicationSet : SigConfigAnyModelMessage
@property (nonatomic,strong) SigPublish *publish;
- (NSData *)parameters;
- (instancetype)initWithPublish:(SigPublish *)publish toElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initWithPublish:(SigPublish *)publish toElementAddress:(UInt16)elementAddress model:(SigModelIDModel *)model;
- (instancetype)initWithDisablePublicationForModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8000
@interface SigConfigAppKeyDelete : SigConfigNetAndAppKeyMessage
- (NSData *)parameters;
- (instancetype)initWithApplicationKey:(SigAppkeyModel *)applicationKey;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8001
@interface SigConfigAppKeyGet : SigConfigNetKeyMessage
- (NSData *)parameters;
- (instancetype)initWithNetworkKeyIndex:(UInt16)networkKeyIndex;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8002
@interface SigConfigAppKeyList : SigConfigNetKeyMessage
/// Operation status.
@property (nonatomic,assign,readonly) SigConfigMessageStatus status;
/// Returns whether the operation was successful or not.
@property (nonatomic,assign,readonly) BOOL isSuccess;
/// The status as String.
@property (nonatomic,strong,readonly) NSString *message;

/// Application Key Indexes bound to the Network Key known to the Node.
@property (nonatomic,strong) NSMutableArray <NSNumber *>*applicationKeyIndexes;//[KeyIndex]
- (NSData *)parameters;
- (instancetype)initWithNetWorkKey:(SigNetkeyModel *)networkKey applicationKeys:(NSArray <SigAppkeyModel *>*)applicationKeys status:(SigConfigMessageStatus)status;
- (instancetype)initWithStatus:(SigConfigMessageStatus)status forMessage:(SigConfigAppKeyGet *)message;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8003
@interface SigConfigAppKeyStatus : SigConfigNetAndAppKeyMessage
@property (nonatomic,assign) SigConfigMessageStatus status;
- (NSData *)parameters;
- (instancetype)initWithApplicationKey:(SigAppkeyModel *)applicationKey;
- (instancetype)initWithStatus:(SigConfigMessageStatus)status forMessage:(SigConfigNetAndAppKeyMessage *)message;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8008
@interface SigConfigCompositionDataGet : SigConfigMessage
/// Page number of the Composition Data to get.
@property (nonatomic,assign) UInt8 page;
- (instancetype)initWithPage:(UInt8)page;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8009
@interface SigConfigBeaconGet : SigConfigMessage
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x800A
@interface SigConfigBeaconSet : SigConfigMessage
/// New Secure Network Beacon state.
@property (nonatomic,assign) BOOL state;

/// Configures the Secure Network Beacon behavior on the Node.
/// @param enable `True` to enable Secure Network Beacon feature,  `false` to disable.
- (instancetype)initWithEnable:(BOOL)enable;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x800B
@interface SigConfigBeaconStatus : SigConfigMessage
/// Secure Network Beacon state.
@property (nonatomic,assign) BOOL isEnabled;

/// Configures the Secure Network Beacon behavior on the Node.
/// @param enable `True` to enable Secure Network Beacon feature, `false` to disable.
- (instancetype)initWithEnable:(BOOL)enable;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x800C
@interface SigConfigDefaultTtlGet : SigConfigMessage
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x800D
@interface SigConfigDefaultTtlSet : SigConfigMessage
/// The Time To Live (TTL) value. Valid value is in range 0x00, 0x02...0x7F.
@property (nonatomic,assign) UInt8 ttl;
- (NSData *)parameters;
- (instancetype)initWithTtl:(UInt8)ttl;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x800E
@interface SigConfigDefaultTtlStatus : SigConfigMessage
/// The Time To Live (TTL) value. Valid value is in range 1...127.
@property (nonatomic,assign) UInt8 ttl;
- (NSData *)parameters;
- (instancetype)initWithTtl:(UInt8)ttl;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x800F
@interface SigConfigFriendGet : SigConfigMessage
- (instancetype)initWithParameters:(NSData *)parameters;
- (NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8010
@interface SigConfigFriendSet : SigConfigMessage
/// The new Friend state of the Node.
@property (nonatomic,assign) SigNodeFeaturesState state;
- (NSData *)parameters;
- (instancetype)initWithEnable:(BOOL)enable;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8011
@interface SigConfigFriendStatus : SigConfigMessage
/// The Friend feature state of the Node.
@property (nonatomic,assign) SigNodeFeaturesState state;
- (NSData *)parameters;
/// Creates the Config Friend Status message.
///
/// - parameter state: The Friend state of the Node.
- (instancetype)initWithState:(SigNodeFeaturesState)state;
- (instancetype)initWithNode:(SigNodeModel *)node;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8012
@interface SigConfigGATTProxyGet : SigConfigMessage
- (instancetype)initWithParameters:(NSData *)parameters;
- (NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8013
@interface SigConfigGATTProxySet : SigConfigMessage
/// The new GATT Proxy state of the Node.
@property (nonatomic,assign) SigNodeFeaturesState state;
/// The interval between retransmissions, in seconds.
- (NSData *)parameters;
/// Configures the GATT Proxy on the Node.
///
/// When disabled, the Node will no longer be able to work as a GATT Proxy
/// until enabled again.
///
/// - parameter enable: `True` to enable GATT Proxy feature, `false` to disable.
- (instancetype)initWithEnable:(BOOL)enable;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8014
@interface SigConfigGATTProxyStatus : SigConfigMessage
/// The GATT Proxy state of the Node.
@property (nonatomic,assign) SigNodeFeaturesState state;
- (NSData *)parameters;
/// Creates the Config GATT Proxy Status message.
///
/// - parameter state: The GATT Proxy state of the Node.
- (instancetype)initWithState:(SigNodeFeaturesState)state;
- (instancetype)initWithNode:(SigNodeModel *)node;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8015

/// 4.3.2.58 Config Key Refresh Phase Get
/// - seeAlso: Mesh_v1.0.pdf  (page.177)
@interface SigConfigKeyRefreshPhaseGet : SigConfigMessage
/// Index of the NetKey.
@property (nonatomic,assign) UInt16 netKeyIndex;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
- (instancetype)initWithNetKeyIndex:(UInt16)netKeyIndex;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8016

/// 4.3.2.59 Config Key Refresh Phase Set
/// - seeAlso: Mesh_v1.0.pdf  (page.177)
@interface SigConfigKeyRefreshPhaseSet : SigConfigMessage
/// Index of the NetKey.
@property (nonatomic,assign) UInt16 netKeyIndex;
/// New Key Refresh Phase Transition.
@property (nonatomic,assign) SigControllableKeyRefreshTransitionValues transition;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
- (instancetype)initWithNetKeyIndex:(UInt16)netKeyIndex transition:(SigControllableKeyRefreshTransitionValues)transition;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8017

/// 4.3.2.60 Config Key Refresh Phase Status
/// - seeAlso: Mesh_v1.0.pdf  (page.177)
@interface SigConfigKeyRefreshPhaseStatus : SigConfigMessage
/// Status Code for the requesting message.
@property (nonatomic,assign) SigConfigMessageStatus status;
/// Index of the NetKey.
@property (nonatomic,assign) UInt16 netKeyIndex;
/// Key Refresh Phase State.
@property (nonatomic, assign) KeyRefreshPhase phase;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8018
@interface SigConfigModelPublicationGet : SigConfigAnyModelMessage
- (NSData *)parameters;
- (instancetype)initWithElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8019
@interface SigConfigModelPublicationStatus : SigConfigAnyModelMessage
@property (nonatomic,strong) SigPublish *publish;
@property (nonatomic,assign,readonly) SigConfigMessageStatus status;
- (NSData *)parameters;
- (instancetype)initResponseToSigConfigAnyModelMessage:(SigConfigAnyModelMessage *)request;
- (instancetype)initResponseToSigConfigAnyModelMessage:(SigConfigAnyModelMessage *)request withPublish:(SigPublish *)publish;
- (instancetype)initResponseToSigConfigAnyModelMessage:(SigConfigAnyModelMessage *)request withStatus:(SigConfigMessageStatus)status;
- (instancetype)initWithConfirmSigConfigModelPublicationSet:(SigConfigModelPublicationSet *)request;
- (instancetype)initWithConfirmSigConfigModelPublicationVirtualAddressSet:(SigConfigModelPublicationVirtualAddressSet *)request;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x801A
@interface SigConfigModelPublicationVirtualAddressSet : SigConfigAnyModelMessage
@property (nonatomic,strong) SigPublish *publish;
- (NSData *)parameters;
- (instancetype)initWithPublish:(SigPublish *)publish toElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initWithPublish:(SigPublish *)publish toElementAddress:(UInt16)elementAddress model:(SigModelIDModel *)model;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x801B
@interface SigConfigModelSubscriptionAdd : SigConfigAnyModelMessage
@property (nonatomic,assign) UInt16 address;
- (NSData *)parameters;
- (instancetype)initWithGroupAddress:(UInt16)groupAddress toElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initWithGroup:(SigGroupModel *)group toElementAddress:(UInt16)elementAddress model:(SigModelIDModel *)model;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x801C
@interface SigConfigModelSubscriptionDelete : SigConfigAnyModelMessage
@property (nonatomic,assign) UInt16 address;
- (NSData *)parameters;
- (instancetype)initWithGroupAddress:(UInt16)groupAddress elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initWithGroup:(SigGroupModel *)group fromModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x801D
@interface SigConfigModelSubscriptionDeleteAll : SigConfigAnyModelMessage
- (NSData *)parameters;
- (instancetype)initWithElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initFromModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x801E
@interface SigConfigModelSubscriptionOverwrite : SigConfigAnyModelMessage
@property (nonatomic,assign) UInt16 address;
- (NSData *)parameters;
- (instancetype)initWithGroupAddress:(UInt16)groupAddress elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initWithGroup:(SigGroupModel *)group toModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x801F
@interface SigConfigModelSubscriptionStatus : SigConfigAnyModelMessage
/// Operation status.
@property (nonatomic,assign) SigConfigMessageStatus status;
/// Returns whether the operation was successful or not.
@property (nonatomic,assign,readonly) BOOL isSuccess;
/// The status as String.
@property (nonatomic,strong,readonly) NSString *message;
@property (nonatomic,assign) UInt16 address;
- (NSData *)parameters;
- (instancetype)initResponseToSigConfigModelPublicationStatus:(SigConfigModelPublicationStatus *)request withStatus:(SigConfigMessageStatus *)status;
- (instancetype)initResponseToSigConfigAnyModelMessage:(SigConfigAnyModelMessage *)request withStatus:(SigConfigMessageStatus)status;
- (instancetype)initResponseToSigConfigModelSubscriptionDeleteAll:(SigConfigModelSubscriptionDeleteAll *)request withStatus:(SigConfigMessageStatus)status;
- (instancetype)initWithConfirmAddingGroup:(SigGroupModel *)group toModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress withStatus:(SigConfigMessageStatus)status;
- (instancetype)initWithConfirmDeletingAddress:(UInt16)address fromModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress withStatus:(SigConfigMessageStatus)status;
- (instancetype)initWithConfirmDeletingAllFromModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8020
@interface SigConfigModelSubscriptionVirtualAddressAdd : SigConfigAnyModelMessage
/// Value of the 128-bt Virtual Label UUID.
@property (nonatomic,strong) CBUUID *virtualLabel;
- (NSData *)parameters;
- (instancetype)initWithVirtualLabel:(CBUUID *)virtualLabel elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initWithGroup:(SigGroupModel *)group toModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8021
@interface SigConfigModelSubscriptionVirtualAddressDelete : SigConfigAnyModelMessage
/// Value of the 128-bt Virtual Label UUID.
@property (nonatomic,strong,readonly) CBUUID *virtualLabel;
- (NSData *)parameters;
- (instancetype)initWithVirtualLabel:(CBUUID *)virtualLabel elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initWithGroup:(SigGroupModel *)group fromModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8022
@interface SigConfigModelSubscriptionVirtualAddressOverwrite : SigConfigAnyModelMessage
/// Value of the 128-bt Virtual Label UUID.
@property (nonatomic,strong,readonly) CBUUID *virtualLabel;
- (NSData *)parameters;
- (instancetype)initWithVirtualLabel:(CBUUID *)virtualLabel elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initWithGroup:(SigGroupModel *)group fromModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8023
@interface SigConfigNetworkTransmitGet : SigConfigMessage
- (instancetype)initWithParameters:(NSData *)parameters;
- (NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8024
@interface SigConfigNetworkTransmitSet : SigConfigMessage
/// Number of message transmissions of Network PDU originating from the
/// Node. Possible values are 0...7, which correspond to 1-8 transmissions
/// in total.
@property (nonatomic,assign) UInt8 count;
/// Number of 10-millisecond steps between transmissions, decremented by 1.
/// Possible values are 0...31, which corresponds to 10-320 milliseconds
/// intervals.
@property (nonatomic,assign) UInt8 steps;
/// The interval between retransmissions, in seconds.
//- (NSTimeInterval)interval;
- (NSData *)parameters;
/// Sets the Network Transmit property of the Node.
///
/// - parameter count: Number of message transmissions of Network PDU
///                    originating from the Node. Possible values are 0...7,
///                    which correspond to 1-8 transmissions in total.
/// - parameter steps: Number of 10-millisecond steps between transmissions,
///                    decremented by 1. Possible values are 0...31, which
///                    corresponds to 10-320 milliseconds intervals.
- (instancetype)initWithCount:(UInt8)count steps:(UInt8)steps;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8025
@interface SigConfigNetworkTransmitStatus : SigConfigMessage
/// Number of message transmissions of Network PDU originating from the
/// Node. Possible values are 0...7, which correspond to 1-8 transmissions
/// in total.
@property (nonatomic,assign) UInt8 count;
/// Number of 10-millisecond steps between transmissions, decremented by 1.
/// Possible values are 0...31, which corresponds to 10-320 milliseconds
/// intervals.
@property (nonatomic,assign) UInt8 steps;
/// The interval between retransmissions, in seconds.
- (NSTimeInterval)interval;
- (NSData *)parameters;
/// Sets the Network Transmit property of the Node.
///
/// - parameter count: Number of message transmissions of Network PDU
///                    originating from the Node. Possible values are 0...7,
///                    which correspond to 1-8 transmissions in total.
/// - parameter steps: Number of 10-millisecond steps between transmissions,
///                    decremented by 1. Possible values are 0...31, which
///                    corresponds to 10-320 milliseconds intervals.
- (instancetype)initWithCount:(UInt8)count steps:(UInt8)steps;
- (instancetype)initWithNode:(SigNodeModel *)node;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8026
@interface SigConfigRelayGet : SigConfigMessage
@property (nonatomic,assign) UInt8 page;
- (instancetype)initWithParameters:(NSData *)parameters;
- (NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8027
@interface SigConfigRelaySet : SigConfigMessage
/// The new Relay state for the Node.
@property (nonatomic,assign) SigNodeRelayState state;
/// Number of retransmissions on advertising bearer for each Network PDU
/// relayed by the Node. Possible values are 0...7, which correspond to
/// 1-8 transmissions in total.
@property (nonatomic,assign) UInt8 count;
/// Number of 10-millisecond steps between retransmissions, decremented by 1.
/// Possible values are 0...31, which corresponds to 10-320 milliseconds
/// intervals.
@property (nonatomic,assign) UInt8 steps;
/// The interval between retransmissions, in seconds.
- (NSTimeInterval)interval;
- (NSData *)parameters;
- (instancetype)initWithCount:(UInt8)count steps:(UInt8)steps;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8028
@interface SigConfigRelayStatus : SigConfigMessage
/// The new Relay state for the Node.
@property (nonatomic,assign) SigNodeFeaturesState state;
/// Number of retransmissions on advertising bearer for each Network PDU
/// relayed by the Node. Possible values are 0...7, which correspond to
/// 1-8 transmissions in total.
@property (nonatomic,assign) UInt8 count;
/// Number of 10-millisecond steps between retransmissions, decremented by 1.
/// Possible values are 0...31, which corresponds to 10-320 milliseconds
/// intervals.
@property (nonatomic,assign) UInt8 steps;
/// The interval between retransmissions, in seconds.
- (NSTimeInterval)interval;
- (NSData *)parameters;
//- (instancetype)initWithState:(SigNodeFeaturesState)state count:(UInt8)count steps:(UInt8)steps;
//- (instancetype)initWithNode:(SigNodeModel *)node;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8029
@interface SigConfigSIGModelSubscriptionGet : SigConfigModelMessage
- (NSData *)parameters;
- (instancetype)initWithElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initOfModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x802A
@interface SigConfigSIGModelSubscriptionList : SigConfigModelSubscriptionList
@property (nonatomic,assign) UInt16 elementAddress;
- (NSData *)parameters;
- (instancetype)initForModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress addresses:(NSArray <NSNumber *>*)addresses withStatus:(SigConfigMessageStatus)status;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x802B
@interface SigConfigVendorModelSubscriptionGet : SigConfigVendorModelMessage
- (NSData *)parameters;
- (instancetype)initWithElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initOfModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x802C
@interface SigConfigVendorModelSubscriptionList : SigConfigVendorModelMessage
@property (nonatomic,assign) SigConfigMessageStatus status;
@property (nonatomic,strong) NSMutableArray <NSNumber *>*addresses;//[Address]
- (NSData *)parameters;
- (instancetype)initForModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress addresses:(NSArray <NSNumber *>*)addresses withStatus:(SigConfigMessageStatus)status;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x802D

/// 4.3.2.67 Config Low Power Node PollTimeout Get
/// - seeAlso: Mesh_v1.0.pdf  (page.181)
@interface SigConfigLowPowerNodePollTimeoutGet : SigConfigMessage
/// The unicast address of the Low Power node.
@property (nonatomic,assign) UInt16 LPNAddress;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
- (instancetype)initWithLPNAddress:(UInt16)LPNAddress;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x802E

/// 4.3.2.68 Config Low Power Node PollTimeout Status
/// - seeAlso: Mesh_v1.0.pdf  (page.182)
@interface SigConfigLowPowerNodePollTimeoutStatus : SigConfigMessage
/// The unicast address of the Low Power node.
@property (nonatomic,assign) UInt16 LPNAddress;
/// The current value of the PollTimeout timer of the Low Power node. Size is 3 bytes.
@property (nonatomic,assign) UInt32 pollTimeout;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8038

/// 4.3.2.61 Config Heartbeat Publication Get
/// - seeAlso: Mesh_v1.0.pdf  (page.178)
@interface SigConfigHeartbeatPublicationGet : SigConfigMessage
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8039

/// 4.3.2.62 Config Heartbeat Publication Set
/// - seeAlso: Mesh_v1.0.pdf  (page.179)
@interface SigConfigHeartbeatPublicationSet : SigConfigMessage
/// Destination address for Heartbeat messages.
@property (nonatomic,assign) UInt16 destination;
/*
 Table 4.24: Heartbeat Publication Count Log values

Value          Description
0x00           Heartbeat messages are not being sent periodically
0x01–0x11      Number of Heartbeat messages, 2^(n-1), that remain to be sent
0x12-0xFE      Prohibited
0xFF           Heartbeat messages are being sent indefinitely
 */
/// Number of Heartbeat messages to be sent.
@property (nonatomic,assign) UInt8 countLog;
/*
 Table 4.25: Heartbeat Publication Period Log values

Value          Description
0x00           Heartbeat messages are not being sent periodically
0x01–0x11      Period in 2^(n-1) seconds for sending periodical Heartbeat messages
0x12-0xFF      Prohibited
 */
/// Period for sending Heartbeat messages.
@property (nonatomic,assign) UInt8 periodLog;
/*
 Table 4.26: Heartbeat Publication TTL values

Value          Description
0x00–0x7F      The Heartbeat Publication TTL state
0x80-0xFF      Prohibited
 */
/// Number of Heartbeat messages to be sent.
@property (nonatomic,assign) UInt8 ttl;
/// Bit field indicating features that trigger Heartbeat messages when changed.
@property (nonatomic,assign) SigFeatures features;
/// Index of the NetKey.
@property (nonatomic,assign) UInt16 netKeyIndex;

- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
- (instancetype)initWithDestination:(UInt16)destination countLog:(UInt8)countLog periodLog:(UInt8)periodLog ttl:(UInt8)ttl features:(SigFeatures)features netKeyIndex:(UInt16)netKeyIndex;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x06

/// 4.3.2.63 Config Heartbeat Publication Status
/// - seeAlso: Mesh_v1.0.pdf  (page.179)
@interface SigConfigHeartbeatPublicationStatus : SigConfigMessage
/// Status Code for the requesting message.
@property (nonatomic,assign) SigConfigMessageStatus status;
/// Destination address for Heartbeat messages.
@property (nonatomic,assign) UInt16 destination;
/*
 Table 4.24: Heartbeat Publication Count Log values

Value          Description
0x00           Heartbeat messages are not being sent periodically
0x01–0x11      Number of Heartbeat messages, 2^(n-1), that remain to be sent
0x12-0xFE      Prohibited
0xFF           Heartbeat messages are being sent indefinitely
 */
/// Number of Heartbeat messages to be sent.
@property (nonatomic,assign) UInt8 countLog;
/*
 Table 4.25: Heartbeat Publication Period Log values

Value          Description
0x00           Heartbeat messages are not being sent periodically
0x01–0x11      Period in 2^(n-1) seconds for sending periodical Heartbeat messages
0x12-0xFF      Prohibited
 */
/// Period for sending Heartbeat messages.
@property (nonatomic,assign) UInt8 periodLog;
/*
 Table 4.26: Heartbeat Publication TTL values

Value          Description
0x00–0x7F      The Heartbeat Publication TTL state
0x80-0xFF      Prohibited
 */
/// Number of Heartbeat messages to be sent.
@property (nonatomic,assign) UInt8 ttl;
/// Bit field indicating features that trigger Heartbeat messages when changed.
@property (nonatomic,assign) SigFeatures features;
/// Index of the NetKey.
@property (nonatomic,assign) UInt16 netKeyIndex;

- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x803A

/// 4.3.2.64 Config Heartbeat Subscription Get
/// - seeAlso: Mesh_v1.0.pdf  (page.180)
@interface SigConfigHeartbeatSubscriptionGet : SigConfigMessage
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x803B

/// 4.3.2.65 Config Heartbeat Subscription Set
/// - seeAlso: Mesh_v1.0.pdf  (page.180)
@interface SigConfigHeartbeatSubscriptionSet : SigConfigMessage
/// Source address for Heartbeat messages.
@property (nonatomic,assign) UInt16 source;
/// Destination address for Heartbeat messages.
@property (nonatomic,assign) UInt16 destination;
/*
 Table 4.25: Heartbeat Publication Period Log values

Value          Description
0x00           Heartbeat messages are not being sent periodically
0x01–0x11      Period in 2^(n-1) seconds for sending periodical Heartbeat messages
0x12-0xFF      Prohibited
 */
/// Period for sending Heartbeat messages.
@property (nonatomic,assign) UInt8 periodLog;

- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
- (instancetype)initWithSource:(UInt16)source destination:(UInt16)destination periodLog:(UInt8)periodLog;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x803C

/// 4.3.2.66 Config Heartbeat Subscription Status
/// - seeAlso: Mesh_v1.0.pdf  (page.181)
@interface SigConfigHeartbeatSubscriptionStatus : SigConfigMessage
/// Status Code for the requesting message.
@property (nonatomic,assign) SigConfigMessageStatus status;
/// Source address for Heartbeat messages.
@property (nonatomic,assign) UInt16 source;
/// Destination address for Heartbeat messages.
@property (nonatomic,assign) UInt16 destination;
/*
 Table 4.25: Heartbeat Publication Period Log values

Value          Description
0x00           Heartbeat messages are not being sent periodically
0x01–0x11      Period in 2^(n-1) seconds for sending periodical Heartbeat messages
0x12-0xFF      Prohibited
 */
/// Period for sending Heartbeat messages.
@property (nonatomic,assign) UInt8 periodLog;
/*
 Table 4.24: Heartbeat Publication Count Log values

Value          Description
0x00           Heartbeat messages are not being sent periodically
0x01–0x11      Number of Heartbeat messages, 2^(n-1), that remain to be sent
0x12-0xFE      Prohibited
0xFF           Heartbeat messages are being sent indefinitely
 */
/// Number of Heartbeat messages to be sent.
@property (nonatomic,assign) UInt8 countLog;
/*
 Table 4.30: Heartbeat Subscription Min TTL values

Value          Description
0x00           No Heartbeat messages have been received
0x01–0x7F      The Heartbeat Subscription Min Hops state
0x80-0xFF      Prohibited
 */
/// Minimum hops when receiving Heartbeat messages.
@property (nonatomic,assign) UInt8 minHops;
/*
 Table 4.31: Heartbeat Subscription Max TTL values

Value          Description
 0x00           No Heartbeat messages have been received
 0x01–0x7F      The Heartbeat Subscription Max Hops state
 0x80-0xFF      Prohibited
 */
/// Maximum hops when receiving Heartbeat messages.
@property (nonatomic,assign) UInt8 maxHops;

- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x803D

/// 4.3.2.46 Config Model App Bind
/// - seeAlso: Mesh_v1.0.pdf  (page.173)
@interface SigConfigModelAppBind : SigConfigAppKeyMessage
/// The Company identified, as defined in Assigned Numbers, or `nil`,
/// if the Model is defined in Bluetooth Mesh Model Specification.
///
/// - seeAlso: https://www.bluetooth.com/specifications/assigned-numbers/company-identifiers/
@property (nonatomic,assign,readonly) UInt16 companyIdentifier;
/// The 16-bit Model identifier.
@property (nonatomic,assign) UInt16 modelIdentifier;
///// The 32-bit Model identifier.
//@property (nonatomic,assign,readonly) UInt32 modelId;
/// The Unicast Address of the Model's parent Element.
@property (nonatomic,assign,readonly) UInt16 elementAddress;

- (NSData *)parameters;
- (instancetype)initWithApplicationKeyIndex:(UInt16)applicationKeyIndex elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initWithApplicationKey:(SigAppkeyModel *)applicationKey toModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x803E
@interface SigConfigModelAppStatus : SigConfigAppKeyMessage
/// The Company identified, as defined in Assigned Numbers, or `nil`,
/// if the Model is defined in Bluetooth Mesh Model Specification.
///
/// - seeAlso: https://www.bluetooth.com/specifications/assigned-numbers/company-identifiers/
@property (nonatomic,assign,readonly) UInt16 companyIdentifier;
/// The 16-bit Model identifier.
@property (nonatomic,assign) UInt16 modelIdentifier;
///// The 32-bit Model identifier.
//@property (nonatomic,assign,readonly) UInt32 modelId;
/// The Unicast Address of the Model's parent Element.
@property (nonatomic,assign,readonly) UInt16 elementAddress;
@property (nonatomic,assign,readonly) SigConfigMessageStatus status;

- (NSData *)parameters;
- (instancetype)initWithConfirmBindingApplicationKey:(SigAppkeyModel *)applicationKey toModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress status:(SigConfigMessageStatus)status;
- (instancetype)initWithConfirmUnbindingApplicationKey:(SigAppkeyModel *)applicationKey toModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress status:(SigConfigMessageStatus)status;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x803F
@interface SigConfigModelAppUnbind : SigConfigAppKeyMessage
/// The Company identified, as defined in Assigned Numbers, or `nil`,
/// if the Model is defined in Bluetooth Mesh Model Specification.
///
/// - seeAlso: https://www.bluetooth.com/specifications/assigned-numbers/company-identifiers/
@property (nonatomic,assign,readonly) UInt16 companyIdentifier;
/// The 16-bit Model identifier.
@property (nonatomic,assign) UInt16 modelIdentifier;
/// The 32-bit Model identifier.
@property (nonatomic,assign,readonly) UInt32 modelId;
/// The Unicast Address of the Model's parent Element.
@property (nonatomic,assign,readonly) UInt16 elementAddress;
- (NSData *)parameters;
- (instancetype)initWithApplicationKeyIndex:(UInt16)applicationKeyIndex elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initWithApplicationKey:(SigAppkeyModel *)applicationKey toModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8040
@interface SigConfigNetKeyAdd : SigConfigNetKeyMessage
/// The 128-bit Application Key data.
@property (nonatomic,strong) NSData *key;
- (NSData *)parameters;
- (instancetype)initWithNetworkKeyIndex:(UInt16)networkKeyIndex networkKeyData:(NSData *)networkKeyData;
- (instancetype)initWithNetworkKey:(SigNetkeyModel *)networkKey;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8041
@interface SigConfigNetKeyDelete : SigConfigNetKeyMessage
- (NSData *)parameters;
- (instancetype)initWithNetworkKeyIndex:(UInt16)networkKeyIndex;
- (instancetype)initWithNetworkKey:(SigNetkeyModel *)networkKey;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8042
@interface SigConfigNetKeyGet : SigConfigMessage
- (instancetype)initWithParameters:(NSData *)parameters;
- (NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8043
@interface SigConfigNetKeyList : SigConfigMessage
/// Network Key Indexes known to the Node.
@property (nonatomic,strong) NSMutableArray <NSNumber *>*networkKeyIndexs;//[KeyIndex]
- (NSData *)parameters;
- (instancetype)initWithNetworkKeys:(NSArray <SigNetkeyModel *>*)networkKeys;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8044
@interface SigConfigNetKeyStatus : SigConfigNetKeyMessage
/// Returns whether the operation was successful or not.
@property (nonatomic,assign,readonly) BOOL isSuccess;
/// The status as String.
@property (nonatomic,strong,readonly) NSString *message;

@property (nonatomic,assign) SigConfigMessageStatus status;
- (NSData *)parameters;
- (instancetype)initWithNetworkKey:(SigNetkeyModel *)networkKey;
- (instancetype)initWithStatus:(SigConfigMessageStatus)status forMessage:(SigConfigNetKeyMessage *)message;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8045
@interface SigConfigNetKeyUpdate : SigConfigNetKeyMessage
/// The 128-bit Application Key data.
@property (nonatomic,strong) NSData *key;
- (NSData *)parameters;
- (instancetype)initWithNetworkKeyIndex:(UInt16)networkKeyIndex networkKeyData:(NSData *)networkKeyData;
- (instancetype)initWithNetworkKey:(SigNetkeyModel *)networkKey;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8046

/// 4.3.2.43 Config Node Identity Get
/// - seeAlso: Mesh_v1.0.pdf  (page.171)
@interface SigConfigNodeIdentityGet : SigConfigMessage
/// Index of the NetKey.
@property (nonatomic,assign) UInt16 netKeyIndex;
- (NSData *)parameters;
- (instancetype)initWithNetKeyIndex:(UInt16)netKeyIndex;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8047

/// 4.3.2.44 Config Node Identity Set
/// - seeAlso: Mesh_v1.0.pdf  (page.172)
@interface SigConfigNodeIdentitySet : SigConfigMessage
/// Index of the NetKey.
@property (nonatomic,assign) UInt16 netKeyIndex;
/// New Node Identity state.
@property (nonatomic,assign) SigNodeIdentityState identity;
- (NSData *)parameters;
- (instancetype)initWithNetKeyIndex:(UInt16)netKeyIndex identity:(SigNodeIdentityState)identity;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x8048

/// 4.3.2.45 Config Node Identity Status
/// - seeAlso: Mesh_v1.0.pdf  (page.172)
@interface SigConfigNodeIdentityStatus : SigConfigMessage
/// Status Code for the requesting message.
@property (nonatomic,assign) SigConfigMessageStatus status;
/// Index of the NetKey.
@property (nonatomic,assign) UInt16 netKeyIndex;
/// Node Identity state.
@property (nonatomic,assign) SigNodeIdentityState identity;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8049
@interface SigConfigNodeReset : SigConfigMessage
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x804A
@interface SigConfigNodeResetStatus : SigConfigMessage
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x804B
@interface SigConfigSIGModelAppGet : SigConfigModelMessage
- (NSData *)parameters;
- (instancetype)initWithElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initWithModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x804C
@interface SigConfigSIGModelAppList : SigConfigModelAppList
@property (nonatomic,assign,readonly) UInt16 elementAddress;
- (NSData *)parameters;
- (instancetype)initResponseToSigConfigSIGModelAppGet:(SigConfigSIGModelAppGet *)request withApplicationKeys:(NSArray <SigAppkeyModel *>*)applicationKeys;
- (instancetype)initResponseToSigConfigSIGModelAppGet:(SigConfigSIGModelAppGet *)request withStatus:(SigConfigMessageStatus)status;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x804D
@interface SigConfigVendorModelAppGet : SigConfigVendorModelMessage
- (NSData *)parameters;
- (instancetype)initWithElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier;
- (instancetype)initWithModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0x804E
@interface SigConfigVendorModelAppList : SigConfigModelAppList
@property (nonatomic,assign) UInt16 elementAddress;
@property (nonatomic,assign) UInt16 companyIdentifier;
- (NSData *)parameters;
- (instancetype)initWithModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress applicationKeys:(NSArray <SigAppkeyModel *>*)applicationKeys status:(SigConfigMessageStatus)status;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark - remote provision

#pragma mark opcode:0x804F

/// 4.3.4.1 Remote Provisioning Scan Capabilities Get
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.18)
@interface SigRemoteProvisioningScanCapabilitiesGet : SigConfigMessage
- (NSData *)parameters;
@end


#pragma mark opcode:0x805F

/// 4.3.4.2 Remote Provisioning Scan Capabilities Status
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.18)
@interface SigRemoteProvisioningScanCapabilitiesStatus : SigConfigMessage
/// The maximum number of UUIDs that can be reported during scanning.
@property (nonatomic,assign) UInt8 maxScannedItems;
/// Indication if active scan is supported.
@property (nonatomic,assign) BOOL activeScan;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8051

/// 4.3.4.3 Remote Provisioning Scan Get
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.18)
@interface SigRemoteProvisioningScanGet : SigConfigMessage
- (NSData *)parameters;
@end


#pragma mark opcode:0x8052

/// 4.3.4.4 Remote Provisioning Scan Start
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.18)
@interface SigRemoteProvisioningScanStart : SigConfigMessage
/// Maximum number of scanned items to be reported.
@property (nonatomic,assign) UInt8 scannedItemsLimit;
/// Time limit for a scan (in seconds).
@property (nonatomic,assign) UInt8 timeout;
/// Device UUID (Optional)
@property (nonatomic,strong) NSData *UUID;
- (NSData *)parameters;
- (instancetype)initWithScannedItemsLimit:(UInt8)scannedItemsLimit timeout:(UInt8)timeout UUID:(nullable NSData *)UUID;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8053

/// 4.3.4.5 Remote Provisioning Scan Stop
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.19)
@interface SigRemoteProvisioningScanStop : SigConfigMessage
- (NSData *)parameters;
@end


#pragma mark opcode:0x8054

/// 4.3.4.6 Remote Provisioning Scan Status
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.19)
@interface SigRemoteProvisioningScanStatus : SigConfigMessage
/// Status for the requesting message.
@property (nonatomic,assign) UInt8 status;
/// The Remote Provisioning Scan state value.
@property (nonatomic,assign) UInt8 RPScanningState;
/// Maximum number of scanned items to be reported.
@property (nonatomic,assign) UInt8 scannedItemsLimit;
/// Time limit for a scan (in seconds).
@property (nonatomic,assign) UInt8 timeout;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8055

/// 4.3.4.7 Remote Provisioning Scan Report
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.20)
@interface SigRemoteProvisioningScanReport : SigConfigMessage
/// Signed integer that is interpreted as an indication of received signal strength measured in dBm..
@property (nonatomic,assign) SInt8 RSSI;
/// Device UUID.
@property (nonatomic,strong) NSData *UUID;
/// OOB information.
@property (nonatomic,assign) UInt16 OOB;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8056

/// 4.3.4.8 Remote Provisioning Extended Scan Start
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.20)
@interface SigRemoteProvisioningExtendedScanStart : SigConfigMessage
/// Number of AD Types in the ADTypeFilter field.
@property (nonatomic,assign) UInt8 ADTypeFilterCount;
/// List of AD Types to be reported, size:variable.
@property (nonatomic,strong) NSData *ADTypeFilter;
/// Device UUID (Optional).
@property (nonatomic,strong) NSData *UUID;
/// Time limit for a scan (in seconds). Length of time (in seconds) to collect information about the unprovisioned device: 0x01~0x05
@property (nonatomic,assign) UInt8 timeout;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
- (instancetype)initWithADTypeFilterCount:(UInt8)ADTypeFilterCount ADTypeFilter:(nullable NSData *)ADTypeFilter UUID:(nullable NSData *)UUID timeout:(UInt8)timeout;
@end


#pragma mark opcode:0x8057

/// 4.3.4.9 Remote Provisioning Extended Scan Report
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.21)
@interface SigRemoteProvisioningExtendedScanReport : SigConfigMessage
/// Status for the requesting message.
@property (nonatomic,assign) SigRemoteProvisioningStatus status;
/// Device UUID (Optional).
@property (nonatomic,strong) NSData *UUID;
/// OOB Information (Optional).
@property (nonatomic,assign) UInt16 OOBInformation;
/// Concatenated list of AD Structures that match the AD Types requested by the client in the ADTypeFilter field of the Remote Provisioning Extended Scan Start message. size:variable
@property (nonatomic,strong) NSData *AdvStructures;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x8058

/// 4.3.4.10 Remote Provisioning Link Get
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.22)
@interface SigRemoteProvisioningLinkGet : SigConfigMessage
- (NSData *)parameters;
@end


#pragma mark opcode:0x8059

/// 4.3.4.11 Remote Provisioning Link Open
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.22)
@interface SigRemoteProvisioningLinkOpen : SigConfigMessage
/// Device UUID (Optional).
@property (nonatomic,strong) NSData *UUID;
- (NSData *)parameters;
- (instancetype)initWithUUID:(nullable NSData *)UUID;
@end


#pragma mark opcode:0x805A

/// 4.3.4.12 Remote Provisioning Link Close
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.23)
@interface SigRemoteProvisioningLinkClose : SigConfigMessage
/// Link close reason code.
@property (nonatomic,assign) SigRemoteProvisioningLinkCloseStatus reason;
- (NSData *)parameters;
- (instancetype)initWithReason:(SigRemoteProvisioningLinkCloseStatus)reason;
@end


#pragma mark opcode:0x805B

/// 4.3.4.13 Remote Provisioning Link Status
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.23)
@interface SigRemoteProvisioningLinkStatus : SigConfigMessage
/// Status for the requesting message.
@property (nonatomic,assign) SigRemoteProvisioningStatus status;
/// Remote Provisioning Link state
@property (nonatomic,assign) BOOL RPState;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x805C

/// 4.3.4.14 Remote Provisioning Link Report
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.24)
@interface SigRemoteProvisioningLinkReport : SigConfigMessage
/// Status for the requesting message.
@property (nonatomic,assign) SigRemoteProvisioningStatus status;
/// Remote Provisioning Link state
@property (nonatomic,assign) BOOL RPState;
/// Link close Reason code (Optional).
@property (nonatomic,assign) SigRemoteProvisioningLinkCloseStatus reason;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x805D

/// 4.3.4.14 Remote Provisioning PDU Send
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.24)
@interface SigRemoteProvisioningPDUSend : SigConfigMessage
/// Provisioning PDU identification number.
@property (nonatomic,assign) UInt8 outboundPDUNumber;
/// Provisioning PDU.
@property (nonatomic,strong) NSData *provisioningPDU;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
- (instancetype)initWithOutboundPDUNumber:(UInt8)outboundPDUNumber provisioningPDU:(NSData *)provisioningPDU;
@end


#pragma mark opcode:0x805E

/// 4.3.4.14 Remote Provisioning PDU Outbound Report
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.25)
@interface SigRemoteProvisioningPDUOutboundReport : SigConfigMessage
/// Provisioning PDU identification number.
@property (nonatomic,assign) UInt8 outboundPDUNumber;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0x805F

/// 4.3.4.14 Remote Provisioning PDU Report
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.25)
@interface SigRemoteProvisioningPDUReport : SigConfigMessage
/// Provisioning PDU identification number.
@property (nonatomic,assign) UInt8 outboundPDUNumber;
/// Provisioning PDU.
@property (nonatomic,strong) NSData *provisioningPDU;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


#pragma mark opcode:0xB809

/// 4.3.9.2 OPCODES_AGGREGATOR_SEQUENCE
/// - seeAlso: MshPRFd1.1r13_clean.pdf  (page.389)
@interface SigOpcodesAggregatorSequence : SigConfigMessage
/// The Element_Address field is the unicast address of the element. All other address types are prohibited.
@property (nonatomic,assign) UInt16 elementAddress;
/// List of items with each item represented as an Aggregator Item.
@property (nonatomic,strong) NSArray <SigOpcodesAggregatorItemModel *>*items;
/// 使用SDK的方法`initWithParameters:`和`initWithElementAddress:items:`初始化的SigOpcodesAggregatorSequence，会自动根据输入的items的第一个message使用的key来赋值isEncryptByDeviceKey。
@property (nonatomic,assign) BOOL isEncryptByDeviceKey;// default is NO.

- (NSData *)parameters;
- (NSData *)opCodeAndParameters;
- (instancetype)initWithParameters:(NSData *)parameters;
- (instancetype)initWithElementAddress:(UInt16)elementAddress items:(NSArray <SigOpcodesAggregatorItemModel *>*)items;
@end


#pragma mark opcode:0xB810

/// 4.3.9.3 OPCODES_AGGREGATOR_STATUS
/// - seeAlso: MshPRFd1.1r13_clean.pdf  (page.389)
@interface SigOpcodesAggregatorStatus : SigConfigMessage
/// The Status field indicates the status of the most recent operation.
@property (nonatomic,assign) SigOpcodesAggregatorMessagesStatus status;
/// The Element_Address field is the unicast address of the element. All other address types are prohibited.
@property (nonatomic,assign) UInt16 elementAddress;
/// List of status items with each status item containing an unacknowledged access layer message or empty item (Optional).
@property (nonatomic,strong) NSArray <SigOpcodesAggregatorItemModel *>*statusItems;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
- (instancetype)initWithStatus:(SigOpcodesAggregatorMessagesStatus)status elementAddress:(UInt16)elementAddress items:(NSArray <SigOpcodesAggregatorItemModel *>*)items;
@end


#pragma mark - 4.3.12 Mesh Private Beacon messages

#pragma mark opcode:0xB711

@interface SigPrivateBeaconGet : SigConfigMessage
- (NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0xB712

@interface SigPrivateBeaconSet : SigConfigMessage
/// New Private Beacon state.
@property (nonatomic,assign) SigPrivateBeaconState privateBeacon;
/// New Random Update Interval Steps state (optional).
/// 0x00, Random field is updated for every Mesh Private beacon.
/// 0x01–0xFF, Random field is updated at an interval (in seconds) of (10 * Random Update Interval Steps).
@property (nonatomic,assign) UInt8 randomUpdateIntervalSteps;

- (instancetype)initWithPrivateBeacon:(SigPrivateBeaconState)privateBeacon randomUpdateIntervalSteps:(UInt8)randomUpdateIntervalSteps;
- (NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0xB713

@interface SigPrivateBeaconStatus : SigConfigMessage
/// Current value of the Private Beacon state.
@property (nonatomic,assign) SigPrivateBeaconState privateBeacon;
/// Current value of the Random Update Interval Steps state.
@property (nonatomic,assign) UInt8 randomUpdateIntervalSteps;

- (instancetype)initWithParameters:(NSData *)parameters;
- (instancetype)initWithPrivateBeacon:(SigPrivateBeaconState)privateBeacon randomUpdateIntervalSteps:(UInt8)randomUpdateIntervalSteps;
- (NSData *)parameters;
@end


#pragma mark opcode:0xB714

@interface SigPrivateGattProxyGet : SigConfigMessage
- (NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0xB715

@interface SigPrivateGattProxySet : SigConfigMessage
/// New Private GATT Proxy state.
@property (nonatomic,assign) SigPrivateGattProxyState privateGattProxy;

- (instancetype)initWithPrivateGattProxy:(SigPrivateGattProxyState)privateGattProxy;
- (NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0xB716

@interface SigPrivateGattProxyStatus : SigConfigMessage
/// Private GATT Proxy state.
@property (nonatomic,assign) SigPrivateGattProxyState privateGattProxy;

- (instancetype)initWithParameters:(NSData *)parameters;
- (instancetype)initWithPrivateGattProxy:(SigPrivateGattProxyState)privateGattProxy;
- (NSData *)parameters;
@end


#pragma mark opcode:0xB718

@interface SigPrivateNodeIdentityGet : SigConfigMessage
/// Index of the NetKey.
@property (nonatomic,assign) UInt16 netKeyIndex;
- (NSData *)parameters;
- (instancetype)initWithNetKeyIndex:(UInt16)netKeyIndex;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0xB719

@interface SigPrivateNodeIdentitySet : SigConfigMessage
/// Index of the NetKey.
@property (nonatomic,assign) UInt16 netKeyIndex;
/// New Private Node Identity state.
@property (nonatomic,assign) SigPrivateNodeIdentityState privateIdentity;
- (NSData *)parameters;
- (instancetype)initWithNetKeyIndex:(UInt16)netKeyIndex privateIdentity:(SigPrivateNodeIdentityState)privateIdentity;
- (instancetype)initWithParameters:(NSData *)parameters;
/// The Type of the response message.
- (Class)responseType;
/// The Op Code of the response message.
- (UInt32)responseOpCode;
@end


#pragma mark opcode:0xB71A

@interface SigPrivateNodeIdentityStatus : SigConfigMessage
/// Status Code for the requesting message.
@property (nonatomic,assign) SigOpcodesAggregatorMessagesStatus status;
/// Index of the NetKey.
@property (nonatomic,assign) UInt16 netKeyIndex;
/// Private Node Identity state.
@property (nonatomic,assign) SigPrivateNodeIdentityState privateIdentity;
- (NSData *)parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
@end

NS_ASSUME_NONNULL_END
