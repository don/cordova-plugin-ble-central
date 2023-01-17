/********************************************************************************************************
 * @file     SigConfigMessage.m
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

#import "SigConfigMessage.h"
#import "CBUUID+Hex.h"

@implementation SigConfigMessage

- (Class)responseType {
    return nil;
}

- (UInt32)responseOpCode {
    return 0;
}

- (NSData *)encodeLimit:(int)limit indexes:(NSArray <NSNumber *>*)indexes {
    if (limit == 0 || indexes == nil || indexes.count == 0) {
        return [NSData data];
    }
    if (limit == 1 || indexes.count == 1) {
        // Encode a sigle Key Index into 2 bytes.
        NSNumber *indexNumber = indexes.firstObject;
        UInt16 index = indexNumber.intValue;
        UInt16 tem = CFSwapInt16HostToLittle(index);
        NSData *temData = [NSData dataWithBytes:&tem length:2];
        return temData;
    }else{
        // Encode a pair of Key Indexes into 3 bytes.
        NSNumber *firstIndexNumber = indexes.firstObject;
        NSNumber *secondIndexNumber = indexes[1];
        UInt32 index1 = firstIndexNumber.intValue;
        UInt32 index2 = secondIndexNumber.intValue;
        UInt32 pair = index1 << 12 | index2;
        NSData *temData = [NSData dataWithBytes:&pair length:4];
        NSMutableData *mData = [NSMutableData dataWithData:[temData subdataWithRange:NSMakeRange(0, temData.length-1)]];
        if (indexes.count > 2) {
            temData = [self encodeLimit:limit-2 indexes:[indexes subarrayWithRange:NSMakeRange(2, indexes.count-2)]];
        } else {
            temData = [self encodeLimit:limit-2 indexes:[NSArray array]];
        }
        [mData appendData:temData];
        return mData;
    }
}

- (NSData *)encodeIndexes:(NSArray <NSNumber *>*)indexes {
    return [self encodeLimit:10000 indexes:indexes];
}

+ (NSArray <NSNumber *>*)decodeLimit:(int)limit indexesFromData:(NSData *)data atOffset:(int)offset {
    NSInteger size = data.length - offset;
    if (limit == 0 || size < 2) {
//        TeLogDebug(@"limit is 0, or data.length is short.");
        return [NSArray array];
    }
    if (limit == 1 || size == 2) {
        // Decode a sigle Key Index from 2 bytes.
        UInt16 index = 0;
        Byte *dataByte = (Byte *)data.bytes;
        memcpy(&index, dataByte+offset, 2);
        return [NSArray arrayWithObject:@(index)];
    } else {
        // Decode a pair of Key Indexes from 3 bytes.
        UInt16 first = 0,second=0;
        UInt8 tem1=0,tem2=0,tem3=0;
        Byte *dataByte = (Byte *)data.bytes;
        memcpy(&tem1, dataByte+offset, 1);
        memcpy(&tem2, dataByte+offset+1, 1);
        memcpy(&tem3, dataByte+offset+2, 1);
        first = tem3 << 4 | tem2 >> 4;
        second = (tem2 & 0x0F) << 8 | tem1;
        NSMutableArray *rArray = [NSMutableArray arrayWithArray:@[@(first),@(second)]];
        [rArray addObjectsFromArray:[self decodeLimit:limit-2 indexesFromData:data atOffset:offset+3]];
        return rArray;
    }
}

+ (NSArray <NSNumber *>*)decodeIndexesFromData:(NSData *)data atOffset:(int)offset {
    return [self decodeLimit:10000 indexesFromData:data atOffset:offset];
}

//- (BOOL)isSegmented {
//    return YES;
//}

@end


@implementation SigConfigStatusMessage
- (BOOL)isSuccess {
    return _status == SigConfigMessageStatus_success;
}
- (NSString *)message {
    UInt8 tem = 0;
    tem = (UInt8)_status;
    switch (tem) {
        case SigConfigMessageStatus_success:
            return @"Success";
            break;
        case SigConfigMessageStatus_invalidAddress:
            return @"Invalid Address";
            break;
        case SigConfigMessageStatus_invalidModel:
            return @"Invalid Model";
            break;
        case SigConfigMessageStatus_invalidAppKeyIndex:
            return @"Invalid Application Key Index";
            break;
        case SigConfigMessageStatus_invalidNetKeyIndex:
            return @"Invalid Network Key Index";
            break;
        case SigConfigMessageStatus_insufficientResources:
            return @"Insufficient resources";
            break;
        case SigConfigMessageStatus_keyIndexAlreadyStored:
            return @"Key Index already stored";
            break;
        case SigConfigMessageStatus_invalidPublishParameters:
            return @"Invalid publish parameters";
            break;
        case SigConfigMessageStatus_notASubscribeModel:
            return @"Not a Subscribe Model";
            break;
        case SigConfigMessageStatus_storageFailure:
            return @"Storage failure";
            break;
        case SigConfigMessageStatus_featureNotSupported:
            return @"Feature not supported";
            break;
        case SigConfigMessageStatus_cannotUpdate:
            return @"Cannot update";
            break;
        case SigConfigMessageStatus_cannotRemove:
            return @"Cannot remove";
            break;
        case SigConfigMessageStatus_cannotBind:
            return @"Cannot bind";
            break;
        case SigConfigMessageStatus_temporarilyUnableToChangeState:
            return @"Temporarily unable to change state";
            break;
        case SigConfigMessageStatus_cannotSet:
            return @"Cannot set";
            break;
        case SigConfigMessageStatus_unspecifiedError:
            return @"Unspecified error";
            break;
        case SigConfigMessageStatus_invalidBinding:
            return @"Invalid binding";
            break;
        default:
            return @"unknown status";
            break;
    }
}
@end


@implementation SigAcknowledgedConfigMessage
@end


@implementation SigConfigNetKeyMessage

- (NSData *)encodeNetKeyIndex {
    return [self encodeIndexes:@[@(_networkKeyIndex)]];
}

+ (UInt16)decodeNetKeyIndexFromData:(NSData *)data atOffset:(int)offset {
    return (UInt16)[self decodeLimit:1 indexesFromData:data atOffset:offset].firstObject.integerValue;
}

@end


@implementation SigConfigAppKeyMessage
@end


@implementation SigConfigNetAndAppKeyMessage

- (instancetype)initWithNetworkKeyIndex:(UInt16)networkKeyIndex applicationKeyIndex:(UInt16)applicationKeyIndex {
    if (self = [super init]) {
        _networkKeyIndex = networkKeyIndex;
        _applicationKeyIndex = applicationKeyIndex;
    }
    return self;
}

- (NSData *)encodeNetAndAppKeyIndex {
    return [self encodeIndexes:@[@(_applicationKeyIndex),@(_networkKeyIndex)]];
}

+ (SigConfigNetAndAppKeyMessage *)decodeNetAndAppKeyIndexFromData:(NSData *)data atOffset:(int)offset {
    NSArray *array = [self decodeIndexesFromData:data atOffset:offset];
    if (array && array.count >= 2) {
        UInt16 tem1 = (UInt16)[array[0] integerValue];
        UInt16 tem2 = (UInt16)[array[1] integerValue];
        SigConfigNetAndAppKeyMessage *msg = [[SigConfigNetAndAppKeyMessage alloc] initWithNetworkKeyIndex:tem2 applicationKeyIndex:tem1];
        return msg;
    }else{
        return nil;
    }
}

@end


@implementation SigConfigElementMessage
@end


@implementation SigConfigModelMessage

- (UInt32)modelId {
    return (UInt32)_modelIdentifier;
}

@end


@implementation SigConfigAnyModelMessage

/// Returns `true` for Models with identifiers assigned by Bluetooth SIG,
/// `false` otherwise.
- (BOOL)isBluetoothSIGAssigned {
    return _companyIdentifier == 0;
}

- (UInt32)modelId {
    if (_companyIdentifier != 0) {
        return ((UInt32)_companyIdentifier << 16) | (UInt32)self.modelIdentifier;
    } else {
        return (UInt32)self.modelIdentifier;
    }
}

@end


@implementation SigConfigVendorModelMessage

- (UInt32)modelId {
    return ((UInt32)_companyIdentifier << 16) | (UInt32)self.modelIdentifier;
}

@end


@implementation SigConfigAddressMessage
@end


@implementation SigConfigVirtualLabelMessage
@end


@implementation SigConfigModelAppList
@end


@implementation SigConfigModelSubscriptionList
@end


@implementation SigCompositionDataPage
@end

@implementation SigPage0

- (NSData *)parameters {
    UInt8 tem = self.page;
    NSMutableData *mData = [NSMutableData dataWithBytes:&tem length:1];
    UInt16 tem2 = self.companyIdentifier;
    [mData appendData:[NSData dataWithBytes:&tem2 length:2]];
    tem2 = self.productIdentifier;
    [mData appendData:[NSData dataWithBytes:&tem2 length:2]];
    tem2 = self.versionIdentifier;
    [mData appendData:[NSData dataWithBytes:&tem2 length:2]];
    tem2 = self.minimumNumberOfReplayProtectionList;
    [mData appendData:[NSData dataWithBytes:&tem2 length:2]];
    tem2 = self.features.rawValue;
    [mData appendData:[NSData dataWithBytes:&tem2 length:2]];
    NSArray *elements = [NSArray arrayWithArray:self.elements];
    for (SigElementModel *elementModel in elements) {
        [mData appendData:elementModel.getElementData];
    }
    return mData;
}

- (BOOL)isSegmented {
    return YES;
}

- (instancetype)initWithNode:(SigNodeModel *)node {
    if (self = [super init]) {
        self.page = 0;
        _companyIdentifier = [LibTools uint16From16String:node.cid];
        _productIdentifier = [LibTools uint16From16String:node.pid];
        _versionIdentifier = [LibTools uint16From16String:node.vid];
        _minimumNumberOfReplayProtectionList = [LibTools uint16From16String:node.crpl];
        if (node.features) {
            _features = node.features;
        } else {
            _features = [[SigNodeFeatures alloc] init];
        }
        _elements = [NSMutableArray arrayWithArray:node.elements];
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (parameters && parameters.length > 0) {
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        self.page = tem;
        if (parameters.length < 11) {
//            if (parameters.length < 11 || tem != 0) {
            return nil;
        }
    }
    if (self = [super init]) {
        UInt16 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte+1, 2);
        _companyIdentifier = tem;
        memcpy(&tem, dataByte+3, 2);
        _productIdentifier = tem;
        memcpy(&tem, dataByte+5, 2);
        _versionIdentifier = tem;
        memcpy(&tem, dataByte+7, 2);
        _minimumNumberOfReplayProtectionList = tem;
        memcpy(&tem, dataByte+9, 2);
        _features = [[SigNodeFeatures alloc] initWithRawValue:tem];
        
        NSMutableArray *readElements = [NSMutableArray array];
        int offset = 11;
        while (offset < parameters.length) {
            SigElementModel *element = [[SigElementModel alloc] initWithCompositionData:parameters offset:&offset];
            element.index = (UInt8)readElements.count;
            [readElements addObject:element];
        }
        _elements = readElements;
    }
    return self;
}
@end

#pragma mark - detail message

@implementation SigConfigAppKeyAdd

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyAdd;
    }
    return self;
}

- (instancetype)initWithApplicationKey:(SigAppkeyModel *)applicationKey {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyAdd;
        self.applicationKeyIndex = applicationKey.index;
        self.networkKeyIndex = applicationKey.boundNetKey;
        _key = [LibTools nsstringToHex:applicationKey.key];
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyAdd;
        if (parameters == nil || parameters.length != 19) {
            return nil;
        }
        SigConfigNetAndAppKeyMessage *message = [SigConfigAppKeyAdd decodeNetAndAppKeyIndexFromData:parameters atOffset:0];
        self.networkKeyIndex = message.networkKeyIndex;
        self.applicationKeyIndex = message.applicationKeyIndex;
        _key = [parameters subdataWithRange:NSMakeRange(3, 16)];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData dataWithData:[self encodeNetAndAppKeyIndex]];
    [mData appendData:_key];
    return mData;
}

- (Class)responseType {
    return [SigConfigAppKeyStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigAppKeyUpdate

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyUpdate;
    }
    return self;
}

- (instancetype)initWithApplicationKey:(SigAppkeyModel *)applicationKey {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyUpdate;
        self.applicationKeyIndex = applicationKey.index;
        self.networkKeyIndex = applicationKey.boundNetKey;
        _key = [LibTools nsstringToHex:applicationKey.key];
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyUpdate;
        if (parameters == nil || parameters.length != 19) {
            return nil;
        }
        SigConfigNetAndAppKeyMessage *message = [SigConfigAppKeyAdd decodeNetAndAppKeyIndexFromData:parameters atOffset:0];
        self.networkKeyIndex = message.networkKeyIndex;
        self.applicationKeyIndex = message.applicationKeyIndex;
        _key = [parameters subdataWithRange:NSMakeRange(3, 16)];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData dataWithData:[self encodeNetAndAppKeyIndex]];
    [mData appendData:_key];
    return mData;
}

- (Class)responseType {
    return [SigConfigAppKeyStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigCompositionDataStatus
- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configCompositionDataStatus;
    }
    return self;
}

- (instancetype)initWithReportPage:(SigCompositionDataPage *)page {
    if (self = [super init]) {
        self.opCode = SigOpCode_configCompositionDataStatus;
        _page = page;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configCompositionDataStatus;
        if (parameters == nil || parameters.length == 0) {
            return nil;
        } else {
            UInt8 tem = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem, dataByte, 1);
            if (tem != 0) {
                TeLogError(@"Other Pages are not supoprted.");
            }
//            if (tem == 0) {
                SigPage0 *page0 = [[SigPage0 alloc] initWithParameters:parameters];//001102010033306900070000001101000002000300040000FE01FE00FF01FF001002100410061007100013011303130413110200000000020002100613
                if (page0) {
                    _page = page0;
                } else {
                    TeLogError(@"init page0 fail.");
                    return nil;
                }
//            } else {
//                TeLogError(@"Other Pages are not supoprted.");
//                return nil;
//            }
        }
    }
    return self;
}

- (NSData *)parameters {
    return _page.parameters;
}

@end


@implementation SigConfigModelPublicationSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationSet;
    }
    return self;
}

- (instancetype)initWithPublish:(SigPublish *)publish toElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationSet;
        if ([SigHelper.share isVirtualAddress:[LibTools uint16From16String:publish.address]]) {
            // ConfigModelPublicationVirtualAddressSet should be used instead.
            return nil;
        }
        _publish = publish;
        self.elementAddress = elementAddress;
        self.modelIdentifier = modelIdentifier;
        self.companyIdentifier = companyIdentifier;
    }
    return self;
}

- (instancetype)initWithPublish:(SigPublish *)publish toElementAddress:(UInt16)elementAddress model:(SigModelIDModel *)model {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationSet;
        if ([SigHelper.share isVirtualAddress:[LibTools uint16From16String:publish.address]]) {
            // ConfigModelPublicationVirtualAddressSet should be used instead.
            return nil;
        }
        _publish = publish;
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithDisablePublicationForModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationSet;
        _publish = [[SigPublish alloc] init];
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationSet;
        if (parameters == nil || (parameters.length != 11 && parameters.length != 13)) {
            return nil;
        }
        UInt16 tem1=0,tem2=0,tem3=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        memcpy(&tem2, dataByte+2, 2);
        memcpy(&tem3, dataByte+4, 2);
        self.elementAddress = tem1;
//        UInt16 address = tem2;
        UInt16 index = tem3 & 0x0FFF;
        UInt8 tem = 0;
        memcpy(&tem, dataByte+5, 1);
        int flag = (int)((tem & 0x10) >> 4);
        memcpy(&tem, dataByte+6, 1);
        UInt8 ttl = tem;
        memcpy(&tem, dataByte+7, 1);
        UInt8 periodSteps = tem & 0x3F;
        SigStepResolution periodResolution = tem >> 6;
        memcpy(&tem, dataByte+8, 1);
        UInt8 count = tem & 0x07;
        UInt8 interval = tem >> 3;
        SigRetransmit *retransmit = [[SigRetransmit alloc] initWithPublishRetransmitCount:count intervalSteps:interval];
        self.publish = [[SigPublish alloc] initWithDestination:tem2 withKeyIndex:index friendshipCredentialsFlag:flag ttl:ttl periodSteps:periodSteps periodResolution:periodResolution retransmit:retransmit];
        if (parameters.length == 13) {
            memcpy(&tem3, dataByte+11, 2);
            self.modelIdentifier = tem3;
            memcpy(&tem3, dataByte+9, 2);
            self.companyIdentifier = tem3;
        }else{
            memcpy(&tem3, dataByte+9, 2);
            self.modelIdentifier = tem3;
            self.companyIdentifier = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = [LibTools uint16From16String:_publish.address];
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    UInt8 tem8 = 0;
    tem8 = _publish.index & 0xFF;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = (UInt8)(_publish.index >> 8) | (UInt8)(_publish.credentials << 4);
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _publish.ttl;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = (_publish.periodSteps & 0x3F) | (_publish.periodResolution << 6);
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = (_publish.retransmit.count & 0x07) | (_publish.retransmit.steps << 3);
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (self.companyIdentifier) {
        tem = self.companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    } else {
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    return mData;
}

- (Class)responseType {
    return [SigConfigModelPublicationStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigAppKeyDelete

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyDelete;
    }
    return self;
}

- (instancetype)initWithApplicationKey:(SigAppkeyModel *)applicationKey {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyDelete;
        self.applicationKeyIndex = applicationKey.index;
        self.networkKeyIndex = applicationKey.boundNetKey;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyDelete;
        if (parameters == nil || parameters.length != 3) {
            return nil;
        }
        SigConfigNetAndAppKeyMessage *message = [SigConfigAppKeyAdd decodeNetAndAppKeyIndexFromData:parameters atOffset:0];
        self.networkKeyIndex = message.networkKeyIndex;
        self.applicationKeyIndex = message.applicationKeyIndex;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData dataWithData:[self encodeNetAndAppKeyIndex]];
    return mData;
}

- (Class)responseType {
    return [SigConfigAppKeyStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigAppKeyGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyGet;
    }
    return self;
}

- (instancetype)initWithNetworkKeyIndex:(UInt16)networkKeyIndex {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyGet;
        self.networkKeyIndex = networkKeyIndex;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyGet;
        if (parameters == nil || parameters.length != 2) {
            return nil;
        }
        self.networkKeyIndex = [SigConfigNetKeyMessage decodeNetKeyIndexFromData:parameters atOffset:0];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData dataWithData:[self encodeNetKeyIndex]];
    return mData;
}

- (Class)responseType {
    return [SigConfigAppKeyList class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigAppKeyList

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyList;
    }
    return self;
}

- (instancetype)initWithNetWorkKey:(SigNetkeyModel *)networkKey applicationKeys:(NSArray <SigAppkeyModel *>*)applicationKeys status:(SigConfigMessageStatus)status {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyList;
        self.networkKeyIndex = networkKey.index;
        _applicationKeyIndexes = [NSMutableArray array];
        for (SigAppkeyModel *model in applicationKeys) {
            [_applicationKeyIndexes addObject:@(model.index)];
        }
        _status = status;
    }
    return self;
}

- (instancetype)initWithStatus:(SigConfigMessageStatus)status forMessage:(SigConfigAppKeyGet *)message {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyList;
        self.networkKeyIndex = message.networkKeyIndex;
        _applicationKeyIndexes = [NSMutableArray array];
        _status = status;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyList;
        if (parameters == nil || parameters.length < 3) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _status = tem;
        self.networkKeyIndex = [SigConfigNetKeyMessage decodeNetKeyIndexFromData:parameters atOffset:1];
        self.applicationKeyIndexes = [NSMutableArray arrayWithArray:[SigConfigNetKeyMessage decodeIndexesFromData:parameters atOffset:3]];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    data = [self encodeNetKeyIndex];
    [mData appendData:data];
    data = [self encodeIndexes:_applicationKeyIndexes];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigConfigAppKeyStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyStatus;
    }
    return self;
}

- (instancetype)initWithApplicationKey:(SigAppkeyModel *)applicationKey {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyStatus;
        self.applicationKeyIndex = applicationKey.index;
        self.networkKeyIndex = applicationKey.boundNetKey;
        _status = SigConfigMessageStatus_success;
    }
    return self;
}

- (instancetype)initWithStatus:(SigConfigMessageStatus)status forMessage:(SigConfigNetAndAppKeyMessage *)message {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyStatus;
        self.applicationKeyIndex = message.applicationKeyIndex;
        self.networkKeyIndex = message.networkKeyIndex;
        _status = status;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configAppKeyStatus;
        if (parameters == nil || parameters.length != 4) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _status = tem;
        SigConfigNetAndAppKeyMessage *message = [SigConfigAppKeyAdd decodeNetAndAppKeyIndexFromData:parameters atOffset:1];
        self.networkKeyIndex = message.networkKeyIndex;
        self.applicationKeyIndex = message.applicationKeyIndex;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    data = [self encodeNetAndAppKeyIndex];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigConfigCompositionDataGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configCompositionDataGet;
        _page = 0;
    }
    return self;
}

- (instancetype)initWithPage:(UInt8)page {
    if (self = [super init]) {
        self.opCode = SigOpCode_configCompositionDataGet;
        _page = page;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configCompositionDataGet;
        _page = 0;
        if (parameters.length == 1) {
            UInt8 tem = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem, dataByte, 1);
            _page = tem;
        } else {
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    UInt8 tem = _page;
    NSData *temData = [NSData dataWithBytes:&tem length:1];
    return temData;
}

- (Class)responseType {
    return [SigConfigCompositionDataStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}


@end


@implementation SigConfigBeaconGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configBeaconGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configBeaconGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigConfigBeaconStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigBeaconSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configBeaconSet;
    }
    return self;
}

- (instancetype)initWithEnable:(BOOL)enable {
    if (self = [super init]) {
        self.opCode = SigOpCode_configBeaconSet;
        _state = enable;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configBeaconSet;
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        if (tem > 1) {
            return nil;
        }
        _state = tem == 0x01;
    }
    return self;
}

- (NSData *)parameters {
    UInt8 tem = [self state]?0x01:0x00;
    return [NSData dataWithBytes:&tem length:1];
}

- (Class)responseType {
    return [SigConfigBeaconStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigBeaconStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configBeaconStatus;
    }
    return self;
}

- (instancetype)initWithEnable:(BOOL)enable {
    if (self = [super init]) {
        self.opCode = SigOpCode_configBeaconStatus;
        _isEnabled = enable;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configBeaconStatus;
        if (parameters == nil || parameters.length == 0) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        if (tem > 1) {
            return nil;
        }
        _isEnabled = tem == 0x01;
    }
    return self;
}

- (NSData *)parameters {
    UInt8 tem = [self isEnabled]?0x01:0x00;
    return [NSData dataWithBytes:&tem length:1];
}

@end


@implementation SigConfigDefaultTtlGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configDefaultTtlGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configDefaultTtlGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigConfigDefaultTtlStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigDefaultTtlSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configDefaultTtlSet;
    }
    return self;
}

- (instancetype)initWithTtl:(UInt8)ttl {
    if (self = [super init]) {
        self.opCode = SigOpCode_configDefaultTtlSet;
        _ttl = ttl;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configDefaultTtlSet;
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _ttl = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem = _ttl;
    NSData *temData = [NSData dataWithBytes:&tem length:1];
    [mData appendData:temData];
    return mData;
}

- (Class)responseType {
    return [SigConfigDefaultTtlStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigDefaultTtlStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configDefaultTtlStatus;
    }
    return self;
}

- (instancetype)initWithTtl:(UInt8)ttl {
    if (self = [super init]) {
        self.opCode = SigOpCode_configDefaultTtlStatus;
        _ttl = ttl;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configDefaultTtlStatus;
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _ttl = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem = _ttl;
    NSData *temData = [NSData dataWithBytes:&tem length:1];
    [mData appendData:temData];
    return mData;
}

@end


@implementation SigConfigFriendGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configFriendGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configFriendGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigConfigFriendStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigFriendSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configFriendSet;
    }
    return self;
}

- (instancetype)initWithEnable:(BOOL)enable {
    if (self = [super init]) {
        self.opCode = SigOpCode_configFriendSet;
        self.state = enable ? SigNodeFeaturesState_enabled : SigNodeFeaturesState_notEnabled;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configFriendSet;
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _state = tem;
    }
    return self;
}

- (NSData *)parameters {
    UInt8 tem = _state;
    return [NSData dataWithBytes:&tem length:1];
}

- (Class)responseType {
    return [SigConfigFriendStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigFriendStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configFriendStatus;
    }
    return self;
}

- (instancetype)initWithState:(SigNodeFeaturesState)state {
    if (self = [super init]) {
        self.opCode = SigOpCode_configFriendStatus;
        self.state = state;
    }
    return self;
}

- (instancetype)initWithNode:(SigNodeModel *)node {
    if (self = [super init]) {
        self.opCode = SigOpCode_configFriendStatus;
        self.state = node.features.proxyFeature <= 2 ? node.features.proxyFeature : SigNodeFeaturesState_notSupported;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configFriendStatus;
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _state = tem;
    }
    return self;
}

- (NSData *)parameters {
    UInt8 tem = _state;
    return [NSData dataWithBytes:&tem length:1];
}

@end


@implementation SigConfigGATTProxyGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configGATTProxyGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configGATTProxyGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigConfigGATTProxyStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigGATTProxySet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configGATTProxySet;
    }
    return self;
}

- (instancetype)initWithEnable:(BOOL)enable {
    if (self = [super init]) {
        self.opCode = SigOpCode_configGATTProxySet;
        self.state = enable ? SigNodeFeaturesState_enabled : SigNodeFeaturesState_notEnabled;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configGATTProxySet;
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _state = tem;
    }
    return self;
}

- (NSData *)parameters {
    UInt8 tem = _state;
    return [NSData dataWithBytes:&tem length:1];
}

- (Class)responseType {
    return [SigConfigGATTProxyStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigGATTProxyStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configGATTProxyStatus;
    }
    return self;
}

- (instancetype)initWithState:(SigNodeFeaturesState)state {
    if (self = [super init]) {
        self.opCode = SigOpCode_configGATTProxyStatus;
        self.state = state;
    }
    return self;
}

- (instancetype)initWithNode:(SigNodeModel *)node {
    if (self = [super init]) {
        self.opCode = SigOpCode_configGATTProxyStatus;
        self.state = node.features.proxyFeature <= 2 ? node.features.proxyFeature : SigNodeFeaturesState_notSupported;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configGATTProxyStatus;
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _state = tem;
    }
    return self;
}

- (NSData *)parameters {
    UInt8 tem = _state;
    return [NSData dataWithBytes:&tem length:1];
}

@end


@implementation SigConfigKeyRefreshPhaseGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configKeyRefreshPhaseGet;
    }
    return self;
}

- (instancetype)initWithNetKeyIndex:(UInt16)netKeyIndex {
    if (self = [super init]) {
        self.opCode = SigOpCode_configKeyRefreshPhaseGet;
        _netKeyIndex = netKeyIndex;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configKeyRefreshPhaseGet;
        if (parameters == nil || parameters.length != 2) {
            return nil;
        }
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _netKeyIndex = (tem16 >> 4) & 0xFFF;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _netKeyIndex << 4;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigConfigKeyRefreshPhaseStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigKeyRefreshPhaseSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configKeyRefreshPhaseSet;
    }
    return self;
}

- (instancetype)initWithNetKeyIndex:(UInt16)netKeyIndex transition:(SigControllableKeyRefreshTransitionValues)transition {
    if (self = [super init]) {
        self.opCode = SigOpCode_configKeyRefreshPhaseSet;
        _netKeyIndex = netKeyIndex;
        _transition = transition;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configKeyRefreshPhaseSet;
        if (parameters == nil || parameters.length != 3) {
            return nil;
        }
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _netKeyIndex = (tem16 >> 4) & 0xFFF;
        UInt8 tem8 = 0;
        memcpy(&tem8, dataByte+2, 1);
        _transition = tem8;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _netKeyIndex << 4;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = _transition;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigConfigKeyRefreshPhaseStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigKeyRefreshPhaseStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configKeyRefreshPhaseStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configKeyRefreshPhaseStatus;
        if (parameters == nil || parameters.length != 4) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _status = tem;
        UInt16 tem16 = 0;
        memcpy(&tem16, dataByte+1, 2);
        _netKeyIndex = (tem16 >> 4) & 0xFFF;
        memcpy(&tem, dataByte+3, 1);
        _phase = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _netKeyIndex << 4;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem8 = _phase;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigConfigModelPublicationGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationGet;
    }
    return self;
}

- (instancetype)initWithElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationGet;
        self.elementAddress = elementAddress;
        self.modelIdentifier = modelIdentifier;
        self.companyIdentifier = companyIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationGet;
        if (parameters == nil || (parameters.length != 4 && parameters.length != 6)) {
            return nil;
        }
        UInt16 tem1=0,tem2=0,tem3=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        memcpy(&tem2, dataByte+2, 2);
        self.elementAddress = tem1;
        if (parameters.length == 6) {
            memcpy(&tem3, dataByte+4, 2);
            self.modelIdentifier = tem3;
            self.companyIdentifier = tem2;
        }else{
            self.modelIdentifier = tem2;
            self.companyIdentifier = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    if (self.companyIdentifier) {
        tem = self.companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    tem = self.modelIdentifier;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigConfigModelPublicationStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigModelPublicationStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationStatus;
    }
    return self;
}

- (instancetype)initResponseToSigConfigAnyModelMessage:(SigConfigAnyModelMessage *)request {
    return [self initResponseToSigConfigAnyModelMessage:request withPublish:[[SigPublish class] init]];
}

- (instancetype)initResponseToSigConfigAnyModelMessage:(SigConfigAnyModelMessage *)request withPublish:(SigPublish *)publish {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationStatus;
        _publish = publish;
        self.elementAddress = request.elementAddress;
        self.modelIdentifier = request.modelIdentifier;
        self.companyIdentifier = request.companyIdentifier;
        _status = SigConfigMessageStatus_success;
    }
    return self;
}

- (instancetype)initResponseToSigConfigAnyModelMessage:(SigConfigAnyModelMessage *)request withStatus:(SigConfigMessageStatus)status {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationStatus;
        _publish = [[SigPublish class] init];
        self.elementAddress = request.elementAddress;
        self.modelIdentifier = request.modelIdentifier;
        self.companyIdentifier = request.companyIdentifier;
        _status = status;
    }
    return self;
}

- (instancetype)initWithConfirmSigConfigModelPublicationSet:(SigConfigModelPublicationSet *)request {
    return [self initResponseToSigConfigAnyModelMessage:request withPublish:request.publish];
}

- (instancetype)initWithConfirmSigConfigModelPublicationVirtualAddressSet:(SigConfigModelPublicationVirtualAddressSet *)request {
    return [self initResponseToSigConfigAnyModelMessage:request withPublish:request.publish];
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationStatus;
        if (parameters == nil || (parameters.length != 12 && parameters.length != 14)) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _status = tem;
        
        UInt16 tem1=0,tem2=0,tem3=0;
        memcpy(&tem1, dataByte+1, 2);
        memcpy(&tem2, dataByte+3, 2);
        memcpy(&tem3, dataByte+5, 2);
        self.elementAddress = tem1;
        UInt16 address = tem2;
        UInt16 index = tem3 & 0x0FFF;
        memcpy(&tem, dataByte+6, 1);
        int flag = (int)((tem & 0x10) >> 4);
        memcpy(&tem, dataByte+7, 1);
        UInt8 ttl = tem;
        memcpy(&tem, dataByte+8, 1);
        UInt8 periodSteps = tem & 0x3F;
        SigStepResolution periodResolution = tem >> 6;
        memcpy(&tem, dataByte+9, 1);
        UInt8 count = tem & 0x07;
        UInt8 interval = tem >> 3;
        SigRetransmit *retransmit = [[SigRetransmit alloc] initWithPublishRetransmitCount:count intervalSteps:interval];
        self.publish = [[SigPublish alloc] initWithDestination:address withKeyIndex:index friendshipCredentialsFlag:flag ttl:ttl periodSteps:periodSteps periodResolution:periodResolution retransmit:retransmit];
        
        if (parameters.length == 14) {
            memcpy(&tem3, dataByte+12, 2);
            self.modelIdentifier = tem3;
            memcpy(&tem3, dataByte+10, 2);
            self.companyIdentifier = tem3;
        }else{
            memcpy(&tem3, dataByte+10, 2);
            self.modelIdentifier = tem3;
            self.companyIdentifier = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem = self.elementAddress;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = [LibTools uint16From16String:_publish.address];
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem8 = _publish.index & 0xFF;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = (UInt8)(_publish.index >> 8) | (UInt8)(_publish.credentials << 4);
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _publish.ttl;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = (_publish.periodSteps & 0x3F) | (_publish.periodResolution >> 6);
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = (_publish.retransmit.count & 0x07) | (_publish.retransmit.steps << 3);
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (self.companyIdentifier) {
        tem = self.companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    } else {
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigConfigModelPublicationVirtualAddressSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationVirtualAddressSet;
    }
    return self;
}

- (instancetype)initWithPublish:(SigPublish *)publish toElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationVirtualAddressSet;
        if ([SigHelper.share isVirtualAddress:[LibTools uint16From16String:_publish.address]]) {
            // ConfigModelPublicationVirtualAddressSet should be used instead.
            return nil;
        }
        _publish = publish;
        self.elementAddress = elementAddress;
        self.modelIdentifier = modelIdentifier;
        self.companyIdentifier = companyIdentifier;
    }
    return self;
}

- (instancetype)initWithPublish:(SigPublish *)publish toElementAddress:(UInt16)elementAddress model:(SigModelIDModel *)model {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationVirtualAddressSet;
        if ([SigHelper.share isVirtualAddress:[LibTools uint16From16String:_publish.address]]) {
            // ConfigModelPublicationVirtualAddressSet should be used instead.
            return nil;
        }
        _publish = publish;
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelPublicationVirtualAddressSet;
        if (parameters == nil || (parameters.length != 25 && parameters.length != 27)) {
            return nil;
        }
        UInt16 tem1=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        self.elementAddress = tem1;
        NSString *label = [LibTools convertDataToHexStr:[parameters subdataWithRange:NSMakeRange(2, 16)]];
        memcpy(&tem1, dataByte+18, 2);
        UInt16 index = tem1 & 0x0FFF;
        UInt8 tem = 0;
        memcpy(&tem, dataByte+19, 1);
        int flag = (int)((tem & 0x10) >> 4);
        memcpy(&tem, dataByte+20, 1);
        UInt8 ttl = tem;
        memcpy(&tem, dataByte+21, 1);
        UInt8 periodSteps = tem & 0x3F;
        SigStepResolution periodResolution = tem >> 6;
        memcpy(&tem, dataByte+22, 1);
        UInt8 count = tem & 0x07;
        UInt8 interval = tem >> 3;
        SigRetransmit *retransmit = [[SigRetransmit alloc] initWithPublishRetransmitCount:count intervalSteps:interval];
        self.publish = [[SigPublish alloc] initWithStringDestination:label withKeyIndex:index friendshipCredentialsFlag:flag ttl:ttl periodSteps:periodSteps periodResolution:periodResolution retransmit:retransmit];

        
        if (parameters.length == 27) {
            memcpy(&tem1, dataByte+25, 2);
            self.modelIdentifier = tem1;
            memcpy(&tem1, dataByte+23, 2);
            self.companyIdentifier = tem1;
        }else{
            memcpy(&tem1, dataByte+23, 2);
            self.modelIdentifier = tem1;
            self.companyIdentifier = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = 0;
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    [mData appendData:_publish.publicationAddress.virtualLabel.getData];
    tem8 = _publish.index & 0xFF;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = (UInt8)(_publish.index >> 8) | (UInt8)(_publish.credentials << 4);
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _publish.ttl;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = (_publish.periodSteps & 0x3F) | (_publish.periodResolution << 6);
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = (_publish.retransmit.count & 0x07) | (_publish.retransmit.steps << 3);
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (self.companyIdentifier) {
        tem = self.companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    } else {
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    return mData;
}

- (Class)responseType {
    return [SigConfigModelPublicationStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigModelSubscriptionAdd

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionAdd;
    }
    return self;
}

- (instancetype)initWithGroupAddress:(UInt16)groupAddress toElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionAdd;
        if (![SigHelper.share isGroupAddress:groupAddress]) {
            // ConfigModelSubscriptionVirtualAddressAdd should be used instead.
            return nil;
        }
        _address = groupAddress;
        self.elementAddress = elementAddress;
        self.modelIdentifier = modelIdentifier;
        self.companyIdentifier = companyIdentifier;
    }
    return self;
}

- (instancetype)initWithGroup:(SigGroupModel *)group toElementAddress:(UInt16)elementAddress model:(SigModelIDModel *)model {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionAdd;
        if (![SigHelper.share isGroupAddress:group.intAddress]) {
            // ConfigModelSubscriptionVirtualAddressAdd should be used instead.
            return nil;
        }
        _address = [LibTools uint16From16String:group.address];
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionAdd;
        if (parameters == nil || (parameters.length != 6 && parameters.length != 8)) {
            return nil;
        }
        UInt16 tem1=0,tem2=0,tem3=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        memcpy(&tem2, dataByte+2, 2);
        self.elementAddress = tem1;
        _address = tem2;
        if (parameters.length == 8) {
            memcpy(&tem3, dataByte+4, 2);
            self.companyIdentifier = tem3;
            memcpy(&tem3, dataByte+6, 2);
            self.modelIdentifier = tem3;
        } else {
            memcpy(&tem3, dataByte+4, 2);
            self.modelIdentifier = tem3;
            self.companyIdentifier = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = _address;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    if (self.companyIdentifier) {
        tem = self.companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    } else {
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    return mData;
}

- (Class)responseType {
    return [SigConfigModelSubscriptionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigModelSubscriptionDelete

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionDelete;
    }
    return self;
}

- (instancetype)initWithGroupAddress:(UInt16)groupAddress elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionDelete;
        if (![SigHelper.share isGroupAddress:groupAddress]) {
            // ConfigModelSubscriptionVirtualAddressAdd should be used instead.
            return nil;
        }
        _address = groupAddress;
        self.elementAddress = elementAddress;
        self.modelIdentifier = modelIdentifier;
        self.companyIdentifier = companyIdentifier;
    }
    return self;
}

- (instancetype)initWithGroup:(SigGroupModel *)group fromModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionDelete;
        if (![SigHelper.share isGroupAddress:group.intAddress]) {
            // ConfigModelSubscriptionVirtualAddressAdd should be used instead.
            return nil;
        }
        _address = [LibTools uint16From16String:group.address];
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionDelete;
        if (parameters == nil || (parameters.length != 6 && parameters.length != 8)) {
            return nil;
        }
        UInt16 tem1=0,tem2=0,tem3=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        memcpy(&tem2, dataByte+2, 2);
        self.elementAddress = tem1;
        _address = tem2;
        if (parameters.length == 8) {
            memcpy(&tem3, dataByte+4, 2);
            self.companyIdentifier = tem3;
            memcpy(&tem3, dataByte+6, 2);
            self.modelIdentifier = tem3;
        } else {
            memcpy(&tem3, dataByte+4, 2);
            self.modelIdentifier = tem3;
            self.companyIdentifier = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = _address;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    if (self.companyIdentifier) {
        tem = self.companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    } else {
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    return mData;
}

- (Class)responseType {
    return [SigConfigModelSubscriptionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigModelSubscriptionDeleteAll

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionDeleteAll;
    }
    return self;
}

- (instancetype)initWithElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionDeleteAll;
        self.elementAddress = elementAddress;
        self.modelIdentifier = modelIdentifier;
        self.companyIdentifier = companyIdentifier;
    }
    return self;
}

- (instancetype)initFromModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionDeleteAll;
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionDeleteAll;
        if (parameters == nil || (parameters.length != 4 && parameters.length != 6)) {
            return nil;
        }
        UInt16 tem1=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        self.elementAddress = tem1;
        if (parameters.length == 6) {
            memcpy(&tem1, dataByte+2, 2);
            self.companyIdentifier = tem1;
            memcpy(&tem1, dataByte+4, 2);
            self.modelIdentifier = tem1;
        } else {
            memcpy(&tem1, dataByte+2, 2);
            self.modelIdentifier = tem1;
            self.companyIdentifier = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    if (self.companyIdentifier) {
        tem = self.companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    } else {
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    return mData;
}

- (Class)responseType {
    return [SigConfigModelSubscriptionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigModelSubscriptionOverwrite

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionOverwrite;
    }
    return self;
}

- (instancetype)initWithGroupAddress:(UInt16)groupAddress elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionOverwrite;
        if (![SigHelper.share isGroupAddress:groupAddress]) {
            // ConfigModelSubscriptionVirtualAddressAdd should be used instead.
            return nil;
        }
        _address = groupAddress;
        self.elementAddress = elementAddress;
        self.modelIdentifier = modelIdentifier;
        self.companyIdentifier = companyIdentifier;
    }
    return self;
}

- (instancetype)initWithGroup:(SigGroupModel *)group toModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionOverwrite;
        if (![SigHelper.share isGroupAddress:group.intAddress]) {
            // ConfigModelSubscriptionVirtualAddressAdd should be used instead.
            return nil;
        }
        _address = [LibTools uint16From16String:group.address];
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionOverwrite;
        if (parameters == nil || (parameters.length != 6 && parameters.length != 8)) {
            return nil;
        }
        UInt16 tem1=0,tem2=0,tem3=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        memcpy(&tem2, dataByte+2, 2);
        self.elementAddress = tem1;
        _address = tem2;
        if (parameters.length == 8) {
            memcpy(&tem3, dataByte+4, 2);
            self.companyIdentifier = tem3;
            memcpy(&tem3, dataByte+6, 2);
            self.modelIdentifier = tem3;
        } else {
            memcpy(&tem3, dataByte+4, 2);
            self.modelIdentifier = tem3;
            self.companyIdentifier = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = _address;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    if (self.companyIdentifier) {
        tem = self.companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    } else {
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    return mData;
}

- (Class)responseType {
    return [SigConfigModelSubscriptionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigModelSubscriptionStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionStatus;
    }
    return self;
}

- (instancetype)initResponseToSigConfigModelPublicationStatus:(SigConfigModelPublicationStatus *)request withStatus:(SigConfigMessageStatus *)status {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionStatus;
        //SigConfigModelSubscriptionAdd|SigConfigModelSubscriptionDelete|SigConfigModelSubscriptionOverwrite|SigConfigModelSubscriptionStatus
        if ([request isMemberOfClass:[SigConfigModelSubscriptionAdd class]]) {
            _address = ((SigConfigModelSubscriptionAdd *)request).address;
        }else if ([request isMemberOfClass:[SigConfigModelSubscriptionDelete class]]) {
            _address = ((SigConfigModelSubscriptionDelete *)request).address;
        }else if ([request isMemberOfClass:[SigConfigModelSubscriptionOverwrite class]]) {
            _address = ((SigConfigModelSubscriptionOverwrite *)request).address;
        }else if ([request isMemberOfClass:[SigConfigModelSubscriptionStatus class]]) {
            _address = ((SigConfigModelSubscriptionStatus *)request).address;
        }else{
            TeLogError(@"Unknown request class.");
            return nil;
        }
        self.elementAddress = request.elementAddress;
        self.modelIdentifier = request.modelIdentifier;
        self.companyIdentifier = request.companyIdentifier;
        _status = request.status;
        }
    return self;
}

- (instancetype)initResponseToSigConfigAnyModelMessage:(SigConfigAnyModelMessage *)request withStatus:(SigConfigMessageStatus)status {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionStatus;
        //SigConfigModelSubscriptionVirtualAddressAdd|SigConfigModelSubscriptionVirtualAddressDelete|SigConfigModelSubscriptionVirtualAddressOverwrite
        if ([request isMemberOfClass:[SigConfigModelSubscriptionVirtualAddressAdd class]]) {
            _address = [[SigMeshAddress alloc] initWithVirtualLabel:((SigConfigModelSubscriptionVirtualAddressAdd *)request).virtualLabel].address;
        }else if ([request isMemberOfClass:[SigConfigModelSubscriptionVirtualAddressDelete class]]) {
            _address = [[SigMeshAddress alloc] initWithVirtualLabel:((SigConfigModelSubscriptionVirtualAddressDelete *)request).virtualLabel].address;
        }else if ([request isMemberOfClass:[SigConfigModelSubscriptionVirtualAddressDelete class]]) {
            _address = [[SigMeshAddress alloc] initWithVirtualLabel:((SigConfigModelSubscriptionVirtualAddressDelete *)request).virtualLabel].address;
        }else{
            TeLogError(@"Unknown request class.");
            return nil;
        }
        self.elementAddress = request.elementAddress;
        self.modelIdentifier = request.modelIdentifier;
        self.companyIdentifier = request.companyIdentifier;
        _status = status;
        }
    return self;
}

- (instancetype)initResponseToSigConfigModelSubscriptionDeleteAll:(SigConfigModelSubscriptionDeleteAll *)request withStatus:(SigConfigMessageStatus)status {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionStatus;
        _address = MeshAddress_unassignedAddress;
        self.elementAddress = request.elementAddress;
        self.modelIdentifier = request.modelIdentifier;
        self.companyIdentifier = request.companyIdentifier;
        _status = status;
    }
    return self;
}

- (instancetype)initWithConfirmAddingGroup:(SigGroupModel *)group toModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress withStatus:(SigConfigMessageStatus)status {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionStatus;
        _status = status;
        _address = [LibTools uint16From16String:group.address];
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithConfirmDeletingAddress:(UInt16)address fromModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress withStatus:(SigConfigMessageStatus)status {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionStatus;
        _status = status;
        _address = address;
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithConfirmDeletingAllFromModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionStatus;
        _status = SigConfigMessageStatus_success;
        _address = MeshAddress_unassignedAddress;
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionStatus;
        if (parameters == nil || (parameters.length != 7 && parameters.length != 9)) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _status = tem;
        
        UInt16 tem1=0,tem2=0;
        memcpy(&tem1, dataByte+1, 2);
        memcpy(&tem2, dataByte+3, 2);
        self.elementAddress = tem1;
        _address = tem2;
        if (parameters.length == 9) {
            memcpy(&tem1, dataByte+5, 2);
            self.companyIdentifier = tem1;
            memcpy(&tem1, dataByte+7, 2);
            self.modelIdentifier = tem1;
        } else {
            self.companyIdentifier = 0;
            memcpy(&tem1, dataByte+5, 2);
            self.modelIdentifier = tem1;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 temState = _status;
    NSData *data = [NSData dataWithBytes:&temState length:1];
    [mData appendData:data];
    UInt16 tem = self.elementAddress;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = _address;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    if (self.companyIdentifier) {
        tem = self.companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    } else {
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigConfigModelSubscriptionVirtualAddressAdd

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionVirtualAddressAdd;
    }
    return self;
}

- (instancetype)initWithVirtualLabel:(CBUUID *)virtualLabel elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionVirtualAddressAdd;
        if (!virtualLabel) {
            // ConfigModelSubscriptionAdd should be used instead.
            return nil;
        }
        _virtualLabel = virtualLabel;
        self.elementAddress = elementAddress;
        self.modelIdentifier = modelIdentifier;
        self.companyIdentifier = companyIdentifier;
    }
    return self;
}

- (instancetype)initWithGroup:(SigGroupModel *)group toModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionVirtualAddressAdd;
        if (!group.meshAddress.virtualLabel) {
            // ConfigModelSubscriptionAdd should be used instead.
            return nil;
        }
        _virtualLabel = group.meshAddress.virtualLabel;
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionVirtualAddressAdd;
        if (parameters == nil || (parameters.length != 20 && parameters.length != 24)) {
            return nil;
        }
        UInt16 tem1=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        self.elementAddress = tem1;
        _virtualLabel = [CBUUID UUIDWithData:[parameters subdataWithRange:NSMakeRange(2, 16)]];
        if (parameters.length == 24) {
            memcpy(&tem1, dataByte+18, 2);
            self.companyIdentifier = tem1;
            memcpy(&tem1, dataByte+20, 2);
            self.modelIdentifier = tem1;
        } else {
            memcpy(&tem1, dataByte+18, 2);
            self.modelIdentifier = tem1;
            self.companyIdentifier = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    data = _virtualLabel.data;
    [mData appendData:data];
    if (self.companyIdentifier) {
        tem = self.companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    } else {
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    return mData;
}

- (Class)responseType {
    return [SigConfigModelSubscriptionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigModelSubscriptionVirtualAddressDelete

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionVirtualAddressDelete;
    }
    return self;
}

- (instancetype)initWithVirtualLabel:(CBUUID *)virtualLabel elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionVirtualAddressDelete;
        if (!virtualLabel) {
            // ConfigModelSubscriptionAdd should be used instead.
            return nil;
        }
        _virtualLabel = virtualLabel;
        self.elementAddress = elementAddress;
        self.modelIdentifier = modelIdentifier;
        self.companyIdentifier = companyIdentifier;
    }
    return self;
}

- (instancetype)initWithGroup:(SigGroupModel *)group fromModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionVirtualAddressDelete;
        if (!group.meshAddress.virtualLabel) {
            // ConfigModelSubscriptionAdd should be used instead.
            return nil;
        }
        _virtualLabel = group.meshAddress.virtualLabel;
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionVirtualAddressDelete;
        if (parameters == nil || (parameters.length != 20 && parameters.length != 24)) {
            return nil;
        }
        UInt16 tem1=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        self.elementAddress = tem1;
        _virtualLabel = [CBUUID UUIDWithData:[parameters subdataWithRange:NSMakeRange(2, 16)]];
        if (parameters.length == 24) {
            memcpy(&tem1, dataByte+18, 2);
            self.companyIdentifier = tem1;
            memcpy(&tem1, dataByte+20, 2);
            self.modelIdentifier = tem1;
        } else {
            memcpy(&tem1, dataByte+18, 2);
            self.modelIdentifier = tem1;
            self.companyIdentifier = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    data = _virtualLabel.data;
    [mData appendData:data];
    if (self.companyIdentifier) {
        tem = self.companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    } else {
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    return mData;
}

- (Class)responseType {
    return [SigConfigModelSubscriptionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigModelSubscriptionVirtualAddressOverwrite

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionVirtualAddressOverwrite;
    }
    return self;
}

- (instancetype)initWithVirtualLabel:(CBUUID *)virtualLabel elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionVirtualAddressOverwrite;
        if (!virtualLabel) {
            // ConfigModelSubscriptionAdd should be used instead.
            return nil;
        }
        _virtualLabel = virtualLabel;
        self.elementAddress = elementAddress;
        self.modelIdentifier = modelIdentifier;
        self.companyIdentifier = companyIdentifier;
    }
    return self;
}

- (instancetype)initWithGroup:(SigGroupModel *)group fromModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionVirtualAddressOverwrite;
        if (!group.meshAddress.virtualLabel) {
            // ConfigModelSubscriptionAdd should be used instead.
            return nil;
        }
        _virtualLabel = group.meshAddress.virtualLabel;
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelSubscriptionVirtualAddressOverwrite;
        if (parameters == nil || (parameters.length != 20 && parameters.length != 24)) {
            return nil;
        }
        UInt16 tem1=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        self.elementAddress = tem1;
        _virtualLabel = [CBUUID UUIDWithData:[parameters subdataWithRange:NSMakeRange(2, 16)]];
        if (parameters.length == 24) {
            memcpy(&tem1, dataByte+18, 2);
            self.companyIdentifier = tem1;
            memcpy(&tem1, dataByte+20, 2);
            self.modelIdentifier = tem1;
        } else {
            memcpy(&tem1, dataByte+18, 2);
            self.modelIdentifier = tem1;
            self.companyIdentifier = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    data = _virtualLabel.data;
    [mData appendData:data];
    if (self.companyIdentifier) {
        tem = self.companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    } else {
        tem = self.modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    return mData;
}

- (Class)responseType {
    return [SigConfigModelSubscriptionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigNetworkTransmitGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetworkTransmitGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetworkTransmitGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigConfigNetworkTransmitStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigNetworkTransmitSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetworkTransmitSet;
        _count = 0;
        _steps = 0;
    }
    return self;
}

- (instancetype)initWithCount:(UInt8)count steps:(UInt8)steps {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetworkTransmitSet;
        _count = MIN(7, count);
        _steps = MIN(63, steps);
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetworkTransmitSet;
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        
        _count = tem & 0x07;
        _steps = tem >> 3;
    }
    return self;
}

- (NSData *)parameters {
    UInt8 tem = (_count & 0x07) | _steps << 3;
    return [NSData dataWithBytes:&tem length:1];
}

//- (NSTimeInterval)interval {
//    return (NSTimeInterval)(_steps+1)/100;
//}

- (Class)responseType {
    return [SigConfigNetworkTransmitStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigNetworkTransmitStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetworkTransmitStatus;
        _count = 0;
        _steps = 0;
    }
    return self;
}

- (instancetype)initWithCount:(UInt8)count steps:(UInt8)steps {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetworkTransmitSet;
        _count = MIN(7, count);
        _steps = MIN(63, steps);
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetworkTransmitStatus;
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        
        _count = tem & 0x07;
        _steps = tem >> 3;
    }
    return self;
}

- (NSData *)parameters {
    UInt8 tem = (_count & 0x07) | _steps << 3;
    return [NSData dataWithBytes:&tem length:1];
}

- (NSTimeInterval)interval {
    return (NSTimeInterval)(_steps+1)/100;
}

- (instancetype)initWithNode:(SigNodeModel *)node {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetworkTransmitStatus;
        SigNetworktransmitModel *transmit = node.networkTransmit;
        if (!transmit) {
            _count = 0;
            _steps = 0;
        }else{
            _count = transmit.networkTransmitCount;
            _steps = transmit.networkTransmitIntervalSteps;
        }
    }
    return self;
}

@end


@implementation SigConfigRelayGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configRelayGet;
        _page = 0;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configRelayGet;
        _page = 0;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigConfigRelayStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigRelaySet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configRelaySet;
        _state = SigNodeRelayState_notEnabled;
        _count = 0;
        _steps = 0;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configRelaySet;
        if (parameters == nil || parameters.length != 2) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte+1, 1);
        _count = tem & 0x07;
        _steps = tem >> 3;
        memcpy(&tem, dataByte, 1);
        _state = tem;
    }
    return self;
}

- (NSData *)parameters {
    UInt8 tem[2] = {};
    tem[0] = _state;
    tem[1] = (_count & 0x07) | _steps << 3;
    return [NSData dataWithBytes:tem length:2];
}

- (NSTimeInterval)interval {
    return (NSTimeInterval)(_steps+1)/100;
}

- (instancetype)initWithCount:(UInt8)count steps:(UInt8)steps {
    if (self = [super init]) {
        self.opCode = SigOpCode_configRelaySet;
        _state = SigNodeRelayState_enabled;
        _count = MIN(7, count);
        _steps = MIN(63, steps);
    }
    return self;
}

- (Class)responseType {
    return [SigConfigRelayStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigRelayStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configRelayStatus;
        _count = 0;
        _steps = 0;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configRelayStatus;
        if (parameters == nil || parameters.length != 2) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte+1, 1);
        _count = tem & 0x07;
        _steps = tem >> 3;
        memcpy(&tem, dataByte, 1);
        _state = tem;
    }
    return self;
}

- (NSData *)parameters {
    UInt8 tem[2] = {};
    tem[0] = _state;
    tem[1] = (_count & 0x07) | _steps << 3;
    return [NSData dataWithBytes:tem length:2];
}

- (NSTimeInterval)interval {
    return (NSTimeInterval)(_steps+1)/100;
}

- (instancetype)initWithState:(SigNodeFeaturesState)state count:(UInt8)count steps:(UInt8)steps {
    if (self = [super init]) {
        _state = state;
        _count = MIN(7, count);
        _steps = MIN(63, steps);
    }
    return self;
}

@end


@implementation SigConfigSIGModelSubscriptionGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelSubscriptionGet;
    }
    return self;
}

- (instancetype)initWithElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelSubscriptionGet;
        if (companyIdentifier != 0) {
            // Use ConfigVendorModelSubscriptionGet instead.
            return nil;
        }
        self.elementAddress = elementAddress;
        self.modelIdentifier = modelIdentifier;
    }
    return self;
}

- (instancetype)initOfModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelSubscriptionGet;
        if (model.getIntCompanyIdentifier != 0) {
            // Use ConfigVendorModelSubscriptionGet instead.
            return nil;
        }
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelSubscriptionGet;
        if (parameters == nil || parameters.length != 4) {
            return nil;
        }
        UInt16 tem1=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        self.elementAddress = tem1;
        memcpy(&tem1, dataByte+2, 2);
        self.modelIdentifier = tem1;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = self.modelIdentifier;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigConfigSIGModelSubscriptionList class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigSIGModelSubscriptionList

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelSubscriptionList;
    }
    return self;
}

- (instancetype)initForModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress addresses:(NSArray <NSNumber *>*)addresses withStatus:(SigConfigMessageStatus)status {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelSubscriptionList;
        if (model.getIntCompanyIdentifier != 0) {
            // Use ConfigVendorModelSubscriptionList instead.
            return nil;
        }
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.addresses = [NSMutableArray arrayWithArray:addresses];
        self.status = status;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelSubscriptionList;
        if (parameters == nil || parameters.length < 5) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        self.status = tem;
        UInt16 tem1=0;
        memcpy(&tem1, dataByte+1, 2);
        self.elementAddress = tem1;
        memcpy(&tem1, dataByte+3, 2);
        self.modelIdentifier = tem1;
        // Read list of addresses.
        NSMutableArray *array = [NSMutableArray array];
        
        for (int i=5; (i+1)<parameters.length; i += 2) {
            memcpy(&tem1, dataByte+i, 2);
            [array addObject:@(tem1)];
        }
        self.addresses = array;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 temStatus = self.status;
    NSData *statusData = [NSData dataWithBytes:&temStatus length:1];
    [mData appendData:statusData];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = self.modelIdentifier;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    NSArray *addresses = [NSArray arrayWithArray:self.addresses];
    for (NSNumber *addressNumber in addresses) {
        UInt16 address = addressNumber.intValue;
        data = [NSData dataWithBytes:&address length:2];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigConfigVendorModelSubscriptionGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configVendorModelSubscriptionGet;
    }
    return self;
}

- (instancetype)initWithElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configVendorModelSubscriptionGet;
        if (companyIdentifier == 0) {
            // Use ConfigSIGModelSubscriptionGet instead.
            return nil;
        }
        self.elementAddress = elementAddress;
        self.modelIdentifier = modelIdentifier;
        self.companyIdentifier = companyIdentifier;
    }
    return self;
}

- (instancetype)initOfModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configVendorModelSubscriptionGet;
        if (model.getIntCompanyIdentifier == 0) {
            // Use ConfigSIGModelSubscriptionGet instead.
            return nil;
        }
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configVendorModelSubscriptionGet;
        if (parameters == nil || parameters.length != 6) {
            return nil;
        }
        UInt16 tem1=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        self.elementAddress = tem1;
        memcpy(&tem1, dataByte+2, 2);
        self.companyIdentifier = tem1;
        memcpy(&tem1, dataByte+4, 2);
        self.modelIdentifier = tem1;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = self.companyIdentifier;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = self.modelIdentifier;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigConfigVendorModelSubscriptionList class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigVendorModelSubscriptionList

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configVendorModelSubscriptionList;
    }
    return self;
}

- (instancetype)initForModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress addresses:(NSArray <NSNumber *>*)addresses withStatus:(SigConfigMessageStatus)status {
    if (self = [super init]) {
        self.opCode = SigOpCode_configVendorModelSubscriptionList;
        if (model.getIntCompanyIdentifier == 0) {
            // Use ConfigSIGModelSubscriptionList instead.
            return nil;
        }
        self.elementAddress = elementAddress;
        self.modelIdentifier = model.getIntModelIdentifier;
        self.companyIdentifier = model.getIntCompanyIdentifier;
        self.addresses = [NSMutableArray arrayWithArray:addresses];
        self.status = status;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configVendorModelSubscriptionList;
        if (parameters == nil || parameters.length < 7) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        self.status = tem;
        UInt16 tem1=0;
        memcpy(&tem1, dataByte+1, 2);
        self.elementAddress = tem1;
        memcpy(&tem1, dataByte+3, 2);
        self.modelIdentifier = tem1;
        memcpy(&tem1, dataByte+5, 2);
        self.companyIdentifier = tem1;
        // Read list of addresses.
        NSMutableArray *array = [NSMutableArray array];
        
        for (int i=7; (i+1)<parameters.length; i += 2) {
            memcpy(&tem1, dataByte+i, 2);
            [array addObject:@(tem1)];
        }
        self.addresses = array;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 temStatus = self.status;
    NSData *statusData = [NSData dataWithBytes:&temStatus length:1];
    [mData appendData:statusData];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = self.companyIdentifier;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = self.modelIdentifier;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    NSArray *addresses = [NSArray arrayWithArray:self.addresses];
    for (NSNumber *addressNumber in addresses) {
        UInt16 address = addressNumber.intValue;
        data = [NSData dataWithBytes:&address length:2];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigConfigLowPowerNodePollTimeoutGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configLowPowerNodePollTimeoutGet;
    }
    return self;
}

- (instancetype)initWithLPNAddress:(UInt16)LPNAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configKeyRefreshPhaseGet;
        _LPNAddress = LPNAddress;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configKeyRefreshPhaseGet;
        if (parameters == nil || parameters.length != 2) {
            return nil;
        }
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _LPNAddress = tem16;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _LPNAddress;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigConfigLowPowerNodePollTimeoutStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigLowPowerNodePollTimeoutStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configLowPowerNodePollTimeoutStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configLowPowerNodePollTimeoutStatus;
        if (parameters == nil || parameters.length != 5) {
            return nil;
        }
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _LPNAddress = tem16;
        UInt32 tem1 = 0,tem2 = 0,tem3 = 0;
        memcpy(&tem1, dataByte+2, 1);
        memcpy(&tem2, dataByte+3, 1);
        memcpy(&tem3, dataByte+4, 1);
        _pollTimeout = tem1 << 16 | tem2 << 8 | tem3;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _LPNAddress;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt32 tem32 = CFSwapInt32HostToBig(_pollTimeout);
    NSData *temData = [NSData dataWithBytes:&tem32 length:4];
    [mData appendData:[temData subdataWithRange:NSMakeRange(1, 3)]];
    return mData;
}

@end


@implementation SigConfigHeartbeatPublicationGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configHeartbeatPublicationGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configHeartbeatPublicationGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigConfigHeartbeatPublicationStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigHeartbeatPublicationSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configHeartbeatPublicationSet;
    }
    return self;
}

- (instancetype)initWithDestination:(UInt16)destination countLog:(UInt8)countLog periodLog:(UInt8)periodLog ttl:(UInt8)ttl features:(SigFeatures)features netKeyIndex:(UInt16)netKeyIndex {
    if (self = [super init]) {
        self.opCode = SigOpCode_configHeartbeatPublicationSet;
        _destination = destination;
        _countLog = countLog;
        _periodLog = periodLog;
        _ttl = ttl;
        _features = features;
        _netKeyIndex = netKeyIndex;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configHeartbeatPublicationSet;
        if (parameters == nil || parameters.length != 9) {
            return nil;
        }
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _destination = tem16;
        UInt8 tem8 = 0;
        memcpy(&tem8, dataByte+2, 1);
        _countLog = tem8;
        memcpy(&tem8, dataByte+3, 1);
        _periodLog = tem8;
        memcpy(&tem8, dataByte+4, 1);
        _ttl = tem8;
        memcpy(&tem16, dataByte+5, 2);
        _features.value = tem16;
        memcpy(&tem16, dataByte+7, 2);
        _netKeyIndex = (tem16 >> 4) & 0xFFF;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _destination;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = _countLog;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _periodLog;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _ttl;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem16 = _features.value;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _netKeyIndex << 4;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigConfigHeartbeatPublicationStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigHeartbeatPublicationStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configHeartbeatPublicationStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configHeartbeatPublicationStatus;
        if (parameters == nil || parameters.length != 10) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = tem8;
        UInt16 tem16 = 0;
        memcpy(&tem16, dataByte+1, 2);
        _destination = tem16;
        memcpy(&tem8, dataByte+3, 1);
        _countLog = tem8;
        memcpy(&tem8, dataByte+4, 1);
        _periodLog = tem8;
        memcpy(&tem8, dataByte+5, 1);
        _ttl = tem8;
        memcpy(&tem16, dataByte+6, 2);
        _features.value = tem16;
        memcpy(&tem16, dataByte+8, 2);
        _netKeyIndex = (tem16 >> 4) & 0xFFF;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _destination;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem8 = _countLog;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _periodLog;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _ttl;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem16 = _features.value;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _netKeyIndex << 4;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigConfigHeartbeatSubscriptionGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configHeartbeatSubscriptionGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configHeartbeatSubscriptionGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigConfigHeartbeatSubscriptionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigHeartbeatSubscriptionSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configHeartbeatSubscriptionSet;
    }
    return self;
}

- (instancetype)initWithSource:(UInt16)source destination:(UInt16)destination periodLog:(UInt8)periodLog {
    if (self = [super init]) {
        self.opCode = SigOpCode_configHeartbeatSubscriptionSet;
        _source = source;
        _destination = destination;
        _periodLog = periodLog;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configHeartbeatSubscriptionSet;
        if (parameters == nil || parameters.length != 5) {
            return nil;
        }
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _source = tem16;
        memcpy(&tem16, dataByte+2, 2);
        _destination = tem16;
        UInt8 tem8 = 0;
        memcpy(&tem8, dataByte+4, 1);
        _periodLog = tem8;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _source;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _destination;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = _periodLog;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigConfigHeartbeatSubscriptionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigHeartbeatSubscriptionStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configHeartbeatSubscriptionStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configHeartbeatSubscriptionStatus;
        if (parameters == nil || parameters.length != 9) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = tem8;
        UInt16 tem16 = 0;
        memcpy(&tem16, dataByte+1, 2);
        _source = tem16;
        memcpy(&tem16, dataByte+3, 2);
        _destination = tem16;
        memcpy(&tem8, dataByte+5, 1);
        _periodLog = tem8;
        memcpy(&tem8, dataByte+6, 1);
        _countLog = tem8;
        memcpy(&tem8, dataByte+7, 1);
        _minHops = tem8;
        memcpy(&tem8, dataByte+8, 1);
        _maxHops = tem8;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _source;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _destination;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem8 = _periodLog;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _countLog;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _minHops;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _maxHops;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigConfigModelAppBind

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelAppBind;
    }
    return self;
}

- (instancetype)initWithApplicationKeyIndex:(UInt16)applicationKeyIndex elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelAppBind;
        self.applicationKeyIndex = applicationKeyIndex;
        _elementAddress = elementAddress;
        _modelIdentifier = modelIdentifier;
        _companyIdentifier = companyIdentifier;
    }
    return self;
}

- (instancetype)initWithApplicationKey:(SigAppkeyModel *)applicationKey toModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelAppBind;
        self.applicationKeyIndex = applicationKey.index;
        _elementAddress = elementAddress;
        _modelIdentifier = model.getIntModelIdentifier;
        _companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelAppBind;
        if (parameters == nil || (parameters.length != 6 && parameters.length != 8)) {
            return nil;
        }
        UInt16 tem1=0,tem2=0,tem3=0,tem4=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        memcpy(&tem2, dataByte+2, 2);
        _elementAddress = tem1;
        self.applicationKeyIndex = tem2;
        if (parameters.length == 8) {
            memcpy(&tem3, dataByte+4, 2);
            memcpy(&tem4, dataByte+6, 2);
            _companyIdentifier = tem3;
            _modelIdentifier = tem4;
        }else{
            memcpy(&tem3, dataByte+4, 2);
            _companyIdentifier = 0;
            _modelIdentifier = tem3;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = _elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = self.applicationKeyIndex;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    if (_companyIdentifier) {
        tem = _companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
        tem = _modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    } else {
        tem = _modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    return mData;
}

- (Class)responseType {
    return [SigConfigModelAppStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

- (BOOL)isSegmented {
    return NO;
}

@end


@implementation SigConfigModelAppStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelAppStatus;
    }
    return self;
}

- (instancetype)initWithConfirmBindingApplicationKey:(SigAppkeyModel *)applicationKey toModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress status:(SigConfigMessageStatus)status {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelAppStatus;
        self.applicationKeyIndex = applicationKey.index;
        _elementAddress = elementAddress;
        _modelIdentifier = model.getIntModelIdentifier;
        _companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithConfirmUnbindingApplicationKey:(SigAppkeyModel *)applicationKey toModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress status:(SigConfigMessageStatus)status {
    return [self initWithConfirmBindingApplicationKey:applicationKey toModel:model elementAddress:elementAddress status:status];
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelAppStatus;
        if (parameters == nil || (parameters.length != 7 && parameters.length != 9)) {
            return nil;
        }
        UInt8 status=0;
        UInt16 tem1=0,tem2=0,tem3=0,tem4=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&status, dataByte, 1);
        memcpy(&tem1, dataByte+1, 2);
        memcpy(&tem2, dataByte+3, 2);
        _status = status;
        _elementAddress = tem1;
        self.applicationKeyIndex = tem2;
        if (parameters.length == 9) {
            memcpy(&tem3, dataByte+5, 2);
            memcpy(&tem4, dataByte+7, 2);
            _companyIdentifier = tem3;
            _modelIdentifier = tem4;
        }else{
            memcpy(&tem3, dataByte+5, 2);
            _companyIdentifier = 0;
            _modelIdentifier = tem3;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem = _elementAddress;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = self.applicationKeyIndex;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    if (_companyIdentifier) {
        tem = _companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
        tem = _modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    } else {
        tem = _modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigConfigModelAppUnbind

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelAppUnbind;
    }
    return self;
}

- (instancetype)initWithApplicationKeyIndex:(UInt16)applicationKeyIndex elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelAppUnbind;
        self.applicationKeyIndex = applicationKeyIndex;
        _elementAddress = elementAddress;
        _modelIdentifier = modelIdentifier;
        _companyIdentifier = companyIdentifier;
    }
    return self;
}

- (instancetype)initWithApplicationKey:(SigAppkeyModel *)applicationKey toModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelAppUnbind;
        self.applicationKeyIndex = applicationKey.index;
        _elementAddress = elementAddress;
        _modelIdentifier = model.getIntModelIdentifier;
        _companyIdentifier = model.getIntCompanyIdentifier;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configModelAppUnbind;
        if (parameters == nil || (parameters.length != 6 && parameters.length != 8)) {
            return nil;
        }
        UInt16 tem1=0,tem2=0,tem3=0,tem4=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        memcpy(&tem2, dataByte+2, 2);
        _elementAddress = tem1;
        self.applicationKeyIndex = tem2;
        if (parameters.length == 8) {
            memcpy(&tem3, dataByte+4, 2);
            memcpy(&tem4, dataByte+6, 2);
            _companyIdentifier = tem3;
            _modelIdentifier = tem4;
        }else{
            memcpy(&tem3, dataByte+4, 2);
            _companyIdentifier = 0;
            _modelIdentifier = tem3;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = _elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = self.applicationKeyIndex;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    if (_companyIdentifier) {
        tem = _companyIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
        tem = _modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    } else {
        tem = _modelIdentifier;
        data = [NSData dataWithBytes:&tem length:2];
        [mData appendData:data];
    }
    return mData;
}

- (Class)responseType {
    return [SigConfigModelAppStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigNetKeyAdd

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyAdd;
    }
    return self;
}

- (instancetype)initWithNetworkKeyIndex:(UInt16)networkKeyIndex networkKeyData:(NSData *)networkKeyData {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyAdd;
        self.networkKeyIndex = networkKeyIndex;
        _key = networkKeyData;
    }
    return self;
}

- (instancetype)initWithNetworkKey:(SigNetkeyModel *)networkKey {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyAdd;
        self.networkKeyIndex = networkKey.index;
        _key = [LibTools nsstringToHex:networkKey.key];
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyAdd;
        if (parameters == nil || parameters.length != 18) {
            return nil;
        }
        self.networkKeyIndex = [SigConfigNetKeyMessage decodeNetKeyIndexFromData:parameters atOffset:0];
        _key = [parameters subdataWithRange:NSMakeRange(2, 16)];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    NSData *data = [self encodeNetKeyIndex];
    [mData appendData:data];
    [mData appendData:_key];
    return mData;
}

- (Class)responseType {
    return [SigConfigNetKeyStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigNetKeyDelete

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyDelete;
    }
    return self;
}

- (instancetype)initWithNetworkKeyIndex:(UInt16)networkKeyIndex {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyDelete;
        self.networkKeyIndex = networkKeyIndex;
    }
    return self;
}

- (instancetype)initWithNetworkKey:(SigNetkeyModel *)networkKey {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyDelete;
        self.networkKeyIndex = networkKey.index;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyDelete;
        if (parameters == nil || parameters.length != 18) {
            return nil;
        }
        self.networkKeyIndex = [SigConfigNetKeyMessage decodeNetKeyIndexFromData:parameters atOffset:0];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData dataWithData:[self encodeNetKeyIndex]];
    return mData;
}

- (Class)responseType {
    return [SigConfigNetKeyStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigNetKeyGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigConfigNetKeyList class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigNetKeyList

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyList;
    }
    return self;
}

- (instancetype)initWithNetworkKeys:(NSArray <SigNetkeyModel *>*)networkKeys {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyList;
        _networkKeyIndexs = [NSMutableArray array];
        for (SigNetkeyModel *model in networkKeys) {
            [_networkKeyIndexs addObject:@(model.index)];
        }
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyList;
        if (parameters == nil || parameters.length == 0) {
            return nil;
        }
        _networkKeyIndexs = [NSMutableArray arrayWithArray:[SigConfigNetKeyMessage decodeIndexesFromData:parameters atOffset:0]];
    }
    return self;
}

- (NSData *)parameters {
    return [self encodeIndexes:_networkKeyIndexs];
}

@end


@implementation SigConfigNetKeyStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyStatus;
    }
    return self;
}

- (instancetype)initWithNetworkKey:(SigNetkeyModel *)networkKey {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyStatus;
        self.networkKeyIndex = networkKey.index;
        _status = SigConfigMessageStatus_success;

    }
    return self;
}

- (instancetype)initWithStatus:(SigConfigMessageStatus)status forMessage:(SigConfigNetKeyMessage *)message {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyStatus;
        self.networkKeyIndex = message.networkKeyIndex;
        _status = status;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyStatus;
        if (parameters == nil || parameters.length != 3) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _status = tem;
        self.networkKeyIndex = [SigConfigNetKeyMessage decodeNetKeyIndexFromData:parameters atOffset:1];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    data = [self encodeNetKeyIndex];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigConfigNetKeyUpdate

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyUpdate;
    }
    return self;
}

- (instancetype)initWithNetworkKeyIndex:(UInt16)networkKeyIndex networkKeyData:(NSData *)networkKeyData {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyUpdate;
        self.networkKeyIndex = networkKeyIndex;
        _key = networkKeyData;
    }
    return self;
}

- (instancetype)initWithNetworkKey:(SigNetkeyModel *)networkKey {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyUpdate;
        self.networkKeyIndex = networkKey.index;
        _key = [LibTools nsstringToHex:networkKey.key];
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNetKeyUpdate;
        if (parameters == nil || parameters.length != 18) {
            return nil;
        }
        self.networkKeyIndex = [SigConfigNetKeyMessage decodeNetKeyIndexFromData:parameters atOffset:0];
        _key = [parameters subdataWithRange:NSMakeRange(2, 16)];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    NSData *data = [self encodeNetKeyIndex];
    [mData appendData:data];
    [mData appendData:_key];
    return mData;
}

- (Class)responseType {
    return [SigConfigNetKeyStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigNodeIdentityGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNodeIdentityGet;
    }
    return self;
}

- (instancetype)initWithNetKeyIndex:(UInt16)netKeyIndex {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNodeIdentityGet;
        _netKeyIndex = netKeyIndex;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNodeIdentityGet;
        if (parameters == nil || parameters.length != 2) {
            return nil;
        }
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _netKeyIndex = (tem16 >> 4) & 0xFFF;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _netKeyIndex << 4;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigConfigNodeIdentityStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigNodeIdentitySet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNodeIdentitySet;
    }
    return self;
}

- (instancetype)initWithNetKeyIndex:(UInt16)netKeyIndex identity:(SigNodeIdentityState)identity {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNodeIdentitySet;
        _netKeyIndex = netKeyIndex;
        _identity = identity;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNodeIdentitySet;
        if (parameters == nil || parameters.length != 3) {
            return nil;
        }
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _netKeyIndex = (tem16 >> 4) & 0xFFF;
        UInt8 tem8 = 0;
        memcpy(&tem8, dataByte+2, 1);
        _identity = tem8;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _netKeyIndex << 4;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = _identity;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigConfigNodeIdentityStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigNodeIdentityStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNodeIdentityStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNodeIdentityStatus;
        if (parameters == nil || parameters.length != 4) {
            return nil;
        }
        Byte *dataByte = (Byte *)parameters.bytes;
        UInt8 tem8 = 0;
        memcpy(&tem8, dataByte, 1);
        _status = tem8;
        UInt16 tem16 = 0;
        memcpy(&tem16, dataByte+1, 2);
        _netKeyIndex = (tem16 >> 4) & 0xFFF;
        memcpy(&tem8, dataByte+3, 1);
        _identity = tem8;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _netKeyIndex << 4;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem8 = _identity;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigConfigNodeReset

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNodeReset;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNodeReset;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigConfigNodeResetStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigNodeResetStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNodeResetStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configNodeResetStatus;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

@end


@implementation SigConfigSIGModelAppGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelAppGet;
    }
    return self;
}

- (instancetype)initWithElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelAppGet;
        if (companyIdentifier == 0) {
            self.elementAddress = elementAddress;
            self.modelIdentifier = modelIdentifier;
        } else {
            // Use ConfigVendorModelAppGet instead.
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelAppGet;
        if (model.getIntCompanyIdentifier == 0) {
            self.elementAddress = elementAddress;
            self.modelIdentifier = model.getIntModelIdentifier;
        } else {
            // Use ConfigVendorModelAppGet instead.
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelAppGet;
        if (parameters == nil || parameters.length != 4) {
            return nil;
        }
        UInt16 tem1=0,tem2=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        memcpy(&tem2, dataByte+2, 2);
        self.elementAddress = tem1;
        self.modelIdentifier = tem2;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = self.modelIdentifier;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigConfigSIGModelAppList class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigSIGModelAppList

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelAppList;
    }
    return self;
}

- (instancetype)initResponseToSigConfigSIGModelAppGet:(SigConfigSIGModelAppGet *)request withApplicationKeys:(NSArray <SigAppkeyModel *>*)applicationKeys {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelAppList;
        _elementAddress = request.elementAddress;
        self.modelIdentifier = request.modelIdentifier;
        self.applicationKeyIndexes = [NSMutableArray array];
        for (SigAppkeyModel *model in applicationKeys) {
            [self.applicationKeyIndexes addObject:@(model.index)];
        }
        self.status = SigConfigMessageStatus_success;
    }
    return self;
}

- (instancetype)initResponseToSigConfigSIGModelAppGet:(SigConfigSIGModelAppGet *)request withStatus:(SigConfigMessageStatus)status {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelAppList;
        _elementAddress = request.elementAddress;
        self.modelIdentifier = request.modelIdentifier;
        self.applicationKeyIndexes = [NSMutableArray array];
        self.status = status;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configSIGModelAppList;
        if (parameters == nil || parameters.length < 5) {
            return nil;
        }
        UInt8 status=0;
        UInt16 tem1=0,tem2=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&status, dataByte, 1);
        memcpy(&tem1, dataByte+1, 2);
        memcpy(&tem2, dataByte+3, 2);
        self.status = status;
        _elementAddress = tem1;
        self.modelIdentifier = tem2;
        self.applicationKeyIndexes = [NSMutableArray arrayWithArray:[SigConfigNetKeyMessage decodeIndexesFromData:parameters atOffset:5]];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = self.status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _elementAddress;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = self.modelIdentifier;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    data = [self encodeIndexes:self.applicationKeyIndexes];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigConfigVendorModelAppGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configVendorModelAppGet;
    }
    return self;
}

- (instancetype)initWithElementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier {
    if (self = [super init]) {
        self.opCode = SigOpCode_configVendorModelAppGet;
        if (companyIdentifier == 0) {
            self.elementAddress = elementAddress;
            self.modelIdentifier = modelIdentifier;
            self.companyIdentifier = companyIdentifier;

        } else {
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_configVendorModelAppGet;
        if (model.getIntCompanyIdentifier == 0) {
            self.elementAddress = elementAddress;
            self.modelIdentifier = model.getIntModelIdentifier;
            self.companyIdentifier = model.getIntCompanyIdentifier;

        } else {
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configVendorModelAppGet;
        if (parameters == nil || parameters.length != 6) {
            return nil;
        }
        UInt16 tem1=0,tem2=0,tem3=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem1, dataByte, 2);
        memcpy(&tem2, dataByte+2, 2);
        memcpy(&tem3, dataByte+4, 2);
        self.elementAddress = tem1;
        self.modelIdentifier = tem2;
        self.companyIdentifier = tem3;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem = self.elementAddress;
    NSData *data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = self.companyIdentifier;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    tem = self.modelIdentifier;
    data = [NSData dataWithBytes:&tem length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigConfigVendorModelAppList class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigConfigVendorModelAppList

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_configVendorModelAppList;
    }
    return self;
}

- (instancetype)initWithModel:(SigModelIDModel *)model elementAddress:(UInt16)elementAddress applicationKeys:(NSArray <SigAppkeyModel *>*)applicationKeys status:(SigConfigMessageStatus)status {
    if (self = [super init]) {
        self.opCode = SigOpCode_configVendorModelAppList;
        if (model.getIntCompanyIdentifier == 0) {
            _elementAddress = elementAddress;
            self.modelIdentifier = model.getIntModelIdentifier;
            self.companyIdentifier = model.getIntCompanyIdentifier;
            self.status = status;
            self.applicationKeyIndexes = [NSMutableArray array];
            for (SigAppkeyModel *model in applicationKeys) {
                [self.applicationKeyIndexes addObject:@(model.index)];
            }
        } else {
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_configVendorModelAppList;
        if (parameters == nil || parameters.length < 7) {
            return nil;
        }
        UInt8 status=0;
        UInt16 tem1=0,tem2=0,tem3=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&status, dataByte, 1);
        memcpy(&tem1, dataByte+1, 2);
        memcpy(&tem2, dataByte+3, 2);
        memcpy(&tem3, dataByte+5, 2);
        self.status = status;
        _elementAddress = tem1;
        self.companyIdentifier = tem2;
        self.modelIdentifier = tem3;
        self.applicationKeyIndexes = [NSMutableArray arrayWithArray:[SigConfigNetKeyMessage decodeIndexesFromData:parameters atOffset:7]];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = self.status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _elementAddress;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = self.companyIdentifier;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = self.modelIdentifier;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    data = [self encodeIndexes:self.applicationKeyIndexes];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigRemoteProvisioningScanCapabilitiesGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningScanCapabilitiesGet;
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigRemoteProvisioningScanCapabilitiesStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

- (BOOL)isSegmented {
    return NO;
}

@end


@implementation SigRemoteProvisioningScanCapabilitiesStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningScanCapabilitiesStatus;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = self.maxScannedItems;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = self.activeScan?1:0;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningScanCapabilitiesStatus;
        if (parameters == nil || parameters.length < 2) {
            return nil;
        }
        UInt8 tem=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _maxScannedItems = tem;
        memcpy(&tem, dataByte+1, 1);
        _activeScan = tem;
    }
    return self;
}

@end


@implementation SigRemoteProvisioningScanGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningScanGet;
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigRemoteProvisioningScanStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

- (BOOL)isSegmented {
    return NO;
}

@end


@implementation SigRemoteProvisioningScanStart

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningScanStart;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = self.scannedItemsLimit;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = self.timeout;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (self.UUID && self.UUID.length) {
        [mData appendData:self.UUID];
    }
    return mData;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningScanStart;
        if (parameters == nil || (parameters.length != 18 && parameters.length != 2)) {
            return nil;
        }
        UInt8 tem=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _scannedItemsLimit = tem;
        memcpy(&tem, dataByte+1, 1);
        _timeout = tem;
        if (parameters.length >= 18) {
            _UUID = [parameters subdataWithRange:NSMakeRange(2, 16)];
        }
    }
    return self;
}

- (instancetype)initWithScannedItemsLimit:(UInt8)scannedItemsLimit timeout:(UInt8)timeout UUID:(nullable NSData *)UUID {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningScanStart;
        _scannedItemsLimit = scannedItemsLimit;
        _timeout = timeout;
        _UUID = UUID;
    }
    return self;
}

- (Class)responseType {
    return [SigRemoteProvisioningScanStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

- (BOOL)isSegmented {
    return NO;
}

@end


@implementation SigRemoteProvisioningScanStop

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningScanStop;
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigRemoteProvisioningScanStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

- (BOOL)isSegmented {
    return NO;
}

@end


@implementation SigRemoteProvisioningScanStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningScanStatus;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = self.status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = self.RPScanningState;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = self.scannedItemsLimit;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = self.timeout;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningScanStatus;
        if (parameters == nil || parameters.length < 4) {
            return nil;
        }
        UInt8 tem=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _status = tem;
        memcpy(&tem, dataByte+1, 1);
        _RPScanningState = tem;
        memcpy(&tem, dataByte+2, 1);
        _scannedItemsLimit = tem;
        memcpy(&tem, dataByte+3, 1);
        _timeout = tem;
    }
    return self;
}

@end


@implementation SigRemoteProvisioningScanReport

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningScanReport;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    SInt8 stem8 = self.RSSI;
    NSData *data = [NSData dataWithBytes:&stem8 length:1];
    [mData appendData:data];
    if (self.UUID && self.UUID.length) {
        [mData appendData:self.UUID];
    }
    UInt16 tem16 = self.OOB;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningScanReport;
        if (parameters == nil || parameters.length <19) {
            return nil;
        }
        SInt8 stem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&stem8, dataByte, 1);
        _RSSI = stem8;
        if (parameters.length >= 17) {
            _UUID = [parameters subdataWithRange:NSMakeRange(1, 16)];
            if (parameters.length >= 19) {
                UInt16 tem16 = 0;
                memcpy(&tem16, dataByte+17, 2);
                _OOB = tem16;
            }
        }
    }
    return self;
}

- (BOOL)isSegmented {
    return NO;
}

@end

@implementation SigRemoteProvisioningExtendedScanStart

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningExtendedScanStart;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = self.ADTypeFilterCount;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (self.ADTypeFilter && self.ADTypeFilter.length) {
        [mData appendData:self.ADTypeFilter];
    }
    if (self.UUID && self.UUID.length) {
        [mData appendData:self.UUID];
        tem8 = self.timeout;
        data = [NSData dataWithBytes:&tem8 length:2];
        [mData appendData:data];
    }
    return mData;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningExtendedScanStart;
        if (parameters == nil || parameters.length < 1) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        self.ADTypeFilterCount = tem8;
        if (self.ADTypeFilterCount == 0) {
            if (parameters.length >= 17) {
                self.UUID = [parameters subdataWithRange:NSMakeRange(1, 16)];
                if (parameters.length >= 18) {
                    memcpy(&tem8, dataByte+17, 1);
                    self.timeout = tem8;
                }
            }
        }
    }
    return self;
}

- (instancetype)initWithADTypeFilterCount:(UInt8)ADTypeFilterCount ADTypeFilter:(nullable NSData *)ADTypeFilter UUID:(nullable NSData *)UUID timeout:(UInt8)timeout {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningExtendedScanStart;
        _ADTypeFilterCount = ADTypeFilterCount;
        _ADTypeFilter = ADTypeFilter;
        _UUID = UUID;
        _timeout = timeout;
    }
    return self;
}

- (Class)responseType {
    return [SigRemoteProvisioningExtendedScanReport class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

- (BOOL)isSegmented {
    return NO;
}

@end


@implementation SigRemoteProvisioningExtendedScanReport

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningExtendedScanReport;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = self.status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    [mData appendData:self.UUID];
    UInt16 tem16 = self.OOBInformation;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningExtendedScanReport;
        if (parameters == nil || parameters.length <17) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = tem8;
        if (parameters.length >= 17) {
            _UUID = [parameters subdataWithRange:NSMakeRange(1, 16)];
            if (parameters.length >= 19) {
                UInt16 tem16 = 0;
                memcpy(&tem16, dataByte+17, 2);
                _OOBInformation = tem16;
                if (parameters.length > 19) {
                    _AdvStructures = [parameters subdataWithRange:NSMakeRange(19, parameters.length-19)];
                }
            }
        }
    }
    return self;
}

@end


@implementation SigRemoteProvisioningLinkGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningLinkGet;
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigRemoteProvisioningLinkStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

- (BOOL)isSegmented {
    return NO;
}

@end


@implementation SigRemoteProvisioningLinkOpen

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningLinkOpen;
    }
    return self;
}

- (NSData *)parameters {
    if (_UUID && _UUID.length > 0) {
        return [NSData dataWithData:_UUID];
    }
    return nil;
}

- (instancetype)initWithUUID:(nullable NSData *)UUID {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningLinkOpen;
        _UUID = UUID;
    }
    return self;
}

- (Class)responseType {
    return [SigRemoteProvisioningLinkStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

- (BOOL)isSegmented {
    return NO;
}

@end


@implementation SigRemoteProvisioningLinkClose

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningLinkClose;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = self.reason;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (instancetype)initWithReason:(SigRemoteProvisioningLinkCloseStatus)reason {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningLinkClose;
        _reason = reason;
    }
    return self;
}

- (Class)responseType {
    return [SigRemoteProvisioningLinkStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

- (BOOL)isSegmented {
    return NO;
}

@end


@implementation SigRemoteProvisioningLinkStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningLinkStatus;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _RPState;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningLinkStatus;
        if (parameters == nil || parameters.length != 2) {
            return nil;
        }
        UInt8 tem=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _status = tem;
        memcpy(&tem, dataByte+1, 1);
        _RPState = tem;
    }
    return self;
}

@end


@implementation SigRemoteProvisioningLinkReport

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningLinkReport;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _RPState;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_reason < 0x03) {
        tem8 = _reason;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningLinkReport;
        if (parameters == nil || (parameters.length != 2 && parameters.length != 3)) {
            return nil;
        }
        UInt8 tem=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _status = tem;
        memcpy(&tem, dataByte+1, 1);
        _RPState = tem;
        if (parameters.length >= 3) {
            memcpy(&tem, dataByte+2, 1);
            _reason = tem;
        }
    }
    return self;
}

@end


@implementation SigRemoteProvisioningPDUSend

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningPDUSend;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _outboundPDUNumber;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_provisioningPDU) {
        [mData appendData:_provisioningPDU];
    }
    return mData;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningPDUSend;
        if (parameters == nil || parameters.length < 2) {
            return nil;
        }
        UInt8 tem=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _outboundPDUNumber = tem;
        if (parameters.length >= 2) {
            _provisioningPDU = [parameters subdataWithRange:NSMakeRange(1, parameters.length-1)];
        }
    }
    return self;
}

- (instancetype)initWithOutboundPDUNumber:(UInt8)outboundPDUNumber provisioningPDU:(NSData *)provisioningPDU {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningPDUSend;
        _outboundPDUNumber = outboundPDUNumber;
        _provisioningPDU = provisioningPDU;
    }
    return self;
}

- (BOOL)isSegmented {
//    return NO;
    return YES;
}

@end


@implementation SigRemoteProvisioningPDUOutboundReport

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningPDUOutboundReport;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _outboundPDUNumber;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningPDUOutboundReport;
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }
        UInt8 tem=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _outboundPDUNumber = tem;
    }
    return self;
}

@end


@implementation SigRemoteProvisioningPDUReport

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningPDUReport;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _outboundPDUNumber;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_provisioningPDU) {
        [mData appendData:_provisioningPDU];
    }
    return mData;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_remoteProvisioningPDUReport;
        if (parameters == nil || parameters.length < 2) {
            return nil;
        }
        UInt8 tem=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _outboundPDUNumber = tem;
        if (parameters.length >= 2) {
            _provisioningPDU = [parameters subdataWithRange:NSMakeRange(1, parameters.length-1)];
        }
    }
    return self;
}

@end


@implementation SigOpcodesAggregatorSequence

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_OpcodesAggregatorSequence;
        _isEncryptByDeviceKey = NO;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _elementAddress;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_items && _items.count) {
        NSArray *temA = [NSArray arrayWithArray:_items];
        for (SigOpcodesAggregatorItemModel *m in temA) {
            [mData appendData:m.parameters];
        }
    }
    return mData;
}

- (NSData *)opCodeAndParameters {
    NSMutableData *mData = [NSMutableData data];
    NSData *data = [SigHelper.share getOpCodeDataWithUInt32Opcode:self.opCode];
    [mData appendData:data];
    [mData appendData:self.parameters];
    return mData;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_OpcodesAggregatorSequence;
        _isEncryptByDeviceKey = NO;
        if (parameters == nil || parameters.length < 2) {
            return nil;
        }
        UInt16 tem16=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _elementAddress = tem16;
        NSMutableArray *mArray = [NSMutableArray array];
        NSMutableData *mData = [NSMutableData dataWithData:[parameters subdataWithRange:NSMakeRange(2, parameters.length-2)]];
        while (mData.length > 0) {
            SigOpcodesAggregatorItemModel *model = [[SigOpcodesAggregatorItemModel alloc] initWithOpcodeAndParameters:mData];
            SigOpCodeAndParametersModel *opCodeAndParametersModel = [[SigOpCodeAndParametersModel alloc] initWithOpCodeAndParameters:model.opcodeAndParameters];
            if (opCodeAndParametersModel == nil) {
                return nil;
            }
            _isEncryptByDeviceKey = [SigHelper.share isDeviceKeyOpCode:opCodeAndParametersModel.opCode];
            if (model) {
                [mArray addObject:model];
                [mData replaceBytesInRange:NSMakeRange(0, model.parameters.length) withBytes:nil length:0];
            } else {
                break;
            }
        }
        _items = mArray;
    }
    return self;
}

- (instancetype)initWithElementAddress:(UInt16)elementAddress items:(NSArray <SigOpcodesAggregatorItemModel *>*)items {
    if (self = [super init]) {
        self.opCode = SigOpCode_OpcodesAggregatorSequence;
        _isEncryptByDeviceKey = NO;
        _elementAddress = elementAddress;
        if (items && items.count > 0) {
            _items = [NSMutableArray arrayWithArray:items];
            SigOpcodesAggregatorItemModel *model = items.firstObject;
            SigOpCodeAndParametersModel *opCodeAndParametersModel = [[SigOpCodeAndParametersModel alloc] initWithOpCodeAndParameters:model.opcodeAndParameters];
            if (opCodeAndParametersModel == nil) {
                return nil;
            }
            _isEncryptByDeviceKey = [SigHelper.share isDeviceKeyOpCode:opCodeAndParametersModel.opCode];
        }
    }
    return self;
}

- (Class)responseType {
    return [SigOpcodesAggregatorStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

//- (BOOL)isSegmented {
//    return NO;
//}

@end


@implementation SigOpcodesAggregatorStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_OpcodesAggregatorStatus;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _elementAddress;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_statusItems && _statusItems.count) {
        NSArray *temA = [NSArray arrayWithArray:_statusItems];
        for (SigOpcodesAggregatorItemModel *m in temA) {
            [mData appendData:m.parameters];
        }
    }
    return mData;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_OpcodesAggregatorStatus;
        if (parameters == nil || parameters.length < 3) {
            return nil;
        }
        UInt8 tem8=0;
        UInt16 tem16=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        memcpy(&tem16, dataByte+1, 2);
        _status = tem8;
        _elementAddress = tem16;
        NSMutableArray *mArray = [NSMutableArray array];
        NSMutableData *mData = [NSMutableData dataWithData:[parameters subdataWithRange:NSMakeRange(3, parameters.length-3)]];
        while (mData.length > 0) {
            SigOpcodesAggregatorItemModel *model = [[SigOpcodesAggregatorItemModel alloc] initWithOpcodeAndParameters:mData];
            if (model) {
                [mArray addObject:model];
                [mData replaceBytesInRange:NSMakeRange(0, model.parameters.length) withBytes:nil length:0];
            } else {
                break;
            }
        }
        _statusItems = mArray;
    }
    return self;
}

- (instancetype)initWithStatus:(SigOpcodesAggregatorMessagesStatus)status elementAddress:(UInt16)elementAddress items:(NSArray <SigOpcodesAggregatorItemModel *>*)items {
    if (self = [super init]) {
        self.opCode = SigOpCode_OpcodesAggregatorStatus;
        _status = status;
        _elementAddress = elementAddress;
        _statusItems = [NSMutableArray arrayWithArray:items];
    }
    return self;
}

@end


@implementation SigPrivateBeaconGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateBeaconGet;
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigPrivateBeaconStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigPrivateBeaconSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateBeaconSet;
    }
    return self;
}

- (instancetype)initWithPrivateBeacon:(SigPrivateBeaconState)privateBeacon randomUpdateIntervalSteps:(UInt8)randomUpdateIntervalSteps {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateBeaconSet;
        _privateBeacon = privateBeacon;
        _randomUpdateIntervalSteps = randomUpdateIntervalSteps;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _privateBeacon;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _randomUpdateIntervalSteps;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigPrivateBeaconStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigPrivateBeaconStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateBeaconStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateBeaconStatus;
        if (parameters == nil || parameters.length != 2) {
            return nil;
        }
        UInt8 tem8=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _privateBeacon = tem8;
        memcpy(&tem8, dataByte+1, 1);
        _randomUpdateIntervalSteps = tem8;
    }
    return self;
}

- (instancetype)initWithPrivateBeacon:(SigPrivateBeaconState)privateBeacon randomUpdateIntervalSteps:(UInt8)randomUpdateIntervalSteps {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateBeaconStatus;
        _privateBeacon = privateBeacon;
        _randomUpdateIntervalSteps = randomUpdateIntervalSteps;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _privateBeacon;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _randomUpdateIntervalSteps;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigPrivateGattProxyGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateGattProxyGet;
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigPrivateGattProxyStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigPrivateGattProxySet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateGattProxySet;
    }
    return self;
}

- (instancetype)initWithPrivateGattProxy:(SigPrivateGattProxyState)privateGattProxy {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateGattProxySet;
        _privateGattProxy = privateGattProxy;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _privateGattProxy;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigPrivateGattProxyStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigPrivateGattProxyStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateGattProxyStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateGattProxyStatus;
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }
        UInt8 tem8=0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _privateGattProxy = tem8;
    }
    return self;
}

- (instancetype)initWithPrivateGattProxy:(SigPrivateGattProxyState)privateGattProxy {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateBeaconStatus;
        _privateGattProxy = privateGattProxy;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _privateGattProxy;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigPrivateNodeIdentityGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateNodeIdentityGet;
    }
    return self;
}

- (instancetype)initWithNetKeyIndex:(UInt16)netKeyIndex {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateNodeIdentityGet;
        _netKeyIndex = netKeyIndex;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateNodeIdentityGet;
        if (parameters == nil || parameters.length != 2) {
            return nil;
        }
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _netKeyIndex = (tem16 >> 4) & 0xFFF;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _netKeyIndex << 4;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigPrivateNodeIdentityStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigPrivateNodeIdentitySet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateNodeIdentitySet;
    }
    return self;
}

- (instancetype)initWithNetKeyIndex:(UInt16)netKeyIndex privateIdentity:(SigPrivateNodeIdentityState)privateIdentity {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateNodeIdentitySet;
        _netKeyIndex = netKeyIndex;
        _privateIdentity = privateIdentity;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateNodeIdentitySet;
        if (parameters == nil || parameters.length != 3) {
            return nil;
        }
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _netKeyIndex = (tem16 >> 4) & 0xFFF;
        UInt8 tem8 = 0;
        memcpy(&tem8, dataByte+2, 1);
        _privateIdentity = tem8;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _netKeyIndex << 4;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = _privateIdentity;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigPrivateNodeIdentityStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigPrivateNodeIdentityStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateNodeIdentityStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_PrivateNodeIdentityStatus;
        if (parameters == nil || parameters.length != 4) {
            return nil;
        }
        Byte *dataByte = (Byte *)parameters.bytes;
        UInt8 tem8 = 0;
        memcpy(&tem8, dataByte, 1);
        _status = tem8;
        UInt16 tem16 = 0;
        memcpy(&tem16, dataByte+1, 2);
        _netKeyIndex = (tem16 >> 4) & 0xFFF;
        memcpy(&tem8, dataByte+3, 1);
        _privateIdentity = tem8;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _netKeyIndex << 4;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem8 = _privateIdentity;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end
