/********************************************************************************************************
 * @file     SigConst.m
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

#import "SigConst.h"

#pragma mark - Const string

NSString * const kTelinkSigMeshLibVersion = @"v3.3.3.5";

NSString * const kNotifyCommandIsBusyOrNot = @"CommandIsBusyOrNot";
NSString * const kCommandIsBusyKey = @"IsBusy";

NSString * const AccessError_invalidSource = @"Local Provisioner does not have Unicast Address specified.";
NSString * const AccessError_invalidElement = @"Element does not belong to the local Node.";
NSString * const AccessError_invalidTtl = @"Invalid TTL.";
NSString * const AccessError_invalidDestination = @"The destination address is unknown.";
NSString * const AccessError_modelNotBoundToAppKey = @"No Application Key bound to the given Model.";
NSString * const AccessError_cannotDelete = @"Cannot delete the last Network Key.";
NSString * const AccessError_timeout = @"Request timed out.";

//service
NSString * const kPBGATTService = @"1827";
NSString * const kPROXYService = @"1828";
//SIGCharacteristicsIDs
NSString * const kPBGATT_Out_CharacteristicsID = @"2ADC";
NSString * const kPBGATT_In_CharacteristicsID = @"2ADB";
NSString * const kPROXY_Out_CharacteristicsID = @"2ADE";
NSString * const kPROXY_In_CharacteristicsID = @"2ADD";
NSString * const kOnlineStatusCharacteristicsID = @"00010203-0405-0607-0809-0A0B0C0D1A11";
/// update firmware
NSString * const kOTA_CharacteristicsID = @"00010203-0405-0607-0809-0A0B0C0D2B12";
NSString * const kMeshOTA_CharacteristicsID = @"00010203-0405-0607-0809-0A0B0C0D7FDF";
NSString * const kFirmwareRevisionCharacteristicsID = @"2A26";

//存储数据的key
//mesh
NSString * const kScanList_key = @"scanList_key";
NSString * const kJsonMeshUUID_key = @"MeshUUID";
NSString * const kCurrenProvisionerUUID_key = @"currenProvisionerUUID_key";
NSString * const kCurrenProvisionerSno_key = @"currenProvisionerSno_key";

//homes
NSString * const kCurrentMeshProvisionAddress_key = @"currentMeshProvisionAddress_key";
//SigScanRspModel
NSString * const kSigScanRspModel_uuid_key = @"sigScanRspModel_uuid_key";
NSString * const kSigScanRspModel_address_key = @"sigScanRspModel_address_key";
NSString * const kSigScanRspModel_mac_key = @"sigScanRspModel_mac_key";
//NSString * const kSigScanRspModel_nodeIdentityData_key = @"sigScanRspModel_nodeIdentityData_key";
//NSString * const kSigScanRspModel_networkIDData_key = @"sigScanRspModel_networkIDData_key";
NSString * const kSigScanRspModel_advertisementDataServiceData_key = @"sigScanRspModel_advertisementDataServiceData_key";
//meshOTA
NSString * const kSaveMeshOTADictKey = @"kSaveMeshOTADictKey";
/*存储在本地的数据的key，不再存储在cache中，以为苹果设备的存储快满的时候，系统会删除cache文件夹的数据*/
NSString * const kSaveLocationDataKey = @"mesh.json";
NSString * const kExtendBearerMode = @"kExtendBearerMode";
UInt8 const kDLEUnsegmentLength = 229;

//oob
NSString * const kSigOOBModel_sourceType_key = @"kSigOOBModel_sourceType_key";
NSString * const kSigOOBModel_UUIDString_key = @"kSigOOBModel_UUIDString_key";
NSString * const kSigOOBModel_OOBString_key = @"kSigOOBModel_OOBString_key";
NSString * const kSigOOBModel_lastEditTimeString_key = @"kSigOOBModel_lastEditTimeString_key";
NSString * const kOOBStoreKey = @"kOOBStoreKey";

