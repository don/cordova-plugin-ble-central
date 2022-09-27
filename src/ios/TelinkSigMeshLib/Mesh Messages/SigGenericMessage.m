/********************************************************************************************************
 * @file     SigGenericMessage.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/11/12
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

#import "SigGenericMessage.h"

@implementation SigGenericMessage

- (BOOL)isTransactionMessage {
    /*
SigGenericDeltaSet|SigGenericDeltaSetUnacknowledged|SigGenericLevelSet|SigGenericLevelSetUnacknowledged|SigGenericMoveSet|SigGenericMoveSetUnacknowledged|SigGenericOnOffSet|SigGenericOnOffSetUnacknowledged|SigGenericPowerLevelSet|SigGenericPowerLevelSetUnacknowledged
     */
    if ([self isMemberOfClass:[SigGenericOnOffSet class]] ||
        [self isMemberOfClass:[SigGenericOnOffSetUnacknowledged class]] ||
        [self isMemberOfClass:[SigGenericLevelSet class]] ||
        [self isMemberOfClass:[SigGenericLevelSetUnacknowledged class]] ||
        [self isMemberOfClass:[SigGenericDeltaSet class]] ||
        [self isMemberOfClass:[SigGenericDeltaSetUnacknowledged class]] ||
        [self isMemberOfClass:[SigGenericMoveSet class]] ||
        [self isMemberOfClass:[SigGenericMoveSetUnacknowledged class]] ||
        [self isMemberOfClass:[SigGenericPowerLevelSet class]] ||
        [self isMemberOfClass:[SigGenericPowerLevelSetUnacknowledged class]] ||
        [self isMemberOfClass:[SigSceneRecall class]] ||
        [self isMemberOfClass:[SigSceneRecallUnacknowledged class]] ||
        [self isMemberOfClass:[SigLightLightnessSet class]] ||
        [self isMemberOfClass:[SigLightLightnessSetUnacknowledged class]] ||
        [self isMemberOfClass:[SigLightLightnessLinearSet class]] ||
        [self isMemberOfClass:[SigLightLightnessLinearSetUnacknowledged class]] ||
        [self isMemberOfClass:[SigLightCTLSet class]] ||
        [self isMemberOfClass:[SigLightCTLSetUnacknowledged class]] ||
        [self isMemberOfClass:[SigLightCTLTemperatureSet class]] ||
        [self isMemberOfClass:[SigLightCTLTemperatureSetUnacknowledged class]] ||
        [self isMemberOfClass:[SigLightHSLHueSet class]] ||
        [self isMemberOfClass:[SigLightHSLHueSetUnacknowledged class]] ||
        [self isMemberOfClass:[SigLightHSLSaturationSet class]] ||
        [self isMemberOfClass:[SigLightHSLSaturationSetUnacknowledged class]] ||
        [self isMemberOfClass:[SigLightHSLSet class]] ||
        [self isMemberOfClass:[SigLightHSLSetUnacknowledged class]] ||
        [self isMemberOfClass:[SigLightXyLSet class]] ||
        [self isMemberOfClass:[SigLightXyLSetUnacknowledged class]] ||
        [self isMemberOfClass:[SigLightLCLightOnOffSet class]] ||
        [self isMemberOfClass:[SigLightLCLightOnOffSetUnacknowledged class]]) {
        return YES;
    }
    return NO;
}

@end


@implementation SigAcknowledgedGenericMessage
- (Class)responseType {
    TeLogDebug(@"注意：本类的子类未重写该方法。");
    return [SigAcknowledgedGenericMessage class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericOnOffGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffGet;
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
    return [SigGenericOnOffStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericOnOffSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffSet;
    }
    return self;
}

- (instancetype)initWithIsOn:(BOOL)isOn {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffSet;
        _isOn = isOn;
        //v3.2.3后，_transitionTime为nil，默认不带渐变参数。
//        _transitionTime = [[SigTransitionTime alloc] initWithSetps:0 stepResolution:0];
        _delay = 0;
    }
    return self;
}

- (instancetype)initWithIsOn:(BOOL)isOn transitionTime:(SigTransitionTime *)transitionTime dalay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffSet;
        _isOn = isOn;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffSet;
        if (parameters == nil || (parameters.length != 2 && parameters.length != 4)) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _isOn = tem == 0x01;
        memcpy(&tem, dataByte+1, 1);
        self.tid = tem;
        if (parameters.length == 4) {
            memcpy(&tem, dataByte+2, 1);
            _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
            memcpy(&tem, dataByte+3, 1);
            _delay = tem;
        } else {
            _transitionTime = nil;
            _delay = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _isOn ? 0x01 : 0x00;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigGenericOnOffStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericOnOffSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithIsOn:(BOOL)isOn {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffSetUnacknowledged;
        _isOn = isOn;
        //v3.2.3后，_transitionTime为nil，默认不带渐变参数。
//        _transitionTime = [[SigTransitionTime alloc] initWithSetps:0 stepResolution:0];
        _delay = 0;
    }
    return self;
}

- (instancetype)initWithIsOn:(BOOL)isOn transitionTime:(SigTransitionTime *)transitionTime dalay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffSetUnacknowledged;
        _isOn = isOn;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffSetUnacknowledged;
        if (parameters == nil || (parameters.length != 2 && parameters.length != 4)) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _isOn = tem == 0x01;
        memcpy(&tem, dataByte+1, 1);
        self.tid = tem;
        if (parameters.length == 4) {
            memcpy(&tem, dataByte+2, 1);
            _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
            memcpy(&tem, dataByte+3, 1);
            _delay = tem;
        } else {
            _transitionTime = nil;
            _delay = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _isOn ? 0x01 : 0x00;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigGenericOnOffStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffStatus;
    }
    return self;
}

- (instancetype)initWithIsOn:(BOOL)isOn {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffStatus;
        _isOn = isOn;
        _targetState = NO;
        _remainingTime = nil;
    }
    return self;
}

- (instancetype)initWithIsOn:(BOOL)isOn targetState:(BOOL)targetState remainingTime:(SigTransitionTime * _Nullable )remainingTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffStatus;
        _isOn = isOn;
        _targetState = targetState;
        _remainingTime = remainingTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffStatus;
        if (parameters == nil || parameters.length < 1) {
//            if (parameters == nil || (parameters.length != 1 && parameters.length != 3)) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _isOn = tem == 0x01;
        if (parameters.length >= 3) {
            memcpy(&tem, dataByte+1, 1);
            _targetState = tem == 0x01;
            memcpy(&tem, dataByte+2, 1);
            _remainingTime = [[SigTransitionTime alloc] initWithRawValue:tem];
        } else {
            _targetState = NO;
            _remainingTime = nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _isOn ? 0x01 : 0x00;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_remainingTime != nil) {
        tem8 = _targetState ? 0x01 : 0x00;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _remainingTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigGenericLevelGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericLevelGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericLevelGet;
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
    return [SigGenericLevelStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericLevelSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericLevelSet;
    }
    return self;
}

- (instancetype)initWithLevel:(UInt16)level {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericLevelSet;
        _level = level;
        //v3.2.3后，_transitionTime为nil，默认不带渐变参数。
//        _transitionTime = [[SigTransitionTime alloc] initWithSetps:0 stepResolution:0];
        _delay = 0;
    }
    return self;
}

- (instancetype)initWithLevel:(UInt16)level transitionTime:(SigTransitionTime *)transitionTime dalay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericLevelSet;
        _level = level;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericLevelSet;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }
        UInt16 tem16 = 0;
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _level = tem16;
        memcpy(&tem, dataByte+2, 1);
        self.tid = tem;
        if (parameters.length == 5) {
            memcpy(&tem, dataByte+3, 1);
            _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
            memcpy(&tem, dataByte+4, 1);
            _delay = tem;
        } else {
            _transitionTime = nil;
            _delay = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _level;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigGenericLevelStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericLevelSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericLevelSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithLevel:(UInt16)level {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericLevelSetUnacknowledged;
        _level = level;
        //v3.2.3后，_transitionTime为nil，默认不带渐变参数。
//        _transitionTime = [[SigTransitionTime alloc] initWithSetps:0 stepResolution:0];
        _delay = 0;
    }
    return self;
}

- (instancetype)initWithLevel:(UInt16)level transitionTime:(SigTransitionTime *)transitionTime dalay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericLevelSetUnacknowledged;
        _level = level;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericLevelSetUnacknowledged;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }
        UInt16 tem16 = 0;
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _level = tem16;
        memcpy(&tem, dataByte+2, 1);
        self.tid = tem;
        if (parameters.length == 5) {
            memcpy(&tem, dataByte+3, 1);
            _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
            memcpy(&tem, dataByte+4, 1);
            _delay = tem;
        } else {
            _transitionTime = nil;
            _delay = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _level;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigGenericLevelStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericLevelStatus;
    }
    return self;
}

- (instancetype)initWithLevel:(UInt16)level {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericLevelStatus;
        _level = level;
        _targetLevel = 0;
        _remainingTime = nil;
    }
    return self;
}

- (instancetype)initWithLevel:(UInt16)level targetLevel:(BOOL)targetLevel remainingTime:(SigTransitionTime *)remainingTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericLevelStatus;
        _level = level;
        _targetLevel = targetLevel;
        _remainingTime = remainingTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericLevelStatus;
        if (parameters == nil || parameters.length < 2) {
//            if (parameters == nil || (parameters.length != 2 && parameters.length != 5)) {
            return nil;
        }
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _level = tem16;
        if (parameters.length >= 5) {
            memcpy(&tem16, dataByte+2, 2);
            _targetLevel = tem16;
            UInt8 tem = 0;
            memcpy(&tem, dataByte+4, 1);
            _remainingTime = [[SigTransitionTime alloc] initWithRawValue:tem];
        } else {
            _targetLevel = 0;
            _remainingTime = nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _level;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_remainingTime != nil) {
        tem16 = _targetLevel;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        UInt8 tem8 = _remainingTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigGenericDeltaSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDeltaSet;
    }
    return self;
}

- (instancetype)initWithDelta:(UInt32)delta {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDeltaSet;
        _delta = delta;
        //v3.2.3后，_transitionTime为nil，默认不带渐变参数。
//        _transitionTime = [[SigTransitionTime alloc] initWithSetps:0 stepResolution:0];
        _delay = 0;
    }
    return self;
}

- (instancetype)initWithDelta:(UInt32)delta transitionTime:(SigTransitionTime *)transitionTime dalay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDeltaSet;
        _delta = delta;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDeltaSet;
        if (parameters == nil || (parameters.length != 5 && parameters.length != 7)) {
            return nil;
        }
        UInt32 tem32 = 0;
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem32, dataByte, 4);
        _delta = tem32;
        memcpy(&tem, dataByte+4, 1);
        self.tid = tem;
        if (parameters.length == 7) {
            memcpy(&tem, dataByte+5, 1);
            _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
            memcpy(&tem, dataByte+6, 1);
            _delay = tem;
        } else {
            _transitionTime = nil;
            _delay = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt32 tem32 = _delta;
    NSData *data = [NSData dataWithBytes:&tem32 length:4];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigGenericLevelStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericDeltaSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDeltaSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithDelta:(UInt32)delta {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDeltaSetUnacknowledged;
        _delta = delta;
        //v3.2.3后，_transitionTime为nil，默认不带渐变参数。
//        _transitionTime = [[SigTransitionTime alloc] initWithSetps:0 stepResolution:0];
        _delay = 0;
    }
    return self;
}

- (instancetype)initWithDelta:(UInt32)delta transitionTime:(SigTransitionTime *)transitionTime dalay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDeltaSetUnacknowledged;
        _delta = delta;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDeltaSet;
        if (parameters == nil || (parameters.length != 5 && parameters.length != 7)) {
            return nil;
        }
        UInt32 tem32 = 0;
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem32, dataByte, 4);
        _delta = tem32;
        memcpy(&tem, dataByte+4, 1);
        self.tid = tem;
        if (parameters.length == 7) {
            memcpy(&tem, dataByte+5, 1);
            _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
            memcpy(&tem, dataByte+6, 1);
            _delay = tem;
        } else {
            _transitionTime = nil;
            _delay = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt32 tem32 = _delta;
    NSData *data = [NSData dataWithBytes:&tem32 length:4];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigGenericMoveSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericMoveSet;
    }
    return self;
}

- (instancetype)initWithDeltaLevel:(UInt16)deltaLevel {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericMoveSet;
        _deltaLevel = deltaLevel;
        //v3.2.3后，_transitionTime为nil，默认不带渐变参数。
//        _transitionTime = [[SigTransitionTime alloc] initWithSetps:0 stepResolution:0];
        _delay = 0;
    }
    return self;
}

- (instancetype)initWithDeltaLevel:(UInt16)deltaLevel transitionTime:(SigTransitionTime *)transitionTime dalay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericMoveSet;
        _deltaLevel = deltaLevel;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericMoveSet;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }
        UInt16 tem16 = 0;
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _deltaLevel = tem16;
        memcpy(&tem, dataByte+2, 1);
        self.tid = tem;
        if (parameters.length == 5) {
            memcpy(&tem, dataByte+3, 1);
            _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
            memcpy(&tem, dataByte+4, 1);
            _delay = tem;
        } else {
            _transitionTime = nil;
            _delay = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _deltaLevel;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigGenericLevelStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericMoveSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericMoveSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithDeltaLevel:(UInt16)deltaLevel {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericMoveSetUnacknowledged;
        _deltaLevel = deltaLevel;
        //v3.2.3后，_transitionTime为nil，默认不带渐变参数。
//        _transitionTime = [[SigTransitionTime alloc] initWithSetps:0 stepResolution:0];
        _delay = 0;
    }
    return self;
}

- (instancetype)initWithDeltaLevel:(UInt16)deltaLevel transitionTime:(SigTransitionTime *)transitionTime dalay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericMoveSetUnacknowledged;
        _deltaLevel = deltaLevel;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericMoveSetUnacknowledged;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }
        UInt16 tem16 = 0;
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _deltaLevel = tem16;
        memcpy(&tem, dataByte+2, 1);
        self.tid = tem;
        if (parameters.length == 5) {
            memcpy(&tem, dataByte+3, 1);
            _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
            memcpy(&tem, dataByte+4, 1);
            _delay = tem;
        } else {
            _transitionTime = nil;
            _delay = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _deltaLevel;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigGenericDefaultTransitionTimeGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDefaultTransitionTimeGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDefaultTransitionTimeGet;
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
    return [SigGenericDefaultTransitionTimeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericDefaultTransitionTimeSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDefaultTransitionTimeSet;
    }
    return self;
}

- (instancetype)initWithTransitionTime:(SigTransitionTime *)transitionTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDefaultTransitionTimeSet;
        _transitionTime = transitionTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDefaultTransitionTimeSet;
        if (parameters == nil || (parameters.length != 1)) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        self.transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = self.transitionTime.rawValue;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigGenericDefaultTransitionTimeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericDefaultTransitionTimeSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDefaultTransitionTimeSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithTransitionTime:(SigTransitionTime *)transitionTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDefaultTransitionTimeSetUnacknowledged;
        _transitionTime = transitionTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDefaultTransitionTimeSetUnacknowledged;
        if (parameters == nil || (parameters.length != 1)) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        self.transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = self.transitionTime.rawValue;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigGenericDefaultTransitionTimeStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDefaultTransitionTimeStatus;
    }
    return self;
}

- (instancetype)initWithTransitionTime:(SigTransitionTime *)transitionTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDefaultTransitionTimeStatus;
        _transitionTime = transitionTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericDefaultTransitionTimeStatus;
        if (parameters == nil || (parameters.length != 1)) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        self.transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = self.transitionTime.rawValue;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigGenericOnPowerUpGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnPowerUpGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnPowerUpGet;
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
    return [SigGenericOnPowerUpStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericOnPowerUpStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnPowerUpStatus;
    }
    return self;
}

- (instancetype)initWithState:(SigOnPowerUp)state {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnPowerUpStatus;
        _state = state;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnPowerUpStatus;
        if (parameters == nil || (parameters.length != 1)) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _state = (SigOnPowerUp)tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = self.state;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigGenericOnPowerUpSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnPowerUpSet;
    }
    return self;
}

- (instancetype)initWithState:(SigOnPowerUp)state {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnPowerUpSet;
        _state = state;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnPowerUpSet;
        if (parameters == nil || (parameters.length != 1)) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _state = (SigOnPowerUp)tem;
    }
    return self;
}

- (NSData *)parameters {
    return nil;
}

- (Class)responseType {
    return [SigGenericOnPowerUpStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericOnPowerUpSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnPowerUpSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithState:(SigOnPowerUp)state {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnPowerUpSetUnacknowledged;
        _state = state;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnPowerUpSetUnacknowledged;
        if (parameters == nil || (parameters.length != 1)) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _state = (SigOnPowerUp)tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = self.state;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigGenericPowerLevelGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLevelGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLevelGet;
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
    return [SigGenericPowerLevelStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericPowerLevelSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLevelSet;
    }
    return self;
}

- (instancetype)initWithPower:(UInt16)power {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLevelSet;
        _power = power;
        //v3.2.3后，_transitionTime为nil，默认不带渐变参数。
//        _transitionTime = [[SigTransitionTime alloc] initWithSetps:0 stepResolution:0];
        _delay = 0;
    }
    return self;
}

- (instancetype)initWithPower:(UInt16)power transitionTime:(nullable SigTransitionTime *)transitionTime dalay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLevelSet;
        _power = power;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLevelSet;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }
        UInt16 tem16 = 0;
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _power = tem16;
        memcpy(&tem, dataByte+2, 1);
        self.tid = tem;
        if (parameters.length == 5) {
            memcpy(&tem, dataByte+3, 1);
            _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
            memcpy(&tem, dataByte+4, 1);
            _delay = tem;
        } else {
            _transitionTime = nil;
            _delay = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _power;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigGenericPowerLevelStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericPowerLevelSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLevelSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithPower:(UInt16)power {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLevelSetUnacknowledged;
        _power = power;
        //v3.2.3后，_transitionTime为nil，默认不带渐变参数。
//        _transitionTime = [[SigTransitionTime alloc] initWithSetps:0 stepResolution:0];
        _delay = 0;
    }
    return self;
}

- (instancetype)initWithPower:(UInt16)power transitionTime:(SigTransitionTime *)transitionTime dalay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLevelSetUnacknowledged;
        _power = power;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLevelSetUnacknowledged;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }
        UInt16 tem16 = 0;
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _power = tem16;
        memcpy(&tem, dataByte+2, 1);
        self.tid = tem;
        if (parameters.length == 5) {
            memcpy(&tem, dataByte+3, 1);
            _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
            memcpy(&tem, dataByte+4, 1);
            _delay = tem;
        } else {
            _transitionTime = nil;
            _delay = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _power;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigGenericPowerLevelStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLevelStatus;
    }
    return self;
}

