/********************************************************************************************************
 * @file     SigModel.h
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

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@class SigNetkeyDerivaties,OpenSSLHelper,SigRangeModel,SigSceneRangeModel,SigNodeFeatures,SigRelayretransmitModel,SigNetworktransmitModel,SigElementModel,SigNodeKeyModel,SigModelIDModel,SigRetransmitModel,SigPeriodModel,SigHeartbeatPubModel,SigHeartbeatSubModel,SigBaseMeshMessage,SigConfigNetworkTransmitSet,SigConfigNetworkTransmitStatus,SigPublishModel,SigNodeModel,SigMeshMessage,SigNetkeyModel,SigAppkeyModel,SigIvIndex,SigPage0,SigSubnetBridgeModel,SigMeshAddress;
typedef void(^BeaconBackCallBack)(BOOL available);
typedef void(^responseAllMessageBlock)(UInt16 source,UInt16 destination,SigMeshMessage *responseMessage);

// callback about SigBluetooth
typedef void(^bleInitSuccessCallback)(CBCentralManager *central);
typedef void(^bleCentralUpdateStateCallback)(CBCentralManagerState state);
typedef void(^bleEnableCallback)(CBCentralManager *central,BOOL enable);
typedef void(^bleScanPeripheralCallback)(CBPeripheral *peripheral, NSDictionary<NSString *, id> *advertisementData, NSNumber *RSSI, BOOL unprovisioned);
typedef void(^bleScanSpecialPeripheralCallback)(CBPeripheral *peripheral, NSDictionary<NSString *, id> *advertisementData, NSNumber *RSSI, BOOL successful);
typedef void(^bleConnectPeripheralCallback)(CBPeripheral *peripheral,BOOL successful);
typedef void(^bleDiscoverServicesCallback)(CBPeripheral *peripheral,BOOL successful);
//typedef void(^bleChangeNotifyCallback)(CBPeripheral *peripheral,BOOL isNotifying);
typedef void(^bleCharacteristicResultCallback)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError * _Nullable error);

typedef void(^bleReadOTACharachteristicCallback)(CBCharacteristic *characteristic,BOOL successful);
typedef void(^bleCancelConnectCallback)(CBPeripheral *peripheral,BOOL successful);
typedef void(^bleCancelAllConnectCallback)(void);
typedef void(^bleDisconnectCallback)(CBPeripheral *peripheral,NSError *error);
typedef void(^bleIsReadyToSendWriteWithoutResponseCallback)(CBPeripheral *peripheral);
typedef void(^bleDidUpdateValueForCharacteristicCallback)(CBPeripheral *peripheral,CBCharacteristic *characteristic, NSError * _Nullable error);
typedef void(^bleDidWriteValueForCharacteristicCallback)(CBPeripheral *peripheral,CBCharacteristic *characteristic, NSError * _Nullable error);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
typedef void(^openChannelResultCallback)(CBPeripheral *peripheral,CBL2CAPChannel * _Nullable channel,NSError * _Nullable error);
#pragma clang diagnostic pop

@interface SigModel : NSObject
@end


@interface ModelIDModel : SigModel
@property (nonatomic,strong) NSString *modelGroup;
@property (nonatomic,strong) NSString *modelName;
@property (nonatomic,assign) NSInteger sigModelID;

-(instancetype)initWithModelGroup:(NSString *)modelGroup modelName:(NSString *)modelName sigModelID:(NSInteger)sigModelID;

@end


@interface ModelIDs : SigModel
@property (nonatomic,strong) NSArray <ModelIDModel *>*modelIDs;//所有的modelID
@property (nonatomic,strong) NSArray <ModelIDModel *>*defaultModelIDs;//默认keyBind的modelID
@end


@interface Groups : SigModel
@property (nonatomic,assign) NSInteger groupCount;
@property (nonatomic,strong) NSString *name1;
@property (nonatomic,strong) NSString *name2;
@property (nonatomic,strong) NSString *name3;
@property (nonatomic,strong) NSString *name4;
@property (nonatomic,strong) NSString *name5;
@property (nonatomic,strong) NSString *name6;
@property (nonatomic,strong) NSString *name7;
@property (nonatomic,strong) NSString *name8;
@property (nonatomic,strong) NSArray <NSString *>*names;
@end


@interface SchedulerModel : SigModel<NSCopying>
@property (nonatomic,assign) UInt64 schedulerID;//4 bits, Enumerates (selects) a Schedule Register entry. The valid values for the Index field are 0x0-0xF.
@property (nonatomic,assign) UInt64 year;
@property (nonatomic,assign) UInt64 month;
@property (nonatomic,assign) UInt64 day;
@property (nonatomic,assign) UInt64 hour;
@property (nonatomic,assign) UInt64 minute;
@property (nonatomic,assign) UInt64 second;
@property (nonatomic,assign) UInt64 week;
@property (nonatomic,assign) SchedulerType action;
@property (nonatomic,assign) UInt64 transitionTime;
@property (nonatomic,assign) UInt64 schedulerData;
@property (nonatomic,assign) UInt64 sceneId;

- (NSDictionary *)getDictionaryOfSchedulerModel;
- (void)setDictionaryToSchedulerModel:(NSDictionary *)dictionary;

@end


/// 缓存蓝牙扫描回调的模型，uuid(peripheral.identifier.UUIDString)为唯一标识符。
@interface SigScanRspModel : NSObject
@property (nonatomic, strong) NSData *advertisementDataServiceData;
//@property (nonatomic, strong) NSData *nodeIdentityData;//byte[0]:type=0x01,byte[1~17]:data
//@property (nonatomic, strong) NSData *networkIDData;//byte[0]:type=0x00,byte[1~9]:data
@property (nonatomic, strong) NSString *macAddress;
@property (nonatomic, assign) UInt16 CID;//企业ID，默认为0x0211，十进制为529.
@property (nonatomic, assign) UInt16 PID;//产品ID，CT灯为1，面板panel为7.
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) UInt16 address;
@property (nonatomic, strong) NSString *advName;//广播包中的CBAdvertisementDataLocalNameKey
@property (nonatomic, strong) NSString *advUuid;//未添加的设备广播包中的CBAdvertisementDataServiceDataKey中的UUID（bytes:0-15），cid和pid为其前四个字节
@property (nonatomic, assign) struct OobInformation advOobInformation;//未添加的设备广播包中的CBAdvertisementDataServiceDataKey中的oob信息（bytes:16-17）
@property (nonatomic, strong) NSDictionary<NSString *,id> *advertisementData;//扫描到的蓝牙设备广播包完整数据
@property (nonatomic, assign) BOOL provisioned;//YES表示已经入网。

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData;
- (SigIdentificationType)getIdentificationType;

@end


//缓存Remot add扫描回调的模型
@interface SigRemoteScanRspModel : NSObject
@property (nonatomic, assign) UInt16 reportNodeAddress;
@property (nonatomic, strong) NSData *reportNodeUUID;
@property (nonatomic, assign) int RSSI;//负值
@property (nonatomic, assign) struct OobInformation oob;
@property (nonatomic, strong) NSString *macAddress;
- (instancetype)initWithParameters:(NSData *)parameters;
//- (instancetype)initWithPar:(UInt8 *)par len:(UInt8)len;
@end


@interface AddDeviceModel : SigModel
@property (nonatomic, strong) SigScanRspModel *scanRspModel;
@property (nonatomic, assign) AddDeviceModelState state;
- (instancetype)initWithRemoteScanRspModel:(SigRemoteScanRspModel *)scanRemoteModel;
@end

@interface PublishResponseModel : NSObject
@property (nonatomic, assign) UInt8 status;
@property (nonatomic, assign) UInt16 elementAddress;
@property (nonatomic, assign) UInt16 publishAddress;
@property (nonatomic, assign) UInt16 appKeyIndex;
@property (nonatomic, assign) UInt8 credentialFlag;
@property (nonatomic, assign) UInt8 RFU;
@property (nonatomic, assign) UInt8 publishTTL;
@property (nonatomic, assign) UInt8 publishPeriod;
@property (nonatomic, assign) UInt8 publishRetransmitCount;
@property (nonatomic, assign) UInt8 publishRetransmitIntervalSteps;
@property (nonatomic, assign) BOOL isVendorModelID;
@property (nonatomic, assign) UInt32 modelIdentifier;

- (instancetype)initWithResponseData:(NSData *)rspData;

@end

@interface ActionModel : SigModel
@property (nonatomic,assign) UInt16 address;
@property (nonatomic,assign) DeviceState state;
@property (nonatomic,assign) UInt8 trueBrightness;//1-100
@property (nonatomic,assign) UInt8 trueTemperature;//0-100
- (instancetype)initWithNode:(SigNodeModel *)node;
- (BOOL)isSameActionWithAction:(ActionModel *)action;
- (NSDictionary *)getDictionaryOfActionModel;
- (void)setDictionaryToActionModel:(NSDictionary *)dictionary;
@end


static Byte CTByte[] = {(Byte) 0x11, (Byte) 0x02, (Byte) 0x01, (Byte) 0x00, (Byte) 0x32, (Byte) 0x37, (Byte) 0x69, (Byte) 0x00, (Byte) 0x07, (Byte) 0x00, (Byte) 0x00, (Byte) 0x00, (Byte) 0x19, (Byte) 0x01, (Byte) 0x00, (Byte) 0x00, (Byte) 0x02, (Byte) 0x00, (Byte) 0x03, (Byte) 0x00, (Byte) 0x04, (Byte) 0x00, (Byte) 0x05, (Byte) 0x00, (Byte) 0x00, (Byte) 0xfe, (Byte) 0x01, (Byte) 0xfe, (Byte) 0x02, (Byte) 0xfe, (Byte) 0x00, (Byte) 0xff, (Byte) 0x01, (Byte) 0xff, (Byte) 0x00, (Byte) 0x12, (Byte) 0x01, (Byte) 0x12, (Byte) 0x00, (Byte) 0x10, (Byte) 0x02, (Byte) 0x10, (Byte) 0x04, (Byte) 0x10, (Byte) 0x06, (Byte) 0x10, (Byte) 0x07, (Byte) 0x10, (Byte) 0x03, (Byte) 0x12, (Byte) 0x04, (Byte) 0x12, (Byte) 0x06, (Byte) 0x12, (Byte) 0x07, (Byte) 0x12, (Byte) 0x00, (Byte) 0x13, (Byte) 0x01, (Byte) 0x13, (Byte) 0x03, (Byte) 0x13, (Byte) 0x04, (Byte) 0x13, (Byte) 0x11, (Byte) 0x02, (Byte) 0x00, (Byte) 0x00, (Byte) 0x00, (Byte) 0x00, (Byte) 0x02, (Byte) 0x00, (Byte) 0x02, (Byte) 0x10, (Byte) 0x06, (Byte) 0x13};
static Byte HSLByte[] = {(Byte) 0x11, (Byte) 0x02, (Byte) 0x02, (Byte) 0x00, (Byte) 0x33, (Byte) 0x33, (Byte) 0x69, (Byte) 0x00, (Byte) 0x07, (Byte) 0x00, (Byte) 0x00, (Byte) 0x00, (Byte) 0x0E, (Byte) 0x01, (Byte) 0x00, (Byte) 0x00, (Byte) 0x02, (Byte) 0x00, (Byte) 0x03, (Byte) 0x00, (Byte) 0x00, (Byte) 0xFE, (Byte) 0x00, (Byte) 0xFF, (Byte) 0x00, (Byte) 0x10, (Byte) 0x02, (Byte) 0x10, (Byte) 0x04, (Byte) 0x10, (Byte) 0x06, (Byte) 0x10, (Byte) 0x07, (Byte) 0x10, (Byte) 0x00, (Byte) 0x13, (Byte) 0x01, (Byte) 0x13, (Byte) 0x07, (Byte) 0x13, (Byte) 0x08, (Byte) 0x13, (Byte) 0x11, (Byte) 0x02, (Byte) 0x00, (Byte) 0x00, (Byte) 0x00, (Byte) 0x00, (Byte) 0x02, (Byte) 0x00, (Byte) 0x02, (Byte) 0x10, (Byte) 0x0A, (Byte) 0x13, (Byte) 0x00, (Byte) 0x00, (Byte) 0x02, (Byte) 0x00, (Byte) 0x02, (Byte) 0x10, (Byte) 0x0B, (Byte) 0x13};
static Byte PanelByte[] = {(Byte) 0x11, (Byte) 0x02, (Byte) 0x07, (Byte) 0x00, (Byte) 0x32, (Byte) 0x37, (Byte) 0x69, (Byte) 0x00, (Byte) 0x07, (Byte) 0x00, (Byte) 0x00, (Byte) 0x00, (Byte) 0x11, (Byte) 0x02, (Byte) 0x00, (Byte) 0x00, (Byte) 0x02, (Byte) 0x00, (Byte) 0x03, (Byte) 0x00, (Byte) 0x04, (Byte) 0x00, (Byte) 0x05, (Byte) 0x00, (Byte) 0x00, (Byte) 0xfe, (Byte) 0x01, (Byte) 0xfe, (Byte) 0x02, (Byte) 0xfe, (Byte) 0x00, (Byte) 0xff, (Byte) 0x01, (Byte) 0xff, (Byte) 0x00, (Byte) 0x12, (Byte) 0x01, (Byte) 0x12, (Byte) 0x00, (Byte) 0x10, (Byte) 0x03, (Byte) 0x12, (Byte) 0x04, (Byte) 0x12, (Byte) 0x06, (Byte) 0x12, (Byte) 0x07, (Byte) 0x12, (Byte) 0x11, (Byte) 0x02, (Byte) 0x00, (Byte) 0x00, (Byte) 0x11, (Byte) 0x02, (Byte) 0x01, (Byte) 0x00, (Byte) 0x00, (Byte) 0x00, (Byte) 0x05, (Byte) 0x01, (Byte) 0x00, (Byte) 0x10, (Byte) 0x03, (Byte) 0x12, (Byte) 0x04, (Byte) 0x12, (Byte) 0x06, (Byte) 0x12, (Byte) 0x07, (Byte) 0x12, (Byte) 0x11, (Byte) 0x02, (Byte) 0x00, (Byte) 0x00, (Byte) 0x00, (Byte) 0x00, (Byte) 0x05, (Byte) 0x01, (Byte) 0x00, (Byte) 0x10, (Byte) 0x03, (Byte) 0x12, (Byte) 0x04, (Byte) 0x12, (Byte) 0x06, (Byte) 0x12, (Byte) 0x07, (Byte) 0x12, (Byte) 0x11, (Byte) 0x02, (Byte) 0x00, (Byte) 0x00};
static Byte LPNByte[] = {(Byte) 0x11, (Byte) 0x02, (Byte) 0x01, (Byte) 0x02, (Byte) 0x33, (Byte) 0x33, (Byte) 0x69, (Byte) 0x00, (Byte) 0x0a, (Byte) 0x00, (Byte) 0x00, (Byte) 0x00, (Byte) 0x05, (Byte) 0x01, (Byte) 0x00, (Byte) 0x00, (Byte) 0x02, (Byte) 0x00, (Byte) 0x03, (Byte) 0x00, (Byte) 0x00, (Byte) 0x10, (Byte) 0x02, (Byte) 0x10, (Byte) 0x11, (Byte) 0x02, (Byte) 0x00, (Byte) 0x00};

@interface DeviceTypeModel : SigModel
@property (nonatomic, assign) UInt16 CID;
@property (nonatomic, assign) UInt16 PID;
@property (nonatomic, strong) SigPage0 *defaultCompositionData;

- (instancetype)initWithCID:(UInt16)cid PID:(UInt16)pid;
- (instancetype)initWithCID:(UInt16)cid PID:(UInt16)pid compositionData:(NSData *)cpsData;
- (void)setCompositionData:(NSData *)compositionData;

@end


@interface SigAddConfigModel : SigModel
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, assign) UInt16 unicastAddress;
@property (nonatomic, strong) NSData *networkKey;
@property (nonatomic, assign) UInt16 netkeyIndex;
@property (nonatomic, strong) NSData *appKey;
@property (nonatomic, assign) UInt16 appkeyIndex;
@property (nonatomic, assign) ProvisionType provisionType;
@property (nonatomic, strong) NSData *staticOOBData;
@property (nonatomic, assign) KeyBindType keyBindType;
@property (nonatomic, assign) UInt16 productID;
@property (nonatomic, strong) NSData *cpsData;

- (instancetype)initWithCBPeripheral:(CBPeripheral *)peripheral unicastAddress:(UInt16)unicastAddress networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex appKey:(NSData *)appkey appkeyIndex:(UInt16)appkeyIndex provisionType:(ProvisionType)provisionType staticOOBData:(NSData *)staticOOBData keyBindType:(KeyBindType)keyBindType productID:(UInt16)productID cpsData:(NSData *)cpsData;

@end


/// sig model struct: mesh_bulk_cmd_par_t, vendor model struct: mesh_vendor_par_ini_t. It is sig model command when vendorId is 0, and It is vendor model command when vendorId isn't 0. sig model config: netkeyIndex, appkeyIndex, retryCount, responseMax, address, opcode, commandData.
@interface IniCommandModel : SigModel
@property (nonatomic, assign) UInt16 netkeyIndex;
@property (nonatomic, assign) UInt16 appkeyIndex;
@property (nonatomic, assign) UInt8 retryCount;// only for reliable command
@property (nonatomic, assign) UInt8 responseMax;// only for reliable command
@property (nonatomic, assign) UInt16 address;
@property (nonatomic, strong) SigMeshAddress *meshAddressModel;// may be Uint16 or 16 bytes Label UUID.
@property (nonatomic, assign) UInt16 opcode;// SigGenericOnOffSet:0x8202. SigGenericOnOffSetUnacknowledged:0x8203. VendorOnOffSet:0xC4, VendorOnOffSetUnacknowledged:0xC3.
@property (nonatomic, assign) UInt16 vendorId;// 0 means sig model command, other means vendor model command.
@property (nonatomic, assign) UInt8 responseOpcode;// response of VendorOnOffSet:0xC4.
@property (nonatomic, assign) BOOL needTid;
@property (nonatomic, assign) UInt8 tidPosition;
@property (nonatomic, assign) UInt8 tid;
@property (nonatomic, strong, nullable) NSData *commandData;//max length is MESH_CMD_ACCESS_LEN_MAX. SigGenericOnOffSet: commandData of turn on without TransitionTime and delay is {0x01,0x00,0x00}. commandData of turn off without TransitionTime and delay is {0x00,0x00,0x00}

@property (nonatomic, copy) responseAllMessageBlock responseCallBack;
@property (nonatomic, assign) BOOL hasReceiveResponse;

//这3个参数的作用是配置当前SDKLibCommand指令实际使用到的key和ivIndex，只有fastProvision流程使用了特殊的key和ivIndex，其它指令使用默认值。
@property (nonatomic,strong) SigNetkeyModel *curNetkey;
@property (nonatomic,strong) SigAppkeyModel *curAppkey;
@property (nonatomic,strong) SigIvIndex *curIvIndex;
@property (nonatomic,assign) NSTimeInterval timeout;

@property (nonatomic,assign) BOOL isEncryptByDeviceKey;// default is NO.

/// create sig model ini command
- (instancetype)initSigModelIniCommandWithNetkeyIndex:(UInt16)netkeyIndex appkeyIndex:(UInt16)appkeyIndex retryCount:(UInt8)retryCount responseMax:(UInt8)responseMax address:(UInt16)address opcode:(UInt16)opcode commandData:(NSData *)commandData;
/// create vebdor model ini command
- (instancetype)initVendorModelIniCommandWithNetkeyIndex:(UInt16)netkeyIndex appkeyIndex:(UInt16)appkeyIndex retryCount:(UInt8)retryCount responseMax:(UInt8)responseMax address:(UInt16)address opcode:(UInt8)opcode vendorId:(UInt16)vendorId responseOpcode:(UInt8)responseOpcode tidPosition:(UInt8)tidPosition tid:(UInt8)tid commandData:(nullable NSData *)commandData;
- (instancetype)initVendorModelIniCommandWithNetkeyIndex:(UInt16)netkeyIndex appkeyIndex:(UInt16)appkeyIndex retryCount:(UInt8)retryCount responseMax:(UInt8)responseMax address:(UInt16)address opcode:(UInt8)opcode vendorId:(UInt16)vendorId responseOpcode:(UInt8)responseOpcode needTid:(BOOL)needTid tid:(UInt8)tid commandData:(nullable NSData *)commandData;
/// create model by ini data
/// @param iniCommandData ini data, eg: "a3ff000000000200ffffc21102c4020100"
- (instancetype)initWithIniCommandData:(NSData *)iniCommandData;

@end


@interface SigUpdatingNodeEntryModel : SigModel
/// least significant bits of the unicast address of the Updating node. Size is 15 bits.
@property (nonatomic, assign) UInt16 address;
/// Retrieved Update Phase state of the Updating node. Size is 4 bits.
@property (nonatomic, assign) SigFirmwareUpdatePhaseType retrievedUpdatePhase;
/// Status of the last operation with the Firmware Update Server. Size is 3 bits.
@property (nonatomic, assign) SigFirmwareUpdateServerAndClientModelStatusType updateStatus;
/// Status of the last operation with the BLOB Transfer Server. Size is 4 bits.
@property (nonatomic, assign) SigBLOBTransferStatusType transferStatus;
/// Progress of the BLOB transfer in 2 percent increments. Size is 6 bits.
@property (nonatomic, assign) UInt8 transferProgress;
/// Index of the firmware image on the Firmware Information List state that is being updated. Size is 8 bits.
@property (nonatomic, assign) UInt8 updateFirmwareImageIndex;

@property (nonatomic, strong) NSData *parameters;
- (instancetype)initWithAddress:(UInt16)address retrievedUpdatePhase:(SigFirmwareUpdatePhaseType)retrievedUpdatePhase updateStatus:(SigFirmwareUpdateServerAndClientModelStatusType)updateStatus transferStatus:(SigBLOBTransferStatusType)transferStatus transferProgress:(UInt8)transferProgress updateFirmwareImageIndex:(UInt8)updateFirmwareImageIndex;
- (instancetype)initWithParameters:(NSData *)parameters;
- (NSString *)getDetailString;
@end

/// 8.4.1.2 Firmware Update Information Status
/// - seeAlso: MshMDL_DFU_MBT_CR_R04_LbL25.pdf  (page.81)
@interface SigFirmwareInformationEntryModel : SigModel
/// Length of the Current Firmware ID field.
@property (nonatomic,assign) UInt8 currentFirmwareIDLength;
/// Identifies the firmware image on the node or any subsystem on the node. Size is variable.
@property (nonatomic,strong) NSData *currentFirmwareID;
/// Length of the Update URI field.
@property (nonatomic,assign) UInt8 updateURILength;
/// URI used to retrieve a new firmware image. Size is 1 ~ 255. (optional)
@property (nonatomic,strong) NSData *updateURL;
@property (nonatomic,strong) NSData *parameters;

- (NSString *)getFirmwareIDString;
- (NSString *)getUpdateURIString;
- (instancetype)initWithParameters:(NSData *)parameters;

@end


/// Table 8.34: The format of the Receiver Entry field
/// - seeAlso: MshMDL_DFU_MBT_CR_R06.pdf  (page.89)
@interface SigReceiverEntryModel : SigModel
/// The unicast address of the Updating node.
@property (nonatomic,assign) UInt16 address;
/// The index of the firmware image in the Firmware Information List state to be updated.
@property (nonatomic,assign) UInt8 updateFirmwareImageIndex;
@property (nonatomic,strong) NSData *parameters;
- (instancetype)initWithAddress:(UInt16)address updateFirmwareImageIndex:(UInt8)updateFirmwareImageIndex;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


@interface SigTransitionTime : NSObject
/// Transition Number of Steps, 6-bit value.
///
/// Value 0 indicates an immediate transition.
///
/// Value 0x3F means that the value is unknown. The state cannot be
/// set to this value, but an element may report an unknown value if
/// a transition is higher than 0x3E or not determined.
@property (nonatomic,assign) UInt8 steps;

/// The step resolution.
@property (nonatomic,assign) SigStepResolution stepResolution;

/// The transition time in milliseconds.
@property (nonatomic,assign) int milliseconds;

/// The transition time as `TimeInterval` in seconds.
@property (nonatomic,assign) NSTimeInterval interval;

@property (nonatomic,assign) UInt8 rawValue;


/// Creates the Transition Time object for an unknown time.
- (instancetype)init;

- (instancetype)initWithRawValue:(UInt8)rawValue;

/// Creates the Transition Time object.
///
/// Only values of 0x00 through 0x3E shall be used to specify the value
/// of the Transition Number of Steps field.
///
/// - parameter steps: Transition Number of Steps, valid values are in
///                    range 0...62. Value 63 means that the value is
///                    unknown and the state cannot be set to this value.
/// - parameter stepResolution: The step resolution.
- (instancetype)initWithSetps:(UInt8)steps stepResolution:(SigStepResolution)stepResolution;

@end


@interface SigMeshAddress : NSObject
/// 16-bit address.
@property (nonatomic, assign) UInt16 address;
/// Virtual label UUID.
@property (nonatomic, strong) CBUUID *virtualLabel;

- (instancetype)initWithHex:(NSString *)hex;

/// Creates a Mesh Address. For virtual addresses use `initWithVirtualLabel:` instead.
/// @param address address
-(instancetype)initWithAddress:(UInt16)address;

/// Creates a Mesh Address based on the virtual label.
- (instancetype)initWithVirtualLabel:(CBUUID *)virtualLabel;

- (NSString *)getHex;

@end


/// The object is used to describe the number of times a message is published and the interval between retransmissions of the published message.
@interface SigRetransmit : NSObject
/// Number of retransmissions for network messages. The value is in range from 0 to 7, where 0 means no retransmissions.
@property (nonatomic,assign) UInt8 count;
/// The interval (in milliseconds) between retransmissions (50...3200 with step 50).
@property (nonatomic,assign) UInt16 interval;
/// Retransmission steps, from 0 to 31. Use `interval` to get the interval in ms.
- (UInt8)steps;
- (instancetype)initWithPublishRetransmitCount:(UInt8)publishRetransmitCount intervalSteps:(UInt8)intervalSteps;
@end


@interface SigPublish : NSObject

/// Publication address for the Model. It's 4 or 32-character long hexadecimal string.
@property (nonatomic,strong) NSString *address;
/// Publication address for the model.
@property (nonatomic,strong) SigMeshAddress *publicationAddress;//Warning: assuming hex address is valid!
/// An Application Key index, indicating which Applicaiton Key to use for the publication.
@property (nonatomic,assign) UInt16 index;
/// An integer from 0 to 127 that represents the Time To Live (TTL) value for the outgoing publish message. 255 means default TTL value.
@property (nonatomic,assign) UInt8 ttl;
/// The interval (in milliseconds) between subsequent publications.
@property (nonatomic,assign) int period;
/// The number of steps, in range 0...63.
@property (nonatomic,assign) UInt8 periodSteps;
/// The resolution of the number of steps.
@property (nonatomic,assign) SigStepResolution periodResolution;
/// An integer 0 o 1 that represents whether master security (0) materials or friendship security material (1) are used.
@property (nonatomic,assign) int credentials;
/// The object describes the number of times a message is published and the interval between retransmissions of the published message.
@property (nonatomic,strong)  SigRetransmit *retransmit;

/// Creates an instance of Publish object.
/// @param stringDestination The publication address.
/// @param keyIndex The Application Key that will be used to send messages.
/// @param friendshipCredentialsFlag `True`, to use Friendship Security Material, `false` to use Master Security Material.
/// @param ttl Time to live. Use 0xFF to use Node's default TTL.
/// @param periodSteps Period steps, together with `periodResolution` are used to calculate period interval. Value can be in range 0...63. Value 0 disables periodic publishing.
/// @param periodResolution The period resolution, used to calculate interval. Use `._100_milliseconds` when periodic publishing is disabled.
/// @param retransmit The retransmission data. See `Retransmit` for details.
- (instancetype)initWithStringDestination:(NSString *)stringDestination withKeyIndex:(UInt16)keyIndex friendshipCredentialsFlag:(int)friendshipCredentialsFlag ttl:(UInt8)ttl periodSteps:(UInt8)periodSteps periodResolution:(SigStepResolution)periodResolution retransmit:(SigRetransmit *)retransmit;

/// Creates an instance of Publish object.
/// @param destination The publication address.
/// @param keyIndex The Application Key that will be used to send messages.
/// @param friendshipCredentialsFlag `True`, to use Friendship Security Material, `false` to use Master Security Material.
/// @param ttl Time to live. Use 0xFF to use Node's default TTL.
/// @param periodSteps Period steps, together with `periodResolution` are used to calculate period interval. Value can be in range 0...63. Value 0 disables periodic publishing.
/// @param periodResolution The period resolution, used to calculate interval. Use `._100_milliseconds` when periodic publishing is disabled.
/// @param retransmit The retransmission data. See `Retransmit` for details.
- (instancetype)initWithDestination:(UInt16)destination withKeyIndex:(UInt16)keyIndex friendshipCredentialsFlag:(int)friendshipCredentialsFlag ttl:(UInt8)ttl periodSteps:(UInt8)periodSteps periodResolution:(SigStepResolution)periodResolution retransmit:(SigRetransmit *)retransmit;

/// Returns the interval between subsequent publications in seconds.
- (NSTimeInterval)publicationInterval;
/// Returns whether master security materials are used.
- (BOOL)isUsingMasterSecurityMaterial;
/// Returns whether friendship security materials are used.
- (BOOL)isUsingFriendshipSecurityMaterial;

@end


/// 5.2.1.2 Time Set
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.143)

@interface SigTimeModel : NSObject
/// 40 bits, The current TAI time in seconds.
@property (nonatomic, assign) UInt64 TAISeconds;
/// The sub-second time in units of 1/256th second.
@property (nonatomic, assign) UInt8 subSeconds;
/// The estimated uncertainty in 10 millisecond steps.
@property (nonatomic, assign) UInt8 uncertainty;
/// 1 bit, 0 = NO Time Authority, 1 = Time Authority.
@property (nonatomic, assign) UInt8 timeAuthority;
/// 15 bits, Current difference between TAI and UTC in seconds.
@property (nonatomic, assign) UInt16 TAI_UTC_Delta;
/// The local time zone offset in 15-minute increments.
@property (nonatomic, assign) UInt8 timeZoneOffset;

- (instancetype)initWithTAISeconds:(UInt64)TAISeconds subSeconds:(UInt8)subSeconds uncertainty:(UInt8)uncertainty timeAuthority:(UInt8)timeAuthority TAI_UTC_Delta:(UInt16)TAI_UTC_Delta timeZoneOffset:(UInt8)timeZoneOffset;
- (instancetype)initWithParameters:(NSData *)parameters;
- (NSData *)getTimeParameters;

@end


@interface SigSensorDescriptorModel : NSObject

/// The Sensor Property ID field is a 2-octet value referencing a device property that describes the meaning and the format of data reported by a sensor.(0x0001–0xFFFF)
@property (nonatomic, assign) UInt16 propertyID;
/// The Sensor Positive Tolerance field is a 12-bit value representing the magnitude of a possible positive error associated with the measurements that the sensor is reporting.(0x001–0xFFF)
@property (nonatomic, assign) UInt16 positiveTolerance;
/// The Sensor Negative Tolerance field is a 12-bit value representing the magnitude of a possible negative error associated with the measurements that the sensor is reporting.(0x001–0xFFF)
@property (nonatomic, assign) UInt16 negativeTolerance;
/// This Sensor Sampling Function field specifies the averaging operation or type of sampling function applied to the measured value.(0x00–0x07)
@property (nonatomic, assign) SigSensorSamplingFunctionType samplingFunction;
/// This Sensor Measurement Period field specifies a uint8 value n that represents the averaging time span, accumulation time, or measurement period in seconds over which the measurement is taken.(0x00–0xFF)
@property (nonatomic, assign) UInt8 measurementPeriod;
/// The measurement reported by a sensor is internally refreshed at the frequency indicated in the Sensor Update Interval field.(0x00–0xFF)
@property (nonatomic, assign) UInt8 updateInterval;

- (NSData *)getDescriptorParameters;
- (instancetype)initWithDescriptorParameters:(NSData *)parameters;

@end


/// mesh设备广播包解密模型。唯一标识符为identityData，且只存储本地json存在的identityData不为空的SigEncryptedModel。设备断电后会改变identityData，出现相同的address的SigEncryptedModel时，需要replace旧的。
@interface SigEncryptedModel : NSObject
@property (nonatomic, strong) NSData *advertisementDataServiceData;
//@property (nonatomic, strong) NSData *identityData;
@property (nonatomic, strong) NSData *hashData;
@property (nonatomic, strong) NSData *randomData;
@property (nonatomic, strong) NSString *peripheralUUID;
@property (nonatomic, strong) NSData *encryptedData;
@property (nonatomic, assign) UInt16 address;
@end


@interface SigNetkeyModel : NSObject

@property (nonatomic, copy, nullable) NSString *oldKey;

@property (nonatomic, assign) UInt16 index;

@property (nonatomic, assign) KeyRefreshPhase phase;

@property (nonatomic, copy) NSString *timestamp;

@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *minSecurity;

@property (nonatomic, strong) SigNetkeyDerivaties *keys;
@property (nonatomic, strong) SigNetkeyDerivaties *oldKeys;

/// Network identifier.
@property (nonatomic, assign) UInt8 nid;
/// Network identifier derived from the old key.
@property (nonatomic, assign) UInt8 oldNid;
/// The IV Index for this subnetwork.
@property (nonatomic, strong) SigIvIndex *ivIndex;
/// The Network ID derived from this Network Key. This identifier is public information.
@property (nonatomic, strong) NSData *networkId;
/// The Network ID derived from the old Network Key. This identifier is public information. It is set when `oldKey` is set.
@property (nonatomic, strong) NSData *oldNetworkId;

- (SigNetkeyDerivaties *)transmitKeys;

/// Returns whether the Network Key is the Primary Network Key.
/// The Primary key is the one which Key Index is equal to 0.
///
/// A Primary Network Key may not be removed from the mesh network.
- (BOOL)isPrimary;

- (NSDictionary *)getDictionaryOfSigNetkeyModel;
- (void)setDictionaryToSigNetkeyModel:(NSDictionary *)dictionary;

- (NSString *)getNetKeyDetailString;

@end

@interface SigNetkeyDerivaties : NSObject

@property (nonatomic, strong) NSData *identityKey;

@property (nonatomic, strong) NSData *beaconKey;

@property (nonatomic, strong) NSData *encryptionKey;

@property (nonatomic, strong) NSData *privacyKey;

- (SigNetkeyDerivaties *)initWithNetkeyData:(NSData *)key helper:(OpenSSLHelper *)helper;

@end

@interface SigIvIndex : NSObject

@property (nonatomic,assign) UInt32 index;//init 0
@property (nonatomic,assign) BOOL updateActive;//init NO

- (instancetype)initWithIndex:(UInt32)index updateActive:(BOOL)updateActive;

@end

@interface SigProvisionerModel : NSObject

@property (nonatomic, strong) NSMutableArray <SigRangeModel *>*allocatedGroupRange;

@property (nonatomic, strong) NSMutableArray <SigRangeModel *>*allocatedUnicastRange;

/*JSON中存储格式为：
 "standardUUID": {
 "type": "string",
 "name": "UUID",
 "pattern": "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"}
 */
