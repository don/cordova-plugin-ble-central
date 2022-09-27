/********************************************************************************************************
 * @file     OpenSSLHelper.m
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

#import "OpenSSLHelper.h"
#import "openssl/cmac.h"
#import "openssl/evp.h"
#import "openssl/rand.h"
#import "openssl/pem.h"
#import "openssl/pem2.h"
#import "openssl/x509.h"

@implementation OpenSSLHelper

+ (OpenSSLHelper *)share{
    static OpenSSLHelper *shareHelper = nil;
    static dispatch_once_t tempOnce=0;
    dispatch_once(&tempOnce, ^{
        shareHelper = [[OpenSSLHelper alloc] init];
    });
    return shareHelper;
}

- (NSData *)generateRandom {
    Byte buffer[16];
    int rc = RAND_bytes(buffer, sizeof(buffer));
    if (rc != 1) {
        NSLog(@"Failed to generate random bytes");
        return NULL;
    }
   return [[NSData alloc] initWithBytes: buffer length: sizeof(buffer)];
}

- (NSData *)calculateSalt:(NSData *)someData {
    //For S1, the key is constant
    unsigned char key[16] = {0x00};

    NSData *keyData = [[NSData alloc] initWithBytes: key length: 16];
    return [self calculateCMAC: someData andKey: keyData];
}

- (NSData *)calculateCMAC:(NSData *)someData andKey:(NSData *)key {
    unsigned char mact[16] = {0x00};
    size_t mactlen;

    CMAC_CTX *ctx = CMAC_CTX_new();
    CMAC_Init(ctx, (unsigned char *)[key bytes], [key length] / sizeof(unsigned char), EVP_aes_128_cbc(), NULL);
    CMAC_Update(ctx, (unsigned char *)[someData bytes], [someData length] / sizeof(unsigned char));
    CMAC_Final(ctx, mact, &mactlen);
    NSData *output = [[NSData alloc] initWithBytes:(const void *)mact length: sizeof(unsigned char) * mactlen];
    CMAC_CTX_free(ctx);
    return output;
}

- (NSData *)calculateECB:(NSData *)someData andKey:(NSData *)key {
    EVP_CIPHER_CTX *ctx;
    unsigned char iv[16] = {0x00};
    int len;
    int ciphertext_len;
    unsigned char outbuf[16] = {0x00};
    ctx = EVP_CIPHER_CTX_new();
    EVP_EncryptInit_ex(ctx, EVP_aes_128_ecb(), NULL, [key bytes], iv);
    EVP_EncryptUpdate(ctx, outbuf, &len, [someData bytes], (int) [someData length] / sizeof(unsigned char));
    ciphertext_len = len;
    EVP_EncryptFinal_ex(ctx, outbuf + len, &len);
    ciphertext_len += len;
    EVP_CIPHER_CTX_free(ctx);
    return [[NSData alloc] initWithBytes: outbuf length: 16];
}

- (NSData *)calculateCCM:(NSData *)someData
                 withKey:(NSData *)key
                   nonce:(NSData *)nonce
              andMICSize:(UInt8)size
      withAdditionalData:(NSData *)aad {
    int outlen = 0;
    int messageLength = (int) [someData length] / sizeof(unsigned char);
    int nonceLength   = (int) [nonce length]    / sizeof(unsigned char);
    int aadLength     = (int) [aad length]      / sizeof(unsigned char);
    int micLength = size;
    // Octets for Encrypted data + octets for TAG (MIC).
    unsigned char outbuf[messageLength + micLength];

    unsigned char* keyBytes     = (unsigned char *)[key bytes];
    unsigned char* nonceBytes   = (unsigned char *)[nonce bytes];
    unsigned char* messageBytes = (unsigned char *)[someData bytes];
    unsigned char* aadBytes     = (unsigned char *)[aad bytes];
    // Create and initialise the context.
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    // Initialise the encryption operation.
    EVP_EncryptInit_ex(ctx, EVP_aes_128_ccm(), NULL, NULL, NULL);
    // Setting IV len to nonce length.
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_CCM_SET_IVLEN, nonceLength, NULL);
    // Set tag length.
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_CCM_SET_TAG, micLength, NULL);
    // Initialise key and IV.
    EVP_EncryptInit_ex(ctx, NULL, NULL, keyBytes, nonceBytes);
    // Provide the total plaintext length.
    EVP_EncryptUpdate(ctx, NULL, &outlen, NULL, messageLength);
    // Provide any AAD data. This can be called zero or one times as required.
    if (aadLength > 0) {
        EVP_EncryptUpdate(ctx, NULL, &outlen, aadBytes, aadLength);
    }
    // Provide the message to be encrypted, and obtain the encrypted output.
    // EVP_EncryptUpdate can only be called once for this.
    EVP_EncryptUpdate(ctx, outbuf, &outlen, messageBytes, messageLength);
    // Finalise the encryption. Normally ciphertext bytes may be written at
    // this stage, but this does not occur in CCM mode.
    EVP_EncryptFinal_ex(ctx, outbuf + outlen, &outlen);
    // Get the tag.
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_CCM_GET_TAG, micLength, outbuf + messageLength);
    // Clean up.
    EVP_CIPHER_CTX_free(ctx);
    
    NSData *outputData = [[NSData alloc] initWithBytes: outbuf length: sizeof(outbuf)];
    return outputData;
}

- (NSData *)calculateDecryptedCCM:(NSData *)someData
                          withKey:(NSData *)key
                            nonce:(NSData *)nonce
                           andMIC:(NSData *)mic
               withAdditionalData:(NSData *)aad {
    int outlen;
    unsigned char outbuf[1024];
    
    int micLength     = (int) [mic length]      / sizeof(unsigned char);
    int messageLength = (int) [someData length] / sizeof(unsigned char);
    int nonceLength   = (int) [nonce length]    / sizeof(unsigned char);
    int aadLength     = (int) [aad length]      / sizeof(unsigned char);
    
    unsigned char* keyBytes     = (unsigned char *)[key bytes];
    unsigned char* nonceBytes   = (unsigned char *)[nonce bytes];
    unsigned char* messageBytes = (unsigned char *)[someData bytes];
    unsigned char* micBytes     = (unsigned char *)[mic bytes];
    unsigned char* aadBytes     = (unsigned char *)[aad bytes];
    
    // Create and initialise the context.
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    // Initialise the decryption operation.
    EVP_DecryptInit_ex(ctx, EVP_aes_128_ccm(), NULL, NULL, NULL);
    // Setting IV len to nonce length.
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_CCM_SET_IVLEN, nonceLength, NULL);
    // Set expected tag value.
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_CCM_SET_TAG, micLength, micBytes);
    // Initialise key and IV.
    EVP_DecryptInit_ex(ctx, NULL, NULL, keyBytes, nonceBytes);
    // Provide the total ciphertext length.
    EVP_DecryptUpdate(ctx, NULL, &outlen, NULL, messageLength);
    // Provide any AAD data. This can be called zero or more times as required.
    if (aadLength > 0) {
        EVP_DecryptUpdate(ctx, NULL, &outlen, aadBytes, aadLength);
    }
    // Provide the message to be decrypted, and obtain the plaintext output.
    // EVP_DecryptUpdate can be called multiple times if necessary.
    int ret = EVP_DecryptUpdate(ctx, outbuf, &outlen, messageBytes, messageLength);
    // Clean up.
    EVP_CIPHER_CTX_free(ctx);
    if (ret > 0) {
        NSData *outputData = [[NSData alloc] initWithBytes: outbuf length: outlen];
        return outputData;
    } else {
        return nil;
    }
}

- (NSData *)obfuscate:(NSData *)data
   usingPrivacyRandom:(NSData *)random
              ivIndex:(UInt32) ivIndex
        andPrivacyKey:(NSData *)privacyKey {
    NSMutableData *privacyRandomSource = [[NSMutableData alloc] init];
    [privacyRandomSource appendData: random];
    NSData *privacyRandom = [privacyRandomSource subdataWithRange: NSMakeRange(0, 7)];
    NSMutableData *pecbInputs = [[NSMutableData alloc] init];
    const unsigned ivIndexBigEndian = CFSwapInt32HostToBig(ivIndex);
    
    //Pad
    const char byteArray[] = { 0x00, 0x00, 0x00, 0x00, 0x00 };
    NSData *padding = [[NSData alloc] initWithBytes:byteArray length: 5];
    [pecbInputs appendData: padding];
    [pecbInputs appendData: [[NSData alloc] initWithBytes: &ivIndexBigEndian length: 4]];
    [pecbInputs appendData: privacyRandom];
    
    NSData *pecb = [[self calculateECB: pecbInputs andKey: privacyKey] subdataWithRange:NSMakeRange(0, 6)];
    
    NSData *obfuscatedData = [self xor: data withData: pecb];
    return obfuscatedData;
}

- (NSData *)deobfuscate:(NSData *)data
                ivIndex:(UInt32) ivIndex
             privacyKey:(NSData *)privacyKey {
    //Privacy random = EncDST || ENCTransportPDU || NetMIC [0-6]
    NSData *obfuscatedData = [data subdataWithRange: NSMakeRange(1, 6)];
    NSData *privacyRandom = [data subdataWithRange: NSMakeRange(7, 7)];
    const unsigned ivIndexBigEndian = CFSwapInt32HostToBig(ivIndex);
    
    //Pad
    const char byteArray[] = { 0x00, 0x00, 0x00, 0x00, 0x00 };
    NSData *padding = [[NSData alloc] initWithBytes: byteArray length: 5];
    NSMutableData *pecbInputs = [[NSMutableData alloc] init];
    [pecbInputs appendData: padding];
    [pecbInputs appendData: [[NSData alloc] initWithBytes: &ivIndexBigEndian length: 4]];
    [pecbInputs appendData: privacyRandom];
    
    NSData *pecb = [[self calculateECB:pecbInputs andKey: privacyKey] subdataWithRange: NSMakeRange(0, 6)];
    
    //DeobfuscatedData = CTL, TTL, SEQ, SRC
    NSData *deobfuscatedData = [self xor: obfuscatedData withData: pecb];
    return deobfuscatedData;
}

/// 3.10.4.1.1 Private beacon security function
/// - seeAlso: MshPRFd1.1r15_clean.pdf  (page.209)
- (NSData *)calculateAuthenticationTagWithKeyRefreshFlag:(BOOL)keyRefreshFlag ivUpdateActive:(BOOL)ivUpdateActive ivIndex:(UInt32)ivIndex randomData:(NSData *)randomData usingNetworkKey:(NSData *)networkKey {
    /*
     B0 = 0x19 || Random || 0x0005
     C0 = 0x01 || Random || 0x0000
     C1 = 0x01 || Random || 0x0001
     Private Beacon Data (5 octets) = Flags || IV Index
     P = Private Beacon Data || 0x0000000000000000000000 (11-octets of Zero padding)
     */
    
    NSData *authenticationTag = nil;
    NSMutableData *mData = [NSMutableData data];
    
    //B0
    UInt8 tem8 = 0x19;
    UInt16 tem16 = CFSwapInt16BigToHost(0x0005);
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    [mData appendData:randomData];
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    NSData *B0 = [NSData dataWithData:mData];
    
    //C0
    mData = [NSMutableData data];
    tem8 = 0x01;
    tem16 = CFSwapInt16BigToHost(0x0000);
    data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    [mData appendData:randomData];
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    NSData *C0 = [NSData dataWithData:mData];

    //Private Beacon Data
    mData = [NSMutableData data];
    struct Flags flags = {};
    flags.value = 0;
    if (keyRefreshFlag) {
        flags.value |= (1 << 0);
    }
    if (ivUpdateActive) {
        flags.value |= (1 << 1);
    }
    [mData appendData:[NSData dataWithBytes:&flags length:1]];
    UInt32 ivIndex32 = CFSwapInt32HostToBig(ivIndex);
    [mData appendData:[NSData dataWithBytes:&ivIndex32 length:4]];
    NSData *privateBeaconData = [NSData dataWithData:mData];

    //P
    UInt8 padding[11] = {};
    memset(padding, 0, 11);
    mData = [NSMutableData data];
    [mData appendData:privateBeaconData];
    [mData appendBytes:padding length:11];
    NSData *P = [NSData dataWithData:mData];

    /*
     The Authentication_Tag is generated using the following computations:
     T0 = e (PrivateBeaconKey, B0)
     T1 = e (PrivateBeaconKey, T0 ⊕ P)
     T2 = T1 ⊕ e (PrivateBeaconKey, C0)
     Authentication_Tag = T2[0-7]
     */
    NSData *privateBeaconKey = [self calculatePrivateBeaconKeyWithNetKey:networkKey];
    NSData *T0 = [self calculateECB:B0 andKey:privateBeaconKey];
    NSData *T1 = [self calculateECB:[self xor:T0 withData:P] andKey:privateBeaconKey];
    NSData *T2 = [self xor:T1 withData:[self calculateECB:C0 andKey:privateBeaconKey]];
    authenticationTag = [T2 subdataWithRange:NSMakeRange(0, 8)];
    return authenticationTag;
}