- (instancetype)initWithPower:(UInt16)power {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLevelStatus;
        _power = power;
        _targetPower = 0;
        //v3.2.3后，_transitionTime为nil，默认不带渐变参数。
//        _transitionTime = [[SigTransitionTime alloc] initWithSetps:0 stepResolution:0];
    }
    return self;
}

- (instancetype)initWithPower:(UInt16)power targetPower:(UInt16)targetPower transitionTime:(SigTransitionTime *)transitionTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLevelStatus;
        _power = power;
        _targetPower = targetPower;
        _transitionTime = transitionTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLevelStatus;
        if (parameters == nil || (parameters.length != 2 && parameters.length != 5)) {
            return nil;
        }
        UInt16 tem16 = 0;
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _power = tem16;
        if (parameters.length == 5) {
            memcpy(&tem16, dataByte+2, 2);
            _targetPower = tem16;
            memcpy(&tem, dataByte+4, 1);
            _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
        } else {
            _targetPower = 0;
            _transitionTime = nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _power;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem16 = _targetPower;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        UInt8 tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigGenericPowerLastGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLastGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLastGet;
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
    return [SigGenericPowerLastStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericPowerLastStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLastStatus;
    }
    return self;
}

- (instancetype)initWithPower:(UInt16)power {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLastStatus;
        _power = power;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerLastStatus;
        if (parameters == nil || (parameters.length != 2)) {
            return nil;
        }
        UInt16 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 2);
        _power = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _power;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigGenericPowerDefaultGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerDefaultGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerDefaultGet;
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
    return [SigGenericPowerDefaultStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericPowerDefaultStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerDefaultStatus;
    }
    return self;
}

- (instancetype)initWithPower:(UInt16)power {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerDefaultStatus;
        _power = power;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerDefaultStatus;
        if (parameters == nil || (parameters.length != 2)) {
            return nil;
        }
        UInt16 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 2);
        _power = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _power;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigGenericPowerRangeGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerRangeGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerRangeGet;
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
    return [SigGenericPowerRangeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericPowerRangeStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerRangeStatus;
    }
    return self;
}

- (instancetype)initWithRangeMin:(UInt16)rangeMin rangeMax:(UInt16)rangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerRangeStatus;
        _rangeMin = rangeMin;
        _rangeMax = rangeMax;
    }
    return self;
}

- (instancetype)initWithStatus:(SigGenericMessageStatus)status forSigGenericPowerRangeSetRequest:(SigGenericPowerRangeSet *)request {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerRangeStatus;
        _status = status;
        _rangeMin = request.rangeMin;
        _rangeMax = request.rangeMax;
    }
    return self;
}

- (instancetype)initWithStatus:(SigGenericMessageStatus)status forSigGenericPowerRangeSetUnacknowledgedRequest:(SigGenericPowerRangeSetUnacknowledged *)request {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerRangeStatus;
        _status = status;
        _rangeMin = request.rangeMin;
        _rangeMax = request.rangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerDefaultStatus;
        if (parameters == nil || (parameters.length != 5)) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = (SigGenericMessageStatus)tem8;
        UInt16 tem = 0;
        memcpy(&tem, dataByte+1, 2);
        _rangeMin = tem;
        memcpy(&tem, dataByte+3, 2);
        _rangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _status;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _rangeMin;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _rangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigGenericPowerDefaultSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerDefaultSet;
    }
    return self;
}

- (instancetype)initWithPower:(UInt16)power {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerDefaultSet;
        _power = power;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerDefaultSet;
        if (parameters == nil || (parameters.length != 2)) {
            return nil;
        }
        UInt16 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 2);
        _power = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _power;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigGenericPowerDefaultStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigGenericPowerDefaultSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerDefaultSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithPower:(UInt16)power {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerDefaultSetUnacknowledged;
        _power = power;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerDefaultSetUnacknowledged;
        if (parameters == nil || (parameters.length != 2)) {
            return nil;
        }
        UInt16 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 2);
        _power = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _power;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigGenericPowerRangeSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerRangeSet;
    }
    return self;
}

- (instancetype)initWithRangeMin:(UInt16)rangeMin rangeMax:(UInt16)rangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerRangeSet;
        _rangeMin = rangeMin;
        _rangeMax = rangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerRangeSet;
        if (parameters == nil || (parameters.length != 4)) {
            return nil;
        }
        Byte *dataByte = (Byte *)parameters.bytes;
        UInt16 tem = 0;
        memcpy(&tem, dataByte+0, 2);
        _rangeMin = tem;
        memcpy(&tem, dataByte+2, 2);
        _rangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _rangeMin;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _rangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigGenericPowerRangeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigGenericPowerRangeSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerRangeSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithRangeMin:(UInt16)rangeMin rangeMax:(UInt16)rangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerRangeSetUnacknowledged;
        _rangeMin = rangeMin;
        _rangeMax = rangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericPowerRangeSetUnacknowledged;
        if (parameters == nil || (parameters.length != 4)) {
            return nil;
        }
        Byte *dataByte = (Byte *)parameters.bytes;
        UInt16 tem = 0;
        memcpy(&tem, dataByte+0, 2);
        _rangeMin = tem;
        memcpy(&tem, dataByte+2, 2);
        _rangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _rangeMin;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _rangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigGenericBatteryGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericBatteryGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericBatteryGet;
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
    return [SigGenericBatteryStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigGenericBatteryStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericBatteryStatus;
    }
    return self;
}

- (instancetype)initWithBatteryLevel:(UInt8)batteryLevel timeToDischarge:(UInt32)timeToDischarge andCharge:(UInt32)timeToCharge batteryPresence:(SigBatteryPresence)batteryPresence batteryIndicator:(SigBatteryIndicator)batteryIndicator batteryChargingState:(SigBatteryChargingState)batteryChargingState batteryServiceability:(SigBatteryServiceability)batteryServiceability {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericBatteryStatus;
        _batteryLevel = batteryLevel != 0xFF ? MIN(batteryLevel, 100) : 0xFF;
        _timeToDischarge = timeToDischarge != 0xFFFFFF ? MIN(timeToDischarge, 0xFFFFFE) : 0xFFFFFF;
        _timeToCharge = timeToCharge != 0xFFFFFF ? MIN(timeToCharge, 0xFFFFFE) : 0xFFFFFF;
        _flags = (batteryServiceability << 6) | (batteryChargingState << 4) | (batteryIndicator << 2) | (batteryPresence);
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericBatteryStatus;
        if (parameters == nil || parameters.length != 8) {
            return nil;
        }else{
            UInt8 tem1 = 0;
            UInt8 tem2 = 0;
            UInt8 tem3 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem1, dataByte, 1);
            _batteryLevel = tem1;
            memcpy(&tem1, dataByte+1, 1);
            memcpy(&tem2, dataByte+2, 1);
            memcpy(&tem3, dataByte+3, 1);
            _timeToDischarge = (UInt32)tem1 | ((UInt32)tem2 << 8) |  ((UInt32)tem3 << 16);
            memcpy(&tem1, dataByte+4, 1);
            memcpy(&tem2, dataByte+5, 1);
            memcpy(&tem3, dataByte+6, 1);
            _timeToCharge = (UInt32)tem1 | ((UInt32)tem2 << 8) |  ((UInt32)tem3 << 16);
            memcpy(&tem1, dataByte+7, 1);
            _flags = tem1;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _batteryLevel;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt32 tem = _timeToDischarge;
    data = [NSData dataWithBytes:&tem length:4];
    [mData appendData:[data subdataWithRange:NSMakeRange(0, 3)]];
    tem = _timeToCharge;
    data = [NSData dataWithBytes:&tem length:4];
    [mData appendData:[data subdataWithRange:NSMakeRange(0, 3)]];
    tem8 = _flags;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (BOOL)isBatteryLevelKnown {
    return _batteryLevel != 0xFF;
}

- (BOOL)isTimeToDischargeKnown {
    return _timeToDischarge != 0xFFFFFF;
}

- (BOOL)isTimeToChargeKnown {
    return _timeToCharge != 0xFFFFFF;
}

- (SigBatteryPresence)batteryPresence {
    return (SigBatteryPresence)(_flags & 0x03);
}

- (SigBatteryIndicator)batteryIndicator {
    return (SigBatteryIndicator)((_flags >> 2) & 0x03);
}

- (SigBatteryChargingState)batteryChargingState {
    return (SigBatteryChargingState)((_flags >> 4) & 0x03);
}

- (SigBatteryServiceability)batteryServiceability {
    return (SigBatteryServiceability)((_flags >> 6) & 0x03);
}

@end


@implementation SigSensorDescriptorGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorDescriptorGet;
    }
    return self;
}

- (instancetype)initWithPropertyID:(UInt16)propertyID {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorDescriptorGet;
        _propertyID = propertyID;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorDescriptorGet;
        if ((parameters == nil || parameters.length == 0) || (parameters != nil && parameters.length == 2)) {
            if (parameters != nil) {
                UInt16 tem16 = 0;
                Byte *dataByte = (Byte *)parameters.bytes;
                memcpy(&tem16, dataByte, 2);
                _propertyID = tem16;
            }
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    if (_propertyID != 0) {
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = _propertyID;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        return mData;
    } else {
        return nil;
    }
}

- (Class)responseType {
    return [SigSensorDescriptorStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigSensorDescriptorStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorDescriptorStatus;
        _descriptorModels = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorDescriptorStatus;
        if (parameters != nil && (parameters.length == 2 || parameters.length % 8 == 0)) {
            _descriptorModels = [NSMutableArray array];
            if (parameters.length == 2) {
                [_descriptorModels addObject:[[SigSensorDescriptorModel alloc] initWithDescriptorParameters:parameters]];
            } else {
                for (int i=0; i<parameters.length/8; i++) {
                    [_descriptorModels addObject:[[SigSensorDescriptorModel alloc] initWithDescriptorParameters:[parameters subdataWithRange:NSMakeRange(i*8, 8)]]];
                }
            }
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    NSArray *descriptorModels = [NSArray arrayWithArray:_descriptorModels];
    for (SigSensorDescriptorModel *model in descriptorModels) {
        [mData appendData:model.getDescriptorParameters];
    }
    return mData;
}

@end


@implementation SigSensorGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorGet;
    }
    return self;
}

- (instancetype)initWithPropertyID:(UInt16)propertyID {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorGet;
        _propertyID = propertyID;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorGet;
        if ((parameters == nil || parameters.length == 0) || (parameters != nil && parameters.length == 2)) {
            if (parameters != nil) {
                UInt16 tem16 = 0;
                Byte *dataByte = (Byte *)parameters.bytes;
                memcpy(&tem16, dataByte, 2);
                _propertyID = tem16;
            }
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    if (_propertyID != 0) {
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = _propertyID;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        return mData;
    } else {
        return nil;
    }
}

- (Class)responseType {
    return [SigSensorStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigSensorStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorStatus;
        _marshalledSensorData = parameters;
    }
    return self;
}

- (NSData *)parameters {
    return _marshalledSensorData;
}

@end


@implementation SigSensorColumnGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorColumnGet;
    }
    return self;
}

- (instancetype)initWithPropertyID:(UInt16)propertyID rawValueX:(NSData *)rawValueX {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorColumnGet;
        _propertyID = propertyID;
        _rawValueX = rawValueX;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorCadenceGet;
        if ((parameters == nil || parameters.length == 0) || (parameters != nil && parameters.length > 2)) {
            if (parameters != nil) {
                UInt16 tem16 = 0;
                Byte *dataByte = (Byte *)parameters.bytes;
                memcpy(&tem16, dataByte, 2);
                _propertyID = tem16;
                _rawValueX = [parameters subdataWithRange:NSMakeRange(2, parameters.length - 2)];
            }
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    if (_propertyID != 0) {
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = _propertyID;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        [mData appendData:_rawValueX];
        return mData;
    } else {
        return nil;
    }
}

- (Class)responseType {
    return [SigSensorColumnStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigSensorColumnStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorColumnStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorColumnStatus;
        _columnData = parameters;
    }
    return self;
}

- (NSData *)parameters {
    return _columnData;
}

@end


@implementation SigSensorSeriesGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSeriesGet;
    }
    return self;
}

- (instancetype)initWithPropertyID:(UInt16)propertyID rawValueX1Data:(NSData *)rawValueX1Data rawValueX2Data:(NSData *)rawValueX2Data {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSeriesGet;
        _propertyID = propertyID;
        _rawValueX1Data = rawValueX1Data;
        _rawValueX2Data = rawValueX2Data;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSeriesGet;
        if (parameters != nil && parameters.length >= 2) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _propertyID = tem16;
            _seriesData = parameters;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return _seriesData;
//    if (_propertyID != 0) {
//        NSMutableData *mData = [NSMutableData data];
//        UInt16 tem16 = _propertyID;
//        NSData *data = [NSData dataWithBytes:&tem16 length:2];
//        [mData appendData:data];
//        return mData;
//    } else {
//        return nil;
//    }
}

- (Class)responseType {
    return [SigSensorSeriesStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigSensorSeriesStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSeriesStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSeriesStatus;
        _seriesData = parameters;
    }
    return self;
}

- (NSData *)parameters {
    return _seriesData;
}

@end


@implementation SigSensorCadenceGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorCadenceSet;
    }
    return self;
}

- (instancetype)initWithPropertyID:(UInt16)propertyID {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorCadenceSet;
        _propertyID = propertyID;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorCadenceSet;
        if (parameters != nil && parameters.length >= 2) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _propertyID = tem16;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    if (_propertyID != 0) {
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = _propertyID;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        return mData;
    } else {
        return nil;
    }
}

- (Class)responseType {
    return [SigSensorCadenceStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigSensorCadenceSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorCadenceSet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorCadenceSet;
        if (parameters != nil && parameters.length >= 2) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _propertyID = tem16;
            _cadenceData = parameters;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return _cadenceData;
//    if (_propertyID != 0) {
//        NSMutableData *mData = [NSMutableData data];
//        UInt16 tem16 = _propertyID;
//        NSData *data = [NSData dataWithBytes:&tem16 length:2];
//        [mData appendData:data];
//        return mData;
//    } else {
//        return nil;
//    }
}

- (Class)responseType {
    return [SigSensorCadenceStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigSensorCadenceSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorCadenceSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorCadenceSetUnacknowledged;
        if (parameters != nil && parameters.length >= 2) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _propertyID = tem16;
            _cadenceData = parameters;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return _cadenceData;
//    if (_propertyID != 0) {
//        NSMutableData *mData = [NSMutableData data];
//        UInt16 tem16 = _propertyID;
//        NSData *data = [NSData dataWithBytes:&tem16 length:2];
//        [mData appendData:data];
//        return mData;
//    } else {
//        return nil;
//    }
}

@end


@implementation SigSensorCadenceStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorCadenceStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorCadenceStatus;
        if (parameters != nil && parameters.length >= 2) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _propertyID = tem16;
            _cadenceData = parameters;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return _cadenceData;
//    if (_propertyID != 0) {
//        NSMutableData *mData = [NSMutableData data];
//        UInt16 tem16 = _propertyID;
//        NSData *data = [NSData dataWithBytes:&tem16 length:2];
//        [mData appendData:data];
//        return mData;
//    } else {
//        return nil;
//    }
}

@end


@implementation SigSensorSettingsGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingsGet;
    }
    return self;
}

- (instancetype)initWithPropertyID:(UInt16)propertyID {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingsGet;
        _propertyID = propertyID;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingsGet;
        if (parameters != nil && parameters.length >= 2) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _propertyID = tem16;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    if (_propertyID != 0) {
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = _propertyID;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        return mData;
    } else {
        return nil;
    }
}

- (Class)responseType {
    return [SigSensorSettingsStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigSensorSettingsStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingsStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingsStatus;
        if (parameters != nil && parameters.length >= 2) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _propertyID = tem16;
            _settingsData = parameters;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    return _settingsData;
//    if (_propertyID != 0) {
//        NSMutableData *mData = [NSMutableData data];
//        UInt16 tem16 = _propertyID;
//        NSData *data = [NSData dataWithBytes:&tem16 length:2];
//        [mData appendData:data];
//        return mData;
//    } else {
//        return nil;
//    }
}

@end


@implementation SigSensorSettingGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingGet;
    }
    return self;
}

- (instancetype)initWithPropertyID:(UInt16)propertyID settingPropertyID:(UInt16)settingPropertyID {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingGet;
        _propertyID = propertyID;
        _settingPropertyID = settingPropertyID;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingGet;
        if (parameters != nil && parameters.length >= 2) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _propertyID = tem16;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    if (_propertyID != 0) {
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = _propertyID;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        return mData;
    } else {
        return nil;
    }
}

- (Class)responseType {
    return [SigSensorSettingStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigSensorSettingSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingSet;
    }
    return self;
}

- (instancetype)initWithPropertyID:(UInt16)propertyID settingPropertyID:(UInt16)settingPropertyID settingRaw:(NSData *)settingRaw {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingSet;
        _propertyID = propertyID;
        _settingPropertyID = settingPropertyID;
        _settingRaw = settingRaw;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingSet;
        if (parameters != nil && parameters.length >= 4) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _propertyID = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _settingPropertyID = tem16;
            _settingRaw = [parameters subdataWithRange:NSMakeRange(4, parameters.length-4)];
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    if (_propertyID != 0) {
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = _propertyID;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = _settingPropertyID;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        [mData appendData:_settingRaw];
        return mData;
    } else {
        return nil;
    }
}

- (Class)responseType {
    return [SigSensorSettingStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigSensorSettingSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithPropertyID:(UInt16)propertyID settingPropertyID:(UInt16)settingPropertyID settingRaw:(NSData *)settingRaw {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingSetUnacknowledged;
        _propertyID = propertyID;
        _settingPropertyID = settingPropertyID;
        _settingRaw = settingRaw;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingSetUnacknowledged;
        if (parameters != nil && parameters.length >= 4) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _propertyID = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _settingPropertyID = tem16;
            _settingRaw = [parameters subdataWithRange:NSMakeRange(4, parameters.length-4)];
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    if (_propertyID != 0) {
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = _propertyID;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = _settingPropertyID;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        [mData appendData:_settingRaw];
        return mData;
    } else {
        return nil;
    }
}

@end


@implementation SigSensorSettingStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingStatus;
    }
    return self;
}

- (instancetype)initWithPropertyID:(UInt16)propertyID settingPropertyID:(UInt16)settingPropertyID settingAccess:(SigSensorSettingAccessType)settingAccess settingRaw:(NSData *)settingRaw {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingStatus;
        _propertyID = propertyID;
        _settingPropertyID = settingPropertyID;
        _settingAccess = settingAccess;
        _settingRaw = settingRaw;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sensorSettingStatus;
        if (parameters != nil && parameters.length >= 5) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _propertyID = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _settingPropertyID = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+4, 1);
            _settingAccess = tem8;
            _settingRaw = [parameters subdataWithRange:NSMakeRange(5, parameters.length-5)];
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    if (_propertyID != 0) {
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = _propertyID;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = _settingPropertyID;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        UInt8 tem8 = _settingAccess;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        [mData appendData:_settingRaw];
        return mData;
    } else {
        return nil;
    }
}

