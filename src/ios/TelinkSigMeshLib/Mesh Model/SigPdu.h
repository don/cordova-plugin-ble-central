/********************************************************************************************************
 * @file     SigPdu.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/9/9
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

@class SigNetkeyModel,SigDataSource,SigLowerTransportPdu,SigIvIndex;

@interface SigPdu : NSObject
@property (nonatomic, strong) NSData *pduData;
@end


@interface SigProvisioningPdu : SigPdu
@property (nonatomic, assign) SigProvisioningPduType provisionType;
#pragma mark - 组包
//- (instancetype)initProvisioningPublicKeyPduWithPublicKey:(NSData *)publicKey;
//- (instancetype)initProvisioningConfirmationPduWithConfirmation:(NSData *)confirmation;
//- (instancetype)initProvisioningRandomPduWithRandom:(NSData *)random;
//- (instancetype)initProvisioningEncryptedDataWithMicPduWithEncryptedData:(NSData *)encryptedData;

/// The Provisioner sends a Provisioning Record Request PDU to request a provisioning record fragment (a part of a provisioning record; see Section 5.4.2.6) from the device.
/// @param recordID Identifies the provisioning record for which the request is made (see Section 5.4.2.6).
/// @param fragmentOffset The starting offset of the requested fragment in the provisioning record data.
/// @param fragmentMaximumSize The maximum size of the provisioning record fragment that the Provisioner can receive.
//- (instancetype)initProvisioningRecordRequestPDUWithRecordID:(UInt16)recordID fragmentOffset:(UInt16)fragmentOffset fragmentMaximumSize:(UInt16)fragmentMaximumSize;

/// The Provisioner sends a Provisioning Records Get PDU to request the list of IDs of the provisioning records that are stored on a device.
//- (instancetype)initProvisioningRecordsGetPDU;
//#pragma mark - 解包
//+ (void)analysisProvisioningCapabilities:(struct ProvisioningCapabilities *)provisioningCapabilities withData:(NSData *)data;

+ (Class)getProvisioningPduClassWithProvisioningPduType:(SigProvisioningPduType)provisioningPduType;

@end


/// 5.4.1.1 Provisioning Invite
/// - seeAlso: MshPRFv1.0.1.pdf (page.240)
@interface SigProvisioningInvitePdu : SigProvisioningPdu
/// Attention Timer state (See Section 4.2.9)
@property (nonatomic, assign) UInt8 attentionDuration;

- (instancetype)initWithAttentionDuration:(UInt8)attentionDuration;

@end


/// 5.4.1.2 Provisioning Capabilities
/// - seeAlso: MshPRFv1.0.1.pdf (page.240)
@interface SigProvisioningCapabilitiesPdu : SigProvisioningPdu
/// Number of elements supported by the device (Table 5.17)
@property (nonatomic, assign) UInt8 numberOfElements;
/// Supported algorithms and other capabilities (see Table 5.18)
@property (nonatomic, assign) struct Algorithms algorithms;
/// Supported public key types (see Table 5.19)
@property (nonatomic, assign) PublicKeyType publicKeyType;
/// Supported static OOB Types (see Table 5.20)
@property (nonatomic, assign) struct StaticOobType staticOobType;
/// Maximum size of Output OOB supported.
@property (nonatomic, assign) UInt8 outputOobSize;
/// Supported Output OOB Actions (see Table 5.22)
@property (nonatomic, assign) struct OutputOobActions outputOobActions;
/// Maximum size in octets of Input OOB supported (see Table 5.23)
@property (nonatomic, assign) UInt8 inputOobSize;
/// Supported Input OOB Actions (see Table 5.24)
@property (nonatomic, assign) struct InputOobActions inputOobActions;

- (instancetype)initWithParameters:(NSData *)parameters;
- (NSString *)getCapabilitiesString;

@end


/// 5.4.1.3 Provisioning Start
/// - seeAlso: MshPRFv1.0.1.pdf (page.243)
@interface SigProvisioningStartPdu : SigProvisioningPdu
/// The algorithm used for provisioning (see Table 5.26)
@property (nonatomic, assign) Algorithm algorithm;
/// Public Key used (see Table 5.27)
@property (nonatomic, assign) PublicKeyType publicKeyType;
/// Authentication Method used (see Table 5.28)
@property (nonatomic, assign) AuthenticationMethod authenticationMethod;
/// Selected Output OOB Action (see Table 5.29) or Input OOB Action (see Table 5.31) or 0x00
@property (nonatomic, assign) UInt8 authenticationAction;
/// Size of the Output OOB used (see Table 5.30) or size of the Input OOB used (see Table 5.32) or 0x00
@property (nonatomic, assign) UInt8 authenticationSize;

- (instancetype)initWithAlgorithm:(Algorithm)algorithm publicKeyType:(PublicKeyType)publicKeyType authenticationMethod:(AuthenticationMethod)authenticationMethod authenticationAction:(UInt8)authenticationAction authenticationSize:(UInt8)authenticationSize;

@end


/// 5.4.1.4 Provisioning Public Key
/// - seeAlso: MshPRFv1.0.1.pdf (page.245)
@interface SigProvisioningPublicKeyPdu : SigProvisioningPdu
/// The X component of public key for the FIPS P-256 algorithm
@property (nonatomic, strong) NSData *publicKeyX;
/// The Y component of public key for the FIPS P-256 algorithm
@property (nonatomic, strong) NSData *publicKeyY;
/// The public key for the FIPS P-256 algorithm
@property (nonatomic, strong) NSData *publicKey;

- (instancetype)initWithPublicKey:(NSData *)publicKey;
- (instancetype)initWithPublicKeyX:(NSData *)publicKeyX publicKeyY:(NSData *)publicKeyY;
- (instancetype)initWithParameters:(NSData *)parameters;

@end


/// 5.4.1.5 Provisioning Input Complete
/// - seeAlso: MshPRFv1.0.1.pdf (page.245)
@interface SigProvisioningInputCompletePdu : SigProvisioningPdu

- (instancetype)init;
- (instancetype)initWithParameters:(NSData *)parameters;

@end


/// 5.4.1.6 Provisioning Confirmation
/// - seeAlso: MshPRFv1.0.1.pdf (page.245)
@interface SigProvisioningConfirmationPdu : SigProvisioningPdu
/// The values exchanged so far including the OOB Authentication value
@property (nonatomic, strong) NSData *confirmation;

- (instancetype)initWithConfirmation:(NSData *)confirmation;
- (instancetype)initWithParameters:(NSData *)parameters;

@end


/// 5.4.1.7 Provisioning Random
/// - seeAlso: MshPRFv1.0.1.pdf (page.246)
@interface SigProvisioningRandomPdu : SigProvisioningPdu
/// The final input to the confirmation
@property (nonatomic, strong) NSData *random;

- (instancetype)initWithRandom:(NSData *)random;
- (instancetype)initWithParameters:(NSData *)parameters;

@end


/// 5.4.1.8 Provisioning Data
/// - seeAlso: MshPRFv1.0.1.pdf (page.246)
@interface SigProvisioningDataPdu : SigProvisioningPdu
/// An encrypted and authenticated network key, NetKey Index, Key Refresh Flag, IV Update Flag, current value of the IV Index, and unicast address of the primary element (see Section 5.4.2.5), szie is 25.
@property (nonatomic, strong) NSData *encryptedProvisioningData;
/// PDU Integrity Check value, size is 8
@property (nonatomic, strong) NSData *provisioningDataMIC;

- (instancetype)initWithEncryptedProvisioningData:(NSData *)encryptedProvisioningData provisioningDataMIC:(NSData *)provisioningDataMIC;

@end


/// 5.4.1.9 Provisioning Complete
/// - seeAlso: MshPRFv1.0.1.pdf (page.246)
@interface SigProvisioningCompletePdu : SigProvisioningPdu

- (instancetype)init;
- (instancetype)initWithParameters:(NSData *)parameters;

@end


/// 5.4.1.10 Provisioning Failed
/// - seeAlso: MshPRFv1.0.1.pdf (page.246)
@interface SigProvisioningFailedPdu : SigProvisioningPdu
/// This represents a specific error in the provisioning protocol encountered by a device.
@property (nonatomic, assign) ProvisioningError errorCode;

- (instancetype)initWithParameters:(NSData *)parameters;

@end


/// 5.4.1.11 Provisioning Record Request
/// - seeAlso: MshPRFd1.1r11_clean.pdf (page.495)
/// The Provisioner sends a Provisioning Record Request PDU to request a provisioning record fragment (a part of a provisioning record; see Section 5.4.2.6) from the device.
@interface SigProvisioningRecordRequestPdu : SigProvisioningPdu
/// Identifies the provisioning record for which the request is made (see Section 5.4.2.6).
@property (nonatomic, assign) UInt16 recordID;
/// fragmentOffset The starting offset of the requested fragment in the provisioning record data.
@property (nonatomic, assign) UInt16 fragmentOffset;
/// The maximum size of the provisioning record fragment that the Provisioner can receive.
@property (nonatomic, assign) UInt16 fragmentMaximumSize;

- (instancetype)initWithRecordID:(UInt16)recordID fragmentOffset:(UInt16)fragmentOffset fragmentMaximumSize:(UInt16)fragmentMaximumSize;

@end


/// 5.4.1.12 Provisioning Record Response
/// - seeAlso: MshPRFd1.1r11_clean.pdf.pdf  (page.496)
@interface SigProvisioningRecordResponsePdu : SigProvisioningPdu
/// Indicates whether or not the request was handled successfully (see Table 5.45).
@property (nonatomic, assign) SigProvisioningRecordResponseStatus status;
/// Identifies the provisioning record whose data fragment is sent in the response (see Section 5.4.2.6).
@property (nonatomic, assign) UInt16 recordID;
/// The starting offset of the data fragment in the provisioning record data.
@property (nonatomic, assign) UInt16 fragmentOffset;
/// Total length of the provisioning record data stored on the device.
@property (nonatomic, assign) UInt16 totalLength;
/// Provisioning record data fragment (Optional).
@property (nonatomic, strong) NSData *data;

- (instancetype)initWithParameters:(NSData *)parameters;

@end


/// 5.4.1.13 Provisioning Records Get
/// - seeAlso: MshPRFd1.1r11_clean.pdf (page.497)
/// The Provisioner sends a Provisioning Records Get PDU to request the list of IDs of the provisioning records that are stored on a device.
@interface SigProvisioningRecordsGetPdu : SigProvisioningPdu

- (instancetype)init;

@end


/// 5.4.1.14 Provisioning Records List
/// - seeAlso: MshPRFd1.1r11_clean.pdf.pdf  (page.497)
@interface SigProvisioningRecordsListPdu : SigProvisioningPdu
/// Bitmask indicating the provisioning extensions supported by the device (see Table 5.47).
@property (nonatomic, assign) UInt16 provisioningExtensions;
/// Lists the Record IDs of the provisioning records stored on the device (see Section 5.4.2.6). (Optional).
@property (nonatomic, strong) NSArray <NSNumber *>*recordsList;

- (instancetype)initWithParameters:(NSData *)parameters;

@end


/// 3.4.4 Network PDU
/// - seeAlso: Mesh_v1.0.pdf (page.43)
@interface SigNetworkPdu : SigPdu
/// The Network Key used to decode/encode the PDU.
@property (nonatomic,strong) SigNetkeyModel *networkKey;

/// Least significant bit of IV Index.
@property (nonatomic,assign) UInt8 ivi;

/// Value derived from the NetKey used to identify the Encryption Key and Privacy Key used to secure this PDU.
@property (nonatomic,assign) UInt8 nid;

/// PDU type.
@property (nonatomic,assign) SigLowerTransportPduType type;

/// Time To Live.
@property (nonatomic,assign) UInt8 ttl;

/// Sequence Number.
@property (nonatomic,assign) UInt32 sequence;

/// Source Address.
@property (nonatomic,assign) UInt16 source;

/// Destination Address.
@property (nonatomic,assign) UInt16 destination;

/// Transport Protocol Data Unit. It is guaranteed to have 1 to 16 bytes.
@property (nonatomic,strong) NSData *transportPdu;

- (instancetype)initWithDecodePduData:(NSData *)pdu pduType:(SigPduType)pduType usingNetworkKey:(SigNetkeyModel *)networkKey ivIndex:(SigIvIndex *)ivIndex;

/// Creates Network PDU object from received PDU. The initiator tries to deobfuscate and decrypt the data using given Network Key and IV Index.
///
/// - parameter pdu:        The data received from mesh network.
/// - parameter pduType:    The type of the PDU: `.networkPdu` of `.proxyConfiguration`.
/// - parameter networkKey: The Network Key to decrypt the PDU.
/// - returns: The deobfuscated and decided Network PDU object, or `nil`, if the key or IV Index don't match.
- (instancetype)initWithDecodePduData:(NSData *)pdu pduType:(SigPduType)pduType usingNetworkKey:(SigNetkeyModel *)networkKey;

- (instancetype)initWithEncodeLowerTransportPdu:(SigLowerTransportPdu *)lowerTransportPdu pduType:(SigPduType)pduType withSequence:(UInt32)sequence andTtl:(UInt8)ttl ivIndex:(SigIvIndex *)ivIndex;

/// Creates the Network PDU. This method enctypts and obfuscates data that are to be send to the mesh network.
///
/// - parameter lowerTransportPdu: The data received from higher layer.
/// - parameter pduType:  The type of the PDU: `.networkPdu` of `.proxyConfiguration`.
/// - parameter sequence: The SEQ number of the PDU. Each PDU between the source and destination must have strictly increasing sequence number.
/// - parameter ttl: Time To Live.
/// - returns: The Network PDU object.
- (instancetype)initWithEncodeLowerTransportPdu:(SigLowerTransportPdu *)lowerTransportPdu pduType:(SigPduType)pduType withSequence:(UInt32)sequence andTtl:(UInt8)ttl;

+ (SigNetworkPdu *)decodePdu:(NSData *)pdu pduType:(SigPduType)pduType usingNetworkKey:(SigNetkeyModel *)networkKey ivIndex:(SigIvIndex *)ivIndex;

/// This method goes over all Network Keys in the mesh network and tries to deobfuscate and decode the network PDU.
///
/// - parameter pdu:         The received PDU.
/// - parameter type:        The type of the PDU: `.networkPdu` of `.proxyConfiguration`.
/// - parameter meshNetwork: The mesh network for which the PDU should be decoded.
/// - returns: The deobfuscated and decoded Network PDU, or `nil` if the PDU was not signed with any of the Network Keys, the IV Index was not valid, or the PDU was invalid.
+ (SigNetworkPdu *)decodePdu:(NSData *)pdu pduType:(SigPduType)pduType forMeshNetwork:(SigDataSource *)meshNetwork;

/// Whether the Network PDU contains a segmented Lower Transport PDU, or not.
- (BOOL)isSegmented;

/// The 24-bit Seq Auth used to transmit the first segment of a segmented message, or the 24-bit sequence number of an unsegmented
/// message.
- (UInt32)messageSequence;

- (UInt32)getDecodeIvIndex;

@end


@interface SigBeaconPdu : SigPdu

/// The beacon type.
@property (nonatomic,assign,readonly) SigBeaconType beaconType;

@end


/// 3.9.3 Secure Network beacon
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.120)
@interface SigSecureNetworkBeacon : SigBeaconPdu
/// The Network Key related to this Secure Network Beacon.
@property (nonatomic,strong) SigNetkeyModel *networkKey;
/// Key Refresh flag value.
///
/// When this flag is active, the Node shall set the Key Refresh Phase for this Network Key to `.finalizing`. When in this phase, the Node shall only transmit messages and Secure Network beacons using the new keys, shall receive messages using the old keys and the new keys, and shall only receive Secure Network beacons secured using the new Network Key.
@property (nonatomic,assign) BOOL keyRefreshFlag;
/// This flag is set to `true` if IV Update procedure is active.
@property (nonatomic,assign) BOOL ivUpdateActive;
/// Contains the value of the Network ID.
@property (nonatomic,strong) NSData *networkId;
/// Contains the current IV Index.
@property (nonatomic,assign) UInt32 ivIndex;

- (NSDictionary *)getDictionaryOfSecureNetworkBeacon;
- (void)setDictionaryToSecureNetworkBeacon:(NSDictionary *)dictionary;

/// Creates USecure Network beacon PDU object from received PDU.
///
/// - parameter pdu: The data received from mesh network.
/// - parameter networkKey: The Network Key to validate the beacon.
/// - returns: The beacon object, or `nil` if the data are invalid.
- (instancetype)initWithDecodePdu:(NSData *)pdu usingNetworkKey:(SigNetkeyModel *)networkKey;
+ (SigSecureNetworkBeacon *)decodePdu:(NSData *)pdu forMeshNetwork:(SigDataSource *)meshNetwork;
- (instancetype)initWithKeyRefreshFlag:(BOOL)keyRefreshFlag ivUpdateActive:(BOOL)ivUpdateActive networkId:(NSData *)networkId ivIndex:(UInt32)ivIndex usingNetworkKey:(SigNetkeyModel *)networkKey;

@end


@interface SigUnprovisionedDeviceBeacon : SigBeaconPdu

/// Device UUID uniquely identifying this device.
@property (nonatomic,strong) NSString *deviceUuid;
/// The OOB Information field is used to help drive the provisioning process by indicating the availability of OOB data, such as a public key of the device.
@property (nonatomic,assign) struct OobInformation oob;
/// Hash of the associated URI advertised with the URI AD Type.
@property (nonatomic,strong) NSData *uriHash;

/// Creates Unprovisioned Device beacon PDU object from received PDU.
///
/// - parameter pdu: The data received from mesh network.
/// - returns: The beacon object, or `nil` if the data are invalid.
- (instancetype)initWithDecodePdu:(NSData *)pdu;

/// This method goes over all Network Keys in the mesh network and tries to parse the beacon.
///
/// - parameter pdu:         The received PDU.
/// - parameter meshNetwork: The mesh network for which the PDU should be decoded.
/// - returns: The beacon object.
+ (SigUnprovisionedDeviceBeacon *)decodeWithPdu:(NSData *)pdu forMeshNetwork:(SigDataSource *)meshNetwork;

@end


/// 3.10.4 Mesh Private beacon
/// - seeAlso: MshPRFd1.1r15_clean.pdf  (page.209)
@interface SigMeshPrivateBeacon : SigBeaconPdu
/// The Network Key related to this Mesh Private beacon.
@property (nonatomic,strong) SigNetkeyModel *networkKey;
@property (nonatomic,strong) NSData *netKeyData;
/// Key Refresh flag value.
///
/// When this flag is active, the Node shall set the Key Refresh Phase for this Network Key to `.finalizing`. When in this phase, the Node shall only transmit messages and Secure Network beacons using the new keys, shall receive messages using the old keys and the new keys, and shall only receive Secure Network beacons secured using the new Network Key.
@property (nonatomic,assign) BOOL keyRefreshFlag;
/// This flag is set to `true` if IV Update procedure is active.
@property (nonatomic,assign) BOOL ivUpdateActive;
/// Contains the current IV Index.
@property (nonatomic,assign) UInt32 ivIndex;
/// Random number used as an entropy for obfuscation and authentication of the Mesh Private beacon. The size is 13 bytes.
@property (nonatomic,strong) NSData *randomData;
/// Obfuscated Private Beacon Data. The size is 5 bytes.
@property (nonatomic,strong) NSData *obfuscatedPrivateBeaconData;
/// Authentication tag for the beacon. The size is 8 bytes.
@property (nonatomic,strong) NSData *authenticationTag;

/// Creates Mesh Private beacon PDU object from received PDU.
///
/// - parameter pdu: The data received from mesh network.
/// - parameter networkKey: The Network Key to validate the beacon.
/// - returns: The beacon object, or `nil` if the data are invalid.
- (instancetype)initWithDecodePdu:(NSData *)pdu usingNetworkKey:(SigNetkeyModel *)networkKey;
+ (SigMeshPrivateBeacon *)decodePdu:(NSData *)pdu forMeshNetwork:(SigDataSource *)meshNetwork;
- (instancetype)initWithKeyRefreshFlag:(BOOL)keyRefreshFlag ivUpdateActive:(BOOL)ivUpdateActive ivIndex:(UInt32)ivIndex randomData:(NSData *)randomData usingNetworkKey:(SigNetkeyModel *)networkKey;

@end


@interface PublicKey : NSObject
@property (nonatomic, strong) NSData *PublicKeyData;
@property (nonatomic, assign) PublicKeyType publicKeyType;
- (instancetype)initWithPublicKeyType:(PublicKeyType)type;
@end


//@interface SigProvisioningResponse : NSObject
//@property (nonatomic, strong) NSData *responseData;
//@property (nonatomic, assign) SigProvisioningPduType type;
////@property (nonatomic, assign) struct ProvisioningCapabilities capabilities;
//@property (nonatomic, strong, nullable) SigProvisioningCapabilitiesPdu *capabilities;
//@property (nonatomic, strong) NSData *publicKey;
//@property (nonatomic, strong) NSData *confirmation;
//@property (nonatomic, strong) NSData *random;
//@property (nonatomic, strong) SigProvisioningRecordsListModel *recordListModel;
//@property (nonatomic, strong) SigProvisioningRecordResponseModel *recordResponseModel;
//@property (nonatomic, assign) RemoteProvisioningError error;
//- (instancetype)initWithData:(NSData *)data;
//- (BOOL)isValid;
//@end

NS_ASSUME_NONNULL_END