/// 3.10.4.1.1 Private beacon security function
/// - seeAlso: MshPRFd1.1r15_clean.pdf  (page.209)
- (NSData *)calculateObfuscatedPrivateBeaconDataWithKeyRefreshFlag:(BOOL)keyRefreshFlag ivUpdateActive:(BOOL)ivUpdateActive ivIndex:(UInt32)ivIndex randomData:(NSData *)randomData usingNetworkKey:(NSData *)networkKey {
    /*
     B0 = 0x19 || Random || 0x0005
     C0 = 0x01 || Random || 0x0000
     C1 = 0x01 || Random || 0x0001
     Private Beacon Data (5 octets) = Flags || IV Index
     P = Private Beacon Data || 0x0000000000000000000000 (11-octets of Zero padding)
     */
    
    NSData *obfuscatedPrivateBeaconData = nil;
    NSMutableData *mData = [NSMutableData data];
        
    //C1
    mData = [NSMutableData data];
    UInt8 tem8 = 0x01;
    UInt16 tem16 = CFSwapInt16BigToHost(0x0001);
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    [mData appendData:randomData];
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    NSData *C1 = [NSData dataWithData:mData];

    //Private Beacon Data
    mData = [NSMutableData data];
    struct Flags flags = {};
    flags.value = 0;
    if (keyRefreshFlag) {
        flags.value |= (1 << 0);
    }
    if (ivUpdateActive) {
        flags.value |= (1 << 1);
    }
    [mData appendData:[NSData dataWithBytes:&flags length:1]];
    UInt32 ivIndex32 = CFSwapInt32HostToBig(ivIndex);
    [mData appendData:[NSData dataWithBytes:&ivIndex32 length:4]];
    NSData *privateBeaconData = [NSData dataWithData:mData];

    /*
     The Private Beacon Data is obfuscated as follows:
     S = e (PrivateBeaconKey, C1)
     Obfuscated_Private_Beacon_Data = (S [0-4]) ⊕ (Private Beacon Data))
     */
    NSData *privateBeaconKey = [self calculatePrivateBeaconKeyWithNetKey:networkKey];
    NSData *S = [self calculateECB:C1 andKey:privateBeaconKey];
    obfuscatedPrivateBeaconData = [self xor:[S subdataWithRange:NSMakeRange(0, 5)] withData:privateBeaconData];
    return obfuscatedPrivateBeaconData;
}

