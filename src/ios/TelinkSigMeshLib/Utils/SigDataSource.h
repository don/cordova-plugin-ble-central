/********************************************************************************************************
 * @file     SigDataSource.h
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

@class SigNetkeyModel,SigProvisionerModel,SigAppkeyModel,SigSceneModel,SigGroupModel,SigNodeModel, SigIvIndex,SigExclusionModel,SigBaseMeshMessage;

@protocol SigDataSourceDelegate <NSObject>
@optional

/// Callback called when the sequenceNumber or ivIndex change.
/// @param sequenceNumber sequenceNumber of current provisioner.
/// @param ivIndex ivIndex of current mesh network.
- (void)onSequenceNumberUpdate:(UInt32)sequenceNumber ivIndexUpdate:(UInt32)ivIndex;

/// Callback called when the unicastRange of provisioner had been changed. APP need update the json to cloud at this time!（如果APP实现了该代理方法，SDK会在当前provisioner地址还剩余10个或者更少的时候给provisioner分配一段新的地址区间。如果APP未实现该方法，SDK在但区间耗尽时超界分配地址(即- (UInt16)provisionAddress方法会返回非本区间的地址)。）
/// @param unicastRange Randge model had beed change.
/// @param provisioner provisioner of unicastRange.
- (void)onUpdateAllocatedUnicastRange:(SigRangeModel *)unicastRange ofProvisioner:(SigProvisionerModel *)provisioner;

@end

@interface SigDataSource : NSObject

@property (nonatomic, weak) id <SigDataSourceDelegate>delegate;

@property (nonatomic, strong) NSMutableArray<SigProvisionerModel *> *provisioners;

@property (nonatomic, strong) NSMutableArray<SigNodeModel *> *nodes;

@property (nonatomic, strong) NSMutableArray<SigGroupModel *> *groups;

@property (nonatomic, strong) NSMutableArray<SigSceneModel *> *scenes;

@property (nonatomic, strong) NSMutableArray<SigNetkeyModel *> *netKeys;

@property (nonatomic, strong) NSMutableArray<SigAppkeyModel *> *appKeys;

/// The networkExclusions property contains the array of exclusionList objects
@property (nonatomic, strong) NSMutableArray<SigExclusionModel *> *networkExclusions;

/*JSON中存储格式为：
 "standardUUID": {
 "type": "string",
 "name": "UUID",
 "pattern": "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"}
 */
@property (nonatomic, copy) NSString *meshUUID;

@property (nonatomic, copy) NSString *schema;
@property (nonatomic, copy) NSString *jsonFormatID;

@property (nonatomic, copy) NSString *version;

@property (nonatomic, copy) NSString *meshName;
/// The timestamp property contains a hexadecimal string that contains an integer representing the last time the Provisioner database has been modified. 
@property (nonatomic, copy) NSString *timestamp;

/// The partial property indicates if this Mesh Configuration Database is part of a larger database.
@property (nonatomic, assign) bool partial;

@property (nonatomic, copy) NSString *ivIndex;

@property (nonatomic,strong) NSMutableArray <SigEncryptedModel *>*encryptedArray;