@end


@implementation SigTimeGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeGet;
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
    return [SigTimeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigTimeSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeSet;
    }
    return self;
}

- (instancetype)initWithTimeModel:(SigTimeModel *)timeModel {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeSet;
        _timeModel = timeModel;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeSet;
        if (parameters == nil || parameters.length != 10) {
            return nil;
        }else{
            _timeModel = [[SigTimeModel alloc] initWithParameters:parameters];
        }
    }
    return self;
}

- (NSData *)parameters {
    return _timeModel.getTimeParameters;
}

- (Class)responseType {
    return [SigTimeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigTimeStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeStatus;
        if (parameters == nil || parameters.length != 10) {
            return nil;
        }else{
            _timeModel = [[SigTimeModel alloc] initWithParameters:parameters];
        }
    }
    return self;
}

- (NSData *)parameters {
    return _timeModel.getTimeParameters;
}

@end


@implementation SigTimeRoleGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeRoleGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeRoleGet;
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
    return [SigTimeRoleStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigTimeRoleSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeRoleSet;
    }
    return self;
}

- (instancetype)initWithTimeRole:(SigTimeRole)timeRole {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeRoleSet;
        _timeRole = timeRole;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeRoleSet;
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }else{
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            _timeRole = (SigTimeRole)tem8;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _timeRole;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigTimeRoleStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigTimeRoleStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeRoleStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeRoleStatus;
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }else{
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            _timeRole = (SigTimeRole)tem8;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _timeRole;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigTimeZoneGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeZoneGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeZoneGet;
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
    return [SigTimeZoneStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigTimeZoneSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeZoneSet;
    }
    return self;
}

- (instancetype)initWithTimeZoneOffsetNew:(UInt8)timeZoneOffsetNew TAIOfZoneChange:(UInt64)TAIOfZoneChange {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeZoneSet;
        _timeZoneOffsetNew = timeZoneOffsetNew;
        _TAIOfZoneChange = TAIOfZoneChange;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeZoneSet;
        if (parameters == nil || parameters.length != 6) {
            return nil;
        }else{
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            _timeZoneOffsetNew = tem8;
            UInt64 tem64 = 0;
            memcpy(&tem64, dataByte+1, 5);
            _TAIOfZoneChange = tem64;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _timeZoneOffsetNew;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt64 tem64 = _TAIOfZoneChange & 0xFFFFFFFFFF;
    data = [NSData dataWithBytes:&tem64 length:5];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigTimeRoleStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigTimeZoneStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeZoneStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_timeZoneStatus;
        if (parameters == nil || parameters.length != 7) {
            return nil;
        }else{
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            _timeZoneOffsetCurrent = tem8;
            memcpy(&tem8, dataByte+1, 1);
            _timeZoneOffsetNew = tem8;
            UInt64 tem64 = 0;
            memcpy(&tem64, dataByte+2, 5);
            _TAIOfZoneChange = tem64;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _timeZoneOffsetCurrent;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _timeZoneOffsetNew;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt64 tem64 = _TAIOfZoneChange & 0xFFFFFFFFFF;
    data = [NSData dataWithBytes:&tem64 length:5];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigTAI_UTC_DeltaGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_TAI_UTC_DeltaGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_TAI_UTC_DeltaGet;
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
    return [SigTAI_UTC_DeltaStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigTAI_UTC_DeltaSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_TAI_UTC_DeltaSet;
    }
    return self;
}

- (instancetype)initWithTAI_UTC_DeltaNew:(UInt16)TAI_UTC_DeltaNew padding:(UInt8)padding TAIOfDeltaChange:(UInt64)TAIOfDeltaChange {
    if (self = [super init]) {
        self.opCode = SigOpCode_TAI_UTC_DeltaSet;
        _TAI_UTC_DeltaNew = TAI_UTC_DeltaNew;
        _padding = padding;
        _TAIOfDeltaChange = TAIOfDeltaChange;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_TAI_UTC_DeltaSet;
        if (parameters == nil || parameters.length != 7) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _TAI_UTC_DeltaNew = (tem16 >> 1) & 0x7FFF;
            _padding = tem16 & 0b1;
            UInt64 tem64 = 0;
            memcpy(&tem64, dataByte+2, 5);
            _TAIOfDeltaChange = tem64;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = ((_TAI_UTC_DeltaNew & 0x7FFF) << 1) | (_padding & 0b1);
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt64 tem64 = _TAIOfDeltaChange & 0xFFFFFFFFFF;
    data = [NSData dataWithBytes:&tem64 length:5];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigTAI_UTC_DeltaStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigTAI_UTC_DeltaStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_TAI_UTC_DeltaStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_TAI_UTC_DeltaStatus;
        if (parameters == nil || parameters.length != 9) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _TAI_UTC_DeltaCurrent = (tem16 >> 1) & 0x7FFF;
            _paddingCurrent = tem16 & 0b1;
            memcpy(&tem16, dataByte+2, 2);
            _TAI_UTC_DeltaNew = (tem16 >> 1) & 0x7FFF;
            _paddingNew = tem16 & 0b1;
            UInt64 tem64 = 0;
            memcpy(&tem64, dataByte+4, 5);
            _TAIOfDeltaChange = tem64;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = ((_TAI_UTC_DeltaCurrent & 0x7FFF) << 1) | (_paddingCurrent & 0b1);
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = ((_TAI_UTC_DeltaNew & 0x7FFF) << 1) | (_paddingNew & 0b1);
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt64 tem64 = _TAIOfDeltaChange & 0xFFFFFFFFFF;
    data = [NSData dataWithBytes:&tem64 length:5];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigSceneGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneGet;
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
    return [SigSceneStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigSceneRecall

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneRecall;
    }
    return self;
}

- (instancetype)initWithSceneNumber:(UInt16)sceneNumber transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneRecall;
        _sceneNumber = sceneNumber;
        _transitionTime = transitionTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneRecall;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _sceneNumber = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+2, 1);
            self.tid = tem8;
            if (parameters.length == 5) {
                memcpy(&tem8, dataByte+3, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+4, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _sceneNumber;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigSceneStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigSceneRecallUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneRecallUnacknowledged;
    }
    return self;
}

- (instancetype)initWithSceneNumber:(UInt16)sceneNumber transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneRecallUnacknowledged;
        _sceneNumber = sceneNumber;
        _transitionTime = transitionTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneRecallUnacknowledged;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _sceneNumber = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+2, 1);
            self.tid = tem8;
            if (parameters.length == 5) {
                memcpy(&tem8, dataByte+3, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+4, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _sceneNumber;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigSceneStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneStatus;
    }
    return self;
}

- (instancetype)initWithStatusCode:(SigSceneResponseStatus)statusCode currentScene:(UInt16)currentScene targetScene:(UInt16)targetScene remainingTime:(SigTransitionTime *)remainingTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneStatus;
        _currentScene = currentScene;
        _targetScene = targetScene;
        _remainingTime = remainingTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneStatus;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 6)) {
            return nil;
        }else{
            Byte *dataByte = (Byte *)parameters.bytes;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte, 1);
            _statusCode = (SigSceneResponseStatus)tem8;
            UInt16 tem16 = 0;
            memcpy(&tem16, dataByte+1, 2);
            _currentScene = tem16;
            if (parameters.length == 6) {
                memcpy(&tem16, dataByte+3, 2);
                _targetScene = tem16;
                memcpy(&tem8, dataByte+5, 1);
                _remainingTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _statusCode;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _currentScene;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_remainingTime != nil) {
        tem16 = _targetScene;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem8 = _remainingTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigSceneRegisterGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneRegisterGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneRegisterGet;
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
    return [SigSceneRegisterStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigSceneRegisterStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneRegisterStatus;
    }
    return self;
}

- (instancetype)initWithStatusCode:(SigSceneResponseStatus)statusCode currentScene:(UInt16)currentScene targetScene:(UInt16)targetScene scenes:(NSMutableArray <NSNumber *>*)scenes {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneRegisterStatus;
        _statusCode = statusCode;
        _currentScene = currentScene;
        _scenes = [NSMutableArray arrayWithArray:scenes];
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneRegisterStatus;
        if (parameters == nil || (parameters.length < 3)) {
            return nil;
        }else{
            Byte *dataByte = (Byte *)parameters.bytes;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte, 1);
            _statusCode = (SigSceneResponseStatus)tem8;
            UInt16 tem16 = 0;
            memcpy(&tem16, dataByte+1, 2);
            _currentScene = tem16;
            if (_scenes == nil) {
                _scenes = [NSMutableArray array];
            }
            while (parameters.length >= 3+(2*(_scenes.count + 1))) {
                memcpy(&tem16, dataByte+3+2*_scenes.count, 2);
                [_scenes addObject:@(tem16)];
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _statusCode;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _currentScene;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_scenes != nil && _scenes.count != 0) {
        for (int i=0; i<_scenes.count; i++) {
            tem16 = [_scenes[i] intValue];
            data = [NSData dataWithBytes:&tem16 length:2];
            [mData appendData:data];
        }
    }
    return mData;
}

@end


@implementation SigSceneStore

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneStore;
    }
    return self;
}

- (instancetype)initWithSceneNumber:(UInt16)sceneNumber {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneStore;
        _sceneNumber = sceneNumber;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneStore;
        if (parameters == nil || (parameters.length != 2)) {
            return nil;
        }else{
            Byte *dataByte = (Byte *)parameters.bytes;
            UInt16 tem16 = 0;
            memcpy(&tem16, dataByte, 2);
            _sceneNumber = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _sceneNumber;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigSceneRegisterStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigSceneStoreUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneStoreUnacknowledged;
    }
    return self;
}

- (instancetype)initWithSceneNumber:(UInt16)sceneNumber {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneStoreUnacknowledged;
        _sceneNumber = sceneNumber;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneStoreUnacknowledged;
        if (parameters == nil || (parameters.length != 2)) {
            return nil;
        }else{
            Byte *dataByte = (Byte *)parameters.bytes;
            UInt16 tem16 = 0;
            memcpy(&tem16, dataByte, 2);
            _sceneNumber = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _sceneNumber;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigSceneDelete

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneDelete;
    }
    return self;
}

- (instancetype)initWithSceneNumber:(UInt16)sceneNumber {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneDelete;
        _sceneNumber = sceneNumber;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneDelete;
        if (parameters == nil || (parameters.length != 2)) {
            return nil;
        }else{
            Byte *dataByte = (Byte *)parameters.bytes;
            UInt16 tem16 = 0;
            memcpy(&tem16, dataByte, 2);
            _sceneNumber = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _sceneNumber;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigSceneRegisterStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigSceneDeleteUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneDeleteUnacknowledged;
    }
    return self;
}

- (instancetype)initWithSceneNumber:(UInt16)sceneNumber {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneDeleteUnacknowledged;
        _sceneNumber = sceneNumber;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_sceneDeleteUnacknowledged;
        if (parameters == nil || (parameters.length != 2)) {
            return nil;
        }else{
            Byte *dataByte = (Byte *)parameters.bytes;
            UInt16 tem16 = 0;
            memcpy(&tem16, dataByte, 2);
            _sceneNumber = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _sceneNumber;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigSchedulerActionGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerActionGet;
    }
    return self;
}

- (instancetype)initWithIndex:(UInt8)index {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerActionGet;
        _index = index;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerActionGet;
        if (parameters == nil || (parameters.length != 1)) {
            return nil;
        }else{
            Byte *dataByte = (Byte *)parameters.bytes;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte, 1);
            _index = tem8;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _index;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigSchedulerActionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigSchedulerActionStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerActionStatus;
    }
    return self;
}