- (NSData *)calculatePrivateBeaconDataWithObfuscatedPrivateBeaconData:(NSData *)obfuscatedPrivateBeaconData randomData:(NSData *)randomData usingNetworkKey:(NSData *)networkKey {
    /*
     B0 = 0x19 || Random || 0x0005
     C0 = 0x01 || Random || 0x0000
     C1 = 0x01 || Random || 0x0001
     Private Beacon Data (5 octets) = Flags || IV Index
     P = Private Beacon Data || 0x0000000000000000000000 (11-octets of Zero padding)
     */
    
    //C1
    NSMutableData *mData = [NSMutableData data];
    UInt8 tem8 = 0x01;
    UInt16 tem16 = CFSwapInt16BigToHost(0x0001);
    NSData *data = [NSData dataWithBytes:&tem8 length:1];
    [mData appendData:data];
    [mData appendData:randomData];
    data = [NSData dataWithBytes:&tem16 length:2];
    [mData appendData:data];
    NSData *C1 = [NSData dataWithData:mData];

    /*
     The Private Beacon Data is obfuscated as follows:
     S = e (PrivateBeaconKey, C1)
     Obfuscated_Private_Beacon_Data = (S [0-4]) ⊕ (Private Beacon Data))
     */
    NSData *privateBeaconKey = [self calculatePrivateBeaconKeyWithNetKey:networkKey];
    NSData *S = [self calculateECB:C1 andKey:privateBeaconKey];
    NSData *privateBeaconData = [self xor:[S subdataWithRange:NSMakeRange(0, 5)] withData:obfuscatedPrivateBeaconData];
    return privateBeaconData;
}

