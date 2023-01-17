/********************************************************************************************************
 * @file     SigKeySet.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/9/28
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

#import "SigKeySet.h"

@implementation SigKeySet

@end


@implementation SigAccessKeySet
- (instancetype)initWithApplicationKey:(SigAppkeyModel *)applicationKey {
    if (self = [super init]) {
        _applicationKey = applicationKey;
    }
    return self;
}

- (SigNetkeyModel *)networkKey {
    return _applicationKey.getCurrentBoundNetKey;
}

- (NSData *)accessKey {
//    if (self.networkKey.phase == distributingKeys) {
//        NSData *oldkey = self.applicationKey.getDataOldKey;
//        if (oldkey != nil && oldkey.length != 0) {
//            return oldkey;
//        }
//        return _applicationKey.getDataKey;
//    }
    return _applicationKey.getDataKey;
}

- (UInt8)aid {
//    if (self.networkKey.phase == distributingKeys) {
//        UInt8 aid = self.applicationKey.oldAid;
//        if (aid != 0) {
//            return aid;
//        }
//        return _applicationKey.aid;
//    }
    return _applicationKey.aid;
}

- (NSString *)description {
    return[NSString stringWithFormat:@"<%p> - applicationKey:0x%@", self, [LibTools convertDataToHexStr:[self accessKey]]];
}

@end


@implementation SigDeviceKeySet

- (instancetype)init {
    if (self = [super init]) {
        _isInitAid = NO;
    }
    return self;
}

- (NSData *)accessKey {
    return [LibTools nsstringToHex:_node.deviceKey];
}

- (instancetype)initWithNetworkKey:(SigNetkeyModel *)networkKey node:(SigNodeModel *)node {
    if (self = [super init]) {
        self.networkKey = networkKey;
        _node = node;
        _isInitAid = NO;
    }
    return self;
}

- (NSString *)description {
    return[NSString stringWithFormat:@"<%p> - deviceKey:0x%@", self, [LibTools convertDataToHexStr:[self accessKey]]];
}

@end
