/********************************************************************************************************
 * @file     OTAManager.m 
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2018/7/18
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

#import "OTAManager.h"

typedef enum : NSUInteger {
    SigGattOTAProgress_idle                                     = 0,
    SigGattOTAProgress_step1_startMeshConnectBeforeGATTOTA      = 1,
    SigGattOTAProgress_step2_nodeIdentitySetBeforeGATTOTA       = 2,
    SigGattOTAProgress_step3_startScanNodeIdentityBeforeGATTOTA = 3,
    SigGattOTAProgress_step4_startConnectCBPeripheral           = 4,
    SigGattOTAProgress_step5_setFilter                          = 5,
    SigGattOTAProgress_step6_startSendGATTOTAPackets            = 6,
} SigGattOTAProgress;

@interface OTAManager()<SigBearerDataDelegate>

@property (nonatomic,strong) SigBearer *bearer;
@property (nonatomic, weak) id <SigBearerDataDelegate>oldBearerDataDelegate;

@property (nonatomic,assign) NSTimeInterval writeOTAInterval;//interval of write ota data, default is 6ms
@property (nonatomic,assign) NSTimeInterval readTimeoutInterval;//timeout of read OTACharacteristic(write 8 packet, read one time), default is 5s.

@property (nonatomic,strong) SigNodeModel *currentModel;
@property (nonatomic,strong) NSString *currentUUID;
@property (nonatomic,strong) NSMutableArray <SigNodeModel *>*allModels;
@property (nonatomic,assign) NSInteger currentIndex;

@property (nonatomic,copy) singleDeviceCallBack singleSuccessCallBack;
@property (nonatomic,copy) singleDeviceCallBack singleFailCallBack;
@property (nonatomic,copy) singleProgressCallBack singleProgressCallBack;
@property (nonatomic,copy) finishCallBack finishCallBack;
@property (nonatomic,strong) NSMutableArray <SigNodeModel *>*successModels;
@property (nonatomic,strong) NSMutableArray <SigNodeModel *>*failModels;

@property (nonatomic,assign) BOOL OTAing;
@property (nonatomic,assign) BOOL stopOTAFlag;
@property (nonatomic,assign) NSInteger offset;
@property (nonatomic,assign) NSInteger otaIndex;//index of current ota packet
@property (nonatomic,strong) NSData *localData;
@property (nonatomic,assign) BOOL sendFinish;
@property (nonatomic,assign) SigGattOTAProgress progress;



@end

@implementation OTAManager

+ (OTAManager *)share{
    static OTAManager *shareOTA = nil;
    static dispatch_once_t tempOnce=0;
    dispatch_once(&tempOnce, ^{
        shareOTA = [[OTAManager alloc] init];
        [shareOTA initData];
    });
    return shareOTA;
}

- (void)initData{
    _bearer = SigBearer.share;
    
    _writeOTAInterval = 0.006;
    _readTimeoutInterval = 5.0;
    
    _currentUUID = @"";
    _currentIndex = 0;
    
    _OTAing = NO;
    _stopOTAFlag = NO;
    _offset = 0;
    _otaIndex = -1;
    _sendFinish = NO;
    _progress = SigGattOTAProgress_idle;
    
    _allModels = [[NSMutableArray alloc] init];
    _successModels = [[NSMutableArray alloc] init];
    _failModels = [[NSMutableArray alloc] init];
}


/**
 OTA，can not call repeat when app is OTAing

 @param otaData data for OTA
 @param models models for OTA
 @param singleSuccessAction callback when single model OTA  success
 @param singleFailAction callback when single model OTA  fail
 @param singleProgressAction callback with single model OTA progress
 @param finishAction callback when all models OTA finish
 @return use API success is ture;user API fail is false.
 */
