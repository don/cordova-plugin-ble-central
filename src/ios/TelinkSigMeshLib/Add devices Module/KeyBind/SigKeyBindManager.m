/********************************************************************************************************
 * @file     SigKeyBindManager.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/9/4
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

#import "SigKeyBindManager.h"
#if SUPPORTOPCODESAGGREGATOR
#import "SDKLibCommand+opcodesAggregatorSequence.h"
#endif

@interface SigKeyBindManager ()
@property (nonatomic,strong) SigMessageHandle *messageHandle;
@property (nonatomic,copy) addDevice_keyBindSuccessCallBack keyBindSuccessBlock;
@property (nonatomic,copy) ErrorBlock failBlock;
@property (nonatomic,assign) UInt16 address;
@property (nonatomic,strong) SigAppkeyModel *appkeyModel;
@property (nonatomic,assign) KeyBindType type;
@property (nonatomic,strong) SigCompositionDataPage *page;
@property (nonatomic,strong) SigNodeModel *node;
@property (nonatomic,assign) BOOL isKeybinding;

@property (nonatomic,assign) UInt16 fastKeybindProductID;
@property (nonatomic,strong) NSData *fastKeybindCpsData;

@end

@implementation SigKeyBindManager

+ (SigKeyBindManager *)share {
    static SigKeyBindManager *shareManager = nil;
    static dispatch_once_t tempOnce=0;
    dispatch_once(&tempOnce, ^{
        shareManager = [[SigKeyBindManager alloc] init];
        shareManager.getCompositionTimeOut = 10;
        shareManager.appkeyAddTimeOut = 10;
        shareManager.bindModelTimeOut = 60*2;
    });
    return shareManager;
}

- (void)keyBind:(UInt16)address appkeyModel:(SigAppkeyModel *)appkeyModel keyBindType:(KeyBindType)type productID:(UInt16)productID cpsData:(nullable NSData *)cpsData keyBindSuccess:(addDevice_keyBindSuccessCallBack)keyBindSuccess fail:(ErrorBlock)fail {
    self.keyBindSuccessBlock = keyBindSuccess;
    self.failBlock = fail;
    self.address = address;
    self.appkeyModel = appkeyModel;
    self.type = type;
    self.node = [SigMeshLib.share.dataSource getNodeWithAddress:address];
    self.fastKeybindProductID = productID;
    self.fastKeybindCpsData = cpsData;
    self.isKeybinding = YES;
    __weak typeof(self) weakSelf = self;
    TeLogInfo(@"start keybind.");
    [SigBluetooth.share setBluetoothDisconnectCallback:^(CBPeripheral * _Nonnull peripheral, NSError * _Nonnull error) {
        [SigMeshLib.share cleanAllCommandsAndRetry];
        if ([peripheral.identifier.UUIDString isEqualToString:SigBearer.share.getCurrentPeripheral.identifier.UUIDString]) {
            if (weakSelf.isKeybinding) {
                TeLogInfo(@"disconnect in keybinding，keybind fail.");
                [weakSelf showKeyBindEnd];
                if (fail) {
                    weakSelf.isKeybinding = NO;
                    NSError *err = [NSError errorWithDomain:@"disconnect in keybinding，keybind fail." code:-1 userInfo:nil];
                    fail(err);
                }
            }
        }
    }];

    /*
     KeyBindType_Normal:
     (原来已经连接则不需要连接逻辑)1.扫描连接、读att列表、
     2.set filter、get composition、
     3.appkey add
     4.bind model to appkey
     KeyBindType_Quick:
     1.appkey add
     */
    if (self.type == KeyBindType_Normal) {
        [self getCompositionData];
    } else if (self.type == KeyBindType_Fast) {
        [self appkeyAdd];
    }else{
        TeLogError(@"KeyBindType is error");
    }
    
}

