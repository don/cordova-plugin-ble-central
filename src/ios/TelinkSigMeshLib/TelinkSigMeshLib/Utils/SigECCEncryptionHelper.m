/********************************************************************************************************
 * @file     SigECCEncryptionHelper.m
 *
 * @brief    for TLSR chips
 *
 * @author     telink
 * @date     Sep. 30, 2010
 *
 * @par      Copyright (c) 2010, Telink Semiconductor (Shanghai) Co., Ltd.
 *           All rights reserved.
 *
 *             The information contained herein is confidential and proprietary property of Telink
 *              Semiconductor (Shanghai) Co., Ltd. and is available under the terms
 *             of Commercial License Agreement between Telink Semiconductor (Shanghai)
 *             Co., Ltd. and the licensee in separate contract or the terms described here-in.
 *           This heading MUST NOT be removed from this file.
 *
 *              Licensees are granted free, non-transferable use of the information in this
 *             file under Mutual Non-Disclosure Agreement. NO WARRENTY of ANY KIND is provided.
 *
 *******************************************************************************************************/
//
//  SigECCEncryptionHelper.m
//  TelinkSigMeshLib
//
//  Created by 梁家誌 on 2019/8/22.
//  Copyright © 2019年 Telink. All rights reserved.
//

#import "SigECCEncryptHelper.h"
#import "GMEllipticCurveCrypto.h"

@interface SigECCEncryptHelper ()
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
    });
    return shareHelper;
}

- (void)eccInit {
//    __weak typeof(self) weakSelf = self;
    [self getECCKeyPair:^(NSData * _Nonnull publicKey, NSData * _Nonnull privateKey) {
//        TeLogInfo(@"init ECC successful, publicKey=%@,privateKey=%@",weakSelf.publicKeyLowIos10,weakSelf.privateKeyLowIos10);
    }];
}

///返回手机端64字节的ECC公钥
- (NSData *)getPublicKeyData {
    return self.publicKeyLowIos10;
}

- (void)getECCKeyPair:(keyPair)pair{
    _crypto = [GMEllipticCurveCrypto generateKeyPairForCurve:GMEllipticCurveSecp256r1];
    _crypto.compressedPublicKey = NO;
    self.publicKeyLowIos10 = [_crypto.publicKey subdataWithRange:NSMakeRange(1, _crypto.publicKey.length-1)];
    self.privateKeyLowIos10 = _crypto.privateKey;
    if (pair) {
        pair(self.publicKeyLowIos10,self.privateKeyLowIos10);
    }
}

- (NSData *)getSharedSecretWithDevicePublicKey:(NSData *)devicePublicKey {
    UInt8 tem = 0x04;
    NSMutableData *devicePublicKeyData = [NSMutableData dataWithBytes:&tem length:1];
    [devicePublicKeyData appendData:devicePublicKey];
    GMEllipticCurveCrypto *deviceKeyCrypto = [GMEllipticCurveCrypto cryptoForKey:devicePublicKeyData];
    deviceKeyCrypto.compressedPublicKey = YES;
    NSData *sharedSecretKeyData = [_crypto sharedSecretForPublicKey:deviceKeyCrypto.publicKey];
    TeLogInfo(@"sharedSecretKeyData=%@",sharedSecretKeyData);
    return sharedSecretKeyData;
}

@end