- (BOOL)startOTAWithOtaData:(NSData *)otaData models:(NSArray <SigNodeModel *>*)models singleSuccessAction:(singleDeviceCallBack)singleSuccessAction singleFailAction:(singleDeviceCallBack)singleFailAction singleProgressAction:(singleProgressCallBack)singleProgressAction finishAction:(finishCallBack)finishAction{
    if (_OTAing) {
        TeLogInfo(@"OTAing, can't call repeated.");
        return NO;
    }
    if (!otaData || otaData.length == 0) {
        TeLogInfo(@"OTA data is invalid.");
        return NO;
    }
    if (models.count == 0) {
        TeLogInfo(@"OTA devices list is invaid.");
        return NO;
    }
    
    _localData = otaData;
    [_allModels removeAllObjects];
    [_allModels addObjectsFromArray:models];
    _currentIndex = 0;
    _singleSuccessCallBack = singleSuccessAction;
    _singleFailCallBack = singleFailAction;
    _singleProgressCallBack = singleProgressAction;
    _finishCallBack = finishAction;
    [_successModels removeAllObjects];
    [_failModels removeAllObjects];
    
    if (_bearer.dataDelegate) {
        self.oldBearerDataDelegate = _bearer.dataDelegate;
    }
    _bearer.dataDelegate = self;
    
    [self refreshCurrentModel];
    SigBearer.share.isAutoReconnect = NO;
    [self otaNext];
    
    return YES;
}

/// stop OTA
- (void)stopOTA{
    [SigBluetooth.share stopScan];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    });
    if (_OTAing) {
        [SDKLibCommand stopMeshConnectWithComplete:nil];
    }
    [SDKLibCommand cancelReadOTACharachteristic];
    _singleSuccessCallBack = nil;
    _singleFailCallBack = nil;
    _singleProgressCallBack = nil;
    _finishCallBack = nil;
    _stopOTAFlag = YES;
    _OTAing = NO;
    _progress = SigGattOTAProgress_idle;
    if (self.oldBearerDataDelegate) {
        _bearer.dataDelegate = self.oldBearerDataDelegate;
    }
}

- (void)connectDevice{
    if (SigBearer.share.isOpen) {
        if (SigMeshLib.share.dataSource.unicastAddressOfConnected == self.currentModel.address) {
            [self setFilter];
        } else {
            [self nodeIdentitySetBeforeGATTOTA];
        }
    } else {
        [self startMeshConnectBeforeGATTOTA];
    }
}

#pragma mark step1:startMeshConnectBeforeGATTOTA
- (void)startMeshConnectBeforeGATTOTA {
    TeLogInfo(@"\n\n==========GATT OTA:step1\n\n");
    self.progress = SigGattOTAProgress_step1_startMeshConnectBeforeGATTOTA;
    __weak typeof(self) weakSelf = self;
    [SDKLibCommand startMeshConnectWithComplete:^(BOOL successful) {
        if (weakSelf.progress == SigGattOTAProgress_step1_startMeshConnectBeforeGATTOTA) {
            if (successful) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(meshConnectTimeoutBeforeGATTOTA) object:nil];
                });
                if (SigMeshLib.share.dataSource.unicastAddressOfConnected == self.currentModel.address) {
                    [weakSelf setFilter];
                } else {
                    [weakSelf nodeIdentitySetBeforeGATTOTA];
                }
            }
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(meshConnectTimeoutBeforeGATTOTA) object:nil];
        [self performSelector:@selector(meshConnectTimeoutBeforeGATTOTA) withObject:nil afterDelay:10.0];
    });
}

/// OTA前直连设备超时。
- (void)meshConnectTimeoutBeforeGATTOTA {
    TeLogInfo(@"OTA fail: startMeshConnect Timeout Before GATT OTA.");
    [self otaFailAction];
}