- (void)getCompositionData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getCompositionDataTimeOut) object:nil];
        [self performSelector:@selector(getCompositionDataTimeOut) withObject:nil afterDelay:self.getCompositionTimeOut];
    });
    TeLogDebug(@"getCompositionData 0x%02x",self.address);
    __weak typeof(self) weakSelf = self;
    self.messageHandle = [SDKLibCommand configCompositionDataGetWithDestination:self.address retryCount:SigMeshLib.share.dataSource.defaultRetryCount responseMaxCount:1 successCallback:^(UInt16 source, UInt16 destination, SigConfigCompositionDataStatus * _Nonnull responseMessage) {
        TeLogInfo(@"opCode=0x%x,parameters=%@",responseMessage.opCode,[LibTools convertDataToHexStr:responseMessage.parameters]);
        weakSelf.page = ((SigConfigCompositionDataStatus *)responseMessage).page;
    } resultCallback:^(BOOL isResponseAll, NSError * _Nonnull error) {
        if (weakSelf.isKeybinding) {
            if (!isResponseAll || error) {
                [weakSelf showKeyBindEnd];
                weakSelf.isKeybinding = NO;
                if (weakSelf.failBlock) {
                    weakSelf.failBlock(error);
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getCompositionDataTimeOut) object:nil];
                });
#if SUPPORTOPCODESAGGREGATOR
                BOOL hasOpCodes = NO;
                SigPage0 *page0 = (SigPage0 *)weakSelf.page;
                NSArray *elements = [NSArray arrayWithArray:page0.elements];
                for (SigElementModel *element in elements) {
                    element.parentNodeAddress = weakSelf.node.address;
                    NSArray *models = [NSArray arrayWithArray:element.models];
                    for (SigModelIDModel *modelID in models) {
                        if (modelID.getIntModelID == kSigModel_OP_AGG_S_ID) {
                            hasOpCodes = YES;
                            break;
                        }
                    }
                    if (hasOpCodes) {
                        break;
                    }
                }
                if (hasOpCodes) {
                    [weakSelf sendAppkeyAddAndBindModelByUsingOpcodesAggregatorSequence];
                } else {
                    [weakSelf appkeyAdd];
                }
#else
                [weakSelf appkeyAdd];
#endif
            }
        }
    }];
    if (self.messageHandle == nil && self.isKeybinding) {
        [self showKeyBindEnd];
        self.isKeybinding = NO;
        if (self.failBlock) {
            NSError *error = [NSError errorWithDomain:@"KeyBind Fail:getCompositionData fail." code:-1 userInfo:nil];
            self.failBlock(error);
        }
    }
}

- (void)getCompositionDataTimeOut {
    if (self.isKeybinding) {
        [self showKeyBindEnd];
        [self.messageHandle cancel];
        self.isKeybinding = NO;
        if (self.failBlock) {
            NSError *error = [NSError errorWithDomain:@"KeyBind Fail:getCompositionData TimeOut." code:-1 userInfo:nil];
            self.failBlock(error);
        }
    }
}