NSString * const kFeatureString_relay = @"relay";
NSString * const kFeatureString_proxy = @"proxy";
NSString * const kFeatureString_friend = @"friend";
NSString * const kFeatureString_lowPower = @"lowPower";

//sig model
NSString * const kSigModelGroup_Generic_Describe = @"Generic";
NSString * const kSigModelGroup_Sensors_Describe = @"Sensors";
NSString * const kSigModelGroup_TimeServer_Describe = @"Time Server";
NSString * const kSigModelGroup_Lighting_Describe = @"Lighting";
NSString * const kSigModelGroup_Configuration_Describe = @"Configuration";
NSString * const kSigModelGroup_Health_Describe = @"Health";
NSString * const kSigModelGroup_RemoteProvision_Describe = @"Remote Provision";
NSString * const kSigModelGroup_FirmwareUpdate_Describe = @"Firmware Update";
NSString * const kSigModelGroup_FirmwareDistribution_Describe = @"Firmware Distribution";
NSString * const kSigModelGroup_ObjectTransfer_Describe = @"Object Transfer";
NSString * const kSigModelGroup_DF_CFG_Describe = @"DF_CFG";
NSString * const kSigModelGroup_SubnetBridge_Describe = @"Subnet Bridge";
NSString * const kSigModelGroup_PrivateBeacon_Describe = @"Private Beacon";
NSString * const kSigModelGroup_ON_DEMAND_PROXY_Describe = @"On-demand Proxy";
NSString * const kSigModelGroup_SAR_CFG_Describe = @"SAR Configuration";
NSString * const kSigModelGroup_OP_AGG_Describe = @"Opcodes Aggregator";
NSString * const kSigModelGroup_LARGE_CPS_Describe = @"Large Composition Data";
NSString * const kSigModelGroup_SOLI_PDU_RPL_CFG_Describe = @"Solicitation PDU RPL Configuration";

NSString * const kSigModel_ConfigurationServer_Describe = @"Configuration Server";
NSString * const kSigModel_ConfigurationClient_Describe             = @"Configuration Client";
NSString * const kSigModel_HealthServer_Describe          = @"Health Server";
NSString * const kSigModel_HealthClient_Describe          = @"Health Client";
NSString * const kSigModel_RemoteProvisionServer_Describe     = @"Remote Provision Server";
NSString * const kSigModel_RemoteProvisionClient_Describe     = @"Remote Provision Client";

