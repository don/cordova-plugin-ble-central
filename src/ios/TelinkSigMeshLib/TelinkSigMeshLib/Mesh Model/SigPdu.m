/********************************************************************************************************
 * @file     SigPdu.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/9/9
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

#import "SigPdu.h"
#import "OpenSSLHelper.h"
#import "SigLowerTransportPdu.h"
#import "OpenSSLHelper.h"

//struct PublicKeyPdu {
//    UInt8 type;
//    UInt8 publicKey[64];
//};
//
//struct ConfirmationPdu {
//    UInt8 type;
//    UInt8 confirmation[16];
//};
//
//struct RandomPdu {
//    UInt8 type;
//    UInt8 random[16];
//};
//
//struct EncryptedDataWithMicPdu {
//    UInt8 type;
//    UInt8 encryptedDataWithMic[33];
//};

@implementation SigPdu
- (instancetype)init {
    self = [super init];
    if (self) {
        _pduData = [NSData data];
    }
    return self;
}
@end


@implementation SigProvisioningPdu

+ (Class)getProvisioningPduClassWithProvisioningPduType:(SigProvisioningPduType)provisioningPduType {
    Class messageType = nil;
    switch (provisioningPduType) {
        case SigProvisioningPduType_invite:
            messageType = [SigProvisioningInvitePdu class];
            break;
        case SigProvisioningPduType_capabilities:
            messageType = [SigProvisioningCapabilitiesPdu class];
            break;
        case SigProvisioningPduType_start:
            messageType = [SigProvisioningStartPdu class];
            break;
        case SigProvisioningPduType_publicKey:
            messageType = [SigProvisioningPublicKeyPdu class];
            break;
        case SigProvisioningPduType_inputComplete:
            messageType = [SigProvisioningInputCompletePdu class];
            break;
        case SigProvisioningPduType_confirmation:
            messageType = [SigProvisioningConfirmationPdu class];
            break;
        case SigProvisioningPduType_random:
            messageType = [SigProvisioningRandomPdu class];
            break;
        case SigProvisioningPduType_data:
            messageType = [SigProvisioningDataPdu class];
            break;
        case SigProvisioningPduType_complete:
            messageType = [SigProvisioningCompletePdu class];
            break;
        case SigProvisioningPduType_failed:
            messageType = [SigProvisioningFailedPdu class];
            break;
        case SigProvisioningPduType_recordRequest:
            messageType = [SigProvisioningRecordRequestPdu class];
            break;
        case SigProvisioningPduType_recordResponse:
            messageType = [SigProvisioningRecordResponsePdu class];
            break;
        case SigProvisioningPduType_recordsGet:
            messageType = [SigProvisioningInvitePdu class];
            break;
        case SigProvisioningPduType_recordsList:
            messageType = [SigProvisioningRecordsListPdu class];
            break;
        default:
            break;
    }
    return messageType;
}

//- (instancetype)initProvisioningPublicKeyPduWithPublicKey:(NSData *)publicKey {
//    if (self = [super init]) {
//        self.pduData = [self getProvisioningPublicKeyPduWithPublicKey:publicKey];
//    }
//    return self;
//}
//
//- (instancetype)initProvisioningConfirmationPduWithConfirmation:(NSData *)confirmation {
//    if (self = [super init]) {
//        self.pduData = [self getProvisioningConfirmationPduWithConfirmation:confirmation];
//    }
//    return self;
//}

//- (instancetype)initProvisioningRandomPduWithRandom:(NSData *)random {
//    if (self = [super init]) {
//        self.pduData = [self getProvisioningRandomPduWithRandom:random];
//    }
//    return self;
//}

//- (instancetype)initProvisioningEncryptedDataWithMicPduWithEncryptedData:(NSData *)encryptedData {
//    if (self = [super init]) {
//        self.pduData = [self getProvisioningEncryptedDataWithMicPduWithEncryptedData:encryptedData];
//    }
//    return self;
//}

/// The Provisioner sends a Provisioning Record Request PDU to request a provisioning record fragment (a part of a provisioning record; see Section 5.4.2.6) from the device.
/// @param recordID Identifies the provisioning record for which the request is made (see Section 5.4.2.6).
/// @param fragmentOffset The starting offset of the requested fragment in the provisioning record data.
/// @param fragmentMaximumSize The maximum size of the provisioning record fragment that the Provisioner can receive.
//- (instancetype)initProvisioningRecordRequestPDUWithRecordID:(UInt16)recordID fragmentOffset:(UInt16)fragmentOffset fragmentMaximumSize:(UInt16)fragmentMaximumSize {
//    if (self = [super init]) {
//        NSMutableData *mData = [NSMutableData data];
//        UInt8 tem8 = SigProvisioningPduType_recordRequest;
//        [mData appendData:[NSData dataWithBytes:&tem8 length:1]];
//        UInt16 tem16 = CFSwapInt16BigToHost(recordID);
//        [mData appendData:[NSData dataWithBytes:&tem16 length:2]];
//        tem16 = CFSwapInt16BigToHost(fragmentOffset);
//        [mData appendData:[NSData dataWithBytes:&tem16 length:2]];
//        tem16 = CFSwapInt16BigToHost(fragmentMaximumSize);
//        [mData appendData:[NSData dataWithBytes:&tem16 length:2]];
//        self.provisionType = SigProvisioningPduType_recordRequest;
//        self.pduData = mData;
//    }
//    return self;
//}

/// The Provisioner sends a Provisioning Records Get PDU to request the list of IDs of the provisioning records that are stored on a device.
//- (instancetype)initProvisioningRecordsGetPDU {
//    if (self = [super init]) {
//        NSMutableData *mData = [NSMutableData data];
//        UInt8 tem8 = SigProvisioningPduType_recordsGet;
//        [mData appendData:[NSData dataWithBytes:&tem8 length:1]];
//        self.provisionType = SigProvisioningPduType_recordsGet;
//        self.pduData = mData;
//    }
//    return self;
//}

//+ (void)analysisProvisioningCapabilities:(struct ProvisioningCapabilities *)provisioningCapabilities withData:(NSData *)data {
//    if (data.length != 12) {
//        TeLogWarn(@"receive pdu isn't ProvisioningCapabilitiesPDU.")
//        return;
//    }
//    
//    Byte *byte = (Byte *)data.bytes;
//    memcpy(provisioningCapabilities, byte, 12);
//    if (provisioningCapabilities->pduType == SigProvisioningPduType_capabilities) {
//        TeLogVerbose(@"analysis ProvisioningCapabilitiesPDU success.")
//    }else{
//        TeLogVerbose(@"analysis ProvisioningCapabilitiesPDU fail.")
//        memcpy(provisioningCapabilities, 0, 12);
//    }
//}

/// document in Mesh_v1.0.pdf 5.4.1.4 Page 243.
//- (NSData *)getProvisioningPublicKeyPduWithPublicKey:(NSData *)publicKey {
//    struct PublicKeyPdu pdu = {};
//    pdu.type = SigProvisioningPduType_publicKey;
//    UInt8 *byte = (UInt8 *)publicKey.bytes;
//    memcpy(pdu.publicKey, byte, publicKey.length);//64bytes
//    NSData *pduData = [NSData dataWithBytes:&pdu length:sizeof(pdu)];
//    return pduData;
//}
//
///// document in Mesh_v1.0.pdf 5.4.1.6 Page 243.
//- (NSData *)getProvisioningConfirmationPduWithConfirmation:(NSData *)confirmation {
//    struct ConfirmationPdu pdu = {};
//    pdu.type = SigProvisioningPduType_confirmation;
//    UInt8 *byte = (UInt8 *)confirmation.bytes;
//    memcpy(pdu.confirmation, byte, confirmation.length);//16bytes
//    NSData *pduData = [NSData dataWithBytes:&pdu length:sizeof(pdu)];
//    return pduData;
//}

/// document in Mesh_v1.0.pdf 5.4.1.7 Page 243.
//- (NSData *)getProvisioningRandomPduWithRandom:(NSData *)random {
//    struct RandomPdu pdu = {};
//    pdu.type = SigProvisioningPduType_random;
//    UInt8 *byte = (UInt8 *)random.bytes;
//    memcpy(pdu.random, byte, random.length);//16bytes
//    NSData *pduData = [NSData dataWithBytes:&pdu length:sizeof(pdu)];
//    return pduData;
//}

/// document in Mesh_v1.0.pdf 5.4.1.8 Page 244.
//- (NSData *)getProvisioningEncryptedDataWithMicPduWithEncryptedData:(NSData *)encryptedData {
//    struct EncryptedDataWithMicPdu pdu = {};
//    pdu.type = SigProvisioningPduType_data;
//    UInt8 *byte = (UInt8 *)encryptedData.bytes;
//    memcpy(pdu.encryptedDataWithMic, byte, encryptedData.length);//25bytes(EncryptedData)+8bytes(Mic)
//    NSData *pduData = [NSData dataWithBytes:&pdu length:sizeof(pdu)];
//    return pduData;
//}

@end


@implementation SigProvisioningInvitePdu

- (instancetype)initWithAttentionDuration:(UInt8)attentionDuration {
    if (self = [super init]) {
        self.provisionType = SigProvisioningPduType_invite;
        _attentionDuration = attentionDuration;
        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = self.provisionType;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = attentionDuration;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        self.pduData = mData;
    }
    return self;
}

@end


@implementation SigProvisioningCapabilitiesPdu

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        if (parameters && parameters.length == 12) {
            self.pduData = [NSData dataWithData:parameters];
            UInt8 tem8 = 0;
            UInt16 tem16 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            if (tem8 == SigProvisioningPduType_capabilities) {
                self.provisionType = SigProvisioningPduType_capabilities;
                memcpy(&tem8, dataByte+1, 1);
                _numberOfElements = tem8;
                memcpy(&tem16, dataByte+2, 2);
                _algorithms.value = tem16;
                memcpy(&tem8, dataByte+4, 1);
                _publicKeyType = tem8;
                memcpy(&tem8, dataByte+5, 1);
                _staticOobType.value = tem8;
                memcpy(&tem8, dataByte+6, 1);
                _outputOobSize = tem8;
                memcpy(&tem16, dataByte+7, 2);
                _outputOobActions.value = tem16;
                memcpy(&tem8, dataByte+9, 1);
                _outputOobSize = tem8;
                memcpy(&tem16, dataByte+10, 2);
                _outputOobActions.value = tem16;
                return self;
            } else {
                return nil;
            }
        }else{
            return nil;
        }
    }
    return self;
}

- (NSString *)getAlgorithmsString {
    NSString *tem = @"";
    if (_algorithms.fipsP256EllipticCurve == 1) {
        tem = [tem stringByAppendingString:@"FIPS P-256 Elliptic Curve"];
    }
    if (_algorithms.fipsP256EllipticCurve_HMAC_SHA256 == 1) {
        if (tem.length > 0) {
            tem = [tem stringByAppendingString:@"\n"];
        }
        tem = [tem stringByAppendingString:@"FIPS P-256 Elliptic Curve - HMAC - SHA256"];
    }
    if (tem.length == 0) {
        tem = @"None";
    }
    return tem;
}

- (NSString *)getCapabilitiesString {
    NSString *string = [NSString stringWithFormat:@"\n------ Capabilities ------\nNumber of elements: %d\nAlgorithms: %@\nPublic Key Type: %@\nStatic OOB Type: %@\nOutput OOB Size: %d\nOutput OOB Actions: %d\nInput OOB Size: %d\nInput OOB Actions: %d\n--------------------------",_numberOfElements,[self getAlgorithmsString],_publicKeyType == PublicKeyType_noOobPublicKey ?@"No OOB Public Key":@"OOB Public Key",_staticOobType.staticOobInformationAvailable == 1 ?@"YES":@"None",_outputOobSize,_outputOobActions.value,_inputOobSize,_inputOobActions.value];
    return string;
}

@end


@implementation SigProvisioningStartPdu

- (instancetype)initWithAlgorithm:(Algorithm)algorithm publicKeyType:(PublicKeyType)publicKeyType authenticationMethod:(AuthenticationMethod)authenticationMethod authenticationAction:(UInt8)authenticationAction authenticationSize:(UInt8)authenticationSize {
    if (self = [super init]) {
        self.provisionType = SigProvisioningPduType_start;
        _algorithm = algorithm;
        _publicKeyType = publicKeyType;
        _authenticationMethod = authenticationMethod;
        _authenticationAction = authenticationAction;
        _authenticationSize = authenticationSize;
        
        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = self.provisionType;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = algorithm;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = publicKeyType;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = authenticationMethod;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = authenticationAction;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem8 = authenticationSize;
        data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        self.pduData = mData;
    }
    return self;
}

@end


@implementation SigProvisioningPublicKeyPdu

- (instancetype)initWithPublicKey:(NSData *)publicKey {
    if (self = [super init]) {
        self.provisionType = SigProvisioningPduType_publicKey;
        if (publicKey.length == 64) {
            _publicKey = publicKey;
            _publicKeyX = [publicKey subdataWithRange:NSMakeRange(0, 32)];
            _publicKeyY = [publicKey subdataWithRange:NSMakeRange(32, 32)];
            NSMutableData *mData = [NSMutableData data];
            UInt8 tem8 = self.provisionType;
            NSData *data = [NSData dataWithBytes:&tem8 length:1];
            [mData appendData:data];
            [mData appendData:_publicKey];
            self.pduData = mData;
        } else {
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithPublicKeyX:(NSData *)publicKeyX publicKeyY:(NSData *)publicKeyY {
    if (self = [super init]) {
        self.provisionType = SigProvisioningPduType_publicKey;
        if (publicKeyX.length == 32 && publicKeyY.length == 32) {
            NSMutableData *mdata = [NSMutableData dataWithData:publicKeyX];
            [mdata appendData:publicKeyY];
            _publicKey = mdata;
            _publicKeyX = publicKeyX;
            _publicKeyY = publicKeyY;
            NSMutableData *mData = [NSMutableData data];
            UInt8 tem8 = self.provisionType;
            NSData *data = [NSData dataWithBytes:&tem8 length:1];
            [mData appendData:data];
            [mData appendData:_publicKey];
            self.pduData = mData;
        } else {
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        if (parameters && parameters.length == 65) {
            self.pduData = [NSData dataWithData:parameters];
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            if (tem8 == SigProvisioningPduType_publicKey) {
                self.provisionType = SigProvisioningPduType_publicKey;
                _publicKey = [parameters subdataWithRange:NSMakeRange(1, parameters.length-1)];
                _publicKeyX = [parameters subdataWithRange:NSMakeRange(1, 32)];
                _publicKeyY = [parameters subdataWithRange:NSMakeRange(33, 32)];
                return self;
            } else {
                return nil;
            }
        }else{
            return nil;
        }
    }
    return self;
}

@end


@implementation SigProvisioningInputCompletePdu

- (instancetype)init {
    if (self = [super init]) {
        self.provisionType = SigProvisioningPduType_inputComplete;
        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = self.provisionType;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        self.pduData = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        if (parameters && parameters.length == 1) {
            self.pduData = [NSData dataWithData:parameters];
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            if (tem8 == SigProvisioningPduType_inputComplete) {
                self.provisionType = SigProvisioningPduType_inputComplete;
                return self;
            } else {
                return nil;
            }
        }else{
            return nil;
        }
    }
    return self;
}

@end


@implementation SigProvisioningConfirmationPdu

- (instancetype)initWithConfirmation:(NSData *)confirmation {
    if (self = [super init]) {
        self.provisionType = SigProvisioningPduType_confirmation;
        if (confirmation && (confirmation.length == 16 || confirmation.length == 32)) {
            NSMutableData *mData = [NSMutableData data];
            UInt8 tem8 = self.provisionType;
            NSData *data = [NSData dataWithBytes:&tem8 length:1];
            [mData appendData:data];
            [mData appendData:confirmation];
            self.pduData = mData;
        } else {
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        if (parameters && (parameters.length == 17 || parameters.length == 33)) {
            self.pduData = [NSData dataWithData:parameters];
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            if (tem8 == SigProvisioningPduType_confirmation) {
                self.provisionType = SigProvisioningPduType_confirmation;
                _confirmation = [parameters subdataWithRange:NSMakeRange(1, parameters.length-1)];
                return self;
            } else {
                return nil;
            }
        }else{
            return nil;
        }
    }
    return self;
}

@end


@implementation SigProvisioningRandomPdu

- (instancetype)initWithRandom:(NSData *)random {
    if (self = [super init]) {
        self.provisionType = SigProvisioningPduType_random;
        if (random && (random.length == 16 || random.length == 32)) {
            NSMutableData *mData = [NSMutableData data];
            UInt8 tem8 = self.provisionType;
            NSData *data = [NSData dataWithBytes:&tem8 length:1];
            [mData appendData:data];
            [mData appendData:random];
            self.pduData = mData;
        } else {
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        if (parameters && (parameters.length == 17 || parameters.length == 33)) {
            self.pduData = [NSData dataWithData:parameters];
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            if (tem8 == SigProvisioningPduType_random) {
                self.provisionType = SigProvisioningPduType_random;
                _random = [parameters subdataWithRange:NSMakeRange(1, parameters.length-1)];
                return self;
            } else {
                return nil;
            }
        }else{
            return nil;
        }
    }
    return self;
}

@end


@implementation SigProvisioningDataPdu

- (instancetype)initWithEncryptedProvisioningData:(NSData *)encryptedProvisioningData provisioningDataMIC:(NSData *)provisioningDataMIC {
    if (self = [super init]) {
        self.provisionType = SigProvisioningPduType_data;
        if (encryptedProvisioningData && encryptedProvisioningData.length == 25 && provisioningDataMIC && provisioningDataMIC.length == 8) {
            NSMutableData *mData = [NSMutableData data];
            UInt8 tem8 = self.provisionType;
            NSData *data = [NSData dataWithBytes:&tem8 length:1];
            [mData appendData:data];
            [mData appendData:encryptedProvisioningData];
            [mData appendData:provisioningDataMIC];
            self.pduData = mData;
        } else {
            return nil;
        }
    }
    return self;
}

@end


@implementation SigProvisioningCompletePdu

- (instancetype)init {
    if (self = [super init]) {
        self.provisionType = SigProvisioningPduType_complete;
        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = self.provisionType;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        self.pduData = mData;
    }
    return self;
}

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        if (parameters && parameters.length == 1) {
            self.pduData = [NSData dataWithData:parameters];
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            if (tem8 == SigProvisioningPduType_complete) {
                self.provisionType = SigProvisioningPduType_complete;
                return self;
            } else {
                return nil;
            }
        }else{
            return nil;
        }
    }
    return self;
}

@end


@implementation SigProvisioningFailedPdu

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        if (parameters && parameters.length == 2) {
            self.pduData = [NSData dataWithData:parameters];
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            if (tem8 == SigProvisioningPduType_failed) {
                self.provisionType = SigProvisioningPduType_failed;
                memcpy(&tem8, dataByte+1, 1);
                _errorCode = tem8;
                return self;
            } else {
                return nil;
            }
        }else{
            return nil;
        }
    }
    return self;
}

@end


@implementation SigProvisioningRecordRequestPdu

- (instancetype)initWithRecordID:(UInt16)recordID fragmentOffset:(UInt16)fragmentOffset fragmentMaximumSize:(UInt16)fragmentMaximumSize {
    if (self = [super init]) {
        self.provisionType = SigProvisioningPduType_recordRequest;
        _recordID = recordID;
        _fragmentOffset = fragmentOffset;
        _fragmentMaximumSize = fragmentMaximumSize;
        NSMutableData *mData = [NSMutableData data];
        UInt16 tem16 = 0;
        UInt8 tem8 = self.provisionType;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        tem16 = CFSwapInt16BigToHost(recordID);
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = CFSwapInt16BigToHost(fragmentOffset);
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        tem16 = CFSwapInt16BigToHost(fragmentMaximumSize);
        data = [NSData dataWithBytes:&tem16 length:2];
        [mData appendData:data];
        self.pduData = mData;
    }
    return self;
}

@end


@implementation SigProvisioningRecordResponsePdu

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        if (parameters && parameters.length >= 8) {
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            if (tem8 == SigProvisioningPduType_recordResponse) {
                self.provisionType = SigProvisioningPduType_recordResponse;
                self.pduData = [NSData dataWithData:parameters];
                memcpy(&tem8, dataByte+1, 1);
                _status = tem8;
                UInt16 tem16 = 0;
                memcpy(&tem16, dataByte+2, 2);
                UInt16 host16 = CFSwapInt16BigToHost(tem16);
                _recordID = host16;
                memcpy(&tem16, dataByte+4, 2);
                host16 = CFSwapInt16BigToHost(tem16);
                _fragmentOffset = host16;
                memcpy(&tem16, dataByte+6, 2);
                host16 = CFSwapInt16BigToHost(tem16);
                _totalLength = host16;
                if (parameters.length > 8) {
                    _data = [parameters subdataWithRange:NSMakeRange(8, parameters.length - 8)];
                }
            } else {
                return nil;
            }
        }else{
            return nil;
        }
    }
    return self;
}

@end


@implementation SigProvisioningRecordsGetPdu

- (instancetype)init {
    if (self = [super init]) {
        self.provisionType = SigProvisioningPduType_recordsGet;
        NSMutableData *mData = [NSMutableData data];
        UInt8 tem8 = self.provisionType;
        NSData *data = [NSData dataWithBytes:&tem8 length:1];
        [mData appendData:data];
        self.pduData = mData;
    }
    return self;
}

@end


@implementation SigProvisioningRecordsListPdu

- (instancetype)initWithParameters:(NSData *)parameters {
    if (self = [super init]) {
        if (parameters && parameters.length >= 3) {
            UInt8 tem8 = 0;
            Byte *dataByte = (Byte *)parameters.bytes;
            memcpy(&tem8, dataByte, 1);
            if (tem8 == SigProvisioningPduType_recordsList) {
                self.provisionType = SigProvisioningPduType_recordsList;
                self.pduData = [NSData dataWithData:parameters];
                Byte *pduByte = (Byte *)parameters.bytes;
                UInt16 tem16 = 0;
                memcpy(&tem16, pduByte+1, 2);
                _provisioningExtensions = tem16;
                NSMutableArray *mArray = [NSMutableArray array];
                while ((mArray.count + 1) * 2 + 1 + 2 <= parameters.length) {
                    memcpy(&tem16, pduByte+1+2+2*mArray.count, 2);
                    UInt16 host16 = CFSwapInt16BigToHost(tem16);
                    [mArray addObject:@(host16)];
                }
                _recordsList = mArray;
            } else {
                return nil;
            }
        }else{
            return nil;
        }
    }
    return self;
}

@end


@implementation SigNetworkPdu

- (instancetype)initWithDecodePduData:(NSData *)pdu pduType:(SigPduType)pduType usingNetworkKey:(SigNetkeyModel *)networkKey ivIndex:(SigIvIndex *)ivIndex {
    if (self = [super init]) {
        if (pduType != SigPduType_networkPdu && pduType != SigPduType_proxyConfiguration) {
            TeLogError(@"pdutype is not support.");
            return nil;
        }
        self.pduData = pdu;
        if (pdu.length < 14) {
            TeLogDebug(@"Valid message must have at least 14 octets.");
            return nil;
        }
        
        // The first byte is not obfuscated.
        UInt8 *byte = (UInt8 *)pdu.bytes;
        UInt8 tem = 0;
        memcpy(&tem, byte, 1);
        _ivi  = tem >> 7;
        _nid  = tem & 0x7F;
        // The NID must match.
        // If the Key Refresh procedure is in place, the received packet might have been encrypted using an old key. We have to try both.
        NSMutableArray <SigNetkeyDerivaties *>*keySets = [NSMutableArray array];
        if (_nid == networkKey.nid) {
            [keySets addObject:networkKey.keys];
        }
        if (networkKey.oldKeys != nil && networkKey.oldNid == _nid) {
            [keySets addObject:networkKey.keys];
        }
        if (keySets.count == 0) {
            return nil;
        }
        
        // IVI should match the LSB bit of current IV Index.
        // If it doesn't, and the IV Update procedure is active, the PDU will be deobfuscated and decoded with IV Index decremented by 1.
        UInt32 index = ivIndex.index;
        if (_ivi != (index & 0x01)) {
            if (index > 0) {
                index -= 1;
            }
        }
//        TeLogVerbose(@"解密使用IvIndex=0x%x",index);
        for (SigNetkeyDerivaties *keys in keySets) {
            // Deobfuscate CTL, TTL, SEQ and SRC.
            NSData *deobfuscatedData = [OpenSSLHelper.share deobfuscate:pdu ivIndex:index privacyKey:keys.privacyKey];

            // First validation: Control Messages have NetMIC of size 64 bits.
            byte = (UInt8 *)deobfuscatedData.bytes;
            memcpy(&tem, byte, 1);
            UInt8 ctl = tem >> 7;
            if (ctl != 0 && pdu.length < 18) {
                continue;
            }
            SigLowerTransportPduType type = (SigLowerTransportPduType)ctl;
            UInt8 ttl = tem & 0x7F;
            UInt32 tem1=0,tem2=0,tem3=0,tem4=0,tem5=0;
            memcpy(&tem1, byte+1, 1);
            memcpy(&tem2, byte+2, 1);
            memcpy(&tem3, byte+3, 1);
            memcpy(&tem4, byte+4, 1);
            memcpy(&tem5, byte+5, 1);

            // Multiple octet values use Big Endian.
            UInt32 sequence = tem1 << 16 | tem2 << 8 | tem3;
            UInt32 source = tem4 << 8 | tem5;
            NSInteger micOffset = pdu.length - [self getNetMicSizeOfLowerTransportPduType:type];
            NSData *destAndTransportPdu = [pdu subdataWithRange:NSMakeRange(7, micOffset-7)];
            NSData *mic = [pdu subdataWithRange:NSMakeRange(micOffset, pdu.length-micOffset)];
            tem = [self getNonceIdOfSigPduType:pduType];
            NSData *data1 = [NSData dataWithBytes:&tem length:1];
            UInt16 tem16 = 0;
            NSData *data2 = [NSData dataWithBytes:&tem16 length:2];
            UInt32 bigIndex = CFSwapInt32HostToBig(index);
            NSData *data3 = [NSData dataWithBytes:&bigIndex length:4];
            NSMutableData *networkNonce = [NSMutableData dataWithData:data1];
            [networkNonce appendData:deobfuscatedData];
            [networkNonce appendData:data2];
            [networkNonce appendData:data3];
            if (pduType == SigPduType_proxyConfiguration) {
                UInt8 zero = 0;// Pad
                [networkNonce replaceBytesInRange:NSMakeRange(1, 1) withBytes:&zero length:1];
            }
            NSData *decryptedData = [OpenSSLHelper.share calculateDecryptedCCM:destAndTransportPdu withKey:keys.encryptionKey nonce:networkNonce andMIC:mic withAdditionalData:nil];
            if (decryptedData == nil || decryptedData.length == 0) {
                TeLogError(@"decryptedData == nil");
                continue;
            }
            
            _networkKey = networkKey;
            _type = type;
            _ttl = ttl;
            _sequence = sequence;
            _source = source;
            UInt8 decryptedData0 = 0,decryptedData1 = 0;
            Byte *decryptedDataByte = (Byte *)decryptedData.bytes;
            memcpy(&decryptedData0, decryptedDataByte+0, 1);
            memcpy(&decryptedData1, decryptedDataByte+1, 1);
            _destination = (UInt16)decryptedData0 << 8 | (UInt16)decryptedData1;
            _transportPdu = [decryptedData subdataWithRange:NSMakeRange(2, decryptedData.length-2)];
            return self;
        }
    }
    return nil;
}

/// Creates Network PDU object from received PDU. The initiator tries to deobfuscate and decrypt the data using given Network Key and IV Index.
///
/// - parameter pdu:        The data received from mesh network.
/// - parameter pduType:    The type of the PDU: `.networkPdu` of `.proxyConfiguration`.
/// - parameter networkKey: The Network Key to decrypt the PDU.
/// - returns: The deobfuscated and decided Network PDU object, or `nil`, if the key or IV Index don't match.
- (instancetype)initWithDecodePduData:(NSData *)pdu pduType:(SigPduType)pduType usingNetworkKey:(SigNetkeyModel *)networkKey {
    if (self = [super init]) {
        if (pduType != SigPduType_networkPdu && pduType != SigPduType_proxyConfiguration) {
            TeLogError(@"pdutype is not support.");
            return nil;
        }
        self.pduData = pdu;
        if (pdu.length < 14) {
            TeLogDebug(@"Valid message must have at least 14 octets.");
            return nil;
        }
        
        // The first byte is not obfuscated.
        UInt8 *byte = (UInt8 *)pdu.bytes;
        UInt8 tem = 0;
        memcpy(&tem, byte, 1);
        _ivi  = tem >> 7;
        _nid  = tem & 0x7F;
        // The NID must match.
        // If the Key Refresh procedure is in place, the received packet might have been encrypted using an old key. We have to try both.
        NSMutableArray <SigNetkeyDerivaties *>*keySets = [NSMutableArray array];
        if (_nid == networkKey.nid) {
            [keySets addObject:networkKey.keys];
        }
        if (networkKey.oldKeys != nil && networkKey.oldNid == _nid) {
            [keySets addObject:networkKey.oldKeys];
        }
        if (keySets.count == 0) {
            return nil;
        }
        
        // IVI should match the LSB bit of current IV Index.
        // If it doesn't, and the IV Update procedure is active, the PDU will be deobfuscated and decoded with IV Index decremented by 1.
        UInt32 index = networkKey.ivIndex.index;
        if (_ivi != (index & 0x01)) {
            if (index > 0) {
                index -= 1;
            }
        }
//        TeLogVerbose(@"解密使用IvIndex=0x%x",index);
        for (SigNetkeyDerivaties *keys in keySets) {
            // Deobfuscate CTL, TTL, SEQ and SRC.
            NSData *deobfuscatedData = [OpenSSLHelper.share deobfuscate:pdu ivIndex:index privacyKey:keys.privacyKey];

            // First validation: Control Messages have NetMIC of size 64 bits.
            byte = (UInt8 *)deobfuscatedData.bytes;
            memcpy(&tem, byte, 1);
            UInt8 ctl = tem >> 7;
            if (ctl != 0 && pdu.length < 18) {
                continue;
            }
            SigLowerTransportPduType type = (SigLowerTransportPduType)ctl;
            UInt8 ttl = tem & 0x7F;
            UInt32 tem1=0,tem2=0,tem3=0,tem4=0,tem5=0;
            memcpy(&tem1, byte+1, 1);
            memcpy(&tem2, byte+2, 1);
            memcpy(&tem3, byte+3, 1);
            memcpy(&tem4, byte+4, 1);
            memcpy(&tem5, byte+5, 1);

            // Multiple octet values use Big Endian.
            UInt32 sequence = tem1 << 16 | tem2 << 8 | tem3;
            UInt32 source = tem4 << 8 | tem5;
            NSInteger micOffset = pdu.length - [self getNetMicSizeOfLowerTransportPduType:type];
            NSData *destAndTransportPdu = [pdu subdataWithRange:NSMakeRange(7, micOffset-7)];
            NSData *mic = [pdu subdataWithRange:NSMakeRange(micOffset, pdu.length-micOffset)];
            tem = [self getNonceIdOfSigPduType:pduType];
            NSData *data1 = [NSData dataWithBytes:&tem length:1];
            UInt16 tem16 = 0;
            NSData *data2 = [NSData dataWithBytes:&tem16 length:2];
            UInt32 bigIndex = CFSwapInt32HostToBig(index);
            NSData *data3 = [NSData dataWithBytes:&bigIndex length:4];
            NSMutableData *networkNonce = [NSMutableData dataWithData:data1];
            [networkNonce appendData:deobfuscatedData];
            [networkNonce appendData:data2];
            [networkNonce appendData:data3];
            if (pduType == SigPduType_proxyConfiguration) {
                UInt8 zero = 0;// Pad
                [networkNonce replaceBytesInRange:NSMakeRange(1, 1) withBytes:&zero length:1];
            }
            NSData *decryptedData = [OpenSSLHelper.share calculateDecryptedCCM:destAndTransportPdu withKey:keys.encryptionKey nonce:networkNonce andMIC:mic withAdditionalData:nil];
            if (decryptedData == nil || decryptedData.length == 0) {
                TeLogError(@"decryptedData == nil");
                continue;
            }
            

            
            _networkKey = networkKey;
            _type = type;
            _ttl = ttl;
            _sequence = sequence;
            _source = source;
            UInt8 decryptedData0 = 0,decryptedData1 = 0;
            Byte *decryptedDataByte = (Byte *)decryptedData.bytes;
            memcpy(&decryptedData0, decryptedDataByte+0, 1);
            memcpy(&decryptedData1, decryptedDataByte+1, 1);
            _destination = (UInt16)decryptedData0 << 8 | (UInt16)decryptedData1;
            _transportPdu = [decryptedData subdataWithRange:NSMakeRange(2, decryptedData.length-2)];
            return self;
        }
    }
    return nil;
}

- (UInt32)getDecodeIvIndex {
    UInt32 index = _networkKey.ivIndex.index;
    if (_ivi != (index & 0x01)) {
        if (index > 0) {
            index -= 1;
        }
    }
    return index;
}

- (instancetype)initWithEncodeLowerTransportPdu:(SigLowerTransportPdu *)lowerTransportPdu pduType:(SigPduType)pduType withSequence:(UInt32)sequence andTtl:(UInt8)ttl ivIndex:(SigIvIndex *)ivIndex {
    if (self = [super init]) {
        UInt32 index = ivIndex.index;

        _networkKey = lowerTransportPdu.networkKey;
        _ivi = (UInt8)(index&0x01);
        _nid = _networkKey.nid;
        if (_networkKey.phase == distributingKeys) {
            _nid = _networkKey.oldNid;
        }
        _type = lowerTransportPdu.type;
        _source = lowerTransportPdu.source;
        _destination = lowerTransportPdu.destination;
        _transportPdu = lowerTransportPdu.transportPdu;
        _ttl = ttl;
        _sequence = sequence;

        UInt8 iviNid = (_ivi << 7) | (_nid & 0x7F);
        UInt8 ctlTtl = (_type << 7) | (_ttl & 0x7F);

        // Data to be obfuscated: CTL/TTL, Sequence Number, Source Address.
        UInt32 bigSequece = CFSwapInt32HostToBig(sequence);
        UInt16 bigSource = CFSwapInt16HostToBig(_source);
        UInt16 bigDestination = CFSwapInt16HostToBig(_destination);
        UInt32 bigIndex = CFSwapInt32HostToBig(index);

        NSData *seq = [[NSData dataWithBytes:&bigSequece length:4] subdataWithRange:NSMakeRange(1, 3)];
        NSData *data1 = [NSData dataWithBytes:&ctlTtl length:1];
        NSData *data2 = [NSData dataWithBytes:&bigSource length:2];
        NSMutableData *deobfuscatedData = [NSMutableData dataWithData:data1];
        [deobfuscatedData appendData:seq];
        [deobfuscatedData appendData:data2];

        // Data to be encrypted: Destination Address, Transport PDU.
        NSData *data3 = [NSData dataWithBytes:&bigDestination length:2];
        NSMutableData *decryptedData = [NSMutableData dataWithData:data3];
        [decryptedData appendData:_transportPdu];
        
        // The key set used for encryption depends on the Key Refresh Phase.
        SigNetkeyDerivaties *keys = _networkKey.transmitKeys;
        UInt8 tem = [self getNonceIdOfSigPduType:pduType];
        data1 = [NSData dataWithBytes:&tem length:1];
        UInt16 tem16 = 0;
        data2 = [NSData dataWithBytes:&tem16 length:2];
        data3 = [NSData dataWithBytes:&bigIndex length:4];
        NSMutableData *networkNonce = [NSMutableData dataWithData:data1];
        [networkNonce appendData:deobfuscatedData];
        [networkNonce appendData:data2];
        [networkNonce appendData:data3];
        if (pduType == SigPduType_proxyConfiguration) {
            tem = 0x00;//Pad
            [networkNonce replaceBytesInRange:NSMakeRange(1, 1) withBytes:&tem length:1];
        }

        NSData *encryptedData = [OpenSSLHelper.share calculateCCM:decryptedData withKey:keys.encryptionKey nonce:networkNonce andMICSize:[self getNetMicSizeOfLowerTransportPduType:_type] withAdditionalData:nil];
        NSData *obfuscatedData = [OpenSSLHelper.share obfuscate:deobfuscatedData usingPrivacyRandom:encryptedData ivIndex:index andPrivacyKey:keys.privacyKey];

        NSMutableData *pduData = [NSMutableData dataWithBytes:&iviNid length:1];
        [pduData appendData:obfuscatedData];
        [pduData appendData:encryptedData];
        self.pduData = pduData;
    }
    return self;
}

/// Creates the Network PDU. This method enctypts and obfuscates data that are to be send to the mesh network.
///
/// - parameter lowerTransportPdu: The data received from higher layer.
/// - parameter pduType:  The type of the PDU: `.networkPdu` of `.proxyConfiguration`.
/// - parameter sequence: The SEQ number of the PDU. Each PDU between the source and destination must have strictly increasing sequence number.
/// - parameter ttl: Time To Live.
/// - returns: The Network PDU object.
- (instancetype)initWithEncodeLowerTransportPdu:(SigLowerTransportPdu *)lowerTransportPdu pduType:(SigPduType)pduType withSequence:(UInt32)sequence andTtl:(UInt8)ttl {
    if (self = [super init]) {
        UInt32 index = lowerTransportPdu.networkKey.ivIndex.index;

        _networkKey = lowerTransportPdu.networkKey;
        _ivi = (UInt8)(index&0x01);
        _nid = _networkKey.nid;
        _type = lowerTransportPdu.type;
        _source = lowerTransportPdu.source;
        _destination = lowerTransportPdu.destination;
        _transportPdu = lowerTransportPdu.transportPdu;
        _ttl = ttl;
        _sequence = sequence;

        UInt8 iviNid = (_ivi << 7) | (_nid & 0x7F);
        UInt8 ctlTtl = (_type << 7) | (_ttl & 0x7F);

        // Data to be obfuscated: CTL/TTL, Sequence Number, Source Address.
        UInt32 bigSequece = CFSwapInt32HostToBig(sequence);
        UInt16 bigSource = CFSwapInt16HostToBig(_source);
        UInt16 bigDestination = CFSwapInt16HostToBig(_destination);
        UInt32 bigIndex = CFSwapInt32HostToBig(index);

        NSData *seq = [[NSData dataWithBytes:&bigSequece length:4] subdataWithRange:NSMakeRange(1, 3)];
        NSData *data1 = [NSData dataWithBytes:&ctlTtl length:1];
        NSData *data2 = [NSData dataWithBytes:&bigSource length:2];
        NSMutableData *deobfuscatedData = [NSMutableData dataWithData:data1];
        [deobfuscatedData appendData:seq];
        [deobfuscatedData appendData:data2];

        // Data to be encrypted: Destination Address, Transport PDU.
        NSData *data3 = [NSData dataWithBytes:&bigDestination length:2];
        NSMutableData *decryptedData = [NSMutableData dataWithData:data3];
        [decryptedData appendData:_transportPdu];
        
        // The key set used for encryption depends on the Key Refresh Phase.
        SigNetkeyDerivaties *keys = _networkKey.transmitKeys;
        UInt8 tem = [self getNonceIdOfSigPduType:pduType];
        data1 = [NSData dataWithBytes:&tem length:1];
        UInt16 tem16 = 0;
        data2 = [NSData dataWithBytes:&tem16 length:2];
        data3 = [NSData dataWithBytes:&bigIndex length:4];
        NSMutableData *networkNonce = [NSMutableData dataWithData:data1];
        [networkNonce appendData:deobfuscatedData];
        [networkNonce appendData:data2];
        [networkNonce appendData:data3];
        if (pduType == SigPduType_proxyConfiguration) {
            tem = 0x00;//Pad
            [networkNonce replaceBytesInRange:NSMakeRange(1, 1) withBytes:&tem length:1];
        }

        NSData *encryptedData = [OpenSSLHelper.share calculateCCM:decryptedData withKey:keys.encryptionKey nonce:networkNonce andMICSize:[self getNetMicSizeOfLowerTransportPduType:_type] withAdditionalData:nil];
        NSData *obfuscatedData = [OpenSSLHelper.share obfuscate:deobfuscatedData usingPrivacyRandom:encryptedData ivIndex:index andPrivacyKey:keys.privacyKey];

        NSMutableData *pduData = [NSMutableData dataWithBytes:&iviNid length:1];
        [pduData appendData:obfuscatedData];
        [pduData appendData:encryptedData];
        self.pduData = pduData;
    }
    return self;
}

+ (SigNetworkPdu *)decodePdu:(NSData *)pdu pduType:(SigPduType)pduType usingNetworkKey:(SigNetkeyModel *)networkKey ivIndex:(SigIvIndex *)ivIndex {
    return [[SigNetworkPdu alloc] initWithDecodePduData:pdu pduType:pduType usingNetworkKey:networkKey ivIndex:ivIndex];
}

/// This method goes over all Network Keys in the mesh network and tries to deobfuscate and decode the network PDU.
///
/// - parameter pdu:         The received PDU.
/// - parameter type:        The type of the PDU: `.networkPdu` of `.proxyConfiguration`.
/// - parameter meshNetwork: The mesh network for which the PDU should be decoded.
/// - returns: The deobfuscated and decoded Network PDU, or `nil` if the PDU was not signed with any of the Network Keys, the IV Index was not valid, or the PDU was invalid.
+ (SigNetworkPdu *)decodePdu:(NSData *)pdu pduType:(SigPduType)pduType forMeshNetwork:(SigDataSource *)meshNetwork {
    NSArray *netKeys = [NSArray arrayWithArray:meshNetwork.netKeys];
    for (SigNetkeyModel *networkKey in netKeys) {
        SigNetworkPdu *networkPdu = [[SigNetworkPdu alloc] initWithDecodePduData:pdu pduType:pduType usingNetworkKey:networkKey];
        if (networkPdu) {
            return networkPdu;
        }
    }
    return nil;
}

- (UInt8)getNetMicSizeOfLowerTransportPduType:(SigLowerTransportPduType)pduType {
    UInt8 tem = 4;
    if (pduType == SigLowerTransportPduType_accessMessage) {
        tem = 4;// 32 bits
    }else if (pduType == SigLowerTransportPduType_controlMessage) {
        tem = 8;// 64 bits
    }
    return tem;
}

- (UInt8)getNonceIdOfSigPduType:(SigPduType)pduType {
    switch (pduType) {
        case SigPduType_networkPdu:
            return 0x00;
            break;
        case SigPduType_proxyConfiguration:
            return 0x03;
            break;
        default:
            TeLogError(@"Unsupported PDU Type:%lu",(unsigned long)pduType);
            break;
    }
    return 0;
}

- (BOOL)isSegmented {
    UInt8 tem = 0;
    Byte *byte = (Byte *)_transportPdu.bytes;
    memcpy(&tem, byte, 1);
    return (tem&0x80)>1;
}

- (UInt32)messageSequence {
    if (self.isSegmented) {
        UInt8 tem = 0,tem2 = 0;
        Byte *byte = (Byte *)_transportPdu.bytes;
        memcpy(&tem, byte+1, 1);
        memcpy(&tem2, byte+2, 1);
        UInt32 sequenceZero = (UInt16)((tem & 0x7F) << 6) | (UInt16)(tem2 >> 2);
        return (_sequence & 0xFFE000) | (UInt32)sequenceZero;
    } else {
        return _sequence;
    }
}

- (NSString *)description {
    int micSize = [self getNetMicSizeOfLowerTransportPduType:_type];
    NSInteger encryptedDataSize = self.pduData.length - micSize - 9;
    NSData *encryptedData = [self.pduData subdataWithRange:NSMakeRange(9, encryptedDataSize)];
    NSData *mic = [self.pduData subdataWithRange:NSMakeRange(9+encryptedDataSize,self.pduData.length - 9- encryptedDataSize)];
    return[NSString stringWithFormat:@"Network PDU (ivi: 0x%x, nid: 0x%x, ctl: 0x%x, ttl: 0x%x, seq: 0x%x, src: 0x%x, dst: 0x%x, transportPdu: %@, netMic: %@)",_ivi,_nid,_type,_ttl,(unsigned int)_sequence,_source,_destination,encryptedData,mic];
}

@end


@implementation SigBeaconPdu

- (void)setBeaconType:(SigBeaconType)beaconType {
    _beaconType = beaconType;
}

@end

/// 3.9.3 Secure Network beacon
/// - seeAlso: Mesh_Model_Specification v1.0.pdf  (page.120)
@implementation SigSecureNetworkBeacon

- (NSDictionary *)getDictionaryOfSecureNetworkBeacon {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_networkKey && _networkKey.key) {
        dict[@"networkKey"] = _networkKey.key;
    }
    dict[@"keyRefreshFlag"] = [NSNumber numberWithBool:_keyRefreshFlag];
    dict[@"ivUpdateActive"] = [NSNumber numberWithBool:_ivUpdateActive];
    if (_networkId) {
        dict[@"networkId"] = _networkId;
    }
    dict[@"ivIndex"] = [NSNumber numberWithInt:_ivIndex];
    return dict;
}

- (void)setDictionaryToSecureNetworkBeacon:(NSDictionary *)dictionary {
    if (dictionary == nil || dictionary.allKeys.count == 0) {
        return;
    }
    NSArray *allKeys = dictionary.allKeys;
    if ([allKeys containsObject:@"networkKey"]) {
        for (SigNetkeyModel *model in SigMeshLib.share.dataSource.netKeys) {
            if ([model.key isEqualToString:dictionary[@"networkKey"]]) {
                _networkKey = model;
                break;
            }
        }
    }
    if ([allKeys containsObject:@"keyRefreshFlag"]) {
        _keyRefreshFlag = [dictionary[@"keyRefreshFlag"] boolValue];
    }
    if ([allKeys containsObject:@"ivUpdateActive"]) {
        _ivUpdateActive = [dictionary[@"ivUpdateActive"] boolValue];
    }
    if ([allKeys containsObject:@"networkId"]) {
        _networkId = dictionary[@"networkId"];
    }
    if ([allKeys containsObject:@"ivIndex"]) {
        _ivIndex = [dictionary[@"ivIndex"] intValue];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        [super setBeaconType:SigBeaconType_secureNetwork];
    }
    return self;
}

/// Creates USecure Network beacon PDU object from received PDU.
///
/// - parameter pdu: The data received from mesh network.
/// - parameter networkKey: The Network Key to validate the beacon.
/// - returns: The beacon object, or `nil` if the data are invalid.
- (instancetype)initWithDecodePdu:(NSData *)pdu usingNetworkKey:(SigNetkeyModel *)networkKey {
    if (self = [super init]) {
        [super setBeaconType:SigBeaconType_secureNetwork];
        self.pduData = pdu;
        UInt8 tem = 0;
        Byte *pduByte = (Byte *)pdu.bytes;
        memcpy(&tem, pduByte, 1);
        if (pdu.length != 22 || tem != 1) {
            TeLogError(@"pdu data error, can not init decode.");
            return nil;
        }
        memcpy(&tem, pduByte+1, 1);
        _keyRefreshFlag = (tem & 0x01) != 0;
        _ivUpdateActive = (tem & 0x02) != 0;
        _networkId = [pdu subdataWithRange:NSMakeRange(2, 8)];
        UInt32 tem10 = 0;
        memcpy(&tem10, pduByte + 10, 4);
        _ivIndex = CFSwapInt32HostToBig(tem10);
        // Authenticate beacon using given Network Key.
        if ([_networkId isEqualToData:networkKey.networkId]) {
            NSData *authenticationValue = [OpenSSLHelper.share calculateCMAC:[pdu subdataWithRange:NSMakeRange(1, 13)] andKey:networkKey.keys.beaconKey];
            if (![[authenticationValue subdataWithRange:NSMakeRange(0, 8)] isEqualToData:[pdu subdataWithRange:NSMakeRange(14, 8)]]) {
                TeLogError(@"authenticationValue is not current networkID.");
                return nil;
            }
            _networkKey = networkKey;
        }else if (networkKey.oldNetworkId != nil && [networkKey.oldNetworkId isEqualToData:_networkId]) {
            NSData *authenticationValue = [OpenSSLHelper.share calculateCMAC:[pdu subdataWithRange:NSMakeRange(1, 13)] andKey:networkKey.oldKeys.beaconKey];
            if (![[authenticationValue subdataWithRange:NSMakeRange(0, 8)] isEqualToData:[pdu subdataWithRange:NSMakeRange(14, 8)]]) {
                TeLogError(@"authenticationValue is not current old networkID.");
                return nil;
            }
            _networkKey = networkKey;
        }else{
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithKeyRefreshFlag:(BOOL)keyRefreshFlag ivUpdateActive:(BOOL)ivUpdateActive networkId:(NSData *)networkId ivIndex:(UInt32)ivIndex usingNetworkKey:(SigNetkeyModel *)networkKey {
    if (self = [super init]) {
        [super setBeaconType:SigBeaconType_secureNetwork];
        _keyRefreshFlag = keyRefreshFlag;
        _ivUpdateActive = ivUpdateActive;
        _networkId = networkId;
        _ivIndex = ivIndex;
        _networkKey = networkKey;
    }
    return self;
}

/// Creates USecure Network beacon PDU object from received PDU.
///
/// - parameter pdu: The data received from mesh network.
/// - parameter networkKey: The Network Key to validate the beacon.
/// - returns: The beacon object, or `nil` if the data are invalid.
+ (SigSecureNetworkBeacon *)decodePdu:(NSData *)pdu forMeshNetwork:(SigDataSource *)meshNetwork {
    if (pdu == nil || pdu.length <= 1) {
        TeLogError(@"decodePdu length is less than 1.");
        return nil;
    }
    UInt8 tem = 0;
    Byte *pduByte = (Byte *)pdu.bytes;
    memcpy(&tem, pduByte, 1);
    SigBeaconType beaconType = tem;
    if (beaconType == SigBeaconType_secureNetwork) {
        NSArray *netKeys = [NSArray arrayWithArray:meshNetwork.netKeys];
        for (SigNetkeyModel *networkKey in netKeys) {
            SigSecureNetworkBeacon *beacon = [[SigSecureNetworkBeacon alloc] initWithDecodePdu:pdu usingNetworkKey:networkKey];
            if (beacon) {
                return beacon;
            }
        }
    } else {
        return nil;
    }
    return nil;
}

- (NSData *)pduData {
    struct Flags flags = {};
    flags.value = 0;
    if (_keyRefreshFlag) {
        flags.value |= (1 << 0);
    }
    if (_ivUpdateActive) {
        flags.value |= (1 << 1);
    }
    NSMutableData *mData = [NSMutableData data];
    [mData appendData:[NSData dataWithBytes:&flags length:1]];
    [mData appendData:_networkId];
    UInt32 ivIndex32 = CFSwapInt32HostToBig(_ivIndex);
    [mData appendData:[NSData dataWithBytes:&ivIndex32 length:4]];
    NSData *authenticationValue = nil;
    if ([_networkId isEqualToData:_networkKey.networkId]) {
        authenticationValue = [OpenSSLHelper.share calculateCMAC:mData andKey:_networkKey.keys.beaconKey];
    }else if (_networkKey.oldNetworkId != nil && [_networkKey.oldNetworkId isEqualToData:_networkId]) {
        authenticationValue = [OpenSSLHelper.share calculateCMAC:mData andKey:_networkKey.oldKeys.beaconKey];
    }
    if (authenticationValue) {
        [mData appendData:[authenticationValue subdataWithRange:NSMakeRange(0, 8)]];
        UInt8 bType = self.beaconType;
        NSMutableData *allData = [NSMutableData data];
        [allData appendData:[NSData dataWithBytes:&bType length:1]];
        [allData appendData:mData];
        return allData;
    } else {
        return nil;
    }
}

- (NSString *)description {
    return[NSString stringWithFormat:@"<%p> - Secure Network Beacon, network ID:(%@), ivIndex: (%x) Key refresh Flag: (%d), IV Update active: (%d)", self, _networkId,(unsigned int)_ivIndex, _keyRefreshFlag,_ivUpdateActive];
}

@end


@implementation SigUnprovisionedDeviceBeacon

- (instancetype)init {
    if (self = [super init]) {
        [super setBeaconType:SigBeaconType_unprovisionedDevice];
    }
    return self;
}

- (instancetype)initWithDecodePdu:(NSData *)pdu {
    if (self = [super init]) {
        [super setBeaconType:SigBeaconType_unprovisionedDevice];
        self.pduData = pdu;
        UInt8 tem = 0;
        Byte *pduByte = (Byte *)pdu.bytes;
        memcpy(&tem, pduByte, 1);
        if (pdu.length < 19 || tem == 0) {
            return nil;
        }
        _deviceUuid = [LibTools convertDataToHexStr:[pdu subdataWithRange:NSMakeRange(1, 16)]];
        UInt16 temOob = 0;
        memcpy(&temOob, pduByte+17, 1);
        _oob.value = temOob;
        if (pdu.length == 23) {
            _uriHash = [pdu subdataWithRange:NSMakeRange(19, pdu.length-19)];
        } else {
            _uriHash = nil;
        }
    }
    return self;
}

+ (SigUnprovisionedDeviceBeacon *)decodeWithPdu:(NSData *)pdu forMeshNetwork:(SigDataSource *)meshNetwork {
    if (pdu == nil || pdu.length == 0) {
        TeLogError(@"decodePdu length is 0.");
        return nil;
    }
    UInt8 tem = 0;
    Byte *pduByte = (Byte *)pdu.bytes;
    memcpy(&tem, pduByte, 1);
    SigBeaconType beaconType = tem;
    if (beaconType == SigBeaconType_unprovisionedDevice) {
        SigUnprovisionedDeviceBeacon *beacon = [[SigUnprovisionedDeviceBeacon alloc] initWithDecodePdu:pdu];
        return beacon;
    } else {
        return nil;
    }
}

- (NSString *)description {
    return[NSString stringWithFormat:@"<%p> - Unprovisioned Device Beacon, uuid:(%@), OOB Info: (%x) URI hash: (%@)", self, _deviceUuid,_oob.value, _uriHash];
}

@end


/// 3.10.4 Mesh Private beacon
/// - seeAlso: MshPRFd1.1r15_clean.pdf  (page.209)
@implementation SigMeshPrivateBeacon

- (instancetype)init {
    if (self = [super init]) {
        [super setBeaconType:SigBeaconType_meshPrivateBeacon];
    }
    return self;
}

/// Creates Mesh Private beacon PDU object from received PDU.
///
/// - parameter pdu: The data received from mesh network.
/// - parameter networkKey: The Network Key to validate the beacon.
/// - returns: The beacon object, or `nil` if the data are invalid.
- (instancetype)initWithDecodePdu:(NSData *)pdu usingNetworkKey:(SigNetkeyModel *)networkKey {
    if (self = [super init]) {
        [super setBeaconType:SigBeaconType_meshPrivateBeacon];
        self.pduData = pdu;
        UInt8 tem = 0;
        Byte *pduByte = (Byte *)pdu.bytes;
        memcpy(&tem, pduByte, 1);
        if (pdu.length != 27 || tem != SigBeaconType_meshPrivateBeacon) {
            TeLogError(@"pdu data error, can not init decode.");
            return nil;
        }
        _randomData = [pdu subdataWithRange:NSMakeRange(1, 13)];
        _obfuscatedPrivateBeaconData = [pdu subdataWithRange:NSMakeRange(14, 5)];
        _authenticationTag = [pdu subdataWithRange:NSMakeRange(19, 8)];
        
        BOOL authentication = NO;
        NSMutableArray *mArray = [NSMutableArray array];
        if (networkKey.key && networkKey.key.length == 32) {
            [mArray addObject:[LibTools nsstringToHex:networkKey.key]];
        }
        if (networkKey.oldKey && networkKey.oldKey.length == 32) {
            [mArray addObject:[LibTools nsstringToHex:networkKey.oldKey]];
        }
        for (NSData *key in mArray) {
            NSData *obfuscatedPrivateBeaconDataC = [OpenSSLHelper.share calculateObfuscatedPrivateBeaconDataWithKeyRefreshFlag:networkKey.phase == distributingKeys ivUpdateActive:networkKey.ivIndex.updateActive ivIndex:networkKey.ivIndex.index randomData:_randomData usingNetworkKey:key];
            if ([obfuscatedPrivateBeaconDataC isEqualToData:_obfuscatedPrivateBeaconData]) {
                NSData *authenticationTagC = [OpenSSLHelper.share calculateAuthenticationTagWithKeyRefreshFlag:networkKey.phase == distributingKeys ivUpdateActive:networkKey.ivIndex.updateActive ivIndex:networkKey.ivIndex.index randomData:_randomData usingNetworkKey:key];
                if ([authenticationTagC isEqualToData:_authenticationTag]) {
                    authentication = YES;
                    _netKeyData = key;
                    _networkKey = networkKey;
                    NSData *privateBeaconData = [OpenSSLHelper.share calculatePrivateBeaconDataWithObfuscatedPrivateBeaconData:obfuscatedPrivateBeaconDataC randomData:_randomData usingNetworkKey:key];
                    Byte *privateBeaconByte = (Byte *)privateBeaconData.bytes;
                    memcpy(&tem, privateBeaconByte, 1);
                    _keyRefreshFlag = (tem & 0x01) != 0;
                    _ivUpdateActive = (tem & 0x02) != 0;
                    UInt32 tem32 = 0;
                    memcpy(&tem32, privateBeaconByte + 1, 4);
                    _ivIndex = CFSwapInt32HostToBig(tem32);
                    break;
                }
            }
        }
        if (authentication == NO) {
            TeLogError(@"Mesh Private beacon authentication fail.");
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithKeyRefreshFlag:(BOOL)keyRefreshFlag ivUpdateActive:(BOOL)ivUpdateActive ivIndex:(UInt32)ivIndex randomData:(NSData *)randomData usingNetworkKey:(SigNetkeyModel *)networkKey {
    if (self = [super init]) {
        [super setBeaconType:SigBeaconType_meshPrivateBeacon];
        _keyRefreshFlag = keyRefreshFlag;
        _ivUpdateActive = ivUpdateActive;
        _randomData = [NSData dataWithData:randomData];
        _ivIndex = ivIndex;
        _networkKey = networkKey;
        _netKeyData = [LibTools nsstringToHex:networkKey.key];
    }
    return self;
}

/// Creates Mesh Private beacon PDU object from received PDU.
///
/// - parameter pdu: The data received from mesh network.
/// - parameter networkKey: The Network Key to validate the beacon.
/// - returns: The beacon object, or `nil` if the data are invalid.
+ (SigMeshPrivateBeacon *)decodePdu:(NSData *)pdu forMeshNetwork:(SigDataSource *)meshNetwork {
    if (pdu == nil || pdu.length <= 1) {
        TeLogError(@"decodePdu length is less than 1.");
        return nil;
    }
    UInt8 tem = 0;
    Byte *pduByte = (Byte *)pdu.bytes;
    memcpy(&tem, pduByte, 1);
    SigBeaconType beaconType = tem;
    if (beaconType == SigBeaconType_meshPrivateBeacon) {
        NSArray *netKeys = [NSArray arrayWithArray:meshNetwork.netKeys];
        for (SigNetkeyModel *networkKey in netKeys) {
            SigMeshPrivateBeacon *beacon = [[SigMeshPrivateBeacon alloc] initWithDecodePdu:pdu usingNetworkKey:networkKey];
            if (beacon) {
                return beacon;
            }
        }
    } else {
        return nil;
    }
    return nil;
}

- (NSData *)pduData {
    NSMutableData *mData = [NSMutableData data];
    UInt8 bType = self.beaconType;
    [mData appendData:[NSData dataWithBytes:&bType length:1]];
    if (_randomData == nil || _randomData.length == 0) {
        return nil;
    }
    [mData appendData:_randomData];
    NSData *obfuscatedPrivateBeaconDataC = self.obfuscatedPrivateBeaconData;
    if (obfuscatedPrivateBeaconDataC == nil || obfuscatedPrivateBeaconDataC.length == 0) {
        return nil;
    }
    [mData appendData:obfuscatedPrivateBeaconDataC];
    NSData *authenticationTagC = self.authenticationTag;
    if (authenticationTagC == nil || authenticationTagC.length == 0) {
        return nil;
    }
    [mData appendData:authenticationTagC];
    return mData;
}

- (NSData *)obfuscatedPrivateBeaconData {
    _obfuscatedPrivateBeaconData = [OpenSSLHelper.share calculateObfuscatedPrivateBeaconDataWithKeyRefreshFlag:_keyRefreshFlag ivUpdateActive:_ivUpdateActive ivIndex:_ivIndex randomData:_randomData usingNetworkKey:self.netKeyData];
    return _obfuscatedPrivateBeaconData;
}

- (NSData *)authenticationTag {
    _authenticationTag = [OpenSSLHelper.share calculateAuthenticationTagWithKeyRefreshFlag:_keyRefreshFlag ivUpdateActive:_ivUpdateActive ivIndex:_ivIndex randomData:_randomData usingNetworkKey:self.netKeyData];
    return _authenticationTag;
}

- (NSString *)description {
    return[NSString stringWithFormat:@"<%p> - Mesh Private Beacon, random:(%@), netKeyData:(%@), ivIndex: (%x) Key refresh Flag: (%d), IV Update active: (%d)", self, [LibTools convertDataToHexStr:_randomData],[LibTools convertDataToHexStr:_netKeyData],(unsigned int)_ivIndex, _keyRefreshFlag,_ivUpdateActive];
}

@end


@implementation PublicKey

- (instancetype)initWithPublicKeyType:(PublicKeyType)type {
    if (self = [super init]) {
        UInt8 tem = type;
        _publicKeyType = type;
        _PublicKeyData = [NSData dataWithBytes:&tem length:1];
    }
    return self;
}

@end


//@implementation SigProvisioningResponse
//
//- (instancetype)initWithData:(NSData *)data {
//    if (self = [super init]) {
//        if (data == nil || data.length == 0) {
//            TeLogDebug(@"response data error.")
//            return nil;
//        }
//        
//        if (data.length >= 1) {
//            UInt8 type = 0;
//            memcpy(&type, data.bytes, 1);
//            if (type == 0 || type > 0x0D) {
//                TeLogDebug(@"response data pduType error.")
//                return nil;
//            }
//            self.type = type;
//        }
//        self.responseData = data;
//        switch (self.type) {
//            case SigProvisioningPduType_capabilities:
//            {
//                TeLogDebug(@"receive capabilities.");
//                SigProvisioningCapabilitiesPdu *pdu = [[SigProvisioningCapabilitiesPdu alloc] initWithParameters:data];
////                struct ProvisioningCapabilities tem = {};
////                [SigProvisioningPdu analysisProvisioningCapabilities:&tem withData:data];
//                self.capabilities = pdu;
//                NSData *d = nil;
//                self.publicKey = d;
//                self.confirmation = d;
//                self.random = d;
//                self.error = 0;
//            }
//                break;
//            case SigProvisioningPduType_publicKey:
//            {
//                TeLogDebug(@"receive publicKey.");
//                self.publicKey = [data subdataWithRange:NSMakeRange(1, data.length - 1)];
////                struct ProvisioningCapabilities tem = {};
////                memset(&tem, 0, 12);
//                self.capabilities = nil;
//                NSData *d = nil;
//                self.confirmation = d;
//                self.random = d;
//                self.error = 0;
//            }
//                break;
//            case SigProvisioningPduType_inputComplete:
//            case SigProvisioningPduType_complete:
//            {
//                TeLogDebug(@"receive inputComplete or complete.");
////                struct ProvisioningCapabilities tem = {};
////                memset(&tem, 0, 12);
//                self.capabilities = nil;
//                NSData *d = nil;
//                self.publicKey = d;
//                self.confirmation = d;
//                self.random = d;
//                self.error = 0;
//                
//            }
//                break;
//            case SigProvisioningPduType_confirmation:
//            {
//                TeLogDebug(@"receive confirmation.");
//                self.confirmation = [data subdataWithRange:NSMakeRange(1, data.length - 1)];
////                struct ProvisioningCapabilities tem = {};
////                memset(&tem, 0, 12);
//                self.capabilities = nil;
//                NSData *d = nil;
//                self.publicKey = d;
//                self.random = d;
//                self.error = 0;
//            }
//                break;
//            case SigProvisioningPduType_random:
//            {
//                TeLogDebug(@"receive random.");
//                self.random = [data subdataWithRange:NSMakeRange(1, data.length - 1)];
////                struct ProvisioningCapabilities tem = {};
////                memset(&tem, 0, 12);
//                self.capabilities = nil;
//                NSData *d = nil;
//                self.publicKey = d;
//                self.confirmation = d;
//                self.error = 0;
//            }
//                break;
//            case SigProvisioningPduType_failed:
//            {
//                TeLogDebug(@"receive failed.");
//                if (data.length != 2) {
//                    TeLogDebug(@"response data length error.")
//                    return nil;
//                }
//                UInt8 status = 0;
//                memcpy(&status, data.bytes+1, 1);
//                if (status == 0) {
//                    TeLogDebug(@"provision response fail data, but analysis status error.")
//                    return nil;
//                }
////                struct ProvisioningCapabilities tem = {};
////                memset(&tem, 0, 12);
//                self.capabilities = nil;
//                NSData *d = nil;
//                self.publicKey = d;
//                self.confirmation = d;
//                self.error = status;
//            }
//                break;
//            case SigProvisioningPduType_recordResponse:
//            {
//                SigProvisioningRecordResponseModel *responseModel = [[SigProvisioningRecordResponseModel alloc] initWithResponseData:[data subdataWithRange:NSMakeRange(1, data.length-1)]];
//                self.recordResponseModel = responseModel;
//            }
//                break;
//            case SigProvisioningPduType_recordsList:
//            {
//                SigProvisioningRecordsListModel *responseModel = [[SigProvisioningRecordsListModel alloc] initWithResponseData:[data subdataWithRange:NSMakeRange(1, data.length-1)]];
//                self.recordListModel = responseModel;
//            }
//                break;
//            default:
//                break;
//        }
//    }
//    return self;
//}
//
//- (BOOL)isValid {
//    switch (self.type) {
//        case SigProvisioningPduType_capabilities:
//        {
//            return self.capabilities != nil && self.capabilities.pduData.length == 12;
//        }
//            break;
//        case SigProvisioningPduType_publicKey:
//        {
//            return self.publicKey != nil;
//        }
//            break;
//        case SigProvisioningPduType_inputComplete:
//        case SigProvisioningPduType_complete:
//        {
//            return YES;
//        }
//            break;
//        case SigProvisioningPduType_confirmation:
//        {
//            return self.confirmation != nil && self.confirmation.length == 16;
//        }
//            break;
//        case SigProvisioningPduType_random:
//        {
//            return self.random != nil && self.random.length == 16;
//        }
//            break;
//        case SigProvisioningPduType_failed:
//        {
//            return self.error != 0;
//        }
//            break;
//        case SigProvisioningPduType_recordResponse:
//        {
//            return self.responseData.length >= 7;
//        }
//            break;
//        case SigProvisioningPduType_recordsList:
//        {
//            return self.responseData.length >= 4;
//        }
//            break;
//        default:
//            break;
//    }
//    return NO;
//}
//
//@end