/// 3.9.6.3.5 PrivateBeaconKey
/// - seeAlso: MshPRFd1.1r15_clean.pdf  (page.200)
- (NSData *)calculatePrivateBeaconKeyWithNetKey:(NSData *)netKey {
    /*
     salt = s1(“nkpk”)
     P = “id128” || 0x01
     PrivateBeaconKey = k1(NetKey, salt, P)
     */
    NSData *salt = [[OpenSSLHelper share] calculateSalt:[@"nkpk" dataUsingEncoding:NSASCIIStringEncoding]];

    UInt8 tem8 = 0x01;
    NSMutableData *P = [NSMutableData dataWithData:[@"id128" dataUsingEncoding:NSASCIIStringEncoding]];
    [P appendData:[NSData dataWithBytes:&tem8 length:1]];
    
    NSData *privateBeaconKey = [[OpenSSLHelper share] calculateK1WithN:netKey salt:salt andP:P];
    return privateBeaconKey;
}

// MARK:- Helpers
- (NSData *)calculateK1WithN:(NSData *)N salt:(NSData *)salt andP:(NSData *)P {
    // Calculace K1 (outputs the confirmationKey).
    // T is calculated first using AES-CMAC N with SALT.
    NSData *t = [self calculateCMAC: N andKey: salt];
    // Then calculating AES-CMAC P with salt T.
    NSData *output = [self calculateCMAC: P andKey: t];
    return output;
}

- (NSData *)calculateK2WithN:(NSData *)N andP:(NSData *)P {
    const char byteArray[] = { 0x73, 0x6D, 0x6B, 0x32 }; //smk2 string.
    NSData *smk2String = [[NSData alloc] initWithBytes: byteArray length: 4];
    NSData *s1 = [self calculateSalt: smk2String];
    NSData *t = [self calculateCMAC: N andKey:s1];
    
    const unsigned char* pBytes = [P bytes];
    // Create T1 => (T0 || P || 0x01).
    NSMutableData *t1Inputs = [[NSMutableData alloc] init];
    [t1Inputs appendBytes:pBytes length:P.length];
    uint8_t one = 1;
    [t1Inputs appendBytes:&one length:1];
    
    NSData *t1 = [self calculateCMAC:t1Inputs andKey:t];
    
    // Create T2 => (T1 || P || 0x02).
    NSMutableData *t2Inputs = [[NSMutableData alloc] init];
    [t2Inputs appendData: t1];
    [t2Inputs appendBytes: pBytes length: P.length];
    uint8_t two = 0x02;
    [t2Inputs appendBytes: &two length:1];
    
    NSData *t2 = [self calculateCMAC: t2Inputs andKey: t];
    
    // Create T3 => (T2 || P || 0x03).
    NSMutableData *t3Inputs = [[NSMutableData alloc] init];
    [t3Inputs appendData: t2];
    [t3Inputs appendBytes: pBytes length: P.length];
    uint8_t three = 0x03;
    [t3Inputs appendBytes: &three length: 1];
    
    NSData *t3 = [self calculateCMAC:t3Inputs andKey:t];
    
    NSMutableData *finalData = [[NSMutableData alloc] init];
    [finalData appendData: t1];
    [finalData appendData: t2];
    [finalData appendData: t3];
    
    // data mod 2^264 (keeps last 14 bytes + 7 bits), as per K2 spec.
    const unsigned char* dataPtr = [finalData bytes];
    // We need only the first 7 bits from first octet, bitmask bit0 off.
    unsigned char firstOffset = dataPtr[15] & 0x7F;
    // Then get the rest of the data up to the 16th octet.
    finalData = (NSMutableData *)[finalData subdataWithRange: NSMakeRange(16, [finalData length] - 16)];
    // and concat the first octet with the chunked data, this is equivalent to removing first 15 octets - 7 bits).
    NSMutableData *output = [[NSMutableData alloc] init];
    [output appendBytes: &firstOffset length:1];
    [output appendData: finalData];
    
    return output;
}