- (void)appkeyAdd {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addAppkeyTimeOut) object:nil];
        [self performSelector:@selector(addAppkeyTimeOut) withObject:nil afterDelay:self.appkeyAddTimeOut];
    });
    __weak typeof(self) weakSelf = self;
    self.messageHandle = [SDKLibCommand configAppKeyAddWithDestination:self.address appkeyModel:self.appkeyModel retryCount:SigMeshLib.share.dataSource.defaultRetryCount responseMaxCount:1 successCallback:^(UInt16 source, UInt16 destination, SigConfigAppKeyStatus * _Nonnull responseMessage) {
//        TeLogInfo(@"opCode=0x%x,parameters=%@",responseMessage.opCode,[LibTools convertDataToHexStr:responseMessage.parameters]);
        if (weakSelf.isKeybinding) {
            if (((SigConfigAppKeyStatus *)responseMessage).status == SigConfigMessageStatus_success) {
                if (weakSelf.type == KeyBindType_Normal) {
                    [weakSelf bindModel];
                } else if (weakSelf.type == KeyBindType_Fast) {
                    DeviceTypeModel *deviceType = nil;
                    if (weakSelf.fastKeybindCpsData != nil) {
                        TeLogVerbose(@"init cpsData from config.cpsdata.");
                        deviceType = [[DeviceTypeModel alloc] initWithCID:kCompanyID PID:weakSelf.fastKeybindProductID compositionData:weakSelf.fastKeybindCpsData];
                    } else {
                        deviceType = [SigMeshLib.share.dataSource getNodeInfoWithCID:[LibTools uint16From16String:weakSelf.node.cid] PID:[LibTools uint16From16String:weakSelf.node.pid]];
                    }
                    if (deviceType == nil) {
                        TeLogError(@"this node not support fast bind!!!");
                        deviceType = [[DeviceTypeModel alloc] initWithCID:kCompanyID PID:weakSelf.fastKeybindProductID];
                    }
                    if (deviceType.defaultCompositionData.elements == nil || deviceType.defaultCompositionData.elements.count == 0) {
                        TeLogError(@"defaultCompositionData had setted to CT");
                        deviceType = [[DeviceTypeModel alloc] initWithCID:kCompanyID PID:1];
                    }
                    weakSelf.page = deviceType.defaultCompositionData;
                    [weakSelf keyBindSuccessAction];
                }else{
                    TeLogError(@"KeyBindType is error");
                }
            } else {
                [weakSelf showKeyBindEnd];
                weakSelf.isKeybinding = NO;
                if (weakSelf.failBlock) {
                    NSError *error = [NSError errorWithDomain:@"KeyBind Fail:add appKey status is not success." code:-1 userInfo:nil];
                    weakSelf.failBlock(error);
                }
            }
        }
    } resultCallback:^(BOOL isResponseAll, NSError * _Nonnull error) {
        if (weakSelf.isKeybinding) {
            if (!isResponseAll || error) {
                [weakSelf showKeyBindEnd];
                weakSelf.isKeybinding = NO;
                if (weakSelf.failBlock) {
                    weakSelf.failBlock(error);
                }
            }
        }
    }];
    if (self.messageHandle == nil && self.isKeybinding) {
        [self showKeyBindEnd];
        self.isKeybinding = NO;
        if (self.failBlock) {
            NSError *error = [NSError errorWithDomain:@"KeyBind Fail:model bind fail." code:-1 userInfo:nil];
            self.failBlock(error);
        }
    }
}

- (void)addAppkeyTimeOut {
    [self keyBindFailActionWithErrorString:@"KeyBind Fail:add appkey timeout."];
}

