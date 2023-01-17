/********************************************************************************************************
 * @file     SigProvisioningData.m
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

#import "SigProvisioningData.h"
#import "SigModel.h"
#import "OpenSSLHelper.h"
#import "ec.h"
#import "SigECCEncryptHelper.h"
#if SUPPORTCARTIFICATEBASED
#import "OpenSSLHelper+EPA.h"
#endif

NSString *const sessionKeyOfCalculateKeys = @"sessionKeyOfCalculateKeys";
NSString *const sessionNonceOfCalculateKeys = @"sessionNonceOfCalculateKeys";
NSString *const deviceKeyOfCalculateKeys = @"deviceKeyOfCalculateKeys";

@interface SigProvisioningData ()

@property (nonatomic, strong) SigDataSource *network;

@property (nonatomic, strong) NSData *authValue;
@property (nonatomic, strong) NSData *deviceConfirmation;
@property (nonatomic, strong) NSData *deviceRandom;

@end

@implementation SigProvisioningData{
    EC_KEY *_seckey;
    NSData *_publicKeyDataLessThanIOS10;
}

- (instancetype)initWithAlgorithm:(Algorithm)algorithm {
    if (self = [super init]) {
        _algorithm = algorithm;
        [self generateProvisionerRandomAndProvisionerPublicKey];
    }
    return self;
}

/// (5.4.2.4 Authentication, MshPRFv1.0.1.pdf, page252) ConfirmationInputs = ProvisioningInvitePDUValue || ProvisioningCapabilitiesPDUValue || ProvisioningStartPDUValue || PublicKeyProvisioner || PublicKeyDevice
/// 1 + 11 + 5 + 64 + 64
/// The Confirmation Inputs is built over the provisioning process. It is composed for: Provisioning Invite PDU, Provisioning Capabilities PDU, Provisioning Start PDU, Provisioner's Public Key and device's Public Key.
- (NSData *)getConfirmationInputs {
    NSMutableData *mData = [NSMutableData data];
    if (self.provisioningInvitePDUValue && self.provisioningCapabilitiesPDUValue && self.provisioningStartPDUValue && self.provisionerPublicKey && self.devicePublicKey) {
        [mData appendData:self.provisioningInvitePDUValue];
        [mData appendData:self.provisioningCapabilitiesPDUValue];
        [mData appendData:self.provisioningStartPDUValue];
        [mData appendData:self.provisionerPublicKey];
        [mData appendData:self.devicePublicKey];
    }
    return mData;
}

- (void)prepareWithNetwork:(SigDataSource *)network networkKey:(SigNetkeyModel *)networkKey unicastAddress:(UInt16)unicastAddress {
    _network = network;
    _ivIndex = networkKey.ivIndex;
    _networkKey = networkKey;
    _unicastAddress = unicastAddress;
}

/// Call this method when the device Public Key has been obtained. This must be called after generating keys.
/// @param data The device Public Key.
- (void)provisionerDidObtainWithDevicePublicKey:(NSData *)data {
    if (data == nil || data.length == 0) {
        TeLogError(@"current piblickey isn't specified.");
        return;
    }
    self.sharedSecret = [SigECCEncryptHelper.share getSharedSecretWithDevicePublicKey:data];
}

/// Call this method when the Auth Value has been obtained.
- (void)provisionerDidObtainAuthValue:(NSData *)data {
    self.authValue = data;
}

/// Call this method when the device Provisioning Confirmation has been obtained.
- (void)provisionerDidObtainWithDeviceConfirmation:(NSData *)data {
    self.deviceConfirmation = data;
}

/// Call this method when the device Provisioning Random has been obtained.
- (void)provisionerDidObtainWithDeviceRandom:(NSData *)data {
    self.deviceRandom = data;
}

/// This method validates the received Provisioning Confirmation and matches it with one calculated locally based on the Provisioning Random received from the device and Auth Value.
- (BOOL)validateConfirmation {
    if (!self.deviceRandom || self.deviceRandom.length == 0 || !self.authValue || self.authValue.length == 0 || !self.sharedSecret || self.sharedSecret.length == 0) {
        TeLogDebug(@"provision info is lack.");
        return NO;
    }
    NSData *confirmation = nil;
    if (self.algorithm == Algorithm_fipsP256EllipticCurve) {
        confirmation = [self calculateConfirmationWithRandom:self.deviceRandom authValue:self.authValue];
    } else if (self.algorithm == Algorithm_fipsP256EllipticCurve_HMAC_SHA256) {
        confirmation = [self calculate_HMAC_SHA256_ConfirmationWithRandom:self.deviceRandom authValue:self.authValue];
    }
    if (![self.deviceConfirmation isEqualToData:confirmation]) {
        TeLogDebug(@"calculate Confirmation fail.");
        return NO;
    }
    return YES;
}

/// Returns the Provisioner Confirmation value. The Auth Value must be set prior to calling this method.
- (NSData *)provisionerConfirmation {
    NSData *confirmation = nil;
    if (self.algorithm == Algorithm_fipsP256EllipticCurve) {
        confirmation = [self calculateConfirmationWithRandom:self.provisionerRandom authValue:self.authValue];
    } else if (self.algorithm == Algorithm_fipsP256EllipticCurve_HMAC_SHA256) {
        confirmation = [self calculate_HMAC_SHA256_ConfirmationWithRandom:self.provisionerRandom authValue:self.authValue];
    }
    return confirmation;
}

- (NSData *)getProvisioningData {
    NSData *key = self.network.curNetKey;
    if (self.network.curNetkeyModel.phase == distributingKeys) {
        if (self.network.curNetkeyModel.oldKey) {
            key = [LibTools nsstringToHex:self.network.curNetkeyModel.oldKey];
        }
    }
    
    struct Flags flags = {};
    flags.value = 0;
    if (self.networkKey.phase == finalizing) {
        flags.value |= (1 << 0);
    }
    if (self.ivIndex.updateActive) {
        flags.value |= (1 << 1);
    }

    NSMutableData *mData = [NSMutableData dataWithData:key];
    UInt16 ind = CFSwapInt16BigToHost(self.networkKey.index);;
    NSData *nIndexData = [NSData dataWithBytes:&ind length:2];
    UInt8 f = flags.value;
    NSData *fData = [NSData dataWithBytes:&f length:1];
    UInt32 iv = CFSwapInt32HostToBig(self.ivIndex.index);
    NSData *ivData = [NSData dataWithBytes:&iv length:4];
    UInt16 address = CFSwapInt16BigToHost(self.unicastAddress);
    NSData *addressData = [NSData dataWithBytes:&address length:2];
    [mData appendData:nIndexData];
    [mData appendData:fData];
    [mData appendData:ivData];
    [mData appendData:addressData];
    return mData;
}

- (NSData *)getEncryptedProvisioningDataAndMicWithProvisioningData:(NSData *)provisioningData {
    NSDictionary *dict = [self calculateKeys];
    self.deviceKey = dict[deviceKeyOfCalculateKeys];
    NSData *sessionNonce = dict[sessionNonceOfCalculateKeys];
    NSData *sessionKey = dict[sessionKeyOfCalculateKeys];
    NSData *resultData = [[OpenSSLHelper share] calculateCCM:provisioningData withKey:sessionKey nonce:sessionNonce andMICSize:8 withAdditionalData:nil];
    return resultData;
}

#pragma mark - Helper methods

- (void)generateProvisionerRandomAndProvisionerPublicKey {
    if (self.algorithm == Algorithm_fipsP256EllipticCurve) {
        _provisionerRandom = [LibTools createRandomDataWithLength:16];
    } else if (self.algorithm == Algorithm_fipsP256EllipticCurve_HMAC_SHA256) {
        _provisionerRandom = [LibTools createRandomDataWithLength:32];
    }
    _provisionerPublicKey = [SigECCEncryptHelper.share getPublicKeyData];
//    TeLogInfo(@"app端的random=%@,publickey=%@",[LibTools convertDataToHexStr:_provisionerRandom],[LibTools convertDataToHexStr:_provisionerPublicKey]);
}

/// This method calculates the Provisioning Confirmation based on the Confirmation Inputs, 16-byte Random and 16-byte AuthValue.
/// @param data An array of 16 random bytes.
/// @param authValue The Auth Value calculated based on the Authentication Method.
/// @returns The Provisioning Confirmation value.
- (NSData *)calculateConfirmationWithRandom:(NSData *)data authValue:(NSData *)authValue {
    // Calculate the Confirmation Salt = s1(confirmationInputs).
//    TeLogDebug(@"confirmationInputs=%@",[LibTools convertDataToHexStr:self.confirmationInputs]);
    NSData *confirmationSalt = [[OpenSSLHelper share] calculateSalt:self.getConfirmationInputs];
    
    // Calculate the Confirmation Key = k1(ECDH Secret, confirmationSalt, 'prck')
    NSData *confirmationKey = [[OpenSSLHelper share] calculateK1WithN:self.sharedSecret salt:confirmationSalt andP:[@"prck" dataUsingEncoding:NSASCIIStringEncoding]];

    // Calculate the Confirmation Provisioner using CMAC(random + authValue)
    NSMutableData *confirmationData = [NSMutableData dataWithData:data];
    [confirmationData appendData:authValue];
    NSData *resultData = [[OpenSSLHelper share] calculateCMAC:confirmationData andKey:confirmationKey];

    return resultData;
}

- (NSData *)calculate_HMAC_SHA256_ConfirmationWithRandom:(NSData *)data authValue:(NSData *)authValue {
#if SUPPORTCARTIFICATEBASED
    // Calculate the Confirmation Salt = s2(confirmationInputs).
//    TeLogDebug(@"confirmationInputs=%@",[LibTools convertDataToHexStr:self.confirmationInputs]);
    NSData *confirmationSalt = [[OpenSSLHelper share] calculateSalt2:self.getConfirmationInputs];
    
    // Calculate the Confirmation Key = k5(ECDH Secret||Authvalue, confirmationSalt, 'prck256')
    NSMutableData *n = [NSMutableData dataWithData:self.sharedSecret];
    [n appendData:authValue];
    NSData *confirmationKey = [[OpenSSLHelper share] calculateK5WithN:n salt:confirmationSalt andP:[@"prck256" dataUsingEncoding:NSASCIIStringEncoding]];

    // Calculate the Confirmation Provisioner using HMAC_SHA256(random)
    NSData *resultData = [[OpenSSLHelper share] calculateHMAC_SHA256:data andKey:confirmationKey];

    return resultData;
#else
    return nil;
#endif
}

/// This method calculates the Session Key, Session Nonce and the Device Key based on the Confirmation Inputs, 16-byte Provisioner Random and 16-byte device Random.
/// @returns The Session Key, Session Nonce and the Device Key.
- (NSDictionary *)calculateKeys {
    // Calculate the Confirmation Salt = s1(confirmationInputs).
    NSData *confirmationSalt = nil;
    if (self.algorithm == Algorithm_fipsP256EllipticCurve) {
        confirmationSalt = [[OpenSSLHelper share] calculateSalt:self.getConfirmationInputs];
    } else if (self.algorithm == Algorithm_fipsP256EllipticCurve_HMAC_SHA256) {
#if SUPPORTCARTIFICATEBASED
        confirmationSalt = [[OpenSSLHelper share] calculateSalt2:self.getConfirmationInputs];
#endif
    }
    
    // Calculate the Provisioning Salt = s1(confirmationSalt + provisionerRandom + deviceRandom)
    NSMutableData *mData = [NSMutableData dataWithData:confirmationSalt];
    [mData appendData:self.provisionerRandom];
    [mData appendData:self.deviceRandom];
    NSData *provisioningSalt = [[OpenSSLHelper share] calculateSalt:mData];

    // The Session Key is derived as k1(ECDH Shared Secret, provisioningSalt, "prsk")
    NSData *sessionKey = [[OpenSSLHelper share] calculateK1WithN:self.sharedSecret salt:provisioningSalt andP:[@"prsk" dataUsingEncoding:NSASCIIStringEncoding]];

    // The Session Nonce is derived as k1(ECDH Shared Secret, provisioningSalt, "prsn")
    // Only 13 least significant bits of the calculated value are used.
    NSData *prsnData = [@"prsn" dataUsingEncoding:NSASCIIStringEncoding];
    NSData *sessionNoncek1 = [[OpenSSLHelper share] calculateK1WithN:self.sharedSecret salt:provisioningSalt andP:prsnData];
    NSData *sessionNonce = [sessionNoncek1 subdataWithRange:NSMakeRange(3, sessionNoncek1.length - 3)];

    // 3.8.6.1 Device key
    // The Device Key is derived as k1(ECDH Shared Secret, provisioningSalt, "prdk")
    NSData *deviceKey = [[OpenSSLHelper share] calculateK1WithN:self.sharedSecret salt:provisioningSalt andP:[@"prdk" dataUsingEncoding:NSASCIIStringEncoding]];

    NSDictionary *resultDict = @{sessionKeyOfCalculateKeys:sessionKey,sessionNonceOfCalculateKeys:sessionNonce,deviceKeyOfCalculateKeys:deviceKey};
    
    return resultDict;
}

@end
