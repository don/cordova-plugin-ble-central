/********************************************************************************************************
 * @file     SigAddDeviceManager.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SigAppkeyModel;

@interface SigAddDeviceManager : NSObject
@property (nonatomic, assign) BOOL needDisconnectBetweenProvisionToKeyBind;//default YES
@property (nonatomic, assign) UInt8 retryCount;//retry count of provision and keybind, default 3


+ (instancetype)new __attribute__((unavailable("please initialize by use .share or .share()")));
- (instancetype)init __attribute__((unavailable("please initialize by use .share or .share()")));


+ (SigAddDeviceManager *)share;

/// function1 :add bluetooth devices (auto add)
- (void)startAddDeviceWithNextAddress:(UInt16)address networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex appkeyModel:(SigAppkeyModel *)appkeyModel unicastAddress:(UInt16)unicastAddress uuid:(nullable NSData *)uuid keyBindType:(KeyBindType)type productID:(UInt16)productID cpsData:(nullable NSData *)cpsData isAutoAddNextDevice:(BOOL)isAuto provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess provisionFail:(ErrorBlock)provisionFail keyBindSuccess:(addDevice_keyBindSuccessCallBack)keyBindSuccess keyBindFail:(ErrorBlock)keyBindFail finish:(AddDeviceFinishCallBack)finish;

/// function2 :add bluetooth device (single add)
- (void)startAddDeviceWithNextAddress:(UInt16)address networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex appkeyModel:(SigAppkeyModel *)appkeyModel peripheral:(CBPeripheral *)peripheral provisionType:(ProvisionType)provisionType staticOOBData:(nullable NSData *)staticOOBData keyBindType:(KeyBindType)type productID:(UInt16)productID cpsData:(nullable NSData *)cpsData provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess provisionFail:(ErrorBlock)provisionFail keyBindSuccess:(addDevice_keyBindSuccessCallBack)keyBindSuccess keyBindFail:(ErrorBlock)keyBindFail;

- (void)startCertificateBasedWithAddress:(UInt16)address networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex appkeyModel:(SigAppkeyModel *)appkeyModel peripheral:(CBPeripheral *)peripheral provisionType:(ProvisionType)provisionType staticOOBData:(nullable NSData *)staticOOBData keyBindType:(KeyBindType)type productID:(UInt16)productID cpsData:(nullable NSData *)cpsData provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess provisionFail:(ErrorBlock)provisionFail keyBindSuccess:(addDevice_keyBindSuccessCallBack)keyBindSuccess keyBindFail:(ErrorBlock)keyBindFail;

/*
 parameter of SigAddConfigModel:
 
    1.normal provision + normal keybind:
peripheral+unicastAddress+networkKey+netkeyIndex+appKey+appkeyIndex+provisionType:ProvisionType_NoOOB+keyBindType:KeyBindType_Normal
    2.normal provision + fast keybind:
 peripheral+unicastAddress+networkKey+netkeyIndex+appKey+appkeyIndex+provisionType:ProvisionType_NoOOB+keyBindType:KeyBindType_Fast+productID+cpsData
    3.static oob provision(cloud oob) + normal keybind:
 peripheral+unicastAddress+networkKey+netkeyIndex+appKey+appkeyIndex+provisionType:ProvisionType_StaticOOB+staticOOBData+keyBindType:KeyBindType_Normal
    4.static oob provision(cloud oob) + fast keybind:
 peripheral+unicastAddress+networkKey+netkeyIndex+appKey+appkeyIndex+provisionType:ProvisionType_StaticOOB+staticOOBData+keyBindType:KeyBindType_Fast+productID+cpsData
 */
/// Add Single Device (provision+keyBind)
/// @param configModel all config message of add device.
/// @param provisionSuccess callback when provision success.
/// @param provisionFail callback when provision fail.
/// @param keyBindSuccess callback when keybind success.
/// @param keyBindFail callback when keybind fail.
- (void)startAddDeviceWithSigAddConfigModel:(SigAddConfigModel *)configModel provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess provisionFail:(ErrorBlock)provisionFail keyBindSuccess:(addDevice_keyBindSuccessCallBack)keyBindSuccess keyBindFail:(ErrorBlock)keyBindFail;

@end

NS_ASSUME_NONNULL_END