- (NSData *)calculateK3WithN:(NSData *)N {
    // Calculace K3 (outputs public value).
    // SALT is calculated using S1 with smk3 in ASCII.
    const char saltInput[] = { 0x73, 0x6D, 0x6B, 0x33 }; // smk3 string.
    NSData *saltInputData = [[NSData alloc] initWithBytes: saltInput length:4];
    NSData *salt = [self calculateSalt: saltInputData];
    // T is calculated first using AES-CMAC N with SALT.
    NSData *t = [self calculateCMAC: N andKey: salt];
    
    // id64 ascii => 0x69 0x64 0x36 0x34 || 0x01.
    const char cmacInput[] = { 0x69, 0x64, 0x36, 0x34, 0x01 }; // id64 string. || 0x01
    NSData *cmacInputData = [[NSData alloc] initWithBytes: cmacInput length: 5];
    NSData *finalData = [self calculateCMAC: cmacInputData andKey: t];
    
    // Data mod 2^64 (keeps last 64 bits), as per K3 spec.
    NSData *output = (NSMutableData *)[finalData subdataWithRange: NSMakeRange(8, [finalData length] - 8)];
    return output;
}

- (UInt8) calculateK4WithN:(NSData *)N {
    // Calculace K4 (outputs 6 bit public value)
    // SALT is calculated using S1 with smk3 in ASCII.
    const char saltInput[] = { 0x73, 0x6D, 0x6B, 0x34 }; // smk4 string.
    NSData *saltInputData = [[NSData alloc] initWithBytes: saltInput length:4];
    NSData *salt = [self calculateSalt: saltInputData];
    // T is calculated first using AES-CMAC N with SALT.
    NSData *t = [self calculateCMAC: N andKey: salt];
    
    // id64 ascii => 0x69 0x64 0x36 || 0x01
    const char cmacInput[] = { 0x69, 0x64, 0x36, 0x01 }; // id64 string || 0x01
    NSData *cmacInputData = [[NSData alloc] initWithBytes: cmacInput length: 4];
    NSData *finalData = [self calculateCMAC: cmacInputData andKey: t];
    
    // data mod 2^6 (keeps last 6 bits), as per K4 spec.
    const unsigned char* dataPtr = [finalData bytes];
    // We need only the last 6 bits from the octet, bitmask bit0 and bit1 off.
    return dataPtr[15] & 0x3F;
}

- (NSData *)calculateEvalueWithData:(NSData *)someData andKey:(NSData *)key {
    return [self calculateECB: someData andKey: key];
}

- (NSData *)xor:(NSData *)someData withData:(NSData *)otherData {
    const char *someDataBytes   = [someData bytes];
    const char *otherDataBytes  = [otherData bytes];
    NSMutableData *result = [[NSMutableData alloc] init];
    for (int i = 0; i < someData.length; i++){
        const char resultByte = someDataBytes[i] ^ otherDataBytes[i % otherData.length];
        [result appendBytes: &resultByte length: 1];
    }
   return result;
}

- (NSData *)calculateSHA1:(NSData *)someData {
    unsigned char hash[SHA_DIGEST_LENGTH];
    SHA_CTX sha;
    SHA_Init(&sha);
    SHA_Update(&sha, someData.bytes, someData.length);
    SHA_Final(hash, &sha);
    NSData *output = [NSData dataWithBytes:hash length:SHA_DIGEST_LENGTH];
    return output;
}

- (BOOL)checkUserCertificates:(NSArray <NSData *>*)userCerDatas withRootCertificate:(NSData *)rootCerData {
    OpenSSL_add_all_algorithms();
    //x509证书验证示例,https://blog.csdn.net/chuicao4350/article/details/52875329

    int ret;

    X509 *user = NULL;
    X509 *ca = NULL;

    X509_STORE *ca_store = NULL;
    X509_STORE_CTX *ctx = NULL;
    STACK_OF(X509) *ca_stack = NULL;

    /* x509初始化 */
    ca_store = X509_STORE_new();
    ctx = X509_STORE_CTX_new();

    /* 父证书DER编码转X509结构 */
    ca = der_to_x509(rootCerData.bytes, (unsigned int)rootCerData.length);
    /* 加入证书存储区 */
    ret = X509_STORE_add_cert(ca_store, ca);
    if ( ret != 1 )
    {
        fprintf(stderr, "X509_STORE_add_cert fail, ret = %d\n", ret);
        goto EXIT;
    }

    /* 需要校验的证书 */
    for (NSData *userCerData  in userCerDatas) {
        user = der_to_x509(userCerData.bytes, (unsigned int)userCerData.length);

        ret = X509_STORE_CTX_init(ctx, ca_store, user, ca_stack);
        if ( ret != 1 )
        {
            fprintf(stderr, "X509_STORE_CTX_init fail, ret = %d\n", ret);
            goto EXIT;
        }
    }
    
    //openssl-1.0.1c/crypto/x509/x509_vfy.h
    ret = X509_verify_cert(ctx);
    if ( ret != 1 )
    {
        fprintf(stderr, "X509_verify_cert fail, ret = %d, error id = %d, %s\n",
                ret, ctx->error, X509_verify_cert_error_string(ctx->error));
        goto EXIT;
    }
    fprintf(stdout, "X509_verify_cert successful\n");
EXIT:
    X509_free(user);
    X509_free(ca);

    X509_STORE_CTX_cleanup(ctx);
    X509_STORE_CTX_free(ctx);

    X509_STORE_free(ca_store);

    return ret == 1 ? YES : NO;
}

