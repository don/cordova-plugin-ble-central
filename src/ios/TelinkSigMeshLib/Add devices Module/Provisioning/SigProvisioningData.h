/********************************************************************************************************
 * @file     SigProvisioningData.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/8/22
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

@class SigDataSource,SigNetkeyModel,SigIvIndex;

UIKIT_EXTERN NSString *const sessionKeyOfCalculateKeys;
UIKIT_EXTERN NSString *const sessionNonceOfCalculateKeys;
UIKIT_EXTERN NSString *const deviceKeyOfCalculateKeys;

@interface SigProvisioningData : NSObject

@property (nonatomic, strong) SigNetkeyModel *networkKey;
@property (nonatomic, strong) SigIvIndex *ivIndex;
@property (nonatomic, assign) UInt16 unicastAddress;
@property (nonatomic, assign) Algorithm algorithm;
@property (nonatomic, strong) NSData *deviceKey;
@property (nonatomic, strong) NSData *provisionerRandom;
@property (nonatomic, strong) NSData *provisionerPublicKey;
@property (nonatomic, strong) NSData *sharedSecret;

@property (nonatomic, strong) NSData *provisioningInvitePDUValue;
@property (nonatomic, strong) NSData *provisioningCapabilitiesPDUValue;
@property (nonatomic, strong) NSData *provisioningStartPDUValue;
@property (nonatomic, strong) NSData *devicePublicKey;

- (instancetype)initWithAlgorithm:(Algorithm)algorithm;

- (void)prepareWithNetwork:(SigDataSource *)network networkKey:(SigNetkeyModel *)networkKey unicastAddress:(UInt16)unicastAddress;

/// Call this method when the device Public Key has been obtained. This must be called after generating keys.
/// @param data The device Public Key.
- (void)provisionerDidObtainWithDevicePublicKey:(NSData *)data;

/// Call this method when the Auth Value has been obtained.
- (void)provisionerDidObtainAuthValue:(NSData *)data;

/// Call this method when the device Provisioning Confirmation has been obtained.
- (void)provisionerDidObtainWithDeviceConfirmation:(NSData *)data;

/// Call this method when the device Provisioning Random has been obtained.
- (void)provisionerDidObtainWithDeviceRandom:(NSData *)data;

/// This method validates the received Provisioning Confirmation and matches it with one calculated locally based on the Provisioning Random received from the device and Auth Value.
- (BOOL)validateConfirmation;

/// Returns the Provisioner Confirmation value. The Auth Value must be set prior to calling this method.
- (NSData *)provisionerConfirmation;

- (NSData *)getProvisioningData;

- (NSData *)getEncryptedProvisioningDataAndMicWithProvisioningData:(NSData *)provisioningData;

#pragma mark - Helper methods

- (void)generateProvisionerRandomAndProvisionerPublicKey;

@end

NS_ASSUME_NONNULL_END