- (instancetype)initWithSchedulerModel:(SchedulerModel *)schedulerModel {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerActionStatus;
        _schedulerModel = schedulerModel;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerActionStatus;
        if (parameters == nil || (parameters.length != 10)) {
            return nil;
        }else{
            SchedulerModel *model = [[SchedulerModel alloc] init];
            Byte *dataByte = (Byte *)parameters.bytes;
            UInt64 tem64 = 0;
            memcpy(&tem64, dataByte, 8);
            [model setSchedulerData:tem64];
            UInt16 tem16 = 0;
            memcpy(&tem16, dataByte+8, 2);
            model.sceneId = tem16;
            _schedulerModel = model;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt64 tem64 = _schedulerModel.schedulerData;
    NSData *data = [NSData dataWithBytes:&tem64 length:8];
    [mData appendData:data];
    UInt16 tem16 = _schedulerModel.sceneId;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigSchedulerGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigSchedulerStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigSchedulerStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerStatus;
        _schedulers = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithSchedulers:(NSMutableArray <NSNumber *>*)schedulers {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerStatus;
        _schedulers = [NSMutableArray arrayWithArray:schedulers];
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerStatus;
        if (parameters == nil || (parameters.length != 2)) {
            return nil;
        }else{
            NSMutableArray *array = [NSMutableArray array];
            Byte *dataByte = (Byte *)parameters.bytes;
            UInt16 tem16 = 0;
            memcpy(&tem16, dataByte, 2);
            for (int i=0; i<0xF; i++) {
                if (((tem16 >> i) & 0b1) == 1) {
                    [array addObject:@(0xF-i)];
                }
            }
            _schedulers = array;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = 0;
    NSArray *schedulers = [NSArray arrayWithArray:_schedulers];
    for (NSNumber *num in schedulers) {
        UInt16 schedulerID = (UInt16)num.intValue;
        tem16 |= (1 << (0xF-schedulerID));
    }
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigSchedulerActionSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerActionSet;
    }
    return self;
}

- (instancetype)initWithSchedulerModel:(SchedulerModel *)schedulerModel {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerActionSet;
        _schedulerModel = schedulerModel;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerActionSet;
        if (parameters == nil || (parameters.length != 10)) {
            return nil;
        }else{
            SchedulerModel *model = [[SchedulerModel alloc] init];
            Byte *dataByte = (Byte *)parameters.bytes;
            UInt64 tem64 = 0;
            memcpy(&tem64, dataByte, 8);
            [model setSchedulerData:tem64];
            UInt16 tem16 = 0;
            memcpy(&tem16, dataByte+8, 2);
            model.sceneId = tem16;
            _schedulerModel = model;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt64 tem64 = _schedulerModel.schedulerData;
    NSData *data = [NSData dataWithBytes:&tem64 length:8];
    [mData appendData:data];
    UInt16 tem16 = _schedulerModel.sceneId;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigSchedulerActionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigSchedulerActionSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerActionSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithSchedulerModel:(SchedulerModel *)schedulerModel {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerActionSetUnacknowledged;
        _schedulerModel = schedulerModel;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_schedulerActionSetUnacknowledged;
        if (parameters == nil || (parameters.length != 10)) {
            return nil;
        }else{
            SchedulerModel *model = [[SchedulerModel alloc] init];
            Byte *dataByte = (Byte *)parameters.bytes;
            UInt64 tem64 = 0;
            memcpy(&tem64, dataByte, 8);
            [model setSchedulerData:tem64];
            UInt16 tem16 = 0;
            memcpy(&tem16, dataByte+8, 2);
            model.sceneId = tem16;
            _schedulerModel = model;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt64 tem64 = _schedulerModel.schedulerData;
    NSData *data = [NSData dataWithBytes:&tem64 length:8];
    [mData appendData:data];
    UInt16 tem16 = _schedulerModel.sceneId;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightLightnessGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightLightnessStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightLightnessSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessSet;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessSet;
        _lightness = lightness;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessSet;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+2, 1);
            self.tid = tem8;
            if (parameters.length == 5) {
                memcpy(&tem8, dataByte+3, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+4, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigLightLightnessStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightLightnessSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessSetUnacknowledged;
        _lightness = lightness;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessSetUnacknowledged;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+2, 1);
            self.tid = tem8;
            if (parameters.length == 5) {
                memcpy(&tem8, dataByte+3, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+4, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigLightLightnessStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessStatus;
    }
    return self;
}

- (instancetype)initWithPresentLightness:(UInt16)presentLightness targetLightness:(UInt16)targetLightness remainingTime:(SigTransitionTime *)remainingTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessStatus;
        _presentLightness = presentLightness;
        _targetLightness = targetLightness;
        _remainingTime = remainingTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessStatus;
        if (parameters == nil || (parameters.length != 2 && parameters.length != 5)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _presentLightness = tem16;
            if (parameters.length == 5) {
                memcpy(&tem16, dataByte+2, 2);
                _targetLightness = tem16;
                UInt8 tem8 = 0;
                memcpy(&tem8, dataByte+4, 1);
                _remainingTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _presentLightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_remainingTime != nil) {
        tem16 = _targetLightness;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        UInt8 tem8 = _remainingTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigLightLightnessLinearGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLinearGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLinearGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightLightnessLinearStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightLightnessLinearSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLinearSet;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLinearSet;
        _lightness = lightness;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLinearSet;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+2, 1);
            self.tid = tem8;
            if (parameters.length == 5) {
                memcpy(&tem8, dataByte+3, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+4, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
//v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigLightLightnessLinearStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightLightnessLinearSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLinearSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLinearSetUnacknowledged;
        _lightness = lightness;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLinearSetUnacknowledged;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+2, 1);
            self.tid = tem8;
            if (parameters.length == 5) {
                memcpy(&tem8, dataByte+3, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+4, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigLightLightnessLinearStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLinearStatus;
    }
    return self;
}

- (instancetype)initWithPresentLightness:(UInt16)presentLightness targetLightness:(UInt16)targetLightness remainingTime:(SigTransitionTime *)remainingTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLinearStatus;
        _presentLightness = presentLightness;
        _targetLightness = targetLightness;
        _remainingTime = remainingTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLinearStatus;
        if (parameters == nil || (parameters.length != 2 && parameters.length != 5)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _presentLightness = tem16;
            if (parameters.length == 5) {
                memcpy(&tem16, dataByte+2, 2);
                _targetLightness = tem16;
                UInt8 tem8 = 0;
                memcpy(&tem8, dataByte+4, 1);
                _remainingTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _presentLightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_remainingTime != nil) {
        tem16 = _targetLightness;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        UInt8 tem8 = _remainingTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigLightLightnessLastGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLastGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLastGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightLightnessLastStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightLightnessLastStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLastStatus;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLastStatus;
        _lightness = lightness;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessLastStatus;
        if (parameters == nil || (parameters.length != 2)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightLightnessDefaultGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessDefaultGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessDefaultGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightLightnessDefaultStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightLightnessDefaultStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessDefaultStatus;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessDefaultStatus;
        _lightness = lightness;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessDefaultStatus;
        if (parameters == nil || (parameters.length != 2)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightLightnessRangeGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessRangeGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessRangeGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightLightnessRangeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightLightnessRangeStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessRangeStatus;
    }
    return self;
}

- (instancetype)initWithRangeMin:(UInt16)rangeMin rangeMax:(UInt16)rangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessRangeStatus;
        _rangeMin = rangeMin;
        _rangeMax = rangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessRangeStatus;
        if (parameters == nil || (parameters.length != 5)) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _statusCode = (SigGenericMessageStatus)tem8;
        UInt16 tem = 0;
        memcpy(&tem, dataByte+1, 2);
        _rangeMin = tem;
        memcpy(&tem, dataByte+3, 2);
        _rangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _statusCode;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _rangeMin;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _rangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightLightnessDefaultSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessDefaultSet;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessDefaultSet;
        _lightness = lightness;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessDefaultSet;
        if (parameters == nil || (parameters.length != 2)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigLightLightnessDefaultStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightLightnessDefaultSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessDefaultSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessDefaultSetUnacknowledged;
        _lightness = lightness;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessDefaultSetUnacknowledged;
        if (parameters == nil || (parameters.length != 2)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightLightnessRangeSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessRangeSet;
    }
    return self;
}

- (instancetype)initWithRangeMin:(UInt16)rangeMin rangeMax:(UInt16)rangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessRangeSet;
        _rangeMin = rangeMin;
        _rangeMax = rangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessRangeSet;
        if (parameters == nil || (parameters.length != 4)) {
            return nil;
        }
        Byte *dataByte = (Byte *)parameters.bytes;
        UInt16 tem = 0;
        memcpy(&tem, dataByte+0, 2);
        _rangeMin = tem;
        memcpy(&tem, dataByte+2, 2);
        _rangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _rangeMin;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _rangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigLightLightnessRangeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightLightnessRangeSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessRangeSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithRangeMin:(UInt16)rangeMin rangeMax:(UInt16)rangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessRangeSetUnacknowledged;
        _rangeMin = rangeMin;
        _rangeMax = rangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightLightnessRangeSetUnacknowledged;
        if (parameters == nil || (parameters.length != 4)) {
            return nil;
        }
        Byte *dataByte = (Byte *)parameters.bytes;
        UInt16 tem = 0;
        memcpy(&tem, dataByte+0, 2);
        _rangeMin = tem;
        memcpy(&tem, dataByte+2, 2);
        _rangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _rangeMin;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _rangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightCTLGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightCTLStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightCTLSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLSet;
    }
    return self;
}

- (instancetype)initWithCTLLightness:(UInt16)CTLLightness CTLTemperature:(UInt16)CTLTemperature CTLDeltaUV:(UInt16)CTLDeltaUV transitionTime:(SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLSet;
        _CTLLightness = CTLLightness;
        _CTLTemperature = CTLTemperature;
        _CTLDeltaUV = CTLDeltaUV;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLSet;
        if (parameters == nil || (parameters.length != 7 && parameters.length != 9)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _CTLLightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _CTLTemperature = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _CTLDeltaUV = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+6, 1);
            self.tid = tem8;
            if (parameters.length == 9) {
                memcpy(&tem8, dataByte+7, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+8, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _CTLLightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _CTLTemperature;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _CTLDeltaUV;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigLightCTLStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightCTLSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithCTLLightness:(UInt16)CTLLightness CTLTemperature:(UInt16)CTLTemperature CTLDeltaUV:(UInt16)CTLDeltaUV transitionTime:(SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLSetUnacknowledged;
        _CTLLightness = CTLLightness;
        _CTLTemperature = CTLTemperature;
        _CTLDeltaUV = CTLDeltaUV;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLSetUnacknowledged;
        if (parameters == nil || (parameters.length != 7 && parameters.length != 9)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _CTLLightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _CTLTemperature = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _CTLDeltaUV = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+6, 1);
            self.tid = tem8;
            if (parameters.length == 9) {
                memcpy(&tem8, dataByte+7, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+8, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _CTLLightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _CTLTemperature;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _CTLDeltaUV;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigLightCTLStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLStatus;
    }
    return self;
}

- (instancetype)initWithPresentCTLLightness:(UInt16)presentCTLLightness presentCTLTemperature:(UInt16)presentCTLTemperature targetCTLLightness:(UInt16)targetCTLLightness targetCTLTemperature:(UInt16)targetCTLTemperature remainingTime:(SigTransitionTime * _Nullable )remainingTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLStatus;
        _presentCTLLightness = presentCTLLightness;
        _presentCTLTemperature = presentCTLTemperature;
        _targetCTLLightness = targetCTLLightness;
        _targetCTLTemperature = targetCTLTemperature;
        _remainingTime = remainingTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLStatus;
        if (parameters == nil || (parameters.length != 4 && parameters.length != 9)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _presentCTLLightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _presentCTLTemperature = tem16;
            if (parameters.length == 9) {
                memcpy(&tem16, dataByte+4, 2);
                _targetCTLLightness = tem16;
                memcpy(&tem16, dataByte+6, 2);
                _targetCTLTemperature = tem16;
                UInt8 tem8 = 0;
                memcpy(&tem8, dataByte+8, 1);
                _remainingTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _presentCTLLightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _presentCTLTemperature;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_remainingTime != nil) {
        tem16 = _targetCTLLightness;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = _targetCTLTemperature;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        UInt8 tem8 = _remainingTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigLightCTLTemperatureGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightCTLTemperatureStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightCTLTemperatureRangeGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureRangeGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureRangeGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightCTLTemperatureRangeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightCTLTemperatureRangeStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureRangeStatus;
    }
    return self;
}

- (instancetype)initWithStatusCode:(SigGenericMessageStatus)statusCode rangeMin:(UInt16)rangeMin rangeMax:(UInt16)rangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureRangeStatus;
        _statusCode = statusCode;
        _rangeMin = rangeMin;
        _rangeMax = rangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureRangeStatus;
        if (parameters == nil || (parameters.length != 5)) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _statusCode = (SigGenericMessageStatus)tem8;
        UInt16 tem = 0;
        memcpy(&tem, dataByte+1, 2);
        _rangeMin = tem;
        memcpy(&tem, dataByte+3, 2);
        _rangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _statusCode;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _rangeMin;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _rangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightCTLTemperatureSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureSet;
    }
    return self;
}

- (instancetype)initWithCTLTemperature:(UInt16)CTLTemperature CTLDeltaUV:(UInt16)CTLDeltaUV transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureSet;
        _CTLTemperature = CTLTemperature;
        _CTLDeltaUV = CTLDeltaUV;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureSet;
        if (parameters == nil || (parameters.length != 5 && parameters.length != 7)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _CTLTemperature = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _CTLDeltaUV = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+4, 1);
            self.tid = tem8;
            if (parameters.length == 7) {
                memcpy(&tem8, dataByte+5, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+6, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _CTLTemperature;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _CTLDeltaUV;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigLightCTLTemperatureStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightCTLTemperatureSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithCTLTemperature:(UInt16)CTLTemperature CTLDeltaUV:(UInt16)CTLDeltaUV transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureSetUnacknowledged;
        _CTLTemperature = CTLTemperature;
        _CTLDeltaUV = CTLDeltaUV;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureSetUnacknowledged;
        if (parameters == nil || (parameters.length != 5 && parameters.length != 7)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _CTLTemperature = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _CTLDeltaUV = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+4, 1);
            self.tid = tem8;
            if (parameters.length == 7) {
                memcpy(&tem8, dataByte+5, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+6, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _CTLTemperature;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _CTLDeltaUV;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigLightCTLTemperatureStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureStatus;
    }
    return self;
}

- (instancetype)initWithPresentCTLTemperature:(UInt16)presentCTLTemperature presentCTLDeltaUV:(UInt16)presentCTLDeltaUV targetCTLTemperature:(UInt16)targetCTLTemperature targetCTLDeltaUV:(UInt16)targetCTLDeltaUV remainingTime:(SigTransitionTime *)remainingTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureStatus;
        _presentCTLTemperature = presentCTLTemperature;
        _presentCTLDeltaUV = presentCTLDeltaUV;
        _targetCTLTemperature = targetCTLTemperature;
        _targetCTLDeltaUV = targetCTLDeltaUV;
        _remainingTime = remainingTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureStatus;
        if (parameters == nil || (parameters.length != 4 && parameters.length != 9)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _presentCTLTemperature = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _presentCTLDeltaUV = tem16;
            if (parameters.length == 9) {
                memcpy(&tem16, dataByte+4, 2);
                _targetCTLTemperature = tem16;
                memcpy(&tem16, dataByte+6, 2);
                _targetCTLDeltaUV = tem16;
                UInt8 tem8 = 0;
                memcpy(&tem8, dataByte+8, 1);
                _remainingTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _presentCTLTemperature;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _presentCTLDeltaUV;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_remainingTime != nil) {
        tem16 = _targetCTLTemperature;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = _targetCTLDeltaUV;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        UInt8 tem8 = _remainingTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigLightCTLDefaultGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLDefaultGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLDefaultGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightCTLDefaultStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightCTLDefaultStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLDefaultStatus;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness temperature:(UInt16)temperature deltaUV:(UInt16)deltaUV {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLDefaultStatus;
        _lightness = lightness;
        _temperature = temperature;
        _deltaUV = deltaUV;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLDefaultStatus;
        if (parameters == nil || (parameters.length != 6)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _temperature = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _deltaUV = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _temperature;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _deltaUV;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightCTLDefaultSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLDefaultSet;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness temperature:(UInt16)temperature deltaUV:(UInt16)deltaUV {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLDefaultSet;
        _lightness = lightness;
        _temperature = temperature;
        _deltaUV = deltaUV;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLDefaultSet;
        if (parameters == nil || (parameters.length != 6)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _temperature = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _deltaUV = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _temperature;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _deltaUV;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigLightCTLStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightCTLDefaultSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLDefaultSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness temperature:(UInt16)temperature deltaUV:(UInt16)deltaUV {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLDefaultSetUnacknowledged;
        _lightness = lightness;
        _temperature = temperature;
        _deltaUV = deltaUV;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLDefaultSetUnacknowledged;
        if (parameters == nil || (parameters.length != 6)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _temperature = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _deltaUV = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _temperature;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _deltaUV;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightCTLTemperatureRangeSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureRangeSet;
    }
    return self;
}

- (instancetype)initWithRangeMin:(UInt16)rangeMin rangeMax:(UInt16)rangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureRangeSet;
        _rangeMin = rangeMin;
        _rangeMax = rangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureRangeSet;
        if (parameters == nil || (parameters.length != 4)) {
            return nil;
        }
        Byte *dataByte = (Byte *)parameters.bytes;
        UInt16 tem = 0;
        memcpy(&tem, dataByte+0, 2);
        _rangeMin = tem;
        memcpy(&tem, dataByte+2, 2);
        _rangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _rangeMin;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _rangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigLightCTLTemperatureRangeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightCTLTemperatureRangeSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureRangeSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithRangeMin:(UInt16)rangeMin rangeMax:(UInt16)rangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureRangeSetUnacknowledged;
        _rangeMin = rangeMin;
        _rangeMax = rangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightCTLTemperatureRangeSetUnacknowledged;
        if (parameters == nil || (parameters.length != 4)) {
            return nil;
        }
        Byte *dataByte = (Byte *)parameters.bytes;
        UInt16 tem = 0;
        memcpy(&tem, dataByte+0, 2);
        _rangeMin = tem;
        memcpy(&tem, dataByte+2, 2);
        _rangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _rangeMin;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _rangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightHSLGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightHSLStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightHSLHueGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLHueGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLHueGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightHSLHueStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightHSLHueSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLHueSet;
    }
    return self;
}

- (instancetype)initWithHue:(UInt16)hue transitionTime:(SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLHueSet;
        _hue = hue;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLHueSet;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _hue = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+2, 1);
            self.tid = tem8;
            if (parameters.length == 5) {
                memcpy(&tem8, dataByte+3, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+4, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _hue;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigLightHSLHueStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightHSLHueSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLHueSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithHue:(UInt16)hue transitionTime:(SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLHueSetUnacknowledged;
        _hue = hue;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLHueSetUnacknowledged;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _hue = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+2, 1);
            self.tid = tem8;
            if (parameters.length == 5) {
                memcpy(&tem8, dataByte+3, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+4, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _hue;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigLightHSLHueStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLHueStatus;
    }
    return self;
}

- (instancetype)initWithPresentHue:(UInt16)presentHue targetHue:(UInt16)targetHue transitionTime:(SigTransitionTime *)transitionTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLHueStatus;
        _presentHue = presentHue;
        _targetHue = targetHue;
        _transitionTime = transitionTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLHueStatus;
        if (parameters == nil || (parameters.length != 2 && parameters.length != 5)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _presentHue = tem16;
            if (parameters.length == 5) {
                memcpy(&tem16, dataByte+2, 2);
                _targetHue = tem16;
                memcpy(&tem8, dataByte+4, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _presentHue;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_transitionTime) {
        tem16 = _targetHue;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        UInt8 tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigLightHSLSaturationGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSaturationGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSaturationGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightHSLSaturationStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightHSLSaturationSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSaturationSet;
    }
    return self;
}

- (instancetype)initWithSaturation:(UInt16)saturation transitionTime:(SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSaturationSet;
        _saturation = saturation;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSaturationSet;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _saturation = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+2, 1);
            self.tid = tem8;
            if (parameters.length == 5) {
                memcpy(&tem8, dataByte+3, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+4, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _saturation;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigLightHSLSaturationStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightHSLSaturationSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSaturationSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithSaturation:(UInt16)saturation transitionTime:(SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSaturationSetUnacknowledged;
        _saturation = saturation;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSaturationSetUnacknowledged;
        if (parameters == nil || (parameters.length != 3 && parameters.length != 5)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _saturation = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+2, 1);
            self.tid = tem8;
            if (parameters.length == 5) {
                memcpy(&tem8, dataByte+3, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+4, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _saturation;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigLightHSLSaturationStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSaturationStatus;
    }
    return self;
}

- (instancetype)initWithPresentSaturation:(UInt16)presentSaturation targetSaturation:(UInt16)targetSaturation remainingTime:(SigTransitionTime *)remainingTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSaturationStatus;
        _presentSaturation = presentSaturation;
        _targetSaturation = targetSaturation;
        _remainingTime = remainingTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSaturationStatus;
        if (parameters == nil || (parameters.length != 2 && parameters.length != 5)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _presentSaturation = tem16;
            if (parameters.length == 5) {
                memcpy(&tem16, dataByte+2, 2);
                _targetSaturation = tem16;
                memcpy(&tem8, dataByte+4, 1);
                _remainingTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _presentSaturation;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_remainingTime) {
        tem16 = _targetSaturation;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        UInt8 tem8 = _remainingTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigLightHSLSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSet;
    }
    return self;
}

- (instancetype)initWithHSLLightness:(UInt16)HSLLightness HSLHue:(UInt16)HSLHue HSLSaturation:(UInt16)HSLSaturation transitionTime:(SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSet;
        _HSLLightness = HSLLightness;
        _HSLHue = HSLHue;
        _HSLSaturation = HSLSaturation;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSet;
        if (parameters == nil || (parameters.length != 7 && parameters.length != 9)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _HSLLightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _HSLHue = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _HSLSaturation = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+6, 1);
            self.tid = tem8;
            if (parameters.length == 9) {
                memcpy(&tem8, dataByte+7, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+8, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _HSLLightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _HSLHue;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _HSLSaturation;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigLightHSLStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightHSLSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithHSLLightness:(UInt16)HSLLightness HSLHue:(UInt16)HSLHue HSLSaturation:(UInt16)HSLSaturation transitionTime:(SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSetUnacknowledged;
        _HSLLightness = HSLLightness;
        _HSLHue = HSLHue;
        _HSLSaturation = HSLSaturation;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLSetUnacknowledged;
        if (parameters == nil || (parameters.length != 7 && parameters.length != 9)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _HSLLightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _HSLHue = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _HSLSaturation = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+6, 1);
            self.tid = tem8;
            if (parameters.length == 9) {
                memcpy(&tem8, dataByte+7, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+8, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _HSLLightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _HSLHue;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _HSLSaturation;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigLightHSLStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLStatus;
    }
    return self;
}

- (instancetype)initWithHSLLightness:(UInt16)HSLLightness HSLHue:(UInt16)HSLHue HSLSaturation:(UInt16)HSLSaturation remainingTime:(SigTransitionTime * _Nullable )remainingTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLStatus;
        _HSLLightness = HSLLightness;
        _HSLHue = HSLHue;
        _HSLSaturation = HSLSaturation;
        _remainingTime = remainingTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLStatus;
        if (parameters == nil || (parameters.length != 7 && parameters.length != 6)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _HSLLightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _HSLHue = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _HSLSaturation = tem16;
            if (parameters.length == 7) {
                memcpy(&tem8, dataByte+6, 1);
                _remainingTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _HSLLightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _HSLHue;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _HSLSaturation;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_remainingTime) {
        UInt8 tem8 = _remainingTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigLightHSLTargetGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLTargetGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLTargetGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightHSLTargetStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightHSLTargetStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLTargetStatus;
    }
    return self;
}

- (instancetype)initWithHSLLightnessTarget:(UInt16)HSLLightnessTarget HSLHueTarget:(UInt16)HSLHueTarget HSLSaturationTarget:(UInt16)HSLSaturationTarget remainingTime:(SigTransitionTime *)remainingTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLTargetStatus;
        _HSLLightnessTarget = HSLLightnessTarget;
        _HSLHueTarget = HSLHueTarget;
        _HSLSaturationTarget = HSLSaturationTarget;
        _remainingTime = remainingTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLTargetStatus;
        if (parameters == nil || (parameters.length != 7 && parameters.length != 6)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _HSLLightnessTarget = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _HSLHueTarget = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _HSLSaturationTarget = tem16;
            if (parameters.length == 7) {
                memcpy(&tem8, dataByte+6, 1);
                _remainingTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _HSLLightnessTarget;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _HSLHueTarget;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _HSLSaturationTarget;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_remainingTime) {
        UInt8 tem8 = _remainingTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigLightHSLDefaultGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLDefaultGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLDefaultGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightHSLDefaultStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightHSLDefaultStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLDefaultStatus;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness hue:(UInt16)hue saturation:(UInt16)saturation remainingTime:(SigTransitionTime *)remainingTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLDefaultStatus;
        _lightness = lightness;
        _hue = hue;
        _saturation = saturation;
        _remainingTime = remainingTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLDefaultStatus;
        if (parameters == nil || (parameters.length != 7)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _hue = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _saturation = tem16;
            memcpy(&tem8, dataByte+6, 1);
            _remainingTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _hue;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _saturation;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = _remainingTime.rawValue;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightHSLRangeGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLRangeGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLRangeGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightHSLRangeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightHSLRangeStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLRangeStatus;
    }
    return self;
}

- (instancetype)initWithStatusCode:(SigGenericMessageStatus)statusCode hueRangeMin:(UInt16)hueRangeMin hueRangeMax:(UInt16)hueRangeMax saturationRangeMin:(UInt16)saturationRangeMin saturationRangeMax:(UInt16)saturationRangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLRangeStatus;
        _statusCode = statusCode;
        _hueRangeMin = hueRangeMin;
        _hueRangeMax = hueRangeMax;
        _saturationRangeMin = saturationRangeMin;
        _saturationRangeMax = saturationRangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLRangeStatus;
        if (parameters == nil || (parameters.length != 9)) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _statusCode = (SigGenericMessageStatus)tem8;
        UInt16 tem = 0;
        memcpy(&tem, dataByte+1, 2);
        _hueRangeMin = tem;
        memcpy(&tem, dataByte+3, 2);
        _hueRangeMax = tem;
        memcpy(&tem, dataByte+5, 2);
        _saturationRangeMin = tem;
        memcpy(&tem, dataByte+7, 2);
        _saturationRangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _statusCode;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _hueRangeMin;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _hueRangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _saturationRangeMin;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _saturationRangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightHSLDefaultSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLDefaultSet;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness hue:(UInt16)hue saturation:(UInt16)saturation {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLDefaultSet;
        _lightness = lightness;
        _hue = hue;
        _saturation = saturation;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLDefaultSet;
        if (parameters == nil || (parameters.length != 6)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _hue = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _saturation = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _hue;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _saturation;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigLightHSLDefaultStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightHSLDefaultSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLDefaultSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness hue:(UInt16)hue saturation:(UInt16)saturation {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLDefaultSetUnacknowledged;
        _lightness = lightness;
        _hue = hue;
        _saturation = saturation;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLDefaultSetUnacknowledged;
        if (parameters == nil || (parameters.length != 6)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _hue = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _saturation = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _hue;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _saturation;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightHSLRangeSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLRangeSet;
    }
    return self;
}

- (instancetype)initWithHueRangeMin:(UInt16)hueRangeMin hueRangeMax:(UInt16)hueRangeMax saturationRangeMin:(UInt16)saturationRangeMin saturationRangeMax:(UInt16)saturationRangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLRangeSet;
        _hueRangeMin = hueRangeMin;
        _hueRangeMax = hueRangeMax;
        _saturationRangeMin = saturationRangeMin;
        _saturationRangeMax = saturationRangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLRangeSet;
        if (parameters == nil || (parameters.length != 8)) {
            return nil;
        }
        Byte *dataByte = (Byte *)parameters.bytes;
        UInt16 tem = 0;
        memcpy(&tem, dataByte, 2);
        _hueRangeMin = tem;
        memcpy(&tem, dataByte+2, 2);
        _hueRangeMax = tem;
        memcpy(&tem, dataByte+4, 2);
        _saturationRangeMin = tem;
        memcpy(&tem, dataByte+6, 2);
        _saturationRangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _hueRangeMin;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _hueRangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _saturationRangeMin;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _saturationRangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigLightHSLRangeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightHSLRangeSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLRangeSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithHueRangeMin:(UInt16)hueRangeMin hueRangeMax:(UInt16)hueRangeMax saturationRangeMin:(UInt16)saturationRangeMin saturationRangeMax:(UInt16)saturationRangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLRangeSetUnacknowledged;
        _hueRangeMin = hueRangeMin;
        _hueRangeMax = hueRangeMax;
        _saturationRangeMin = saturationRangeMin;
        _saturationRangeMax = saturationRangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightHSLRangeSetUnacknowledged;
        if (parameters == nil || (parameters.length != 8)) {
            return nil;
        }
        Byte *dataByte = (Byte *)parameters.bytes;
        UInt16 tem = 0;
        memcpy(&tem, dataByte, 2);
        _hueRangeMin = tem;
        memcpy(&tem, dataByte+2, 2);
        _hueRangeMax = tem;
        memcpy(&tem, dataByte+4, 2);
        _saturationRangeMin = tem;
        memcpy(&tem, dataByte+6, 2);
        _saturationRangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _hueRangeMin;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _hueRangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _saturationRangeMin;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _saturationRangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightXyLGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightXyLStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightXyLSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLSet;
    }
    return self;
}

- (instancetype)initWithXyLLightness:(UInt16)xyLLightness xyLX:(UInt16)xyLX xyLY:(UInt16)xyLY transitionTime:(SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLSet;
        _xyLLightness = xyLLightness;
        _xyLX = xyLX;
        _xyLY = xyLY;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLSet;
        if (parameters == nil || (parameters.length != 7 && parameters.length != 9)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _xyLLightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _xyLX = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _xyLY = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+6, 1);
            self.tid = tem8;
            if (parameters.length == 9) {
                memcpy(&tem8, dataByte+7, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+8, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _xyLLightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLX;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLY;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigLightXyLStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightXyLSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithXyLLightness:(UInt16)xyLLightness xyLX:(UInt16)xyLX xyLY:(UInt16)xyLY transitionTime:(SigTransitionTime *)transitionTime delay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLSetUnacknowledged;
        _xyLLightness = xyLLightness;
        _xyLX = xyLX;
        _xyLY = xyLY;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLSetUnacknowledged;
        if (parameters == nil || (parameters.length != 7 && parameters.length != 9)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _xyLLightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _xyLX = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _xyLY = tem16;
            UInt8 tem8 = 0;
            memcpy(&tem8, dataByte+6, 1);
            self.tid = tem8;
            if (parameters.length == 9) {
                memcpy(&tem8, dataByte+7, 1);
                _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
                memcpy(&tem8, dataByte+8, 1);
                _delay = tem8;
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _xyLLightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLX;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLY;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    UInt8 tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigLightXyLStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLStatus;
    }
    return self;
}

- (instancetype)initWithXyLLightness:(UInt16)xyLLightness xyLX:(UInt16)xyLX xyLY:(UInt16)xyLY remainingTime:(SigTransitionTime *)remainingTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLStatus;
        _xyLLightness = xyLLightness;
        _xyLX = xyLX;
        _xyLY = xyLY;
        _remainingTime = remainingTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLStatus;
        if (parameters == nil || (parameters.length != 6 && parameters.length != 7)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _xyLLightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _xyLX = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _xyLY = tem16;
            if (parameters.length == 7) {
                UInt8 tem8 = 0;
                memcpy(&tem8, dataByte+6, 1);
                _remainingTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _xyLLightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLX;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLY;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_remainingTime != nil) {
        UInt8 tem8 = _remainingTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigLightXyLTargetGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLTargetGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLTargetGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightXyLTargetStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightXyLTargetStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLTargetStatus;
    }
    return self;
}

- (instancetype)initWithTargetXyLLightness:(UInt16)targetXyLLightness targetXyLX:(UInt16)targetXyLX targetXyLY:(UInt16)targetXyLY remainingTime:(SigTransitionTime *)remainingTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLTargetStatus;
        _targetXyLLightness = targetXyLLightness;
        _targetXyLX = targetXyLX;
        _targetXyLY = targetXyLY;
        _remainingTime = remainingTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLTargetStatus;
        if (parameters == nil || (parameters.length != 6 && parameters.length != 7)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _targetXyLLightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _targetXyLX = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _targetXyLY = tem16;
            if (parameters.length == 7) {
                UInt8 tem8 = 0;
                memcpy(&tem8, dataByte+6, 1);
                _remainingTime = [[SigTransitionTime alloc] initWithRawValue:tem8];
            }
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _targetXyLLightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _targetXyLX;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _targetXyLY;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_remainingTime != nil) {
        UInt8 tem8 = _remainingTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigLightXyLDefaultGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLDefaultGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLDefaultGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightXyLDefaultStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightXyLDefaultStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLDefaultStatus;
    }
    return self;
}

- (instancetype)initWithXyLLightness:(UInt16)lightness xyLX:(UInt16)xyLX xyLY:(UInt16)xyLY {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLDefaultStatus;
        _lightness = lightness;
        _xyLX = xyLX;
        _xyLY = xyLY;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLDefaultStatus;
        if (parameters == nil || (parameters.length != 6)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _xyLX = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _xyLY = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLX;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLY;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightXyLRangeGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLRangeGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLRangeGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightXyLRangeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightXyLRangeStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLRangeStatus;
    }
    return self;
}

- (instancetype)initWithStatusCode:(SigGenericMessageStatus)statusCode xyLXRangeMin:(UInt16)xyLXRangeMin xyLXRangeMax:(UInt16)xyLXRangeMax xyLYRangeMin:(UInt16)xyLYRangeMin xyLYRangeMax:(UInt16)xyLYRangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLRangeStatus;
        _statusCode = statusCode;
        _xyLXRangeMin = xyLXRangeMin;
        _xyLXRangeMax = xyLXRangeMax;
        _xyLYRangeMin = xyLYRangeMin;
        _xyLYRangeMax = xyLYRangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLRangeStatus;
        if (parameters == nil || (parameters.length != 9)) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _statusCode = (SigGenericMessageStatus)tem8;
        UInt16 tem = 0;
        memcpy(&tem, dataByte+1, 2);
        _xyLXRangeMin = tem;
        memcpy(&tem, dataByte+3, 2);
        _xyLXRangeMax = tem;
        memcpy(&tem, dataByte+5, 2);
        _xyLYRangeMin = tem;
        memcpy(&tem, dataByte+7, 2);
        _xyLYRangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _statusCode;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    UInt16 tem16 = _xyLXRangeMin;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLXRangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLYRangeMin;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLYRangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightXyLDefaultSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLDefaultSet;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness xyLX:(UInt16)xyLX xyLY:(UInt16)xyLY {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLDefaultSet;
        _lightness = lightness;
        _xyLX = xyLX;
        _xyLY = xyLY;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLDefaultSet;
        if (parameters == nil || (parameters.length != 6)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _xyLX = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _xyLY = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLX;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLY;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigLightXyLDefaultStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightXyLDefaultSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLDefaultSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithLightness:(UInt16)lightness xyLX:(UInt16)xyLX xyLY:(UInt16)xyLY {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLDefaultSetUnacknowledged;
        _lightness = lightness;
        _xyLX = xyLX;
        _xyLY = xyLY;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLDefaultSetUnacknowledged;
        if (parameters == nil || (parameters.length != 6)) {
            return nil;
        }else{
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightness = tem16;
            memcpy(&tem16, dataByte+2, 2);
            _xyLX = tem16;
            memcpy(&tem16, dataByte+4, 2);
            _xyLY = tem16;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightness;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLX;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLY;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightXyLRangeSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLRangeSet;
    }
    return self;
}

- (instancetype)initWithXyLXRangeMin:(UInt16)xyLXRangeMin xyLXRangeMax:(UInt16)xyLXRangeMax xyLYRangeMin:(UInt16)xyLYRangeMin xyLYRangeMax:(UInt16)xyLYRangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLRangeSet;
        _xyLXRangeMin = xyLXRangeMin;
        _xyLXRangeMax = xyLXRangeMax;
        _xyLYRangeMin = xyLYRangeMin;
        _xyLYRangeMax = xyLYRangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLRangeSet;
        if (parameters == nil || (parameters.length != 9)) {
            return nil;
        }
        Byte *dataByte = (Byte *)parameters.bytes;
        UInt16 tem = 0;
        memcpy(&tem, dataByte+1, 2);
        _xyLXRangeMin = tem;
        memcpy(&tem, dataByte+3, 2);
        _xyLXRangeMax = tem;
        memcpy(&tem, dataByte+5, 2);
        _xyLYRangeMin = tem;
        memcpy(&tem, dataByte+7, 2);
        _xyLYRangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _xyLXRangeMin;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLXRangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLYRangeMin;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLYRangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigLightXyLRangeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightXyLRangeSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLRangeSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithXyLXRangeMin:(UInt16)xyLXRangeMin xyLXRangeMax:(UInt16)xyLXRangeMax xyLYRangeMin:(UInt16)xyLYRangeMin xyLYRangeMax:(UInt16)xyLYRangeMax {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLRangeSetUnacknowledged;
        _xyLXRangeMin = xyLXRangeMin;
        _xyLXRangeMax = xyLXRangeMax;
        _xyLYRangeMin = xyLYRangeMin;
        _xyLYRangeMax = xyLYRangeMax;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_lightXyLRangeSetUnacknowledged;
        if (parameters == nil || (parameters.length != 9)) {
            return nil;
        }
        Byte *dataByte = (Byte *)parameters.bytes;
        UInt16 tem = 0;
        memcpy(&tem, dataByte+1, 2);
        _xyLXRangeMin = tem;
        memcpy(&tem, dataByte+3, 2);
        _xyLXRangeMax = tem;
        memcpy(&tem, dataByte+5, 2);
        _xyLYRangeMin = tem;
        memcpy(&tem, dataByte+7, 2);
        _xyLYRangeMax = tem;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _xyLXRangeMin;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLXRangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLYRangeMin;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    tem16 = _xyLYRangeMax;
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightLCModeGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCModeGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCModeGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightLCModeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightLCModeSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCModeSet;
    }
    return self;
}

- (instancetype)initWithMode:(UInt8)mode {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCModeSet;
        _mode = mode;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCModeSet;
        if (parameters == nil || (parameters.length != 1)) {
            return nil;
        }else{
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            _mode = tem8;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _mode;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigLightLCModeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightLCModeSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCModeSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithMode:(UInt8)mode {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCModeSetUnacknowledged;
        _mode = mode;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCModeSetUnacknowledged;
        if (parameters == nil || (parameters.length != 1)) {
            return nil;
        }else{
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            _mode = tem8;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _mode;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightLCModeStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCModeStatus;
    }
    return self;
}

- (instancetype)initWithMode:(UInt8)mode {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCModeStatus;
        _mode = mode;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCModeStatus;
        if (parameters == nil || (parameters.length != 1)) {
            return nil;
        }else{
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            _mode = tem8;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _mode;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightLCOMGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCOMGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCOMGet;
        if (parameters == nil || (parameters.length == 0)) {
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
    return [SigLightLCOMStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightLCOMSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCOMSet;
    }
    return self;
}

- (instancetype)initWithMode:(UInt8)mode {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCOMSet;
        _mode = mode;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCOMSet;
        if (parameters == nil || (parameters.length != 1)) {
            return nil;
        }else{
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            _mode = tem8;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _mode;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigLightLCOMStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigLightLCOMSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCOMSetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithMode:(UInt8)mode {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCOMSetUnacknowledged;
        _mode = mode;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCOMSetUnacknowledged;
        if (parameters == nil || (parameters.length != 1)) {
            return nil;
        }else{
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            _mode = tem8;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _mode;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightLCOMStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCOMStatus;
    }
    return self;
}

- (instancetype)initWithMode:(UInt8)mode {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCOMStatus;
        _mode = mode;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCOMStatus;
        if (parameters == nil || (parameters.length != 1)) {
            return nil;
        }else{
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            _mode = tem8;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _mode;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

@end


@implementation SigLightLCLightOnOffGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCLightOnOffGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCLightOnOffGet;
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
    return [SigLightLCLightOnOffStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigLightLCLightOnOffSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCLightOnOffSet;
        //v3.2.3后，_transitionTime为nil，默认不带渐变参数。
//        _transitionTime = [[SigTransitionTime alloc] initWithSetps:0 stepResolution:0];
        _delay = 0;
    }
    return self;
}

- (instancetype)initWithLightOnOff:(BOOL)lightOnOff transitionTime:(SigTransitionTime *)transitionTime dalay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCLightOnOffSet;
        _lightOnOff = lightOnOff;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCLightOnOffSet;
        if (parameters == nil || (parameters.length != 2 && parameters.length != 4)) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _lightOnOff = tem == 0x01;
        memcpy(&tem, dataByte+1, 1);
        self.tid = tem;
        if (parameters.length == 4) {
            memcpy(&tem, dataByte+2, 1);
            _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
            memcpy(&tem, dataByte+3, 1);
            _delay = tem;
        } else {
            _transitionTime = nil;
            _delay = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _lightOnOff ? 0x01 : 0x00;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

- (Class)responseType {
    return [SigLightLCLightOnOffStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigLightLCLightOnOffSetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCLightOnOffSet;
        //v3.2.3后，_transitionTime为nil，默认不带渐变参数。
//        _transitionTime = [[SigTransitionTime alloc] initWithSetps:0 stepResolution:0];
        _delay = 0;
    }
    return self;
}

- (instancetype)initWithLightOnOff:(BOOL)lightOnOff transitionTime:(SigTransitionTime *)transitionTime dalay:(UInt8)delay {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCLightOnOffSet;
        _lightOnOff = lightOnOff;
        _transitionTime = transitionTime;
        _delay = delay;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCLightOnOffSet;
        if (parameters == nil || (parameters.length != 2 && parameters.length != 4)) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _lightOnOff = tem == 0x01;
        memcpy(&tem, dataByte+1, 1);
        self.tid = tem;
        if (parameters.length == 4) {
            memcpy(&tem, dataByte+2, 1);
            _transitionTime = [[SigTransitionTime alloc] initWithRawValue:tem];
            memcpy(&tem, dataByte+3, 1);
            _delay = tem;
        } else {
            _transitionTime = nil;
            _delay = 0;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _lightOnOff ? 0x01 : 0x00;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = self.tid;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_transitionTime != nil) {
        tem8 = _transitionTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _delay;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    //v3.2.3后，_transitionTime为nil，则不补0000了。
//    else{
//        tem8 = 0;
//        data = [NSData dataWithBytes:&tem8 length:1];
//        [mData appendData:data];
//        [mData appendData:data];
//    }
    return mData;
}

@end


@implementation SigLightLCLightOnOffStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCLightOnOffStatus;
    }
    return self;
}

- (instancetype)initWithPresentLightOnOff:(BOOL)presentLightOnOff targetLightOnOff:(BOOL)targetLightOnOff remainingTime:(SigTransitionTime *)remainingTime {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCLightOnOffStatus;
        _presentLightOnOff = presentLightOnOff;
        _targetLightOnOff = targetLightOnOff;
        _remainingTime = remainingTime;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_genericOnOffStatus;
        if (parameters == nil || (parameters.length != 1 && parameters.length != 3)) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _presentLightOnOff = tem == 0x01;
        if (parameters.length == 3) {
            memcpy(&tem, dataByte+1, 1);
            _targetLightOnOff = tem == 0x01;
            memcpy(&tem, dataByte+2, 1);
            _remainingTime = [[SigTransitionTime alloc] initWithRawValue:tem];
        } else {
            _targetLightOnOff = NO;
            _remainingTime = nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _presentLightOnOff ? 0x01 : 0x00;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    if (_remainingTime != nil) {
        tem8 = _targetLightOnOff ? 0x01 : 0x00;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = _remainingTime.rawValue;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
    }
    return mData;
}

@end


@implementation SigLightLCPropertyGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCPropertyGet;
    }
    return self;
}

- (instancetype)initWithLightLCPropertyID:(UInt16)lightLCPropertyID {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCPropertyGet;
        _lightLCPropertyID = lightLCPropertyID;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCPropertyGet;
        if (parameters != nil && parameters.length == 2) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightLCPropertyID = tem16;
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightLCPropertyID;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigLightLCPropertyStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigLightLCPropertySet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCPropertySet;
    }
    return self;
}

- (instancetype)initWithLightLCPropertyID:(UInt16)lightLCPropertyID lightLCPropertyValue:(NSData *)lightLCPropertyValue {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCPropertySet;
        _lightLCPropertyID = lightLCPropertyID;
        _lightLCPropertyValue = lightLCPropertyValue;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCPropertySet;
        if (parameters != nil && parameters.length >= 2) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightLCPropertyID = tem16;
            _lightLCPropertyValue = [parameters subdataWithRange:NSMakeRange(2, parameters.length - 2)];
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightLCPropertyID;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_lightLCPropertyValue != nil) {
        [mData appendData:_lightLCPropertyValue];
    }
    return mData;
}

- (Class)responseType {
    return [SigLightLCPropertyStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigLightLCPropertySetUnacknowledged

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCPropertySetUnacknowledged;
    }
    return self;
}

- (instancetype)initWithLightLCPropertyID:(UInt16)lightLCPropertyID lightLCPropertyValue:(NSData *)lightLCPropertyValue {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCPropertySetUnacknowledged;
        _lightLCPropertyID = lightLCPropertyID;
        _lightLCPropertyValue = lightLCPropertyValue;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCPropertySetUnacknowledged;
        if (parameters != nil && parameters.length >= 2) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightLCPropertyID = tem16;
            _lightLCPropertyValue = [parameters subdataWithRange:NSMakeRange(2, parameters.length - 2)];
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightLCPropertyID;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_lightLCPropertyValue != nil) {
        [mData appendData:_lightLCPropertyValue];
    }
    return mData;
}

@end


@implementation SigLightLCPropertyStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCPropertyStatus;
    }
    return self;
}

- (instancetype)initWithLightLCPropertyID:(UInt16)lightLCPropertyID lightLCPropertyValue:(NSData *)lightLCPropertyValue {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCPropertyStatus;
        _lightLCPropertyID = lightLCPropertyID;
        _lightLCPropertyValue = lightLCPropertyValue;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_LightLCPropertyStatus;
        if (parameters != nil && parameters.length >= 2) {
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem16, dataByte, 2);
            _lightLCPropertyID = tem16;
            _lightLCPropertyValue = [parameters subdataWithRange:NSMakeRange(2, parameters.length - 2)];
        }else{
            return nil;
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _lightLCPropertyID;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    if (_lightLCPropertyValue != nil) {
        [mData appendData:_lightLCPropertyValue];
    }
    return mData;
}

@end


@implementation SigFirmwareUpdateInformationGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateInformationGet;
        _firstIndex = 0;
        _entriesLimit = 0;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateInformationGet;
        if (parameters != nil && parameters.length > 2) {
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            _firstIndex = tem8;
            memcpy(&tem8, dataByte+1, 1);
            _entriesLimit = tem8;
        }else{
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithFirstIndex:(UInt8)firstIndex entriesLimit:(UInt8)entriesLimit {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateInformationGet;
        _firstIndex = firstIndex;
        _entriesLimit = entriesLimit;
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = _firstIndex;
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    tem8 = _entriesLimit;
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    return mData;
}

- (Class)responseType {
    return [SigFirmwareUpdateInformationStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareUpdateInformationStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateInformationStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateInformationStatus;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters.length < 2 + 3) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _firmwareInformationListCount = tem8;
        memcpy(&tem8, dataByte+1, 1);
        _firstIndex = tem8;
        NSInteger index = 2;
        _firmwareInformationList = [NSMutableArray array];
        while (parameters.length > index) {
            SigFirmwareInformationEntryModel *model = [[SigFirmwareInformationEntryModel alloc] initWithParameters:[parameters subdataWithRange:NSMakeRange(index, parameters.length - index)]];
            if (model) {
                [_firmwareInformationList addObject:model];
                index += model.parameters.length;
            } else {
                break;
            }
            if (_firmwareInformationList.count >= _firmwareInformationListCount) {
                break;
            }
        }
    }
    return self;
}

@end


@implementation SigFirmwareDistributionGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareDistributionStart

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionStart;
    }
    return self;
}

- (instancetype)initWithDistributionAppKeyIndex:(UInt16)distributionAppKeyIndex distributionTTL:(UInt8)distributionTTL distributionTimeoutBase:(UInt16)distributionTimeoutBase distributionTransferMode:(SigTransferModeState)distributionTransferMode updatePolicy:(SigUpdatePolicyType)updatePolicy RFU:(UInt8)RFU distributionFirmwareImageIndex:(UInt16)distributionFirmwareImageIndex distributionMulticastAddress:(NSData *)distributionMulticastAddress {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionStart;
        _distributionAppKeyIndex = distributionAppKeyIndex;
        _distributionTTL = distributionTTL;
        _distributionTimeoutBase = distributionTimeoutBase;
        _distributionTransferMode = distributionTransferMode;
        _updatePolicy = updatePolicy;
        _RFU = RFU;
        _distributionFirmwareImageIndex = distributionFirmwareImageIndex;
        _distributionMulticastAddress = [NSData dataWithData:distributionMulticastAddress];
        
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = distributionAppKeyIndex;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        UInt8 tem8 = distributionTTL;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem16 = distributionTimeoutBase;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem8 = distributionTransferMode | ((updatePolicy == SigUpdatePolicyType_verifyAndApply ? 1 : 0) << 2) | ((RFU&0b11111) << 3);
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem16 = distributionFirmwareImageIndex;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        [mData appendData:distributionMulticastAddress];
        self.parameters = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionStart;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || (parameters.length != 10 && parameters.length != 24)) {
            return nil;
        }
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _distributionAppKeyIndex = tem16;
        UInt8 tem8 = 0;
        memcpy(&tem8, dataByte+2, 1);
        _distributionTTL = tem8;
        memcpy(&tem16, dataByte+3, 2);
        _distributionTimeoutBase = tem16;
        memcpy(&tem8, dataByte+5, 1);
        _distributionTransferMode = tem8 & 0b11;
        _updatePolicy = (tem8 >> 2) & 0b1;
        _RFU = tem8 >> 3;
        memcpy(&tem16, dataByte+6, 2);
        _distributionFirmwareImageIndex = tem16;
        if (parameters.length == 10) {
            _distributionMulticastAddress = [parameters subdataWithRange:NSMakeRange(8, 2)];
        } else if (parameters.length >= 24){
            _distributionMulticastAddress = [parameters subdataWithRange:NSMakeRange(8, 16)];
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareDistributionCancel

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionCancel;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionCancel;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareDistributionApply

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionApply;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionApply;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareDistributionUploadGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionUploadGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionUploadGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionUploadStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareDistributionUploadStart

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionUploadStart;
    }
    return self;
}

- (instancetype)initWithUploadTTL:(UInt8)uploadTTL uploadTimeoutBase:(UInt16)uploadTimeoutBase uploadBLOBID:(UInt64)uploadBLOBID uploadFirmwareSize:(UInt32)uploadFirmwareSize uploadFirmwareMetadataLength:(UInt8)uploadFirmwareMetadataLength uploadFirmwareMetadata:(NSData *)uploadFirmwareMetadata uploadFirmwareID:(NSData *)uploadFirmwareID {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionUploadStart;
        _uploadTTL = uploadTTL;
        _uploadTimeoutBase = uploadTimeoutBase;
        _uploadBLOBID = uploadBLOBID;
        _uploadFirmwareSize = uploadFirmwareSize;
        _uploadFirmwareMetadataLength = uploadFirmwareMetadataLength;
        if (uploadFirmwareMetadata && uploadFirmwareMetadata.length > 0) {
            _uploadFirmwareMetadata = [NSData dataWithData:uploadFirmwareMetadata];
        }
        if (uploadFirmwareID && uploadFirmwareID.length > 0) {
            _uploadFirmwareID = [NSData dataWithData:uploadFirmwareID];
        }
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        UInt32 tem32 = 0;
        UInt64 tem64 = 0;
        NSMutableData *mData = [NSMutableData data];
        tem8 = uploadTTL;
        [mData appendData:[NSData dataWithBytes:&tem8 length:1]];
        tem16 = uploadTimeoutBase;
        [mData appendData:[NSData dataWithBytes:&tem16 length:2]];
        tem64 = uploadBLOBID;
        [mData appendData:[NSData dataWithBytes:&tem64 length:8]];
        tem32 = uploadFirmwareSize;
        [mData appendData:[NSData dataWithBytes:&tem32 length:4]];
        tem8 = uploadFirmwareMetadataLength;
        [mData appendData:[NSData dataWithBytes:&tem8 length:1]];
        if (uploadFirmwareMetadata && uploadFirmwareMetadata.length > 0) {
            [mData appendData:uploadFirmwareMetadata];
        }
        if (uploadFirmwareID && uploadFirmwareID.length > 0) {
            [mData appendData:uploadFirmwareID];
        }
        self.parameters = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionUploadStart;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length < 17) {
            return nil;
        }
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        UInt32 tem32 = 0;
        UInt64 tem64 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _uploadTTL = tem8;
        memcpy(&tem16, dataByte + 1, 2);
        _uploadTimeoutBase = tem16;
        memcpy(&tem64, dataByte + 3, 8);
        _uploadBLOBID = tem64;
        memcpy(&tem32, dataByte + 11, 4);
        _uploadFirmwareSize = tem32;
        memcpy(&tem8, dataByte + 15, 1);
        _uploadFirmwareMetadataLength = tem8;
        if (_uploadFirmwareMetadataLength == 0) {
            _uploadFirmwareID = [parameters subdataWithRange:NSMakeRange(16, parameters.length - 16)];
        } else {
            if (parameters.length >= 16 + _uploadFirmwareMetadataLength) {
                _uploadFirmwareMetadata = [parameters subdataWithRange:NSMakeRange(16, _uploadFirmwareMetadataLength)];
                _uploadFirmwareID = [parameters subdataWithRange:NSMakeRange(16 + _uploadFirmwareMetadataLength, parameters.length - 16 - _uploadFirmwareMetadataLength)];
            }
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionUploadStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareDistributionUploadOOBStart

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionUploadOOBStart;
    }
    return self;
}

- (instancetype)initWithUploadURILength:(UInt8)uploadURILength uploadURI:(NSData *)uploadURI uploadFirmwareID:(NSData *)uploadFirmwareID {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionUploadOOBStart;
        _uploadURILength = uploadURILength;
        _uploadURI = uploadURI;
        if (uploadURI && uploadURI.length > 0) {
            _uploadURI = [NSData dataWithData:uploadURI];
        }
        if (uploadFirmwareID && uploadFirmwareID.length > 0) {
            _uploadFirmwareID = [NSData dataWithData:uploadFirmwareID];
        }
        UInt8 tem8 = 0;
        NSMutableData *mData = [NSMutableData data];
        tem8 = uploadURILength;
        [mData appendData:[NSData dataWithBytes:&tem8 length:1]];
        if (uploadURI && uploadURI.length > 0) {
            [mData appendData:uploadURI];
        }
        if (uploadFirmwareID && uploadFirmwareID.length > 0) {
            [mData appendData:uploadFirmwareID];
        }
        self.parameters = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionUploadOOBStart;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length < 2) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _uploadURILength = tem8;
        if (_uploadURILength > 0) {
            if (parameters.length >= 1 + _uploadURILength) {
                _uploadURI = [parameters subdataWithRange:NSMakeRange(1, _uploadURILength)];
                _uploadFirmwareID = [parameters subdataWithRange:NSMakeRange(1 + _uploadURILength, parameters.length - 1 - _uploadURILength)];
            }
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionUploadStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareDistributionUploadCancel

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionUploadCancel;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionUploadCancel;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionUploadStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareDistributionUploadStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionUploadStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionUploadStatus;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || (parameters.length != 2 && parameters.length < 4)) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = tem8;
        memcpy(&tem8, dataByte+1, 1);
        _uploadPhase = tem8;
        if (parameters.length >= 4) {
            memcpy(&tem8, dataByte + 2, 1);
            _uploadProgress = tem8 & 0x7F;
            _uploadType = (tem8 >> 7) & 0b1;
            _uploadFirmwareID = [parameters subdataWithRange:NSMakeRange(3, parameters.length - 3)];
        }
    }
    return self;
}

- (instancetype)initWithStatus:(SigFirmwareDistributionServerAndClientModelStatusType)status uploadPhase:(SigFirmwareUploadPhaseStateType)uploadPhase uploadProgress:(UInt8)uploadProgress uploadType:(BOOL)uploadType uploadFirmwareID:(NSData *)uploadFirmwareID {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionUploadStatus;
        _status = status;
        _uploadPhase = uploadPhase;
        _uploadProgress = uploadProgress;
        if (uploadFirmwareID && uploadFirmwareID.length > 0) {
            _uploadFirmwareID = [NSData dataWithData:uploadFirmwareID];
        }

        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = 0;
        tem8 = status;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = uploadPhase;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = uploadProgress | ((uploadType==YES?1:0) << 7);
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        if (uploadFirmwareID && uploadFirmwareID.length > 0) {
            [mData appendData:uploadFirmwareID];
        }
        self.parameters = mData;
    }
    return self;
}

@end


@implementation SigFirmwareDistributionFirmwareGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionFirmwareGet;
    }
    return self;
}

- (instancetype)initWithFirmwareID:(NSData *)firmwareID {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionFirmwareGet;
        if (firmwareID && firmwareID.length > 0) {
            _firmwareID = [NSData dataWithData:firmwareID];
        }
        NSMutableData *mData = [NSMutableData data];
        if (firmwareID && firmwareID.length > 0) {
            [mData appendData:firmwareID];
        }
        self.parameters = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionFirmwareGet;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length == 0) {
            return nil;
        }
        _firmwareID = [NSData dataWithData:parameters];
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionFirmwareStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigFirmwareDistributionFirmwareGetByIndex

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionFirmwareGetByIndex;
    }
    return self;
}

- (instancetype)initWithDistributionFirmwareImageIndex:(UInt16)distributionFirmwareImageIndex {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionFirmwareGetByIndex;
        _distributionFirmwareImageIndex = distributionFirmwareImageIndex;
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = 0;
        tem16 = distributionFirmwareImageIndex;
        [mData appendData:[NSData dataWithBytes:&tem16 length:2]];
        self.parameters = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionFirmwareGetByIndex;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length != 2) {
            return nil;
        }
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _distributionFirmwareImageIndex = tem16;
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionFirmwareStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigFirmwareDistributionFirmwareDelete

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionFirmwareDelete;
    }
    return self;
}

- (instancetype)initWithFirmwareID:(NSData *)firmwareID {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionFirmwareDelete;
        if (firmwareID && firmwareID.length > 0) {
            _firmwareID = [NSData dataWithData:firmwareID];
        }
        NSMutableData *mData = [NSMutableData data];
        if (firmwareID && firmwareID.length > 0) {
            [mData appendData:firmwareID];
        }
        self.parameters = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionFirmwareDelete;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length == 0) {
            return nil;
        }
        _firmwareID = [NSData dataWithData:parameters];
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionFirmwareStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigFirmwareDistributionFirmwareDeleteAll

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionFirmwareDeleteAll;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionFirmwareDeleteAll;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionUploadStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareDistributionFirmwareStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionFirmwareStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionFirmwareStatus;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length < 5) {
            return nil;
        }
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = tem8;
        memcpy(&tem16, dataByte+1, 2);
        _entryCount = tem16;
        memcpy(&tem16, dataByte+3, 2);
        _distributionFirmwareImageIndex = tem16;
        if (parameters.length > 5) {
            _firmwareID = [NSData dataWithData:[parameters subdataWithRange:NSMakeRange(5, parameters.length - 5)]];
        }
    }
    return self;
}

- (instancetype)initWithStatus:(SigFirmwareDistributionServerAndClientModelStatusType)status entryCount:(UInt16)entryCount distributionFirmwareImageIndex:(UInt16)distributionFirmwareImageIndex firmwareID:(NSData *)firmwareID {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionFirmwareStatus;
        _status = status;
        _entryCount = entryCount;
        _distributionFirmwareImageIndex = distributionFirmwareImageIndex;
        if (firmwareID && firmwareID.length > 0) {
            _firmwareID = [NSData dataWithData:firmwareID];
        }

        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        tem8 = status;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem16 = entryCount;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = distributionFirmwareImageIndex;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        if (firmwareID && firmwareID.length > 0) {
            [mData appendData:firmwareID];
        }
        self.parameters = mData;
    }
    return self;
}

@end


@implementation SigFirmwareDistributionStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionStatus;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || (parameters.length != 2 && parameters.length != 12)) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = tem8;
        memcpy(&tem8, dataByte+1, 1);
        _distributionPhase = tem8;
        if (parameters.length == 12) {
            UInt16 tem16 = 0;
            memcpy(&tem16, dataByte + 2, 2);
            _distributionMulticastAddress = tem16;
            memcpy(&tem16, dataByte + 4, 2);
            _distributionAppKeyIndex = tem16;
            memcpy(&tem8, dataByte+6, 1);
            _distributionTTL = tem8;
            memcpy(&tem16, dataByte + 7, 2);
            _distributionTimeoutBase = tem16;
            memcpy(&tem8, dataByte+9, 1);
            _distributionTransferMode = tem8 & 0b11;
            _updatePolicy = (tem8 >> 2) & 0b1;
            _RFU = (tem8 >> 3) & 0b11111;
            memcpy(&tem16, dataByte + 10, 2);
            _distributionFirmwareImageIndex = tem16;
        }
    }
    return self;
}

- (instancetype)initWithStatus:(SigFirmwareDistributionServerAndClientModelStatusType)status distributionPhase:(SigDistributionPhaseState)distributionPhase distributionMulticastAddress:(UInt16)distributionMulticastAddress distributionAppKeyIndex:(UInt16)distributionAppKeyIndex distributionTTL:(UInt8)distributionTTL distributionTimeoutBase:(UInt16)distributionTimeoutBase distributionTransferMode:(SigTransferModeState)distributionTransferMode updatePolicy:(SigUpdatePolicyType)updatePolicy RFU:(UInt8)RFU distributionFirmwareImageIndex:(UInt16)distributionFirmwareImageIndex {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionStatus;
        _status = status;
        _distributionPhase = distributionPhase;
        _distributionMulticastAddress = distributionMulticastAddress;
        _distributionAppKeyIndex = distributionAppKeyIndex;
        _distributionTTL = distributionTTL;
        _distributionTimeoutBase = distributionTimeoutBase;
        _distributionTransferMode = distributionTransferMode;
        _updatePolicy = updatePolicy;
        _RFU = RFU;
        _distributionFirmwareImageIndex = distributionFirmwareImageIndex;

        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        tem8 = status;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = distributionPhase;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem16 = distributionMulticastAddress;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = distributionAppKeyIndex;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem8 = distributionTTL;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem16 = distributionTimeoutBase;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem8 = (distributionTransferMode & 0b11) | ((updatePolicy & 0b1) << 2) | ((RFU & 0b11111) << 3);
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem16 = distributionFirmwareImageIndex;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        self.parameters = mData;
    }
    return self;
}

@end


@implementation SigFirmwareUpdateGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareUpdateStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareDistributionReceiversGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionReceiversGet;
    }
    return self;
}

- (instancetype)initWithFirstIndex:(UInt16)firstIndex entriesLimit:(UInt16)entriesLimit {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionReceiversGet;
        _firstIndex = firstIndex;
        _entriesLimit = entriesLimit;
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = firstIndex;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = entriesLimit;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        self.parameters = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionReceiversGet;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length != 4) {
            return nil;
        }
        UInt16 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 2);
        _firstIndex = tem;
        memcpy(&tem, dataByte + 2, 2);
        _entriesLimit = tem;
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionReceiversList class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareDistributionReceiversList

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionReceiversList;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionReceiversList;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length < 4 || ((parameters.length - 4) % 5) != 0) {
            return nil;
        }
        UInt16 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 2);
        _receiversListCount = tem;
        memcpy(&tem, dataByte + 2, 2);
        _firstIndex = tem;

        NSMutableArray *mArray = [NSMutableArray array];
        while ((mArray.count * 5 + 4) < parameters.length) {
            SigUpdatingNodeEntryModel *model = [[SigUpdatingNodeEntryModel alloc] initWithParameters:[parameters subdataWithRange:NSMakeRange(mArray.count * 5 + 4, 5)]];
            [mArray addObject:model];
        }
        _receiversList = mArray;
    }
    return self;
}

- (instancetype)initWithReceiversListCount:(UInt16)receiversListCount firstIndex:(UInt16)firstIndex receiversList:(NSArray <SigUpdatingNodeEntryModel *>*)receiversList {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionReceiversList;
        _receiversListCount = receiversListCount;
        _firstIndex = firstIndex;
        _receiversList = [NSMutableArray arrayWithArray:receiversList];

        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = 0;
        tem16 = receiversListCount;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = firstIndex;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        
        for (SigUpdatingNodeEntryModel *model in receiversList) {
            if (model && model.parameters && model.parameters.length > 0) {
                [mData appendData:model.parameters];
            }
        }
        self.parameters = mData;
    }
    return self;
}

@end


@implementation SigFirmwareDistributionReceiversAdd

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionReceiversAdd;
    }
    return self;
}

