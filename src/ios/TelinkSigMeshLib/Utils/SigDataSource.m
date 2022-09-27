/********************************************************************************************************
 * @file     SigDataSource.m 
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

#import "SigDataSource.h"
#import "OpenSSLHelper.h"

@interface SigDataSource ()<SigDataSourceDelegate>
@property (nonatomic,assign) UInt32 sequenceNumberOnDelegate;//通过SigDataSourceDelegate回调的sequenceNumber值。
@end

@implementation SigDataSource

+ (SigDataSource *)share{
    static SigDataSource *shareDS = nil;
    static dispatch_once_t tempOnce=0;
    dispatch_once(&tempOnce, ^{
        shareDS = [[SigDataSource alloc] init];        
    });
    return shareDS;
}

- (instancetype)init{
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

- (void)initData {
    _provisioners = [NSMutableArray array];
    _nodes = [NSMutableArray array];
    _groups = [NSMutableArray array];
    _scenes = [NSMutableArray array];
    _netKeys = [NSMutableArray array];
    _appKeys = [NSMutableArray array];
    _scanList = [NSMutableArray array];
    _networkExclusions = [NSMutableArray array];
    _ivIndex = [NSString stringWithFormat:@"%08X",(unsigned int)kDefaultIvIndex];
    _partial = false;
    _encryptedArray = [NSMutableArray array];
    _defaultGroupSubscriptionModels = [NSMutableArray arrayWithArray:@[@(kSigModel_GenericOnOffServer_ID),@(kSigModel_LightLightnessServer_ID),@(kSigModel_LightCTLServer_ID),@(kSigModel_LightCTLTemperatureServer_ID),@(kSigModel_LightHSLServer_ID)]];
    _defaultNodeInfos = [NSMutableArray array];
    DeviceTypeModel *model1 = [[DeviceTypeModel alloc] initWithCID:kCompanyID PID:SigNodePID_Panel];
    DeviceTypeModel *model2 = [[DeviceTypeModel alloc] initWithCID:kCompanyID PID:SigNodePID_CT];
    DeviceTypeModel *model3 = [[DeviceTypeModel alloc] initWithCID:kCompanyID PID:SigNodePID_HSL];
    DeviceTypeModel *model4 = [[DeviceTypeModel alloc] initWithCID:kCompanyID PID:SigNodePID_LPN];
    [_defaultNodeInfos addObject:model1];
    [_defaultNodeInfos addObject:model2];
    [_defaultNodeInfos addObject:model3];
    [_defaultNodeInfos addObject:model4];
    SigNetkeyModel *netkey = [[SigNetkeyModel alloc] init];
    netkey.key = @"7dd7364cd842ad18c17c74656c696e6b";
    netkey.index = 0;
    netkey.name = @"netkeyA";
    netkey.minSecurity = @"secure";
    _defaultNetKeyA = netkey;
    SigAppkeyModel *appkey = [[SigAppkeyModel alloc] init];
    appkey.key = @"63964771734fbd76e3b474656c696e6b";
    appkey.index = 0;
    appkey.name = @"appkeyA";
    appkey.boundNetKey = 0;
    _defaultAppKeyA = appkey;
    _defaultIvIndexA = [[SigIvIndex alloc] initWithIndex:0x12345678 updateActive:NO];
    _needPublishTimeModel = YES;
    _defaultUnsegmentedMessageLowerTransportPDUMaxLength = kUnsegmentedMessageLowerTransportPDUMaxLength;
    _telinkExtendBearerMode = SigTelinkExtendBearerMode_noExtend;
    
    //OOB
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:kOOBStoreKey];
    if (data) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (array && array.count) {
            _OOBList = [NSMutableArray arrayWithArray:array];
        } else {
            _OOBList = [NSMutableArray array];
        }
    } else {
        _OOBList = [NSMutableArray array];
    }
    _addStaticOOBDevcieByNoOOBEnable = YES;
    _defaultRetryCount = 2;
    _defaultAllocatedUnicastRangeHighAddress = kAllocatedUnicastRangeHighAddress;
    _defaultSequenceNumberIncrement = kSequenceNumberIncrement;
    SigPeriodModel *periodModel = [[SigPeriodModel alloc] init];
    periodModel.numberOfSteps = kPublishInterval;
    periodModel.resolution = [LibTools getSigStepResolutionInMillisecondsOfJson:SigStepResolution_seconds];
    _defaultPublishPeriodModel = periodModel;
    _security = SigMeshMessageSecurityLow;
    _defaultReliableIntervalOfNotLPN = kSDKLibCommandTimeout;
    _defaultReliableIntervalOfLPN = kSDKLibCommandTimeout * 2;
    //默认为写死的pts的root.der根证书
    _defaultRootCertificateData = [LibTools nsstringToHex:@"308202873082022EA003020102020101300A06082A8648CE3D04030230819D310B30090603550406130255533113301106035504080C0A57617368696E67746F6E31163014060355040A0C0D426C7565746F6F746820534947310C300A060355040B0C03505453312D302B06035504030C2430303142444330382D313032312D304230452D304130432D3030304230453041304330303124302206092A864886F70D0109011615737570706F727440626C7565746F6F74682E636F6D301E170D3139303731383138353533365A170D3330313030343138353533365A30819D310B30090603550406130255533113301106035504080C0A57617368696E67746F6E31163014060355040A0C0D426C7565746F6F746820534947310C300A060355040B0C03505453312D302B06035504030C2430303142444330382D313032312D304230452D304130432D3030304230453041304330303124302206092A864886F70D0109011615737570706F727440626C7565746F6F74682E636F6D3059301306072A8648CE3D020106082A8648CE3D03010703420004D183194D0257D2141D3C5566639B4F7AF0834945349B7207DDDA730693FD2B56B8A83AC49FD22517D28D0EED9AE3F1D43A221FE37919B66E9418FF9618C2081EA35D305B301D0603551D0E041604142556CB5D177EFA709C7E05CCB7418A3B714C0A77301F0603551D230418301680142556CB5D177EFA709C7E05CCB7418A3B714C0A77300C0603551D13040530030101FF300B0603551D0F040403020106300A06082A8648CE3D040302034700304402207C9696D079CB866BEA5EAAC230FB52EB5BC8EFC72F46E25F7B1E7990401BC74202206B6FD9F0DBAC54D4121045FD0E4AC06D5F3306BF8DCAF32F2D701C1445A62EF8"];
//    _defaultRootCertificateData = [LibTools getDataWithFileName:@"root" fileType:@"der"];
//    _defaultRootCertificateData =[LibTools getDataWithFileName:@"root_error" fileType:@"der"];
}

- (NSDictionary *)getDictionaryFromDataSource {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_meshUUID) {
        if (_meshUUID.length == 32) {
            dict[@"meshUUID"] = [LibTools UUIDToMeshUUID:_meshUUID];
        } else if (_meshUUID.length == 36) {
            dict[@"meshUUID"] = _meshUUID;
        }
    }
    if (_meshName) {
        dict[@"meshName"] = _meshName;
    }
    if (_schema) {
        dict[@"$schema"] = _schema;
    }
    if (_jsonFormatID) {
        dict[@"id"] = _jsonFormatID;
    }
    if (_version) {
        dict[@"version"] = _version;
    }
    if (_timestamp) {
        dict[@"timestamp"] = _timestamp;
    }
    if (_ivIndex) {
        dict[@"ivIndex"] = _ivIndex;
    }
    dict[@"partial"] = [NSNumber numberWithBool:_partial];
    if (_networkExclusions) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *netKeys = [NSArray arrayWithArray:_networkExclusions];
        for (SigExclusionModel *model in netKeys) {
            NSDictionary *exclusionDict = [model getDictionaryOfSigExclusionModel];
            [array addObject:exclusionDict];
        }
        dict[@"networkExclusions"] = array;
    }
    if (_netKeys) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *netKeys = [NSArray arrayWithArray:_netKeys];
        for (SigNetkeyModel *model in netKeys) {
            NSDictionary *netkeyDict = [model getDictionaryOfSigNetkeyModel];
            [array addObject:netkeyDict];
        }
        dict[@"netKeys"] = array;
    }
    if (_appKeys) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *appKeys = [NSArray arrayWithArray:_appKeys];
        for (SigAppkeyModel *model in appKeys) {
            NSDictionary *appkeyDict = [model getDictionaryOfSigAppkeyModel];
            [array addObject:appkeyDict];
        }
        dict[@"appKeys"] = array;
    }
    if (_provisioners) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *provisioners = [NSArray arrayWithArray:_provisioners];
        for (SigProvisionerModel *model in provisioners) {
            NSDictionary *provisionDict = [model getDictionaryOfSigProvisionerModel];
            [array addObject:provisionDict];
        }
        dict[@"provisioners"] = array;
    }
    if (_nodes) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *nodes = [NSArray arrayWithArray:_nodes];
        for (SigNodeModel *model in nodes) {
            NSDictionary *nodeDict = [model getDictionaryOfSigNodeModel];
            [array addObject:nodeDict];
        }
        dict[@"nodes"] = array;
    }
    if (_groups) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *groups = [NSArray arrayWithArray:_groups];
        for (SigGroupModel *model in groups) {
            NSDictionary *groupDict = [model getDictionaryOfSigGroupModel];
            [array addObject:groupDict];
        }
        dict[@"groups"] = array;
    }
    if (_scenes) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *scenes = [NSArray arrayWithArray:_scenes];
        for (SigSceneModel *model in scenes) {
            NSDictionary *sceneDict = [model getDictionaryOfSigSceneModel];
            [array addObject:sceneDict];
        }
        dict[@"scenes"] = array;
    }
    return dict;
}

- (void)setDictionaryToDataSource:(NSDictionary *)dictionary {
    if (dictionary == nil || dictionary.allKeys.count == 0) {
        return;
    }
    _curNodes = nil;
    NSArray *allKeys = dictionary.allKeys;
    if ([allKeys containsObject:@"meshUUID"]) {
        NSString *str = dictionary[@"meshUUID"];
        if (str.length == 32) {
            _meshUUID = [LibTools UUIDToMeshUUID:str];
        } else if (str.length == 36) {
            _meshUUID = str;
        }
    }
    if ([allKeys containsObject:@"meshName"]) {
        _meshName = dictionary[@"meshName"];
    }
    if ([allKeys containsObject:@"$schema"]) {
        _schema = dictionary[@"$schema"];
    }
    if ([allKeys containsObject:@"id"]) {
        _jsonFormatID = dictionary[@"id"];
    }
    if ([allKeys containsObject:@"version"]) {
        _version = dictionary[@"version"];
    }
    if ([allKeys containsObject:@"timestamp"]) {
        _timestamp = dictionary[@"timestamp"];
    }
    if ([allKeys containsObject:@"ivIndex"]) {
        _ivIndex = dictionary[@"ivIndex"];
    }
    if ([allKeys containsObject:@"partial"]) {
        _partial = [dictionary[@"partial"] boolValue];
    }
    if ([allKeys containsObject:@"networkExclusions"]) {
        NSMutableArray *netKeys = [NSMutableArray array];
        NSArray *array = dictionary[@"networkExclusions"];
        for (NSDictionary *netkeyDict in array) {
            SigExclusionModel *model = [[SigExclusionModel alloc] init];
            [model setDictionaryToSigExclusionModel:netkeyDict];
            [netKeys addObject:model];
        }
        _networkExclusions = netKeys;
    }
    if ([allKeys containsObject:@"netKeys"]) {
        NSMutableArray *netKeys = [NSMutableArray array];
        NSArray *array = dictionary[@"netKeys"];
        for (NSDictionary *netkeyDict in array) {
            SigNetkeyModel *model = [[SigNetkeyModel alloc] init];
            [model setDictionaryToSigNetkeyModel:netkeyDict];
            [netKeys addObject:model];
        }
        _netKeys = netKeys;
    }
    if ([allKeys containsObject:@"appKeys"]) {
        NSMutableArray *appKeys = [NSMutableArray array];
        NSArray *array = dictionary[@"appKeys"];
        for (NSDictionary *appkeyDict in array) {
            SigAppkeyModel *model = [[SigAppkeyModel alloc] init];
            [model setDictionaryToSigAppkeyModel:appkeyDict];
            [appKeys addObject:model];
        }
        _appKeys = appKeys;
    }
    if ([allKeys containsObject:@"provisioners"]) {
        NSMutableArray *provisioners = [NSMutableArray array];
        NSArray *array = dictionary[@"provisioners"];
        for (NSDictionary *provisionDict in array) {
            SigProvisionerModel *model = [[SigProvisionerModel alloc] init];
            [model setDictionaryToSigProvisionerModel:provisionDict];
            [provisioners addObject:model];
        }
        _provisioners = provisioners;
    }
    if ([allKeys containsObject:@"nodes"]) {
        NSMutableArray *nodes = [NSMutableArray array];
        NSArray *array = dictionary[@"nodes"];
        for (NSDictionary *nodeDict in array) {
            SigNodeModel *model = [[SigNodeModel alloc] init];
            [model setDictionaryToSigNodeModel:nodeDict];
            [nodes addObject:model];
        }
        _nodes = nodes;
    }
    if ([allKeys containsObject:@"groups"]) {
        NSMutableArray *groups = [NSMutableArray array];
        NSArray *array = dictionary[@"groups"];
        for (NSDictionary *groupDict in array) {
            SigGroupModel *model = [[SigGroupModel alloc] init];
            [model setDictionaryToSigGroupModel:groupDict];
            [groups addObject:model];
        }
        _groups = groups;
    }
    if ([allKeys containsObject:@"scenes"]) {
        NSMutableArray *scenes = [NSMutableArray array];
        NSArray *array = dictionary[@"scenes"];
        for (NSDictionary *sceneDict in array) {
            SigSceneModel *model = [[SigSceneModel alloc] init];
            [model setDictionaryToSigSceneModel:sceneDict];
            [scenes addObject:model];
        }
        _scenes = scenes;
    }
    _curNetkeyModel = nil;
    _curAppkeyModel = nil;
}

- (NSDictionary *)getFormatDictionaryFromDataSource {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_meshUUID) {
        if (_meshUUID.length == 32) {
            dict[@"meshUUID"] = [LibTools UUIDToMeshUUID:_meshUUID];
        } else if (_meshUUID.length == 36) {
            dict[@"meshUUID"] = _meshUUID;
        }
    }
    if (_meshName) {
        dict[@"meshName"] = _meshName;
    }
    if (_schema) {
        dict[@"$schema"] = _schema;
    }
    if (_jsonFormatID) {
        dict[@"id"] = _jsonFormatID;
    }
    if (_version) {
        dict[@"version"] = _version;
    }
    if (_timestamp) {
        dict[@"timestamp"] = _timestamp;
    }
    if (_ivIndex) {
        dict[@"ivIndex"] = _ivIndex;
    }
    dict[@"partial"] = [NSNumber numberWithBool:_partial];
    if (_networkExclusions) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *netKeys = [NSArray arrayWithArray:_networkExclusions];
        for (SigExclusionModel *model in netKeys) {
            NSDictionary *exclusionDict = [model getDictionaryOfSigExclusionModel];
            [array addObject:exclusionDict];
        }
        dict[@"networkExclusions"] = array;
    }
    if (_netKeys) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *netKeys = [NSArray arrayWithArray:_netKeys];
        for (SigNetkeyModel *model in netKeys) {
            NSDictionary *netkeyDict = [model getDictionaryOfSigNetkeyModel];
            [array addObject:netkeyDict];
        }
        dict[@"netKeys"] = array;
    }
    if (_appKeys) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *appKeys = [NSArray arrayWithArray:_appKeys];
        for (SigAppkeyModel *model in appKeys) {
            NSDictionary *appkeyDict = [model getDictionaryOfSigAppkeyModel];
            [array addObject:appkeyDict];
        }
        dict[@"appKeys"] = array;
    }
    if (_provisioners) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *provisioners = [NSArray arrayWithArray:_provisioners];
        for (SigProvisionerModel *model in provisioners) {
            NSDictionary *provisionDict = [model getDictionaryOfSigProvisionerModel];
            [array addObject:provisionDict];
        }
        dict[@"provisioners"] = array;
    }
    if (_nodes) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *nodes = [NSArray arrayWithArray:_nodes];
        for (SigNodeModel *model in nodes) {
            NSDictionary *nodeDict = [model getFormatDictionaryOfSigNodeModel];
            [array addObject:nodeDict];
        }
        dict[@"nodes"] = array;
    }
    if (_groups) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *groups = [NSArray arrayWithArray:_groups];
        for (SigGroupModel *model in groups) {
            NSDictionary *groupDict = [model getDictionaryOfSigGroupModel];
            [array addObject:groupDict];
        }
        dict[@"groups"] = array;
    }
    if (_scenes) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *scenes = [NSArray arrayWithArray:_scenes];
        for (SigSceneModel *model in scenes) {
            NSDictionary *sceneDict = [model getFormatDictionaryOfSigSceneModel];
            [array addObject:sceneDict];
        }
        dict[@"scenes"] = array;
    }
    dict[@"id"] = @"http://www.bluetooth.com/specifications/assigned-numbers/mesh-profile/cdb-schema.json#";
    return dict;
}

- (UInt16)provisionAddress{
    if (!self.curProvisionerModel) {
        TeLogInfo(@"warning: Abnormal situation, there is not provisioner.");
        return kLocationAddress;
    } else {
        UInt16 maxAddr = self.curProvisionerModel.allocatedUnicastRange.firstObject.lowIntAddress;
        NSArray *nodes = [NSArray arrayWithArray:_nodes];
        for (SigNodeModel *node in nodes) {
            NSInteger curMax = node.address + node.elements.count - 1;
            if (curMax > maxAddr) {
                maxAddr = curMax;
            }
        }

        NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentMeshProvisionAddress_key];
        if (dict) {
            NSString *key = [self getKeyOfMaxUsedUnicastAddressOfLocationWithMeshUUID:self.meshUUID provisionerUUID:self.getCurrentProvisionerUUID];
            if ([dict.allKeys containsObject:key]) {
                UInt16 localMaxAddr = [dict[key] intValue];
                if (maxAddr > localMaxAddr) {
                    [self saveLocationProvisionAddress:maxAddr];
                } else {
                    maxAddr = localMaxAddr;
                }
            } else {
                [self saveLocationProvisionAddress:maxAddr];
            }
        } else {
            [self saveLocationProvisionAddress:maxAddr];
        }

        //限制短地址的做法：
//        if (maxAddr + 1 <= self.curProvisionerModel.allocatedUnicastRange.firstObject.hightIntAddress) {
//            //Attention: location address is the smallest address of allocatedUnicastRange, app can add new node by use address from smallest address+1.
//            return maxAddr + 1;
//        } else {
//            TeLogInfo(@"warning: Abnormal situation, there is no more address can be use.");
//            return 0;
//        }
        //不限制短地址的做法：
        return maxAddr + 1;
    }
}

- (SigAppkeyModel *)curAppkeyModel{
    if (_curAppkeyModel == nil) {
        //The default use first appkey temporarily
        if (_appKeys && _appKeys.count > 0) {
            _curAppkeyModel = _appKeys.firstObject;
        }
    }
    return _curAppkeyModel;
}

- (SigNetkeyModel *)curNetkeyModel{
    if (_curNetkeyModel == nil) {
        //The default use first netkey temporarily
        if (_netKeys && _netKeys.count > 0) {
            _curNetkeyModel = _netKeys.firstObject;
        }
    }
    return _curNetkeyModel;
}

- (SigProvisionerModel *)curProvisionerModel{
    //Practice 1. Temporary default to the first provisioner
//    if (self.provisioners.count > 0) {
//        return self.provisioners.firstObject;
//    }
    //Practice 2. get provisioner by location node's uuid.
    NSString *curUUID = [self getCurrentProvisionerUUID];
    NSArray *provisioners = [NSArray arrayWithArray: _provisioners];
    for (SigProvisionerModel *provisioner in provisioners) {
        if ([provisioner.UUID isEqualToString:curUUID]) {
            return provisioner;
        }
    }
    return nil;
}

- (NSData *)curNetKey{
    if (self.curNetkeyModel) {
        return [LibTools nsstringToHex:self.curNetkeyModel.key];
    }
    return nil;
}

- (NSData *)curAppKey{
    if (self.curAppkeyModel) {
        return [LibTools nsstringToHex:self.curAppkeyModel.key];
    }
    return nil;
}

- (SigNodeModel *)curLocationNodeModel{
    if (self.curProvisionerModel) {
        NSArray *nodes = [NSArray arrayWithArray: self.nodes];
        for (SigNodeModel *model in nodes) {
            if ([model.UUID isEqualToString:self.curProvisionerModel.UUID]) {
                return model;
            }
        }
    }
    return nil;
}

- (NSInteger)getOnlineDevicesNumber{
    NSInteger count = 0;
    NSArray *curNodes = [NSArray arrayWithArray:self.curNodes];
    for (SigNodeModel *model in curNodes) {
        if (model.state != DeviceStateOutOfLine) {
            count ++;
        }
    }
    return count;
}

- (BOOL)hasNodeExistTimeModelID {
    BOOL tem = NO;
    NSArray *curNodes = [NSArray arrayWithArray:self.curNodes];
    for (SigNodeModel *node in curNodes) {
        UInt32 option = kSigModel_TimeServer_ID;
        NSArray *elementAddresses = [node getAddressesWithModelID:@(option)];
        if (elementAddresses.count > 0) {
            tem = YES;
            break;
        }
    }
    return tem;
}

///Special handling: store the uuid of current provisioner.
- (void)saveCurrentProvisionerUUID:(NSString *)uuid {
    if (uuid.length == 32) {
        uuid = [LibTools UUIDToMeshUUID:uuid];
    }
    [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:kCurrenProvisionerUUID_key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

///Special handling: get the uuid of current provisioner.
- (NSString *)getCurrentProvisionerUUID{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [defaults objectForKey:kCurrenProvisionerUUID_key];
    if (uuid.length == 32) {
        uuid = [LibTools UUIDToMeshUUID:uuid];
    }
    return uuid;
}

- (NSData *)getLocationMeshData {
    return [NSUserDefaults.standardUserDefaults objectForKey:kSaveLocationDataKey];
}

- (void)saveLocationMeshData:(NSData *)data {
    [NSUserDefaults.standardUserDefaults setObject:data forKey:kSaveLocationDataKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

/// Init SDK location Data(include create mesh.json, check provisioner, provisionLocation)
- (void)configData{
    //初始化当前手机的唯一标识UUID，卸载重新安装才会重新生成。
    NSString *provisionerUUID = [self getCurrentProvisionerUUID];
    if (provisionerUUID == nil) {
        [self saveCurrentProvisionerUUID:[LibTools convertDataToHexStr:[LibTools initMeshUUID]]];
    }
    
    NSData *locationData = [self getLocationMeshData];
    BOOL exist = locationData.length > 0;
    if (!exist) {
        //don't exist mesh.json, create and init mesh
        [self initMeshData];
        TeLogInfo(@"creat mesh_sample.json success");
        [self saveLocationData];
    }else{
        //exist mesh.json, load json
        NSData *data = [self getLocationMeshData];
        NSDictionary *meshDict = [LibTools getDictionaryWithJSONData:data];
        [self setDictionaryToDataSource:meshDict];
        //Attention: it will set _ivIndex to kDefaultIvIndex when mesh.json hasn't the key @"ivIndex"
        if (!_ivIndex || _ivIndex.length == 0) {
            _ivIndex = [NSString stringWithFormat:@"%08X",(unsigned int)kDefaultIvIndex];
            [self saveLocationData];
        }
    }
    //check provisioner
    [self checkExistLocationProvisioner];
    //init SigScanRspModel list
    [self loadScanList];
    //init Bluetooth
    [SigBluetooth share];
}

- (void)initMeshData {
    NSString *timestamp = [LibTools getNowTimeStringOfJson];
    //1.netKeys
    SigNetkeyModel *netkey = [[SigNetkeyModel alloc] init];
    netkey.index = 0;
    netkey.phase = 0;
    netkey.timestamp = timestamp;
    netkey.oldKey = @"00000000000000000000000000000000";
    netkey.key = [LibTools convertDataToHexStr:[LibTools createNetworkKey]];
    netkey.name = @"Default NetKey";
    netkey.minSecurity = @"secure";
    _curNetkeyModel = nil;
    [_netKeys removeAllObjects];
    [_netKeys addObject:netkey];

    //2.appKeys
    SigAppkeyModel *appkey = [[SigAppkeyModel alloc] init];
    appkey.oldKey = @"00000000000000000000000000000000";
    appkey.key = [LibTools convertDataToHexStr:[LibTools initAppKey]];
    appkey.name = @"Default AppKey";
    appkey.boundNetKey = 0;
    appkey.index = 0;
    _curAppkeyModel = nil;
    [_appKeys removeAllObjects];
    [_appKeys addObject:appkey];

    //3.provisioners
    SigProvisionerModel *provisioner = [[SigProvisionerModel alloc] initWithExistProvisionerMaxHighAddressUnicast:0 andProvisionerUUID:[self getCurrentProvisionerUUID]];
    [_provisioners removeAllObjects];
    [_provisioners addObject:provisioner];

    //4.add new provisioner to nodes
    _curNodes = nil;
    [_nodes removeAllObjects];
    [self addLocationNodeWithProvisioner:provisioner];

    //5.add default group
    Groups *defultGroup = [[Groups alloc] init];
    [_groups removeAllObjects];
    for (int i=0; i<defultGroup.groupCount; i++) {
        SigGroupModel *group = [[SigGroupModel alloc] init];
        group.address = [NSString stringWithFormat:@"%04X",0xc000+i];
        group.parentAddress = [NSString stringWithFormat:@"%04X",0];
        group.name = defultGroup.names[i];
        [_groups addObject: group];
    }

    [_scenes removeAllObjects];
    [_encryptedArray removeAllObjects];
    
    _meshUUID = netkey.key;
    _schema = @"http://json-schema.org/draft-04/schema#";
    _jsonFormatID = @"http://www.bluetooth.com/specifications/assigned-numbers/mesh-profile/cdb-schema.json#";
    _meshName = @"Telink-Sig-Mesh";
//    _version = LibTools.getSDKVersion;
    _version = @"1.0.0";
    _timestamp = timestamp;
    _ivIndex = [NSString stringWithFormat:@"%08X",(unsigned int)kDefaultIvIndex];
}

- (void)addLocationNodeWithProvisioner:(SigProvisionerModel *)provisioner{
    SigNodeModel *node = [[SigNodeModel alloc] init];

    //init defoult data
    node.UUID = provisioner.UUID;
    node.secureNetworkBeacon = YES;
    node.defaultTTL = TTL_DEFAULT;
    node.features.proxyFeature = SigNodeFeaturesState_notSupported;
    node.features.friendFeature = SigNodeFeaturesState_notEnabled;
    node.features.relayFeature = SigNodeFeaturesState_notSupported;
    node.relayRetransmit.relayRetransmitCount = 5;
    node.relayRetransmit.relayRetransmitIntervalSteps = 2;
    node.unicastAddress = [NSString stringWithFormat:@"%04X",(UInt16)provisioner.allocatedUnicastRange.firstObject.lowIntAddress];
    node.name = @"Telink iOS provisioner node";
    node.cid = @"0211";
    node.pid = @"0100";
    node.vid = @"0100";
    node.crpl = @"0100";
    
    //添加本地节点的element
    NSMutableArray *elements = [NSMutableArray array];
    SigElementModel *element = [[SigElementModel alloc] init];
    element.name = @"Primary Element";
    element.location = @"0000";
    element.index = 0;
    NSMutableArray *models = [NSMutableArray array];
//    NSArray *defaultModelIDs = @[@"0000",@"0001",@"0002",@"0003",@"0005",@"FE00",@"FE01",@"FE02",@"FE03",@"FF00",@"FF01",@"1202",@"1001",@"1003",@"1005",@"1008",@"1205",@"1208",@"1302",@"1305",@"1309",@"1311",@"1015",@"00010211"];
    NSArray *defaultModelIDs = @[@"0000",@"0001"];
    for (NSString *modelID in defaultModelIDs) {
        SigModelIDModel *modelIDModel = [[SigModelIDModel alloc] init];
        modelIDModel.modelId = modelID;
        modelIDModel.subscribe = [NSMutableArray array];
        modelIDModel.bind = [NSMutableArray arrayWithArray:@[@(0)]];
        [models addObject:modelIDModel];
    }
    element.models = models;
    element.parentNodeAddress = node.address;
    [elements addObject:element];
    node.elements = elements;
    
    NSData *devicekeyData = [LibTools createRandomDataWithLength:16];
    node.deviceKey = [LibTools convertDataToHexStr:devicekeyData];
    SigAppkeyModel *appkey = [self curAppkeyModel];
    SigNodeKeyModel *nodeAppkey = [[SigNodeKeyModel alloc] init];
    nodeAppkey.index = appkey.index;
    if (![node.appKeys containsObject:nodeAppkey]) {
        [node.appKeys addObject:nodeAppkey];
    }
    SigNodeKeyModel *nodeNetkey = [[SigNodeKeyModel alloc] init];
    nodeNetkey.index = self.curNetkeyModel.index;
    if (![node.netKeys containsObject:nodeNetkey]) {
        [node.netKeys addObject:nodeNetkey];
    }

    [_nodes addObject:node];
}

- (void)deleteNodeFromMeshNetworkWithDeviceAddress:(UInt16)deviceAddress{
    @synchronized(self) {
        NSArray *nodes = [NSArray arrayWithArray:_nodes];
        for (int i=0; i<nodes.count; i++) {
            SigNodeModel *model = nodes[i];
            if (model.address == deviceAddress) {
                [_nodes removeObjectAtIndex:i];
                break;
            }
        }
        NSArray *scenes = [NSArray arrayWithArray:_scenes];
        for (SigSceneModel *scene in scenes) {
//            for (NSString *actionAddress in scene.addresses) {
//                if (actionAddress.intValue == deviceAddress) {
//                    [scene.addresses removeObject:actionAddress];
//                    break;
//                }
//            }
            NSArray *actionList = [NSArray arrayWithArray:scene.actionList];
            for (ActionModel *action in actionList) {
                if (action.address == deviceAddress) {
                    [scene.actionList removeObject:action];
                    break;
                }
            }
        }
        [self saveLocationData];
        [self deleteScanRspModelWithAddress:deviceAddress];
        [self deleteSigEncryptedModelWithAddress:deviceAddress];
    }
}

/// check SigDataSource.provisioners, this api will auto create a provisioner when SigDataSource.provisioners hasn't provisioner corresponding to app's UUID.
- (void)checkExistLocationProvisioner{
    if (_encryptedArray) {
        [_encryptedArray removeAllObjects];
    }
    if (self.curProvisionerModel) {
        TeLogInfo(@"exist location provisioner, needn't create");
        //sno添加增量
        [self setLocationSno:self.getLocationSno + self.defaultSequenceNumberIncrement];
    }else{
        //don't exist location provisioner, create and add to SIGDataSource.provisioners, then save location.
        //Attention: the max location address is 0x7fff, so max provisioner's allocatedUnicastRange highAddress cann't bigger than 0x7fff.
        if (self.provisioners.count <= 0x7f) {
            SigProvisionerModel *provisioner = [[SigProvisionerModel alloc] initWithExistProvisionerMaxHighAddressUnicast:[self getMaxHighAddressUnicast] andProvisionerUUID:[self getCurrentProvisionerUUID]];
            [_provisioners addObject:provisioner];
            [self addLocationNodeWithProvisioner:provisioner];
            _timestamp = [LibTools getNowTimeStringOfJson];
            [self saveLocationData];
        }else{
            TeLogInfo(@"waring: count of provisioners is bigger than 0x7f, app allocates node address will be error.");
        }
    }
}

- (void)changeLocationProvisionerNodeAddressToAddress:(UInt16)address {
    SigNodeModel *node = self.curLocationNodeModel;
    node.unicastAddress = [NSString stringWithFormat:@"%04X",address];
}

- (NSInteger)getProvisionerCount{
    NSInteger max = 0;
    NSArray *provisioners = [NSArray arrayWithArray:_provisioners];
    for (SigProvisionerModel *provisioner in provisioners) {
        if (max < provisioner.allocatedUnicastRange.firstObject.hightIntAddress) {
            max = provisioner.allocatedUnicastRange.firstObject.hightIntAddress;
        }
    }
    NSInteger count = (max >> 8) + 1;
    return count;
}

- (UInt16)getMaxHighAddressUnicast {
    UInt16 max = 0;
    NSArray *provisioners = [NSArray arrayWithArray:_provisioners];
    for (SigProvisionerModel *provisioner in provisioners) {
        for (SigRangeModel *unicastRange in provisioner.allocatedUnicastRange) {
            if (max < unicastRange.hightIntAddress) {
                max = unicastRange.hightIntAddress;
            }
        }
    }
    return max;
}

- (void)editGroupIDsOfDevice:(BOOL)add unicastAddress:(NSNumber *)unicastAddress groupAddress:(NSNumber *)groupAddress{
    @synchronized(self) {
        SigNodeModel *model = [self getDeviceWithAddress:[unicastAddress intValue]];
        if (model) {
            if (add) {
                if (![model.getGroupIDs containsObject:groupAddress]) {
                    [model addGroupID:groupAddress];
                    [self saveLocationData];
                } else {
                    TeLogInfo(@"add group model fail.");
                }
            } else {
                if (![model.getGroupIDs containsObject:groupAddress]) {
                    TeLogInfo(@"delete group model fail.");
                } else {
                    [model deleteGroupID:groupAddress];
                    [self saveLocationData];
                }
            }
        } else {
            TeLogInfo(@"edit group model fail, node no found.");
        }
    }
}

- (void)addAndSaveNodeToMeshNetworkWithDeviceModel:(SigNodeModel *)model{
    @synchronized(self) {
        if ([_nodes containsObject:model]) {
            NSInteger index = [_nodes indexOfObject:model];
            _nodes[index] = model;
        } else {
            [_nodes addObject:model];
        }
        [self saveLocationData];
    }
}

- (void)setAllDevicesOutline{
    @synchronized(self) {
        _curNodes = nil;
        NSArray *nodes = [NSArray arrayWithArray:_nodes];
        for (SigNodeModel *model in nodes) {
            model.state = DeviceStateOutOfLine;
        }
    }
}

- (void)saveLocationData{
//    TeLogDebug(@"");
    @synchronized(self) {
        //sort
        [self.nodes sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [(SigNodeModel *)obj1 address] > [(SigNodeModel *)obj2 address];
        }];
        [self.groups sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [(SigGroupModel *)obj1 intAddress] > [(SigGroupModel *)obj2 intAddress];
        }];
        [self.scenes sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [(SigSceneModel *)obj1 number] > [(SigSceneModel *)obj2 number];
        }];

        NSDictionary *meshDict = [self getDictionaryFromDataSource];
        NSData *tempData = [LibTools getJSONDataWithDictionary:meshDict];
        [self saveLocationMeshData:tempData];
        saveMeshJsonData([LibTools getReadableJSONStringWithDictionary:meshDict]);
    }
}

///Special handling: store the uuid and MAC mapping relationship.
- (void)saveScanList {
    NSMutableArray *tem = [NSMutableArray array];
    NSArray *nodes = [NSArray arrayWithArray:self.curNodes];
    for (SigNodeModel *node in nodes) {
        SigScanRspModel *rsp = [self getScanRspModelWithAddress:node.address];
        if (rsp) {
            [tem addObject:rsp];
        }
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tem];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kScanList_key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

///Special handling: load the uuid and MAC mapping relationship.
- (void)loadScanList {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:kScanList_key];
    if (data) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (array && array.count) {
            [self.scanList addObjectsFromArray:array];
        }
    }
}

///Special handling: clean the uuid and MAC mapping relationship.
- (void)cleanScanList {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kScanList_key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (SigNodeModel *)getDeviceWithAddress:(UInt16)address{
    NSArray *curNodes = [NSArray arrayWithArray:self.curNodes];
    for (SigNodeModel *model in curNodes) {
        if (model.getElementCount > 1) {
            if (model.address <= address && model.address + model.getElementCount - 1 >= address) {
                return model;
            }
        } else {
            if (model.address == address) {
                return model;
            }
        }
    }
    return nil;
}

///nodes should show in HomeViewController
- (NSMutableArray<SigNodeModel *> *)curNodes{
    @synchronized(self) {
        if (_curNodes && _curNodes.count == _nodes.count - _provisioners.count) {
            return _curNodes;
        } else {
            _curNodes = [NSMutableArray array];
            NSArray *nodes = [NSArray arrayWithArray:_nodes];
            for (SigNodeModel *node in nodes) {
                BOOL isProvisioner = NO;
                NSArray *provisioners = [NSArray arrayWithArray:_provisioners];
                for (SigProvisionerModel *provisioner in provisioners) {
                    if (node.UUID && [node.UUID isEqualToString:provisioner.UUID]) {
                        isProvisioner = YES;
                        break;
                    }
                }
                if (isProvisioner) {
                    continue;
                }
                [_curNodes addObject:node];
            }
            return _curNodes;
        }
    }
}

- (void)saveLocationProvisionAddress:(NSInteger)address{
    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentMeshProvisionAddress_key];
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
    }else{
        dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    NSString *key = [self getKeyOfMaxUsedUnicastAddressOfLocationWithMeshUUID:self.meshUUID provisionerUUID:self.getCurrentProvisionerUUID];
    [dict setObject:[NSNumber numberWithInteger:address] forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kCurrentMeshProvisionAddress_key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateNodeStatusWithBaseMeshMessage:(SigBaseMeshMessage *)responseMessage source:(UInt16)source {
    SigNodeModel *node = [self getDeviceWithAddress:source];
    if (responseMessage && node) {
        [node updateNodeStatusWithBaseMeshMessage:responseMessage source:source];
    }
}

- (UInt16)getNewSceneAddress{
    UInt16 address = 1;
    if (_scenes.count > 0) {
        [_scenes sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [LibTools uint16From16String:[(SigSceneModel *)obj1 number]] > [LibTools uint16From16String:[(SigSceneModel *)obj2 number]];
        }];
        address = [LibTools uint16From16String:_scenes.lastObject.number] + 1;
    }
    return address;
}

- (void)saveSceneModelWithModel:(SigSceneModel *)model{
    @synchronized(self) {
        SigSceneModel *scene = [[SigSceneModel alloc] init];
        scene.number = model.number;
        scene.name = model.name;
        scene.actionList = [[NSMutableArray alloc] initWithArray:model.actionList];

        if ([self.scenes containsObject:scene]) {
            NSInteger index = [self.scenes indexOfObject:scene];
            self.scenes[index] = scene;
        } else {
            [self.scenes addObject:scene];
        }
        [self saveLocationData];
    }
}

- (void)delectSceneModelWithModel:(SigSceneModel *)model{
    @synchronized(self) {
        if ([self.scenes containsObject:model]) {
            [self.scenes removeObject:model];
            [self saveLocationData];
        }
    }
}

- (NSData *)getIvIndexData{
    return [LibTools nsstringToHex:_ivIndex];
}

//- (void)updateIvIndexString:(NSString *)ivIndexString {
//    _ivIndex = ivIndexString;
//    [self saveLocationData];
//}

- (int)getCurrentProvisionerIntSequenceNumber {
    if (self.curLocationNodeModel) {
        return [self getLocationSno];
    }
    TeLogInfo(@"get sequence fail.");
    return 0;
}

- (void)updateCurrentProvisionerIntSequenceNumber:(int)sequenceNumber {
    if (sequenceNumber < self.getCurrentProvisionerIntSequenceNumber) {
//        TeLogVerbose(@"更新sequenceNumber异常=0x%x",sequenceNumber);
        return;
    }
    if (self.curLocationNodeModel && sequenceNumber != self.getCurrentProvisionerIntSequenceNumber) {
//        TeLogVerbose(@"更新，下一个可用的sequenceNumber=0x%x",sequenceNumber);
        [self setLocationSno:sequenceNumber];
    }else{
//        TeLogVerbose(@"set sequence=0x%x again.",sequenceNumber);
    }
}

- (UInt32)getLocationSno {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *sno = [defaults objectForKey:kCurrenProvisionerSno_key];
    if (!sno) {
        sno = @(0);
    }
//    TeLogVerbose(@"sno=0x%x",sno.intValue);
    return sno.intValue;
}

- (void)setLocationSno:(UInt32)sno {
    if ((sno - _sequenceNumberOnDelegate >= self.defaultSequenceNumberIncrement) || (sno < _sequenceNumberOnDelegate)) {
        self.sequenceNumberOnDelegate = sno;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onSequenceNumberUpdate:ivIndexUpdate:)]) {
                [weakSelf.delegate onSequenceNumberUpdate:weakSelf.sequenceNumberOnDelegate ivIndexUpdate:[LibTools uint32From16String:weakSelf.ivIndex]];
            }
        });
    }
    //    TeLogVerbose(@"sno=0x%x",(unsigned int)sno);
    [[NSUserDefaults standardUserDefaults] setObject:@(sno) forKey:kCurrenProvisionerSno_key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateIvIndexString:(NSString *)ivIndexString {
    if (![ivIndexString isEqualToString:_ivIndex]) {
        _ivIndex = ivIndexString;
        UInt32 newSequenceNumber = 0;
        _sequenceNumberOnDelegate = newSequenceNumber;
        [[NSUserDefaults standardUserDefaults] setObject:@(newSequenceNumber) forKey:kCurrenProvisionerSno_key];
        //v3.3.3之后。(因为ivIndex更新后，所有设备端的sequenceNumber会归零。)
        [[NSUserDefaults standardUserDefaults] setValue:@{} forKey:SigMeshLib.share.dataSource.meshUUID];
        [[NSUserDefaults standardUserDefaults] synchronize];// save sequenceNumber
        [self saveLocationData];// save ivIndex
        __block NSString *blockIv = _ivIndex;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(onSequenceNumberUpdate:ivIndexUpdate:)]) {
                [weakSelf.delegate onSequenceNumberUpdate:weakSelf.sequenceNumberOnDelegate ivIndexUpdate:[LibTools uint32From16String:blockIv]];
            }
        });
    }
}

- (SigEncryptedModel *)getSigEncryptedModelWithAddress:(UInt16)address {
    SigEncryptedModel *tem = nil;
    NSArray *encryptedArray = [NSArray arrayWithArray:_encryptedArray];
    for (SigEncryptedModel *model in encryptedArray) {
        if (model.address == address) {
            return model;
        }
    }
    return tem;
}

- (void)deleteSigEncryptedModelWithAddress:(UInt16)address {
    @synchronized(self) {
        NSArray *encryptedArray = [NSArray arrayWithArray:_encryptedArray];
        for (SigEncryptedModel *model in encryptedArray) {
            if (model.address == address) {
                [_encryptedArray removeObject:model];
                break;
            }
        }
    }
}

///Special handling: determine model whether exist current meshNetwork
- (BOOL)existScanRspModelOfCurrentMeshNetwork:(SigScanRspModel *)model{
    if (model && model.advertisementDataServiceData && model.advertisementDataServiceData.length) {
        SigIdentificationType advType = [model getIdentificationType];
        switch (advType) {
            case SigIdentificationType_networkID:
            {
                if (model.advertisementDataServiceData.length >= 9) {
                    NSData *networkID = [model.advertisementDataServiceData subdataWithRange:NSMakeRange(1, 8)];
                    return [self matchWithNetworkID:networkID];
                }
            }
                break;
            case SigIdentificationType_nodeIdentity:
            {
                if (model.advertisementDataServiceData.length >= 17) {
                    if ([self existEncryptedWithAdvertisementDataServiceData:model.advertisementDataServiceData]) {
                        return YES;
                    } else {
                        return [self matchNodeIdentityWithAdvertisementDataServiceData:model.advertisementDataServiceData peripheralUUIDString:model.uuid nodes:self.curNodes networkKey:self.curNetkeyModel];
                    }
                }
            }
                break;
            case SigIdentificationType_privateNetworkIdentity:
            {
                TeLogDebug(@"receive SigIdentificationType_privateNetworkIdentity");
                if (model.advertisementDataServiceData.length >= 17) {
                    if ([self existEncryptedWithAdvertisementDataServiceData:model.advertisementDataServiceData]) {
                        return YES;
                    } else {
                        return [self matchPrivateNetworkIdentityWithAdvertisementDataServiceData:model.advertisementDataServiceData peripheralUUIDString:model.uuid networkKey:self.curNetkeyModel];
                    }
                }
            }
                break;
            case SigIdentificationType_privateNodeIdentity:
            {
                TeLogDebug(@"receive SigIdentificationType_privateNodeIdentity");
                if (model.advertisementDataServiceData.length >= 17) {
                    if ([self existEncryptedWithAdvertisementDataServiceData:model.advertisementDataServiceData]) {
                        return YES;
                    } else {
                        return [self matchPrivateNodeIdentityWithAdvertisementDataServiceData:model.advertisementDataServiceData peripheralUUIDString:model.uuid nodes:self.curNodes networkKey:self.curNetkeyModel];
                    }
                }
            }
                break;

            default:
                break;
        }
    }
    return NO;
}

///Special handling: determine peripheralUUIDString whether exist current meshNetwork
- (BOOL)existPeripheralUUIDString:(NSString *)peripheralUUIDString{
    SigNodeModel *node = [self getNodeWithUUID:peripheralUUIDString];
    return node != nil;
}

- (BOOL)existEncryptedWithAdvertisementDataServiceData:(NSData *)advertisementDataServiceData {
    SigEncryptedModel *tem = [[SigEncryptedModel alloc] init];
    tem.advertisementDataServiceData = advertisementDataServiceData;
    return [_encryptedArray containsObject:tem];
}

- (BOOL)matchWithNetworkID:(NSData *)networkID {
    if (self.curNetkeyModel.phase == distributingKeys) {
        if (self.curNetkeyModel.oldNetworkId && self.curNetkeyModel.oldNetworkId.length > 0) {
            return [self.curNetkeyModel.oldNetworkId isEqualToData:networkID];
        }
    } else {
        if (self.curNetkeyModel.networkId && self.curNetkeyModel.networkId.length > 0) {
            return [self.curNetkeyModel.networkId isEqualToData:networkID];
        }
    }
    return NO;
}

- (BOOL)matchNodeIdentityWithAdvertisementDataServiceData:(NSData *)advertisementDataServiceData peripheralUUIDString:(NSString *)peripheralUUIDString nodes:(NSArray <SigNodeModel *>*)nodes networkKey:(SigNetkeyModel *)networkKey {
    NSData *hash = [advertisementDataServiceData subdataWithRange:NSMakeRange(1, 8)];
    NSData *random = [advertisementDataServiceData subdataWithRange:NSMakeRange(9, 8)];
    NSArray *curNodes = [NSArray arrayWithArray:nodes];
    for (SigNodeModel *node in curNodes) {
        // Data are: 48 bits of Padding (0s), 64 bit Random and Unicast Address.
        Byte byte[6];
        memset(byte, 0, 6);
        NSData *data = [NSData dataWithBytes:byte length:6];
        NSMutableData *mData = [NSMutableData dataWithData:data];
        [mData appendData:random];
        // 把大端模式的数字Number转为本机数据存放模式
        UInt16 address = CFSwapInt16BigToHost(node.address);;
        data = [NSData dataWithBytes:&address length:2];
        [mData appendData:data];
//        NSLog(@"mdata=%@",mData);
        NSData *encryptedData = [OpenSSLHelper.share calculateEvalueWithData:mData andKey:networkKey.keys.identityKey];
        BOOL isExist = NO;
        if ([[encryptedData subdataWithRange:NSMakeRange(8, encryptedData.length-8)] isEqualToData:hash]) {
            isExist = YES;
        }
        // If the Key refresh procedure is in place, the identity might have been generated with the old key.
        if (!isExist && networkKey.oldKey && networkKey.oldKey.length > 0 && ![networkKey.oldKey isEqualToString:@"00000000000000000000000000000000"]) {
            encryptedData = [OpenSSLHelper.share calculateEvalueWithData:mData andKey:networkKey.oldKeys.identityKey];
            if ([[encryptedData subdataWithRange:NSMakeRange(8, encryptedData.length-8)] isEqualToData:hash]) {
                isExist = YES;
            }
        }
        if (isExist) {
            NSMutableData *mData = [NSMutableData dataWithData:hash];
            [mData appendData:random];
            SigEncryptedModel *tem = [[SigEncryptedModel alloc] init];
            tem.advertisementDataServiceData = advertisementDataServiceData;
            tem.hashData = hash;
            tem.randomData = random;
            tem.peripheralUUID = peripheralUUIDString;
            tem.encryptedData = encryptedData;
            tem.address = node.address;
            [self deleteSigEncryptedModelWithAddress:node.address];
            [self.encryptedArray addObject:tem];
            return YES;
        }
    }
    return NO;
}

- (BOOL)matchPrivateNetworkIdentityWithAdvertisementDataServiceData:(NSData *)advertisementDataServiceData peripheralUUIDString:(NSString *)peripheralUUIDString networkKey:(SigNetkeyModel *)networkKey {
    NSData *networkID = networkKey.networkId;
    NSData *netKey = [LibTools nsstringToHex:networkKey.key];
    NSData *identityKey = networkKey.keys.identityKey;
    if (networkKey.phase == distributingKeys) {
        if (networkKey.oldNetworkId && networkKey.oldNetworkId.length > 0) {
            networkID = networkKey.oldNetworkId;
            netKey = [LibTools nsstringToHex:networkKey.oldKey];
            identityKey = networkKey.oldKeys.identityKey;
        }
    } else {
        if (networkKey.networkId && networkKey.networkId.length > 0) {
            networkID = networkKey.networkId;
            netKey = [LibTools nsstringToHex:networkKey.key];
            identityKey = networkKey.keys.identityKey;
        }
    }
    if (networkID == nil || netKey == nil || identityKey == nil) {
        return NO;
    }
    NSData *hash = [advertisementDataServiceData subdataWithRange:NSMakeRange(1, 8)];
    NSData *random = [advertisementDataServiceData subdataWithRange:NSMakeRange(9, 8)];
    NSMutableData *mData = [NSMutableData dataWithData:networkID];
    [mData appendData:random];
    NSData *encryptedData = [OpenSSLHelper.share calculateEvalueWithData:mData andKey:identityKey];
    BOOL isExist = NO;
    if ([[encryptedData subdataWithRange:NSMakeRange(8, encryptedData.length-8)] isEqualToData:hash]) {
        isExist = YES;
    }
    // If the Key refresh procedure is in place, the identity might have been generated with the old key.
    if (!isExist && networkKey.oldKey && networkKey.oldKey.length > 0 && ![networkKey.oldKey isEqualToString:@"00000000000000000000000000000000"]) {
        networkID = networkKey.oldNetworkId;
        netKey = [LibTools nsstringToHex:networkKey.oldKey];
        identityKey = networkKey.oldKeys.identityKey;
        if (networkID == nil || netKey == nil || identityKey == nil) {
            return NO;
        }
        mData = [NSMutableData dataWithData:networkID];
        [mData appendData:random];
        encryptedData = [OpenSSLHelper.share calculateEvalueWithData:mData andKey:identityKey];
        if ([[encryptedData subdataWithRange:NSMakeRange(8, encryptedData.length-8)] isEqualToData:hash]) {
            isExist = YES;
        }
    }
    if (isExist) {
        SigEncryptedModel *tem = [[SigEncryptedModel alloc] init];
        tem.advertisementDataServiceData = advertisementDataServiceData;
        tem.hashData = hash;
        tem.randomData = random;
        tem.peripheralUUID = peripheralUUIDString;
        tem.encryptedData = encryptedData;
        [self.encryptedArray addObject:tem];
        return YES;
    }
    return NO;
}

- (BOOL)matchPrivateNodeIdentityWithAdvertisementDataServiceData:(NSData *)advertisementDataServiceData peripheralUUIDString:(NSString *)peripheralUUIDString nodes:(NSArray <SigNodeModel *>*)nodes networkKey:(SigNetkeyModel *)networkKey {
    NSData *hash = [advertisementDataServiceData subdataWithRange:NSMakeRange(1, 8)];
    NSData *random = [advertisementDataServiceData subdataWithRange:NSMakeRange(9, 8)];
    NSArray *curNodes = [NSArray arrayWithArray:nodes];
    for (SigNodeModel *node in curNodes) {
        // Data are: 40 bits of Padding (0s), 8bits is 0x03, 64 bits Random and 16 bits Unicast Address.
        Byte byte[6];
        memset(byte, 0, 6);
        byte[5] = SigIdentificationType_privateNodeIdentity;
        NSData *data = [NSData dataWithBytes:byte length:6];
        NSMutableData *mData = [NSMutableData dataWithData:data];
        [mData appendData:random];
        // 把大端模式的数字Number转为本机数据存放模式
        UInt16 address = CFSwapInt16BigToHost(node.address);;
        data = [NSData dataWithBytes:&address length:2];
        [mData appendData:data];
//        NSLog(@"mdata=%@",mData);
        NSData *encryptedData = [OpenSSLHelper.share calculateEvalueWithData:mData andKey:networkKey.keys.identityKey];
        BOOL isExist = NO;
        if ([[encryptedData subdataWithRange:NSMakeRange(8, encryptedData.length-8)] isEqualToData:hash]) {
            isExist = YES;
        }
        // If the Key refresh procedure is in place, the identity might have been generated with the old key.
        if (!isExist && networkKey.oldKey && networkKey.oldKey.length > 0 && ![networkKey.oldKey isEqualToString:@"00000000000000000000000000000000"]) {
            encryptedData = [OpenSSLHelper.share calculateEvalueWithData:mData andKey:networkKey.oldKeys.identityKey];
            if ([[encryptedData subdataWithRange:NSMakeRange(8, encryptedData.length-8)] isEqualToData:hash]) {
                isExist = YES;
            }
        }
        if (isExist) {
            NSMutableData *mData = [NSMutableData dataWithData:hash];
            [mData appendData:random];
            SigEncryptedModel *tem = [[SigEncryptedModel alloc] init];
            tem.advertisementDataServiceData = advertisementDataServiceData;
            tem.hashData = hash;
            tem.randomData = random;
            tem.peripheralUUID = peripheralUUIDString;
            tem.encryptedData = encryptedData;
            tem.address = node.address;
            [self deleteSigEncryptedModelWithAddress:node.address];
            [self.encryptedArray addObject:tem];
            return YES;
        }
    }
    return NO;
}

- (void)updateScanRspModelToDataSource:(SigScanRspModel *)model{
    @synchronized(self) {
        if (model.uuid) {
            if ([self.scanList containsObject:model]) {
                NSInteger index = [self.scanList indexOfObject:model];
                SigScanRspModel *oldModel = [self.scanList objectAtIndex:index];
                if (![oldModel.macAddress isEqualToString:model.macAddress]) {
                    if (!model.macAddress || model.macAddress.length != 12) {
                        model.macAddress = oldModel.macAddress;
                    }
                }
                if (oldModel.address != model.address && model.address == 0) {
                    model.address = oldModel.address;
                }
//                if (model.provisioned) {
//                    if (oldModel.networkIDData && oldModel.networkIDData.length == 8 && (model.networkIDData == nil || model.networkIDData.length != 8)) {
//                        model.networkIDData = oldModel.networkIDData;
//                    }
//                    if (oldModel.nodeIdentityData && oldModel.nodeIdentityData.length == 16 && (model.nodeIdentityData == nil || model.nodeIdentityData.length != 16)) {
//                        model.nodeIdentityData = oldModel.nodeIdentityData;
//                    }
//                }
//                if (![oldModel.macAddress isEqualToString:model.macAddress] || oldModel.address != model.address || ![oldModel.networkIDData isEqualToData:model.networkIDData] || ![oldModel.nodeIdentityData isEqualToData:model.nodeIdentityData]) {
                if (![oldModel.macAddress isEqualToString:model.macAddress] || oldModel.address != model.address || ![oldModel.advertisementDataServiceData isEqualToData:model.advertisementDataServiceData]) {
                    [self.scanList replaceObjectAtIndex:index withObject:model];
                    [self saveScanList];
                }
            } else {
                [self.scanList addObject:model];
                [self saveScanList];
            }
        }
    }
}

- (SigScanRspModel *)getScanRspModelWithUUID:(NSString *)uuid{
    NSArray *scanList = [NSArray arrayWithArray:_scanList];
    for (SigScanRspModel *model in scanList) {
        if ([model.uuid isEqualToString:uuid]) {
            return model;
        }
    }
    return nil;
}

- (SigScanRspModel *)getScanRspModelWithMac:(NSString *)mac{
    NSArray *scanList = [NSArray arrayWithArray:_scanList];
    for (SigScanRspModel *model in scanList) {
        if ([model.macAddress isEqualToString:mac]) {
            return model;
        }
    }
    return nil;
}

- (SigScanRspModel *)getScanRspModelWithAddress:(UInt16)address{
    NSArray *scanList = [NSArray arrayWithArray:_scanList];
    for (SigScanRspModel *model in scanList) {
        if (model.address == address) {
            return model;
        }
    }
    return nil;
}

- (void)deleteScanRspModelWithAddress:(UInt16)address{
    @synchronized(self) {
        NSArray *scanList = [NSArray arrayWithArray:_scanList];
        for (SigScanRspModel *model in scanList) {
            if (model.address == address) {
                [_scanList removeObject:model];
                break;
            }
        }
        [self saveScanList];
    }
}

- (SigNetkeyModel *)getNetkeyModelWithNetworkId:(NSData *)networkId {
    SigNetkeyModel *tem = nil;
    NSArray *netKeys = [NSArray arrayWithArray:_netKeys];
    for (SigNetkeyModel *model in netKeys) {
        if (model.networkId && [model.networkId isEqualToData:networkId]) {
            tem = model;
            break;
        }else if (model.oldNetworkId && [model.oldNetworkId isEqualToData:networkId]) {
            tem = model;
            break;
        }
    }
    return tem;
}

- (SigNetkeyModel *)getNetkeyModelWithNetkeyIndex:(NSInteger)index {
    SigNetkeyModel *tem = nil;
    NSArray *netKeys = [NSArray arrayWithArray:_netKeys];
    for (SigNetkeyModel *model in netKeys) {
        if (model.index == index) {
            tem = model;
            break;
        }
    }
    return tem;
}

- (SigAppkeyModel *)getAppkeyModelWithAppkeyIndex:(NSInteger)appkeyIndex {
    SigAppkeyModel *model = nil;
    NSArray *appKeys = [NSArray arrayWithArray:_appKeys];
    for (SigAppkeyModel *tem in appKeys) {
        if (tem.index == appkeyIndex) {
            model = tem;
            break;
        }
    }
    return model;
}

- (SigNodeModel *)getNodeWithUUID:(NSString *)uuid{
    NSArray *nodes = [NSArray arrayWithArray:_nodes];
    for (SigNodeModel *model in nodes) {
        if ([model.peripheralUUID isEqualToString:uuid]) {
            return model;
        }
    }
    return nil;
}

- (SigNodeModel *)getNodeWithAddress:(UInt16)address{
    NSArray *nodes = [NSArray arrayWithArray:_nodes];
    for (SigNodeModel *model in nodes) {
        if (model.elements.count > 1) {
            if (model.address <= address && model.address + model.elements.count - 1 >= address) {
                return model;
            }
        } else {
            if (model.address == address) {
                return model;
            }
        }
    }
    return nil;
}

- (SigNodeModel *)getDeviceWithMacAddress:(NSString *)macAddress{
    NSArray *nodes = [NSArray arrayWithArray:_nodes];
    for (SigNodeModel *model in nodes) {
        //peripheralUUID || location node's uuid
        if (macAddress && model.macAddress && [model.macAddress.uppercaseString isEqualToString:macAddress.uppercaseString]) {
            return model;
        }
    }
    return nil;
}

- (SigNodeModel *)getCurrentConnectedNode{
    SigNodeModel *node = [self getNodeWithAddress:self.unicastAddressOfConnected];
    return node;
}

- (ModelIDModel *)getModelIDModel:(NSNumber *)modelID{
    ModelIDs *modelIDs = [[ModelIDs alloc] init];
    NSArray *all = [NSArray arrayWithArray:modelIDs.modelIDs];
    for (ModelIDModel *model in all) {
        if (model.sigModelID == [modelID intValue]) {
            return model;
        }
    }
    return nil;
}

- (SigGroupModel *)getGroupModelWithGroupAddress:(UInt16)groupAddress {
    SigGroupModel *tem = nil;
    NSArray *groups = [NSArray arrayWithArray:_groups];
    for (SigGroupModel *model in groups) {
        if (model.intAddress == groupAddress) {
            tem = model;
            break;
        }
    }
    return tem;
}

- (DeviceTypeModel *)getNodeInfoWithCID:(UInt16)CID PID:(UInt16)PID {
    DeviceTypeModel *model = nil;
    NSArray *defaultNodeInfos = [NSArray arrayWithArray:_defaultNodeInfos];
    for (DeviceTypeModel *tem in defaultNodeInfos) {
        if (tem.CID == CID && tem.PID == PID) {
            model = tem;
            break;
        }
    }
    return model;
}

#pragma mark - OOB存取相关

- (void)addAndUpdateSigOOBModel:(SigOOBModel *)oobModel {
    if ([self.OOBList containsObject:oobModel]) {
        NSInteger index = [self.OOBList indexOfObject:oobModel];
        [self.OOBList replaceObjectAtIndex:index withObject:oobModel];
    } else {
        [self.OOBList addObject:oobModel];
    }
    [self saveCurrentOobList];
}

- (void)addAndUpdateSigOOBModelList:(NSArray <SigOOBModel *>*)oobModelList {
    for (SigOOBModel *oobModel in oobModelList) {
        if ([self.OOBList containsObject:oobModel]) {
            NSInteger index = [self.OOBList indexOfObject:oobModel];
            [self.OOBList replaceObjectAtIndex:index withObject:oobModel];
        } else {
            [self.OOBList addObject:oobModel];
        }
    }
    [self saveCurrentOobList];
}

- (void)deleteSigOOBModel:(SigOOBModel *)oobModel {
    if ([self.OOBList containsObject:oobModel]) {
        [self.OOBList removeObject:oobModel];
        [self saveCurrentOobList];
    }
}

- (void)deleteAllSigOOBModel {
    [self.OOBList removeAllObjects];
    [self saveCurrentOobList];
}

- (SigOOBModel *)getSigOOBModelWithUUID:(NSString *)UUIDString {
    SigOOBModel *tem = nil;
    NSArray *OOBList = [NSArray arrayWithArray:self.OOBList];
    for (SigOOBModel *oobModel in OOBList) {
        if ([oobModel.UUIDString isEqualToString:UUIDString]) {
            tem = oobModel;
            break;
        }
    }
    return tem;
}

- (void)saveCurrentOobList {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.OOBList];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kOOBStoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - new api since v3.3.3
- (UInt16)getMaxUsedUnicastAddressOfJson {
    UInt16 maxUsedUnicastAddress = 0;
    for (SigNodeModel *node in self.nodes) {
        UInt16 usedUnicastAddress = node.address + node.elements.count - 1;
        if (maxUsedUnicastAddress < usedUnicastAddress) {
            maxUsedUnicastAddress = usedUnicastAddress;
            TeLogInfo(@"update maxUsedUnicastAddress to 0x%X",maxUsedUnicastAddress);
        }
    }
    return maxUsedUnicastAddress;
}

- (UInt16)getMaxUsedUnicastAddressOfJsonWithProvisioner:(SigProvisionerModel *)provisioner {
    UInt16 maxUsedUnicastAddress = 0;
    for (SigNodeModel *node in self.nodes) {
        BOOL belongToProvisioner = NO;
        for (SigRangeModel *unicastRange in provisioner.allocatedUnicastRange) {
            if (node.address >= unicastRange.lowIntAddress && node.address <= unicastRange.hightIntAddress) {
                belongToProvisioner = YES;
                TeLogInfo(@"Provisioner.UUID:%@ Range:%@~%@ Used Unicast Address:0x%X",provisioner.UUID,unicastRange.lowAddress,unicastRange.highAddress,node.address);
                break;
            }
        }
        if (belongToProvisioner) {
            UInt16 usedUnicastAddress = node.address + node.elements.count - 1;
            if (maxUsedUnicastAddress < usedUnicastAddress) {
                maxUsedUnicastAddress = usedUnicastAddress;
                TeLogInfo(@"update maxUsedUnicastAddress to 0x%X",maxUsedUnicastAddress);
            }
        }
    }
    return maxUsedUnicastAddress;
}

- (UInt16)getMaxUsedUnicastAddressOfJsonWithUnicastRange:(SigRangeModel *)unicastRange {
    UInt16 maxUsedUnicastAddress = 0;
    for (SigNodeModel *node in self.nodes) {
        if (node.address >= unicastRange.lowIntAddress && node.address <= unicastRange.hightIntAddress) {
            TeLogInfo(@"Range:%@~%@ Used Unicast Address:0x%X",unicastRange.lowAddress,unicastRange.highAddress,node.address);
            UInt16 usedUnicastAddress = node.address + node.elements.count - 1;
            if (maxUsedUnicastAddress < usedUnicastAddress) {
                maxUsedUnicastAddress = usedUnicastAddress;
                TeLogInfo(@"update maxUsedUnicastAddress to 0x%X",maxUsedUnicastAddress);
            }
        }
    }
    return maxUsedUnicastAddress;
}

/// 修正下一次添加设备使用的短地址到当前provisioner的地址范围，剩余地址个数小于10时给当前provisioner再申请一个地址区间
- (void)fixUnicastAddressOfAddDeviceOnAllocatedUnicastRange {
    UInt16 maxUsedUnicastAddressOfJson = [self getMaxUsedUnicastAddressOfJsonWithProvisioner:self.curProvisionerModel];
    UInt16 maxUsedUnicastAddressOfLocation = maxUsedUnicastAddressOfJson;
    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentMeshProvisionAddress_key];
    if (dict) {
        NSString *key = [self getKeyOfMaxUsedUnicastAddressOfLocationWithMeshUUID:self.meshUUID provisionerUUID:self.getCurrentProvisionerUUID];
        if ([dict.allKeys containsObject:key]) {
            maxUsedUnicastAddressOfLocation = [dict[key] intValue];
        }
    }
    UInt16 maxUsedUnicastAddress = MAX(maxUsedUnicastAddressOfJson, maxUsedUnicastAddressOfLocation);
    [self saveLocationProvisionAddress:maxUsedUnicastAddress];
    UInt16 maxRangeHightAddress = 0;
    for (SigRangeModel *unicastRange in self.curProvisionerModel.allocatedUnicastRange) {
        if (maxRangeHightAddress < unicastRange.hightIntAddress) {
            maxRangeHightAddress = unicastRange.hightIntAddress;
        }
    }
    if (maxUsedUnicastAddress >= (maxRangeHightAddress - 10)) {
        //剩余地址个数小于10时给当前provisioner再申请一个地址区间
        [self addNewUnicastRangeToCurrentProvisioner];
    }
}

/// 地址范围是1~0x7FFF,其它值为地址耗尽，分配地址失败。返回用于添加设备的地址，如果APP未实现代理方法`onUpdateAllocatedUnicastRange:ofProvisioner:`则本Provisioner地址耗尽时会超界分配地址，如果APP实现了代理方法`onUpdateAllocatedUnicastRange:ofProvisioner:`则本Provisioner地址耗尽时会重新分配地址区间并通过该代理方法回调给APP，如果所有地址区间都已经分配完成则会超界分配地址且不新增区间也不回调区间更新方法。
- (UInt16)getNextUnicastAddressOfProvision {
    if (!self.curProvisionerModel) {
        TeLogInfo(@"warning: Abnormal situation, there is not provisioner.");
        return kLocationAddress;
    } else {
        UInt16 maxUsedUnicastAddressOfLocation = 0;
        UInt16 maxUsedUnicastAddressOfJson = 0;
        UInt16 maxUsedUnicastAddress = 0;
        NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentMeshProvisionAddress_key];
        if (dict) {
            NSString *key = [self getKeyOfMaxUsedUnicastAddressOfLocationWithMeshUUID:self.meshUUID provisionerUUID:self.getCurrentProvisionerUUID];
            if ([dict.allKeys containsObject:key]) {
                maxUsedUnicastAddressOfLocation = [dict[key] intValue];
            }
        }
        if (maxUsedUnicastAddressOfLocation >= [self getMaxUsedUnicastAddressOfJsonWithProvisioner:self.curProvisionerModel]) {
            //地址用尽，超界或者重新多分配一个区间
            if ([self.delegate respondsToSelector:@selector(onUpdateAllocatedUnicastRange:ofProvisioner:)]) {
                //v3.3.3及之后版本做法：重新多分配一个区间
                BOOL result = [self addNewUnicastRangeToCurrentProvisioner];
                if (result == NO) {
                    //地址分配完成，不得已只能超界分配地址
                    maxUsedUnicastAddress = [self getMaxUsedUnicastAddressOfJson];
                } else {
                    return [self getNextUnicastAddressOfProvision];
                }
            } else {
                //v3.3.2及之前版本做法：超界分配地址
                maxUsedUnicastAddress = [self getMaxUsedUnicastAddressOfJson];
            }
        } else {
            //地址未用尽
            maxUsedUnicastAddressOfJson = [self getMaxUsedUnicastAddressOfJsonWithProvisioner:self.curProvisionerModel];
            maxUsedUnicastAddress = MAX(maxUsedUnicastAddressOfJson, maxUsedUnicastAddressOfLocation);
        }
        
        //如果刚好耗尽的是hightIntAddress，需要从下一个unicastRange取lowIntAddress。
        BOOL nextRangeReturn = NO;
        for (SigRangeModel *unicastRange in self.curProvisionerModel.allocatedUnicastRange) {
            if (nextRangeReturn) {
                return unicastRange.lowIntAddress;
            }
            if (maxUsedUnicastAddress == unicastRange.hightIntAddress) {
                nextRangeReturn = YES;
            }
        }
        return maxUsedUnicastAddress + 1;
    }
}

/// 地址范围是1~0x7FFF,其它值为地址耗尽，分配地址失败。返回经过设备端返回的参数ElementCount进行修正后的添加设备地址。如区间1~0xFF已经使用到了0xFE，只剩下一个地址0xFF未使用，则当前provisioner添加的下一个设备的地址为0xFF，如果当前需要添加的设备的elementCount大于1，则需要重新修正添加的地址。
- (UInt16)getNextUnicastAddressOfProvisionWithElementCount:(UInt8)elementCount {
    if (!self.curProvisionerModel) {
        TeLogInfo(@"warning: Abnormal situation, there is not provisioner.");
        return kLocationAddress;
    } else {
        UInt16 maxUsedUnicastAddress = [self getNextUnicastAddressOfProvision];
        BOOL existRange = NO;
        for (SigRangeModel *unicastRange in self.curProvisionerModel.allocatedUnicastRange) {
            if (existRange == NO) {
                if (unicastRange.lowIntAddress <= maxUsedUnicastAddress && unicastRange.hightIntAddress >= maxUsedUnicastAddress) {
                    existRange = YES;
                    if (maxUsedUnicastAddress + elementCount - 1 <= unicastRange.hightIntAddress) {
                        //该地址合法，剩余地址区间满足elementCount使用。
                        return maxUsedUnicastAddress;
                    } else {
                        //该地址不合法，剩余地址区间不满足elementCount使用。到一下区间分配地址，如果没有下一区间，则分配失败返回0。
                        if ([self.curProvisionerModel.allocatedUnicastRange indexOfObject:unicastRange] < (self.curProvisionerModel.allocatedUnicastRange.count - 1)) {
                            //存在下一区间
                            continue;
                        } else {
                            //不存在下一区间
                            BOOL result = [self addNewUnicastRangeToCurrentProvisioner];
                            if (result) {
                                return [self getNextUnicastAddressOfProvisionWithElementCount:elementCount];
                            } else {
                                return 0;
                            }
                        }
                    }
                }
            } else {
                //已经找到maxUsedUnicastAddress的区间，但剩余区间不足。需要另外寻找区间和地址。
                if (unicastRange.lowIntAddress >= maxUsedUnicastAddress && unicastRange.hightIntAddress >= (maxUsedUnicastAddress + elementCount - 1)) {
                    //在剩余区间找到合法地址且elementcount足够
                    return unicastRange.lowIntAddress;
                }
            }
        }
        //在剩余区间未找到合法地址或者elementcount长度不足。
        return 0;
    }
}

- (BOOL)addNewUnicastRangeToCurrentProvisioner {
    UInt16 maxAddress = [self getMaxHighAddressUnicast];
    if (maxAddress >= 0x7FFF) {
        //所有地址都已经分配完毕
        TeLogError(@"警告！所有地址区间都已经分配完毕！");
        return NO;
    } else {
        SigRangeModel *rangeModel = [[SigRangeModel alloc] initWithMaxHighAddressUnicast:maxAddress];
        if (self.curProvisionerModel.allocatedUnicastRange) {
            TeLogInfo(@"Provisioner.UUID:%@ add Range:%@~%@",self.curProvisionerModel.UUID,rangeModel.lowAddress,rangeModel.highAddress);
            [self.curProvisionerModel.allocatedUnicastRange addObject:rangeModel];
            //if add some thing to json, how does app update json to cloud.
            if ([self.delegate respondsToSelector:@selector(onUpdateAllocatedUnicastRange:ofProvisioner:)]) {
                [self.delegate onUpdateAllocatedUnicastRange:rangeModel ofProvisioner:self.curProvisionerModel];
            }
        }
        return YES;
    }
}

- (NSString *)getKeyOfMaxUsedUnicastAddressOfLocationWithMeshUUID:(NSString *)meshUUID provisionerUUID:(NSString *)provisionerUUID {
    return [NSString stringWithFormat:@"%@-%@",meshUUID,provisionerUUID];
}

/// 初始化一个mesh网络的数据。默认所有参数随机生成。不会清除SigDataSource.share里面的数据（包括scanList、sequenceNumber、sequenceNumberOnDelegate）。
- (instancetype)initDefaultMesh {
    if (self = [super init]) {
        [self initData];
        [self initMeshData];
    }
    return self;
}

/// 清除SigDataSource.share里面的所有参数（包括scanList、sequenceNumber、sequenceNumberOnDelegate），并随机生成新的默认参数。
- (void)resetMesh {
    [self initMeshData];
    [self saveLocationProvisionAddress:1];//重置已经使用的address为1.
    [self cleanScanList];
    [self.scanList removeAllObjects];
    _sequenceNumberOnDelegate = 0;
    [self setLocationSno:0];
    [self saveLocationData];
}

- (void)updateNodeModelVidWithAddress:(UInt16)address vid:(UInt16)vid {
    SigNodeModel *node = [self getNodeWithAddress:address];
    if (node) {
        if ([LibTools uint16From16String:node.vid] != vid) {
            node.vid = [NSString stringWithFormat:@"%04X",vid];
            [self saveLocationData];
        }
    }
}

@end
