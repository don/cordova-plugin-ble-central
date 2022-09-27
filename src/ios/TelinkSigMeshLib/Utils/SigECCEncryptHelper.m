/********************************************************************************************************
 * @file     SigECCEncryptHelper.m
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

#import "SigECCEncryptHelper.h"
#import <Security/Security.h>
#import "GMEllipticCurveCrypto.h"

static const UInt8 publicKeyIdentifier[] = "com.apple.sample.publickey/0";
static const UInt8 privateKeyIdentifier[] = "com.apple.sample.privatekey/0";

@interface SigSeckeyModel : NSObject
@property (nonatomic, assign) SecKeyRef privateKey;
@property (nonatomic, assign) SecKeyRef publicKey;
@end
@implementation SigSeckeyModel
@end

@interface SigECCEncryptHelper ()
@property (nonatomic, strong) SigSeckeyModel *seckeyModel;
@property (nonatomic, strong) NSData *publicKeyLowIos10;
@property (nonatomic, strong) NSData *privateKeyLowIos10;
@property (nonatomic, strong) GMEllipticCurveCrypto *crypto;

@end

@implementation SigECCEncryptHelper

+ (SigECCEncryptHelper *)share{
    static SigECCEncryptHelper *shareHelper = nil;
    static dispatch_once_t tempOnce=0;
    dispatch_once(&tempOnce, ^{
        shareHelper = [[SigECCEncryptHelper alloc] init];
        shareHelper.seckeyModel = [[SigSeckeyModel alloc] init];
    });
    return shareHelper;
}

- (void)eccInit {
//    __weak typeof(self) weakSelf = self;
    [self getECCKeyPair:^(NSData * _Nonnull publicKey, NSData * _Nonnull privateKey) {
        if (@available(iOS 10.0, *)) {
//            TeLogVerbose(@"init ECC bigger than ios10, publicKey=%@,privateKey=%@",weakSelf.seckeyModel.publicKey,weakSelf.seckeyModel.privateKey);
        } else {
//            TeLogVerbose(@"init ECC lower than ios10, publicKey=%@,privateKey=%@",weakSelf.publicKeyLowIos10,weakSelf.privateKeyLowIos10);
        }
    }];
}

///返回手机端64字节的ECC公钥
- (NSData *)getPublicKeyData {
    if (@available(iOS 10.0, *)) {
        if (self.seckeyModel && self.seckeyModel.publicKey) {
            NSData *pub = [self getPublicKeyBitsFromKey:self.seckeyModel.publicKey];
            return [pub subdataWithRange:NSMakeRange(1, pub.length-1)];
        } else {
            return nil;
        }
    } else {
        return self.publicKeyLowIos10;
    }
}

- (void)getECCKeyPair:(keyPair)pair{
    if (@available(iOS 10.0, *)) {
        [self getECCKeyPairWithKeySize:256 keyPair:pair];
    } else {
        _crypto = [GMEllipticCurveCrypto generateKeyPairForCurve:GMEllipticCurveSecp256r1];
        _crypto.compressedPublicKey = NO;
        self.publicKeyLowIos10 = [_crypto.publicKey subdataWithRange:NSMakeRange(1, _crypto.publicKey.length-1)];
        self.privateKeyLowIos10 = _crypto.privateKey;
        if (pair) {
            pair(self.publicKeyLowIos10,self.privateKeyLowIos10);
        }
    }
}

- (NSData *)getSharedSecretWithDevicePublicKey:(NSData *)devicePublicKey {
    if (@available(iOS 10.0, *)) {
        return [self calculateSharedSecretEithPublicKey:devicePublicKey];
    } else {
        UInt8 tem = 0x04;
        NSMutableData *devicePublicKeyData = [NSMutableData dataWithBytes:&tem length:1];
        [devicePublicKeyData appendData:devicePublicKey];
        GMEllipticCurveCrypto *deviceKeyCrypto = [GMEllipticCurveCrypto cryptoForKey:devicePublicKeyData];
        deviceKeyCrypto.compressedPublicKey = YES;
        NSData *sharedSecretKeyData = [_crypto sharedSecretForPublicKey:deviceKeyCrypto.publicKey];
    //    TeLogInfo(@"sharedSecretKeyData=%@",sharedSecretKeyData);
        return sharedSecretKeyData;
    }
}

#pragma mark -  =============苹果自带方法=====================

- (void)getECCKeyPairWithKeySize:(int)keySize keyPair:(keyPair)pair;
{
    OSStatus status = noErr;
    if (keySize == 256 || keySize == 512 || keySize == 1024 || keySize == 2048) {
        
        //定义dictionary，用于传递SecKeyGeneratePair函数中的第1个参数。
        NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init];
        
        //把第1步中定义的字符串转换为NSData对象。
        NSData * publicTag = [NSData dataWithBytes:publicKeyIdentifier
                                            length:strlen((const char *)publicKeyIdentifier)];
        NSData * privateTag = [NSData dataWithBytes:privateKeyIdentifier
                                             length:strlen((const char *)privateKeyIdentifier)];
        //为公／私钥对准备SecKeyRef对象。
        SecKeyRef publicKey = NULL;
        SecKeyRef privateKey = NULL;
        //
        //设置密钥对的密钥类型为kSecAttrKeyTypeEC。
        [keyPairAttr setObject:(id)kSecAttrKeyTypeEC forKey:(id)kSecAttrKeyType];
        //设置密钥对的密钥长度为256。
        [keyPairAttr setObject:[NSNumber numberWithInt:keySize] forKey:(id)kSecAttrKeySizeInBits];
        
        //设置私钥的持久化属性（即是否存入钥匙串）为YES。
        [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecAttrIsPermanent];
        [privateKeyAttr setObject:privateTag forKey:(id)kSecAttrApplicationTag];
        
        //设置公钥的持久化属性（即是否存入钥匙串）为YES。
        [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecAttrIsPermanent];
        [publicKeyAttr setObject:publicTag forKey:(id)kSecAttrApplicationTag];
        
        // 把私钥的属性集（dictionary）加到密钥对的属性集（dictionary）中。
        [keyPairAttr setObject:privateKeyAttr forKey:(id)kSecPrivateKeyAttrs];
        [keyPairAttr setObject:publicKeyAttr forKey:(id)kSecPublicKeyAttrs];
        
        //生成密钥对
        status = SecKeyGeneratePair((CFDictionaryRef)keyPairAttr,&publicKey, &privateKey); // 13
        if (status == noErr && publicKey != NULL && privateKey != NULL) {
            self.seckeyModel.publicKey = publicKey;
            self.seckeyModel.privateKey = privateKey;
            pair([self getPublicKeyBitsFromKey:publicKey],[NSData data]);
        }else{
            pair([NSData data],[NSData data]);
        }
    }
}

- (NSData *)getPublicKeyBitsFromKey:(SecKeyRef)givenKey {
    NSData *publicTag = [[NSData alloc] initWithBytes:publicKeyIdentifier length:sizeof(publicKeyIdentifier)];
    
    OSStatus sanityCheck = noErr;
    NSData * publicKeyBits = nil;
    
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeEC forKey:(__bridge id)kSecAttrKeyType];
    
    // Temporarily add key to the Keychain, return as data:
    NSMutableDictionary * attributes = [queryPublicKey mutableCopy];
    [attributes setObject:(__bridge id)givenKey forKey:(__bridge id)kSecValueRef];
    [attributes setObject:@YES forKey:(__bridge id)kSecReturnData];
    CFTypeRef result;
    sanityCheck = SecItemAdd((__bridge CFDictionaryRef) attributes, &result);
    if (sanityCheck == errSecSuccess) {
        publicKeyBits = CFBridgingRelease(result);
        
        // Remove from Keychain again:
        (void)SecItemDelete((__bridge CFDictionaryRef) queryPublicKey);
    }
    
    return publicKeyBits;
}

/// Calculates the Shared Secret based on the given Public Key
/// and the local Private Key.
///
/// - parameter publicKey: The device's Public Key as bytes.
/// - returns: The ECDH Shared Secret.
- (NSData *)calculateSharedSecretEithPublicKey:(NSData *)publicKey {
    // First byte has to be 0x04 to indicate uncompressed representation.
    UInt8 tem = 0x04;
    NSMutableData *devicePublicKeyData = [NSMutableData dataWithBytes:&tem length:1];
    [devicePublicKeyData appendData:publicKey];
    
    NSMutableDictionary * pubKeyParameters = [[NSMutableDictionary alloc] init];
    [pubKeyParameters setObject:(id)kSecAttrKeyTypeEC forKey:(id)kSecAttrKeyType];
    [pubKeyParameters setObject:(__bridge id)kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    
    CFErrorRef *err = nil;
    SecKeyRef devicePublicKey = NULL;
    
    if (@available(iOS 10.0, *)) {
        devicePublicKey = SecKeyCreateWithData((CFDataRef)devicePublicKeyData, (CFDictionaryRef)pubKeyParameters, err);
    }
    if (err) {
        TeLogError(@"SecKeyCreateWithData fail.");
        return nil;
    }
    
    NSMutableDictionary * exchangeResultParams = [[NSMutableDictionary alloc] init];
    if (@available(iOS 10.0, *)) {
        [exchangeResultParams setObject:@(32) forKey:(id)kSecKeyKeyExchangeParameterRequestedSize];
    }
    
    NSData *ssk;
    if (@available(iOS 10.0, *)) {
        ssk = CFBridgingRelease(SecKeyCopyKeyExchangeResult(self.seckeyModel.privateKey, kSecKeyAlgorithmECDHKeyExchangeStandard, devicePublicKey, (CFDictionaryRef)exchangeResultParams, err));
    }
    
    if (err) {
        TeLogError(@"SecKeyCopyKeyExchangeResult fail.");
        return nil;
    }
    
    return ssk;
}

@end
