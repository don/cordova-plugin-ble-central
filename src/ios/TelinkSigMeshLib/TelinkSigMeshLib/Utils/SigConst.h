/********************************************************************************************************
 * @file     SigConst.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/11/27
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
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Const string

UIKIT_EXTERN NSString * const kTelinkSigMeshLibVersion;

UIKIT_EXTERN NSString * const kNotifyCommandIsBusyOrNot;
UIKIT_EXTERN NSString * const kCommandIsBusyKey;

/// Error thrown when the local Provisioner does not have a Unicast Address specified and is not able to send requested message.
UIKIT_EXTERN NSString * const AccessError_invalidSource;
/// Thrown when trying to send a message using an Element that does not belong to the local Provisioner's Node.
UIKIT_EXTERN NSString * const AccessError_invalidElement;
/// Thrown when the given TTL is not valid. Valid TTL must be 0 or in range 2...127.
UIKIT_EXTERN NSString * const AccessError_invalidTtl;
/// Thrown when the destination Address is not known and the library cannot determine the Network Key to use.
UIKIT_EXTERN NSString * const AccessError_invalidDestination;
/// Thrown when trying to send a message from a Model that does not have any Application Key bound to it.
UIKIT_EXTERN NSString * const AccessError_modelNotBoundToAppKey;
/// Error thrown when the Provisioner is trying to delete the last Network Key from the Node.
UIKIT_EXTERN NSString * const AccessError_cannotDelete;
/// Thrown, when the acknowledgment has not been received until the time run out.
UIKIT_EXTERN NSString * const AccessError_timeout;


//service
UIKIT_EXTERN NSString * const kPBGATTService;
UIKIT_EXTERN NSString * const kPROXYService;
//SIGCharacteristicsIDs
UIKIT_EXTERN NSString * const kPBGATT_Out_CharacteristicsID;
UIKIT_EXTERN NSString * const kPBGATT_In_CharacteristicsID;
UIKIT_EXTERN NSString * const kPROXY_Out_CharacteristicsID;
UIKIT_EXTERN NSString * const kPROXY_In_CharacteristicsID;
UIKIT_EXTERN NSString * const kOnlineStatusCharacteristicsID;
/// update firmware
UIKIT_EXTERN NSString * const kOTA_CharacteristicsID;
UIKIT_EXTERN NSString * const kMeshOTA_CharacteristicsID;
UIKIT_EXTERN NSString * const kFirmwareRevisionCharacteristicsID;


//存储数据的key
//mesh
UIKIT_EXTERN NSString * const kScanList_key;
UIKIT_EXTERN NSString * const kJsonMeshUUID_key;
UIKIT_EXTERN NSString * const kCurrenProvisionerUUID_key;
UIKIT_EXTERN NSString * const kCurrenProvisionerSno_key;
//homes
UIKIT_EXTERN NSString * const kCurrentMeshProvisionAddress_key;
//SigScanRspModel
UIKIT_EXTERN NSString * const kSigScanRspModel_uuid_key;
UIKIT_EXTERN NSString * const kSigScanRspModel_address_key;
UIKIT_EXTERN NSString * const kSigScanRspModel_mac_key;
//UIKIT_EXTERN NSString * const kSigScanRspModel_nodeIdentityData_key;
//UIKIT_EXTERN NSString * const kSigScanRspModel_networkIDData_key;
UIKIT_EXTERN NSString * const kSigScanRspModel_advertisementDataServiceData_key;
//meshOTA
UIKIT_EXTERN NSString * const kSaveMeshOTADictKey;
/*存储在本地的数据的key，不再存储在cache中，因为苹果设备的存储快满的时候，系统会删除cache文件夹的数据*/
UIKIT_EXTERN NSString * const kSaveLocationDataKey;//@"mesh.json"
UIKIT_EXTERN NSString * const kExtendBearerMode;//@"kExtendBearerMode"
UIKIT_EXTERN UInt8 const kDLEUnsegmentLength;// 229