- (void)bindModel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addAppkeyTimeOut) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bindModelToAppkeyTimeOut) object:nil];
        [self performSelector:@selector(bindModelToAppkeyTimeOut) withObject:nil afterDelay:self.bindModelTimeOut];
    });
    __weak typeof(self) weakSelf = self;
    //子线程执行bindModel
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperationWithBlock:^{
        __block BOOL isFail = NO;
        SigPage0 *page0 = (SigPage0 *)weakSelf.page;
        NSArray *elements = [NSArray arrayWithArray:page0.elements];
        for (SigElementModel *element in elements) {
            element.parentNodeAddress = weakSelf.node.address;
            NSArray *models = [NSArray arrayWithArray:element.models];
            for (SigModelIDModel *modelID in models) {
                if (modelID.isDeviceKeyModelID) {
                    TeLogVerbose(@"app needn't Bind modelID=%@",modelID.modelId);
                    continue;
                }
                TeLogVerbose(@"appBind modelID=%@",modelID.modelId);
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                
                // 写法1：不判断modelID
//                self.messageHandle = [SDKLibCommand configModelAppBindWithSigAppkeyModel:weakSelf.appkeyModel toModelIDModel:modelID toNode:weakSelf.node successCallback:^(UInt16 source, UInt16 destination, SigConfigModelAppStatus * _Nonnull responseMessage) {
//                    TeLogVerbose(@"SigConfigModelAppStatus.parameters=%@",responseMessage.parameters);
//                    dispatch_semaphore_signal(semaphore);
//                } resultCallback:^(BOOL isResponseAll, NSError * _Nonnull error) {
//                    if (!isResponseAll || error) {
//                        isFail = YES;
//                    }
//                    dispatch_semaphore_signal(semaphore);
//                }];
                
                // 写法2：判断modelID
                self.messageHandle = [SDKLibCommand configModelAppBindWithDestination:weakSelf.address applicationKeyIndex:weakSelf.appkeyModel.index elementAddress:element.unicastAddress modelIdentifier:modelID.getIntModelIdentifier companyIdentifier:modelID.getIntCompanyIdentifier retryCount:SigMeshLib.share.dataSource.defaultRetryCount*3 responseMaxCount:1 successCallback:^(UInt16 source, UInt16 destination, SigConfigModelAppStatus * _Nonnull responseMessage) {
                    TeLogInfo(@"SigConfigModelAppStatus.parameters=%@",responseMessage.parameters);
                    if (responseMessage.modelIdentifier == modelID.getIntModelIdentifier && responseMessage.companyIdentifier == modelID.getIntCompanyIdentifier && responseMessage.elementAddress == element.unicastAddress) {
                        if (responseMessage.status == SigConfigMessageStatus_success || modelID.getIntCompanyIdentifier != 0) {//sig model判断状态，vendor model不判断状态
                            isFail = NO;
                        } else {
                            isFail = YES;
                        }
                        dispatch_semaphore_signal(semaphore);
                    }
                    //如果判断status失败，应该设置isFail = YES;才会回调keyBind失败。
                } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
                    if (!isFail) {
                        if (!isResponseAll || error) {
                            isFail = YES;
                        }
                        dispatch_semaphore_signal(semaphore);
                    }
                }];
                if (self.messageHandle == nil) {
                    isFail = YES;
                } else {
                    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 20.0));
                }
                if (isFail) {
                    break;
                }
            }
            if (isFail) {
                break;
            }
        }
        if (!isFail) {
            [weakSelf keyBindSuccessAction];
        } else {
            if (weakSelf.isKeybinding) {
                [weakSelf showKeyBindEnd];
                TeLogInfo(@"keyBind fail.");
                [weakSelf.messageHandle cancel];
                weakSelf.isKeybinding = NO;
                if (weakSelf.failBlock) {
                    NSError *error = [NSError errorWithDomain:@"KeyBind Fail:model bind fail." code:-1 userInfo:nil];
                    weakSelf.failBlock(error);
                }
            }
        }
    }];
}

- (void)bindModelToAppkeyTimeOut {
    [self keyBindFailActionWithErrorString:@"KeyBind Fail:bind model timeout."];
}

