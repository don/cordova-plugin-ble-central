/********************************************************************************************************
 * @file     SigFastProvisionAddManager.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2020/4/2
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

#import "SigFastProvisionAddManager.h"

@interface SigFastProvisionModel : NSObject
@property (nonatomic, strong) NSData *macAddress;
@property (nonatomic, assign) UInt16 sourceUnicastAddress;
@property (nonatomic, assign) UInt16 productId;
@property (nonatomic, assign) UInt16 address;
@property (nonatomic, strong) NSData *deviceKey;
@end


@implementation SigFastProvisionModel

- (NSData *)deviceKey {
    if (!_deviceKey && _macAddress && _macAddress.length) {
        Byte byte[10];
        memset(byte, 0, 10);
        NSData *data = [NSData dataWithBytes:byte length:10];
        NSMutableData *mData = [NSMutableData data];
        [mData appendData:_macAddress];
        [mData appendData:data];
        _deviceKey = mData;
    }
    return _deviceKey;;
}

- (BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[SigFastProvisionModel class]]) {
        return [_macAddress isEqualToData:[(SigFastProvisionModel *)object macAddress]];
    } else {
        return NO;
    }
}

@end


@interface SigFastProvisionAddManager ()
@property (nonatomic, assign) SigFastProvisionStatus  fastProvisionStatus;
@property (nonatomic, assign) UInt16 provisionAddress;
//@property (nonatomic, assign) UInt16 productId;
@property (nonatomic, strong) NSArray <NSNumber *>* productIds;
//@property (nonatomic, strong) SigPage0 *page0;
@property (nonatomic, copy) ScanCallbackOfFastProvisionCallBack scanResponseBlock;
@property (nonatomic, copy) StartProvisionCallbackOfFastProvisionCallBack startProvisionBlock;
@property (nonatomic, copy) AddSingleDeviceSuccessOfFastProvisionCallBack singleSuccessBlock;
@property (nonatomic, copy) ErrorBlock finishBlock;
//@property (nonatomic, strong) NSData *compositionData;
@property (nonatomic, strong) NSMutableArray <SigFastProvisionModel *>*scanMacAddressList;
@property (nonatomic, strong) NSMutableArray <SigFastProvisionModel *>*setAddressList;
@property (nonatomic, assign) BOOL currentConnectedNodeIsUnprovisioned;

@end

@implementation SigFastProvisionAddManager

+ (SigFastProvisionAddManager *)share {
    static SigFastProvisionAddManager *shareManager = nil;
    static dispatch_once_t tempOnce=0;
    dispatch_once(&tempOnce, ^{
        shareManager = [[SigFastProvisionAddManager alloc] init];
    });
    return shareManager;
}

/// start FastProvision
/// @param provisionAddress  new unicastAddress for unprovision device.
/// @param productId  product id of unprovision device, 0xffff means provision all unprovision device, but develop can't use 0xffff in this api.
/// @param compositionData compositionData of node in this productId.
/// @param unprovisioned current Connected Node Is Unprovisioned?
/// @param scanResponseBlock callback when SDK scaned unprovision devcie successful.
/// @param startProvisionBlock callback when SDK start provision devcie.
/// @param singleSuccess callback when SDK add single devcie successful.
/// @param finish callback when fast provision finish, fast provision successful when error is nil.
- (void)startFastProvisionWithProvisionAddress:(UInt16)provisionAddress productId:(UInt16)productId compositionData:(NSData *)compositionData currentConnectedNodeIsUnprovisioned:(BOOL)unprovisioned scanResponseCallback:(ScanCallbackOfFastProvisionCallBack)scanResponseBlock startProvisionCallback:(StartProvisionCallbackOfFastProvisionCallBack)startProvisionBlock addSingleDeviceSuccessCallback:(AddSingleDeviceSuccessOfFastProvisionCallBack)singleSuccess finish:(ErrorBlock)finish {
    if (self.fastProvisionStatus != SigFastProvisionStatus_idle) {
        NSString *errstr = [NSString stringWithFormat:@"fastProvisionStatus is %d, needn't call again.",self.fastProvisionStatus];
        TeLogError(@"%@",errstr);
        NSError *err = [NSError errorWithDomain:errstr code:-1 userInfo:nil];
        if (finish) {
            finish(err);
        }
        return;
    }
    self.fastProvisionStatus = SigFastProvisionStatus_start;
    self.provisionAddress = provisionAddress;
//    self.productId = productId;
    self.productIds = [NSArray arrayWithObject:[NSNumber numberWithInt:productId]];
//    self.compositionData = compositionData;
    self.currentConnectedNodeIsUnprovisioned = unprovisioned;
    
    NSMutableData *mData = [NSMutableData data];
    UInt8 page0 = 0;
    [mData appendData:[NSData dataWithBytes:&page0 length:1]];
    [mData appendData:compositionData];
    SigPage0 *page = [[SigPage0 alloc] initWithParameters:mData];
    if (page.productIdentifier != productId) {
        if (self.finishBlock) {
            NSError *error = [NSError errorWithDomain:@"productId is different from the PID of compositionData." code:-1 userInfo:nil];
            self.finishBlock(error);
        }
        return;
    }
    
    DeviceTypeModel *model = [[DeviceTypeModel alloc] initWithCID:kCompanyID PID:productId];
    [model setCompositionData:compositionData];
    DeviceTypeModel *lodModel = [SigDataSource.share getNodeInfoWithCID:kCompanyID PID:productId];
    if (lodModel) {
        [SigDataSource.share.defaultNodeInfos replaceObjectAtIndex:[SigDataSource.share.defaultNodeInfos indexOfObject:lodModel] withObject:model];
    }
    
    self.scanResponseBlock = scanResponseBlock;
    self.startProvisionBlock = startProvisionBlock;
    self.singleSuccessBlock = singleSuccess;
    self.finishBlock = finish;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fastProvisionTimeoutAction) object:nil];
        [self performSelector:@selector(fastProvisionTimeoutAction) withObject:nil afterDelay:60.0];
    });
    [self resetNetwork];
}

- (void)startFastProvisionWithProvisionAddress:(UInt16)provisionAddress productIds:(NSArray <NSNumber *>*)productIds currentConnectedNodeIsUnprovisioned:(BOOL)unprovisioned scanResponseCallback:(ScanCallbackOfFastProvisionCallBack)scanResponseBlock startProvisionCallback:(StartProvisionCallbackOfFastProvisionCallBack)startProvisionBlock addSingleDeviceSuccessCallback:(AddSingleDeviceSuccessOfFastProvisionCallBack)singleSuccess finish:(ErrorBlock)finish {
    if (self.fastProvisionStatus != SigFastProvisionStatus_idle) {
        NSString *errstr = [NSString stringWithFormat:@"fastProvisionStatus is %d, needn't call again.",self.fastProvisionStatus];
        TeLogError(@"%@",errstr);
        NSError *err = [NSError errorWithDomain:errstr code:-1 userInfo:nil];
        if (finish) {
            finish(err);
        }
        return;
    }
    self.fastProvisionStatus = SigFastProvisionStatus_start;
    self.provisionAddress = provisionAddress;
//    self.productId = productId;
    self.productIds = [NSArray arrayWithArray:productIds];
    self.currentConnectedNodeIsUnprovisioned = unprovisioned;
    
//    NSMutableData *mData = [NSMutableData data];
//    UInt8 page0 = 0;
//    [mData appendData:[NSData dataWithBytes:&page0 length:1]];
//    [mData appendData:compositionData];
//    self.page0 = [[SigPage0 alloc] initWithParameters:mData];
    self.scanResponseBlock = scanResponseBlock;
    self.startProvisionBlock = startProvisionBlock;
    self.singleSuccessBlock = singleSuccess;
    self.finishBlock = finish;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fastProvisionTimeoutAction) object:nil];
        [self performSelector:@selector(fastProvisionTimeoutAction) withObject:nil afterDelay:60.0];
    });
    [self resetNetwork];
}

#pragma mark step1: resetNetwork
- (void)resetNetwork {
    TeLogInfo(@"\n\n==========fast provision:step1\n\n");
    self.fastProvisionStatus = SigFastProvisionStatus_resetNetwork;
    self.setAddressList = [NSMutableArray array];
    UInt16 delayMillisecond = 1000;
    [self fastProvisionResetNetworkWithDelayMillisecond:delayMillisecond successCallback:^(UInt16 source, UInt16 destination, SigMeshMessage * _Nonnull responseMessage) {
//        TeLogVerbose(@"source=0x%x,destination=0x%x,opCode=0x%x,parameters=%@",responseMessage.opCode,[LibTools convertDataToHexStr:responseMessage.parameters]);
    } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
//        TeLogVerbose(@"isResponseAll=%d,error=%@",isResponseAll,error);
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getAddress) object:nil];
        [self performSelector:@selector(getAddress) withObject:nil afterDelay:delayMillisecond/1000.0+1];
    });
}

#pragma mark step2: getAddress
- (void)getAddress {
    TeLogInfo(@"\n\n==========fast provision:step2\n\n");
    self.fastProvisionStatus = SigFastProvisionStatus_getAddress;
    self.scanMacAddressList = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    UInt16 productId = self.productIds.count > 1 ? 0xFFFF : self.productIds.firstObject.intValue;
    [self fastProvisionGetAddressWithProductId:productId successCallback:^(UInt16 source, UInt16 destination, SigMeshMessage * _Nonnull responseMessage) {
        if (((responseMessage.opCode >> 16) & 0xFF) == SigOpCode_VendorID_MeshAddressGetStatus) {
            SigFastProvisionModel *model = [[SigFastProvisionModel alloc] init];
            if (responseMessage.parameters.length >= 8) {
                model.macAddress = [responseMessage.parameters subdataWithRange:NSMakeRange(0, 6)];
                model.sourceUnicastAddress = source;
                UInt16 tem = 0;
                Byte *dataByte = (Byte *)responseMessage.parameters.bytes;
                memcpy(&tem, dataByte+6, 2);
                model.productId = tem;
                if ([self.productIds containsObject:@(tem)]) {
                    [weakSelf.scanMacAddressList addObject:model];
                    if (weakSelf.scanResponseBlock) {
                        weakSelf.scanResponseBlock(model.deviceKey, [LibTools convertDataToHexStr:[LibTools turnOverData:model.macAddress]], 0, model.productId);
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(checkScanMacAddressList) object:nil];
                        [weakSelf performSelector:@selector(checkScanMacAddressList) withObject:nil afterDelay:2.0+0.2];
                    });
                }
            }
        }
    } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkScanMacAddressList) object:nil];
        [self performSelector:@selector(checkScanMacAddressList) withObject:nil afterDelay:2.0+0.2];
    });
}

- (void)checkScanMacAddressList {
    if (self.scanMacAddressList.count) {
        [self setAddress];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(getAddressRetry) withObject:nil afterDelay:0.5];
        });
    }
}

#pragma mark step3: setAddress
- (void)setAddress {
    TeLogInfo(@"\n\n==========fast provision:step3\n\n");
    self.fastProvisionStatus = SigFastProvisionStatus_setAddress;
    SigFastProvisionModel *model = self.scanMacAddressList.firstObject;
    __weak typeof(self) weakSelf = self;
    [self fastProvisionSetAddressWithProvisionAddress:self.provisionAddress macAddressData:model.macAddress toDestination:model.sourceUnicastAddress successCallback:^(UInt16 source, UInt16 destination, SigMeshMessage * _Nonnull responseMessage) {
        TeLogInfo(@"source=0x%x,destination=0x%x,opCode=0x%x,parameters=%@",source,destination,responseMessage.opCode,[LibTools convertDataToHexStr:responseMessage.parameters]);
        if (((responseMessage.opCode >> 16) & 0xFF) == SigOpCode_VendorID_MeshAddressSetStatus) {
            if (responseMessage.parameters.length >= 8) {
                NSData *mac = [responseMessage.parameters subdataWithRange:NSMakeRange(0, 6)];
                UInt16 tem = 0;
                Byte *dataByte = (Byte *)responseMessage.parameters.bytes;
                memcpy(&tem, dataByte+6, 2);
                if ([model.macAddress isEqualToData:mac] && tem == model.productId) {
                    model.address = weakSelf.provisionAddress;
                    [weakSelf.setAddressList addObject:model];
                    DeviceTypeModel *typeModel = [SigDataSource.share getNodeInfoWithCID:kCompanyID PID:model.productId];
                    weakSelf.provisionAddress += typeModel.defaultCompositionData.elements.count;
                } else {
                    TeLogInfo(@"set address response error!");
                }
            } else {
                TeLogInfo(@"set address response error!");
            }
        } else {
            TeLogInfo(@"set address response error!");
        }
    } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
        TeLogInfo(@"isResponseAll=%d,error=%@",isResponseAll,error);
        [weakSelf.scanMacAddressList removeObjectAtIndex:0];
        [weakSelf setSingleAddressFinish];
    }];
}

- (void)setSingleAddressFinish {
    if (self.scanMacAddressList.count) {
        [self setAddress];
    } else {
        [self getAddress];
    }
}

#pragma mark step4: getAddressRetry
- (void)getAddressRetry {
    TeLogInfo(@"\n\n==========fast provision:step4\n\n");
    self.fastProvisionStatus = SigFastProvisionStatus_getAddressRetry;
    self.scanMacAddressList = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    UInt16 productId = self.productIds.count > 1 ? 0xFFFF : self.productIds.firstObject.intValue;
    [self fastProvisionGetAddressRetryWithProductId:productId provisionAddress:self.provisionAddress successCallback:^(UInt16 source, UInt16 destination, SigMeshMessage * _Nonnull responseMessage) {
//        TeLogInfo(@"source=0x%x,destination=0x%x,opCode=0x%x,parameters=%@",responseMessage.opCode,[LibTools convertDataToHexStr:responseMessage.parameters]);
        if (((responseMessage.opCode >> 16) & 0xFF) == SigOpCode_VendorID_MeshAddressGetStatus) {
            SigFastProvisionModel *model = [[SigFastProvisionModel alloc] init];
            if (responseMessage.parameters.length >= 8) {
                model.macAddress = [responseMessage.parameters subdataWithRange:NSMakeRange(0, 6)];
                UInt16 tem = 0;
                Byte *dataByte = (Byte *)responseMessage.parameters.bytes;
                memcpy(&tem, dataByte+6, 2);
                model.productId = tem;
                if ([self.productIds containsObject:@(tem)]) {
                    [weakSelf.scanMacAddressList addObject:model];
                    if (weakSelf.scanResponseBlock) {
                        weakSelf.scanResponseBlock(model.deviceKey, [LibTools convertDataToHexStr:[LibTools turnOverData:model.macAddress]], 0, model.productId);
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(getAddressRetryFinish) object:nil];
                        [weakSelf performSelector:@selector(getAddressRetryFinish) withObject:nil afterDelay:2.0+0.2];
                    });
                }
            }
        }
    } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
//        TeLogInfo(@"isResponseAll=%d,error=%@",isResponseAll,error);
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getAddressRetryFinish) object:nil];
        [self performSelector:@selector(getAddressRetryFinish) withObject:nil afterDelay:2.0+0.2];
    });
}

- (void)getAddressRetryFinish {
    if (self.scanMacAddressList.count) {
        [self setAddress];
    } else {
        if (self.setAddressList.count) {
            [self setNetworkInfo];
        } else {
            __weak typeof(self) weakSelf = self;
            UInt16 delayMillisecond = 100;
            [self fastProvisionCompleteWithDelayMillisecond:delayMillisecond successCallback:^(UInt16 source, UInt16 destination, SigMeshMessage * _Nonnull responseMessage) {
                
            } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
                NSString *errstr = @"SigFastProvisionAddManager scaned unprovision device fail.";
                TeLogError(@"%@",errstr);
                NSError *err = [NSError errorWithDomain:errstr code:-1 userInfo:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf performSelector:@selector(callbackFastProvisionError:) withObject:err afterDelay:0.3];
                });
            }];
        }
    }
}

#pragma mark step5: setNetworkInfo
- (void)setNetworkInfo {
    TeLogInfo(@"\n\n==========fast provision:step5\n\n");
    self.fastProvisionStatus = SigFastProvisionStatus_setNetworkInfo;
    if (self.startProvisionBlock) {
        self.startProvisionBlock();
    }
    __weak typeof(self) weakSelf = self;
    [self fastProvisionSetNetworkInfoWithSuccessCallback:^(UInt16 source, UInt16 destination, SigMeshMessage * _Nonnull responseMessage) {
//        TeLogInfo(@"source=0x%x,destination=0x%x,opCode=0x%x,parameters=%@",responseMessage.opCode,[LibTools convertDataToHexStr:responseMessage.parameters]);
    } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
//        TeLogInfo(@"isResponseAll=%d,error=%@",isResponseAll,error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf performSelector:@selector(confirm) withObject:nil afterDelay:0.5];
        });
    }];
}

#pragma mark step6: confirm
- (void)confirm {
    TeLogInfo(@"\n\n==========fast provision:step6\n\n");
    self.fastProvisionStatus = SigFastProvisionStatus_confirm;
    __weak typeof(self) weakSelf = self;
    __block BOOL hasResponse = NO;
    [self fastProvisionConfirmWithSuccessCallback:^(UInt16 source, UInt16 destination, SigMeshMessage * _Nonnull responseMessage) {
//        TeLogInfo(@"source=0x%x,destination=0x%x,opCode=0x%x,parameters=%@",responseMessage.opCode,[LibTools convertDataToHexStr:responseMessage.parameters]);
        if (((responseMessage.opCode >> 16) & 0xFF) == SigOpCode_VendorID_MeshProvisionConfirmStatus) {
            hasResponse = YES;
        }
    } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
//        TeLogInfo(@"isResponseAll=%d,error=%@",isResponseAll,error);
        if (hasResponse) {
            [weakSelf setNetworkInfo];
        } else {
            [weakSelf complete];
        }
    }];
}

#pragma mark step7: complete
- (void)complete {
    TeLogInfo(@"\n\n==========fast provision:step7\n\n");
    self.fastProvisionStatus = SigFastProvisionStatus_confirmOk;
    UInt16 delayMillisecond = 1000;
//    __weak typeof(self) weakSelf = self;
    [self fastProvisionCompleteWithDelayMillisecond:delayMillisecond successCallback:^(UInt16 source, UInt16 destination, SigMeshMessage * _Nonnull responseMessage) {
//        TeLogInfo(@"source=0x%x,destination=0x%x,opCode=0x%x,parameters=%@",responseMessage.opCode,[LibTools convertDataToHexStr:responseMessage.parameters]);
    } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
//        TeLogInfo(@"isResponseAll=%d,error=%@",isResponseAll,error);
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fastProvisionSuccessAction) object:nil];
        [self performSelector:@selector(fastProvisionSuccessAction) withObject:nil afterDelay:(delayMillisecond + 100)/1000.0];
    });
}

- (void)fastProvisionSuccessAction {
    TeLogInfo(@"\n\n==========fast provision:Success.\n\n");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    });
    self.fastProvisionStatus = SigFastProvisionStatus_complete;
    NSArray *setAddressList = [NSArray arrayWithArray:self.setAddressList];
    for (SigFastProvisionModel *fastModel in setAddressList) {
        SigNodeModel *model = [[SigNodeModel alloc] init];
        [model setAddress:fastModel.address];
        [model setAddSigAppkeyModelSuccess:SigMeshLib.share.dataSource.curAppkeyModel];
        DeviceTypeModel *typeModel = [SigDataSource.share getNodeInfoWithCID:kCompanyID PID:fastModel.productId ];
        [model setCompositionData:typeModel.defaultCompositionData];
        model.deviceKey = [LibTools convertDataToHexStr:fastModel.deviceKey];
        model.UUID = [LibTools convertDataToHexStr:fastModel.deviceKey];
        model.peripheralUUID = nil;
        model.macAddress = [LibTools convertDataToHexStr:[LibTools turnOverData:fastModel.macAddress]];
        SigNodeKeyModel *nodeNetkey = [[SigNodeKeyModel alloc] init];
        nodeNetkey.index = SigMeshLib.share.dataSource.curNetkeyModel.index;
        if (![model.netKeys containsObject:nodeNetkey]) {
            [model.netKeys addObject:nodeNetkey];
        }

        if ([SigMeshLib.share.dataSource.nodes containsObject:model]) {
            NSInteger index = [SigMeshLib.share.dataSource.nodes indexOfObject:model];
            SigMeshLib.share.dataSource.nodes[index] = model;
        } else {
            [SigMeshLib.share.dataSource.nodes addObject:model];
        }
    }
    [SigMeshLib.share.dataSource saveLocationData];
    [SigMeshLib.share.dataSource saveLocationProvisionAddress:self.provisionAddress-1];

    for (SigFastProvisionModel *model in setAddressList) {
        if (self.singleSuccessBlock) {
            self.singleSuccessBlock(model.deviceKey, [LibTools convertDataToHexStr:[LibTools turnOverData:model.macAddress]], model.address, model.productId);
        }
    }
    if (self.finishBlock) {
        self.finishBlock(nil);
    }
    self.fastProvisionStatus = SigFastProvisionStatus_idle;
}

/// 整个fast provision流程的超时时间，60秒。防止一直重复getAddress或者一直重复setNetwork。
- (void)fastProvisionTimeoutAction {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    });
    self.fastProvisionStatus = SigFastProvisionStatus_timeout;
    
    if (SigBearer.share.isOpen) {
        __weak typeof(self) weakSelf = self;
        UInt16 delayMillisecond = 100;
        [self fastProvisionCompleteWithDelayMillisecond:delayMillisecond successCallback:^(UInt16 source, UInt16 destination, SigMeshMessage * _Nonnull responseMessage) {
            
        } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
            if (weakSelf.finishBlock) {
                NSString *errstr = [NSString stringWithFormat:@"Fast provision is timeout:60s, current status is %d.",weakSelf.fastProvisionStatus];
                TeLogError(@"%@",errstr);
                NSError *err = [NSError errorWithDomain:errstr code:-weakSelf.fastProvisionStatus userInfo:nil];
                weakSelf.finishBlock(err);
            }
            weakSelf.fastProvisionStatus = SigFastProvisionStatus_idle;
        }];
    } else {
        if (self.finishBlock) {
            NSString *errstr = [NSString stringWithFormat:@"Device is disconnected! Fast provision is fail, current status is %d.",self.fastProvisionStatus];
            TeLogError(@"%@",errstr);
            NSError *err = [NSError errorWithDomain:errstr code:-self.fastProvisionStatus userInfo:nil];
            self.finishBlock(err);
        }
        self.fastProvisionStatus = SigFastProvisionStatus_idle;
    }
}

- (void)callbackFastProvisionError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    });
    self.fastProvisionStatus = SigFastProvisionStatus_idle;
    __weak typeof(self) weakSelf = self;
    [SDKLibCommand stopMeshConnectWithComplete:^(BOOL successful) {
        if (weakSelf.finishBlock) {
            weakSelf.finishBlock(error);
        }
    }];
}

#pragma mark - command

#pragma mark ResetNetwork

/// 将mesh参数设置到默认网络。（延时delayMillisecond毫秒+1秒后，可以进行GetAddress操作。）
/// @param delayMillisecond  长度为2个字节，表示mesh参数重置到默认网络的延时时间，单位为ms。
- (void)fastProvisionResetNetworkWithDelayMillisecond:(UInt16)delayMillisecond successCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    UInt16 tem = delayMillisecond;
    NSData *temData = [NSData dataWithBytes:&tem length:2];
    IniCommandModel *model = [[IniCommandModel alloc] initVendorModelIniCommandWithNetkeyIndex:SigMeshLib.share.dataSource.defaultNetKeyA.index appkeyIndex:SigMeshLib.share.dataSource.defaultAppKeyA.index retryCount:SigMeshLib.share.dataSource.defaultRetryCount responseMax:0 address:kMeshAddress_allNodes opcode:SigOpCode_VendorID_MeshResetNetwork vendorId:kCompanyID responseOpcode:0 tidPosition:0 tid:0 commandData:temData];
    if (self.currentConnectedNodeIsUnprovisioned) {
        model.curNetkey = SigMeshLib.share.dataSource.defaultNetKeyA;
        model.curAppkey = SigMeshLib.share.dataSource.defaultAppKeyA;
        model.curIvIndex = SigMeshLib.share.dataSource.defaultIvIndexA;
    } else {
        model.curNetkey = SigMeshLib.share.dataSource.curNetkeyModel;
        model.curAppkey = SigMeshLib.share.dataSource.curAppkeyModel;
        model.curIvIndex = SigMeshLib.share.dataSource.curNetkeyModel.ivIndex;
    }
    [SDKLibCommand sendIniCommandModel:model successCallback:successCallback resultCallback:resultCallback];
}

#pragma mark GetAddress

/// 获取未入网的设备。（发送GetAddress后延时2000毫秒等待response，存在设备则进入SetAddress，不存在设备则进入GetAddressRetry。）
/// @param productId  获取返回设备的产品ID，如果产品ID为0xFFFF，则返回所有类型的可入网设备。
- (void)fastProvisionGetAddressWithProductId:(UInt16)productId successCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    UInt16 tem = productId;
    NSData *temData = [NSData dataWithBytes:&tem length:2];
    IniCommandModel *model = [[IniCommandModel alloc] initVendorModelIniCommandWithNetkeyIndex:SigMeshLib.share.dataSource.defaultNetKeyA.index appkeyIndex:SigMeshLib.share.dataSource.defaultAppKeyA.index retryCount:0 responseMax:0xFF address:kMeshAddress_allNodes opcode:SigOpCode_VendorID_MeshAddressGet vendorId:kCompanyID responseOpcode:SigOpCode_VendorID_MeshAddressGetStatus tidPosition:0 tid:0 commandData:temData];
    model.curNetkey = SigMeshLib.share.dataSource.defaultNetKeyA;
    model.curAppkey = SigMeshLib.share.dataSource.defaultAppKeyA;
    model.curIvIndex = SigMeshLib.share.dataSource.defaultIvIndexA;
    model.timeout = 2.0;
    [SDKLibCommand sendIniCommandModel:model successCallback:successCallback resultCallback:resultCallback];
}

#pragma mark SetAddress

/// 配置未入网设备的短地址。
/// @param provisionAddress 未入网设备的新短地址
/// @param macAddressData 未入网设备的MacAddress
/// @param destination 直连node的短地址
- (void)fastProvisionSetAddressWithProvisionAddress:(UInt16)provisionAddress macAddressData:(NSData *)macAddressData toDestination:(UInt16)destination successCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    UInt16 tem = provisionAddress;
    NSData *temData = [NSData dataWithBytes:&tem length:2];
    NSMutableData *mData = [NSMutableData data];
    [mData appendData:macAddressData];
    [mData appendData:temData];
    IniCommandModel *model = [[IniCommandModel alloc] initVendorModelIniCommandWithNetkeyIndex:SigMeshLib.share.dataSource.defaultNetKeyA.index appkeyIndex:SigMeshLib.share.dataSource.defaultAppKeyA.index retryCount:SigMeshLib.share.dataSource.defaultRetryCount responseMax:1 address:destination opcode:SigOpCode_VendorID_MeshAddressSet vendorId:kCompanyID responseOpcode:SigOpCode_VendorID_MeshAddressSetStatus tidPosition:0 tid:0 commandData:mData];
    model.curNetkey = SigMeshLib.share.dataSource.defaultNetKeyA;
    model.curAppkey = SigMeshLib.share.dataSource.defaultAppKeyA;
    model.curIvIndex = SigMeshLib.share.dataSource.defaultIvIndexA;
    [SDKLibCommand sendIniCommandModel:model successCallback:successCallback resultCallback:resultCallback];
}

#pragma mark GetAddressRetry

/// 重试获取未入网设备。（发送GetAddressRetry后延时2000毫秒等待response，存在设备则进入SetAddress，不存在设备则进入SetNetworkInfo。）
/// @param productId 获取返回设备的产品ID，如果产品ID为0xFFFF，则返回所有类型的可入网设备。
/// @param provisionAddress 下一个可用于provision的设备短地址。
- (void)fastProvisionGetAddressRetryWithProductId:(UInt16)productId provisionAddress:(UInt16)provisionAddress successCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    UInt16 tem = productId;
    NSData *temData = [NSData dataWithBytes:&tem length:2];
    NSMutableData *mData = [NSMutableData data];
    [mData appendData:temData];
    tem = provisionAddress;
    temData = [NSData dataWithBytes:&tem length:2];
    [mData appendData:temData];
    IniCommandModel *model = [[IniCommandModel alloc] initVendorModelIniCommandWithNetkeyIndex:SigMeshLib.share.dataSource.defaultNetKeyA.index appkeyIndex:SigMeshLib.share.dataSource.defaultAppKeyA.index retryCount:0 responseMax:0xFF address:kMeshAddress_allNodes opcode:SigOpCode_VendorID_MeshAddressGet vendorId:kCompanyID responseOpcode:SigOpCode_VendorID_MeshAddressGetStatus tidPosition:0 tid:0 commandData:mData];
    model.curNetkey = SigMeshLib.share.dataSource.defaultNetKeyA;
    model.curAppkey = SigMeshLib.share.dataSource.defaultAppKeyA;
    model.curIvIndex = SigMeshLib.share.dataSource.defaultIvIndexA;
    [SDKLibCommand sendIniCommandModel:model successCallback:successCallback resultCallback:resultCallback];
}

#pragma mark SetNetworkInfo

/// 配置设备的新网络参数。
- (void)fastProvisionSetNetworkInfoWithSuccessCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    /*
     NetworkInfo数据为provision data+appkeyAdd data
     
     provision data为
     netkeyData(16bytes)+netkeyIndex(2bytes)+flags(1bytes)+ivIndex(4bytes)+locationAddress(2bytes)
     flags:
     typedef struct{
         u8 KeyRefresh   :1;
         u8 IVUpdate     :1;
         u8 RFU          :6;
     }mesh_ctl_fri_update_flag_t;
     
     appkeyAdd data为
     appkeyIndex(3bytes)+appkeyData(16bytes)
     appkeyIndex为：
     u32 net_app_idx = (fast_prov.net_info.pro_data.key_index&0x0FFF) | (mesh_key.net_key[nk_array_idx][0].app_key[ak_array_idx].index<<12);
          
     CA1102
     5F584C3E6C892A7FF7005205512C04B6
     0000
     00
     11223344
     0100
     000000
     CAB385F63994A94B0A57902B1AD80E2C
     */
    UInt16 tem = SigMeshLib.share.dataSource.curNetkeyModel.index;
    NSData *temData = [NSData dataWithBytes:&tem length:2];
    NSMutableData *mData = [NSMutableData data];
    [mData appendData:SigMeshLib.share.dataSource.curNetKey];
    [mData appendData:temData];
    UInt8 flags = 0;
    BOOL keyRefreshFlag = NO;
    BOOL ivUpdateActive = NO;
    if (keyRefreshFlag) {
        flags = flags | (1 << 7);
    }
    if (ivUpdateActive) {
        flags = flags | (1 << 6);
    }
    temData = [NSData dataWithBytes:&flags length:1];
    [mData appendData:temData];
    [mData appendData:SigMeshLib.share.dataSource.getIvIndexData];
    tem = SigMeshLib.share.dataSource.curLocationNodeModel.address;
    temData = [NSData dataWithBytes:&tem length:2];
    [mData appendData:temData];
    UInt32 net_app_idx = (SigMeshLib.share.dataSource.curNetkeyModel.index & 0x0FFF) | (((UInt32)SigMeshLib.share.dataSource.curAppkeyModel.index) << 12);
    temData = [NSData dataWithBytes:&net_app_idx length:3];
    [mData appendData:temData];
    [mData appendData:SigMeshLib.share.dataSource.curAppKey];
    
    IniCommandModel *model = [[IniCommandModel alloc] initVendorModelIniCommandWithNetkeyIndex:SigMeshLib.share.dataSource.defaultNetKeyA.index appkeyIndex:SigMeshLib.share.dataSource.defaultAppKeyA.index retryCount:0 responseMax:0 address:kMeshAddress_allNodes opcode:SigOpCode_VendorID_MeshProvisionDataSet vendorId:kCompanyID responseOpcode:0 tidPosition:0 tid:0 commandData:mData];
    model.curNetkey = SigMeshLib.share.dataSource.defaultNetKeyA;
    model.curAppkey = SigMeshLib.share.dataSource.defaultAppKeyA;
    model.curIvIndex = SigMeshLib.share.dataSource.defaultIvIndexA;
    [SDKLibCommand sendIniCommandModel:model successCallback:successCallback resultCallback:resultCallback];
}