//oob
UIKIT_EXTERN NSString * const kSigOOBModel_sourceType_key;
UIKIT_EXTERN NSString * const kSigOOBModel_UUIDString_key;
UIKIT_EXTERN NSString * const kSigOOBModel_OOBString_key;
UIKIT_EXTERN NSString * const kSigOOBModel_lastEditTimeString_key;
UIKIT_EXTERN NSString * const kOOBStoreKey;

UIKIT_EXTERN NSString * const kFeatureString_relay;
UIKIT_EXTERN NSString * const kFeatureString_proxy;
UIKIT_EXTERN NSString * const kFeatureString_friend;
UIKIT_EXTERN NSString * const kFeatureString_lowPower;

UIKIT_EXTERN NSString * const kSigModelGroup_Generic_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_Sensors_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_TimeServer_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_Lighting_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_Configuration_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_Health_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_RemoteProvision_Describe;

UIKIT_EXTERN NSString * const kSigModelGroup_FirmwareUpdate_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_FirmwareDistribution_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_ObjectTransfer_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_DF_CFG_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_SubnetBridge_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_PrivateBeacon_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_ON_DEMAND_PROXY_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_SAR_CFG_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_OP_AGG_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_LARGE_CPS_Describe;
UIKIT_EXTERN NSString * const kSigModelGroup_SOLI_PDU_RPL_CFG_Describe;

UIKIT_EXTERN NSString * const kSigModel_ConfigurationServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_ConfigurationClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_HealthServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_HealthClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_RemoteProvisionServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_RemoteProvisionClient_Describe;

UIKIT_EXTERN NSString * const kSigModel_GenericOnOffServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericOnOffClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericLevelServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericLevelClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericDefaultTransitionTimeServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericDefaultTransitionTimeClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericPowerOnOffServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericPowerOnOffSetupServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericPowerOnOffClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericPowerLevelServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericPowerLevelSetupServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericPowerLevelClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericBatteryServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericBatteryClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericLocationServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericLocationSetupServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericLocationClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericAdminPropertyServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericManufacturerPropertyServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericUserPropertyServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericClientPropertyServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_GenericPropertyClient_Describe;
// --------
UIKIT_EXTERN NSString * const kSigModel_SensorServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_SensorSetupServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_SensorClient_Describe;
// --------
UIKIT_EXTERN NSString * const kSigModel_TimeServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_TimeSetupServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_TimeClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_SceneServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_SceneSetupServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_SceneClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_SchedulerServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_SchedulerSetupServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_SchedulerClient_Describe;
// --------
UIKIT_EXTERN NSString * const kSigModel_LightLightnessServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightLightnessSetupServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightLightnessClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightCTLServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightCTLSetupServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightCTLClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightCTLTemperatureServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightHSLServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightHSLSetupServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightHSLClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightHSLHueServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightHSLSaturationServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightxyLServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightxyLSetupServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightxyLClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightLCServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightLCSetupServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_LightLCClient_Describe;
// --------
UIKIT_EXTERN NSString * const kSigModel_FirmwareUpdateServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_FirmwareUpdateClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_FirmwareDistributionServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_FirmwareDistributionClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_ObjectTransferServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_ObjectTransferClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_DF_CFG_S_Describe;
UIKIT_EXTERN NSString * const kSigModel_DF_CFG_C_Describe;
UIKIT_EXTERN NSString * const kSigModel_SubnetBridgeServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_SubnetBridgeClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_PrivateBeaconServer_Describe;
UIKIT_EXTERN NSString * const kSigModel_PrivateBeaconClient_Describe;
UIKIT_EXTERN NSString * const kSigModel_ON_DEMAND_PROXY_S_Describe;
UIKIT_EXTERN NSString * const kSigModel_ON_DEMAND_PROXY_C_Describe;
UIKIT_EXTERN NSString * const kSigModel_SAR_CFG_S_Describe;
UIKIT_EXTERN NSString * const kSigModel_SAR_CFG_C_Describe;
UIKIT_EXTERN NSString * const kSigModel_OP_AGG_S_Describe;
UIKIT_EXTERN NSString * const kSigModel_OP_AGG_C_Describe;
UIKIT_EXTERN NSString * const kSigModel_LARGE_CPS_S_Describe;
UIKIT_EXTERN NSString * const kSigModel_LARGE_CPS_C_Describe;
UIKIT_EXTERN NSString * const kSigModel_SOLI_PDU_RPL_CFG_S_Describe;
UIKIT_EXTERN NSString * const kSigModel_SOLI_PDU_RPL_CFG_C_Describe;