/* default config value */
@property (nonatomic, strong) SigNetkeyModel *defaultNetKeyA;
@property (nonatomic, strong) SigAppkeyModel *defaultAppKeyA;
@property (nonatomic, strong) SigIvIndex *defaultIvIndexA;
@property (nonatomic, strong) SigNetkeyModel *curNetkeyModel;
@property (nonatomic, strong) SigAppkeyModel *curAppkeyModel;
/* cache value */
@property (nonatomic, strong) NSMutableArray<SigScanRspModel *> *scanList;
/// nodes should show in HomeViewController
@property (nonatomic,strong) NSMutableArray <SigNodeModel *>*curNodes;
/// There is the modelID that show in ModelIDListViewController, it is using when app use whiteList at keybind.
@property (nonatomic,strong) NSMutableArray <NSNumber *>*keyBindModelIDs;
/// modelID of subscription group
@property (nonatomic, strong) NSMutableArray <NSNumber *>*defaultGroupSubscriptionModels;
/// default nodeInfo for fast bind.
@property (nonatomic, strong) NSMutableArray <DeviceTypeModel *>*defaultNodeInfos;
/// get from source address of `setFilterForProvisioner:`
@property (nonatomic, assign) UInt16 unicastAddressOfConnected;
@property (nonatomic, assign) BOOL needPublishTimeModel;
@property (nonatomic, strong) NSMutableArray <SigOOBModel *>*OOBList;
/// `YES` means SDK will add staticOOB devcie that never input staticOOB data by noOOB provision. `NO` means SDK will not add staticOOB devcie that never input staticOOB data.
@property (nonatomic, assign) BOOL addStaticOOBDevcieByNoOOBEnable;
/// default retry count of every command. default is 2.
@property (nonatomic, assign) UInt8 defaultRetryCount;
/// 默认一个provisioner分配的设备地址区间，默认值为kAllocatedUnicastRangeHighAddress（0x400）.
@property (nonatomic, assign) UInt16 defaultAllocatedUnicastRangeHighAddress;
/// 默认sequenceNumber的步长，默认值为kSequenceNumberIncrement（128）.
@property (nonatomic, assign) UInt8 defaultSequenceNumberIncrement;
/// 默认一个unsegmented Access PDU的最大长度，大于该长度则需要进行segment分包，默认值为kUnsegmentedMessageLowerTransportPDUMaxLength（15，如onoff：2bytes opcode + 9bytes data(1byte onoff+1byte TID+7bytes other data) + 4bytes MIC）。默认一个segmented Access PDU的最大长度为kUnsegmentedMessageLowerTransportPDUMaxLength-3。
@property (nonatomic, assign) UInt16 defaultUnsegmentedMessageLowerTransportPDUMaxLength;
/// telink私有定义的Extend Bearer Mode，SDK默认是使用0，特殊用户需要用到2。
@property (nonatomic, assign) SigTelinkExtendBearerMode telinkExtendBearerMode;
/// 默认publish的周期，默认值为kPublishInterval（20），SigStepResolution_seconds.
@property (nonatomic, strong) SigPeriodModel *defaultPublishPeriodModel;
/// 0 means have response message, other means haven't response message.
//@property (nonatomic,assign) UInt32 responseOpCode;

/// Returns whether the message should be sent or has been sent using
/// 32-bit or 64-bit TransMIC value. By default `.low` is returned.
///
/// Only Segmented Access Messages can use 64-bit MIC. If the payload
/// is shorter than 11 bytes, make sure you return `true` from
/// `isSegmented`, otherwise this field will be ignored.
@property (nonatomic,assign) SigMeshMessageSecurity security;

/// sig mesh协议v1.1之后，SDK进行provision操作使用算法的配置项，默认为SigFipsP256EllipticCurve_auto，自动适配provision算法。
@property (nonatomic, assign) SigFipsP256EllipticCurve fipsP256EllipticCurve;

/// 非LPN节点的默认可靠发包间隔，默认值为1.28。
@property (nonatomic, assign) float defaultReliableIntervalOfNotLPN;
/// LPN节点的默认可靠发包间隔，默认值为2.56。
@property (nonatomic, assign) float defaultReliableIntervalOfLPN;

/// certificate-base provision 的根证书。 默认为APP端写死的root.der，开发者也可以自行修改该证书。
@property (nonatomic, strong) NSData *defaultRootCertificateData;


//取消该限制：因为客户可以init该类型，用于创建一个中间的mesh数据，用于比较前后的mesh信息。
//+ (instancetype)new __attribute__((unavailable("please initialize by use .share or .share()")));
//- (instancetype)init __attribute__((unavailable("please initialize by use .share or .share()")));


+ (SigDataSource *)share;

