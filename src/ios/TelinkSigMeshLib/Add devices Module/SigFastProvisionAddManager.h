/********************************************************************************************************
 * @file     SigFastProvisionAddManager.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ScanCallbackOfFastProvisionCallBack)(NSData *deviceKey,NSString *macAddress,UInt16 address,UInt16 pid);
typedef void(^StartProvisionCallbackOfFastProvisionCallBack)(void);
typedef void(^AddSingleDeviceSuccessOfFastProvisionCallBack)(NSData *deviceKey,NSString *macAddress,UInt16 address,UInt16 pid);

@interface SigFastProvisionAddManager : NSObject


+ (instancetype)new __attribute__((unavailable("please initialize by use .share or .share()")));
- (instancetype)init __attribute__((unavailable("please initialize by use .share or .share()")));


+ (SigFastProvisionAddManager *)share;


/// start FastProvision with only one PID
/// @param provisionAddress  new unicastAddress for unprovision device.
/// @param productId  product id of unprovision device, 0xffff means provision all unprovision device, but develop can't use 0xffff in this api.
/// @param compositionData compositionData of node in this productId.
/// @param unprovisioned current Connected Node Is Unprovisioned?
/// @param scanResponseBlock callback when SDK scaned unprovision devcie successful.
/// @param startProvisionBlock callback when SDK start provision devcie.
/// @param singleSuccess callback when SDK add single devcie successful.
/// @param finish callback when fast provision finish, fast provision successful when error is nil.
- (void)startFastProvisionWithProvisionAddress:(UInt16)provisionAddress productId:(UInt16)productId compositionData:(NSData *)compositionData currentConnectedNodeIsUnprovisioned:(BOOL)unprovisioned scanResponseCallback:(ScanCallbackOfFastProvisionCallBack)scanResponseBlock startProvisionCallback:(StartProvisionCallbackOfFastProvisionCallBack)startProvisionBlock addSingleDeviceSuccessCallback:(AddSingleDeviceSuccessOfFastProvisionCallBack)singleSuccess finish:(ErrorBlock)finish;


/// start FastProvision with some PIDs
/// @param provisionAddress  new unicastAddress for unprovision device.
/// @param productIds  product id of unprovision device, 0xffff means provision all unprovision device, but develop can't use 0xffff in this api. Develop need input a list of product id of unprovision device, this api will check the composition data of them, if any composition data is non-existent in SigDataSource.share.defaultNodeInfos, this api will callback finish with error immediately.
/// @param unprovisioned current Connected Node Is Unprovisioned?
/// @param scanResponseBlock callback when SDK scaned unprovision devcie successful.
/// @param startProvisionBlock callback when SDK start provision devcie.
/// @param singleSuccess callback when SDK add single devcie successful.
/// @param finish callback when fast provision finish, fast provision successful when error is nil.
- (void)startFastProvisionWithProvisionAddress:(UInt16)provisionAddress productIds:(NSArray <NSNumber *>*)productIds currentConnectedNodeIsUnprovisioned:(BOOL)unprovisioned scanResponseCallback:(ScanCallbackOfFastProvisionCallBack)scanResponseBlock startProvisionCallback:(StartProvisionCallbackOfFastProvisionCallBack)startProvisionBlock addSingleDeviceSuccessCallback:(AddSingleDeviceSuccessOfFastProvisionCallBack)singleSuccess finish:(ErrorBlock)finish;

#pragma mark - command

/// reset network
/// @param delayMillisecond  delay of reset network, the unit is millisecond.
- (void)fastProvisionResetNetworkWithDelayMillisecond:(UInt16)delayMillisecond successCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback;

/// get address
/// @param productId  product id of unprovision device, 0xffff means provision all unprovision device.
- (void)fastProvisionGetAddressWithProductId:(UInt16)productId successCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback;

/// set address
/// @param provisionAddress  new unicastAddress for unprovision device.
/// @param macAddressData  macAddress of unprovision device.
/// @param destination unicastAddress of connected node.
- (void)fastProvisionSetAddressWithProvisionAddress:(UInt16)provisionAddress macAddressData:(NSData *)macAddressData toDestination:(UInt16)destination successCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback;

/// get address retry
/// @param productId  product id of unprovision device, 0xffff means provision all unprovision device.
/// @param provisionAddress  new unicastAddress for unprovision device.
- (void)fastProvisionGetAddressRetryWithProductId:(UInt16)productId provisionAddress:(UInt16)provisionAddress successCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback;

/// set new network info
- (void)fastProvisionSetNetworkInfoWithSuccessCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback;

/// confirm of set network info
- (void)fastProvisionConfirmWithSuccessCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback;

/// complete, recovery to new network info.
/// @param delayMillisecond  delay of recovery to new network info, the unit is millisecond.
- (void)fastProvisionCompleteWithDelayMillisecond:(UInt16)delayMillisecond successCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback;

@end

NS_ASSUME_NONNULL_END
