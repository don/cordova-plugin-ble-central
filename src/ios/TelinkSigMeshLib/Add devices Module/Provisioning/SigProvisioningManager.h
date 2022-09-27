/********************************************************************************************************
 * @file     SigProvisioningManager.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/8/19
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

@class SigProvisioningData,SigAuthenticationModel;

typedef void(^prvisionResponseCallBack)(SigProvisioningPdu * _Nullable response);

@interface SigProvisioningManager : NSObject
@property (nonatomic,assign) AuthenticationMethod authenticationMethod;
@property (nonatomic,strong) SigAuthenticationModel *authenticationModel;
@property (nonatomic,strong) SigProvisioningData *provisioningData;
@property (nonatomic,copy,nullable) prvisionResponseCallBack provisionResponseBlock;

/// - seeAlso: MshPRFv1.0.1.pdf  (page.240)
/// Attention Timer state (See Section 4.2.9), default is 0.
@property (nonatomic, assign) UInt8 attentionDuration;

#pragma mark - Public properties

/// The provisioning capabilities of the device. This information is retrieved from the remote device during identification process.
@property (nonatomic, strong, nullable) SigProvisioningCapabilitiesPdu *provisioningCapabilities;

/// The Network Key to be sent to the device during provisioning.
@property (nonatomic, strong) SigNetkeyModel *networkKey;

/// The current state of the provisioning process.
@property (nonatomic, assign) ProvisioningState state;//init with ready


+ (instancetype)new __attribute__((unavailable("please initialize by use .share or .share()")));
- (instancetype)init __attribute__((unavailable("please initialize by use .share or .share()")));


+ (SigProvisioningManager *)share;

/// founcation1: no oob provision (CBPeripheral's state mush be CBPeripheralStateConnected.)
- (void)provisionWithUnicastAddress:(UInt16)unicastAddress networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess fail:(ErrorBlock)fail;

/// founcation2: static oob provision (CBPeripheral's state mush be CBPeripheralStateConnected.)
- (void)provisionWithUnicastAddress:(UInt16)unicastAddress networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex staticOobData:(NSData *)oobData provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess fail:(ErrorBlock)fail;

/// founcation3: provision (If CBPeripheral's state isn't CBPeripheralStateConnected, SDK will connect CBPeripheral in this api. )
/// @param peripheral CBPeripheral of CoreBluetooth will be provision.
/// @param unicastAddress address of new device.
/// @param networkKey networkKey
/// @param netkeyIndex netkeyIndex
/// @param provisionType ProvisionType_NoOOB means oob data is 16 bytes zero data, ProvisionType_StaticOOB means oob data is get from HTTP API.
/// @param staticOOBData oob data get from HTTP API when provisionType is ProvisionType_StaticOOB.
/// @param provisionSuccess callback when provision success.
/// @param fail callback when provision fail.
- (void)provisionWithPeripheral:(CBPeripheral *)peripheral unicastAddress:(UInt16)unicastAddress networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex provisionType:(ProvisionType)provisionType staticOOBData:(nullable NSData *)staticOOBData provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess fail:(ErrorBlock)fail;

/// founcation4: provision (If CBPeripheral's state isn't CBPeripheralStateConnected, SDK will connect CBPeripheral in this api. )
/// @param peripheral CBPeripheral of CoreBluetooth will be provision.
/// @param unicastAddress address of new device.
/// @param networkKey networkKey
/// @param netkeyIndex netkeyIndex
/// @param provisionType ProvisionType_NoOOB means oob data is 16 bytes zero data, ProvisionType_StaticOOB means oob data is get from HTTP API.
/// @param staticOOBData oob data get from HTTP API when provisionType is ProvisionType_StaticOOB.
/// @param provisionSuccess callback when provision success.
/// @param fail callback when provision fail.
- (void)certificateBasedProvisionWithPeripheral:(CBPeripheral *)peripheral unicastAddress:(UInt16)unicastAddress networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex provisionType:(ProvisionType)provisionType staticOOBData:(nullable NSData *)staticOOBData provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess fail:(ErrorBlock)fail;

@end

NS_ASSUME_NONNULL_END
