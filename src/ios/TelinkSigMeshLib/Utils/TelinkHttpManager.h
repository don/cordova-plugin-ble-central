/********************************************************************************************************
 * @file     TelinkHttpManager.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2020/4/29
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

NS_ASSUME_NONNULL_BEGIN

@class TelinkHttpRequest;
typedef void (^MyBlock) (id _Nullable result, NSError * _Nullable err);

@interface TelinkHttpManager : NSObject

+ (instancetype)new __attribute__((unavailable("please initialize by use .share or .share()")));
- (instancetype)init __attribute__((unavailable("please initialize by use .share or .share()")));


+ (TelinkHttpManager *)share;

/// 1.upload json dictionary
/// @param jsonDict json dictionary
/// @param timeout Upload data effective time
/// @param block result callback
- (void)uploadJsonDictionary:(NSDictionary *)jsonDict timeout:(NSInteger)timeout didLoadData:(MyBlock)block;

/// 2.download json dictionary
/// @param uuid identify of json dictionary
/// @param block result callback
- (void)downloadJsonDictionaryWithUUID:(NSString *)uuid didLoadData:(MyBlock)block;

/// 3.check firmware
/// @param firewareIDString current firmware id
/// @param updateURI update URI from the response of firmwareUpdateInformationGet
/// @param block result callback
- (void)firmwareCheckRequestWithFirewareIDString:(NSString *)firewareIDString updateURI:(NSString *)updateURI didLoadData:(MyBlock)block;

/// 4.get firmware
/// @param firewareIDString current firmware id
/// @param updateURI update URI from the response of firmwareUpdateInformationGet
/// @param block result callback
- (void)firmwareGetRequestWithFirewareIDString:(NSString *)firewareIDString updateURI:(NSString *)updateURI didLoadData:(MyBlock)block;

@end

NS_ASSUME_NONNULL_END