@property (nonatomic, copy) NSString *UUID;

@property (nonatomic, copy) NSString *provisionerName;

@property (nonatomic, strong) NSMutableArray <SigSceneRangeModel *>*allocatedSceneRange;


/**
 create new provisioner by count of exist provisioners.（已弃用，请使用'initWithExistProvisionerMaxHighAddressUnicast:andProvisionerUUID:'）

 @param count count of exist provisioners
 @param provisionerUUID new provisioner's uuid
 @return SigProvisionerModel model
 */
-(instancetype)initWithExistProvisionerCount:(UInt16)count andProvisionerUUID:(NSString *)provisionerUUID DEPRECATED_MSG_ATTRIBUTE("Use 'initWithExistProvisionerMaxHighAddressUnicast:andProvisionerUUID:' instead");;

- (instancetype)initWithExistProvisionerMaxHighAddressUnicast:(UInt16)maxHighAddressUnicast andProvisionerUUID:(NSString *)provisionerUUID;

- (SigNodeModel *)node;

- (NSDictionary *)getDictionaryOfSigProvisionerModel;
- (void)setDictionaryToSigProvisionerModel:(NSDictionary *)dictionary;

@end

@interface SigRangeModel : NSObject

@property (nonatomic, copy) NSString *lowAddress;