#pragma mark - Const bool

/// 标记是否添加未广播蓝牙mac地址的设备，默认不添加
UIKIT_EXTERN BOOL const kAddNotAdvertisementMac;
/// json中是否保存MacAddress，默认保存
UIKIT_EXTERN BOOL const kSaveMacAddressToJson;


#pragma mark - Const int

UIKIT_EXTERN UInt16 const CTL_TEMP_MIN;// 800
UIKIT_EXTERN UInt16 const CTL_TEMP_MAX;// 20000
UIKIT_EXTERN UInt8 const TTL_DEFAULT;// 10, max relay count = TTL_DEFAULT - 1
UIKIT_EXTERN UInt16 const LEVEL_OFF;// -32768
UIKIT_EXTERN UInt16 const LUM_OFF;// 0

//sig model
UIKIT_EXTERN UInt16 const kSigModel_ConfigurationServer_ID;//               = 0x0000
UIKIT_EXTERN UInt16 const kSigModel_ConfigurationClient_ID;//               = 0x0001
UIKIT_EXTERN UInt16 const kSigModel_HealthServer_ID;//                      = 0x0002;
UIKIT_EXTERN UInt16 const kSigModel_HealthClient_ID;//                      = 0x0003;
UIKIT_EXTERN UInt16 const kSigModel_RemoteProvisionServer_ID;//             = 0x0004;
UIKIT_EXTERN UInt16 const kSigModel_RemoteProvisionClient_ID;//             = 0x0005;
// --------
UIKIT_EXTERN UInt16 const kSigModel_GenericOnOffServer_ID;//                = 0x1000;
UIKIT_EXTERN UInt16 const kSigModel_GenericOnOffClient_ID;//                = 0x1001;
UIKIT_EXTERN UInt16 const kSigModel_GenericLevelServer_ID;//                = 0x1002;
UIKIT_EXTERN UInt16 const kSigModel_GenericLevelClient_ID;//                = 0x1003;
UIKIT_EXTERN UInt16 const kSigModel_GenericDefaultTransitionTimeServer_ID;//= 0x1004;
UIKIT_EXTERN UInt16 const kSigModel_GenericDefaultTransitionTimeClient_ID;//= 0x1005;
UIKIT_EXTERN UInt16 const kSigModel_GenericPowerOnOffServer_ID;//           = 0x1006;
UIKIT_EXTERN UInt16 const kSigModel_GenericPowerOnOffSetupServer_ID;//      = 0x1007;
UIKIT_EXTERN UInt16 const kSigModel_GenericPowerOnOffClient_ID;//           = 0x1008;
UIKIT_EXTERN UInt16 const kSigModel_GenericPowerLevelServer_ID;//           = 0x1009;
UIKIT_EXTERN UInt16 const kSigModel_GenericPowerLevelSetupServer_ID;//      = 0x100A;
UIKIT_EXTERN UInt16 const kSigModel_GenericPowerLevelClient_ID;//           = 0x100B;
UIKIT_EXTERN UInt16 const kSigModel_GenericBatteryServer_ID;//              = 0x100C;
UIKIT_EXTERN UInt16 const kSigModel_GenericBatteryClient_ID;//              = 0x100D;
UIKIT_EXTERN UInt16 const kSigModel_GenericLocationServer_ID;//             = 0x100E;
UIKIT_EXTERN UInt16 const kSigModel_GenericLocationSetupServer_ID;//        = 0x100F;
UIKIT_EXTERN UInt16 const kSigModel_GenericLocationClient_ID;//             = 0x1010;
UIKIT_EXTERN UInt16 const kSigModel_GenericAdminPropertyServer_ID;//        = 0x1011;
UIKIT_EXTERN UInt16 const kSigModel_GenericManufacturerPropertyServer_ID;// = 0x1012;
UIKIT_EXTERN UInt16 const kSigModel_GenericUserPropertyServer_ID;//         = 0x1013;
UIKIT_EXTERN UInt16 const kSigModel_GenericClientPropertyServer_ID;//       = 0x1014;
UIKIT_EXTERN UInt16 const kSigModel_GenericPropertyClient_ID;//             = 0x1015;
// --------
UIKIT_EXTERN UInt16 const kSigModel_SensorServer_ID;//                      = 0x1100;
UIKIT_EXTERN UInt16 const kSigModel_SensorSetupServer_ID;//                 = 0x1101;
UIKIT_EXTERN UInt16 const kSigModel_SensorClient_ID;//                      = 0x1102;
// --------
UIKIT_EXTERN UInt16 const kSigModel_TimeServer_ID;//                        = 0x1200;
UIKIT_EXTERN UInt16 const kSigModel_TimeSetupServer_ID;//                   = 0x1201;
UIKIT_EXTERN UInt16 const kSigModel_TimeClient_ID;//                        = 0x1202;
UIKIT_EXTERN UInt16 const kSigModel_SceneServer_ID;//                       = 0x1203;
UIKIT_EXTERN UInt16 const kSigModel_SceneSetupServer_ID;//                  = 0x1204;
UIKIT_EXTERN UInt16 const kSigModel_SceneClient_ID;//                       = 0x1205;
UIKIT_EXTERN UInt16 const kSigModel_SchedulerServer_ID;//                   = 0x1206;
UIKIT_EXTERN UInt16 const kSigModel_SchedulerSetupServer_ID;//              = 0x1207;
UIKIT_EXTERN UInt16 const kSigModel_SchedulerClient_ID;//                   = 0x1208;
// --------
UIKIT_EXTERN UInt16 const kSigModel_LightLightnessServer_ID;//              = 0x1300;
UIKIT_EXTERN UInt16 const kSigModel_LightLightnessSetupServer_ID;//         = 0x1301;
UIKIT_EXTERN UInt16 const kSigModel_LightLightnessClient_ID;//              = 0x1302;
UIKIT_EXTERN UInt16 const kSigModel_LightCTLServer_ID;//                    = 0x1303;
UIKIT_EXTERN UInt16 const kSigModel_LightCTLSetupServer_ID;//               = 0x1304;
UIKIT_EXTERN UInt16 const kSigModel_LightCTLClient_ID;//                    = 0x1305;
UIKIT_EXTERN UInt16 const kSigModel_LightCTLTemperatureServer_ID;//         = 0x1306;
UIKIT_EXTERN UInt16 const kSigModel_LightHSLServer_ID;//                    = 0x1307;
UIKIT_EXTERN UInt16 const kSigModel_LightHSLSetupServer_ID;//               = 0x1308;
UIKIT_EXTERN UInt16 const kSigModel_LightHSLClient_ID;//                    = 0x1309;
UIKIT_EXTERN UInt16 const kSigModel_LightHSLHueServer_ID;//                 = 0x130A;
UIKIT_EXTERN UInt16 const kSigModel_LightHSLSaturationServer_ID;//          = 0x130B;
UIKIT_EXTERN UInt16 const kSigModel_LightxyLServer_ID;//                    = 0x130C;
UIKIT_EXTERN UInt16 const kSigModel_LightxyLSetupServer_ID;//               = 0x130D;
UIKIT_EXTERN UInt16 const kSigModel_LightxyLClient_ID;//                    = 0x130E;
UIKIT_EXTERN UInt16 const kSigModel_LightLCServer_ID;//                     = 0x130F;
UIKIT_EXTERN UInt16 const kSigModel_LightLCSetupServer_ID;//                = 0x1310;
UIKIT_EXTERN UInt16 const kSigModel_LightLCClient_ID;//                     = 0x1311;
// --------
/// - seeAlso: pre-spec OTA model opcode details.pdf  (page.2)
UIKIT_EXTERN UInt16 const kSigModel_FirmwareUpdateServer_ID;//              = 0xFE00;
UIKIT_EXTERN UInt16 const kSigModel_FirmwareUpdateClient_ID;//              = 0xFE01;
UIKIT_EXTERN UInt16 const kSigModel_FirmwareDistributionServer_ID;//        = 0xFE02;
UIKIT_EXTERN UInt16 const kSigModel_FirmwareDistributionClient_ID;//        = 0xFE03;
UIKIT_EXTERN UInt16 const kSigModel_ObjectTransferServer_ID;//              = 0xFF00;
UIKIT_EXTERN UInt16 const kSigModel_ObjectTransferClient_ID;//              = 0xFF01;
UIKIT_EXTERN UInt16 const kSigModel_SubnetBridgeServer_ID;//                = 0xBF32;