#pragma mark step2:nodeIdentitySetBeforeGATTOTA
- (void)nodeIdentitySetBeforeGATTOTA {
    TeLogInfo(@"\n\n==========GATT OTA:step2\n\n");
    self.progress = SigGattOTAProgress_step2_nodeIdentitySetBeforeGATTOTA;
    __weak typeof(self) weakSelf = self;
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperationWithBlock:^{
        //这个block语句块在子线程中执行
        __block BOOL hasSuccess = NO;        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [SDKLibCommand configNodeIdentitySetWithDestination:weakSelf.currentModel.address netKeyIndex:SigMeshLib.share.dataSource.curNetkeyModel.index identity:SigNodeIdentityState_enabled retryCount:SigMeshLib.share.dataSource.defaultRetryCount responseMaxCount:1 successCallback:^(UInt16 source, UInt16 destination, SigConfigNodeIdentityStatus * _Nonnull responseMessage) {
            TeLogInfo(@"configNodeIdentitySetWithDestination=%@,source=%d,destination=%d",[LibTools convertDataToHexStr:responseMessage.parameters],source,destination);
        } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
            if (!error) {
                hasSuccess = YES;
            }
            dispatch_semaphore_signal(semaphore);
            TeLogInfo(@"isResponseAll=%d,error=%@",isResponseAll,error);
        }];
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 4.0));
        [SDKLibCommand stopMeshConnectWithComplete:^(BOOL successful) {
            if (weakSelf.progress == SigGattOTAProgress_step2_nodeIdentitySetBeforeGATTOTA) {
                if (hasSuccess) {
                    [weakSelf startScanNodeIdentityBeforeGATTOTA];
                } else {
                    NSString *errStr = @"OTA fail: nodeIdentitySet fail Before GATT OTA.";
                    TeLogInfo(@"%@",errStr);
                    [weakSelf otaFailAction];
                }
            }
        }];
    }];
}

#pragma mark step3:startScanNodeIdentityBeforeGATTOTA
- (void)startScanNodeIdentityBeforeGATTOTA {
    TeLogInfo(@"\n\n==========GATT OTA:step3\n\n");
    self.progress = SigGattOTAProgress_step3_startScanNodeIdentityBeforeGATTOTA;
    __weak typeof(self) weakSelf = self;
    [SigBluetooth.share scanProvisionedDevicesWithResult:^(CBPeripheral * _Nonnull peripheral, NSDictionary<NSString *,id> * _Nonnull advertisementData, NSNumber * _Nonnull RSSI, BOOL unprovisioned) {
        if (!unprovisioned) {
            SigScanRspModel *rspModel = [SigMeshLib.share.dataSource getScanRspModelWithUUID:peripheral.identifier.UUIDString];
            if (rspModel.getIdentificationType == SigIdentificationType_nodeIdentity || rspModel.getIdentificationType == SigIdentificationType_privateNodeIdentity) {
                SigEncryptedModel *encryptedModel = [SigMeshLib.share.dataSource getSigEncryptedModelWithAddress:weakSelf.currentModel.address];
                if (encryptedModel && encryptedModel.advertisementDataServiceData && encryptedModel.advertisementDataServiceData.length == 17 && [encryptedModel.advertisementDataServiceData isEqualToData:rspModel.advertisementDataServiceData]) {
                    TeLogInfo(@"gatt ota start connect macAddress:%@",rspModel.macAddress);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(scanNodeIdentityTimeoutBeforeGATTOTA) object:nil];
                    });
                    //扫描到当前需要OTA的设备
                    [SigBluetooth.share stopScan];
                    //更新uuid
                    [weakSelf refreshCurrentModel];
                    [weakSelf startConnectCBPeripheral:peripheral];
                } else {
                    if ([rspModel.macAddress isEqualToString:@"A4C138BB9CF7"]) {
                        TeLogInfo(@"encryptedModel=%@",encryptedModel);
                    }
                }
            }
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scanNodeIdentityTimeoutBeforeGATTOTA) object:nil];
        [self performSelector:@selector(scanNodeIdentityTimeoutBeforeGATTOTA) withObject:nil afterDelay:10.0];
    });
}

- (void)scanNodeIdentityTimeoutBeforeGATTOTA{
    [self otaFailAction];
}