@property (nonatomic, copy) NSString *highAddress;

- (NSInteger)lowIntAddress;
- (NSInteger)hightIntAddress;

- (NSDictionary *)getDictionaryOfSigRangeModel;
- (void)setDictionaryToSigRangeModel:(NSDictionary *)dictionary;
- (instancetype)initWithMaxHighAddressUnicast:(UInt16)maxHighAddressUnicast;

@end

@interface SigSceneRangeModel : NSObject

@property (nonatomic, copy) NSString *firstScene;

@property (nonatomic, copy) NSString *lastScene;

- (NSDictionary *)getDictionaryOfSigSceneRangeModel;
- (void)setDictionaryToSigSceneRangeModel:(NSDictionary *)dictionary;

@end

@interface SigAppkeyModel : NSObject

@property (nonatomic, copy) NSString *oldKey;

@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSInteger boundNetKey;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) UInt8 aid;
@property (nonatomic, assign) UInt8 oldAid;

- (SigNetkeyModel *)getCurrentBoundNetKey;
- (NSData *)getDataKey;
- (NSData *)getDataOldKey;

- (NSDictionary *)getDictionaryOfSigAppkeyModel;
- (void)setDictionaryToSigAppkeyModel:(NSDictionary *)dictionary;

- (NSString *)getAppKeyDetailString;