NSString * const kSigModel_GenericOnOffServer_Describe              = @"Generic OnOff Server";
NSString * const kSigModel_GenericOnOffClient_Describe              = @"Generic OnOff Client";
NSString * const kSigModel_GenericLevelServer_Describe              = @"Generic Level Server";
NSString * const kSigModel_GenericLevelClient_Describe              = @"Generic Level Client";
NSString * const kSigModel_GenericDefaultTransitionTimeServer_Describe   = @"Generic Default Transition Time Server";
NSString * const kSigModel_GenericDefaultTransitionTimeClient_Describe   = @"Generic Default Transition Time Client";
NSString * const kSigModel_GenericPowerOnOffServer_Describe        = @"Generic Power OnOff Server";
NSString * const kSigModel_GenericPowerOnOffSetupServer_Describe  = @"Generic Power OnOff Setup Server";
NSString * const kSigModel_GenericPowerOnOffClient_Describe        = @"Generic Power OnOff Client";
NSString * const kSigModel_GenericPowerLevelServer_Describe        = @"Generic Power Level Server";
NSString * const kSigModel_GenericPowerLevelSetupServer_Describe  = @"Generic Power Level Setup Server";
NSString * const kSigModel_GenericPowerLevelClient_Describe        = @"Generic Power Level Client";
NSString * const kSigModel_GenericBatteryServer_Describe                = @"Generic Battery Server";
NSString * const kSigModel_GenericBatteryClient_Describe                = @"Generic Battery Client";
NSString * const kSigModel_GenericLocationServer_Describe           = @"Generic Location Server";
NSString * const kSigModel_GenericLocationSetupServer_Describe     = @"Generic Location Setup Server";
NSString * const kSigModel_GenericLocationClient_Describe           = @"Generic Location Client";
NSString * const kSigModel_GenericAdminPropertyServer_Describe         = @"Generic Admin Property Server";
NSString * const kSigModel_GenericManufacturerPropertyServer_Describe           = @"Generic Manufacturer Property Server";
NSString * const kSigModel_GenericUserPropertyServer_Describe          = @"Generic User Property Server";
NSString * const kSigModel_GenericClientPropertyServer_Describe        = @"Generic Client Property Server";
NSString * const kSigModel_GenericPropertyClient_Describe               = @"Generic Property Client";
// --------
NSString * const kSigModel_SensorServer_Describe               = @"Sensor Server";
NSString * const kSigModel_SensorSetupServer_Describe         = @"Sensor Setup Server";
NSString * const kSigModel_SensorClient_Describe               = @"Sensor Client";
// --------
NSString * const kSigModel_TimeServer_Describe                 = @"Time Server";
NSString * const kSigModel_TimeSetupServer_Describe           = @"Time Setup Server";
NSString * const kSigModel_TimeClient_Describe                 = @"Time Client";
NSString * const kSigModel_SceneServer_Describe                = @"Scene Server";
NSString * const kSigModel_SceneSetupServer_Describe          = @"Scene Setup Server";
NSString * const kSigModel_SceneClient_Describe                = @"Scene Client";
NSString * const kSigModel_SchedulerServer_Describe                = @"Scheduler Server";
NSString * const kSigModel_SchedulerSetupServer_Describe          = @"Scheduler Setup Server";
NSString * const kSigModel_SchedulerClient_Describe                = @"Scheduler Client";
// --------
NSString * const kSigModel_LightLightnessServer_Describe            = @"Light Lightness Server";
NSString * const kSigModel_LightLightnessSetupServer_Describe      = @"Light Lightness Setup Server";
NSString * const kSigModel_LightLightnessClient_Describe            = @"Light Lightness Client";
NSString * const kSigModel_LightCTLServer_Describe            = @"Light CTL Server";
NSString * const kSigModel_LightCTLSetupServer_Describe      = @"Light CTL Setup Server";
NSString * const kSigModel_LightCTLClient_Describe            = @"Light CTL Client";
NSString * const kSigModel_LightCTLTemperatureServer_Describe       = @"Light CTL Temperature Server";
NSString * const kSigModel_LightHSLServer_Describe            = @"Light HSL Server";
NSString * const kSigModel_LightHSLSetupServer_Describe      = @"Light HSL Setup Server";
NSString * const kSigModel_LightHSLClient_Describe            = @"Light HSL Client";
NSString * const kSigModel_LightHSLHueServer_Describe        = @"Light HSL Hue Server";
NSString * const kSigModel_LightHSLSaturationServer_Describe        = @"Light HSL Saturation Server";
NSString * const kSigModel_LightxyLServer_Describe            = @"Light xyL Server";
NSString * const kSigModel_LightxyLSetupServer_Describe      = @"Light xyL Setup Server";
NSString * const kSigModel_LightxyLClient_Describe            = @"Light xyL Client";
NSString * const kSigModel_LightLCServer_Describe             = @"Light LC Server";
NSString * const kSigModel_LightLCSetupServer_Describe       = @"Light LC Setup Server";
NSString * const kSigModel_LightLCClient_Describe             = @"Light LC Client";
// --------
NSString * const kSigModel_FirmwareUpdateServer_Describe            = @"Firmware Update Server";
NSString * const kSigModel_FirmwareUpdateClient_Describe            = @"Firmware Update Client";
NSString * const kSigModel_FirmwareDistributionServer_Describe         = @"Firmware Distribution Server";
NSString * const kSigModel_FirmwareDistributionClient_Describe         = @"Firmware Distribution Client";
NSString * const kSigModel_ObjectTransferServer_Describe         = @"Object Transfer Server";
NSString * const kSigModel_ObjectTransferClient_Describe         = @"Object Transfer Client";