- (void)sendAppkeyAddAndBindModelByUsingOpcodesAggregatorSequence {
#if SUPPORTOPCODESAGGREGATOR
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendAppkeyAddAndBindModelByUsingOpcodesAggregatorSequenceTimeout) object:nil];
        [self performSelector:@selector(sendAppkeyAddAndBindModelByUsingOpcodesAggregatorSequenceTimeout) withObject:nil afterDelay:self.appkeyAddTimeOut+self.bindModelTimeOut];
    });
    NSMutableArray *mArray = [NSMutableArray array];
    SigOpcodesAggregatorItemModel *model1 = [[SigOpcodesAggregatorItemModel alloc] initWithSigMeshMessage:[[SigConfigAppKeyAdd alloc] initWithApplicationKey:self.appkeyModel]];
    [mArray addObject:model1];
    BOOL hasTimeServerModel = NO;
    UInt16 timeServerModelElementAddress = 0;
    SigPage0 *page0 = (SigPage0 *)self.page;
    NSArray *elements = [NSArray arrayWithArray:page0.elements];
    for (SigElementModel *element in elements) {
        element.parentNodeAddress = self.node.address;
        NSArray *models = [NSArray arrayWithArray:element.models];
        for (SigModelIDModel *modelID in models) {
            SigConfigModelAppBind *bindModel = [[SigConfigModelAppBind alloc] initWithApplicationKey:self.appkeyModel toModel:modelID elementAddress:element.unicastAddress];
            SigOpcodesAggregatorItemModel *model = [[SigOpcodesAggregatorItemModel alloc] initWithSigMeshMessage:bindModel];
            [mArray addObject:model];
            if (modelID.getIntModelID == kSigModel_TimeServer_ID) {
                hasTimeServerModel = YES;
                timeServerModelElementAddress = element.unicastAddress;
            }
        }
    }
    //publish time model
    if (hasTimeServerModel == YES && timeServerModelElementAddress > 0 && SigMeshLib.share.dataSource.needPublishTimeModel) {
        TeLogInfo(@"SDK need publish time");
        //周期，20秒上报一次。ttl:0xff（表示采用节点默认参数），0表示不relay。
        SigRetransmit *retransmit = [[SigRetransmit alloc] initWithPublishRetransmitCount:0 intervalSteps:2];
        SigPublish *publish = [[SigPublish alloc] initWithDestination:kMeshAddress_allNodes withKeyIndex:SigMeshLib.share.dataSource.curAppkeyModel.index friendshipCredentialsFlag:0 ttl:0 periodSteps:kTimePublishInterval periodResolution:1 retransmit:retransmit];
        SigConfigModelPublicationSet *timePublication = [[SigConfigModelPublicationSet alloc] initWithPublish:publish toElementAddress:timeServerModelElementAddress modelIdentifier:kSigModel_TimeServer_ID companyIdentifier:0];
        SigOpcodesAggregatorItemModel *model = [[SigOpcodesAggregatorItemModel alloc] initWithSigMeshMessage:timePublication];
        [mArray addObject:model];
    }
    
    SigOpcodesAggregatorSequence *message = [[SigOpcodesAggregatorSequence alloc] initWithElementAddress:self.address items:mArray];
    __weak typeof(self) weakSelf = self;
    self.messageHandle = [SDKLibCommand sendSigOpcodesAggregatorSequenceMessage:message retryCount:SigMeshLib.share.dataSource.defaultRetryCount responseMaxCount:1 successCallback:^(UInt16 source, UInt16 destination, SigOpcodesAggregatorStatus * _Nonnull responseMessage) {
        TeLogInfo(@"SigOpcodesAggregatorStatus=%@,source=0x%x,destination=0x%x",[LibTools convertDataToHexStr:responseMessage.parameters],source,destination);
        if (responseMessage.status == SigOpcodesAggregatorMessagesStatus_success) {
            if (weakSelf.isKeybinding) {
                [weakSelf showKeyBindEnd];
                TeLogInfo(@"keyBind successful.");
                weakSelf.isKeybinding = NO;
            }
            [weakSelf finishTimePublicationAction];
        } else {
            [weakSelf keyBindFailActionWithErrorString:[NSString stringWithFormat:@"KeyBind Fail:send AppkeyAdd And BindModel By Using OpcodesAggregatorSequence fail, status=0x%X.",responseMessage.status]];
        }
    } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
        TeLogInfo(@"isResponseAll=%d,error=%@",isResponseAll,error);
        if (error) {
            [weakSelf keyBindFailActionWithErrorString:error.domain];
        }
    }];
#endif
}

- (void)sendAppkeyAddAndBindModelByUsingOpcodesAggregatorSequenceTimeout {
    [self keyBindFailActionWithErrorString:@"KeyBind Fail:send AppkeyAdd And BindModel By Using OpcodesAggregatorSequence timeout."];
}

- (void)keyBindFailActionWithErrorString:(NSString *)errorString {
    if (self.isKeybinding) {
        [self showKeyBindEnd];
        TeLogInfo(@"%@",errorString);
        [self.messageHandle cancel];
        self.isKeybinding = NO;
        if (self.failBlock) {
            NSError *error = [NSError errorWithDomain:errorString code:-1 userInfo:nil];
            self.failBlock(error);
        }
    }
}

