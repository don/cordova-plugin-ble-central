/********************************************************************************************************
 * @file     OpenSSLHelper.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/10/16
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

@interface OpenSSLHelper : NSObject


+ (instancetype)new __attribute__((unavailable("please initialize by use .share or .share()")));
- (instancetype)init __attribute__((unavailable("please initialize by use .share or .share()")));


+ (OpenSSLHelper *)share;

/// Generates 128-bit random data.
- (NSData *)generateRandom;

/// Calculates salt over given data.
/// @param someData A non-zero length octet array or ASCII encoded string.
- (NSData *)calculateSalt:(NSData *)someData;

/// Calculates Cipher-based Message Authentication Code (CMAC) that uses
/// AES-128 as the block cipher function, also known as AES-CMAC.
/// @param someData Data to be authenticated.
/// @param key The 128-bit key.
/// @return The 128-bit authentication code (MAC).
- (NSData *)calculateCMAC:(NSData *)someData andKey:(NSData *)key;

/// RFC3610 defines teh AES Counted with CBC-MAC (CCM).
/// This method generates ciphertext and MIC (Message Integrity Check).
/// @param someData The data to be encrypted and authenticated, also known as plaintext.
/// @param key The 128-bit key.
/// @param nonce A 104-bit nonce.
/// @param micSize Length of the MIC to be generated, in bytes.
/// @param aad Additional data to be authenticated.
/// @return Encrypted data concatenated with MIC of given size.
- (NSData *)calculateCCM:(NSData *)someData withKey:(NSData *)key nonce:(NSData *)nonce andMICSize:(UInt8)micSize withAdditionalData:(NSData *)aad;

/// Decrypts data encrypted with CCM.
/// @param someData Encrypted data.
/// @param key The 128-bit key.
/// @param nonce A 104-bit nonce.
/// @param mic Message Integrity Check data.
/// @param aad Additional data to be authenticated.
/// @return Decrypted data, if decryption is successful and MIC is valid, otherwise `nil`.
- (NSData *)calculateDecryptedCCM:(NSData *)someData withKey:(NSData *)key nonce:(NSData *)nonce andMIC:(NSData *)mic withAdditionalData:(NSData *)aad;

/// Obfuscates given data by XORing it with PECB, which is caluclated by encrypting
/// Privacy Plaintext (encrypted data (used as Privacy Random) and IV Index) using the given key.
/// @param data The data to obfuscate.
/// @param privacyRandom Data used as Privacy Random.
/// @param ivIndex The current IV Index value.
/// @param privacyKey The 128-bit Privacy Key.
/// @return Obfuscated data of the same size as input data.
- (NSData *)obfuscate:(NSData *)data usingPrivacyRandom:(NSData *)privacyRandom ivIndex:(UInt32)ivIndex andPrivacyKey:(NSData *)privacyKey;

/// Deobfuscates given data. This method reverses the obfuscation done by method above.
///
/// @param data The obfuscated data.
/// @param ivIndex The current IV Index value.
/// @param privacyKey The 128-bit Privacy Key.
/// @return Deobfuscated data of the same size as input data.
- (NSData *)deobfuscate:(NSData *)data ivIndex:(UInt32)ivIndex privacyKey:(NSData *)privacyKey;

- (NSData *)calculateAuthenticationTagWithKeyRefreshFlag:(BOOL)keyRefreshFlag ivUpdateActive:(BOOL)ivUpdateActive ivIndex:(UInt32)ivIndex randomData:(NSData *)randomData usingNetworkKey:(NSData *)networkKey;
- (NSData *)calculateObfuscatedPrivateBeaconDataWithKeyRefreshFlag:(BOOL)keyRefreshFlag ivUpdateActive:(BOOL)ivUpdateActive ivIndex:(UInt32)ivIndex randomData:(NSData *)randomData usingNetworkKey:(NSData *)networkKey;
- (NSData *)calculatePrivateBeaconDataWithObfuscatedPrivateBeaconData:(NSData *)obfuscatedPrivateBeaconData randomData:(NSData *)randomData usingNetworkKey:(NSData *)networkKey;

- (NSData *)calculatePrivateBeaconKeyWithNetKey:(NSData *)netKey;

// MARK: - Helpers

/// THe network key material derivation function k1 is used to generate instances of Identity Key and Beacon Key.
///
/// The definition of this derivation function makes use of the MAC function AES-CMAC(T) with 128-bit key T.
/// @param N is 0 or more octets.
/// @param salt is 128 bits.
/// @param P is 0 or more octets.
/// @return 128-bit key.
- (NSData *)calculateK1WithN:(NSData *)N salt:(NSData *)salt andP:(NSData *)P;

/// The network key material derivation function k2 is used to generate instances of Encryption Key, Privacy Key and NID for use as Master and Private Low Power node communication. This method returns 33 byte data.
///
/// The definition of this derivation function makes use of the MAC function AES-CMAC(T) with 128-bit key T.
/// @param N 128-bit key.
/// @param P 1 or more octets.
/// @return NID (7 bits), Encryption Key (128 bits) and Privacy Key (128 bits).
- (NSData *)calculateK2WithN:(NSData *)N andP:(NSData *)P;

/// The derivation function k3 us used to generate a public value of 64 bits derived from a private key.
///
/// The definition of this derivation function makes use of the MAC function AES-CMAC(T) with 128-bit key T.
/// @param N 128-bit key.
/// @return 64 bits of a public value derived from the key.
- (NSData *)calculateK3WithN:(NSData *)N;

/// The derivation function k4 us used to generate a public value of 6 bits derived from a private key.
///
/// The definition of this derivation function makes use of the MAC function AES-CMAC(T) with 128-bit key T.
/// @param N 128-bit key.
/// @return UInt8 with 6 LSB bits of a public value derived from the key.
- (UInt8)calculateK4WithN:(NSData *)N;

/// Encrypts given data using the key.
/// @param someData Data to be encrypted.
/// @param key The 128-bit key.
/// @return A byte array of encrypted data using the key. The size of the returned  array is equal to the size of input data.
- (NSData *)calculateEvalueWithData:(NSData *)someData andKey:(NSData *)key;

- (NSData *)xor:(NSData *)someData withData:(NSData *)otherData;

/// check version & time & Serial Number
///
/// "ecdsa-with-SHA256"
/// check certificate data and return inner public key
/// @param cerData certificate data formatted by x509 DeviceCertificate der.
/// @param superCerData certificate data formatted by x509 IntermediateCertificate der.
/// @return public key.
- (NSData *)checkCertificate:(NSData *)cerData withSuperCertificate:(NSData *)superCerData;

- (NSData *)getStaticOOBDataFromCertificate:(NSData *)cerData;

- (BOOL)checkUserCertificates:(NSArray <NSData *>*)userCerDatas withRootCertificate:(NSData *)rootCerData;

@end