#pragma mark Confirm

/// 向设备确认是否收到了新网络参数。（Confirm发送一次retry两次，如果设备返回SigOpCode_VendorID_MeshProvisionConfirmStatus 表示这个设备在SetNetworkInfo设置mesh info失败了，重复执行SetNetworkInfo；如果APP未收到表示SigOpCode_VendorID_MeshProvisionConfirmStatus则表示所有设备都完成了SetNetworkInfo。）
- (void)fastProvisionConfirmWithSuccessCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    IniCommandModel *model = [[IniCommandModel alloc] initVendorModelIniCommandWithNetkeyIndex:SigMeshLib.share.dataSource.defaultNetKeyA.index appkeyIndex:SigMeshLib.share.dataSource.defaultAppKeyA.index retryCount:SigMeshLib.share.dataSource.defaultRetryCount responseMax:1 address:kMeshAddress_allNodes opcode:SigOpCode_VendorID_MeshProvisionConfirm vendorId:kCompanyID responseOpcode:SigOpCode_VendorID_MeshProvisionConfirmStatus tidPosition:0 tid:0 commandData:nil];
    model.curNetkey = SigMeshLib.share.dataSource.defaultNetKeyA;
    model.curAppkey = SigMeshLib.share.dataSource.defaultAppKeyA;
    model.curIvIndex = SigMeshLib.share.dataSource.defaultIvIndexA;
    [SDKLibCommand sendIniCommandModel:model successCallback:successCallback resultCallback:resultCallback];
}