@end

@interface SigSceneModel : NSObject<NSCopying>

@property (nonatomic, copy) NSString *name;

//@property (nonatomic, assign) NSInteger number;
@property (nonatomic, copy) NSString *number;

@property (nonatomic, strong) NSMutableArray <NSString *>*addresses;

//暂时添加并保存json
@property (nonatomic, strong) NSMutableArray <ActionModel *>*actionList;

- (NSDictionary *)getDictionaryOfSigSceneModel;
- (void)setDictionaryToSigSceneModel:(NSDictionary *)dictionary;
- (NSDictionary *)getFormatDictionaryOfSigSceneModel;

@end

@interface SigGroupModel : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *address;

@property (nonatomic, copy) NSString *parentAddress;

@property (nonatomic, copy) SigMeshAddress *meshAddress;

- (UInt16)intAddress;

- (NSDictionary *)getDictionaryOfSigGroupModel;
- (void)setDictionaryToSigGroupModel:(NSDictionary *)dictionary;

//临时缓存groupBrightness、groupTempareture，关闭APP后就丢失。
@property (nonatomic,assign) UInt8 groupBrightness;
@property (nonatomic,assign) UInt8 groupTempareture;

- (BOOL)isOn;
- (NSMutableArray <SigNodeModel *>*)groupDevices;
- (NSMutableArray <SigNodeModel *>*)groupOnlineDevices;

