/********************************************************************************************************
 * @file     SigProxyConfigurationMessage.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/10/30
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

#import "SigProxyConfigurationMessage.h"

@implementation SigProxyConfigurationMessage

@end


@implementation SigStaticProxyConfigurationMessage

@end


@implementation SigAcknowledgedProxyConfigurationMessage

@end


@implementation SigStaticAcknowledgedProxyConfigurationMessage
- (UInt8)responseOpCode {
    return self.responseType.opCode;
}
@end


@implementation SigSetFilterType

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigProxyFilerOpcode_setFilterType;
        self.responseType = [[SigFilterStatus alloc] init];
    }
    return self;
}

- (instancetype)initWithType:(SigProxyFilerType)type {
    if (self = [super init]) {
        self.opCode = SigProxyFilerOpcode_setFilterType;
        self.responseType = [[SigFilterStatus alloc] init];
        _filterType = type;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        if (parameters == nil || parameters.length != 1) {
            return nil;
        }
        UInt8 tem = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        _filterType = tem;
        self.opCode = SigProxyFilerOpcode_setFilterType;
        self.responseType = [[SigFilterStatus alloc] init];
    }
    return self;
}

- (NSData *)parameters {
    UInt8 tem = _filterType;
    NSData *temData = [NSData dataWithBytes:&tem length:1];
    return temData;
}

@end


@implementation SigAddAddressesToFilter

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigProxyFilerOpcode_addAddressesToFilter;
        self.responseType = [[SigFilterStatus alloc] init];
        _addresses = [NSMutableArray array];
    }
    return self;
}

/// Creates the Add Addresses To Filter message.
///
/// - parameter addresses: The array of addresses to be added
///                        to the current filter.
- (instancetype)initWithAddresses:(NSArray <NSNumber *>*)addresses {
    if (self = [super init]) {
        self.opCode = SigProxyFilerOpcode_addAddressesToFilter;
        self.responseType = [[SigFilterStatus alloc] init];
        _addresses = [NSMutableArray arrayWithArray:addresses];
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        if (parameters == nil || parameters.length % 2 != 0) {
            return nil;
        }
        NSMutableArray *tem = [NSMutableArray array];
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        for (int i=0; 2*(i+1)>parameters.length; i++) {
            memcpy(&tem16, dataByte+2*i, 2);
            UInt16 bigTem = CFSwapInt16HostToBig(tem16);
//            UInt16 bigTem = tem16;
            [tem addObject:@(bigTem)];
        }
        _addresses = tem;
        self.opCode = SigProxyFilerOpcode_addAddressesToFilter;
        self.responseType = [[SigFilterStatus alloc] init];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    NSArray *addresses = [NSArray arrayWithArray:_addresses];
    for (NSNumber *bigNum in addresses) {
        UInt16 bigTem = CFSwapInt16HostToBig((UInt16)bigNum.intValue);
//        UInt16 bigTem = (UInt16)bigNum.intValue;
        NSData *temData = [NSData dataWithBytes:&bigTem length:2];
        [mData appendData:temData];
    }
    return mData;
}

@end


@implementation SigRemoveAddressesFromFilter

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigProxyFilerOpcode_removeAddressesFromFilter;
        self.responseType = [[SigFilterStatus alloc] init];
        _addresses = [NSMutableArray array];
    }
    return self;
}

/// Creates the Add Addresses To Filter message.
///
/// - parameter addresses: The array of addresses to be added
///                        to the current filter.
- (instancetype)initWithAddresses:(NSArray <NSNumber *>*)addresses {
    if (self = [super init]) {
        self.opCode = SigProxyFilerOpcode_removeAddressesFromFilter;
        self.responseType = [[SigFilterStatus alloc] init];
        _addresses = [NSMutableArray arrayWithArray:addresses];
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        if (parameters == nil || parameters.length % 2 != 0) {
            return nil;
        }
        NSMutableArray *tem = [NSMutableArray array];
        UInt16 tem16 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        for (int i=0; 2*(i+1)>parameters.length; i++) {
            memcpy(&tem16, dataByte+2*i, 2);
            UInt16 bigTem = CFSwapInt16HostToBig(tem16);
//            UInt16 bigTem = tem16;
            [tem addObject:@(bigTem)];
        }
        _addresses = tem;
        self.opCode = SigProxyFilerOpcode_removeAddressesFromFilter;
        self.responseType = [[SigFilterStatus alloc] init];
    }
    return self;
}

- (NSData *)parameters {
    NSMutableData *mData = [NSMutableData data];
    NSArray *addresses = [NSArray arrayWithArray:_addresses];
    for (NSNumber *bigNum in addresses) {
        UInt16 bigTem = CFSwapInt16HostToBig((UInt16)bigNum.intValue);
//        UInt16 bigTem = (UInt16)bigNum.intValue;
        NSData *temData = [NSData dataWithBytes:&bigTem length:2];
        [mData appendData:temData];
    }
    return mData;
}

@end


@implementation SigFilterStatus

- (instancetype)init {
    if (self = [super init]) {
        self.opCode = SigProxyFilerOpcode_filterStatus;
    }
    return self;
}

/// Creates a new Filter Status message.
///
/// - parameter type: The current filter type.
/// - parameter listSize: Number of addresses in the proxy
///                       filter list.
- (instancetype)initWithType:(SigProxyFilerType)type listSize:(UInt16)listSize {
    if (self = [super init]) {
        self.opCode = SigProxyFilerOpcode_filterStatus;
        _filterType = type;
        _listSize = listSize;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        if (parameters == nil || parameters.length != 3) {
            return nil;
        }
        UInt8 tem = 0;
        UInt16 tem2 = 0;
        Byte *dataByte = (Byte *)parameters.bytes;
        memcpy(&tem, dataByte, 1);
        memcpy(&tem2, dataByte+1, 2);
        _filterType = tem;
        _listSize = CFSwapInt16HostToBig(tem2);
//        _listSize = tem2;
        self.opCode = SigProxyFilerOpcode_filterStatus;
    }
    return self;
}

- (NSData *)parameters {
    UInt8 tem = _filterType;
    NSData *temData = [NSData dataWithBytes:&tem length:1];
    UInt16 temlistSize = CFSwapInt16HostToBig(_listSize);;
//    UInt16 temlistSize = _listSize;;
    NSData *temData2 = [NSData dataWithBytes:&temlistSize length:2];
    NSMutableData *mData = [NSMutableData dataWithData:temData];
    [mData appendData:temData2];
    return mData;
}

@end