X509 *der_to_x509(const unsigned char *der_str, unsigned int der_str_len) {
    X509 *x509;
    x509 = d2i_X509(NULL, &der_str, der_str_len);
    if ( NULL == x509 )
    {
        fprintf(stderr, "d2i_X509 fail\n");

        return NULL;
    }
    return x509;
}

//- (NSData *)getStaticOOBDataFromCertificate:(NSData *)cerData {
//    OpenSSL_add_all_algorithms();
//
//    X509* x509 = NULL;
//    NSData *staticOOB = nil;
//
//    @try {
//        const unsigned char* certificateData = [cerData bytes];
//        long certificateDataLength = [cerData length];
//        x509 = d2i_X509(NULL, &certificateData, certificateDataLength);
//        if (!x509) {
//            NSLog(@"Failed to read certificate, function: d2i_X509");
//            @throw [NSException exceptionWithName:@"Failed to read certificate"   reason:@"crush's function: d2i_X509" userInfo:nil];
//        }
//
//        //打印证书
//        BIO *b;
//        b = BIO_new(BIO_s_file());
//        BIO_set_fp(b, stdout, BIO_NOCLOSE);
//        X509_print(b, x509);
//
//        //获取staticOOB数据
//        int ExtCount = X509_get_ext_count(x509);
//        for ( int k = 0; k < ExtCount; ++k ) {
//            X509_EXTENSION *ex = X509_get_ext(x509, k);
//
//            if( ex == NULL )
//            continue;
//
//            ASN1_OBJECT* obj = X509_EXTENSION_get_object(ex);
//            char *extstr;
//            char *extValue;
//            extstr=(char*) OBJ_nid2sn(OBJ_obj2nid(obj));
//            extValue=(char*) OBJ_nid2ln(OBJ_obj2nid(obj));
//
//            NSLog(@"%@:%@",[NSString stringWithCString:extstr encoding:NSASCIIStringEncoding],[NSString stringWithCString:extValue encoding:NSASCIIStringEncoding]);
//            if(!strcmp(extstr,"2.25.234763379998062148653007332685657680359"))
//            {
//
//            }
//
//            if ( obj == NULL )
//            continue;
//
//            int nID = OBJ_obj2nid( obj );
//#define EXTNAME_LEN 100
//            if (nID == NID_undef) {
//                // no lookup found for the provided OID so nid came back as undefined.
//                char extname[EXTNAME_LEN];
//                OBJ_obj2txt(extname, EXTNAME_LEN, (const ASN1_OBJECT *) obj, 1);
//                printf("extension name is %s\n", extname);
//                printf("extension length is %u\n", obj->length);
//                printf("extension length is %u\n", obj->length);
//                printf("extension value is %s\n", obj->data);
//
//                ASN1_OCTET_STRING *s = X509_EXTENSION_get_data(ex);
//                printf("extension length is %u\n", s->length);
//                printf("extension value is %s\n", s->data);
//                NSLog(@"%@:%d",[NSData dataWithBytes:s->data length:s->length],s->type);
//
//            } else {
//                // the OID translated to a NID which implies that the OID has a known sn/ln
////                const char *c_ext_name = OBJ_nid2ln(nid);
////                IFNULL_FAIL(c_ext_name, "invalid X509v3 extension name");
////                printf("extension name is %s\n", c_ext_name);
//            }
//
//
//            if (nID == 0) {
//                staticOOB = [NSData dataWithBytes:obj->data length:obj->length];
////                NSLog(@"nID = %d, object=%@",nID,staticOOB);
////                break;
//            } else {
////                NSLog(@"nID = %d, object=%@",nID,[NSData dataWithBytes:obj->data length:obj->length]);
//            }
//        }
//        X509_free(x509);
//        if (staticOOB && staticOOB.length >= 20) {
//            return [staticOOB subdataWithRange:NSMakeRange(4, 16)];
////            return [LibTools turnOverData:[staticOOB subdataWithRange:NSMakeRange(4, 16)]];
//        } else {
//            return staticOOB;
//        }
//    }
//    @catch (NSException *exception) {
//        EVP_cleanup();
//        CRYPTO_cleanup_all_ex_data();  //generic
//        X509_free(x509);
//        return nil;
//    }
//}