@end

///Attention: Boolean type should use bool not BOOL.
@interface SigNodeModel : NSObject<NSCopying>

@property (nonatomic, strong) SigNodeFeatures *features;

@property (nonatomic, copy) NSString *unicastAddress;

@property (nonatomic, assign) bool secureNetworkBeacon;

@property (nonatomic, strong) SigRelayretransmitModel *relayRetransmit;

@property (nonatomic, strong) SigNetworktransmitModel *networkTransmit;

@property (nonatomic, assign) bool configComplete;

@property (nonatomic, copy) NSString *vid;

@property (nonatomic, copy) NSString *cid;

//@property (nonatomic, assign) bool blacklisted;
/*JSON中存储格式为：
 "standardUUID": {
 "type": "string",
 "name": "UUID",
 "pattern": "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"}
 */
@property (nonatomic, copy) NSString *UUID;

@property (nonatomic, copy) NSString *security;

@property (nonatomic, copy) NSString *crpl;

@property (nonatomic, assign) UInt8 defaultTTL;

@property (nonatomic, copy) NSString *pid;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *deviceKey;

@property (nonatomic, copy) NSString *macAddress;//new add the mac to json, get mac from scanResponse's Manufacturer Data.
//默认为nil，不需要存储json。配置过才存储到json里面
@property (nonatomic, strong) SigHeartbeatPubModel *heartbeatPub;
//默认为nil，不需要存储json。配置过才存储到json里面
@property (nonatomic, strong) SigHeartbeatSubModel *heartbeatSub;

@property (nonatomic, strong) NSMutableArray<SigElementModel *> *elements;
@property (nonatomic, strong) NSMutableArray<SigNodeKeyModel *> *netKeys;
@property (nonatomic, strong) NSMutableArray<SigNodeKeyModel *> *appKeys;//node isn't unbound when appkeys is empty.
/// The excluded property contains a Boolean value that is set to “true” when the node is in the process of being deleted and is excluded from the new network key distribution during the Key Refresh procedure; otherwise, it is set to “false”.
@property (nonatomic, assign) bool excluded;

//暂时添加到json数据中
@property (nonatomic,strong) NSMutableArray <SchedulerModel *>*schedulerList;
@property (nonatomic,assign) BOOL subnetBridgeEnable;
@property (nonatomic,strong) NSMutableArray <SigSubnetBridgeModel *>*subnetBridgeList;