#pragma mark step4:startConnectCBPeripheral
- (void)startConnectCBPeripheral:(CBPeripheral *)peripheral {
    TeLogInfo(@"\n\n==========GATT OTA:step4\n\n");
    self.progress = SigGattOTAProgress_step4_startConnectCBPeripheral;
    __weak typeof(self) weakSelf = self;
    [SigBearer.share connectAndReadServicesWithPeripheral:peripheral result:^(BOOL successful) {
        if (weakSelf.progress == SigGattOTAProgress_step4_startConnectCBPeripheral) {
            if (successful) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(setFilter) object:nil];
                    [weakSelf performSelector:@selector(setFilter) withObject:nil afterDelay:0.5];
                });
            } else {
                [weakSelf connectCBPeripheralFail];
            }
        }
    }];
}

- (void)connectCBPeripheralFail {
    TeLogInfo(@"OTA fail: connectCBPeripheral fail Before GATT OTA.");
    [self otaFailAction];
}

#pragma mark step5:setFilter
- (void)setFilter {
    TeLogInfo(@"\n\n==========GATT OTA:step5\n\n");
    self.progress = SigGattOTAProgress_step5_setFilter;
    __weak typeof(self) weakSelf = self;
    [SDKLibCommand setFilterForProvisioner:SigMeshLib.share.dataSource.curProvisionerModel successCallback:^(UInt16 source, UInt16 destination, SigFilterStatus * _Nonnull responseMessage) {
        TeLogInfo(@"setFilterForProvisioner=%@,source=%d,destination=%d",[LibTools convertDataToHexStr:responseMessage.parameters],source,destination);
    } finishCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
        TeLogInfo(@"isResponseAll=%d,error=%@",isResponseAll,error);
        if (weakSelf.progress == SigGattOTAProgress_step5_setFilter) {
            if (error) {
                [weakSelf setFilterFail];
            } else {
                [weakSelf startSendGATTOTAPackets];
            }
        }
    }];
}

- (void)setFilterFail {
    TeLogInfo(@"OTA fail: setFilter fail Before GATT OTA.");
    [self otaFailAction];
}

#pragma mark step6:startSendGATTOTAPackets
- (void)startSendGATTOTAPackets {
    TeLogInfo(@"\n\n==========GATT OTA:step6\n\n");
    self.progress = SigGattOTAProgress_step6_startSendGATTOTAPackets;
    if (@available(iOS 11.0, *)) {
        //ios11.0及以上，6ms发送一个包，SendPacketsFinishCallback这个block返回则发送下一个包，不需要read。127KB耗时75秒
        [self sendPartDataAvailableIOS11];
    } else {
        //ios11.0以下，6ms发送一个包，发送8个包read一次OTA特征，read返回则发送下一组8个包。127KB耗时115~120秒
        [self sendPartData];
    }
}

- (void)sendPartDataAvailableIOS11 {
    if (self.stopOTAFlag) {
        return;
    }
    if (self.currentModel && _bearer.getCurrentPeripheral && _bearer.getCurrentPeripheral.state == CBPeripheralStateConnected) {
        NSInteger lastLength = _localData.length - _offset;
        
        //OTA 结束包特殊处理
        if (lastLength == 0) {
            Byte byte[] = {0x02,0xff};
            NSData *endData = [NSData dataWithBytes:byte length:2];
            [self sendOTAEndData:endData index:(int)self.otaIndex complete:nil];
            self.sendFinish = YES;
            return;
        }
        
        self.otaIndex ++;
        //OTA开始包特殊处理
        if (self.otaIndex == 0) {
            [self sendReadFirmwareVersionWithComplete:nil];
            [self sendStartOTAWithComplete:nil];
        }
        
        NSInteger writeLength = (lastLength >= 16) ? 16 : lastLength;
        NSData *writeData = [self.localData subdataWithRange:NSMakeRange(self.offset, writeLength)];
        self.offset += writeLength;
        float progress = (self.offset * 100.0) / self.localData.length;
        if (self.singleProgressCallBack) {
            self.singleProgressCallBack(progress);
        }
        __weak typeof(self) weakSelf = self;
        [self sendOTAData:writeData index:(int)self.otaIndex complete:^{
            //注意：index=0与index=1之间的时间间隔修改为300ms，让固件有充足的时间进行ota配置。
            if (weakSelf.otaIndex == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf performSelector:@selector(sendPartDataAvailableIOS11) withObject:nil afterDelay:0.3];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf performSelector:@selector(sendPartDataAvailableIOS11) withObject:nil afterDelay:weakSelf.writeOTAInterval];
                });
            }
        }];
    }
}

