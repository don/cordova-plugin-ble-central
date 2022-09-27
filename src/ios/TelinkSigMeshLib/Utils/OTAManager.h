/********************************************************************************************************
 * @file     OTAManager.h 
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

#import <Foundation/Foundation.h>

typedef void(^singleDeviceCallBack)(SigNodeModel *device);
typedef void(^singleProgressCallBack)(float progress);
typedef void(^finishCallBack)(NSArray <SigNodeModel *>*successModels,NSArray <SigNodeModel *>*fileModels);

@interface OTAManager : NSObject


+ (instancetype)new __attribute__((unavailable("please initialize by use .share or .share()")));
- (instancetype)init __attribute__((unavailable("please initialize by use .share or .share()")));


+ (OTAManager *)share;

/**
 OTA，can not call repeat when app is OTAing
 
 @param otaData data for OTA
 @param models models for OTA
 @param singleSuccessAction callback when single model OTA  success
 @param singleFailAction callback when single model OTA  fail
 @param singleProgressAction callback with single model OTA progress
 @param finishAction callback when all models OTA finish
 @return  ture when call API success;false when call API fail.
 */
- (BOOL)startOTAWithOtaData:(NSData *)otaData models:(NSArray <SigNodeModel *>*)models singleSuccessAction:(singleDeviceCallBack)singleSuccessAction singleFailAction:(singleDeviceCallBack)singleFailAction singleProgressAction:(singleProgressCallBack)singleProgressAction finishAction:(finishCallBack)finishAction;

/// stop OTA
- (void)stopOTA;

@end