UIKIT_EXTERN UInt16 const kSigModel_DF_CFG_S_ID;//                = 0xBF30;
UIKIT_EXTERN UInt16 const kSigModel_DF_CFG_C_ID;//                = 0xBF31;
UIKIT_EXTERN UInt16 const kSigModel_SubnetBridgeServer_ID;//                = 0xBF32;
UIKIT_EXTERN UInt16 const kSigModel_SubnetBridgeClient_ID;//                = 0xBF33;
UIKIT_EXTERN UInt16 const kSigModel_PrivateBeaconServer_ID;//                = 0xBF40;
UIKIT_EXTERN UInt16 const kSigModel_PrivateBeaconClient_ID;//                = 0xBF41;
UIKIT_EXTERN UInt16 const kSigModel_ON_DEMAND_PROXY_S_ID;//                = 0xBF50;
UIKIT_EXTERN UInt16 const kSigModel_ON_DEMAND_PROXY_C_ID;//                = 0xBF51;
UIKIT_EXTERN UInt16 const kSigModel_SAR_CFG_S_ID;//                = 0xBF52;
UIKIT_EXTERN UInt16 const kSigModel_SAR_CFG_C_ID;//                = 0xBF53;
UIKIT_EXTERN UInt16 const kSigModel_OP_AGG_S_ID;//                = 0xBF54;
UIKIT_EXTERN UInt16 const kSigModel_OP_AGG_C_ID;//                = 0xBF55;
UIKIT_EXTERN UInt16 const kSigModel_LARGE_CPS_S_ID;//                = 0xBF56;
UIKIT_EXTERN UInt16 const kSigModel_LARGE_CPS_C_ID;//                = 0xBF57;
UIKIT_EXTERN UInt16 const kSigModel_SOLI_PDU_RPL_CFG_S_ID;//                = 0xBF58;
UIKIT_EXTERN UInt16 const kSigModel_SOLI_PDU_RPL_CFG_C_ID;//                = 0xBF59;