- (void)sendPartData {
    if (self.stopOTAFlag) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(readTimeout) object:nil];
    });
    
    if (self.currentModel && _bearer.getCurrentPeripheral && _bearer.getCurrentPeripheral.state == CBPeripheralStateConnected) {
        NSInteger lastLength = _localData.length - _offset;
        
        //OTA 结束包特殊处理
        if (lastLength == 0) {
            Byte byte[] = {0x02,0xff};
            NSData *endData = [NSData dataWithBytes:byte length:2];
            [self sendOTAEndData:endData index:(int)self.otaIndex complete:nil];
            self.sendFinish = YES;
            return;
        }
        
        self.otaIndex ++;
        //OTA开始包特殊处理
        if (self.otaIndex == 0) {
            [self sendReadFirmwareVersionWithComplete:nil];
            [self sendStartOTAWithComplete:nil];
        }
        
        NSInteger writeLength = (lastLength >= 16) ? 16 : lastLength;
        NSData *writeData = [self.localData subdataWithRange:NSMakeRange(self.offset, writeLength)];
        [self sendOTAData:writeData index:(int)self.otaIndex complete:nil];
        self.offset += writeLength;
        
        float progress = (self.offset * 100.0) / self.localData.length;
        if (self.singleProgressCallBack) {
            self.singleProgressCallBack(progress);
        }
        
        if ((self.otaIndex + 1) % 8 == 0) {
            __weak typeof(self) weakSelf = self;
            [SDKLibCommand readOTACharachteristicWithTimeout:self.readTimeoutInterval complete:^(CBCharacteristic * _Nonnull characteristic, BOOL successful) {
                if (successful) {
                    [weakSelf sendPartData];
                } else {
                    [weakSelf readTimeout];
                }
            }];
            return;
        }
        //注意：index=0与index=1之间的时间间隔修改为300ms，让固件有充足的时间进行ota配置。
        NSTimeInterval timeInterval = self.writeOTAInterval;
        if (self.otaIndex == 0) {
            timeInterval = 0.3;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(sendPartData) withObject:nil afterDelay:timeInterval];
        });
    }
}

- (void)readTimeout{
    [self otaFailAction];
}

- (void)otaSuccessAction{
    self.progress = SigGattOTAProgress_idle;
    self.OTAing = NO;
    self.sendFinish = NO;
    self.stopOTAFlag = YES;
    if (self.singleSuccessCallBack) {
        self.singleSuccessCallBack(self.currentModel);
    }
    [self.successModels addObject:self.currentModel];
    self.currentIndex ++;
    [self refreshCurrentModel];
    [self otaNext];
}

- (void)otaFailAction{
    self.progress = SigGattOTAProgress_idle;
    self.OTAing = NO;
    self.sendFinish = NO;
    self.stopOTAFlag = YES;
    [SigBluetooth.share cancelReadOTACharachteristic];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    });
    [SDKLibCommand stopMeshConnectWithComplete:nil];
    if (self.singleFailCallBack) {
        self.singleFailCallBack(self.currentModel);
    }
    [self.failModels addObject:self.currentModel];
    self.currentIndex ++;
    [self refreshCurrentModel];
    [self otaNext];
}