- (NSData *)getStaticOOBDataFromCertificate:(NSData *)cerData {
    OpenSSL_add_all_algorithms();

    X509* x509 = NULL;
    NSData *staticOOB = nil;
    
    @try {
        const unsigned char* certificateData = [cerData bytes];
        long certificateDataLength = [cerData length];
        x509 = d2i_X509(NULL, &certificateData, certificateDataLength);
        if (!x509) {
            NSLog(@"Failed to read certificate, function: d2i_X509");
            @throw [NSException exceptionWithName:@"Failed to read certificate"   reason:@"crush's function: d2i_X509" userInfo:nil];
        }
        
        //获取staticOOB数据
        int ExtCount = X509_get_ext_count(x509);
        for ( int k = 0; k < ExtCount; ++k ) {
            X509_EXTENSION *ex = X509_get_ext(x509, k);

            if( ex == NULL )
            continue;

            ASN1_OBJECT* obj = X509_EXTENSION_get_object(ex);
//            char *extstr;
//            char *extValue;
//            extstr=(char*) OBJ_nid2sn(OBJ_obj2nid(obj));
//            extValue=(char*) OBJ_nid2ln(OBJ_obj2nid(obj));
//            NSLog(@"%@:%@",[NSString stringWithCString:extstr encoding:NSASCIIStringEncoding],[NSString stringWithCString:extValue encoding:NSASCIIStringEncoding]);
//            if(!strcmp(extstr,"2.25.234763379998062148653007332685657680359"))
//            {
//
//            }

            if ( obj == NULL )
            continue;

            int nID = OBJ_obj2nid( obj );
#define EXTNAME_LEN 100
            if (nID == NID_undef) {
                // no lookup found for the provided OID so nid came back as undefined.
                char extname[EXTNAME_LEN];
                OBJ_obj2txt(extname, EXTNAME_LEN, (const ASN1_OBJECT *) obj, 1);
//                printf("extension name is %s\n", extname);

                ASN1_OCTET_STRING *s = X509_EXTENSION_get_data(ex);
//                NSLog(@"%@:%d",[NSData dataWithBytes:s->data length:s->length],s->type);
                staticOOB = [NSData dataWithBytes:s->data length:s->length];
                break;
            }
        }
        X509_free(x509);
        if (staticOOB && staticOOB.length >= 16) {
            return [staticOOB subdataWithRange:NSMakeRange(staticOOB.length-16, 16)];
        } else {
            return staticOOB;
        }
    }
    @catch (NSException *exception) {
        EVP_cleanup();
        CRYPTO_cleanup_all_ex_data();  //generic
        X509_free(x509);
        return nil;
    }
}