//旧版本使用的key start
UIKIT_EXTERN UInt16 const SIG_MD_G_ONOFF_S;// 0x1000
UIKIT_EXTERN UInt16 const SIG_MD_LIGHTNESS_S;// 0x1300
UIKIT_EXTERN UInt16 const SIG_MD_LIGHT_CTL_S;// 0x1303
UIKIT_EXTERN UInt16 const SIG_MD_LIGHT_CTL_TEMP_S;// 0x1306
UIKIT_EXTERN UInt16 const SIG_MD_LIGHT_HSL_S;// 0x1307
//旧版本使用的key end


UIKIT_EXTERN UInt16 const kMeshAddress_unassignedAddress;// 0x0000
UIKIT_EXTERN UInt16 const kMeshAddress_minUnicastAddress;// 0x0001
UIKIT_EXTERN UInt16 const kMeshAddress_maxUnicastAddress;// 0x7FFF
UIKIT_EXTERN UInt16 const kMeshAddress_minVirtualAddress;// 0x8000
UIKIT_EXTERN UInt16 const kMeshAddress_maxVirtualAddress;// 0xBFFF
UIKIT_EXTERN UInt16 const kMeshAddress_minGroupAddress;// 0xC000
UIKIT_EXTERN UInt16 const kMeshAddress_maxGroupAddress;// 0xFEFF
UIKIT_EXTERN UInt16 const kMeshAddress_allProxies;// 0xFFFC
UIKIT_EXTERN UInt16 const kMeshAddress_allFriends;// 0xFFFD
UIKIT_EXTERN UInt16 const kMeshAddress_allRelays;// 0xFFFE
UIKIT_EXTERN UInt16 const kMeshAddress_allNodes;// 0xFFFF