- (void)keyBindSuccessAction {
    if (self.isKeybinding) {
        [self showKeyBindEnd];
        TeLogInfo(@"keyBind successful.");
        self.isKeybinding = NO;
        //publish time model
        UInt32 option = kSigModel_TimeServer_ID;
        
        SigNodeModel *node = [[SigNodeModel alloc] init];
        [node setAddress:self.node.address];
        [node setAddSigAppkeyModelSuccess:self.appkeyModel];
        [node setCompositionData:(SigPage0 *)self.page];
        NSArray *elementAddresses = [node getAddressesWithModelID:@(option)];
        if (elementAddresses.count > 0 && SigMeshLib.share.dataSource.needPublishTimeModel) {
            TeLogInfo(@"SDK need publish time");
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UInt16 eleAdr = [elementAddresses.firstObject intValue];
                //周期，20秒上报一次。ttl:0xff（表示采用节点默认参数），0表示不relay。
                SigRetransmit *retransmit = [[SigRetransmit alloc] initWithPublishRetransmitCount:0 intervalSteps:2];
                SigPublish *publish = [[SigPublish alloc] initWithDestination:kMeshAddress_allNodes withKeyIndex:SigMeshLib.share.dataSource.curAppkeyModel.index friendshipCredentialsFlag:0 ttl:0 periodSteps:kTimePublishInterval periodResolution:1 retransmit:retransmit];
                SigModelIDModel *modelID = [node getModelIDModelWithModelID:option andElementAddress:eleAdr];
                [SDKLibCommand configModelPublicationSetWithDestination:self.address publish:publish elementAddress:eleAdr modelIdentifier:modelID.getIntModelIdentifier companyIdentifier:modelID.getIntCompanyIdentifier retryCount:SigMeshLib.share.dataSource.defaultRetryCount responseMaxCount:1 successCallback:^(UInt16 source, UInt16 destination, SigConfigModelPublicationStatus * _Nonnull responseMessage) {
                    TeLogInfo(@"publish time callback");
                    if (responseMessage.elementAddress == eleAdr) {
                        if (responseMessage.status == SigConfigMessageStatus_success && [LibTools uint16From16String:responseMessage.publish.address] == kMeshAddress_allNodes) {
                            TeLogInfo(@"publish time success");
                        } else {
                            TeLogInfo(@"publish time status=%d,pubModel.publishAddress=%@",responseMessage.status,responseMessage.publish.address);
                        }
                        [weakSelf finishTimePublicationAction];
                    }
                } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
                    TeLogInfo(@"publish time finish.");
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(publicationSetTimeout) object:nil];
//                    });
                    if (error) {
                        if (weakSelf.failBlock) {
                            weakSelf.failBlock(error);
                        }
                    }
                }];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(publicationSetTimeout) object:nil];
//                    [weakSelf performSelector:@selector(publicationSetTimeout) withObject:nil afterDelay:2.0];
//                });
            });
        }else{
            TeLogInfo(@"SDK needn't publish time");
            [self finishTimePublicationAction];
        }
    }
}

- (void)finishTimePublicationAction {
    [self saveKeyBindSuccessToLocationData];
    [SigMeshLib.share cleanAllCommandsAndRetry];
    //callback
    if (self.keyBindSuccessBlock) {
        self.keyBindSuccessBlock(self.node.peripheralUUID, self.address);
    }
}

//先注释publicationSetTimeout相关代码，因为configModelPublicationSetWithDestination会超时并通过resultCallback返回，不需要这里的这个额外的超时机制。
//- (void)publicationSetTimeout {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(publicationSetTimeout) object:nil];
//    });
//    TeLogInfo(@"publish time timeout.");
//    NSError *error = [NSError errorWithDomain:@"KeyBind Fail:publicationSet time model TimeOut." code:-1 userInfo:nil];
//    if (error) {
//        if (self.failBlock) {
//            self.failBlock(error);
//        }
//    }
//}

- (void)saveKeyBindSuccessToLocationData {
    //appkeys
    [self.node setAddSigAppkeyModelSuccess:self.appkeyModel];
    //composition data
    [self.node setCompositionData:(SigPage0 *)self.page];
    //save
    [SigMeshLib.share.dataSource saveLocationData];
}

- (void)showKeyBindEnd {
    TeLogInfo(@"\n\n==========keyBind end.\n\n");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    });
}

@end