- (NSDictionary *)getDictionaryFromDataSource;
- (void)setDictionaryToDataSource:(NSDictionary *)dictionary;
- (NSDictionary *)getFormatDictionaryFromDataSource;

- (UInt16)provisionAddress;
- (SigProvisionerModel *)curProvisionerModel;
- (NSData *)curNetKey;
- (NSData *)curAppKey;
- (SigNodeModel *)curLocationNodeModel;
- (NSInteger)getOnlineDevicesNumber;
- (BOOL)hasNodeExistTimeModelID;
///Special handling: store the uuid of current provisioner.
- (void)saveCurrentProvisionerUUID:(NSString *)uuid;
///Special handling: get the uuid of current provisioner.
- (NSString *)getCurrentProvisionerUUID;

/// Init SDK location Data(include create mesh.json, check provisioner, provisionLocation)
- (void)configData;

/// check SigDataSource.provisioners, this api will auto create a provisioner when SigDataSource.provisioners hasn't provisioner corresponding to app's UUID.
- (void)checkExistLocationProvisioner;

- (void)changeLocationProvisionerNodeAddressToAddress:(UInt16)address;

- (void)addAndSaveNodeToMeshNetworkWithDeviceModel:(SigNodeModel *)model;

- (void)deleteNodeFromMeshNetworkWithDeviceAddress:(UInt16)deviceAddress;

- (void)editGroupIDsOfDevice:(BOOL)add unicastAddress:(NSNumber *)unicastAddress groupAddress:(NSNumber *)groupAddress;

- (void)setAllDevicesOutline;

- (void)saveLocationData;
- (void)saveLocationProvisionAddress:(NSInteger)address;

- (void)updateNodeStatusWithBaseMeshMessage:(SigBaseMeshMessage *)responseMessage source:(UInt16)source;

- (UInt16)getNewSceneAddress;
- (void)saveSceneModelWithModel:(SigSceneModel *)model;
- (void)delectSceneModelWithModel:(SigSceneModel *)model;

- (NSData *)getIvIndexData;
- (void)updateIvIndexString:(NSString *)ivIndexString;

- (int)getCurrentProvisionerIntSequenceNumber;
- (void)updateCurrentProvisionerIntSequenceNumber:(int)sequenceNumber;
- (void)setLocationSno:(UInt32)sno;

- (SigEncryptedModel *)getSigEncryptedModelWithAddress:(UInt16)address;
///Special handling: determine model whether exist current meshNetwork
- (BOOL)existScanRspModelOfCurrentMeshNetwork:(SigScanRspModel *)model;
///Special handling: determine peripheralUUIDString whether exist current meshNetwork
- (BOOL)existPeripheralUUIDString:(NSString *)peripheralUUIDString;
- (BOOL)matchNodeIdentityWithAdvertisementDataServiceData:(NSData *)advertisementDataServiceData peripheralUUIDString:(NSString *)peripheralUUIDString nodes:(NSArray <SigNodeModel *>*)nodes networkKey:(SigNetkeyModel *)networkKey;
- (BOOL)matchPrivateNetworkIdentityWithAdvertisementDataServiceData:(NSData *)advertisementDataServiceData peripheralUUIDString:(NSString *)peripheralUUIDString networkKey:(SigNetkeyModel *)networkKey;
- (BOOL)matchPrivateNodeIdentityWithAdvertisementDataServiceData:(NSData *)advertisementDataServiceData peripheralUUIDString:(NSString *)peripheralUUIDString nodes:(NSArray <SigNodeModel *>*)nodes networkKey:(SigNetkeyModel *)networkKey;

///Special handling: update the uuid and MAC mapping relationship.
- (void)updateScanRspModelToDataSource:(SigScanRspModel *)model;
- (SigScanRspModel *)getScanRspModelWithUUID:(NSString *)uuid;
- (SigScanRspModel *)getScanRspModelWithMac:(NSString *)mac;
- (SigScanRspModel *)getScanRspModelWithAddress:(UInt16)address;
- (void)deleteScanRspModelWithAddress:(UInt16)address;