UIKIT_EXTERN UInt8 const kGetATTListTime;// 5
UIKIT_EXTERN UInt8 const kScanUnprovisionDeviceTimeout;// 10
UIKIT_EXTERN UInt8 const kGetCapabilitiesTimeout;// 5
UIKIT_EXTERN UInt8 const kStartProvisionAndPublicKeyTimeout;// 5
UIKIT_EXTERN UInt8 const kProvisionConfirmationTimeout;// 5
UIKIT_EXTERN UInt8 const kProvisionRandomTimeout;// 5
UIKIT_EXTERN UInt8 const kSentProvisionEncryptedDataWithMicTimeout;// 5
UIKIT_EXTERN UInt8 const kStartMeshConnectTimeout;// 10
UIKIT_EXTERN UInt8 const kProvisioningRecordRequestTimeout;// 10
UIKIT_EXTERN UInt8 const kProvisioningRecordsGetTimeout;// 10

UIKIT_EXTERN UInt8 const kScanNodeIdentityBeforeKeyBindTimeout;// 3

/// publish设置的上报周期
UIKIT_EXTERN UInt8 const kPublishInterval;// 20
/// time model设置的上报周期
UIKIT_EXTERN UInt8 const kTimePublishInterval;// 20
/// 离线检测的时长
UIKIT_EXTERN UInt8 const kOfflineInterval;// = (kPublishInterval * 3 + 1)

/// kCmdReliable_SIGParameters: 1 means send reliable cmd ,and the node will send rsp ,0 means unreliable ,will not send
UIKIT_EXTERN UInt8 const kCmdReliable_SIGParameters;// 1
UIKIT_EXTERN UInt8 const kCmdUnReliable_SIGParameters;// 0

/// Telink默认的企业id
UIKIT_EXTERN UInt16 const kCompanyID;// 0x0211

/// json数据导入本地，本地地址
UIKIT_EXTERN UInt8 const kLocationAddress;// 1
/// json数据生成，生成默认的短地址范围、组地址范围、场景id范围(当前默认一个provisioner，且所有平台使用同一个provisioner)
UIKIT_EXTERN UInt8 const kAllocatedUnicastRangeLowAddress;// 1
UIKIT_EXTERN UInt16 const kAllocatedUnicastRangeHighAddress;// 0x400

UIKIT_EXTERN UInt16 const kAllocatedGroupRangeLowAddress;// 0xC000
UIKIT_EXTERN UInt16 const kAllocatedGroupRangeHighAddress;// 0xC0ff

UIKIT_EXTERN UInt8 const kAllocatedSceneRangeFirstAddress;// 1
UIKIT_EXTERN UInt8 const kAllocatedSceneRangeLastAddress;// 0xf