//@property (nonatomic, copy) NSString *sno;
//The following properties are not stored JSON
@property (nonatomic,assign) DeviceState state;
@property (nonatomic,assign) BOOL isKeyBindSuccess;
@property (nonatomic,assign) UInt16 brightness;
@property (nonatomic,assign) UInt16 temperature;
@property (nonatomic,assign) UInt16 HSL_Lightness;
@property (nonatomic,assign) UInt16 HSL_Hue;
@property (nonatomic,assign) UInt16 HSL_Saturation;
@property (nonatomic,assign) UInt8 HSL_Lightness100;
@property (nonatomic,assign) UInt8 HSL_Hue100;
@property (nonatomic,assign) UInt8 HSL_Saturation100;
@property (nonatomic,strong) NSMutableArray <NSNumber *>*keyBindModelIDs;//There are modelID that current had key bind.
@property (nonatomic,strong) SigPage0 *compositionData;//That is composition data get from add device process.APP can get ele_cut in provision_end_callback, app can get detail composition data in App_key_bind_end_callback.
@property (nonatomic,strong) NSMutableArray <NSNumber *>*onoffAddresses;//element addresses of onoff
@property (nonatomic,strong) NSMutableArray <NSNumber *>*levelAddresses;//element addresses of level
@property (nonatomic,strong) NSMutableArray <NSNumber *>*temperatureAddresses;//element addresses of color temperature
@property (nonatomic,strong) NSMutableArray <NSNumber *>*HSLAddresses;//element addresses of HSL
@property (nonatomic,strong) NSMutableArray <NSNumber *>*lightnessAddresses;//element addresses of lightness
@property (nonatomic,strong) NSMutableArray <NSNumber *>*schedulerAddress;//element addresses of scheduler
@property (nonatomic,strong) NSMutableArray <NSNumber *>*subnetBridgeServerAddress;//element addresses of subnetBridgeServer
@property (nonatomic,strong) NSMutableArray <NSNumber *>*sceneAddress;//element addresses of scene
@property (nonatomic,strong) NSMutableArray <NSNumber *>*publishAddress;//element addresses of publish
@property (nonatomic,assign) UInt16 publishModelID;//modelID of set publish
@property (nonatomic,strong,nullable) NSString *peripheralUUID;

///return node true brightness, range is 0~100
- (UInt8)trueBrightness;

///return node true color temperture, range is 0~100
- (UInt8)trueTemperature;

///update node status, YES means status had changed, NO means status hadn't changed.
//- (BOOL)update:(ResponseModel *)m;

///update node status from api getOnlineStatusFromUUIDWithCompletation
- (void)updateOnlineStatusWithDeviceState:(DeviceState)state bright100:(UInt8)bright100 temperature100:(UInt8)temperature100;

- (UInt16)getNewSchedulerID;

- (void)saveSchedulerModelWithModel:(SchedulerModel *)scheduler;

- (UInt8)getElementCount;

- (NSMutableArray *)getAddressesWithModelID:(NSNumber *)sigModelID;

- (instancetype)initWithNode:(SigNodeModel *)node;

- (UInt16)address;
- (void)setAddress:(UInt16)address;
//- (int)getIntSNO;
//- (void)setIntSno:(UInt32)intSno;

///get all groupIDs of node(获取该设备的所有组号)
- (NSMutableArray <NSNumber *>*)getGroupIDs;

///add new groupID to node(新增设备的组号)
- (void)addGroupID:(NSNumber *)groupID;

///delete old groupID from node(删除设备的组号)
- (void)deleteGroupID:(NSNumber *)groupID;

- (void)openPublish;

- (void)closePublish;

- (BOOL)hasPublishFunction;

- (BOOL)hasOpenPublish;

///publish是否存在周期上报功能。
- (BOOL)hasPublishPeriod;

- (BOOL)isSensor;

/// 返回当前节点是否是遥控器。
- (BOOL)isRemote;

/// Returns list of Network Keys known to this Node.
- (NSArray <SigNetkeyModel *>*)getNetworkKeys;

/// The last unicast address allocated to this node. Each node's element
/// uses its own subsequent unicast address. The first (0th) element is identified
/// by the node's unicast address. If there are no elements, the last unicast address
/// is equal to the node's unicast address.
- (UInt16)lastUnicastAddress;

/// Returns whether the address uses the given unicast address for one
/// of its elements.
///
/// - parameter addr: Address to check.
/// - returns: `True` if any of node's elements (or the node itself) was assigned
///            the given address, `false` otherwise.
- (BOOL)hasAllocatedAddr:(UInt16)addr;

- (SigModelIDModel *)getModelIDModelWithModelID:(UInt32)modelID;
- (SigModelIDModel *)getModelIDModelWithModelID:(UInt32)modelID andElementAddress:(UInt16)elementAddress;

- (NSDictionary *)getDictionaryOfSigNodeModel;
- (void)setDictionaryToSigNodeModel:(NSDictionary *)dictionary;
- (NSDictionary *)getFormatDictionaryOfSigNodeModel;

- (void)setAddSigAppkeyModelSuccess:(SigAppkeyModel *)appkey;
- (void)setCompositionData:(SigPage0 *)compositionData;
- (void)setBindSigNodeKeyModel:(SigNodeKeyModel *)appkey toSigModelIDModel:(SigModelIDModel *)modelID;

- (void)updateNodeStatusWithBaseMeshMessage:(SigBaseMeshMessage *)responseMessage source:(UInt16)source;

- (void)addDefaultPublicAddressToRemote;

@end


@interface SigExclusionModel : NSObject
/// The ivIndex property contains the integer value of the IV index of the mesh network that was in use while the unicast addresses were marked as excluded.
@property (nonatomic, assign) NSInteger ivIndex;
/// The addresses property contains an array of 4-character hexadecimal strings, representing the excluded unicast addresses.
@property (nonatomic, strong) NSMutableArray <NSString *>*addresses;

- (NSDictionary *)getDictionaryOfSigExclusionModel;
- (void)setDictionaryToSigExclusionModel:(NSDictionary *)dictionary;

@end


/// The Relay Retransmit state is a composite state that controls parameters of retransmission of the Network PDU relayed by the node.(Interval在json存储10~320，SDK内存装换为0~31使用)
@interface SigRelayretransmitModel : NSObject
/// Number of retransmissions on advertising bearer for each Network PDU relayed by the node.
/// For example, a value of 0b000 represents a single transmission with no retransmissions, and a value of 0b111 represents a single transmission and 7 retransmissions for a total of 8 transmissions.
@property (nonatomic, assign) NSInteger relayRetransmitCount;
/// The Relay Retransmit Interval Steps field is a 5-bit value representing the number of 10 millisecond steps that controls the interval between message retransmissions of the Network PDU relayed by the node.
/// The retransmission interval is calculated using the formula:
/// retransmission interval = (Relay Retransmit Interval Steps + 1) * 10
@property (nonatomic, assign) NSInteger relayRetransmitIntervalSteps;

- (UInt8)getIntervalOfJsonFile;
- (void)setIntervalOfJsonFile:(UInt8)intervalOfJsonFile;

- (NSDictionary *)getDictionaryOfSigRelayretransmitModel;
- (void)setDictionaryToSigRelayretransmitModel:(NSDictionary *)dictionary;

@end

/// The object represents parameters of the transmissions of network layer messages originating from a mesh node.(Interval在json存储10~320，SDK内存装换为0~31使用)
@interface SigNetworktransmitModel : NSObject
/// The Network Transmit Count field is a 3-bit value that controls the number of message transmissions of the Network PDU originating from the node. The number of transmissions is the Transmit Count + 1.
/// For example a value of 0b000 represents a single transmission and a value of 0b111 represents 8 transmissions.
@property (nonatomic, assign) NSInteger networkTransmitCount;
/// The Network Transmit Interval Steps field is a 5-bit value representing the number of 10 millisecond steps that controls the interval between message transmissions of Network PDUs originating from the node.
/// The transmission interval is calculated using the formula:
/// transmission interval = (Network Retransmit Interval Steps + 1) * 10
/// Each transmission should be perturbed by a random value between 0 to 10 milliseconds between each transmission.
/// For example, a value of 0b10000 represents a transmission interval between 170 and 180 milliseconds between each transmission.
@property (nonatomic, assign) NSInteger networkTransmitIntervalSteps;

- (UInt8)getIntervalOfJsonFile;
- (void)setIntervalOfJsonFile:(UInt8)intervalOfJsonFile;

/// The interval in as `TimeInterval` in seconds.
//- (NSTimeInterval)timeInterval;

- (NSDictionary *)getDictionaryOfSigNetworktransmitModel;
- (void)setDictionaryToSigNetworktransmitModel:(NSDictionary *)dictionary;

@end

/// The features object represents the functionality of a mesh node that is determined by the set features that the node supports.
@interface SigNodeFeatures : NSObject

/// The state of Relay feature. Default is 2.
@property (nonatomic,assign) SigNodeFeaturesState relayFeature;
/// The state of Proxy feature. Default is 2.
@property (nonatomic,assign) SigNodeFeaturesState proxyFeature;
/// The state of Friend feature. Default is 2.
@property (nonatomic,assign) SigNodeFeaturesState friendFeature;
/// The state of Low Power feature. Default is 2.
@property (nonatomic,assign) SigNodeFeaturesState lowPowerFeature;