#pragma mark Complete

/// 将mesh参数设置到新配置的参数。（延时delayMillisecond毫秒+100毫秒，表示设备恢复网络成功。setFilter后即可控制设备。（iv_update待完善））
/// @param delayMillisecond  长度为2个字节，表示mesh参数恢复到配置网络的延时时间，单位为ms。
- (void)fastProvisionCompleteWithDelayMillisecond:(UInt16)delayMillisecond successCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    UInt16 tem = delayMillisecond;
    NSData *temData = [NSData dataWithBytes:&tem length:2];
    IniCommandModel *model = [[IniCommandModel alloc] initVendorModelIniCommandWithNetkeyIndex:SigMeshLib.share.dataSource.defaultNetKeyA.index appkeyIndex:SigMeshLib.share.dataSource.defaultAppKeyA.index retryCount:SigMeshLib.share.dataSource.defaultRetryCount responseMax:0 address:kMeshAddress_allNodes opcode:SigOpCode_VendorID_MeshProvisionComplete vendorId:kCompanyID responseOpcode:0 tidPosition:0 tid:0 commandData:temData];
    model.curNetkey = SigMeshLib.share.dataSource.defaultNetKeyA;
    model.curAppkey = SigMeshLib.share.dataSource.defaultAppKeyA;
    model.curIvIndex = SigMeshLib.share.dataSource.defaultIvIndexA;
    [SDKLibCommand sendIniCommandModel:model successCallback:successCallback resultCallback:resultCallback];
}

@end
