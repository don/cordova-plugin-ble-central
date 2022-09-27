/********************************************************************************************************
 * @file     SigECCEncryptHelper.h
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

typedef void (^keyPair)(NSData *publicKey ,NSData *privateKey);

@interface SigECCEncryptHelper : NSObject


+ (instancetype)new __attribute__((unavailable("please initialize by use .share or .share()")));
- (instancetype)init __attribute__((unavailable("please initialize by use .share or .share()")));


+ (SigECCEncryptHelper *)share;

- (void)eccInit;

///返回手机端64字节的ECC公钥
- (NSData *)getPublicKeyData;

- (NSData *)getSharedSecretWithDevicePublicKey:(NSData *)devicePublicKey;

- (void)getECCKeyPair:(keyPair)pair;

@end

NS_ASSUME_NONNULL_END