- (UInt16)rawValue;
- (instancetype)initWithRawValue:(UInt16)rawValue;
- (instancetype)initWithRelay:(SigNodeFeaturesState)relayFeature proxy:(SigNodeFeaturesState)proxyFeature friend:(SigNodeFeaturesState)friendFeature lowPower:(SigNodeFeaturesState)lowPowerFeature;

- (NSDictionary *)getDictionaryOfSigFeatureModel;
- (void)setDictionaryToSigFeatureModel:(NSDictionary *)dictionary;

@end

@interface SigNodeKeyModel : NSObject
/// The Key index for this network key.
@property (nonatomic, assign) UInt16 index;
/// This flag contains value set to `false`, unless a Key Refresh
/// procedure is in progress and the network has been successfully
/// updated.
@property (nonatomic, assign) bool updated;
- (instancetype)initWithIndex:(UInt16)index updated:(bool)updated;

- (NSDictionary *)getDictionaryOfSigNodeKeyModel;
- (void)setDictionaryToSigNodeKeyModel:(NSDictionary *)dictionary;

@end

@interface SigElementModel : NSObject

@property (nonatomic, strong) NSMutableArray<SigModelIDModel *> *models;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *location;

@property (nonatomic, assign) UInt8 index;

@property (nonatomic, assign) UInt16 parentNodeAddress;

- (instancetype)initWithLocation:(SigLocation)location;

- (instancetype)initWithCompositionData:(NSData *)compositionData offset:(int *)offset;

/// Returns the Unicast Address of the Element. For Elements not added to Node this returns the Element index value as `Address`.
- (UInt16)unicastAddress;

- (SigNodeModel * _Nullable)getParentNode;

- (SigLocation)getSigLocation;
- (void)setSigLocation:(SigLocation)sigLocation;

- (NSDictionary *)getDictionaryOfSigElementModel;
- (void)setDictionaryToSigElementModel:(NSDictionary *)dictionary;

- (NSData *)getElementData;

@end

@interface SigModelIDModel : NSObject
/// An array of Appliaction Key indexes to which this model is bound.
@property (nonatomic, strong) NSMutableArray <NSNumber *>*bind;//[KeyIndex]
//Attention: length=4，为SIG modelID，类型为UInt16；length=8，为vendor modelID，类型为UInt32
@property (nonatomic, copy) NSString *modelId;
/// The array of Unicast or Group Addresses (4-character hexadecimal value), or Virtual Label UUIDs (32-character hexadecimal string).
@property (nonatomic, strong) NSMutableArray <NSString *>*subscribe;
/// The configuration of this Model's publication.
@property (nonatomic, strong, nullable) SigPublishModel *publish;
/// The model message handler. This is non-`nil` for supported local Models and `nil` for Models of remote Nodes.
@property (nonatomic,weak) id delegate;

///返回整形的modelID
- (int)getIntModelID;
- (UInt16)getIntModelIdentifier;
- (UInt16)getIntCompanyIdentifier;

- (instancetype)initWithSigModelId:(UInt16)sigModelId;

- (instancetype)initWithVendorModelId:(UInt32)vendorModelId;

///// Bluetooth SIG or vendor-assigned model identifier.
//- (UInt16)modelIdentifier;
///// The Company Identifier or `nil`, if the model is Bluetooth SIG-assigned.
//- (UInt16)companyIdentifier;
/// Returns `true` for Models with identifiers assigned by Bluetooth SIG,
/// `false` otherwise.
- (BOOL)isBluetoothSIGAssigned;
/// Returns the list of known Groups that this Model is subscribed to.
/// It may be that the Model is subscribed to some other Groups, which are
/// not known to the local database, and those are not returned.
/// Use `isSubscribed(to:)` to check other Groups.
- (NSArray <SigGroupModel *>*)subscriptions;

- (BOOL)isConfigurationServer;
- (BOOL)isConfigurationClient;
- (BOOL)isHealthServer;
- (BOOL)isHealthClient;
/// 返回是否是强制使用deviceKey加解密的modelID，是则无需进行keyBind操作。
- (BOOL)isDeviceKeyModelID;

/// Adds the given Application Key Index to the bound keys.
///
/// - paramter applicationKeyIndex: The Application Key index to bind.
- (void)bindApplicationKeyWithIndex:(UInt16)applicationKeyIndex;

/// Removes the Application Key binding to with the given Key Index
/// and clears the publication, if it was set to use the same key.
///
/// - parameter applicationKeyIndex: The Application Key index to unbind.
- (void)unbindApplicationKeyWithIndex:(UInt16)applicationKeyIndex;

/// Adds the given Group to the list of subscriptions.
///
/// - parameter group: The new Group to be added.
- (void)subscribeToGroup:(SigGroupModel *)group;

/// Removes the given Group from list of subscriptions.
///
/// - parameter group: The Group to be removed.
- (void)unsubscribeFromGroup:(SigGroupModel *)group;

/// Removes the given Address from list of subscriptions.
///
/// - parameter address: The Address to be removed.
- (void)unsubscribeFromAddress:(UInt16)address;

/// Removes all subscribtions from this Model.
- (void)unsubscribeFromAll;

/// Whether the given Application Key is bound to this Model.
///
/// - parameter applicationKey: The key to check.
/// - returns: `True` if the key is bound to this Model,
///            otherwise `false`.
- (BOOL)isBoundToApplicationKey:(SigAppkeyModel *)applicationKey;

/// Returns whether the given Model is compatible with the one.
///
/// A compatible Models create a Client-Server pair. I.e., the
/// Generic On/Off Client is compatible to Generic On/Off Server,
/// and vice versa. The rule is that the Server Model has an even
/// Model ID and the Client Model has Model ID greater by 1.
///
/// - parameter model: The Model to compare to.
/// - returns: `True`, if the Models are compatible, `false` otherwise.
- (BOOL)isCompatibleToModel:(SigModelIDModel *)model;

/// Returns whether the Model is subscribed to the given Group.
///
/// This method may also return `true` if the Group is not known
/// to the local Provisioner and is not returned using `subscriptions`
/// property.
///
/// - parameter group: The Group to check subscription to.
/// - returns: `True` if the Model is subscribed to the Group,
///            `false` otherwise.
- (BOOL)isSubscribedToGroup:(SigGroupModel *)group;

/// Returns whether the Model is subscribed to the given address.
///
/// This method may also return `true` if the address is not known
/// to the local Provisioner and is a Group with this address is
/// not returned using `subscriptions` property.
/// Moreover, if a Virtual Label of a Group is not known, but the
/// 16-bit address is known, and the given address contains the Virtual
/// Label, with the same 16-bit address, this method will return `false`,
/// as it may not guarantee that the labels are the same.
///
/// - parameter address: The address to check subscription to.
/// - returns: `True` if the Model is subscribed to a Group with given,
///            address, `false` otherwise.
- (BOOL)isSubscribedToAddress:(SigMeshAddress *)address;

- (NSDictionary *)getDictionaryOfSigModelIDModel;
- (void)setDictionaryToSigModelIDModel:(NSDictionary *)dictionary;

@end

@interface SigPublishModel : NSObject

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) NSInteger credentials;

@property (nonatomic, assign) NSInteger ttl;

@property (nonatomic, strong) SigRetransmitModel *retransmit;

@property (nonatomic, strong) SigPeriodModel *period;

@property (nonatomic, copy) NSString *address;

- (NSDictionary *)getDictionaryOfSigPublishModel;
- (void)setDictionaryToSigPublishModel:(NSDictionary *)dictionary;

@end

@interface SigRetransmitModel : NSObject

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) NSInteger interval;

- (NSDictionary *)getDictionaryOfSigRetransmitModel;
- (void)setDictionaryToSigRetransmitModel:(NSDictionary *)dictionary;

@end

@interface SigPeriodModel : NSObject

@property (nonatomic, assign) NSInteger numberOfSteps;

/// 值为100、1000、10000、600000
@property (nonatomic, assign) NSInteger resolution;

- (NSDictionary *)getDictionaryOfSigPeriodModel;
- (void)setDictionaryToSigPeriodModel:(NSDictionary *)dictionary;

@end

@interface SigHeartbeatPubModel : NSObject

@property (nonatomic, copy) NSString *address;

@property (nonatomic, assign) NSInteger period;

@property (nonatomic, assign) NSInteger ttl;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSMutableArray <NSString *>*features;