- (instancetype)initWithReceiverEntrysList:(NSArray <SigReceiverEntryModel *>*)receiverEntrysList {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionReceiversAdd;
        if (receiverEntrysList && receiverEntrysList.count) {
            _receiverEntrysList = [NSMutableArray arrayWithArray:receiverEntrysList];
            NSMutableData *mData = [NSMutableData data];
            for (SigReceiverEntryModel *model in receiverEntrysList) {
                [mData appendData:model.parameters];
            }
            self.parameters = mData;
        }
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionReceiversAdd;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length == 0 || (parameters.length % 3) != 0) {
            return nil;
        }
        NSMutableArray *mArray = [NSMutableArray array];
        while (mArray.count*3 < parameters.length) {
            SigReceiverEntryModel *model = [[SigReceiverEntryModel alloc] initWithParameters:[parameters subdataWithRange:NSMakeRange(mArray.count*3, 3)]];
            [mArray addObject:model];
        }
        _receiverEntrysList = mArray;
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionReceiversStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareDistributionReceiversDeleteAll

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionReceiversDeleteAll;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionReceiversDeleteAll;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionReceiversStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareDistributionReceiversStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionReceiversStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionReceiversStatus;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length < 3) {
            return nil;
        }
        UInt8 tem8 = 0;
        UInt16 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = tem8;
        memcpy(&tem, dataByte + 1, 2);
        _receiversListCount = tem;
    }
    return self;
}