NSString * const kSigModel_DF_CFG_S_Describe = @"DF_CFG Server";
NSString * const kSigModel_DF_CFG_C_Describe = @"DF_CFG Client";
NSString * const kSigModel_SubnetBridgeServer_Describe = @"Subnet Bridge Server";
NSString * const kSigModel_SubnetBridgeClient_Describe = @"Subnet Bridge Client";
NSString * const kSigModel_PrivateBeaconServer_Describe = @"Private Beacon Server";
NSString * const kSigModel_PrivateBeaconClient_Describe = @"Private Beacon Client";
NSString * const kSigModel_ON_DEMAND_PROXY_S_Describe = @"On-demand Proxy Server";
NSString * const kSigModel_ON_DEMAND_PROXY_C_Describe = @"On-demand Proxy Client";
NSString * const kSigModel_SAR_CFG_S_Describe = @"SAR Configuration Server";
NSString * const kSigModel_SAR_CFG_C_Describe = @"SAR Configuration Client";
NSString * const kSigModel_OP_AGG_S_Describe = @"Opcodes Aggregator Server";
NSString * const kSigModel_OP_AGG_C_Describe = @"Opcodes Aggregator Client";
NSString * const kSigModel_LARGE_CPS_S_Describe = @"Large Composition Data Server";
NSString * const kSigModel_LARGE_CPS_C_Describe = @"Large Composition Data Client";
NSString * const kSigModel_SOLI_PDU_RPL_CFG_S_Describe = @"Solicitation PDU RPL Configuration Server";
NSString * const kSigModel_SOLI_PDU_RPL_CFG_C_Describe = @"Solicitation PDU RPL Configuration Client";


#pragma mark - Const bool

BOOL const kAddNotAdvertisementMac = NO;
BOOL const kSaveMacAddressToJson = YES;


#pragma mark - Const int

UInt16 const CTL_TEMP_MIN = 0x0320;// 800
UInt16 const CTL_TEMP_MAX = 0x4E20;// 20000
UInt8 const TTL_DEFAULT = 10;// max relay count = TTL_DEFAULT - 1
UInt16 const LEVEL_OFF = -32768;
UInt16 const LUM_OFF = 0;

//sig model
UInt16 const kSigModel_ConfigurationServer_ID                = 0x0000;
UInt16 const kSigModel_ConfigurationClient_ID                = 0x0001;
UInt16 const kSigModel_HealthServer_ID                       = 0x0002;
UInt16 const kSigModel_HealthClient_ID                       = 0x0003;
UInt16 const kSigModel_RemoteProvisionServer_ID              = 0x0004;
UInt16 const kSigModel_RemoteProvisionClient_ID              = 0x0005;