- (NSData *)checkCertificate:(NSData *)cerData withSuperCertificate:(NSData *)superCerData {
    OpenSSL_add_all_algorithms();

    X509* x509 = NULL;
    X509* superX509 = NULL;
    
//>>>>>>> release3.3.5
    @try {

        const unsigned char* certificateData = [cerData bytes];
        long certificateDataLength = [cerData length];
        x509 = d2i_X509(NULL, &certificateData, certificateDataLength);
        if (!x509) {
            NSLog(@"Failed to read certificate, function: d2i_X509");
            @throw [NSException exceptionWithName:@"Failed to read certificate"   reason:@"crush's function: d2i_X509" userInfo:nil];
        }
        const unsigned char* superCertificateData = [superCerData bytes];
        long superCertificateDataLength = [superCerData length];
        superX509 = d2i_X509(NULL, &superCertificateData, superCertificateDataLength);
        if (!superX509) {
            NSLog(@"Failed to read super certificate, function: d2i_X509");
            @throw [NSException exceptionWithName:@"Failed to read superX509 certificate"   reason:@"crush's function: d2i_X509" userInfo:nil];
        }

        //打印证书
        BIO *b;
        b = BIO_new(BIO_s_file());
        BIO_set_fp(b, stdout, BIO_NOCLOSE);
        X509_print(b, x509);
        
/*
 X509_verify_cert successful
 Certificate:
     Data:
         Version: 3 (0x2)
         Serial Number: 3 (0x3)
     Signature Algorithm: ecdsa-with-SHA256
         Issuer: C=US, ST=Washington, O=Bluetooth SIG, OU=PTS, CN=Intermediate Authority/emailAddress=support@bluetooth.com
         Validity
             Not Before: Jul 18 18:55:36 2019 GMT
             Not After : Oct  4 18:55:36 2030 GMT
         Subject: C=US, ST=Washington, O=Bluetooth SIG, OU=PTS, CN=001BDC08-1021-0B0E-0A0C-000B0E0A0C00
         Subject Public Key Info:
             Public Key Algorithm: id-ecPublicKey
                 Public-Key: (256 bit)
                 pub:
                     04:f4:65:e4:3f:f2:3d:3f:1b:9d:c7:df:c0:4d:a8:
                     75:81:84:db:c9:66:20:47:96:ec:cf:0d:6c:f5:e1:
                     65:00:cc:02:01:d0:48:bc:bb:d8:99:ee:ef:c4:24:
                     16:4e:33:c2:01:c2:b0:10:ca:6b:4d:43:a8:a1:55:
                     ca:d8:ec:b2:79
                 ASN1 OID: prime256v1
                 NIST CURVE: P-256
         X509v3 extensions:
             X509v3 Basic Constraints:
                 CA:FALSE
             X509v3 Key Usage:
                 Key Agreement
             X509v3 Subject Key Identifier:
                 E2:62:F3:58:4A:B6:88:EC:88:2E:A5:28:ED:8E:5C:44:2A:71:36:9F
             X509v3 Authority Key Identifier:
                 keyid:4A:BE:29:39:03:A8:BB:49:FF:1D:32:7C:FE:B8:09:85:F4:10:9C:21

             2.25.580603855837255606715559455207:
                 ..................
     Signature Algorithm: ecdsa-with-SHA256
          30:46:02:21:00:f7:b5:04:47:7e:c2:e5:79:66:44:a0:c5:a9:
          5d:86:4b:f0:01:cf:96:a5:a1:80:e2:43:43:2c:ce:28:fc:5f:
          9e:02:21:00:8d:81:6b:ee:11:c3:6c:dc:18:90:18:9e:db:85:
          df:9a:26:99:80:63:ea:c8:ea:55:33:0b:7f:75:00:3f:eb:98

 
 
 */
        
        
        //获取证书公钥
        NSData *publicKey = [NSData data];
        ASN1_BIT_STRING *string = X509_get0_pubkey_bitstr(x509);
        if (string != NULL) {
            publicKey = [NSData dataWithBytes:string->data length:string->length];
            publicKey = [publicKey subdataWithRange:NSMakeRange(1, publicKey.length - 1)];
        } else {
            NSLog(@"Failed to read certificate, function: X509_get0_pubkey_bitstr");
            @throw [NSException exceptionWithName:@"Failed to read certificate"   reason:@"crush's function: X509_get0_pubkey_bitstr" userInfo:nil];
        }

        //获取证书版本号
        long version = X509_get_version(x509);
        
        //获取证书有效时间
        ASN1_TIME* notBeforeASN1_TIME = X509_get_notBefore(x509);
        if (!notBeforeASN1_TIME) {
            NSLog(@"Failed to read certificate, function: X509_get_notBefore");
            @throw [NSException exceptionWithName:@"Failed to read certificate"   reason:@"crush's function: X509_get_notBefore" userInfo:nil];
        }
        NSDate* notBefore = [self convertASN1_TIMEToNSDate:notBeforeASN1_TIME];
        ASN1_TIME* notAfterASN1_TIME = X509_get_notAfter(x509);
        if (!notAfterASN1_TIME) {
            NSLog(@"Failed to read certificate, function: X509_get_notAfter");
            @throw [NSException exceptionWithName:@"Failed to read certificate"   reason:@"crush's function: X509_get_notAfter" userInfo:nil];
        }
        NSDate* notAfter = [self convertASN1_TIMEToNSDate:notAfterASN1_TIME];

        //获取证书签名 Signature
//        ASN1_BIT_STRING *signature = nil;
//        X509_get0_signature(&signature, &x509->sig_alg, x509);
//        NSData *sig = [NSData dataWithBytes:signature->data length:signature->length];
//        TeLogInfo(@"check certificate success, sig=%@",[LibTools convertDataToHexStr:sig]);
//        NSLog(@"check certificate success, sig=%@",[LibTools convertDataToHexStr:sig]);

        //验证证书签名(存在父证书的publicKey则使用父证书的publicKey验签，没有则使用自己的publicKey验签)
        EVP_PKEY *key = nil;
        EVP_PKEY *superPublicKey = X509_get_pubkey(superX509);
        if (superPublicKey) {
            key = superPublicKey;
        } else {
            EVP_PKEY *pub_key = X509_get_pubkey(x509);
            key = pub_key;
        }
        if (key) {
            //verify. result less than or 0 means not verified or some error.
            int verify = X509_verify(x509, key);
            if (verify == 1) {
                TeLogInfo(@"Signature is valid");
            } else {
                TeLogError(@"serial number check err,X509_verify=%d",verify);
                return nil;
            }
            EVP_PKEY_free(key);
        }

        //比较版本号（值是0x2，对应的版本是3）
        if (version != 0x2) {
            TeLogError(@"version check err,version=0x%lx",version);
            return nil;
        }
        //比较有效期
        NSDate *nowDate = [NSDate date];
        NSComparisonResult notBeforeResult = [nowDate compare:notBefore];
        NSComparisonResult notAfterResult = [nowDate compare:notAfter];
        if (notBeforeResult == 1 && notAfterResult == -1) {
            //time is validity
        } else {
            TeLogError(@"time check err,%@ ~~~> %@",notBefore,notAfter);
            return nil;
        }

        TeLogInfo(@"check certificate success, publicKey=%@",[LibTools convertDataToHexStr:publicKey]);
        X509_free(x509);
        return publicKey;
    }
    @catch (NSException *exception) {
        EVP_cleanup();
        CRYPTO_cleanup_all_ex_data();  //generic
        X509_free(x509);
        return nil;
    }
}

- (NSDate *)convertASN1_TIMEToNSDate:(ASN1_TIME *)asn1_time {
    NSString* dateString = [NSString stringWithCString:(const char*)asn1_time->data encoding:NSASCIIStringEncoding];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    if ([dateString length] == 13) {
        [formatter setDateFormat:@"yyMMddHHmmss'Z'"];
    } else if ([dateString length] == 15) {
        [formatter setDateFormat:@"yyyyMMddHHmmssZ"];
    } else {
        NSLog(@"Failed to convert ASN1_TIME, format is unknown");
        return nil;
    }
    NSDate* d = [formatter dateFromString:dateString];
    return d;
}

@end