- (instancetype)initWithStatus:(SigFirmwareDistributionServerAndClientModelStatusType)status receiversListCount:(UInt16)receiversListCount {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionReceiversStatus;
        _status = status;
        _receiversListCount = receiversListCount;
        
        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        tem8 = status;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem16 = receiversListCount;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        self.parameters = mData;
    }
    return self;
}

@end


@implementation SigFirmwareDistributionCapabilitiesGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionCapabilitiesGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionCapabilitiesGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareDistributionCapabilitiesStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareDistributionCapabilitiesStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionCapabilitiesStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionCapabilitiesStatus;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length < 17) {
            return nil;
        }
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        UInt32 tem32 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _maxDistributionReceiversListSize = tem16;
        memcpy(&tem16, dataByte + 2, 2);
        _maxFirmwareImagesListSize = tem16;
        memcpy(&tem32, dataByte + 4, 4);
        _maxFirmwareImageSize = tem32;
        memcpy(&tem32, dataByte + 8, 4);
        _maxUploadSpace = tem32;
        memcpy(&tem32, dataByte + 12, 4);
        _remainingUploadSpace = tem32;
        memcpy(&tem8, dataByte + 16, 1);
        _outOfBandRetrievalSupported = tem8;
        if (parameters.length > 17) {
            _supportedURISchemeNames = [parameters subdataWithRange:NSMakeRange(17, parameters.length - 17)];
        }
    }
    return self;
}