UInt16 const kSigModel_GenericOnOffServer_ID                 = 0x1000;
UInt16 const kSigModel_GenericOnOffClient_ID                 = 0x1001;
UInt16 const kSigModel_GenericLevelServer_ID                 = 0x1002;
UInt16 const kSigModel_GenericLevelClient_ID                 = 0x1003;
UInt16 const kSigModel_GenericDefaultTransitionTimeServer_ID = 0x1004;
UInt16 const kSigModel_GenericDefaultTransitionTimeClient_ID = 0x1005;
UInt16 const kSigModel_GenericPowerOnOffServer_ID            = 0x1006;
UInt16 const kSigModel_GenericPowerOnOffSetupServer_ID       = 0x1007;
UInt16 const kSigModel_GenericPowerOnOffClient_ID            = 0x1008;
UInt16 const kSigModel_GenericPowerLevelServer_ID            = 0x1009;
UInt16 const kSigModel_GenericPowerLevelSetupServer_ID       = 0x100A;
UInt16 const kSigModel_GenericPowerLevelClient_ID            = 0x100B;
UInt16 const kSigModel_GenericBatteryServer_ID               = 0x100C;
UInt16 const kSigModel_GenericBatteryClient_ID               = 0x100D;
UInt16 const kSigModel_GenericLocationServer_ID              = 0x100E;
UInt16 const kSigModel_GenericLocationSetupServer_ID         = 0x100F;
UInt16 const kSigModel_GenericLocationClient_ID              = 0x1010;
UInt16 const kSigModel_GenericAdminPropertyServer_ID         = 0x1011;
UInt16 const kSigModel_GenericManufacturerPropertyServer_ID  = 0x1012;
UInt16 const kSigModel_GenericUserPropertyServer_ID          = 0x1013;
UInt16 const kSigModel_GenericClientPropertyServer_ID        = 0x1014;
UInt16 const kSigModel_GenericPropertyClient_ID              = 0x1015;
// --------
UInt16 const kSigModel_SensorServer_ID                       = 0x1100;
UInt16 const kSigModel_SensorSetupServer_ID                  = 0x1101;
UInt16 const kSigModel_SensorClient_ID                       = 0x1102;
// --------
UInt16 const kSigModel_TimeServer_ID                         = 0x1200;
UInt16 const kSigModel_TimeSetupServer_ID                    = 0x1201;
UInt16 const kSigModel_TimeClient_ID                         = 0x1202;
UInt16 const kSigModel_SceneServer_ID                        = 0x1203;
UInt16 const kSigModel_SceneSetupServer_ID                   = 0x1204;
UInt16 const kSigModel_SceneClient_ID                        = 0x1205;
UInt16 const kSigModel_SchedulerServer_ID                    = 0x1206;
UInt16 const kSigModel_SchedulerSetupServer_ID               = 0x1207;
UInt16 const kSigModel_SchedulerClient_ID                    = 0x1208;
// --------
UInt16 const kSigModel_LightLightnessServer_ID               = 0x1300;
UInt16 const kSigModel_LightLightnessSetupServer_ID          = 0x1301;
UInt16 const kSigModel_LightLightnessClient_ID               = 0x1302;
UInt16 const kSigModel_LightCTLServer_ID                     = 0x1303;
UInt16 const kSigModel_LightCTLSetupServer_ID                = 0x1304;
UInt16 const kSigModel_LightCTLClient_ID                     = 0x1305;
UInt16 const kSigModel_LightCTLTemperatureServer_ID          = 0x1306;
UInt16 const kSigModel_LightHSLServer_ID                     = 0x1307;
UInt16 const kSigModel_LightHSLSetupServer_ID                = 0x1308;
UInt16 const kSigModel_LightHSLClient_ID                     = 0x1309;
UInt16 const kSigModel_LightHSLHueServer_ID                  = 0x130A;
UInt16 const kSigModel_LightHSLSaturationServer_ID           = 0x130B;
UInt16 const kSigModel_LightxyLServer_ID                     = 0x130C;
UInt16 const kSigModel_LightxyLSetupServer_ID                = 0x130D;
UInt16 const kSigModel_LightxyLClient_ID                     = 0x130E;
UInt16 const kSigModel_LightLCServer_ID                      = 0x130F;
UInt16 const kSigModel_LightLCSetupServer_ID                 = 0x1310;
UInt16 const kSigModel_LightLCClient_ID                      = 0x1311;
// --------
UInt16 const kSigModel_FirmwareUpdateServer_ID               = 0xFE00;
UInt16 const kSigModel_FirmwareUpdateClient_ID               = 0xFE01;
UInt16 const kSigModel_FirmwareDistributionServer_ID         = 0xFE02;
UInt16 const kSigModel_FirmwareDistributionClient_ID         = 0xFE03;
UInt16 const kSigModel_ObjectTransferServer_ID               = 0xFF00;
UInt16 const kSigModel_ObjectTransferClient_ID               = 0xFF01;
// --------
UInt16 const kSigModel_DF_CFG_S_ID                 = 0xBF30;
UInt16 const kSigModel_DF_CFG_C_ID                 = 0xBF31;
UInt16 const kSigModel_SubnetBridgeServer_ID                 = 0xBF32;
UInt16 const kSigModel_SubnetBridgeClient_ID                 = 0xBF33;
UInt16 const kSigModel_PrivateBeaconServer_ID                 = 0xBF40;
UInt16 const kSigModel_PrivateBeaconClient_ID                 = 0xBF41;
UInt16 const kSigModel_ON_DEMAND_PROXY_S_ID                 = 0xBF50;
UInt16 const kSigModel_ON_DEMAND_PROXY_C_ID                 = 0xBF51;
UInt16 const kSigModel_SAR_CFG_S_ID                 = 0xBF52;
UInt16 const kSigModel_SAR_CFG_C_ID                 = 0xBF53;
UInt16 const kSigModel_OP_AGG_S_ID                 = 0xBF54;
UInt16 const kSigModel_OP_AGG_C_ID                 = 0xBF55;
UInt16 const kSigModel_LARGE_CPS_S_ID                 = 0xBF56;
UInt16 const kSigModel_LARGE_CPS_C_ID                 = 0xBF57;
UInt16 const kSigModel_SOLI_PDU_RPL_CFG_S_ID                 = 0xBF58;
UInt16 const kSigModel_SOLI_PDU_RPL_CFG_C_ID                 = 0xBF59;
// --------