- (void)refreshCurrentModel{
    if (self.currentIndex < self.allModels.count) {
        self.currentModel = self.allModels[self.currentIndex];
        if (SigMeshLib.share.dataSource.unicastAddressOfConnected == self.currentModel.address) {
            self.currentUUID = SigBearer.share.getCurrentPeripheral.identifier.UUIDString;
        } else {
            self.currentUUID = [SigMeshLib.share.dataSource getNodeWithAddress:self.currentModel.address].peripheralUUID;
        }
    }else{
        if (self.oldBearerDataDelegate) {
            _bearer.dataDelegate = self.oldBearerDataDelegate;
        }
    }
}

- (void)otaNext{
    if (self.currentIndex == self.allModels.count) {
        //all devices are OTA finished.
        if (self.finishCallBack) {
            self.finishCallBack(self.successModels,self.failModels);
        }
    } else {
        self.OTAing = YES;
        self.stopOTAFlag = NO;
        self.otaIndex = -1;
        self.offset = 0;
        [self connectDevice];
    }
}

#pragma mark - SigBearerDataDelegate

- (void)bearer:(SigBearer *)bearer didCloseWithError:(NSError *)error {
    TeLogInfo(@"");
    if ([_bearer.getCurrentPeripheral.identifier.UUIDString isEqualToString:self.currentUUID]) {
        if (self.progress != SigGattOTAProgress_step2_nodeIdentitySetBeforeGATTOTA) {
            if (self.sendFinish) {
                [self otaSuccessAction];
            } else {
                [self otaFailAction];
            }
        }
    }
}

#pragma mark - OTA packet

- (void)sendOTAData:(NSData *)data index:(int)index complete:(SendPacketsFinishCallback)complete {
    BOOL isEnd = data.length == 0;
    int countIndex = index;
    Byte *tempBytes = (Byte *)[data bytes];
    Byte resultBytes[20];
    
    memset(resultBytes, 0xff, 20);
    memcpy(resultBytes, &countIndex, 2);
    memcpy(resultBytes+2, tempBytes, data.length);
    uint16_t crc = crc16(resultBytes, isEnd ? 2 : 18);
    memcpy(isEnd ? (resultBytes + 2) : (resultBytes+18), &crc, 2);
    NSData *writeData = [NSData dataWithBytes:resultBytes length:isEnd ? 4 : 20];
    [_bearer sendOTAData:writeData complete:complete];
}

- (void)sendReadFirmwareVersionWithComplete:(SendPacketsFinishCallback)complete {
    uint8_t buf[2] = {0x00,0xff};
    NSData *writeData = [NSData dataWithBytes:buf length:2];
    TeLogInfo(@"sendReadFirmwareVersion -> length:%lu,%@",(unsigned long)writeData.length,writeData);
    [_bearer sendOTAData:writeData complete:complete];
}

- (void)sendStartOTAWithComplete:(SendPacketsFinishCallback)complete {
    uint8_t buf[2] = {0x01,0xff};
    NSData *writeData = [NSData dataWithBytes:buf length:2];
    TeLogInfo(@"sendStartOTA -> length:%lu,%@",(unsigned long)writeData.length,writeData);
    [_bearer sendOTAData:writeData complete:complete];
}

/*
 packet of end OTA 6 bytes structure：1byte:0x02 + 1byte:0xff + 2bytes:index + 2bytes:~index
 */
- (void)sendOTAEndData:(NSData *)data index:(int)index complete:(SendPacketsFinishCallback)complete {
    int negationIndex = ~index;
    Byte *tempBytes = (Byte *)[data bytes];
    Byte resultBytes[6];
    
    memset(resultBytes, 0xff, 6);
    memcpy(resultBytes, tempBytes, data.length);
    memcpy(resultBytes+2, &index, 2);
    memcpy(resultBytes+4, &negationIndex, 2);
    NSData *writeData = [NSData dataWithBytes:resultBytes length:6];
    TeLogInfo(@"sendOTAEndData -> %04x ,length:%lu,%@", index,(unsigned long)writeData.length,writeData);
    [_bearer sendOTAData:writeData complete:complete];
    TeLogInfo(@"\n\n==========GATT OTA:end\n\n");
}

@end
