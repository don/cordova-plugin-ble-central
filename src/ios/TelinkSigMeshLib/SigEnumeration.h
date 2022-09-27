/********************************************************************************************************
 * @file     SigStruct.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/9/6
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

#ifndef SigEnumeration_h
#define SigEnumeration_h

/// Table 3.43: Opcode formats
/// - seeAlso: Mesh_v1.0.pdf  (page.93)
typedef enum : UInt8 {
    SigOpCodeType_sig1 = 1,//1-octet Opcodes,Opcode Format:0xxxxxxx (excluding 01111111)
    SigOpCodeType_sig2 = 2,//2-octet Opcodes,Opcode Format:10xxxxxx xxxxxxxx
    SigOpCodeType_vendor3 = 3,//3-octet Opcodes,Opcode Format:11xxxxxx zzzzzzzz
    SigOpCodeType_RFU = 0b01111111,
} SigOpCodeType;

/// Table 5.14: Provisioning PDU types.
/// - seeAlso: Mesh_v1.0.pdf  (page.238)
/// Table 5.18: Provisioning PDU types.
/// - seeAlso: MshPRFd1.1r11_clean.pdf  (page.488)
typedef enum : UInt8 {
    /// Invites a device to join a mesh network
    SigProvisioningPduType_invite         = 0x00,
    /// Indicates the capabilities of the device
    SigProvisioningPduType_capabilities   = 0x01,
    /// Indicates the provisioning method selected by the Provisioner based on the capabilities of the device
    SigProvisioningPduType_start          = 0x02,
    /// Contains the Public Key of the device or the Provisioner
    SigProvisioningPduType_publicKey      = 0x03,
    /// Indicates that the user has completed inputting a value
    SigProvisioningPduType_inputComplete  = 0x04,
    /// Contains the provisioning confirmation value of the device or the Provisioner
    SigProvisioningPduType_confirmation   = 0x05,
    /// Contains the provisioning random value of the device or the Provisioner
    SigProvisioningPduType_random         = 0x06,
    /// Includes the assigned unicast address of the primary element, a network key, NetKey Index, Flags and the IV Index
    SigProvisioningPduType_data           = 0x07,
    /// Indicates that provisioning is complete
    SigProvisioningPduType_complete       = 0x08,
    /// Indicates that provisioning was unsuccessful
    SigProvisioningPduType_failed         = 0x09,
    /// Indicates a request to retrieve a provisioning record fragment from the device
    SigProvisioningPduType_recordRequest  = 0x0A,
    /// Contains a provisioning record fragment or an error status, sent in response to a Provisioning Record Request
    SigProvisioningPduType_recordResponse = 0x0B,
    /// Indicates a request to retrieve the list of IDs of the provisioning records that the unprovisioned device supports.
    SigProvisioningPduType_recordsGet     = 0x0C,
    /// Contains the list of IDs of the provisioning records that the unprovisioned device supports.
    SigProvisioningPduType_recordsList    = 0x0D,
    /// RFU, Reserved for Future Use, 0x0E–0xFF.
} SigProvisioningPduType;

typedef enum : UInt16 {
    MeshAddress_unassignedAddress = 0x0000,
    MeshAddress_minUnicastAddress = 0x0001,
    MeshAddress_maxUnicastAddress = 0x7FFF,
    MeshAddress_minVirtualAddress = 0x8000,
    MeshAddress_maxVirtualAddress = 0xBFFF,
    MeshAddress_minGroupAddress   = 0xC000,
    MeshAddress_maxGroupAddress   = 0xFEFF,
    MeshAddress_allProxies        = 0xFFFC,
    MeshAddress_allFriends        = 0xFFFD,
    MeshAddress_allRelays         = 0xFFFE,
    MeshAddress_allNodes          = 0xFFFF,
} MeshAddress;

typedef enum : UInt8 {
    DeviceStateOn,
    DeviceStateOff,
    DeviceStateOutOfLine,
} DeviceState;//设备状态

typedef enum : NSUInteger {
    OOBSourceTypeManualInput,
    OOBSourceTypeImportFromFile,
} OOBSourceType;

/// Table 6.2: SAR field values.
/// - seeAlso: Mesh_v1.0.pdf  (page.261)
typedef enum : UInt8 {
    /// Data field contains a complete message
    SAR_completeMessage  = 0b00,
    /// Data field contains the first segment of a message
    SAR_firstSegment     = 0b01,
    /// Data field contains a continuation segment of a message
    SAR_continuation     = 0b10,
    /// Data field contains the last segment of a message
    SAR_lastSegment      = 0b11,
} SAR;

/// Table 5.12: Action field values.
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.141)
typedef enum : UInt8 {
    SchedulerTypeOff      = 0x0,
    SchedulerTypeOn       = 0x1,
    SchedulerTypeScene    = 0x2,
    SchedulerTypeNoAction = 0xF,
} SchedulerType;//闹钟类型

typedef enum : UInt8 {
    AddDeviceModelStateProvisionFail,
    AddDeviceModelStateBinding,
    AddDeviceModelStateBindSuccess,
    AddDeviceModelStateBindFail,
    AddDeviceModelStateScanned,
    AddDeviceModelStateProvisioning,
} AddDeviceModelState;//添加的设备的状态

/// Table 5.18: Algorithms field values.
/// - seeAlso: Mesh_v1.0.pdf  (page.239)
typedef enum : UInt8 {
    /// FIPS P-256 Elliptic Curve algorithm will be used to calculate the shared secret.
    Algorithm_fipsP256EllipticCurve = 0,
    /// BTM_ECDH_P256_HMAC_SHA256_AES_CCM
    Algorithm_fipsP256EllipticCurve_HMAC_SHA256 = 1,
    /// Reserved for Future Use: 2~15
} Algorithm;

/// Table 5.19: Public Key Type field values
/// - seeAlso: Mesh_v1.0.pdf  (page.239)
typedef enum : UInt8 {
    /// No OOB Public Key is used.
    PublicKeyType_noOobPublicKey = 0,
    /// OOB Public Key is used. The key must contain the full value of the Public Key, depending on the chosen algorithm.
    PublicKeyType_oobPublicKey   = 1,
    /// 0x02–0xFF, Prohibited.
} PublicKeyType;

/// The authentication method chosen for provisioning.
/// Table 5.28: Authentication Method field values
/// - seeAlso: Mesh_v1.0.pdf  (page.241)
typedef enum : UInt8 {
    /// No OOB authentication is used.
    AuthenticationMethod_noOob     = 0,
    /// Static OOB authentication is used.
    AuthenticationMethod_staticOob = 1,
    /// Output OOB authentication is used. Size must be in range 1...8.
    AuthenticationMethod_outputOob = 2,
    /// Input OOB authentication is used. Size must be in range 1...8.
    AuthenticationMethod_inputOob  = 3,
    /// Prohibited, 0x04–0xFF.
} AuthenticationMethod;

/// The output action will be displayed on the device. For example, the device may use its LED to blink number of times. The number of blinks will then have to be entered to the Provisioner Manager.
/// Table 5.22: Output OOB Action field values
/// - seeAlso: Mesh_v1.0.pdf  (page.240)
typedef enum : UInt8 {
    OutputAction_blink              = 0,
    OutputAction_beep               = 1,
    OutputAction_vibrate            = 2,
    OutputAction_outputNumeric      = 3,
    OutputAction_outputAlphanumeric = 4
    /// Reserved for Future Use, 5–15.
} OutputAction;

/// The user will have to enter the input action on the device. For example, if the device supports `.push`, user will be asked to press a button on the device required number of times.
/// Table 5.24: Input OOB Action field values
/// - seeAlso: Mesh_v1.0.pdf  (page.240)
typedef enum : UInt8 {
    InputAction_push              = 0,
    InputAction_twist             = 1,
    InputAction_inputNumeric      = 2,
    InputAction_inputAlphanumeric = 3,
    /// Reserved for Future Use, 4–15.
} InputAction;

/// Table 3.52: Beacon Type values
/// - seeAlso: Mesh_v1.0.pdf  (page.118)
typedef enum : UInt8 {
    SigBeaconType_unprovisionedDevice = 0,
    SigBeaconType_secureNetwork       = 1,
    /// - seeAlso: MshPRFd1.1r15_clean.pdf  (page.209)
    SigBeaconType_meshPrivateBeacon   = 2,
    /// Reserved for Future Use, 0x03–0xFF.
} SigBeaconType;

typedef enum      : UInt8 {
    /// - seeAlso : 3.4.4 Network PDU of Mesh_v1.0.pdf  (page.43)
    SigPduType_networkPdu         = 0,
    /// - seeAlso : 3.9 Mesh beacons of Mesh_v1.0.pdf  (page.117)
    SigPduType_meshBeacon         = 1,
    /// - seeAlso : 6.5 Proxy configuration messages of Mesh_v1.0.pdf  (page.262)
    SigPduType_proxyConfiguration = 2,
    /// - seeAlso : 5.4.1 Provisioning PDUs of Mesh_v1.0.pdf  (page.237)
    SigPduType_provisioningPdu    = 3,
} SigPduType;

/// Table 5.20: Static OOB Type field values
/// - seeAlso: Mesh_v1.0.pdf  (page.239)
typedef enum : UInt8 {
    ProvisionType_NoOOB,//普通添加模式
    ProvisionType_StaticOOB,//云端校验添加模式（阿里的天猫精灵设备、小米的小爱同学设备）
    ProvisionType_Reserved,//预留
} ProvisionType;

typedef enum : UInt8 {
    KeyBindType_Normal,//普通添加模式
    KeyBindType_Fast,//快速添加模式
    KeyBindType_Reserved,//预留
} KeyBindType;

/// The Step Resolution field enumerates the resolution of the Number of Steps field and the values are defined in Table 4.6.
/// - seeAlso: Mesh_v1.0.pdf  (page.137)
typedef enum : UInt8 {
    SigStepResolution_hundredsOfMilliseconds = 0b00,
    SigStepResolution_seconds                = 0b01,
    SigStepResolution_tensOfSeconds          = 0b10,
    SigStepResolution_tensOfMinutes          = 0b11,
} SigStepResolution;

/// The status of a Config operation.Table 4.108: Summary of status codes.
/// - seeAlso: Mesh_v1.0.pdf  (page.194)
typedef enum : UInt8 {
    SigConfigMessageStatus_success                        = 0x00,
    SigConfigMessageStatus_invalidAddress                 = 0x01,
    SigConfigMessageStatus_invalidModel                   = 0x02,
    SigConfigMessageStatus_invalidAppKeyIndex             = 0x03,
    SigConfigMessageStatus_invalidNetKeyIndex             = 0x04,
    SigConfigMessageStatus_insufficientResources          = 0x05,
    SigConfigMessageStatus_keyIndexAlreadyStored          = 0x06,
    SigConfigMessageStatus_invalidPublishParameters       = 0x07,
    SigConfigMessageStatus_notASubscribeModel             = 0x08,
    SigConfigMessageStatus_storageFailure                 = 0x09,
    SigConfigMessageStatus_featureNotSupported            = 0x0A,
    SigConfigMessageStatus_cannotUpdate                   = 0x0B,
    SigConfigMessageStatus_cannotRemove                   = 0x0C,
    SigConfigMessageStatus_cannotBind                     = 0x0D,
    SigConfigMessageStatus_temporarilyUnableToChangeState = 0x0E,
    SigConfigMessageStatus_cannotSet                      = 0x0F,
    SigConfigMessageStatus_unspecifiedError               = 0x10,
    SigConfigMessageStatus_invalidBinding                 = 0x11,
    /// 0x12-0xFF, RFU
} SigConfigMessageStatus;

typedef enum      : UInt32 {

    /// 4.3.4 Messages summary
    /// - seeAlso : Mesh_v1.0.pdf  (page.188)

    SigOpCode_configAppKeyAdd                                = 0x00,
    SigOpCode_configAppKeyDelete                             = 0x8000,
    SigOpCode_configAppKeyGet                                = 0x8001,
    SigOpCode_configAppKeyList                               = 0x8002,
    SigOpCode_configAppKeyStatus                             = 0x8003,
    SigOpCode_configAppKeyUpdate                             = 0x01,

    SigOpCode_configBeaconGet                                = 0x8009,
    SigOpCode_configBeaconSet                                = 0x800A,
    SigOpCode_configBeaconStatus                             = 0x800B,

    SigOpCode_configCompositionDataGet                       = 0x8008,
    SigOpCode_configCompositionDataStatus                    = 0x02,

    SigOpCode_configDefaultTtlGet                            = 0x800C,
    SigOpCode_configDefaultTtlSet                            = 0x800D,
    SigOpCode_configDefaultTtlStatus                         = 0x800E,

    SigOpCode_configFriendGet                                = 0x800F,
    SigOpCode_configFriendSet                                = 0x8010,
    SigOpCode_configFriendStatus                             = 0x8011,

    SigOpCode_configGATTProxyGet                             = 0x8012,
    SigOpCode_configGATTProxySet                             = 0x8013,
    SigOpCode_configGATTProxyStatus                          = 0x8014,

    SigOpCode_configKeyRefreshPhaseGet                       = 0x8015,
    SigOpCode_configKeyRefreshPhaseSet                       = 0x8016,
    SigOpCode_configKeyRefreshPhaseStatus                    = 0x8017,

    SigOpCode_configModelPublicationGet                      = 0x8018,
    SigOpCode_configModelPublicationSet                      = 0x03,
    SigOpCode_configModelPublicationStatus                   = 0x8019,
    SigOpCode_configModelPublicationVirtualAddressSet        = 0x801A,

    SigOpCode_configModelSubscriptionAdd                     = 0x801B,
    SigOpCode_configModelSubscriptionDelete                  = 0x801C,
    SigOpCode_configModelSubscriptionDeleteAll               = 0x801D,
    SigOpCode_configModelSubscriptionOverwrite               = 0x801E,
    SigOpCode_configModelSubscriptionStatus                  = 0x801F,
    SigOpCode_configModelSubscriptionVirtualAddressAdd       = 0x8020,
    SigOpCode_configModelSubscriptionVirtualAddressDelete    = 0x8021,
    SigOpCode_configModelSubscriptionVirtualAddressOverwrite = 0x8022,

    SigOpCode_configNetworkTransmitGet                       = 0x8023,
    SigOpCode_configNetworkTransmitSet                       = 0x8024,
    SigOpCode_configNetworkTransmitStatus                    = 0x8025,

    SigOpCode_configRelayGet                                 = 0x8026,
    SigOpCode_configRelaySet                                 = 0x8027,
    SigOpCode_configRelayStatus                              = 0x8028,

    SigOpCode_configSIGModelSubscriptionGet                  = 0x8029,
    SigOpCode_configSIGModelSubscriptionList                 = 0x802A,
    SigOpCode_configVendorModelSubscriptionGet               = 0x802B,
    SigOpCode_configVendorModelSubscriptionList              = 0x802C,

    SigOpCode_configLowPowerNodePollTimeoutGet               = 0x802D,
    SigOpCode_configLowPowerNodePollTimeoutStatus            = 0x802E,

    SigOpCode_configHeartbeatPublicationGet                  = 0x8038,
    SigOpCode_configHeartbeatPublicationSet                  = 0x8039,
    SigOpCode_configHeartbeatPublicationStatus               = 0x06,
    SigOpCode_configHeartbeatSubscriptionGet                 = 0x803A,
    SigOpCode_configHeartbeatSubscriptionSet                 = 0x803B,
    SigOpCode_configHeartbeatSubscriptionStatus              = 0x803C,
    
    SigOpCode_configModelAppBind                             = 0x803D,
    SigOpCode_configModelAppStatus                           = 0x803E,
    SigOpCode_configModelAppUnbind                           = 0x803F,

    SigOpCode_configNetKeyAdd                                = 0x8040,
    SigOpCode_configNetKeyDelete                             = 0x8041,
    SigOpCode_configNetKeyGet                                = 0x8042,
    SigOpCode_configNetKeyList                               = 0x8043,
    SigOpCode_configNetKeyStatus                             = 0x8044,
    SigOpCode_configNetKeyUpdate                             = 0x8045,

    SigOpCode_configNodeIdentityGet                          = 0x8046,
    SigOpCode_configNodeIdentitySet                          = 0x8047,
    SigOpCode_configNodeIdentityStatus                       = 0x8048,

    SigOpCode_configNodeReset                                = 0x8049,
    SigOpCode_configNodeResetStatus                          = 0x804A,
    SigOpCode_configSIGModelAppGet                           = 0x804B,
    SigOpCode_configSIGModelAppList                          = 0x804C,
    SigOpCode_configVendorModelAppGet                        = 0x804D,
    SigOpCode_configVendorModelAppList                       = 0x804E,

    /// 4.3.5.2 Numerical summary of opcodes
    /// - seeAlso : MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.26)

    SigOpCode_remoteProvisioningScanCapabilitiesGet          = 0x804F,
    SigOpCode_remoteProvisioningScanCapabilitiesStatus       = 0x8050,
    SigOpCode_remoteProvisioningScanGet                      = 0x8051,
    SigOpCode_remoteProvisioningScanStart                    = 0x8052,
    SigOpCode_remoteProvisioningScanStop                     = 0x8053,
    SigOpCode_remoteProvisioningScanStatus                   = 0x8054,
    SigOpCode_remoteProvisioningScanReport                   = 0x8055,
    SigOpCode_remoteProvisioningExtendedScanStart            = 0x8056,
    SigOpCode_remoteProvisioningExtendedScanReport           = 0x8057,
    SigOpCode_remoteProvisioningLinkGet                      = 0x8058,
    SigOpCode_remoteProvisioningLinkOpen                     = 0x8059,
    SigOpCode_remoteProvisioningLinkClose                    = 0x805A,
    SigOpCode_remoteProvisioningLinkStatus                   = 0x805B,
    SigOpCode_remoteProvisioningLinkReport                   = 0x805C,
    SigOpCode_remoteProvisioningPDUSend                      = 0x805D,
    SigOpCode_remoteProvisioningPDUOutboundReport            = 0x805E,
    SigOpCode_remoteProvisioningPDUReport                    = 0x805F,

    /// 7.1 Messages summary
    /// - seeAlso : Mesh_Model_Specification v1.0.pdf  (page.298)

    //Generic OnOff
    SigOpCode_genericOnOffGet                                = 0x8201,
    SigOpCode_genericOnOffSet                                = 0x8202,
    SigOpCode_genericOnOffSetUnacknowledged                  = 0x8203,
    SigOpCode_genericOnOffStatus                             = 0x8204,

    //Generic Level
    SigOpCode_genericLevelGet                                = 0x8205,
    SigOpCode_genericLevelSet                                = 0x8206,
    SigOpCode_genericLevelSetUnacknowledged                  = 0x8207,
    SigOpCode_genericLevelStatus                             = 0x8208,
    SigOpCode_genericDeltaSet                                = 0x8209,
    SigOpCode_genericDeltaSetUnacknowledged                  = 0x820A,
    SigOpCode_genericMoveSet                                 = 0x820B,
    SigOpCode_genericMoveSetUnacknowledged                   = 0x820C,

    //Generic Default Transition Time
    SigOpCode_genericDefaultTransitionTimeGet                = 0x820D,
    SigOpCode_genericDefaultTransitionTimeSet                = 0x820E,
    SigOpCode_genericDefaultTransitionTimeSetUnacknowledged  = 0x820F,
    SigOpCode_genericDefaultTransitionTimeStatus             = 0x8210,

    //Generic Power OnOff
    SigOpCode_genericOnPowerUpGet                            = 0x8211,
    SigOpCode_genericOnPowerUpStatus                         = 0x8212,
    //Generic Power OnOff Setup
    SigOpCode_genericOnPowerUpSet                            = 0x8213,
    SigOpCode_genericOnPowerUpSetUnacknowledged              = 0x8214,

    //Generic Power Level
    SigOpCode_genericPowerLevelGet                           = 0x8215,
    SigOpCode_genericPowerLevelSet                           = 0x8216,
    SigOpCode_genericPowerLevelSetUnacknowledged             = 0x8217,
    SigOpCode_genericPowerLevelStatus                        = 0x8218,
    SigOpCode_genericPowerLastGet                            = 0x8219,
    SigOpCode_genericPowerLastStatus                         = 0x821A,
    SigOpCode_genericPowerDefaultGet                         = 0x821B,
    SigOpCode_genericPowerDefaultStatus                      = 0x821C,
    SigOpCode_genericPowerRangeGet                           = 0x821D,
    SigOpCode_genericPowerRangeStatus                        = 0x821E,
    //Generic Power Level Setup
    SigOpCode_genericPowerDefaultSet                         = 0x821F,
    SigOpCode_genericPowerDefaultSetUnacknowledged           = 0x8220,
    SigOpCode_genericPowerRangeSet                           = 0x8221,
    SigOpCode_genericPowerRangeSetUnacknowledged             = 0x8222,

    //Generic Battery
    SigOpCode_genericBatteryGet                              = 0x8223,
    SigOpCode_genericBatteryStatus                           = 0x8224,

    //Sensor
    SigOpCode_sensorDescriptorGet                            = 0x8230,
    SigOpCode_sensorDescriptorStatus                         = 0x51,
    SigOpCode_sensorGet                                      = 0x8231,
    SigOpCode_sensorStatus                                   = 0x52,
    SigOpCode_sensorColumnGet                                = 0x8232,
    SigOpCode_sensorColumnStatus                             = 0x53,
    SigOpCode_sensorSeriesGet                                = 0x8233,
    SigOpCode_sensorSeriesStatus                             = 0x54,
    //Sensor Setup
    SigOpCode_sensorCadenceGet                               = 0x8234,
    SigOpCode_sensorCadenceSet                               = 0x55,
    SigOpCode_sensorCadenceSetUnacknowledged                 = 0x56,
    SigOpCode_sensorCadenceStatus                            = 0x57,
    SigOpCode_sensorSettingsGet                              = 0x8235,
    SigOpCode_sensorSettingsStatus                           = 0x58,
    SigOpCode_sensorSettingGet                               = 0x8236,
    SigOpCode_sensorSettingSet                               = 0x59,
    SigOpCode_sensorSettingSetUnacknowledged                 = 0x5A,
    SigOpCode_sensorSettingStatus                            = 0x5B,

    //Time
    SigOpCode_timeGet                                        = 0x8237,
    SigOpCode_timeSet                                        = 0x5C,
    SigOpCode_timeStatus                                     = 0x5D,
    SigOpCode_timeRoleGet                                    = 0x8238,
    SigOpCode_timeRoleSet                                    = 0x8239,
    SigOpCode_timeRoleStatus                                 = 0x823A,
    SigOpCode_timeZoneGet                                    = 0x823B,
    SigOpCode_timeZoneSet                                    = 0x823C,
    SigOpCode_timeZoneStatus                                 = 0x823D,
    SigOpCode_TAI_UTC_DeltaGet                               = 0x823E,
    SigOpCode_TAI_UTC_DeltaSet                               = 0x823F,
    SigOpCode_TAI_UTC_DeltaStatus                            = 0x8240,

    //Scene
    SigOpCode_sceneGet                                       = 0x8241,
    SigOpCode_sceneRecall                                    = 0x8242,
    SigOpCode_sceneRecallUnacknowledged                      = 0x8243,
    SigOpCode_sceneStatus                                    = 0x5E,
    SigOpCode_sceneRegisterGet                               = 0x8244,
    SigOpCode_sceneRegisterStatus                            = 0x8245,
    //Scene Setup
    SigOpCode_sceneStore                                     = 0x8246,
    SigOpCode_sceneStoreUnacknowledged                       = 0x8247,
    SigOpCode_sceneDelete                                    = 0x829E,
    SigOpCode_sceneDeleteUnacknowledged                      = 0x829F,

    //Scheduler
    SigOpCode_schedulerActionGet                             = 0x8248,
    SigOpCode_schedulerActionStatus                          = 0x5F,
    SigOpCode_schedulerGet                                   = 0x8249,
    SigOpCode_schedulerStatus                                = 0x824A,
    //Scheduler Setup
    SigOpCode_schedulerActionSet                             = 0x60,
    SigOpCode_schedulerActionSetUnacknowledged               = 0x61,

    //Light Lightness
    SigOpCode_lightLightnessGet                              = 0x824B,
    SigOpCode_lightLightnessSet                              = 0x824C,
    SigOpCode_lightLightnessSetUnacknowledged                = 0x824D,
    SigOpCode_lightLightnessStatus                           = 0x824E,
    SigOpCode_lightLightnessLinearGet                        = 0x824F,
    SigOpCode_lightLightnessLinearSet                        = 0x8250,
    SigOpCode_lightLightnessLinearSetUnacknowledged          = 0x8251,
    SigOpCode_lightLightnessLinearStatus                     = 0x8252,
    SigOpCode_lightLightnessLastGet                          = 0x8253,
    SigOpCode_lightLightnessLastStatus                       = 0x8254,
    SigOpCode_lightLightnessDefaultGet                       = 0x8255,
    SigOpCode_lightLightnessDefaultStatus                    = 0x8256,
    SigOpCode_lightLightnessRangeGet                         = 0x8257,
    SigOpCode_lightLightnessRangeStatus                      = 0x8258,
    //Light Lightness Setup
    SigOpCode_lightLightnessDefaultSet                       = 0x8259,
    SigOpCode_lightLightnessDefaultSetUnacknowledged         = 0x825A,
    SigOpCode_lightLightnessRangeSet                         = 0x825B,
    SigOpCode_lightLightnessRangeSetUnacknowledged           = 0x825C,

    //Light CTL
    SigOpCode_lightCTLGet                                    = 0x825D,
    SigOpCode_lightCTLSet                                    = 0x825E,
    SigOpCode_lightCTLSetUnacknowledged                      = 0x825F,
    SigOpCode_lightCTLStatus                                 = 0x8260,
    SigOpCode_lightCTLTemperatureGet                         = 0x8261,
    SigOpCode_lightCTLTemperatureRangeGet                    = 0x8262,
    SigOpCode_lightCTLTemperatureRangeStatus                 = 0x8263,
    SigOpCode_lightCTLTemperatureSet                         = 0x8264,
    SigOpCode_lightCTLTemperatureSetUnacknowledged           = 0x8265,
    SigOpCode_lightCTLTemperatureStatus                      = 0x8266,
    SigOpCode_lightCTLDefaultGet                             = 0x8267,
    SigOpCode_lightCTLDefaultStatus                          = 0x8268,
    //Light CTL Setup
    SigOpCode_lightCTLDefaultSet                             = 0x8269,
    SigOpCode_lightCTLDefaultSetUnacknowledged               = 0x826A,
    SigOpCode_lightCTLTemperatureRangeSet                    = 0x826B,
    SigOpCode_lightCTLTemperatureRangeSetUnacknowledged      = 0x826C,

    //Light HSL
    SigOpCode_lightHSLGet                                    = 0x826D,
    SigOpCode_lightHSLHueGet                                 = 0x826E,
    SigOpCode_lightHSLHueSet                                 = 0x826F,
    SigOpCode_lightHSLHueSetUnacknowledged                   = 0x8270,
    SigOpCode_lightHSLHueStatus                              = 0x8271,
    SigOpCode_lightHSLSaturationGet                          = 0x8272,
    SigOpCode_lightHSLSaturationSet                          = 0x8273,
    SigOpCode_lightHSLSaturationSetUnacknowledged            = 0x8274,
    SigOpCode_lightHSLSaturationStatus                       = 0x8275,
    SigOpCode_lightHSLSet                                    = 0x8276,
    SigOpCode_lightHSLSetUnacknowledged                      = 0x8277,
    SigOpCode_lightHSLStatus                                 = 0x8278,
    SigOpCode_lightHSLTargetGet                              = 0x8279,
    SigOpCode_lightHSLTargetStatus                           = 0x827A,
    SigOpCode_lightHSLDefaultGet                             = 0x827B,
    SigOpCode_lightHSLDefaultStatus                          = 0x827C,
    SigOpCode_lightHSLRangeGet                               = 0x827D,
    SigOpCode_lightHSLRangeStatus                            = 0x827E,
    //Light HSL Setup
    SigOpCode_lightHSLDefaultSet                             = 0x827F,
    SigOpCode_lightHSLDefaultSetUnacknowledged               = 0x8280,
    SigOpCode_lightHSLRangeSet                               = 0x8281,
    SigOpCode_lightHSLRangeSetUnacknowledged                 = 0x82,

    //Light xyL
    SigOpCode_lightXyLGet                                    = 0x8283,
    SigOpCode_lightXyLSet                                    = 0x8284,
    SigOpCode_lightXyLSetUnacknowledged                      = 0x8285,
    SigOpCode_lightXyLStatus                                 = 0x8286,
    SigOpCode_lightXyLTargetGet                              = 0x8287,
    SigOpCode_lightXyLTargetStatus                           = 0x8288,
    SigOpCode_lightXyLDefaultGet                             = 0x8289,
    SigOpCode_lightXyLDefaultStatus                          = 0x828A,
    SigOpCode_lightXyLRangeGet                               = 0x828B,
    SigOpCode_lightXyLRangeStatus                            = 0x828C,
    //Light xyL Setup
    SigOpCode_lightXyLDefaultSet                             = 0x828D,
    SigOpCode_lightXyLDefaultSetUnacknowledged               = 0x828E,
    SigOpCode_lightXyLRangeSet                               = 0x828F,
    SigOpCode_lightXyLRangeSetUnacknowledged                 = 0x8290,

    //Light Control
    SigOpCode_LightLCModeGet                                 = 0x8291,
    SigOpCode_LightLCModeSet                                 = 0x8292,
    SigOpCode_LightLCModeSetUnacknowledged                   = 0x8293,
    SigOpCode_LightLCModeStatus                              = 0x8294,
    SigOpCode_LightLCOMGet                                   = 0x8295,
    SigOpCode_LightLCOMSet                                   = 0x8296,
    SigOpCode_LightLCOMSetUnacknowledged                     = 0x8297,
    SigOpCode_LightLCOMStatus                                = 0x8298,
    SigOpCode_LightLCLightOnOffGet                           = 0x8299,
    SigOpCode_LightLCLightOnOffSet                           = 0x829A,
    SigOpCode_LightLCLightOnOffSetUnacknowledged             = 0x829B,
    SigOpCode_LightLCLightOnOffStatus                        = 0x829C,
    SigOpCode_LightLCPropertyGet                             = 0x829D,
    SigOpCode_LightLCPropertySet                             = 0x62,
    SigOpCode_LightLCPropertySetUnacknowledged               = 0x63,
    SigOpCode_LightLCPropertyStatus                          = 0x64,

    /// 3.1.1 Firmware Update Model Messages
    /// - seeAlso : pre-spec OTA model opcode details.pdf  (page.2)
    /// 8.4 Firmware update messages
    /// - seeAlso : MshMDL_DFU_MBT_CR_R04_LbL25.pdf  (page.80)

    //8.4.1 Firmware Update model messages
    SigOpCode_FirmwareUpdateInformationGet                   = 0xB601,
    SigOpCode_FirmwareUpdateInformationStatus                = 0xB602,
    SigOpCode_FirmwareUpdateFirmwareMetadataCheck            = 0xB603,
    SigOpCode_FirmwareUpdateFirmwareMetadataStatus           = 0xB604,
    SigOpCode_FirmwareUpdateGet                              = 0xB605,
    SigOpCode_FirmwareUpdateStart                            = 0xB606,
    SigOpCode_FirmwareUpdateCancel                           = 0xB607,
    SigOpCode_FirmwareUpdateApply                            = 0xB608,
    SigOpCode_FirmwareUpdateStatus                           = 0xB609,

    //8.4.2 Firmware Distribution model messages
    SigOpCode_FirmwareDistributionGet                        = 0xB60A,
    SigOpCode_FirmwareDistributionStart                      = 0xB60B,
    SigOpCode_FirmwareDistributionCancel                     = 0xB60C,
    SigOpCode_FirmwareDistributionApply                      = 0xB60D,
    SigOpCode_FirmwareDistributionStatus                     = 0xB60E,
    SigOpCode_FirmwareDistributionReceiversGet               = 0xB60F,
    SigOpCode_FirmwareDistributionReceiversList              = 0xB610,
    SigOpCode_FirmwareDistributionReceiversAdd               = 0xB611,
    SigOpCode_FirmwareDistributionReceiversDeleteAll         = 0xB612,
    SigOpCode_FirmwareDistributionReceiversStatus            = 0xB613,
    SigOpCode_FirmwareDistributionCapabilitiesGet            = 0xB614,
    SigOpCode_FirmwareDistributionCapabilitiesStatus         = 0xB615,
    SigOpCode_FirmwareDistributionUploadGet                  = 0xB616,
    SigOpCode_FirmwareDistributionUploadStart                = 0xB617,
    SigOpCode_FirmwareDistributionUploadOOBStart             = 0xB618,
    SigOpCode_FirmwareDistributionUploadCancel               = 0xB619,
    SigOpCode_FirmwareDistributionUploadStatus               = 0xB61A,
    SigOpCode_FirmwareDistributionFirmwareGet                = 0xB61B,
    SigOpCode_FirmwareDistributionFirmwareStatus             = 0xB61C,
    SigOpCode_FirmwareDistributionFirmwareGetByIndex         = 0xB61D,
    SigOpCode_FirmwareDistributionFirmwareDelete             = 0xB61E,
    SigOpCode_FirmwareDistributionFirmwareDeleteAll          = 0xB61F,

    /// 3.1.3.1 BLOB Transfer messages
    /// - seeAlso : MshMDL_BLOB_CR_Vienna_IOP.pdf  (page.35)

    //BLOB Transfer Messages
    SigOpCode_BLOBTransferGet                                = 0xB701,
    SigOpCode_BLOBTransferStart                              = 0xB702,
    SigOpCode_BLOBTransferCancel                             = 0xB703,
    SigOpCode_BLOBTransferStatus                             = 0xB704,
    SigOpCode_BLOBBlockStart                                 = 0xB705,
    SigOpCode_ObjectBlockTransferStatus                      = 0xB706,
    SigOpCode_BLOBBlockGet                                   = 0xB707,
    SigOpCode_BLOBInformationGet                             = 0xB70A,
    SigOpCode_BLOBInformationStatus                          = 0xB70B,
    SigOpCode_BLOBPartialBlockReport                         = 0x7C,
    SigOpCode_BLOBChunkTransfer                              = 0x7D,
    SigOpCode_BLOBBlockStatus                                = 0x7E,

    /// Private Beacons
    /// - seeAlso : message_opcode_sizes_R01.docx  (page.5)
    SigOpCode_PrivateBeaconGet                               = 0xB711,
    SigOpCode_PrivateBeaconSet                               = 0xB712,
    SigOpCode_PrivateBeaconStatus                            = 0xB713,
    SigOpCode_PrivateGattProxyGet                            = 0xB714,
    SigOpCode_PrivateGattProxySet                            = 0xB715,
    SigOpCode_PrivateGattProxyStatus                         = 0xB716,
    SigOpCode_PrivateNodeIdentityGet                         = 0xB718,
    SigOpCode_PrivateNodeIdentitySet                         = 0xB719,
    SigOpCode_PrivateNodeIdentityStatus                      = 0xB71A,

    /// - seeAlso : message_opcode_sizes_R01.docx  (page.5)
    /// Opcodes aggregator
    SigOpCode_OpcodesAggregatorSequence                      = 0xB809,
    SigOpCode_OpcodesAggregatorStatus                        = 0xB810,

    /// - seeAlso : MshPRF_SBR_CR_r03.pdf  (page.16)
    /// Subnet Bridge
    /// 4.3.4.1 Alphabetical summary of opcodes
    SigOpCode_BridgeCapabilityGet                            = 0xBF7A,
    SigOpCode_BridgeCapabilityStatus                         = 0xBF7B,
    SigOpCode_BridgeTableAdd                                 = 0xBF73,
    SigOpCode_BridgeTableGet                                 = 0xBF78,
    SigOpCode_BridgeTableList                                = 0xBF79,
    SigOpCode_BridgeTableRemove                              = 0xBF74,
    SigOpCode_BridgeTableStatus                              = 0xBF75,
    SigOpCode_BridgeSubnetsGet                               = 0xBF76,
    SigOpCode_BridgeSubnetsList                              = 0xBF77,
    SigOpCode_SubnetBridgeGet                                = 0xBF70,
    SigOpCode_SubnetBridgeSet                                = 0xBF71,
    SigOpCode_SubnetBridgeStatus                             = 0xBF72,

    /// - seeAlso : fast provision流程简介.pdf  (page.1)

    /// fast provision
    SigOpCode_VendorID_MeshResetNetwork                      = 0xC5,
    SigOpCode_VendorID_MeshAddressGet                        = 0xC6,
    SigOpCode_VendorID_MeshAddressGetStatus                  = 0xC7,
    SigOpCode_VendorID_MeshAddressSet                        = 0xC8,
    SigOpCode_VendorID_MeshAddressSetStatus                  = 0xC9,
    SigOpCode_VendorID_MeshProvisionDataSet                  = 0xCA,
    SigOpCode_VendorID_MeshProvisionConfirm                  = 0xCB,
    SigOpCode_VendorID_MeshProvisionConfirmStatus            = 0xCC,
    SigOpCode_VendorID_MeshProvisionComplete                 = 0xCD,

} SigOpCode;

typedef enum : UInt8 {
    /// The segmented message has not been acknowledged before the timeout occurred.
    SigLowerTransportError_timeout = 0,
    /// The target device is busy at the moment and could not accept the message.
    SigLowerTransportError_busy    = 1,
} SigLowerTransportError;

typedef enum : UInt8 {
    SigLowerTransportPduType_accessMessage  = 0,
    SigLowerTransportPduType_controlMessage = 1,
} SigLowerTransportPduType;

typedef enum : UInt8 {
    /// Provisioning Manager is ready to start.
    ProvisioningState_ready,
    /// The manager is requesting Provisioioning Capabilities from the device.
    ProvisioningState_requestingCapabilities,
    /// Provisioning Capabilities were received.
    ProvisioningState_capabilitiesReceived,
    /// Provisioning has been started.
    ProvisioningState_provisioning,
    /// The provisioning process is complete.
    ProvisioningState_complete,
    /// The provisioning has failed because of a local error.
    ProvisioningState_fail,
    /// The manager is requesting Provisioning Records Get.
    ProvisioningState_recordsGet,
    /// Provisioning Records List were received.
    ProvisioningState_recordsList,
    /// The manager is requesting Provisioning Record.
    ProvisioningState_recordRequest,
    /// Provisioning Record Response were received.
    ProvisioningState_recordResponse,
} ProvisioningState;

/// Table 5.38: Provisioning error codes.
/// - seeAlso: Mesh_v1.0.pdf  (page.244)
typedef enum : UInt8 {
    /// Prohibited.
    ProvisioningError_prohibited            = 0,
    /// The provisioning protocol PDU is not recognized by the device.
    ProvisioningError_invalidPdu            = 1,
    /// The arguments of the protocol PDUs are outside expected values or the length of the PDU is different than expected.
    ProvisioningError_invalidFormat         = 2,
    /// The PDU received was not expected at this moment of the procedure.
    ProvisioningError_unexpectedPDU         = 3,
    /// The computed confirmation value was not successfully verified.
    ProvisioningError_confirmationFailed    = 4,
    /// The provisioning protocol cannot be continued due to insufficient resources in the device.
    ProvisioningError_outOfResources        = 5,
    /// The Data block was not successfully decrypted.
    ProvisioningError_decryptionFailed      = 6,
    /// An unexpected error occurred that may not be recoverable.
    ProvisioningError_unexpectedError       = 7,
    /// The device cannot assign consecutive unicast addresses to all elements.
    ProvisioningError_cannotAssignAddresses = 8,
    /// RFU, Reserved for Future Use, 0x09–0xFF.
} ProvisioningError;

typedef enum : NSUInteger {
    /// The provisioning protocol PDU is not recognized by the device.
    RemoteProvisioningError_invalidPdu             = 1,
    /// The arguments of the protocol PDUs are outside expected values
    /// or the length of the PDU is different than expected.
    RemoteProvisioningError_invalidFormat          = 2,
    /// The PDU received was not expected at this moment of the procedure.
    RemoteProvisioningError_unexpectedPdu          = 3,
    /// The computed confirmation value was not successfully verified.
    RemoteProvisioningError_confirmationFailed     = 4,
    /// The provisioning protocol cannot be continued due to insufficient
    /// resources in the device.
    RemoteProvisioningError_outOfResources         = 5,
    /// The Data block was not successfully decrypted.
    RemoteProvisioningError_decryptionFailed       = 6,
    /// An unexpected error occurred that may not be recoverable.
    RemoteProvisioningError_unexpectedError        = 7,
    /// The device cannot assign consecutive unicast addresses to all elements.
    RemoteProvisioningError_cannotAssignAddresses = 8,
} RemoteProvisioningError;

typedef enum : NSUInteger {
    /// Message will be sent with 32-bit Transport MIC.
    SigMeshMessageSecurityLow,
    /// Message will be sent with 64-bit Transport MIC.
    /// Unsegmented messages cannot be sent with this option.
    SigMeshMessageSecurityHigh,
} SigMeshMessageSecurity;

/// Locations defined by Bluetooth SIG.
/// Imported from: https://www.bluetooth.com/specifications/assigned-numbers/gatt-namespace-descriptors
typedef enum : UInt16 {
    SigLocation_auxiliary                   = 0x0108,
    SigLocation_back                        = 0x0101,
    SigLocation_backup                      = 0x0107,
    SigLocation_bottom                      = 0x0103,
    SigLocation_eighteenth                  = 0x0012,
    SigLocation_eighth                      = 0x0008,
    SigLocation_eightieth                   = 0x0050,
    SigLocation_eightyEighth                = 0x0058,
    SigLocation_eightyFifth                 = 0x0055,
    SigLocation_eightyFirst                 = 0x0051,
    SigLocation_eightyFourth                = 0x0054,
    SigLocation_eightyNineth                = 0x0059,
    SigLocation_eightySecond                = 0x0052,
    SigLocation_eightySeventh               = 0x0057,
    SigLocation_eightySixth                 = 0x0056,
    SigLocation_eightyThird                 = 0x0053,
    SigLocation_eleventh                    = 0x000b,
    SigLocation_external                    = 0x0110,
    SigLocation_fifteenth                   = 0x000f,
    SigLocation_fifth                       = 0x0005,
    SigLocation_fiftieth                    = 0x0032,
    SigLocation_fiftyEighth                 = 0x003a,
    SigLocation_fiftyFifth                  = 0x0037,
    SigLocation_fiftyFirst                  = 0x0033,
    SigLocation_fiftyFourth                 = 0x0036,
    SigLocation_fiftyNineth                 = 0x003b,
    SigLocation_fiftySecond                 = 0x0034,
    SigLocation_fiftySeventh                = 0x0039,
    SigLocation_fiftySixth                  = 0x0038,
    SigLocation_fiftyThird                  = 0x0035,
    SigLocation_first                       = 0x0001,
    SigLocation_flash                       = 0x010A,
    SigLocation_fortieth                    = 0x0028,
    SigLocation_fourteenth                  = 0x000e,
    SigLocation_fourth                      = 0x0004,
    SigLocation_fourtyEighth                = 0x0030,
    SigLocation_fourtyFifth                 = 0x002d,
    SigLocation_fourtyFirst                 = 0x0029,
    SigLocation_fourtyFourth                = 0x002c,
    SigLocation_fourtyNineth                = 0x0031,
    SigLocation_fourtySecond                = 0x002a,
    SigLocation_fourtySeventh               = 0x002f,
    SigLocation_fourtySixth                 = 0x002e,
    SigLocation_fourtyThird                 = 0x002b,
    SigLocation_front                       = 0x0100,
    SigLocation_inside                      = 0x010B,
    SigLocation_internal                    = 0x010F,
    SigLocation_left                        = 0x010D,
    SigLocation_lower                       = 0x0105,
    SigLocation_main                        = 0x0106,
    SigLocation_nineteenth                  = 0x0013,
    SigLocation_nineth                      = 0x0009,
    SigLocation_ninetieth                   = 0x005a,
    SigLocation_ninetyEighth                = 0x0062,
    SigLocation_ninetyFifth                 = 0x005f,
    SigLocation_ninetyFirst                 = 0x005b,
    SigLocation_ninetyFourth                = 0x005e,
    SigLocation_ninetyNineth                = 0x0063,
    SigLocation_ninetySecond                = 0x005c,
    SigLocation_ninetySeventh               = 0x0061,
    SigLocation_ninetySixth                 = 0x0060,
    SigLocation_ninetyThird                 = 0x005d,
    SigLocation_oneHundredAndEighteenth     = 0x0076,
    SigLocation_oneHundredAndEighth         = 0x006c,
    SigLocation_oneHundredAndEightyEighth   = 0x00bc,
    SigLocation_oneHundredAndEightyFifth    = 0x00b9,
    SigLocation_oneHundredAndEightyFirst    = 0x00b5,
    SigLocation_oneHundredAndEightyFourth   = 0x00b8,
    SigLocation_oneHundredAndEightyNineth   = 0x00bd,
    SigLocation_oneHundredAndEightySecond   = 0x00b6,
    SigLocation_oneHundredAndEightySeventh  = 0x00bb,
    SigLocation_oneHundredAndEightySixth    = 0x00ba,
    SigLocation_oneHundredAndEightyThird    = 0x00b7,
    SigLocation_oneHundredAndEleventh       = 0x006f,
    SigLocation_oneHundredAndFifteenth      = 0x0073,
    SigLocation_oneHundredAndFifth          = 0x0069,
    SigLocation_oneHundredAndFiftyEighth    = 0x009e,
    SigLocation_oneHundredAndFiftyFifth     = 0x009b,
    SigLocation_oneHundredAndFiftyFirst     = 0x0097,
    SigLocation_oneHundredAndFiftyFourth    = 0x009a,
    SigLocation_oneHundredAndFiftyNineth    = 0x009f,
    SigLocation_oneHundredAndFiftySecond    = 0x0098,
    SigLocation_oneHundredAndFiftySeventh   = 0x009d,
    SigLocation_oneHundredAndFiftySixth     = 0x009c,
    SigLocation_oneHundredAndFiftyThird     = 0x0099,
    SigLocation_oneHundredAndFirst          = 0x0065,
    SigLocation_oneHundredAndFourteenth     = 0x0072,
    SigLocation_oneHundredAndFourth         = 0x0068,
    SigLocation_oneHundredAndFourtyEighth   = 0x0094,
    SigLocation_oneHundredAndFourtyFifth    = 0x0091,
    SigLocation_oneHundredAndFourtyFirst    = 0x008d,
    SigLocation_oneHundredAndFourtyFourth   = 0x0090,
    SigLocation_oneHundredAndFourtyNineth   = 0x0095,
    SigLocation_oneHundredAndFourtySecond   = 0x008e,
    SigLocation_oneHundredAndFourtySeventh  = 0x0093,
    SigLocation_oneHundredAndFourtySixth    = 0x0092,
    SigLocation_oneHundredAndFourtyThird    = 0x008f,
    SigLocation_oneHundredAndNineteenth     = 0x0077,
    SigLocation_oneHundredAndNineth         = 0x006d,
    SigLocation_oneHundredAndNinetyEighth   = 0x00c6,
    SigLocation_oneHundredAndNinetyFifth    = 0x00c3,
    SigLocation_oneHundredAndNinetyFirst    = 0x00bf,
    SigLocation_oneHundredAndNinetyFourth   = 0x00c2,
    SigLocation_oneHundredAndNinetyNineth   = 0x00c7,
    SigLocation_oneHundredAndNinetySecond   = 0x00c0,
    SigLocation_oneHundredAndNinetySeventh  = 0x00c5,
    SigLocation_oneHundredAndNinetySixth    = 0x00c4,
    SigLocation_oneHundredAndNinetyThird    = 0x00c1,
    SigLocation_oneHundredAndSecond         = 0x0066,
    SigLocation_oneHundredAndSeventeenth    = 0x0075,
    SigLocation_oneHundredAndSeventh        = 0x006b,
    SigLocation_oneHundredAndSeventyEighth  = 0x00b2,
    SigLocation_oneHundredAndSeventyFifth   = 0x00af,
    SigLocation_oneHundredAndSeventyFirst   = 0x00ab,
    SigLocation_oneHundredAndSeventyFourth  = 0x00ae,
    SigLocation_oneHundredAndSeventyNineth  = 0x00b3,
    SigLocation_oneHundredAndSeventySecond  = 0x00ac,
    SigLocation_oneHundredAndSeventySeventh = 0x00b1,
    SigLocation_oneHundredAndSeventySixth   = 0x00b0,
    SigLocation_oneHundredAndSeventyThird   = 0x00ad,
    SigLocation_oneHundredAndSixteenth      = 0x0074,
    SigLocation_oneHundredAndSixth          = 0x006a,
    SigLocation_oneHundredAndSixtyEighth    = 0x00a8,
    SigLocation_oneHundredAndSixtyFifth     = 0x00a5,
    SigLocation_oneHundredAndSixtyFirst     = 0x00a1,
    SigLocation_oneHundredAndSixtyFourth    = 0x00a4,
    SigLocation_oneHundredAndSixtyNineth    = 0x00a9,
    SigLocation_oneHundredAndSixtySecond    = 0x00a2,
    SigLocation_oneHundredAndSixtySeventh   = 0x00a7,
    SigLocation_oneHundredAndSixtySixth     = 0x00a6,
    SigLocation_oneHundredAndSixtyThird     = 0x00a3,
    SigLocation_oneHundredAndTenth          = 0x006e,
    SigLocation_oneHundredAndThird          = 0x0067,
    SigLocation_oneHundredAndThirteenth     = 0x0071,
    SigLocation_oneHundredAndThirtyEighth   = 0x008a,
    SigLocation_oneHundredAndThirtyFifth    = 0x0087,
    SigLocation_oneHundredAndThirtyFirst    = 0x0083,
    SigLocation_oneHundredAndThirtyFourth   = 0x0086,
    SigLocation_oneHundredAndThirtyNineth   = 0x008b,
    SigLocation_oneHundredAndThirtySecond   = 0x0084,
    SigLocation_oneHundredAndThirtySeventh  = 0x0089,
    SigLocation_oneHundredAndThirtySixth    = 0x0088,
    SigLocation_oneHundredAndThirtyThird    = 0x0085,
    SigLocation_oneHundredAndTwelveth       = 0x0070,
    SigLocation_oneHundredAndTwentyEighth   = 0x0080,
    SigLocation_oneHundredAndTwentyFifth    = 0x007d,
    SigLocation_oneHundredAndTwentyFirst    = 0x0079,
    SigLocation_oneHundredAndTwentyFourth   = 0x007c,
    SigLocation_oneHundredAndTwentyNineth   = 0x0081,
    SigLocation_oneHundredAndTwentySecond   = 0x007a,
    SigLocation_oneHundredAndTwentySeventh  = 0x007f,
    SigLocation_oneHundredAndTwentySixth    = 0x007e,
    SigLocation_oneHundredAndTwentyThird    = 0x007b,
    SigLocation_oneHundredEightieth         = 0x00b4,
    SigLocation_oneHundredFiftieth          = 0x0096,
    SigLocation_oneHundredFortieth          = 0x008c,
    SigLocation_oneHundredNinetieth         = 0x00be,
    SigLocation_oneHundredSeventieth        = 0x00aa,
    SigLocation_oneHundredSixtieth          = 0x00a0,
    SigLocation_oneHundredThirtieth         = 0x0082,
    SigLocation_oneHundredTwentieth         = 0x0078,
    SigLocation_oneHundredth                = 0x0064,
    SigLocation_outside                     = 0x010C,
    SigLocation_right                       = 0x010E,
    SigLocation_second                      = 0x0002,
    SigLocation_seventeenth                 = 0x0011,
    SigLocation_seventh                     = 0x0007,
    SigLocation_seventieth                  = 0x0046,
    SigLocation_seventyEighth               = 0x004e,
    SigLocation_seventyFifth                = 0x004b,
    SigLocation_seventyFirst                = 0x0047,
    SigLocation_seventyFourth               = 0x004a,
    SigLocation_seventyNineth               = 0x004f,
    SigLocation_seventySecond               = 0x0048,
    SigLocation_seventySeventh              = 0x004d,
    SigLocation_seventySixth                = 0x004c,
    SigLocation_seventyThird                = 0x0049,
    SigLocation_sixteenth                   = 0x0010,
    SigLocation_sixth                       = 0x0006,
    SigLocation_sixtieth                    = 0x003c,
    SigLocation_sixtyEighth                 = 0x0044,
    SigLocation_sixtyFifth                  = 0x0041,
    SigLocation_sixtyFirst                  = 0x003d,
    SigLocation_sixtyFourth                 = 0x0040,
    SigLocation_sixtyNineth                 = 0x0045,
    SigLocation_sixtySecond                 = 0x003e,
    SigLocation_sixtySeventh                = 0x0043,
    SigLocation_sixtySixth                  = 0x0042,
    SigLocation_sixtyThird                  = 0x003f,
    SigLocation_supplementary               = 0x0109,
    SigLocation_tenth                       = 0x000a,
    SigLocation_third                       = 0x0003,
    SigLocation_thirteenth                  = 0x000d,
    SigLocation_thirtieth                   = 0x001e,
    SigLocation_thirtyEighth                = 0x0026,
    SigLocation_thirtyFifth                 = 0x0023,
    SigLocation_thirtyFirst                 = 0x001f,
    SigLocation_thirtyFourth                = 0x0022,
    SigLocation_thirtyNineth                = 0x0027,
    SigLocation_thirtySecond                = 0x0020,
    SigLocation_thirtySeventh               = 0x0025,
    SigLocation_thirtySixth                 = 0x0024,
    SigLocation_thirtyThird                 = 0x0021,
    SigLocation_top                         = 0x0102,
    SigLocation_twelveth                    = 0x000c,
    SigLocation_twentieth                   = 0x0014,
    SigLocation_twentyEighth                = 0x001c,
    SigLocation_twentyFifth                 = 0x0019,
    SigLocation_twentyFirst                 = 0x0015,
    SigLocation_twentyFourth                = 0x0018,
    SigLocation_twentyNineth                = 0x001d,
    SigLocation_twentySecond                = 0x0016,
    SigLocation_twentySeventh               = 0x001b,
    SigLocation_twentySixth                 = 0x001a,
    SigLocation_twentyThird                 = 0x0017,
    SigLocation_twoHundredAndEighteenth     = 0x00da,
    SigLocation_twoHundredAndEighth         = 0x00d0,
    SigLocation_twoHundredAndEleventh       = 0x00d3,
    SigLocation_twoHundredAndFifteenth      = 0x00d7,
    SigLocation_twoHundredAndFifth          = 0x00cd,
    SigLocation_twoHundredAndFiftyFifth     = 0x00ff,
    SigLocation_twoHundredAndFiftyFirst     = 0x00fb,
    SigLocation_twoHundredAndFiftyFourth    = 0x00fe,
    SigLocation_twoHundredAndFiftySecond    = 0x00fc,
    SigLocation_twoHundredAndFiftyThird     = 0x00fd,
    SigLocation_twoHundredAndFirst          = 0x00c9,
    SigLocation_twoHundredAndFourteenth     = 0x00d6,
    SigLocation_twoHundredAndFourth         = 0x00cc,
    SigLocation_twoHundredAndFourtyEighth   = 0x00f8,
    SigLocation_twoHundredAndFourtyFifth    = 0x00f5,
    SigLocation_twoHundredAndFourtyFirst    = 0x00f1,
    SigLocation_twoHundredAndFourtyFourth   = 0x00f4,
    SigLocation_twoHundredAndFourtyNineth   = 0x00f9,
    SigLocation_twoHundredAndFourtySecond   = 0x00f2,
    SigLocation_twoHundredAndFourtySeventh  = 0x00f7,
    SigLocation_twoHundredAndFourtySixth    = 0x00f6,
    SigLocation_twoHundredAndFourtyThird    = 0x00f3,
    SigLocation_twoHundredAndNineteenth     = 0x00db,
    SigLocation_twoHundredAndNineth         = 0x00d1,
    SigLocation_twoHundredAndSecond         = 0x00ca,
    SigLocation_twoHundredAndSeventeenth    = 0x00d9,
    SigLocation_twoHundredAndSeventh        = 0x00cf,
    SigLocation_twoHundredAndSixteenth      = 0x00d8,
    SigLocation_twoHundredAndSixth          = 0x00ce,
    SigLocation_twoHundredAndTenth          = 0x00d2,
    SigLocation_twoHundredAndThird          = 0x00cb,
    SigLocation_twoHundredAndThirteenth     = 0x00d5,
    SigLocation_twoHundredAndThirtyEighth   = 0x00ee,
    SigLocation_twoHundredAndThirtyFifth    = 0x00eb,
    SigLocation_twoHundredAndThirtyFirst    = 0x00e7,
    SigLocation_twoHundredAndThirtyFourth   = 0x00ea,
    SigLocation_twoHundredAndThirtyNineth   = 0x00ef,
    SigLocation_twoHundredAndThirtySecond   = 0x00e8,
    SigLocation_twoHundredAndThirtySeventh  = 0x00ed,
    SigLocation_twoHundredAndThirtySixth    = 0x00ec,
    SigLocation_twoHundredAndThirtyThird    = 0x00e9,
    SigLocation_twoHundredAndTwelveth       = 0x00d4,
    SigLocation_twoHundredAndTwentyEighth   = 0x00e4,
    SigLocation_twoHundredAndTwentyFifth    = 0x00e1,
    SigLocation_twoHundredAndTwentyFirst    = 0x00dd,
    SigLocation_twoHundredAndTwentyFourth   = 0x00e0,
    SigLocation_twoHundredAndTwentyNineth   = 0x00e5,
    SigLocation_twoHundredAndTwentySecond   = 0x00de,
    SigLocation_twoHundredAndTwentySeventh  = 0x00e3,
    SigLocation_twoHundredAndTwentySixth    = 0x00e2,
    SigLocation_twoHundredAndTwentyThird    = 0x00df,
    SigLocation_twoHundredFiftieth          = 0x00fa,
    SigLocation_twoHundredFortieth          = 0x00f0,
    SigLocation_twoHundredThirtieth         = 0x00e6,
    SigLocation_twoHundredTwentieth         = 0x00dc,
    SigLocation_twoHundredth                = 0x00c8,
    SigLocation_unknown                     = 0x0000,
    SigLocation_upper                       = 0x0104,
} SigLocation;

/// Table 3.6: Generic OnPowerUp states.
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.31)
typedef enum : UInt8 {
    /// Off. After being powered up, the element is in an off state.
    SigOnPowerUpOff     = 0x00,
    /// Default. After being powered up, the element is in an On state and uses default state values.
    SigOnPowerUpDefault = 0x01,
    /// Restore. If a transition was in progress when powered down, the element restores the target state when powered up. Otherwise the element restores the state it was in when powered down.
    SigOnPowerUpRestore = 0x02,
} SigOnPowerUp;

/// Table 7.2: Summary of status codes.
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.303)
typedef enum : UInt8 {
    /// Command successfully processed.
    SigGenericMessageStatusSuccess           = 0x00,
    /// The provided value for Range Min cannot be set.
    SigGenericMessageStatusCannotSetRangeMin = 0x01,
    /// The provided value for Range Max cannot be set.
    SigGenericMessageStatusCannotSetRangeMax = 0x02,
    /// Reserved for Future Use, RFU, 0x03–0xFF.
} SigGenericMessageStatus;

/// Table 3.15: Generic Battery Flags Presence states.
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.35)
typedef enum : UInt8 {
    /// The battery is not present.
    SigBatteryPresenceNotPresent   = 0b00,
    /// The battery is present and is removable.
    SigBatteryPresenceRemovable    = 0b01,
    /// The battery is present and is non-removable.
    SigBatteryPresenceNotRemovable = 0b10,
    /// The battery presence is unknown.
    SigBatteryPresenceUnknown      = 0b11,
} SigBatteryPresence;

/// Table 3.16: Generic Battery Flags Indicator states.
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.35)
typedef enum : UInt8 {
    /// The battery charge is Critically Low Level.
    SigBatteryIndicatorCriticallyLow = 0b00,
    /// The battery charge is Low Level.
    SigBatteryIndicatorLow          = 0b01,
    /// The battery charge is Good Level.
    SigBatteryIndicatorGood         = 0b10,
    /// The battery charge is unknown.
    SigBatteryIndicatorUnknown      = 0b11,
} SigBatteryIndicator;

/// Table 3.17: Generic Battery Flags Charging states.
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.35)
typedef enum : UInt8 {
    /// The battery is not chargeable.
    SigBatteryChargingStateNotChargeable = 0b00,
    /// The battery is chargeable and is not charging.
    SigBatteryChargingStateNotCharging  = 0b01,
    /// The battery is chargeable and is charging.
    SigBatteryChargingStateCharging     = 0b10,
    /// The battery charging state is unknown.
    SigBatteryChargingStateUnknown      = 0b11,
} SigBatteryChargingState;

/// Table 3.18: Generic Battery Flags Serviceability states.
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.35)
typedef enum : UInt8 {
    /// Reserved for Future Use
    SigBatteryServiceabilityReservedForFutureUse = 0b00,
    /// The battery does not require service.
    SigBatteryServiceabilityServiceNotRequired   = 0b01,
    /// The battery requires service.
    SigBatteryServiceabilityServiceRequired      = 0b10,
    /// The battery serviceability is unknown.
    SigBatteryServiceabilityUnknown              = 0b11,
} SigBatteryServiceability;

/// 5.1.2 Time Role
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.136)
typedef enum : UInt8 {
    /// The element does not participate in propagation of time information.
    SigTimeRoleNode              = 0x00,
    /// The element publishes Time Status messages but does not process received Time Status messages.
    SigTimeRoleMeshTimeAuthority = 0x01,
    /// The element processes received and publishes Time Status messages.
    SigTimeRoleMeshTimeRelay     = 0x02,
    /// The element does not publish but processes received Time Status messages.
    SigTimeRoleMeshTimeClient    = 0x03,
} SigTimeRole;

/// 5.2.2.11 Summary of status codes
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.149)
typedef enum : UInt8 {
    /// Success
    SigSceneResponseStatus_success           = 0x00,
    /// Scene Register Full
    SigSceneResponseStatus_sceneRegisterFull = 0x01,
    /// Scene Not Found
    SigSceneResponseStatus_sceneNotFound     = 0x02,
    /// Reserved for Future Use, 0x03–0xFF.
} SigSceneResponseStatus;

/// 4.1.1.4 Sensor Sampling Function
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.106)
typedef enum : UInt8 {
    SigSensorSamplingFunctionType_unspecified    = 0x00,
    SigSensorSamplingFunctionType_instantaneous  = 0x01,
    SigSensorSamplingFunctionType_arithmeticMean = 0x02,
    SigSensorSamplingFunctionType_RMS            = 0x03,
    SigSensorSamplingFunctionType_maximum        = 0x04,
    SigSensorSamplingFunctionType_minimum        = 0x05,
    SigSensorSamplingFunctionType_accumulated    = 0x06,
    SigSensorSamplingFunctionType_count          = 0x07,
} SigSensorSamplingFunctionType;

/// 4.1.2.3 Sensor Setting Access
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.109)
typedef enum : UInt8 {
    //The device property can be read.
    SigSensorSettingAccessType_read      = 0x01,
    //The device property can be read and written.
    SigSensorSettingAccessType_readWrite = 0x03,
} SigSensorSettingAccessType;

/// 4.2.8 Relay
/// - seeAlso: Mesh_v1.0.pdf  (page.140)
typedef enum : UInt8 {
    //The node support Relay feature that is disabled.
    SigNodeRelayState_notEnabled   = 0,
    //The node supports Relay feature that is enabled.
    SigNodeRelayState_enabled      = 1,
    //Relay feature is not supported.
    SigNodeRelayState_notSupported = 2,
} SigNodeRelayState;

/// 4.2.10 SecureNetworkBeacon
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.141)
typedef enum : UInt8 {
    //The node is broadcasting a Secure Network beacon.
    SigSecureNetworkBeaconState_close = 0,
    //The node is not broadcasting a Secure Network beacon.
    SigSecureNetworkBeaconState_open = 1,
} SigSecureNetworkBeaconState;

/// 4.2.11 GATTProxy
/// - seeAlso: Mesh_v1.0.pdf  (page.141)
typedef enum : UInt8 {
    //The Mesh Proxy Service is running, Proxy feature is disabled.
    SigNodeGATTProxyState_notEnabled   = 0,
    //The Mesh Proxy Service is running, Proxy feature is enabled.
    SigNodeGATTProxyState_enabled      = 1,
    //The Mesh Proxy Service is not supported, Proxy feature is not supported.
    SigNodeGATTProxyState_notSupported = 2,
} SigNodeGATTProxyState;

/// 4.2.12 NodeIdentity
/// - seeAlso: Mesh_v1.0.pdf  (page.142)
typedef enum : UInt8 {
    //Node Identity for a subnet is stopped.
    SigNodeIdentityState_notEnabled   = 0,
    //Node Identity for a subnet is running.
    SigNodeIdentityState_enabled      = 1,
    //Node Identity is not supported.
    SigNodeIdentityState_notSupported = 2,
} SigNodeIdentityState;

/// 4.2.13 Friend
/// - seeAlso: Mesh_v1.0.pdf  (page.142)
typedef enum : UInt8 {
    //The node supports Friend feature that is disabled.
    SigNodeFeaturesState_notEnabled   = 0,
    //The node supports Friend feature that is enabled.
    SigNodeFeaturesState_enabled      = 1,
    //The Friend feature is not supported.
    SigNodeFeaturesState_notSupported = 2,
} SigNodeFeaturesState;

/// 4.2.14 Key Refresh Phase.Table 4.17: Key Refresh Phase state values.
/// - seeAlso: Mesh_v1.0.pdf  (page.143)
typedef enum : UInt8 {
    /// Phase 0: Normal Operation.
    normalOperation  = 0,
    /// Phase 1: Distributing new keys to all nodes. Nodes will transmit using
    /// old keys, but can receive using old and new keys.
    distributingKeys = 1,
    /// Phase 2: Transmitting a Secure Network beacon that signals to the network
    /// that all nodes have the new keys. The nodes will then transmit using
    /// the new keys but can receive using the old or new keys.
    finalizing       = 2,
} KeyRefreshPhase;

/// Table 6.5: Proxy Configuration message opcodes
/// - seeAlso: Mesh_v1.0.pdf  (page.263)
typedef enum : UInt8 {
    //Sent by a Proxy Client to set the proxy filter type.
    SigProxyFilerOpcode_setFilterType             = 0x00,
    //Sent by a Proxy Client to add addresses to the proxy filter list.
    SigProxyFilerOpcode_addAddressesToFilter      = 0x01,
    //Sent by a Proxy Client to remove addresses from the proxy filter list.
    SigProxyFilerOpcode_removeAddressesFromFilter = 0x02,
    //Acknowledgment by a Proxy Server to a Proxy Client to report the status of the proxy filter list.
    SigProxyFilerOpcode_filterStatus              = 0x03,
} SigProxyFilerOpcode;

/// Table 6.7: FilterType Values
/// - seeAlso: Mesh_v1.0.pdf  (page.263)
typedef enum : UInt8 {
    /// A white list filter has an associated white list, which is a list of destination addresses that are of interest for the Proxy Client. The white list filter blocks all destination addresses except those that have been added to the white list.
    SigProxyFilerType_whitelist = 0x00,
    /// A black list filter has an associated black list, which is a list of destination addresses that the Proxy Client does not want to receive. The black list filter accepts all destination addresses except those that have been added to the black list.
    SigProxyFilerType_blacklist = 0x01,
} SigProxyFilerType;

/// Firmware Distribution Status Values
/// - seeAlso: Mesh_Firmware_update_20180228_d05r05.pdf  (page.24)
typedef enum : UInt8 {
    /// ready, distribution is not active
    SigFirmwareDistributionStatusType_notActive             = 0x00,
    /// distribution is active
    SigFirmwareDistributionStatusType_active                = 0x01,
    /// no such Company ID and Firmware ID combin
    SigFirmwareDistributionStatusType_noSuchId              = 0x02,
    /// busy with different distribution
    SigFirmwareDistributionStatusType_busyWithDifferent     = 0x03,
    /// update nodes list is too long
    SigFirmwareDistributionStatusType_updateNodeListTooLong = 0x04,
} SigFirmwareDistributionStatusType;

/// Update status code values:
/// - seeAlso: Mesh_Firmware_update_20180228_d05r05.pdf  (page.25)
typedef enum : UInt8 {
    /// successfully updated
    SigUpdateStatusType_success    = 0x00,
    /// in progress
    SigUpdateStatusType_inProgress = 0x01,
    /// canceled
    SigUpdateStatusType_cancel     = 0x02,
} SigUpdateStatusType;

/// Table 8.17: Update Policy state values
/// - seeAlso: MshMDL_DFU_MBT_CR_R06.pdf  (page.87)
typedef enum : UInt8 {
    /// The Firmware Distribution Server verifies that firmware image distribution completed successfully but does not apply the update. The Initiator (the Firmware Distribution Client) initiates firmware image application.
    SigUpdatePolicyType_verifyOnly       = 0x00,
    /// The Firmware Distribution Server verifies that firmware image distribution completed successfully and then applies the firmware update.
    SigUpdatePolicyType_verifyAndApply = 0x01,
} SigUpdatePolicyType;

/// Firmware Update Status Values
/// - seeAlso: Mesh_Firmware_update_20180228_d05r05.pdf  (page.28)
typedef enum : UInt8 {
    /// success
    SigFirmwareUpdateStatusType_success                 = 0x00,
    /// wrong Company ID and Firmware ID combination
    SigFirmwareUpdateStatusType_IdCombinationWrong      = 0x01,
    /// different object transfer already ongoing
    SigFirmwareUpdateStatusType_busyWithDifferentObject = 0x02,
    /// Company ID and Firmware ID combination apply failed
    SigFirmwareUpdateStatusType_IdCombinationApplyFail  = 0x03,
    /// Company ID and Firmware ID combination permanently rejected, newer firmware version present
    SigFirmwareUpdateStatusType_combinationAlwaysReject = 0x04,
    /// Company ID and Firmware ID combination temporary rejected, node is not able to accept new firmware now, try again later
    SigFirmwareUpdateStatusType_combinationTempReject   = 0x05,
} SigFirmwareUpdateStatusType;

/// The Block Checksum Algorithm values
/// - seeAlso: Mesh_Firmware_update_20180228_d05r05.pdf  (page.31)
typedef enum : UInt8 {
    /// Details TBD, Block Checksum Value len is 4.
    SigBlockChecksumAlgorithmType_CRC32 = 0x00,
    /// Reserved for Future Use, 0x01-0xFF
} SigBlockChecksumAlgorithmType;

/// Object Block Transfer Status values
/// - seeAlso: Mesh_Firmware_update_20180228_d05r05.pdf  (page.32)
typedef enum : UInt8 {
    /// block transfer accepted
    SigObjectBlockTransferStatusType_accepted                 = 0x00,
    /// block already transferred
    SigObjectBlockTransferStatusType_alreadyRX                = 0x01,
    /// invalid block number, no previous block
    SigObjectBlockTransferStatusType_invalidBlockNumber       = 0x02,
    /// wrong current block size - bigger then Block Size Log [Object Transfer Start]
    SigObjectBlockTransferStatusType_wrongCurrentBlockSize    = 0x03,
    /// wrong Chunk Size - bigger then Block Size divided by Max Chunks Number [Object Information Status]
    SigObjectBlockTransferStatusType_wrongChunkSize           = 0x04,
    /// unknown checksum algorithm
    SigObjectBlockTransferStatusType_unknownChecksumAlgorithm = 0x05,
    /// block transfer rejected
    SigObjectBlockTransferStatusType_rejected                 = 0x0F,
} SigObjectBlockTransferStatusType;

/// Table 8.22: Status codes for the Firmware Update Server model and Firmware Update Client model
/// - seeAlso: MshMDL_DFU_MBT_CR_R04_LbL25.pdf  (page.80)
typedef enum : UInt8 {
    /// The message was processed successfully.
    SigFirmwareUpdateServerAndClientModelStatusType_success                = 0x00,
    /// Insufficient resources on the node.
    SigFirmwareUpdateServerAndClientModelStatusType_insufficientResources  = 0x01,
    /// The operation cannot be performed while the server is in the current phase.
    SigFirmwareUpdateServerAndClientModelStatusType_wrongPhase             = 0x02,
    /// An internal error occurred on the node.
    SigFirmwareUpdateServerAndClientModelStatusType_internalError          = 0x03,
    /// The message contains a firmware index value that is not expected.
    SigFirmwareUpdateServerAndClientModelStatusType_wrongFirmwareIndex     = 0x04,
    /// The metadata check failed.
    SigFirmwareUpdateServerAndClientModelStatusType_metadataCheckFailed    = 0x05,
    /// The server cannot start a firmware update.
    SigFirmwareUpdateServerAndClientModelStatusType_temporarilyUnavailable = 0x06,
    /// Another BLOB transfer is in progress.
    SigFirmwareUpdateServerAndClientModelStatusType_BLOBTransferBusy       = 0x07,
} SigFirmwareUpdateServerAndClientModelStatusType;

/// Table 8.24: Status codes for the Firmware Distribution Server model and Firmware Distribution Client model
/// - seeAlso: MshMDL_DFU_MBT_CR_R06  (page.92)
typedef enum : UInt8 {
    /// The message was processed successfully.
    SigFirmwareDistributionServerAndClientModelStatusType_success               = 0x00,
    /// Insufficient resources on the node.
    SigFirmwareDistributionServerAndClientModelStatusType_insufficientResources = 0x01,
    /// The operation cannot be performed while the server is in the current phase.
    SigFirmwareDistributionServerAndClientModelStatusType_wrongPhase            = 0x02,
    /// An internal error occurred on the node.
    SigFirmwareDistributionServerAndClientModelStatusType_internalError         = 0x03,
    /// The requested firmware image is not stored on the Distributor.
    SigFirmwareDistributionServerAndClientModelStatusType_firmwareNotFound      = 0x04,
    /// The AppKey identified by the AppKey Index is not known to the node.
    SigFirmwareDistributionServerAndClientModelStatusType_invalidAppKeyIndex    = 0x05,
    /// There are no Updating nodes in the Distribution Receivers List state.
    SigFirmwareDistributionServerAndClientModelStatusType_receiversListEmpty    = 0x06,
    /// Another firmware image distribution is in progress.
    SigFirmwareDistributionServerAndClientModelStatusType_busyWithDistribution  = 0x07,
    /// Another upload is in progress.
    SigFirmwareDistributionServerAndClientModelStatusType_busyWithUpload        = 0x08,
    /// The URI scheme name indicated by the Update URI is not supported.
    SigFirmwareDistributionServerAndClientModelStatusType_URINotSupported       = 0x09,
    /// The format of the Update URI is invalid.
    SigFirmwareDistributionServerAndClientModelStatusType_URIMalformed          = 0x0A,
    /// Reserved For Future Use, 0x0B–0xFF.
} SigFirmwareDistributionServerAndClientModelStatusType;

/// Table 8.18: Upload Phase state values
/// - seeAlso: MshMDL_DFU_MBT_CR_R06.pdf  (page.89)
typedef enum       : UInt8 {
    /// No firmware upload is in progress.
    SigFirmwareUploadPhaseStateType_idle              = 0x00,
    /// The Store Firmware procedure is being executed.
    SigFirmwareUploadPhaseStateType_transferActive    = 0x01,
//    /// The Store Firmware OOB procedure is being executed.
//    SigFirmwareUploadPhaseStateType_OOBTransferActive = 0x02,
    /// The Store Firmware procedure or Store Firmware OOB procedure failed.
    SigFirmwareUploadPhaseStateType_transferError     = 0x02,
    /// The Store Firmware procedure or the Store Firmware OOB procedure completed successfully.
    SigFirmwareUploadPhaseStateType_transferSuccess   = 0x03,
    /// Prohibited : 0x05–0xFF
} SigFirmwareUploadPhaseStateType;

/// Table 8.8: Firmware Update Additional Information state values
/// - seeAlso: MshMDL_DFU_MBT_CR_R04_LbL25.pdf  (page.71)
typedef enum                    : UInt8 {
    /// No changes to node composition data.
    SigFirmwareUpdateAdditionalInformationStatusType_noChangeCompositionData              = 0x00,
    /// Node composition data changed. The node does not support remote provisioning.
    SigFirmwareUpdateAdditionalInformationStatusType_changeCompositionDataUnSupportRemote = 0x01,
    /// Node composition data changed, and remote provisioning is supported. The node supports remote provisioning and composition data page 0x80. Page 0x80 contains different composition data than page 0x0.
    SigFirmwareUpdateAdditionalInformationStatusType_changeCompositionDataSupportRemote   = 0x02,
    /// Node unprovisioned. The node is unprovisioned after successful application of a verified firmware image.
    SigFirmwareUpdateAdditionalInformationStatusType_nodeUnprovisioned                    = 0x03,
    /// Reserved for Future Use : 0x4–0x1F
} SigFirmwareUpdateAdditionalInformationStatusType;

/// Table 8.7: Update Phase state values
/// - seeAlso: MshMDL_DFU_MBT_CR_R04_LbL25.pdf  (page.71)
typedef enum : UInt8 {
    /// Ready to start a Receive Firmware procedure..
    SigFirmwareUpdatePhaseType_idle                = 0x00,
    /// The Transfer BLOB procedure failed.
    SigFirmwareUpdatePhaseType_transferError       = 0x01,
    /// The Receive Firmware procedure is being executed.
    SigFirmwareUpdatePhaseType_transferActive      = 0x02,
    /// The Verify Firmware procedure is being executed.
    SigFirmwareUpdatePhaseType_verifyingUpdate     = 0x03,
    /// The Verify Firmware procedure completed successfully.
    SigFirmwareUpdatePhaseType_verificationSuccess = 0x04,
    /// The Verify Firmware procedure failed.
    SigFirmwareUpdatePhaseType_verificationFailed  = 0x05,
    /// The Apply New Firmware procedure is being executed.
    SigFirmwareUpdatePhaseType_applyingUpdate      = 0x06,
    /// Prohibited.
    SigFirmwareUpdatePhaseType_prohibited          = 0x07,
} SigFirmwareUpdatePhaseType;

/// Table 3.10 Status codes used by the BLOB Transfer models
/// - seeAlso: MshMDL_BLOB_CR_Vienna_IOP.pdf  (page.16)
typedef enum : UInt8 {
    /// The message was processed successfully.
    SigBLOBBlockStatusType_success                 = 0x00,
    /// The Block Number field value is not within range.
    SigBLOBBlockStatusType_invalidBlockNumber      = 0x01,
    /// The block size is lower than the size represented by Min Block Size Log, or the block size is higher than the size represented by Max Block Size Log.
    SigBLOBBlockStatusType_wrongBlockSize          = 0x02,
    /// Chunk size exceeds the size represented by Max Chunk Size, or the number of chunks exceeds the number specified by Max Chunks Number.
    SigBLOBBlockStatusType_wrongChunkSize          = 0x03,
    /// The model is in a state where it cannot process the message.
    SigBLOBBlockStatusType_invalidState            = 0x04,
    /// A parameter value in the message cannot be accepted.
    SigBLOBBlockStatusType_invalidParameter        = 0x05,
    /// The requested BLOB ID is not expected.
    SigBLOBBlockStatusType_wrongBLOBID             = 0x06,
    /// There is not enough space available in memory to receive the BLOB.
    SigBLOBBlockStatusType_BLOBTooLarge            = 0x07,
    /// The transfer mode is not supported by the BLOB Transfer Server model.
    SigBLOBBlockStatusType_unsupportedTransferMode = 0x08,
    /// An internal error occurred on the node.
    SigBLOBBlockStatusType_internalError           = 0x09,
    /// Prohibited, 0xA-0xF
} SigBLOBBlockStatusType;

/// Table 3.16 Format field enumeration values
/// - seeAlso: MshMDL_BLOB_CR_Vienna_IOP.pdf  (page.20)
typedef enum : UInt8 {
    /// All chunks in the block are missing.
    SigBLOBBlockFormatType_allChunksMissing     = 0x00,
    /// All chunks in the block have been received.
    SigBLOBBlockFormatType_noMissingChunks      = 0x01,
    /// At least one chunk has been received and at least one chunk is missing.
    SigBLOBBlockFormatType_someChunksMissing    = 0x02,
    /// List of chunks requested by the server.
    SigBLOBBlockFormatType_encodedMissingChunks = 0x03,
} SigBLOBBlockFormatType;

/// Table 7.17 Status codes used by the BLOB Transfer Server and the BLOB Transfer Client models
/// - seeAlso: MshMDL_DFU_MBT_CR_R06  (page.27)
typedef enum       : UInt8 {
    /// The message was processed successfully.
    SigBLOBTransferStatusType_success                 = 0x00,
    /// The Block Number field value is not within the range of blocks being transferred.
    SigBLOBTransferStatusType_invalidBlockNumber      = 0x01,
    /// The block size is smaller than the size indicated by the Min Block Size Log state or is larger than the size indicated by the Max Block Size Log state.
    SigBLOBTransferStatusType_invalidBlockSize        = 0x02,
    /// The chunk size exceeds the size indicated by the Max Chunk Size state, or the number of chunks exceeds the number specified by the Max Total Chunks state.
    SigBLOBTransferStatusType_invalidChunkSize        = 0x03,
    /// The operation cannot be performed while the server is in the current phase.
    SigBLOBTransferStatusType_wrongPhase              = 0x04,
    /// A parameter value in the message cannot be accepted.
    SigBLOBTransferStatusType_invalidParameter        = 0x05,
    /// The message contains a BLOB ID value that is not expected.
    SigBLOBTransferStatusType_wrongBLOBID             = 0x06,
    /// There is not enough space available in memory to receive the BLOB.
    SigBLOBTransferStatusType_BLOBTooLarge            = 0x07,
    /// The transfer mode is not supported by the BLOB Transfer Server model.
    SigBLOBTransferStatusType_unsupportedTransferMode = 0x08,
    /// An internal error occurred on the node.
    SigBLOBTransferStatusType_internalError           = 0x09,
    /// The requested information cannot be provided while the server is in the current phase.
    SigBLOBTransferStatusType_informationUnavailable  = 0x0A,
    /// Prohibited : 0xB–0xF
} SigBLOBTransferStatusType;

/// Table 7.5: Transfer Mode state values
/// - seeAlso: MshMDL_DFU_MBT_CR_R04_LbL25.pdf  (page.21)
typedef enum : UInt8 {
    /// No Active Transfer.
    SigTransferModeState_noActiveTransfer     = 0x00,
    /// Push BLOB Transfer Mode (see Section 7.1.1.1).
    SigTransferModeState_pushBLOBTransferMode = 0x01,
    /// Pull BLOB Transfer Mode (see Section 7.1.1.1).
    SigTransferModeState_pullBLOBTransferMode = 0x02,
    /// Prohibited.
    SigTransferModeState_prohibited           = 0x03,
} SigTransferModeState;

/// Table 7.6: Transfer Phase state values
/// - seeAlso: MshMDL_DFU_MBT_CR_R04_LbL25.pdf  (page.22)
typedef enum       : UInt8 {
    /// The BLOB Transfer Server is awaiting configuration and cannot receive a BLOB.
    SigTransferPhaseState_inactive                = 0x00,
    /// The BLOB Transfer Server is ready to receive the BLOB identified by the Expected BLOB ID.
    SigTransferPhaseState_waitingForTransferStart = 0x01,
    /// The BLOB Transfer Server is waiting for the next block of data.
    SigTransferPhaseState_waitingForNextBlock     = 0x02,
    /// The BLOB Transfer Server is waiting for the next chunk of data.
    SigTransferPhaseState_waitingForNextChunk     = 0x03,
    /// The BLOB was transferred successfully.
    SigTransferPhaseState_complete                = 0x04,
    /// The Initialize and Receive BLOB procedure is paused.
    SigTransferPhaseState_suspended               = 0x05,
    /// Prohibited : 0x06–0xFF
} SigTransferPhaseState;

/// Table 8.16: Distribution Phase state values
/// - seeAlso: MshMDL_DFU_MBT_CR_R06.pdf  (page.87)
typedef enum       : UInt8 {
    /// No firmware distribution is in progress.
    SigDistributionPhaseState_idle            = 0x00,
    /// Firmware distribution is in progress.
    SigDistributionPhaseState_transferActive  = 0x01,
    /// The Transfer BLOB procedure has completed successfully.
    SigDistributionPhaseState_transferSuccess = 0x02,
    /// The Apply Firmware on Updating Nodes procedure is being executed.
    SigDistributionPhaseState_applyingUpdate  = 0x03,
    /// The Distribute Firmware procedure has completed successfully.
    SigDistributionPhaseState_completed       = 0x04,
    /// The Distribute Firmware procedure has failed.
    SigDistributionPhaseState_failed          = 0x05,
    /// The Cancel Firmware Update procedure is being executed.
    SigDistributionPhaseState_cancelingUpdate = 0x06,
    /// Prohibited : 0x07–0xFF
} SigDistributionPhaseState;

/// Table 4.22 defines status codes for Remote Provisioning Server messages that contain a status code.
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.27)
typedef enum : UInt8 {
    SigRemoteProvisioningStatus_success                                    = 0x00,
    SigRemoteProvisioningStatus_scanningCannotStart                        = 0x01,
    SigRemoteProvisioningStatus_invalidState                               = 0x02,
    SigRemoteProvisioningStatus_limitedResources                           = 0x03,
    SigRemoteProvisioningStatus_linkCannotOpen                             = 0x04,
    SigRemoteProvisioningStatus_linkOpenFailed                             = 0x05,
    SigRemoteProvisioningStatus_linkClosedByDevice                         = 0x06,
    SigRemoteProvisioningStatus_linkClosedByServer                         = 0x07,
    SigRemoteProvisioningStatus_linkClosedByClient                         = 0x08,
    SigRemoteProvisioningStatus_linkClosedAsCannotReceivePDU               = 0x09,
    SigRemoteProvisioningStatus_linkClosedAsCannotSendPDU                  = 0x0A,
    SigRemoteProvisioningStatus_linkClosedAsCannotDeliverPDUReport         = 0x0B,
    SigRemoteProvisioningStatus_linkClosedAsCannotDeliverPDUOutboundReport = 0x0C,
    /// Reserved for Future Use, 0x0D-0xFF
} SigRemoteProvisioningStatus;

/// Table 4.15: Reason field values for a Remote Provisioning Link Close message
/// - seeAlso: MshPRF_RPR_CR_r16_VZ2_ba3-dpc-ok2-PW_ok-PW2_RemoteProvisioner.docx  (page.23)
typedef enum : UInt8 {
    /// The provisioning or Device Key Refresh procedure completed successfully.
    SigRemoteProvisioningLinkCloseStatus_success    = 0x00,
    /// Prohibited
    SigRemoteProvisioningLinkCloseStatus_prohibited = 0x01,
    /// The provisioning or Device Key Refresh procedure failed.
    SigRemoteProvisioningLinkCloseStatus_fail       = 0x02,
    /// Reserved for Future Use, 0x03-0xFF
} SigRemoteProvisioningLinkCloseStatus;

/// Fast provision status
/// - seeAlso: fast provision流程简介.pdf  (page.1)
typedef enum : UInt8 {
    SigFastProvisionStatus_idle            = 0x00,
    SigFastProvisionStatus_start           = 0x01,
    SigFastProvisionStatus_resetNetwork    = 0x02,
    SigFastProvisionStatus_getAddress      = 0x03,
    SigFastProvisionStatus_getAddressRetry = 0x04,
    SigFastProvisionStatus_setAddress      = 0x05,
    SigFastProvisionStatus_setNetworkInfo  = 0x06,
    SigFastProvisionStatus_confirm         = 0x07,
    SigFastProvisionStatus_confirmOk       = 0x08,
    SigFastProvisionStatus_complete        = 0x09,
    SigFastProvisionStatus_timeout         = 0x0A,
} SigFastProvisionStatus;

/// Table 4.18: Controllable Key Refresh transition values
/// - seeAlso: Mesh_v1.0.pdf  (page.143)
typedef enum : UInt8 {
    SigControllableKeyRefreshTransitionValues_two   = 0x02,
    SigControllableKeyRefreshTransitionValues_three = 0x03,
} SigControllableKeyRefreshTransitionValues;

/// Table 4.Y+0: Subnet Bridge state values (The default value of the Subnet Bridge state shall be 0x00.)
/// - seeAlso: MshPRF_SBR_CR_r03.pdf  (page.8)
typedef enum : UInt8 {
    /// Subnet bridge functionality is disabled.
    SigSubnetBridgeStateValues_disabled = 0x00,
    /// Subnet bridge functionality is enabled.
    SigSubnetBridgeStateValues_enabled  = 0x01,
    /// Prohibited, 0x02–0xFF.
} SigSubnetBridgeStateValues;

/// Table 4.Y+2: Directions field values
/// - seeAlso: MshPRF_SBR_CR_r03.pdf  (page.9)
typedef enum : UInt8 {
    /// Prohibited.
    SigDirectionsFieldValues_prohibited     = 0x00,
    /// Bridging is allowed only for messages with Address1 as the source address and Address2 as the destination address. (单向)
    SigDirectionsFieldValues_unidirectional = 0x01,
    /// Bridging is allowed for messages with Address1 as the source address and Address2 as the destination address, and messages with Address2 as the source address and Address1 as the destination address. (双向)
    SigDirectionsFieldValues_bidirectional  = 0x02,
    /// Prohibited, 0x03–0xFF.
} SigDirectionsFieldValues;

/// Table 4.Y+10: Filter field values
/// - seeAlso: MshPRF_SBR_CR_r03.pdf  (page.13)
typedef enum : UInt8 {
    /// Report all pairs of NetKey Indexes extracted from the Bridging Table state entries.
    SigFilterFieldValues_all                   = 0b00,
    /// Report pairs of NetKey Indexes extracted from the Bridging Table state entries with the NetKey Index of the first subnet that matches the NetKeyIndex field value.
    SigFilterFieldValues_first                 = 0b01,
    /// Report pairs of NetKey Indexes extracted from the Bridging Table state entries with the NetKey Index of the second subnet that matches the NetKeyIndex field value.
    SigFilterFieldValues_second                = 0b10,
    /// Report pairs of NetKey Indexes extracted from the Bridging Table state entries with one of the NetKey Indexes that matches the NetKeyIndex field.
    SigFilterFieldValues_oneOfTheNetKeyIndexes = 0b11,
} SigFilterFieldValues;

/// Table 5.45: Status codes for the Provisioning Record Response PDU
/// - seeAlso: MshPRFd1.1r11_clean.pdf.pdf  (page.496)
typedef enum : UInt8 {
    /// Success.
    SigProvisioningRecordResponseStatus_success                   = 0x00,
    /// Requested Record Is Not Present.
    SigProvisioningRecordResponseStatus_requestedRecordIsNotPresent                 = 0x01,
    /// Requested Offset Is Out Of Bounds.
    SigProvisioningRecordResponseStatus_requestedOffsetIsOutOfBounds                = 0x02,
    /// 0x03–0xFF Reserved for Future Use.
} SigProvisioningRecordResponseStatus;

typedef enum : UInt8 {
    SigFipsP256EllipticCurve_CMAC_AES128 = 0x01,//BTM_ECDH_P256_CMAC_AES128_AES_CCM，如果设备端不支持该算法就会出现provision失败。
    SigFipsP256EllipticCurve_HMAC_SHA256 = 0x02,//BTM_ECDH_P256_HMAC_SHA256_AES_CCM，如果设备端不支持该算法就会出现provision失败。
    SigFipsP256EllipticCurve_auto = 0xFF,//APP端根据从设备端实时读取数据来判定使用哪一种算法进行provision流程，如果设备端同时支持多种算法，默认使用value最大的算法进行provision。
} SigFipsP256EllipticCurve;

/// telink私有定义的Extend Bearer Mode，SDK默认是使用0，特殊用户需要用到2。
typedef enum : UInt8 {
    SigTelinkExtendBearerMode_noExtend = 0x00,//segment发包中的单个分包的UpperTransportPDU最大长度都是标准sig定义的12字节。
    SigTelinkExtendBearerMode_extendGATTOnly = 0x01,//非直连节点使用的是上述标准sig定义的12字节。直连节点使用SigDataSource.share.defaultUnsegmentedMessageLowerTransportPDUMaxLength最为单个分包的UpperTransportPDU最大长度。
    SigTelinkExtendBearerMode_extendGATTAndAdv = 0x02,//segment发包中的单个分包的UpperTransportPDU最大长度都是telink自定义的SigDataSource.share.defaultUnsegmentedMessageLowerTransportPDUMaxLength。
} SigTelinkExtendBearerMode;

/// Table 4.295: Summary of status codes for Opcodes Aggregator messages
/// - seeAlso: MshPRFd1.1r13_clean.pdf  (page.418)
typedef enum : UInt8 {
    /// Success
    SigOpcodesAggregatorMessagesStatus_success = 0,
    /// The unicast address provided in the Element_Address field is not known to the node.
    SigOpcodesAggregatorMessagesStatus_invalidAddress = 1,
    /// The model identified by the Element_Address field and Item #0 opcode is not found in the identified element.
    SigOpcodesAggregatorMessagesStatus_invalidModel = 2,
    /// 1.The message is encrypted with an application key, and the identified model is not bound to the message’s application key, or the identified model’s access layer security is not using application keys.
    /// 2.The message is encrypted with a device key, and the identified model’s access layer security is not using a device key.
    SigOpcodesAggregatorMessagesStatus_wrongAccessKey = 3,
    /// At least one of the items from the message request list contains an opcode that is not supported by the identified model.
    SigOpcodesAggregatorMessagesStatus_wrongOpCode = 4,
    /// An access message has a valid opcode but is not understood by the identified model (see Section 3.7.4.4)
    SigOpcodesAggregatorMessagesStatus_messageNotUnderstood = 5,
    /// Reserved for Future Use, 0x06–0xFF.
} SigOpcodesAggregatorMessagesStatus;

/// Table 3.109: Day of Week field
/// - seeAlso: GATT_Specification_Supplement_v5.pdf  (page.105)
typedef enum : UInt8 {
    GattDayOfWeek_Unknown = 0,
    GattDayOfWeek_Monday = 1,
    GattDayOfWeek_Tuesday = 2,
    GattDayOfWeek_Wednesday = 3,
    GattDayOfWeek_Thursday = 4,
    GattDayOfWeek_Friday = 5,
    GattDayOfWeek_Saturday = 6,
    GattDayOfWeek_Sunday = 7,
    //Reserved for Future Use 8–255
} GattDayOfWeek;

/// Table 7.8: Identification Type values
/// - seeAlso: MshPRFd1.1r14_clean.pdf  (page.634)
typedef enum : UInt8 {
    SigIdentificationType_networkID = 0,
    SigIdentificationType_nodeIdentity = 1,
    SigIdentificationType_privateNetworkIdentity = 2,
    SigIdentificationType_privateNodeIdentity = 3,
    //Reserved for Future Use 0x04–0xFF
} SigIdentificationType;

/// Table 4.65: Private Beacon state
/// - seeAlso: MshPRFd1.1r14_clean.pdf  (page.276)
typedef enum : UInt8 {
    SigPrivateBeaconState_disable = 0,
    SigPrivateBeaconState_enable = 1,
    //Prohibited 0x02–0xFF
} SigPrivateBeaconState;

/// Table 4.67: Private GATT Proxy state values
/// - seeAlso: MshPRFd1.1r14_clean.pdf  (page.280)
typedef enum : UInt8 {
    SigPrivateGattProxyState_disable = 0,
    SigPrivateGattProxyState_enable = 1,
    SigPrivateGattProxyState_notSupported = 2,
    //Prohibited 0x03–0xFF
} SigPrivateGattProxyState;

/// Table 4.68: Private Node Identity values
/// - seeAlso: MshPRFd1.1r14_clean.pdf  (page.280)
typedef enum : UInt8 {
    //Node Identity for a subnet is stopped.
    SigPrivateNodeIdentityState_notEnabled   = 0,
    //Node Identity for a subnet is running.
    SigPrivateNodeIdentityState_enabled      = 1,
    //Node Identity is not supported.
    SigPrivateNodeIdentityState_notSupported = 2,
    //0x03–0xFF Prohibited
} SigPrivateNodeIdentityState;

/// app端发送的beacon类型
typedef enum : UInt8 {
    AppSendBeaconType_auto,//根据设备返回的beacon类型来返回
    AppSendBeaconType_secureNetwork,//强制发送secureNetworkBeacon
    AppSendBeaconType_meshPrivateBeacon,//强制发送meshPrivateBeacon
} AppSendBeaconType;

#endif /* SigEnumeration_h */