- (instancetype)initWithMaxDistributionReceiversListSize:(UInt16)maxDistributionReceiversListSize maxFirmwareImagesListSize:(UInt16)maxFirmwareImagesListSize maxFirmwareImageSize:(UInt32)maxFirmwareImageSize maxUploadSpace:(UInt32)maxUploadSpace remainingUploadSpace:(UInt32)remainingUploadSpace outOfBandRetrievalSupported:(UInt8)outOfBandRetrievalSupported {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareDistributionCapabilitiesStatus;
        _maxDistributionReceiversListSize = maxDistributionReceiversListSize;
        _maxFirmwareImagesListSize = maxFirmwareImagesListSize;
        _maxFirmwareImageSize = maxFirmwareImageSize;
        _maxUploadSpace = maxUploadSpace;
        _remainingUploadSpace = remainingUploadSpace;
        _outOfBandRetrievalSupported = outOfBandRetrievalSupported;
        
        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        UInt32 tem32 = 0;
        tem16 = maxDistributionReceiversListSize;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = maxFirmwareImagesListSize;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem32 = maxFirmwareImageSize;
        data = [NSData dataWithBytes:&tem32 length:4];
        [mData appendData:data];
        tem32 = maxUploadSpace;
        data = [NSData dataWithBytes:&tem32 length:4];
        [mData appendData:data];
        tem32 = remainingUploadSpace;
        data = [NSData dataWithBytes:&tem32 length:4];
        [mData appendData:data];
        tem8 = outOfBandRetrievalSupported;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        self.parameters = mData;
    }
    return self;
}

@end


@implementation SigFirmwareUpdateFirmwareMetadataCheck

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateFirmwareMetadataCheck;
    }
    return self;
}

- (instancetype)initWithUpdateFirmwareImageIndex:(UInt8)updateFirmwareImageIndex incomingFirmwareMetadata:(nullable NSData *)incomingFirmwareMetadata {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateFirmwareMetadataCheck;
        if (incomingFirmwareMetadata && incomingFirmwareMetadata.length) {
            _incomingFirmwareMetadata = [NSData dataWithData:incomingFirmwareMetadata];
        }
        _updateFirmwareImageIndex = updateFirmwareImageIndex;
        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = updateFirmwareImageIndex;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        if (incomingFirmwareMetadata && incomingFirmwareMetadata.length) {
            [mData appendData:incomingFirmwareMetadata];
        }
        self.parameters = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateFirmwareMetadataCheck;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length == 0) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _updateFirmwareImageIndex = tem8;
        if (parameters.length > 1) {
            _incomingFirmwareMetadata = [parameters subdataWithRange:NSMakeRange(1, parameters.length - 1)];
        } else {
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareUpdateFirmwareMetadataStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareUpdateFirmwareMetadataStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateFirmwareMetadataStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateFirmwareMetadataStatus;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length < 2) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = tem8 & 0b111;
        _additionalInformation = (tem8 >> 3) & 0b11111;
        memcpy(&tem8, dataByte+1, 1);
        _updateFirmwareImageIndex = tem8;
    }
    return self;
}

@end


@implementation SigFirmwareUpdateStart

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateStart;
    }
    return self;
}

- (instancetype)initWithUpdateTTL:(UInt8)updateTTL updateTimeoutBase:(UInt16)updateTimeoutBase updateBLOBID:(UInt64)updateBLOBID updateFirmwareImageIndex:(UInt8)updateFirmwareImageIndex incomingFirmwareMetadata:(nullable NSData *)incomingFirmwareMetadata {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateStart;
        _updateTTL = updateTTL;
        _updateTimeoutBase = updateTimeoutBase;
        _updateBLOBID = updateBLOBID;
        _updateFirmwareImageIndex = updateFirmwareImageIndex;
        _incomingFirmwareMetadata = [NSData dataWithData:incomingFirmwareMetadata];
        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = updateTTL;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        UInt16 tem16 = updateTimeoutBase;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        UInt64 tem64 = updateBLOBID;
        data = [NSData dataWithBytes:&tem64 length:8];
        [mData appendData:data];
        tem8 = updateFirmwareImageIndex;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        if (incomingFirmwareMetadata && incomingFirmwareMetadata.length) {
            [mData appendData:incomingFirmwareMetadata];
        }
        self.parameters = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateStart;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length < 1 + 2 + 8 + 1 + 2) {
            return nil;
        }
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        UInt64 tem64 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        memcpy(&tem16, dataByte + 1, 2);
        memcpy(&tem64, dataByte + 3, 8);
        _updateTTL = tem8;
        _updateTimeoutBase = tem16;
        _updateBLOBID = tem64;
        memcpy(&tem8, dataByte + 11, 1);
        _updateFirmwareImageIndex = tem8;
        if (_incomingFirmwareMetadata && _incomingFirmwareMetadata.length > 0) {
            _incomingFirmwareMetadata = [parameters subdataWithRange:NSMakeRange(12, parameters.length - 12)];
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareUpdateStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareUpdateCancel

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateCancel;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateCancel;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareUpdateStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareUpdateApply

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateApply;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateApply;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigFirmwareUpdateStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}
@end


@implementation SigFirmwareUpdateStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_FirmwareUpdateStatus;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || (parameters.length != 1 && parameters.length <= 13)) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = tem8 & 0b111;
        _RFU1 = (tem8 >> 3) & 0b11;
        _updatePhase = (tem8 >> 5) & 0b111;
        if (parameters.length > 1) {
            memcpy(&tem8, dataByte+1, 1);
            _updateTTL = tem8;
            memcpy(&tem8, dataByte+2, 1);
            _additionalInformation = tem8 & 0b11111;
            _RFU2 = (tem8 >> 5) & 0b111;
            UInt16 tem16 = 0;
            memcpy(&tem16, dataByte + 3, 2);
            _updateTimeoutBase = tem16;
            UInt64 tem64 = 0;
            memcpy(&tem64, dataByte + 5, 8);
            _updateBLOBID = tem64;
            memcpy(&tem8, dataByte+13, 1);
            _updateFirmwareImageIndex = tem8;
        }
    }
    return self;
}

@end


@implementation SigBLOBTransferGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBTransferGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBTransferGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigBLOBTransferStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigBLOBTransferStart

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBTransferStart;
    }
    return self;
}

- (instancetype)initWithTransferMode:(SigTransferModeState)transferMode BLOBID:(UInt64)BLOBID BLOBSize:(UInt32)BLOBSize BLOBBlockSizeLog:(UInt8)BLOBBlockSizeLog MTUSize:(UInt16)MTUSize {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBTransferStart;
        _RFU = 0;
        _transferMode = transferMode;
        _BLOBID = BLOBID;
        _BLOBSize = BLOBSize;
        _BLOBBlockSizeLog = BLOBBlockSizeLog;
        _MTUSize = MTUSize;
        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = (_transferMode << 6) | _RFU;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        UInt64 tem64 = BLOBID;
        data = [NSData dataWithBytes:&tem64 length:8];
        [mData appendData:data];
        UInt32 tem32 = BLOBSize;
        data = [NSData dataWithBytes:&tem32 length:4];
        [mData appendData:data];
        tem8 = BLOBBlockSizeLog;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        UInt16 tem16 = MTUSize;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        self.parameters = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBTransferStart;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length != 17) {
            return nil;
        }
        UInt64 tem64 = 0;
        UInt32 tem32 = 0;
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _RFU = tem8 & 0b111111;
        _transferMode = (tem8 >> 6) & 0b11;

        memcpy(&tem64, dataByte+1, 8);
        memcpy(&tem32, dataByte+1+8, 4);
        memcpy(&tem8, dataByte+1+8+4, 1);
        memcpy(&tem16, dataByte+1+8+4+1, 2);
        _BLOBID = tem64;
        _BLOBSize = tem32;
        _BLOBBlockSizeLog = tem8;
        _MTUSize = tem16;
    }
    return self;
}

- (Class)responseType {
    return [SigBLOBTransferStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigObjectTransferCancel

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBTransferCancel;
    }
    return self;
}

- (instancetype)initWithBLOBID:(UInt64)BLOBID {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBTransferCancel;
        _BLOBID = BLOBID;
        NSMutableData *mData = [NSMutableData data];
        UInt64 tem64 = BLOBID;
        NSData *data = [NSData dataWithBytes:&tem64 length:8];
        [mData appendData:data];
        self.parameters = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBTransferCancel;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length != 8) {
            return nil;
        }
        UInt64 tem64 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem64, dataByte, 8);
        _BLOBID = tem64;
    }
    return self;
}

- (Class)responseType {
    return [SigBLOBTransferStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigBLOBTransferStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBTransferStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBTransferStatus;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length < 2) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = tem8 & 0b1111;
        _RFU = (tem8 >> 4) & 0b11;
        _transferMode = (tem8 >> 6) & 0b11;
        memcpy(&tem8, dataByte+1, 1);
        _transferPhase = tem8;
        if (parameters.length >= 1+1+8) {
            UInt64 tem64 = 0;
            memcpy(&tem64, dataByte + 1 + 1, 8);
            _BLOBID = tem64;
            if (parameters.length >= 1+1+8+4+1+2+1) {
                UInt32 tem32 = 0;
                memcpy(&tem32, dataByte + 1 + 1 + 8, 4);
                _BLOBSize = tem32;
                memcpy(&tem8, dataByte+1+1+8+4, 1);
                _blockSizeLog = tem8;
                UInt16 tem16 = 0;
                memcpy(&tem16, dataByte+1+1+8+4+1, 2);
                _transferMTUSize = tem16;
                _blocksNotReceived = [parameters subdataWithRange:NSMakeRange(1+1+8+4+1+2, parameters.length - (1+1+8+4+1+2))];
            }
        }
    }
    return self;
}

- (instancetype)initWithStatus:(SigBLOBTransferStatusType)status RFU:(UInt8)RFU transferMode:(SigTransferModeState)transferMode transferPhase:(SigTransferPhaseState)transferPhase BLOBID:(UInt64)BLOBID BLOBSize:(UInt32)BLOBSize blockSizeLog:(UInt8)blockSizeLog transferMTUSize:(UInt16)transferMTUSize blocksNotReceived:(NSData *)blocksNotReceived {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBTransferStatus;
        _status = status;
        _RFU = RFU;
        _transferMode = transferMode;
        _transferPhase = transferPhase;
        _BLOBID = BLOBID;
        _BLOBSize = BLOBSize;
        _blockSizeLog = blockSizeLog;
        _transferMTUSize = transferMTUSize;
        _blocksNotReceived = blocksNotReceived;
        if (blocksNotReceived && blocksNotReceived.length > 0) {
            _blocksNotReceived = [NSData dataWithData:blocksNotReceived];
        }

        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        UInt32 tem32 = 0;
        UInt64 tem64 = 0;
        tem8 = (status & 0b1111) | ((RFU & 0b11) << 4) | ((transferMode & 0b11) << 6);
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = transferPhase;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem64 = BLOBID;
        data = [NSData dataWithBytes:&tem64 length:8];
        [mData appendData:data];
        tem32 = BLOBSize;
        data = [NSData dataWithBytes:&tem32 length:4];
        [mData appendData:data];
        tem8 = blockSizeLog;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem16 = transferMTUSize;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        if (blocksNotReceived && blocksNotReceived.length > 0) {
            [mData appendData:blocksNotReceived];
        }
        self.parameters = mData;
    }
    return self;
}

@end


@implementation SigBLOBBlockStart

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBBlockStart;
    }
    return self;
}

- (instancetype)initWithBlockNumber:(UInt16)blockNumber chunkSize:(UInt16)chunkSize {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBBlockStart;
        _blockNumber = blockNumber;
        _chunkSize = chunkSize;
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = blockNumber;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = chunkSize;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        self.parameters = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBBlockStart;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length < 4) {
            return nil;
        }
        Byte *dataByte = (Byte *)parameters.bytes;
        UInt16 tem16 = 0;
        memcpy(&tem16, dataByte, 2);
        _blockNumber = tem16;
        memcpy(&tem16, dataByte+2, 2);
        _chunkSize = tem16;
    }
    return self;
}

- (Class)responseType {
    return [SigBLOBBlockStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigObjectBlockTransferStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_ObjectBlockTransferStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_ObjectBlockTransferStatus;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = tem8;
    }
    return self;
}

@end


@implementation SigBLOBChunkTransfer

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBChunkTransfer;
    }
    return self;
}

- (instancetype)initWithChunkNumber:(UInt16)chunkNumber chunkData:(NSData *)chunkData sendBySegmentPdu:(BOOL)sendBySegmentPdu {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBChunkTransfer;
        _chunkNumber = chunkNumber;
        _chunkData = [NSData dataWithData:chunkData];
        _sendBySegmentPdu = sendBySegmentPdu;
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = chunkNumber;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        [mData appendData:chunkData];
        self.parameters = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBChunkTransfer;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length < 2+1) {
            return nil;
        }
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte, 2);
        _chunkNumber = tem16;
        if (parameters.length >= 2+1) {
            _chunkData = [parameters subdataWithRange:NSMakeRange(2, parameters.length-2)];
        }
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    UInt16 tem16 = _chunkNumber;
    NSData *data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    [mData appendData:_chunkData];
    return mData;
}

- (BOOL)isSegmented {
    //v3.3.0特殊处理：最后一个包如果为unsegment包，需使用segment包进行发送。即所有SigBLOBChunkTransfer都使用segment的发送发送即可。
    return _sendBySegmentPdu;
}

@end