/// 需要response的指令的默认重试次数，默认为3，客户可修改
UIKIT_EXTERN UInt8 const kAcknowledgeMessageDefaultRetryCount;// 0x3

/*SDK的command list存在需要response的指令，正在等待response或者等待超时。*/
UIKIT_EXTERN UInt32 const kSigMeshLibIsBusyErrorCode;// 0x02110100
UIKIT_EXTERN NSString * const kSigMeshLibIsBusyErrorMessage;// busy

/*当前连接的设备不存在私有特征OnlineStatusCharacteristic*/
UIKIT_EXTERN UInt32 const kSigMeshLibNoFoundOnlineStatusCharacteristicErrorCode;// 0x02110101
UIKIT_EXTERN NSString * const kSigMeshLibNoFoundOnlineStatusCharacteristicErrorMessage;// no found onlineStatus characteristic

/*当前的mesh数据源未创建*/
UIKIT_EXTERN UInt32 const kSigMeshLibNoCreateMeshNetworkErrorCode;// 0x02110102
UIKIT_EXTERN NSString * const kSigMeshLibNoCreateMeshNetworkErrorMessage;// No create mesh

/*当前组号不存在*/
UIKIT_EXTERN UInt32 const kSigMeshLibGroupAddressNoExistErrorCode;// 0x02110103
UIKIT_EXTERN NSString * const kSigMeshLibGroupAddressNoExistErrorMessage;// groupAddress is not exist

/*当前model不存在*/
UIKIT_EXTERN UInt32 const kSigMeshLibModelIDModelNoExistErrorCode;// 0x02110104
UIKIT_EXTERN NSString * const kSigMeshLibModelIDModelNoExistErrorMessage;// modelIDModel is not exist

/*指令超时*/
UIKIT_EXTERN UInt32 const kSigMeshLibCommandTimeoutErrorCode;// 0x02110105
UIKIT_EXTERN NSString * const kSigMeshLibCommandTimeoutErrorMessage;// command is timeout

/*NetKey Index 不存在*/
UIKIT_EXTERN UInt32 const kSigMeshLibCommandInvalidNetKeyIndexErrorCode;// 0x02110106
UIKIT_EXTERN NSString * const kSigMeshLibCommandInvalidNetKeyIndexErrorMessage;// Invalid NetKey Index

/*AppKey Index 不存在*/
UIKIT_EXTERN UInt32 const kSigMeshLibCommandInvalidAppKeyIndexErrorCode;// 0x02110107
UIKIT_EXTERN NSString * const kSigMeshLibCommandInvalidAppKeyIndexErrorMessage;// Invalid AppKey Index

/*telink当前定义的三个设备类型*/
UIKIT_EXTERN UInt16 const SigNodePID_CT;// 1
UIKIT_EXTERN UInt16 const SigNodePID_HSL;// 2
UIKIT_EXTERN UInt16 const SigNodePID_Panel;// 7
UIKIT_EXTERN UInt16 const SigNodePID_LPN;// 0x0201
UIKIT_EXTERN UInt16 const SigNodePID_Switch;// 0x0301

UIKIT_EXTERN float const kCMDInterval;// 0.32
UIKIT_EXTERN float const kSDKLibCommandTimeout;// 1.28

/*读取json里面的mesh数据后，默认新增一个增量128*/
UIKIT_EXTERN UInt32 const kSequenceNumberIncrement;//128

/*初始化json数据时的ivIndex的值*/
UIKIT_EXTERN UInt32 const kDefaultIvIndex;//0x0

/*默认一个unsegmented Access PDU的最大长度，大于该长度则需要进行segment分包，默认值为kUnsegmentedMessageLowerTransportPDUMaxLength（15）*/
UIKIT_EXTERN UInt16 const kUnsegmentedMessageLowerTransportPDUMaxLength;//15

NS_ASSUME_NONNULL_END