//旧版本使用的key start
UInt16 const SIG_MD_G_ONOFF_S              = 0x1000;
UInt16 const SIG_MD_LIGHTNESS_S            = 0x1300;
UInt16 const SIG_MD_LIGHT_CTL_S            = 0x1303;
UInt16 const SIG_MD_LIGHT_CTL_TEMP_S       = 0x1306;
UInt16 const SIG_MD_LIGHT_HSL_S            = 0x1307;
//旧版本使用的key end

UInt16 const kMeshAddress_unassignedAddress = 0x0000;
UInt16 const kMeshAddress_minUnicastAddress = 0x0001;
UInt16 const kMeshAddress_maxUnicastAddress = 0x7FFF;
UInt16 const kMeshAddress_minVirtualAddress = 0x8000;
UInt16 const kMeshAddress_maxVirtualAddress = 0xBFFF;
UInt16 const kMeshAddress_minGroupAddress   = 0xC000;
UInt16 const kMeshAddress_maxGroupAddress   = 0xFEFF;
UInt16 const kMeshAddress_allProxies        = 0xFFFC;
UInt16 const kMeshAddress_allFriends        = 0xFFFD;
UInt16 const kMeshAddress_allRelays         = 0xFFFE;
UInt16 const kMeshAddress_allNodes          = 0xFFFF;

UInt8 const kGetATTListTime = 5;
UInt8 const kScanUnprovisionDeviceTimeout = 10;
UInt8 const kGetCapabilitiesTimeout = 5;
UInt8 const kStartProvisionAndPublicKeyTimeout = 5;
UInt8 const kProvisionConfirmationTimeout = 5;
UInt8 const kProvisionRandomTimeout = 5;
UInt8 const kSentProvisionEncryptedDataWithMicTimeout = 5;
UInt8 const kStartMeshConnectTimeout = 5;
UInt8 const kProvisioningRecordRequestTimeout = 10;
UInt8 const kProvisioningRecordsGetTimeout = 10;

UInt8 const kScanNodeIdentityBeforeKeyBindTimeout = 3;

//publish设置的上报周期
UInt8 const kPublishInterval = 20;
//time model设置的上报周期
UInt8 const kTimePublishInterval = 30;
//离线检测的时长
UInt8 const kOfflineInterval = (kPublishInterval * 3 + 1);

//kCmdReliable_SIGParameters: 1 means send reliable cmd ,and the node will send rsp ,0 means unreliable ,will not send
UInt8 const kCmdReliable_SIGParameters = 1;
UInt8 const kCmdUnReliable_SIGParameters = 0;

//Telink默认的企业id
UInt16 const kCompanyID = 0x0211;