@implementation SigBLOBBlockGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBBlockGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBBlockGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigBLOBBlockStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigBLOBPartialBlockReport

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBPartialBlockReport;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBPartialBlockReport;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil) {
            return nil;
        }
        if (parameters.length > 0) {
            NSArray *array = [LibTools getNumberListFromUTF8EncodeData:parameters];
            if (array) {
                _encodedMissingChunks = [NSMutableArray arrayWithArray:array];
            } else {
                _encodedMissingChunks = [NSMutableArray array];
            }
        }
    }
    return self;
}

@end


@implementation SigBLOBBlockStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBBlockStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBBlockStatus;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length < 5) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = tem8 & 0b1111;
        _RFU = (tem8 >> 4) & 0b11;
        _format = (tem8 >> 6) & 0b11;
        UInt16 tem16 = 0;
        memcpy(&tem16, dataByte+1, 2);
        _blockNumber = tem16;
        memcpy(&tem16, dataByte+3, 2);
        _chunkSize = tem16;
        if (_format == SigBLOBBlockFormatType_someChunksMissing) {
            if (parameters.length > 5) {
                NSMutableArray *array = [NSMutableArray array];
                UInt16 addressesLength = parameters.length - 5;
                UInt16 index = 0;
                while (addressesLength > index) {
                    memcpy(&tem8, dataByte+5+index, 1);
                    for (int i=0; i<8; i++) {
                        BOOL exist = (tem8 >> i) & 1;
                        if (exist) {
                            [array addObject:@(i+8*index)];
                        }
                    }
                    index++;
                }
                _missingChunksList = array;
            }
        } else if (_format == SigBLOBBlockFormatType_encodedMissingChunks) {
            if (parameters.length > 5) {
                NSMutableArray *array = [NSMutableArray arrayWithArray:[LibTools getNumberListFromUTF8EncodeData:[parameters subdataWithRange:NSMakeRange(5, parameters.length-5)]]];
                _encodedMissingChunksList = array;
            }
        }
    }
    return self;
}

- (instancetype)initWithStatus:(SigBLOBBlockStatusType)status RFU:(UInt8)RFU format:(SigBLOBBlockFormatType)format blockNumber:(UInt16)blockNumber chunkSize:(UInt16)chunkSize missingChunksList:(NSArray <NSNumber *>*)missingChunksList encodedMissingChunksList:(NSArray <NSNumber *>*)encodedMissingChunksList {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBBlockStatus;
        _status = status;
        _RFU = RFU;
        _format = format;
        _blockNumber = blockNumber;
        _chunkSize = chunkSize;
        if (missingChunksList) {
            _missingChunksList = [NSArray arrayWithArray:missingChunksList];
        } else {
            _missingChunksList = [NSArray array];
        }
        if (encodedMissingChunksList) {
            _encodedMissingChunksList = [NSArray arrayWithArray:encodedMissingChunksList];
        } else {
            _encodedMissingChunksList = [NSArray array];
        }

        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        tem8 = (status & 0b1111) | ((RFU & 0b11) << 4) | ((format & 0b11) << 6);
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem16 = blockNumber;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = chunkSize;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        //暂时不处理该逻辑，因为需要知道当前BLOB的chunks个数。
        if (format == SigBLOBBlockFormatType_someChunksMissing) {
            TeLogError(@"暂时不处理该逻辑，因为需要知道当前BLOB的chunks个数!!!");
//            if (missingChunksList && missingChunksList.count > 0) {
//                for (NSNumber *num in missingChunksList) {
//
//                }
//                [mData appendData:blocksNotReceived];
//            }
        } else if (format == SigBLOBBlockFormatType_encodedMissingChunks) {
            if (encodedMissingChunksList && encodedMissingChunksList.count > 0) {
                NSData *encodedMissingChunksListData = [LibTools getUTF8EncodeDataFromNumberList:encodedMissingChunksList];
                [mData appendData:encodedMissingChunksListData];
            }
        }
        self.parameters = mData;
    }
    return self;
}

@end


@implementation SigBLOBInformationGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBInformationGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBInformationGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigBLOBInformationStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigBLOBInformationStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBInformationStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBInformationStatus;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length < 13) {
            return nil;
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _minBlockSizeLog = tem8;
        memcpy(&tem8, dataByte+1, 1);
        _maxBlockSizeLog = tem8;
        UInt16 tem16 = 0;
        memcpy(&tem16, dataByte+2, 2);
        _maxChunksNumber = tem16;
        memcpy(&tem16, dataByte+4, 2);
        _maxChunkSize = tem16;
        UInt32 tem32 = 0;
        memcpy(&tem32, dataByte+6, 4);
        _maxBLOBSize = tem32;
        memcpy(&tem16, dataByte+10, 2);
        _MTUSize = tem16;
        memcpy(&tem8, dataByte+12, 1);
        _supportedTransferMode.value = tem8;
    }
    return self;
}

- (instancetype)initWithMinBlockSizeLog:(UInt8)minBlockSizeLog maxBlockSizeLog:(UInt8)maxBlockSizeLog maxChunksNumber:(UInt16)maxChunksNumber maxChunkSize:(UInt16)maxChunkSize maxBLOBSize:(UInt32)maxBLOBSize MTUSize:(UInt16)MTUSize supportedTransferMode:(struct SigSupportedTransferMode)supportedTransferMode {
    if (self = [super init]) {
        self.opCode = SigOpCode_BLOBInformationStatus;
        _minBlockSizeLog = minBlockSizeLog;
        _maxBlockSizeLog = maxBlockSizeLog;
        _maxChunksNumber = maxChunksNumber;
        _maxChunkSize = maxChunkSize;
        _maxBLOBSize = maxBLOBSize;
        _MTUSize = MTUSize;
        _supportedTransferMode = supportedTransferMode;

        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        UInt32 tem32 = 0;
        tem8 = minBlockSizeLog;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = maxBlockSizeLog;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem16 = maxChunksNumber;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = maxChunkSize;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem32 = maxBLOBSize;
        data = [NSData dataWithBytes:&tem32 length:4];
        [mData appendData:data];
        tem16 = MTUSize;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem8 = supportedTransferMode.value;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        self.parameters = mData;
    }
    return self;
}

@end


@implementation SigSubnetBridgeGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_SubnetBridgeGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_SubnetBridgeGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigSubnetBridgeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigSubnetBridgeSet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_SubnetBridgeSet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_SubnetBridgeSet;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length < 1) {
            return nil;
        }
        Byte *dataByte = (Byte *)parameters.bytes;
        UInt8 tem8 = 0;
        memcpy(&tem8, dataByte, 1);
        _subnetBridge = tem8;
    }
    return self;
}

- (instancetype)initWithSubnetBridge:(SigSubnetBridgeStateValues)subnetBridge {
    if (self = [super init]) {
        self.opCode = SigOpCode_SubnetBridgeSet;
        _subnetBridge = subnetBridge;
        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = subnetBridge;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        self.parameters = mData;
    }
    return self;
}

- (Class)responseType {
    return [SigSubnetBridgeStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigSubnetBridgeStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_SubnetBridgeStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_SubnetBridgeStatus;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length != 8) {
            return nil;
        }
        SigSubnetBridgeModel *model = [[SigSubnetBridgeModel alloc] initWithParameters:parameters];
        _subnetBridge = model;
    }
    return self;
}

- (instancetype)initWithSubnetBridge:(SigSubnetBridgeModel *)subnetBridge {
    if (self = [super init]) {
        self.opCode = SigOpCode_SubnetBridgeStatus;
        _subnetBridge = subnetBridge;
        self.parameters = [NSData dataWithData:subnetBridge.parameters];
    }
    return self;
}

@end


@implementation SigBridgeTableAdd

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableAdd;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableAdd;
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        if (parameters == nil || parameters.length != 8) {
            return nil;
        }
        SigSubnetBridgeModel *model = [[SigSubnetBridgeModel alloc] initWithParameters:parameters];
        _subnetBridge = model;
    }
    return self;
}

- (instancetype)initWithSubnetBridge:(SigSubnetBridgeModel *)subnetBridge {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableAdd;
        _subnetBridge = subnetBridge;
        self.parameters = [NSData dataWithData:subnetBridge.parameters];
    }
    return self;
}

- (Class)responseType {
    return [SigBridgeTableStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigBridgeTableRemove

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableRemove;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableRemove;
        if (parameters == nil || parameters.length != 7) {
            return nil;
        }
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        SigDirectionsFieldValues value = SigDirectionsFieldValues_prohibited;
        NSData *data = [NSData dataWithBytes:&value length:1];
        NSMutableData *mData = [NSMutableData dataWithData:parameters];
        [mData appendData:data];
        SigSubnetBridgeModel *model = [[SigSubnetBridgeModel alloc] initWithParameters:mData];
        _netKeyIndex1 = model.netKeyIndex1;
        _netKeyIndex2 = model.netKeyIndex2;
        _address1 = model.address1;
        _address2 = model.address2;
    }
    return self;
}

- (instancetype)initWithNetKeyIndex1:(UInt16)netKeyIndex1 netKeyIndex2:(UInt16)netKeyIndex2 address1:(UInt16)address1 address2:(UInt16)address2 {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableRemove;
        _netKeyIndex1 = netKeyIndex1;
        _netKeyIndex2 = netKeyIndex2;
        _address1 = address1;
        _address2 = address2;
        SigSubnetBridgeModel *model = [[SigSubnetBridgeModel alloc] initWithDirections:SigDirectionsFieldValues_prohibited netKeyIndex1:netKeyIndex1 netKeyIndex2:netKeyIndex2 address1:address1 address2:address2];
        self.parameters = [NSData dataWithData:[model.parameters subdataWithRange:NSMakeRange(1, 7)]];
    }
    return self;
}

- (Class)responseType {
    return [SigBridgeTableStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigBridgeTableStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableStatus;
        if (parameters == nil || parameters.length != 9) {
            return nil;
        }
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = tem8;
        SigSubnetBridgeModel *model = [[SigSubnetBridgeModel alloc] initWithParameters:[parameters subdataWithRange:NSMakeRange(1, 8)]];
        _subnetBridge = model;
    }
    return self;
}

- (instancetype)initWithStatus:(SigConfigMessageStatus)status subnetBridge:(SigSubnetBridgeModel *)subnetBridge {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableStatus;
        _status = status;
        _subnetBridge = subnetBridge;
        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = status;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        [mData appendData:subnetBridge.parameters];
        self.parameters = mData;
    }
    return self;
}

@end


@implementation SigBridgeSubnetsGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeSubnetsGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeSubnetsGet;
        if (parameters == nil || parameters.length != 3) {
            return nil;
        }
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _filter = tem8 >> 6;
        _prohibited = (tem8 >> 4) & 0b11;
        memcpy(&tem16, dataByte, 2);
        _netKeyIndex = tem16 & 0xFFF;
        memcpy(&tem8, dataByte+2, 1);
        _startIndex = tem8;
    }
    return self;
}

- (instancetype)initWithFilter:(SigFilterFieldValues)filter prohibited:(UInt8)prohibited netKeyIndex:(UInt16)netKeyIndex startIndex:(UInt8)startIndex {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeSubnetsGet;
        _filter = filter;
        _prohibited = prohibited;
        _netKeyIndex = netKeyIndex;
        _startIndex = startIndex;
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        tem16 = ((filter & 0b11) << 14) | ((prohibited & 0b11) << 12) | (startIndex & 0xFFF);
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        NSMutableData *mData = [NSMutableData dataWithData:data];
        tem8 = startIndex;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        self.parameters = mData;
    }
    return self;
}

- (Class)responseType {
    return [SigBridgeSubnetsList class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigBridgeSubnetsList

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeSubnetsList;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeSubnetsList;
        if (parameters == nil || parameters.length < 3) {
            return nil;
        }
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _filter = tem8 >> 6;
        _prohibited = (tem8 >> 4) & 0b11;
        memcpy(&tem16, dataByte, 2);
        _netKeyIndex = tem16 & 0xFFF;
        memcpy(&tem8, dataByte+2, 1);
        _startIndex = tem8;
        NSMutableArray *mArray = [NSMutableArray array];
        while (3 * (_bridgedSubnetsList.count + 1) + 3 >= parameters.length) {
            SigBridgeSubnetModel *model = [[SigBridgeSubnetModel alloc] initWithParameters:[parameters subdataWithRange:NSMakeRange(3 + 3 * _bridgedSubnetsList.count, 3)]];
            [mArray addObject:model];
        }
        _bridgedSubnetsList = mArray;
    }
    return self;
}

- (instancetype)initWithFilter:(SigFilterFieldValues)filter prohibited:(UInt8)prohibited netKeyIndex:(UInt16)netKeyIndex startIndex:(UInt8)startIndex bridgedSubnetsList:(NSArray <SigBridgeSubnetModel *>*)bridgedSubnetsList {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeSubnetsList;
        _filter = filter;
        _prohibited = prohibited;
        _netKeyIndex = netKeyIndex;
        _startIndex = startIndex;
        if (bridgedSubnetsList) {
            _bridgedSubnetsList = [NSArray arrayWithArray:bridgedSubnetsList];
        }
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        tem16 = ((filter & 0b11) << 14) | ((prohibited & 0b11) << 12) | (startIndex & 0xFFF);
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        NSMutableData *mData = [NSMutableData dataWithData:data];
        tem8 = startIndex;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        for (SigBridgeSubnetModel *model in bridgedSubnetsList) {
            if (model.parameters) {
                [mData appendData:model.parameters];
            }
        }
        self.parameters = mData;
    }
    return self;
}

@end


@implementation SigBridgeTableGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableGet;
        if (parameters == nil || parameters.length != 5) {
            return nil;
        }
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        SigBridgeSubnetModel *model = [[SigBridgeSubnetModel alloc] initWithParameters:[parameters subdataWithRange:NSMakeRange(0, 3)]];
        _netKeyIndex1 = model.netKeyIndex1;
        _netKeyIndex2 = model.netKeyIndex2;
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem16, dataByte+3, 2);
        _startIndex = tem16;

    }
    return self;
}

- (instancetype)initWithNetKeyIndex1:(UInt16)netKeyIndex1 netKeyIndex2:(UInt16)netKeyIndex2 startIndex:(UInt16)startIndex {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableGet;
        _netKeyIndex1 = netKeyIndex1;
        _netKeyIndex2 = netKeyIndex2;
        _startIndex = startIndex;
        SigBridgeSubnetModel *model = [[SigBridgeSubnetModel alloc] initWithNetKeyIndex1:netKeyIndex1 netKeyIndex2:netKeyIndex2];
        UInt16 tem16 = startIndex;
        NSData *data = [NSData dataWithBytes:&tem16 length:2];
        NSMutableData *mData = [NSMutableData dataWithData:model.parameters];
        [mData appendData:data];
        self.parameters = mData;
    }
    return self;
}

- (Class)responseType {
    return [SigBridgeTableList class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigBridgeTableList

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableList;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableList;
        if (parameters == nil || parameters.length < 6) {
            return nil;
        }
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        UInt8 tem8 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _status = tem8;
        SigBridgeSubnetModel *model = [[SigBridgeSubnetModel alloc] initWithParameters:[parameters subdataWithRange:NSMakeRange(1, 3)]];
        _netKeyIndex1 = model.netKeyIndex1;
        _netKeyIndex2 = model.netKeyIndex2;
        UInt16 tem16 = 0;
        memcpy(&tem16, dataByte+4, 2);
        _startIndex = tem16;
        NSMutableArray *mArray = [NSMutableArray array];
        while (6 + 5 * (mArray.count + 1) <= parameters.length) {
            SigBridgedAddressesModel *addressesModel = [[SigBridgedAddressesModel alloc] initWithParameters:[parameters subdataWithRange:NSMakeRange(6+5*mArray.count, 5)]];
            [mArray addObject:addressesModel];
        }
        _bridgedAddressesList = mArray;
    }
    return self;
}

- (instancetype)initWithStatus:(UInt8)status netKeyIndex1:(UInt16)netKeyIndex1 netKeyIndex2:(UInt16)netKeyIndex2 startIndex:(UInt16)startIndex bridgedAddressesList:(NSArray <SigBridgedAddressesModel *>*)bridgedAddressesList {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeTableList;
        _status = status;
        _netKeyIndex1 = netKeyIndex1;
        _netKeyIndex2 = netKeyIndex2;
        _startIndex = startIndex;
        if (bridgedAddressesList) {
            _bridgedAddressesList = [NSArray arrayWithArray:bridgedAddressesList];
        }
        
        UInt16 tem8 = status;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        NSMutableData *mData = [NSMutableData dataWithData:data];
        SigBridgeSubnetModel *model = [[SigBridgeSubnetModel alloc] initWithNetKeyIndex1:netKeyIndex1 netKeyIndex2:netKeyIndex2];
        [mData appendData:model.parameters];
        UInt16 tem16 = startIndex;
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        if (bridgedAddressesList && bridgedAddressesList.count > 0) {
            for (SigBridgedAddressesModel *addressesModel in bridgedAddressesList) {
                if (addressesModel.parameters) {
                    [mData appendData:addressesModel.parameters];
                }
            }
        }
        self.parameters = mData;
    }
    return self;
}

@end


@implementation SigBridgeCapabilityGet

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeCapabilityGet;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeCapabilityGet;
        if (parameters == nil || parameters.length == 0) {
            return self;
        }else{
            return nil;
        }
    }
    return self;
}

- (Class)responseType {
    return [SigBridgeCapabilityStatus class];
}

- (UInt32)responseOpCode {
    return ((SigMeshMessage *)[[self.responseType alloc] init]).opCode;
}

@end


@implementation SigBridgeCapabilityStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeCapabilityStatus;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeCapabilityStatus;
        if (parameters == nil || parameters.length != 3) {
            return nil;
        }
        if (parameters) {
            self.parameters = [NSData dataWithData:parameters];
        }
        UInt8 tem8 = 0;
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem8, dataByte, 1);
        _maxNumberOfBridgedSubnets = tem8;
        memcpy(&tem16, dataByte+1, 2);
        _maxNumberOfBridgedSubnets = tem16;
    }
    return self;
}

- (instancetype)initWithMaxNumberOfBridgedSubnets:(UInt8)maxNumberOfBridgedSubnets maxNumberOfBridgingTableEntries:(UInt16)maxNumberOfBridgingTableEntries {
    if (self = [super init]) {
        self.opCode = SigOpCode_BridgeCapabilityStatus;
        _maxNumberOfBridgedSubnets = maxNumberOfBridgedSubnets;
        _maxNumberOfBridgingTableEntries = maxNumberOfBridgingTableEntries;
        UInt8 tem8 = maxNumberOfBridgedSubnets;
        UInt16 tem16 = maxNumberOfBridgingTableEntries;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        NSMutableData *mData = [NSMutableData dataWithData:data];
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        self.parameters = mData;
    }
    return self;
}

@end


@implementation SigTelinkOnlineStatusMessage
- (instancetype)initWithAddress:(UInt16)address state:(DeviceState)state brightness:(UInt8)brightness temperature:(UInt8)temperature {
    if (self = [super init]) {
        _address = address;
        _state = state;
        _brightness = brightness;
        _temperature = temperature;
    }
    return self;
}
@end