- (NSDictionary *)getDictionaryOfSigHeartbeatPubModel;
- (void)setDictionaryToSigHeartbeatPubModel:(NSDictionary *)dictionary;

@end

@interface SigHeartbeatSubModel : NSObject

@property (nonatomic, copy) NSString *source;

@property (nonatomic, copy) NSString *destination;

//@property (nonatomic, assign) NSInteger period;

- (NSDictionary *)getDictionaryOfSigHeartbeatSubModel;
- (void)setDictionaryToSigHeartbeatSubModel:(NSDictionary *)dictionary;

@end


@interface SigOOBModel : SigModel
@property (nonatomic, assign) OOBSourceType sourceType;
@property (nonatomic, strong) NSString *UUIDString;
@property (nonatomic, strong) NSString *OOBString;
@property (nonatomic, strong) NSString *lastEditTimeString;
- (instancetype)initWithSourceType:(OOBSourceType)sourceType UUIDString:(NSString *)UUIDString OOBString:(NSString *)OOBString;
- (void)updateWithUUIDString:(NSString *)UUIDString OOBString:(NSString *)OOBString;
@end


/// 4.2.X+1 Bridging Table
/// - seeAlso: MshPRF_SBR_CR_r03.pdf  (page.9)
@interface SigSubnetBridgeModel : SigModel
/// Allowed directions for the bridged traffic, size is 8 bits.
@property (nonatomic, assign) SigDirectionsFieldValues directions;
/// NetKey Index of the first subnet, size is 12 bits.
@property (nonatomic, assign) UInt16 netKeyIndex1;
/// NetKey Index of the second subnet, size is 12 bits.
@property (nonatomic, assign) UInt16 netKeyIndex2;
/// Address of the node in the first subnet, size is 16 bits.
@property (nonatomic, assign) UInt16 address1;
/// Address of the node in the second subnet, size is 16 bits.
@property (nonatomic, assign) UInt16 address2;
@property (nonatomic,strong) NSData *parameters;
- (NSDictionary *)getDictionaryOfSubnetBridgeModel;
- (void)setDictionaryToSubnetBridgeModel:(NSDictionary *)dictionary;
- (instancetype)initWithDirections:(SigDirectionsFieldValues)directions netKeyIndex1:(UInt16)netKeyIndex1 netKeyIndex2:(UInt16)netKeyIndex2 address1:(UInt16)address1 address2:(UInt16)address2;
- (instancetype)initWithParameters:(NSData *)parameters;
- (NSString *)getDescription;
@end


/// Table 4.Y+12: Bridged_Subnets_List entry format
/// - seeAlso: MshPRF_SBR_CR_r03.pdf  (page.14)
@interface SigBridgeSubnetModel : SigModel
/// NetKey Index of the first subnet, size is 12 bits.
@property (nonatomic, assign) UInt16 netKeyIndex1;
/// NetKey Index of the second subnet, size is 12 bits.
@property (nonatomic, assign) UInt16 netKeyIndex2;
@property (nonatomic,strong) NSData *parameters;
- (instancetype)initWithNetKeyIndex1:(UInt16)netKeyIndex1 netKeyIndex2:(UInt16)netKeyIndex2;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


/// Table 4.Y+15: Bridged_Addresses_List entry format
/// - seeAlso: MshPRF_SBR_CR_r03.pdf  (page.16)
@interface SigBridgedAddressesModel : SigModel
/// Address of the node in the first subnet, size is 16 bits.
@property (nonatomic, assign) UInt16 address1;
/// Address of the node in the second subnet, size is 16 bits.
@property (nonatomic, assign) UInt16 address2;
/// Allowed directions for the bridged traffic, size is 8 bits.
@property (nonatomic, assign) SigDirectionsFieldValues directions;
@property (nonatomic,strong) NSData *parameters;
- (instancetype)initWithAddress1:(UInt16)address1 address2:(UInt16)address2 directions:(SigDirectionsFieldValues)directions;
- (instancetype)initWithParameters:(NSData *)parameters;
@end


/// Table 4.259: Format of the Aggregator Item
/// - seeAlso: MshPRFd1.1r13_clean.pdf  (page.388)
/// An empty item shall be represented by setting the value of the Length_Format field to 0 and the value of the Length_Short field to 0.
@interface SigOpcodesAggregatorItemModel : SigModel
/// The size is 1 bit. 0: Length_Short field is present, 1: Length_Long field is present.
@property (nonatomic, assign) BOOL lengthFormat;
/// The size is 7 bits. Size of Opcode_And_Parameters field (C.1) (C.1: Included if Length_Format is 0, otherwise excluded.)
@property (nonatomic, assign) UInt8 lengthShort;
/// The size is 15 bits. Size of Opcode_And_Parameters field (C.2) (C.2: Included if Length_Format is 1, otherwise excluded.)
@property (nonatomic, assign) UInt16 lengthLong;
/// The Opcode_And_Parameters field shall contain a valid opcode and parameters (contained in an unencrypted access layer message) for the given model.
@property (nonatomic, strong) NSData *opcodeAndParameters;
@property (nonatomic, strong) NSData *parameters;

- (instancetype)initWithLengthFormat:(BOOL)lengthFormat lengthShort:(UInt8)lengthShort lengthLong:(UInt8)lengthLong opcodeAndParameters:(NSData *)opcodeAndParameters;
- (instancetype)initWithSigMeshMessage:(SigMeshMessage *)meshMessage;
- (instancetype)initWithOpcodeAndParameters:(NSData *)opcodeAndParameters;
- (SigMeshMessage *)getSigMeshMessage;
@end


@interface SigOpCodeAndParametersModel : SigModel
@property (nonatomic, assign) UInt8 opCodeSize;
@property (nonatomic, assign) UInt32 opCode;
@property (nonatomic, strong) NSData *parameters;
@property (nonatomic, strong) NSData *opCodeAndParameters;

- (instancetype)initWithOpCodeAndParameters:(NSData *)opCodeAndParameters;
- (SigMeshMessage *)getSigMeshMessage;

@end


/// Table 3.106: Structure of the Date Time characteristic, eg: 2017-11-12 01:00:30 -> @"E1070B0C01001E"
/// - seeAlso: GATT_Specification_Supplement_v5.pdf  (page.103)
@interface GattDateTimeModel : SigModel
/// Year as defined by the Gregorian calendar. Valid range 1582 to 9999. A value of 0 means that the year is not known. All other values are reserved for future use (RFU).
@property (nonatomic, assign) UInt16 year;
/// Month of the year as defined by the Gregorian calendar. Valid range 1 (January) to 12 (December). A value of 0 means that the month is not known. All other values are reserved for future use (RFU).
@property (nonatomic, assign) UInt8 month;
/// Day of the month as defined by the Gregorian calendar. Valid range 1 to 31. A value of 0 means that the day of month is not known. All other values are reserved for future use (RFU).
@property (nonatomic, assign) UInt8 day;
/// Number of hours past midnight. Valid range 0 to 23. All other values are reserved for future use (RFU).
@property (nonatomic, assign) UInt8 hours;
/// Number of minutes since the start of the hour. Valid range 0 to 59. All other values are reserved for future use (RFU).
@property (nonatomic, assign) UInt8 minutes;
/// Number of seconds since the start of the minute. Valid range 0 to 59. All other values are reserved for future use (RFU).
@property (nonatomic, assign) UInt8 seconds;

@property (nonatomic, strong) NSData *parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
- (instancetype)initWithDate:(NSDate *)date;
- (instancetype)initWithYear:(UInt16)year month:(UInt8)month day:(UInt8)day hours:(UInt8)hours minutes:(UInt8)minutes seconds:(UInt8)seconds;

@end


/// Table 3.107: Structure of the Day Date Time characteristic
/// - seeAlso: GATT_Specification_Supplement_v5.pdf  (page.104)
@interface GattDayDateTimeModel : SigModel
/// It contains year, month, day, hours, minutes, seconds. The size is 7 bytes.
@property (nonatomic, strong) GattDateTimeModel *dateTime;
/// Refer to the Day of Week characteristic in Section 3.66.
@property (nonatomic, assign) GattDayOfWeek dayOfWeek;

@property (nonatomic, strong) NSData *parameters;
- (instancetype)initWithParameters:(NSData *)parameters;
- (instancetype)initWithDate:(NSDate *)date;
- (instancetype)initWithYear:(UInt16)year month:(UInt8)month day:(UInt8)day hours:(UInt8)hours minutes:(UInt8)minutes seconds:(UInt8)seconds dayOfWeek:(GattDayOfWeek)dayOfWeek;

@end

NS_ASSUME_NONNULL_END