//json数据导入本地，本地地址
UInt8 const kLocationAddress = 1;
//json数据生成，生成默认的短地址范围、组地址范围、场景id范围(当前默认一个provisioner，且所有平台使用同一个provisioner)
UInt8 const kAllocatedUnicastRangeLowAddress = 1;
UInt16 const kAllocatedUnicastRangeHighAddress = 0x400;//1024

UInt16 const kAllocatedGroupRangeLowAddress = 0xC000;
UInt16 const kAllocatedGroupRangeHighAddress = 0xC0ff;

UInt8 const kAllocatedSceneRangeFirstAddress = 1;
UInt8 const kAllocatedSceneRangeLastAddress = 0xf;

//需要response的指令的默认重试次数，默认为2，客户可修改
UInt8 const kAcknowledgeMessageDefaultRetryCount = 0x2;

/*SDK的command list存在需要response的指令，正在等待response或者等待超时。*/
UInt32 const kSigMeshLibIsBusyErrorCode = 0x02110100;
NSString * const kSigMeshLibIsBusyErrorMessage = @"SDK is busy, because SigMeshLib.share.commands.count isn't empty.";

/*当前连接的设备不存在私有特征OnlineStatusCharacteristic*/
UInt32 const kSigMeshLibNoFoundOnlineStatusCharacteristicErrorCode = 0x02110101;
NSString * const kSigMeshLibNoFoundOnlineStatusCharacteristicErrorMessage = @"No found, because current device no found onlineStatusCharacteristic.";

/*当前的mesh数据源未创建*/
UInt32 const kSigMeshLibNoCreateMeshNetworkErrorCode = 0x02110102;
NSString * const kSigMeshLibNoCreateMeshNetworkErrorMessage = @"No create, because current meshNetwork is nil.";

/*当前组号不存在*/
UInt32 const kSigMeshLibGroupAddressNoExistErrorCode = 0x02110103;
NSString * const kSigMeshLibGroupAddressNoExistErrorMessage = @"No exist, because groupAddress is not exist.";

/*当前model不存在*/
UInt32 const kSigMeshLibModelIDModelNoExistErrorCode = 0x02110104;
NSString * const kSigMeshLibModelIDModelNoExistErrorMessage = @"No exist, because modelIDModel is not exist.";

/*指令超时*/
UInt32 const kSigMeshLibCommandTimeoutErrorCode = 0x02110105;
NSString * const kSigMeshLibCommandTimeoutErrorMessage = @"stop wait response, because command is timeout.";

/*NetKey Index 不存在*/
UInt32 const kSigMeshLibCommandInvalidNetKeyIndexErrorCode = 0x02110106;
NSString * const kSigMeshLibCommandInvalidNetKeyIndexErrorMessage = @"Invalid NetKey Index.";

/*AppKey Index 不存在*/
UInt32 const kSigMeshLibCommandInvalidAppKeyIndexErrorCode = 0x02110107;
NSString * const kSigMeshLibCommandInvalidAppKeyIndexErrorMessage = @"Invalid AppKey Index.";

/*telink当前定义的两个设备类型*/
UInt16 const SigNodePID_CT = 1;
UInt16 const SigNodePID_HSL = 2;
UInt16 const SigNodePID_Panel = 7;
UInt16 const SigNodePID_LPN = 0x0201;
UInt16 const SigNodePID_Switch = 0x0301;

float const kCMDInterval = 0.32;
float const kSDKLibCommandTimeout = 1.28;

/*读取json里面的mesh数据后，默认新增一个增量128; SequenceNumber增加这个增量后存储一次本地json(当前只存储手机本地，无需存储在json)*/
UInt32 const kSequenceNumberIncrement = 128;

/*初始化json数据时的ivIndex的值*/
UInt32 const kDefaultIvIndex = 0x0;//0x0

/*默认一个unsegmented Access PDU的最大长度，大于该长度则需要进行segment分包，默认值为kUnsegmentedMessageLowerTransportPDUMaxLength（15）*/
UInt16 const kUnsegmentedMessageLowerTransportPDUMaxLength = 15;//15
