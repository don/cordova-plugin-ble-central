/********************************************************************************************************
 * @file     MeshOTAManager.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2018/4/24
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

typedef void(^ProgressBlock)(NSInteger progress);
typedef void(^ProgressReceiversListBlock)(SigFirmwareDistributionReceiversList *responseMessage);
typedef void(^FinishBlock)(NSArray <NSNumber *>*successAddresses,NSArray <NSNumber *>*failAddresses);
typedef void(^CompleteBlock)(BOOL isSuccess);
typedef void(^PeripheralStateChangeBlock)(CBPeripheral *peripheral);

typedef enum : UInt8 {
    SigMeshOTAProgressIdle                                = 0,
    SigMeshOTAProgressFirmwareDistributionStart           = 1,
    SigMeshOTAProgressSubscriptionAdd                     = 2,
    SigMeshOTAProgressFirmwareUpdateInformationGet        = 3,
    SigMeshOTAProgressFirmwareUpdateFirmwareMetadataCheck = 4,
    SigMeshOTAProgressFirmwareUpdateStart                 = 5,
    SigMeshOTAProgressBLOBTransferGet                     = 6,
    SigMeshOTAProgressBLOBInformationGet                  = 7,
    SigMeshOTAProgressBLOBTransferStart                   = 8,
    SigMeshOTAProgressBLOBBlockStart                      = 9,
    SigMeshOTAProgressBLOBChunkTransfer                   = 10,
    SigMeshOTAProgressBLOBBlockGet                        = 11,
    SigMeshOTAProgressFirmwareUpdateGet                   = 12,
    SigMeshOTAProgressFirmwareUpdateApply                 = 13,
    SigMeshOTAProgressFirmwareDistributionCancel          = 14,
} SigMeshOTAProgress;

typedef enum : UInt8 {
    SigFirmwareUpdateProgressIdle                                         = 0,
    SigFirmwareUpdateProgressCheckLastFirmwareUpdateStatue                = 1,
    SigFirmwareUpdateProgressFirmwareDistributionCapabilitiesGet          = 2,
    SigFirmwareUpdateProgressFirmwareUpdateInformationGet                 = 3,
    SigFirmwareUpdateProgressFirmwareUpdateFirmwareMetadataCheck          = 4,
    SigFirmwareUpdateProgressSubscriptionAdd                              = 5,
    SigFirmwareUpdateProgressFirmwareDistributionReceiversAdd             = 6,
    SigFirmwareUpdateProgressFirmwareDistributionUploadStart              = 7,
    SigFirmwareUpdateProgressInitiatorToDistributorBLOBTransferGet        = 8,
    SigFirmwareUpdateProgressInitiatorToDistributorBLOBInformationGet     = 9,
    SigFirmwareUpdateProgressInitiatorToDistributorBLOBTransferStart      = 10,
    SigFirmwareUpdateProgressInitiatorToDistributorBLOBBlockStart         = 11,
    SigFirmwareUpdateProgressInitiatorToDistributorBLOBChunkTransfer      = 12,
    SigFirmwareUpdateProgressInitiatorToDistributorBLOBBlockGet           = 13,
    SigFirmwareUpdateProgressFirmwareDistributionStart                    = 14,
    SigFirmwareUpdateProgressFirmwareUpdateStart                          = 15,
    SigFirmwareUpdateProgressDistributorToUpdatingNodesBLOBTransferGet    = 16,
    SigFirmwareUpdateProgressDistributorToUpdatingNodesBLOBInformationGet = 17,
    SigFirmwareUpdateProgressDistributorToUpdatingNodesBLOBTransferStart  = 18,
    SigFirmwareUpdateProgressDistributorToUpdatingNodesBLOBBlockStart     = 19,
    SigFirmwareUpdateProgressDistributorToUpdatingNodesBLOBChunkTransfer  = 20,
    SigFirmwareUpdateProgressDistributorToUpdatingNodesBLOBBlockGet       = 21,
    SigFirmwareUpdateProgressFirmwareDistributionReceiversGet             = 22,
    SigFirmwareUpdateProgressFirmwareDistributionApply                    = 23,
    SigFirmwareUpdateProgressFirmwareUpdateGet                            = 24,
    SigFirmwareUpdateProgressFirmwareUpdateApply                          = 25,
    SigFirmwareUpdateProgressFirmwareDistributionGet                      = 26,
    SigFirmwareUpdateInformationGetCheckVersion                           = 27,
    SigFirmwareUpdateProgressFirmwareDistributionCancel                   = 28,
} SigFirmwareUpdateProgress;

@interface MeshOTAManager : NSObject

@property (nonatomic, assign) UInt16 distributionAppKeyIndex;//parameters for step1:firmwareDistributionStart
@property (nonatomic, assign) SigTransferModeState transferModeOfDistributor;//parameters for step9:BLOBTransferStart and step8:BLOBTransferStart
@property (nonatomic, assign) SigTransferModeState transferModeOfUpdateNodes;//parameters for step1:firmwareDistributionStart and step8:BLOBTransferStart
/// default is NO, app neetn`t send firmwareDistributionApply.
@property (nonatomic, assign) SigUpdatePolicyType updatePolicy;//parameters for step1:firmwareDistributionStart
/// Multicast address used in a firmware image distribution. Size is 16 bits or 128 bits.
@property (nonatomic,strong) NSData *distributionMulticastAddress;//parameters for step1:firmwareDistributionStart
@property (nonatomic, assign) UInt16 distributionFirmwareImageIndex;//parameters for step1:firmwareDistributionStart
@property (nonatomic, strong) NSData *incomingFirmwareMetadata;//parameters for step4:firmwareUpdateFirmwareMetadataCheck and step5:firmwareUpdateStart
@property (nonatomic, assign) UInt16 updateFirmwareImageIndex;//parameters for step4:firmwareUpdateFirmwareMetadataCheck and step5:firmwareUpdateStart
@property (nonatomic, assign) UInt8 updateTTL;//parameters for step14:firmwareUpdateStart
@property (nonatomic, assign) UInt8 uploadTTL;//parameters for step6:firmwareDistributionUploadStart
@property (nonatomic, assign) UInt8 distributionTTL;//parameters for step13:firmwareDistributionStart
@property (nonatomic, assign) UInt16 updateTimeoutBase;//parameters for step14:firmwareUpdateStart
@property (nonatomic, assign) UInt16 uploadTimeoutBase;//parameters for step6:firmwareDistributionUploadStart
@property (nonatomic, assign) UInt16 distributionTimeoutBase;//parameters for step13:firmwareDistributionStart
@property (nonatomic, assign) UInt64 updateBLOBID;//parameters for step5:firmwareUpdateStart and step8:BLOBTransferStart
@property (nonatomic, assign) UInt64 updateBLOBIDForDistributor;//parameters for step5:firmwareUpdateStart and step8:BLOBTransferStart
@property (nonatomic, assign) UInt16 MTUSize;//parameters for step8:BLOBTransferStart
@property (nonatomic, assign) BOOL phoneIsDistributor;//记录手机是否作为Distributor角色，默认为NO，即直连节点支持作为Distributor则使用直连节点作为Distributor，否则才使用手机作为Distributor。YES则固定手机作为Distributor。
@property (nonatomic, assign) UInt16 distributorAddress;
@property (nonatomic, strong) NSMutableArray <NSNumber *>*allAddressArray;//Mesh OTA的所有短地址列表

@property (nonatomic, copy) PeripheralStateChangeBlock peripheralStateChangeBlock;
/// default is NO. YES则在apply后获取设备的固件版本号进行比较，版本号增大则OTA成功；NO则在apply后不比较版本号就返回OTA结果，apply成功则OTA成功。
@property (nonatomic, assign) BOOL needCheckVersionAfterApply;
@property (nonatomic, assign) NSInteger checkVersionCount;//记录当前还需要检查固件版本号的次数，检查一次减一，等零后进入下一步骤。



+ (instancetype)new __attribute__((unavailable("please initialize by use .share or .share()")));
- (instancetype)init __attribute__((unavailable("please initialize by use .share or .share()")));


+ (MeshOTAManager *)share;

/// developer call this api to start mesh ota.
- (void)startMeshOTAWithLocationAddress:(int)locationAddress deviceAddresses:(NSArray <NSNumber *>*)deviceAddresses otaData:(NSData *)otaData incomingFirmwareMetadata:(NSData *)incomingFirmwareMetadata progressHandle:(ProgressBlock)progressBlock finishHandle:(FinishBlock)finishBlock errorHandle:(ErrorBlock)errorBlock;

/// stop meshOTA, developer needn't call this api but midway stop mesh ota procress.
- (void)stopMeshOTA;

/// 查询当前是否处在meshOTA
- (BOOL)isMeshOTAing;

- (void)saveIsMeshOTAing:(BOOL)isMeshOTAing;


/// 开始MeshOTA
/// @param deviceAddresses 需要升级的设备地址数组
/// @param otaData 需要升级的设备firmware数据
/// @param incomingFirmwareMetadata meshOTA校验数据
/// @param gattDistributionProgressBlock initiator->Distributor阶段升级的进度回调
/// @param advDistributionProgressBlock Distributor->updating node(s)阶段升级的进度回调
/// @param finishBlock 升级完成的回调
/// @param errorBlock 升级失败的回调
- (void)startFirmwareUpdateWithDeviceAddresses:(NSArray <NSNumber *>*)deviceAddresses otaData:(NSData *)otaData incomingFirmwareMetadata:(NSData *)incomingFirmwareMetadata gattDistributionProgressHandle:(ProgressBlock)gattDistributionProgressBlock advDistributionProgressHandle:(ProgressReceiversListBlock)advDistributionProgressBlock finishHandle:(FinishBlock)finishBlock errorHandle:(ErrorBlock)errorBlock;


/// 继续MeshOTA，仅用于直连节点作为Distributor时，Distributor处于广播firmware到updating node(s)阶段才可用，其它情况不可继续上一次未完成的meshOTA。
/// @param deviceAddresses 需要升级的设备地址数组
/// @param advDistributionProgressBlock Distributor->updating node(s)阶段升级的进度回调
/// @param finishBlock 升级完成的回调
/// @param errorBlock 升级失败的回调
- (void)continueFirmwareUpdateWithDeviceAddresses:(NSArray <NSNumber *>*)deviceAddresses advDistributionProgressHandle:(ProgressReceiversListBlock)advDistributionProgressBlock finishHandle:(FinishBlock)finishBlock errorHandle:(ErrorBlock)errorBlock;

- (void)stopFirmwareUpdateWithCompleteHandle:(CompleteBlock)completeBlock;

@end