- (SigNetkeyModel *)getNetkeyModelWithNetworkId:(NSData *)networkId;
- (SigNetkeyModel *)getNetkeyModelWithNetkeyIndex:(NSInteger)index;

- (SigAppkeyModel *)getAppkeyModelWithAppkeyIndex:(NSInteger)appkeyIndex;

- (SigNodeModel *)getNodeWithUUID:(NSString *)uuid;
- (SigNodeModel *)getNodeWithAddress:(UInt16)address;
- (SigNodeModel *)getDeviceWithMacAddress:(NSString *)macAddress;
- (SigNodeModel *)getCurrentConnectedNode;

- (ModelIDModel *)getModelIDModel:(NSNumber *)modelID;

- (SigGroupModel *)getGroupModelWithGroupAddress:(UInt16)groupAddress;

- (DeviceTypeModel *)getNodeInfoWithCID:(UInt16)CID PID:(UInt16)PID;

#pragma mark - OOB存取相关

- (void)addAndUpdateSigOOBModel:(SigOOBModel *)oobModel;
- (void)addAndUpdateSigOOBModelList:(NSArray <SigOOBModel *>*)oobModelList;
- (void)deleteSigOOBModel:(SigOOBModel *)oobModel;
- (void)deleteAllSigOOBModel;
- (SigOOBModel *)getSigOOBModelWithUUID:(NSString *)UUIDString;

#pragma mark - new api since v3.3.3

- (UInt16)getMaxUsedUnicastAddressOfJson;

- (UInt16)getMaxUsedUnicastAddressOfJsonWithProvisioner:(SigProvisionerModel *)provisioner;

- (UInt16)getMaxUsedUnicastAddressOfJsonWithUnicastRange:(SigRangeModel *)unicastRange;

/// 修正下一次添加设备使用的短地址到当前provisioner的地址范围，剩余地址个数小于10时给当前provisioner再申请一个地址区间
- (void)fixUnicastAddressOfAddDeviceOnAllocatedUnicastRange;

/// 地址范围是1~0x7FFF,其它值为地址耗尽，分配地址失败。返回用于添加设备的地址，如果APP未实现代理方法`onUpdateAllocatedUnicastRange:ofProvisioner:`则本Provisioner地址耗尽时会超界分配地址，如果APP实现了代理方法`onUpdateAllocatedUnicastRange:ofProvisioner:`则本Provisioner地址耗尽时会重新分配地址区间并通过该代理方法回调给APP，如果所有地址区间都已经分配完成则会超界分配地址且不新增区间也不回调区间更新方法。
- (UInt16)getNextUnicastAddressOfProvision;

/// 地址范围是1~0x7FFF,其它值为地址耗尽，分配地址失败。返回经过设备端返回的参数ElementCount进行修正后的添加设备地址。如区间1~0xFF已经使用到了0xFE，只剩下一个地址0xFF未使用，则当前provisioner添加的下一个设备的地址为0xFF，如果当前需要添加的设备的elementCount大于1，则需要重新修正添加的地址。
- (UInt16)getNextUnicastAddressOfProvisionWithElementCount:(UInt8)elementCount;

- (BOOL)addNewUnicastRangeToCurrentProvisioner;

- (NSString *)getKeyOfMaxUsedUnicastAddressOfLocationWithMeshUUID:(NSString *)meshUUID provisionerUUID:(NSString *)provisionerUUID;

/// 初始化一个mesh网络的数据。默认所有参数随机生成。不会清除SigDataSource.share里面的数据（包括scanList、sequenceNumber、sequenceNumberOnDelegate）。
- (instancetype)initDefaultMesh;

/// 清除SigDataSource.share里面的所有参数（包括scanList、sequenceNumber、sequenceNumberOnDelegate），并随机生成新的默认参数。
- (void)resetMesh;

- (void)updateNodeModelVidWithAddress:(UInt16)address vid:(UInt16)vid;

@end
