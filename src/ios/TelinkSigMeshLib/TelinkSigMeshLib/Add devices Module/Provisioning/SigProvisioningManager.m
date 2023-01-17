/********************************************************************************************************
 * @file     SigProvisioningManager.m
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

#import "SigProvisioningManager.h"
#import "SigBluetooth.h"
#import "SigProvisioningData.h"
#import "SigAuthenticationModel.h"
#import "OpenSSLHelper.h"
#import "SigECCEncryptHelper.h"

#define kFragmentMaximumSize    (20)

/// Table 5.53: Provisioning records
/// - seeAlso: MshPRFd1.1r11_clean-472-529.pdf  (page.42)
typedef enum : UInt16 {
    SigProvisioningRecordID_CertificateBasedProvisioningURI = 0x0000,
    SigProvisioningRecordID_DeviceCertificate               = 0x0001,
    SigProvisioningRecordID_IntermediateCertificate1        = 0x0002,
    SigProvisioningRecordID_IntermediateCertificate2        = 0x0003,
    SigProvisioningRecordID_IntermediateCertificate3        = 0x0004,
    SigProvisioningRecordID_IntermediateCertificate4        = 0x0005,
    SigProvisioningRecordID_IntermediateCertificate5        = 0x0006,
    SigProvisioningRecordID_IntermediateCertificate6        = 0x0007,
    SigProvisioningRecordID_IntermediateCertificate7        = 0x0008,
    SigProvisioningRecordID_IntermediateCertificate8        = 0x0009,
    SigProvisioningRecordID_IntermediateCertificate9        = 0x000A,
    SigProvisioningRecordID_IntermediateCertificate10       = 0x000B,
    SigProvisioningRecordID_IntermediateCertificate11       = 0x000C,
    SigProvisioningRecordID_IntermediateCertificate12       = 0x000D,
    SigProvisioningRecordID_IntermediateCertificate13       = 0x000E,
    SigProvisioningRecordID_IntermediateCertificate14       = 0x000F,
    SigProvisioningRecordID_IntermediateCertificate15       = 0x0010,
    SigProvisioningRecordID_CompleteLocalName               = 0x0011,
    SigProvisioningRecordID_Appearance                      = 0x0012,
} SigProvisioningRecordID;

@interface SigProvisioningManager ()
@property (nonatomic, assign) UInt16 unicastAddress;
@property (nonatomic, strong) NSData *staticOobData;
@property (nonatomic, strong) SigScanRspModel *unprovisionedDevice;
@property (nonatomic,copy) addDevice_prvisionSuccessCallBack provisionSuccessBlock;
@property (nonatomic,copy) ErrorBlock failBlock;
@property (nonatomic, assign) BOOL isProvisionning;
@property (nonatomic, assign) UInt16 totalLength;
//@property (nonatomic, strong) NSMutableData *deviceCertificateData;
@property (nonatomic, strong) SigProvisioningRecordsListPdu *recordsListPdu;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *,NSData *>*certificateDict;
@property (nonatomic, assign) UInt16 currentRecordID;

@property (nonatomic,strong) NSData *devicePublicKey;//certificate-base获取到的devicePublicKey

@end

@implementation SigProvisioningManager

- (instancetype)init{
    if (self = [super init]) {
        _state = ProvisioningState_ready;
        _isProvisionning = NO;
        _attentionDuration = 0;
    }
    return self;
}

/// This method get the Capabilities of the device.
/// @param attentionDuration 0x00, Off; 0x01–0xFF, On, remaining time in seconds.
- (void)identifyWithAttentionDuration:(UInt8)attentionDuration {
    
    // Has the provisioning been restarted?
    if (self.state == ProvisioningState_fail) {
        [self reset];
    }
    
    // Is the Provisioner Manager in the right state?
    if (self.state != ProvisioningState_ready) {
        TeLogError(@"current node isn't in ready.");
        return;
    }

    // Initialize provisioning data.
    self.provisioningData = [[SigProvisioningData alloc] init];

    self.state = ProvisioningState_requestingCapabilities;
    
    SigProvisioningInvitePdu *pdu = [[SigProvisioningInvitePdu alloc] initWithAttentionDuration:attentionDuration];
    self.provisioningData.provisioningInvitePDUValue = [pdu.pduData subdataWithRange:NSMakeRange(1, pdu.pduData.length-1)];
    [self sendPdu:pdu];
}

- (void)setState:(ProvisioningState)state{
    _state = state;
    if (state == ProvisioningState_fail) {
        [self reset];
        __weak typeof(self) weakSelf = self;
        [SDKLibCommand stopMeshConnectWithComplete:^(BOOL successful) {
            if (weakSelf.failBlock) {
                NSError *err = [NSError errorWithDomain:@"provision fail." code:-1 userInfo:nil];
                weakSelf.failBlock(err);
            }
        }];
    }
}

- (BOOL)isDeviceSupported{
    if (self.provisioningCapabilities.provisionType != SigProvisioningPduType_capabilities || self.provisioningCapabilities.numberOfElements == 0) {
        TeLogError(@"Capabilities is error.");
        return NO;
    }
    return self.provisioningCapabilities.algorithms.fipsP256EllipticCurve == 1 || self.provisioningCapabilities.algorithms.fipsP256EllipticCurve_HMAC_SHA256 == 1;
}

- (void)provisionSuccess{
    UInt16 address = self.provisioningData.unicastAddress;
    UInt8 ele_count = self.provisioningCapabilities.numberOfElements;
    [SigMeshLib.share.dataSource saveLocationProvisionAddress:address+ele_count-1];
    NSData *devKeyData = self.provisioningData.deviceKey;
    TeLogInfo(@"deviceKey=%@",devKeyData);
    
    self.unprovisionedDevice.address = address;
    [SigMeshLib.share.dataSource updateScanRspModelToDataSource:self.unprovisionedDevice];
    
    SigNodeModel *model = [[SigNodeModel alloc] init];
    [model setAddress:address];
    model.deviceKey = [LibTools convertDataToHexStr:devKeyData];
    model.peripheralUUID = nil;
    model.UUID = self.unprovisionedDevice.advUuid;
    //Attention: There isn't scanModel at remote add, so develop need add macAddress in provisionSuccessCallback.
    model.macAddress = self.unprovisionedDevice.macAddress;
    SigNodeKeyModel *nodeNetkey = [[SigNodeKeyModel alloc] init];
    nodeNetkey.index = self.networkKey.index;
    if (![model.netKeys containsObject:nodeNetkey]) {
        [model.netKeys addObject:nodeNetkey];
    }

    SigPage0 *compositionData = [[SigPage0 alloc] init];
    compositionData.companyIdentifier = self.unprovisionedDevice.CID;
    compositionData.productIdentifier = self.unprovisionedDevice.PID;
    NSMutableArray *elements = [NSMutableArray array];
    if (ele_count) {
        for (int i=0; i<ele_count; i++) {
            SigElementModel *ele = [[SigElementModel alloc] init];
            [elements addObject:ele];
        }
    }
    compositionData.elements = elements;
    model.compositionData = compositionData;
    
    [SigMeshLib.share.dataSource addAndSaveNodeToMeshNetworkWithDeviceModel:model];
}

/// This method should be called when the OOB value has been received and Auth Value has been calculated. It computes and sends the Provisioner Confirmation to the device.
/// @param data The 16/32 byte long Auth Value.
- (void)authValueReceivedData:(NSData *)data {
    SigAuthenticationModel *auth = nil;
    self.authenticationModel = auth;
    [self.provisioningData provisionerDidObtainAuthValue:data];
    NSData *provisionerConfirmationData = [self.provisioningData provisionerConfirmation];
    SigProvisioningConfirmationPdu *pdu = [[SigProvisioningConfirmationPdu alloc] initWithConfirmation:provisionerConfirmationData];
//    TeLogInfo(@"app端的Confirmation=%@",[LibTools convertDataToHexStr:provisionerConfirmationData]);

    [self sendPdu:pdu];
}

- (void)sendPdu:(SigProvisioningPdu *)pdu {
    dispatch_async(SigMeshLib.share.queue, ^{
        [SigBearer.share sendBlePdu:pdu ofType:SigPduType_provisioningPdu];
    });
}

/// Resets the provisioning properties and state.
- (void)reset {
    self.authenticationMethod = 0;
    memset(&_provisioningCapabilities, 0, sizeof(_provisioningCapabilities));
    SigProvisioningData *tem = nil;
    self.provisioningData = tem;
    self.state = ProvisioningState_ready;
    [SigBearer.share setBearerProvisioned:YES];
}

+ (SigProvisioningManager *)share {
    static SigProvisioningManager *shareManager = nil;
    static dispatch_once_t tempOnce=0;
    dispatch_once(&tempOnce, ^{
        shareManager = [[SigProvisioningManager alloc] init];
    });
    return shareManager;
}

- (void)provisionWithUnicastAddress:(UInt16)unicastAddress networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess fail:(ErrorBlock)fail {
    //since v3.3.3 每次provision前都初始化一次ECC算法的公私钥。
    [SigECCEncryptHelper.share eccInit];
    
    self.staticOobData = nil;
    self.unicastAddress = unicastAddress;
    self.provisionSuccessBlock = provisionSuccess;
    self.failBlock = fail;
    self.unprovisionedDevice = [SigMeshLib.share.dataSource getScanRspModelWithUUID:[SigBearer.share getCurrentPeripheral].identifier.UUIDString];
    SigNetkeyModel *provisionNet = nil;
    NSArray *netKeys = [NSArray arrayWithArray:SigMeshLib.share.dataSource.netKeys];
    for (SigNetkeyModel *net in netKeys) {
        if (([networkKey isEqualToData:[LibTools nsstringToHex:net.key]] || (net.phase == distributingKeys && [networkKey isEqualToData:[LibTools nsstringToHex:net.oldKey]])) && netkeyIndex == net.index) {
            provisionNet = net;
            break;
        }
    }
    if (provisionNet == nil) {
        TeLogError(@"error network key.");
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self reset];
    [SigBearer.share setBearerProvisioned:NO];
    self.networkKey = provisionNet;
    self.isProvisionning = YES;
    TeLogInfo(@"start provision.");
    [SigBluetooth.share setBluetoothDisconnectCallback:^(CBPeripheral * _Nonnull peripheral, NSError * _Nonnull error) {
        [SigMeshLib.share cleanAllCommandsAndRetry];
        if ([peripheral.identifier.UUIDString isEqualToString:SigBearer.share.getCurrentPeripheral.identifier.UUIDString]) {
            if (weakSelf.isProvisionning) {
                TeLogInfo(@"disconnect in provisioning，provision fail.");
                if (fail) {
                    weakSelf.isProvisionning = NO;
                    NSError *err = [NSError errorWithDomain:@"disconnect in provisioning，provision fail." code:-1 userInfo:nil];
                    fail(err);
                }
            }
        }
    }];
    [self getCapabilitiesWithTimeout:kGetCapabilitiesTimeout callback:^(SigProvisioningPdu * _Nullable response) {
        [weakSelf getCapabilitiesResultWithResponse:response];
    }];
}

- (void)provisionWithUnicastAddress:(UInt16)unicastAddress networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex staticOobData:(NSData *)oobData provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess fail:(ErrorBlock)fail {
    //since v3.3.3 每次provision前都初始化一次ECC算法的公私钥。
    [SigECCEncryptHelper.share eccInit];

    self.staticOobData = oobData;
    self.unicastAddress = unicastAddress;
    self.provisionSuccessBlock = provisionSuccess;
    self.failBlock = fail;
    self.unprovisionedDevice = [SigMeshLib.share.dataSource getScanRspModelWithUUID:[SigBearer.share getCurrentPeripheral].identifier.UUIDString];
    SigNetkeyModel *provisionNet = nil;
    NSArray *netKeys = [NSArray arrayWithArray:SigMeshLib.share.dataSource.netKeys];
    for (SigNetkeyModel *net in netKeys) {
        if (([networkKey isEqualToData:[LibTools nsstringToHex:net.key]] || (net.phase == distributingKeys && [networkKey isEqualToData:[LibTools nsstringToHex:net.oldKey]])) && netkeyIndex == net.index) {
            provisionNet = net;
            break;
        }
    }
    if (provisionNet == nil) {
        TeLogError(@"error network key.");
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self reset];
    [SigBearer.share setBearerProvisioned:NO];
    self.networkKey = provisionNet;
    self.isProvisionning = YES;
    TeLogInfo(@"start provision.");
    [SigBluetooth.share setBluetoothDisconnectCallback:^(CBPeripheral * _Nonnull peripheral, NSError * _Nonnull error) {
        [SigMeshLib.share cleanAllCommandsAndRetry];
        if ([peripheral.identifier.UUIDString isEqualToString:SigBearer.share.getCurrentPeripheral.identifier.UUIDString]) {
            if (weakSelf.isProvisionning) {
                TeLogInfo(@"disconnect in provisioning，provision fail.");
                if (fail) {
                    weakSelf.isProvisionning = NO;
                    NSError *err = [NSError errorWithDomain:@"disconnect in provisioning，provision fail." code:-1 userInfo:nil];
                    fail(err);
                }
            }
        }
    }];
    [self getCapabilitiesWithTimeout:kGetCapabilitiesTimeout callback:^(SigProvisioningPdu * _Nullable response) {
        [weakSelf getCapabilitiesResultWithResponse:response];
    }];

}

/// founcation3: provision (If CBPeripheral isn't CBPeripheralStateConnected, SDK will connect CBPeripheral in this api. )
/// @param peripheral CBPeripheral of CoreBluetooth will be provision.
/// @param unicastAddress address of new device.
/// @param networkKey networkKey
/// @param netkeyIndex netkeyIndex
/// @param provisionType ProvisionType_NoOOB means oob data is 16 bytes zero data, ProvisionType_StaticOOB means oob data is get from HTTP API.
/// @param staticOOBData oob data get from HTTP API when provisionType is ProvisionType_StaticOOB.
/// @param provisionSuccess callback when provision success.
/// @param fail callback when provision fail.
- (void)provisionWithPeripheral:(CBPeripheral *)peripheral unicastAddress:(UInt16)unicastAddress networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex provisionType:(ProvisionType)provisionType staticOOBData:(NSData * _Nullable)staticOOBData provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess fail:(ErrorBlock)fail {
    //since v3.3.3 每次provision前都初始化一次ECC算法的公私钥。
    [SigECCEncryptHelper.share eccInit];

    if (provisionType == ProvisionType_NoOOB || provisionType == ProvisionType_StaticOOB) {
        if (peripheral.state == CBPeripheralStateConnected) {
            if (provisionType == ProvisionType_NoOOB) {
                TeLogVerbose(@"start noOob provision.");
                [self provisionWithUnicastAddress:unicastAddress networkKey:networkKey netkeyIndex:netkeyIndex provisionSuccess:provisionSuccess fail:fail];
            } else if (provisionType == ProvisionType_StaticOOB) {
                TeLogVerbose(@"start staticOob provision.");
                [self provisionWithUnicastAddress:unicastAddress networkKey:networkKey netkeyIndex:netkeyIndex staticOobData:staticOOBData provisionSuccess:provisionSuccess fail:fail];
            }
        } else {
            __weak typeof(self) weakSelf = self;
            TeLogVerbose(@"start connect for provision.");
            [SigBearer.share connectAndReadServicesWithPeripheral:peripheral result:^(BOOL successful) {
                if (successful) {
                    TeLogVerbose(@"connect successful.");
                    [weakSelf provisionWithPeripheral:peripheral unicastAddress:unicastAddress networkKey:networkKey netkeyIndex:netkeyIndex provisionType:provisionType staticOOBData:staticOOBData provisionSuccess:provisionSuccess fail:fail];
                } else {
                    if (fail) {
                        NSError *err = [NSError errorWithDomain:@"Provision fail, because connect fail before provision." code:-1 userInfo:nil];
                        fail(err);
                    }
                }
            }];
        }
    } else {
        TeLogError(@"unsupport provision type.");
    }
}

/// founcation4: provision (If CBPeripheral's state isn't CBPeripheralStateConnected, SDK will connect CBPeripheral in this api. )
/// @param peripheral CBPeripheral of CoreBluetooth will be provision.
/// @param unicastAddress address of new device.
/// @param networkKey networkKey
/// @param netkeyIndex netkeyIndex
/// @param provisionType ProvisionType_NoOOB means oob data is 16 bytes zero data, ProvisionType_StaticOOB means oob data is get from HTTP API.
/// @param staticOOBData oob data get from HTTP API when provisionType is ProvisionType_StaticOOB.
/// @param provisionSuccess callback when provision success.
/// @param fail callback when provision fail.
- (void)certificateBasedProvisionWithPeripheral:(CBPeripheral *)peripheral unicastAddress:(UInt16)unicastAddress networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex provisionType:(ProvisionType)provisionType staticOOBData:(nullable NSData *)staticOOBData provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess fail:(ErrorBlock)fail {
    //since v3.3.3 每次provision前都初始化一次ECC算法的公私钥。
    [SigECCEncryptHelper.share eccInit];

    self.staticOobData = nil;
    self.unicastAddress = unicastAddress;
    self.provisionSuccessBlock = provisionSuccess;
    self.failBlock = fail;
    self.unprovisionedDevice = [SigMeshLib.share.dataSource getScanRspModelWithUUID:[SigBearer.share getCurrentPeripheral].identifier.UUIDString];
    SigNetkeyModel *provisionNet = nil;
    NSArray *netKeys = [NSArray arrayWithArray:SigMeshLib.share.dataSource.netKeys];
    for (SigNetkeyModel *net in netKeys) {
        if (([networkKey isEqualToData:[LibTools nsstringToHex:net.key]] || (net.phase == distributingKeys && [networkKey isEqualToData:[LibTools nsstringToHex:net.oldKey]])) && netkeyIndex == net.index) {
            provisionNet = net;
            break;
        }
    }
    if (provisionNet == nil) {
        TeLogError(@"error network key.");
        return;
    }
    self.certificateDict = [NSMutableDictionary dictionary];
    self.currentRecordID = 0;
    
    __weak typeof(self) weakSelf = self;
    [self reset];
    [SigBearer.share setBearerProvisioned:NO];
    self.networkKey = provisionNet;
    self.isProvisionning = YES;
    TeLogInfo(@"start certificateBasedProvision.");
    
    if (provisionType == ProvisionType_NoOOB || provisionType == ProvisionType_StaticOOB) {
        if (peripheral.state == CBPeripheralStateConnected) {
            TeLogVerbose(@"start RecordsGet.");
            [self sentProvisioningRecordsGetWithTimeout:kProvisioningRecordsGetTimeout callback:^(SigProvisioningPdu * _Nullable response) {
                [weakSelf sentProvisioningRecordsGetWithResponse:response];
            }];
        } else {
            TeLogVerbose(@"start connect for provision.");
            [SigBearer.share connectAndReadServicesWithPeripheral:peripheral result:^(BOOL successful) {
                if (successful) {
                    TeLogVerbose(@"connect successful.");
                    [weakSelf provisionWithPeripheral:peripheral unicastAddress:unicastAddress networkKey:networkKey netkeyIndex:netkeyIndex provisionType:provisionType staticOOBData:staticOOBData provisionSuccess:provisionSuccess fail:fail];
                } else {
                    if (fail) {
                        NSError *err = [NSError errorWithDomain:@"Provision fail, because connect fail before provision." code:-1 userInfo:nil];
                        fail(err);
                    }
                }
            }];
        }
    } else {
        TeLogError(@"unsupport provision type.");
    }
}

#pragma mark step1:getCapabilities
- (void)getCapabilitiesWithTimeout:(NSTimeInterval)timeout callback:(prvisionResponseCallBack)block {
    TeLogInfo(@"\n\n==========provision:step1\n\n");
    self.provisionResponseBlock = block;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getCapabilitiesTimeout) object:nil];
        [self performSelector:@selector(getCapabilitiesTimeout) withObject:nil afterDelay:timeout];
    });
    [self identifyWithAttentionDuration:self.attentionDuration];
}

#pragma mark step2:start
- (void)sentStartNoOobProvisionPduAndPublicKeyPduWithTimeout:(NSTimeInterval)timeout callback:(prvisionResponseCallBack)block {
    TeLogInfo(@"\n\n==========provision:step2(noOob)\n\n");
    // Is the Provisioner Manager in the right state?
    if (self.state != ProvisioningState_capabilitiesReceived) {
        TeLogError(@"current state is wrong.");
        return;
    }
    
    // Ensure the Network Key is set.
    if (self.networkKey == nil) {
        TeLogError(@"current networkKey isn't specified.");
        return;
    }
    
    // Is the Bearer open?
    if (!SigBearer.share.isOpen) {
        TeLogError(@"current node's bearer isn't open.");
        return;
    }
        
    self.provisionResponseBlock = block;

    self.provisioningData.algorithm = [self getCurrentProvisionAlgorithm];
    [self.provisioningData generateProvisionerRandomAndProvisionerPublicKey];
    
    // Send Provisioning Start request.
    self.state = ProvisioningState_provisioning;
    [self.provisioningData prepareWithNetwork:SigMeshLib.share.dataSource networkKey:self.networkKey unicastAddress:self.unicastAddress];
    PublicKey *publicKey = [[PublicKey alloc] initWithPublicKeyType:self.provisioningCapabilities.publicKeyType];
    AuthenticationMethod authenticationMethod = AuthenticationMethod_noOob;

    SigProvisioningStartPdu *startPdu = [[SigProvisioningStartPdu alloc] initWithAlgorithm:[self getCurrentProvisionAlgorithm] publicKeyType:publicKey.publicKeyType authenticationMethod:authenticationMethod authenticationAction:0 authenticationSize:0];
    self.provisioningData.provisioningStartPDUValue = [startPdu.pduData subdataWithRange:NSMakeRange(1, startPdu.pduData.length-1)];
    [self sendPdu:startPdu];
    self.authenticationMethod = authenticationMethod;
    // Send the Public Key of the Provisioner.
    SigProvisioningPublicKeyPdu *publicPdu = [[SigProvisioningPublicKeyPdu alloc] initWithPublicKey:self.provisioningData.provisionerPublicKey];
    [self sendPdu:publicPdu];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getCapabilitiesTimeout) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentStartProvisionPduAndPublicKeyPduTimeout) object:nil];
        [self performSelector:@selector(sentStartProvisionPduAndPublicKeyPduTimeout) withObject:nil afterDelay:timeout];
        if (self.provisioningCapabilities.publicKeyType == PublicKeyType_oobPublicKey) {
            //if use oob public key, needn`t waith devicePublicKey response, use devicePublicKey from certificate.
            SigProvisioningPublicKeyPdu *devicePublicKeyPdu = [[SigProvisioningPublicKeyPdu alloc] initWithPublicKey:self.devicePublicKey];
            [self sentStartProvisionPduAndPublicKeyPduWithResponse:devicePublicKeyPdu];
        }
    });
}

- (void)sentStartStaticOobProvisionPduAndPublicKeyPduWithStaticOobData:(NSData *)oobData timeout:(NSTimeInterval)timeout callback:(prvisionResponseCallBack)block {
    TeLogInfo(@"\n\n==========provision:step2(staticOob)\n\n");
    // Is the Provisioner Manager in the right state?
    if (self.state != ProvisioningState_capabilitiesReceived) {
        TeLogError(@"current state is wrong.");
        return;
    }
    
    // Ensure the Network Key is set.
    if (self.networkKey == nil) {
        TeLogError(@"current networkKey isn't specified.");
        return;
    }
    
    // Is the Bearer open?
    if (!SigBearer.share.isOpen) {
        TeLogError(@"current node's bearer isn't open.");
        return;
    }
    
    self.provisionResponseBlock = block;

    self.provisioningData.algorithm = [self getCurrentProvisionAlgorithm];
    [self.provisioningData generateProvisionerRandomAndProvisionerPublicKey];
    [self.provisioningData provisionerDidObtainAuthValue:oobData];
    
    // Send Provisioning Start request.
    self.state = ProvisioningState_provisioning;
    [self.provisioningData prepareWithNetwork:SigMeshLib.share.dataSource networkKey:self.networkKey unicastAddress:self.unicastAddress];
    PublicKey *publicKey = [[PublicKey alloc] initWithPublicKeyType:self.provisioningCapabilities.publicKeyType];
    AuthenticationMethod authenticationMethod = AuthenticationMethod_staticOob;

    SigProvisioningStartPdu *startPdu = [[SigProvisioningStartPdu alloc] initWithAlgorithm:[self getCurrentProvisionAlgorithm] publicKeyType:publicKey.publicKeyType authenticationMethod:authenticationMethod authenticationAction:0 authenticationSize:0];
    self.provisioningData.provisioningStartPDUValue = [startPdu.pduData subdataWithRange:NSMakeRange(1, startPdu.pduData.length-1)];
    [self sendPdu:startPdu];
    self.authenticationMethod = authenticationMethod;
    // Send the Public Key of the Provisioner.
    SigProvisioningPublicKeyPdu *publicPdu = [[SigProvisioningPublicKeyPdu alloc] initWithPublicKey:self.provisioningData.provisionerPublicKey];
    [self sendPdu:publicPdu];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getCapabilitiesTimeout) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentStartProvisionPduAndPublicKeyPduTimeout) object:nil];
        [self performSelector:@selector(sentStartProvisionPduAndPublicKeyPduTimeout) withObject:nil afterDelay:timeout];
        if (self.provisioningCapabilities.publicKeyType == PublicKeyType_oobPublicKey) {
            //if use oob public key, needn`t waith devicePublicKey response, use devicePublicKey from certificate.
            SigProvisioningPublicKeyPdu *devicePublicKeyPdu = [[SigProvisioningPublicKeyPdu alloc] initWithPublicKey:self.devicePublicKey];
            [self sentStartProvisionPduAndPublicKeyPduWithResponse:devicePublicKeyPdu];
        }
    });
}

#pragma mark step3:Confirmation
- (void)sentProvisionConfirmationPduWithTimeout:(NSTimeInterval)timeout callback:(prvisionResponseCallBack)block {
    TeLogInfo(@"\n\n==========provision:step3\n\n");
    self.provisionResponseBlock = block;
    NSData *authValue = nil;
    if (self.staticOobData) {
        //当前设置为static oob provision
        authValue = self.staticOobData;
    } else {
        //当前设置为no oob provision
        UInt8 value[32] = {};
        memset(&value, 0, 32);
        if ([self getCurrentProvisionAlgorithm] == Algorithm_fipsP256EllipticCurve) {
            authValue = [NSData dataWithBytes:&value length:16];
        } else if ([self getCurrentProvisionAlgorithm] == Algorithm_fipsP256EllipticCurve_HMAC_SHA256) {
            authValue = [NSData dataWithBytes:&value length:32];
        }
    }
    [self authValueReceivedData:authValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentStartProvisionPduAndPublicKeyPduTimeout) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisionConfirmationPduTimeout) object:nil];
        [self performSelector:@selector(sentProvisionConfirmationPduTimeout) withObject:nil afterDelay:timeout];
    });
}

#pragma mark step4:Random
- (void)sentProvisionRandomPduWithTimeout:(NSTimeInterval)timeout callback:(prvisionResponseCallBack)block {
    TeLogInfo(@"\n\n==========provision:step4\n\n");
    self.provisionResponseBlock = block;
    SigProvisioningRandomPdu *pdu = [[SigProvisioningRandomPdu alloc] initWithRandom:self.provisioningData.provisionerRandom];
    [self sendPdu:pdu];

    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisionConfirmationPduTimeout) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisionRandomPduTimeout) object:nil];
        [self performSelector:@selector(sentProvisionRandomPduTimeout) withObject:nil afterDelay:timeout];
    });
}

#pragma mark step5:EncryptedData
- (void)sentProvisionEncryptedDataWithMicPduWithTimeout:(NSTimeInterval)timeout callback:(prvisionResponseCallBack)block {
    TeLogInfo(@"\n\n==========provision:step5\n\n");
    self.provisionResponseBlock = block;
    NSData *provisioningData = self.provisioningData.getProvisioningData;
    NSData *encryptedProvisioningDataAndMic = [self.provisioningData getEncryptedProvisioningDataAndMicWithProvisioningData:provisioningData];
    SigProvisioningDataPdu *pdu = [[SigProvisioningDataPdu alloc] initWithEncryptedProvisioningData:[encryptedProvisioningDataAndMic subdataWithRange:NSMakeRange(0, 25)] provisioningDataMIC:[encryptedProvisioningDataAndMic subdataWithRange:NSMakeRange(25, 8)]];
    [self sendPdu:pdu];

    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisionRandomPduTimeout) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisionEncryptedDataWithMicPduTimeout) object:nil];
        [self performSelector:@selector(sentProvisionEncryptedDataWithMicPduTimeout) withObject:nil afterDelay:timeout];
    });
}

- (void)getCapabilitiesResultWithResponse:(SigProvisioningPdu *)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getCapabilitiesTimeout) object:nil];
    });
    if (response.provisionType == SigProvisioningPduType_capabilities) {
        SigProvisioningCapabilitiesPdu *capabilitiesPdu = (SigProvisioningCapabilitiesPdu *)response;
        TeLogInfo(@"%@",capabilitiesPdu.getCapabilitiesString);
        self.provisioningCapabilities = capabilitiesPdu;
        self.provisioningData.provisioningCapabilitiesPDUValue = [capabilitiesPdu.pduData subdataWithRange:NSMakeRange(1, capabilitiesPdu.pduData.length-1)];
        self.state = ProvisioningState_capabilitiesReceived;
        if (self.unicastAddress == 0) {
            self.state = ProvisioningState_fail;
        }else{
            __weak typeof(self) weakSelf = self;
            if (self.provisioningCapabilities.staticOobType.staticOobInformationAvailable == 1) {
                //设备端支持staticOOB
                if (self.staticOobData) {
                    TeLogVerbose(@"static OOB device, do static OOB provision, staticOobData=%@",self.staticOobData);
                    [self sentStartStaticOobProvisionPduAndPublicKeyPduWithStaticOobData:self.staticOobData timeout:kStartProvisionAndPublicKeyTimeout callback:^(SigProvisioningPdu * _Nullable response) {
                        [weakSelf sentStartProvisionPduAndPublicKeyPduWithResponse:response];
                    }];
                } else {
                    if (SigMeshLib.share.dataSource.addStaticOOBDevcieByNoOOBEnable) {
                        //SDK当前设置了兼容模式（即staticOOB设备可以通过noOOB provision的方式进行添加）
                        TeLogVerbose(@"static OOB device,do no OOB provision");
                        [self sentStartNoOobProvisionPduAndPublicKeyPduWithTimeout:kStartProvisionAndPublicKeyTimeout callback:^(SigProvisioningPdu * _Nullable response) {
                            [weakSelf sentStartProvisionPduAndPublicKeyPduWithResponse:response];
                        }];
                    } else {
                        //SDK当前未设置兼容模式（即staticOOB设备必须通过staticOOB provision的方式进行添加）
                        //设备不支持则直接provision fail
                        TeLogError(@"SDK not find static OOB data, not support static OOB.");
                        self.state = ProvisioningState_fail;
                    }
                }
            } else {
                //设备端不支持staticOOB
                TeLogVerbose(@"no OOB device,do no OOB provision");
                [self sentStartNoOobProvisionPduAndPublicKeyPduWithTimeout:kStartProvisionAndPublicKeyTimeout callback:^(SigProvisioningPdu * _Nullable response) {
                    [weakSelf sentStartProvisionPduAndPublicKeyPduWithResponse:response];
                }];
            }
        }
    }else if (!response || response.provisionType == SigProvisioningPduType_failed) {
        self.state = ProvisioningState_fail;
        SigProvisioningFailedPdu *failedPdu = (SigProvisioningFailedPdu *)response;
        TeLogDebug(@"getCapabilities error = %lu",(unsigned long)failedPdu.errorCode);
    }else{
        TeLogDebug(@"getCapabilities:no handel this response data");
    }
}

- (void)getCapabilitiesTimeout {
    TeLogInfo(@"getCapabilitiesTimeout");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getCapabilitiesTimeout) object:nil];
    });
    if (self.provisionResponseBlock) {
        self.provisionResponseBlock(nil);
    }
}

- (void)sentStartProvisionPduAndPublicKeyPduWithResponse:(SigProvisioningPdu *)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentStartProvisionPduAndPublicKeyPduTimeout) object:nil];
    });
    if (response.provisionType == SigProvisioningPduType_publicKey) {
        SigProvisioningPublicKeyPdu *publicKeyPdu = (SigProvisioningPublicKeyPdu *)response;
        TeLogInfo(@"device public key back:%@",[LibTools convertDataToHexStr:publicKeyPdu.publicKey]);
        self.provisioningData.devicePublicKey = publicKeyPdu.publicKey;
        [self.provisioningData provisionerDidObtainWithDevicePublicKey:publicKeyPdu.publicKey];
        if (self.provisioningData.sharedSecret && self.provisioningData.sharedSecret.length > 0) {
            TeLogInfo(@"APP端SharedSecret=%@",[LibTools convertDataToHexStr:self.provisioningData.sharedSecret]);
            __weak typeof(self) weakSelf = self;
            [self sentProvisionConfirmationPduWithTimeout:kProvisionConfirmationTimeout callback:^(SigProvisioningPdu * _Nullable response) {
                [weakSelf sentProvisionConfirmationPduWithResponse:response];
            }];
        } else {
            TeLogDebug(@"calculate SharedSecret fail.");
            self.state = ProvisioningState_fail;
        }
    }else if (!response || response.provisionType == SigProvisioningPduType_failed) {
        self.state = ProvisioningState_fail;
        SigProvisioningFailedPdu *failedPdu = (SigProvisioningFailedPdu *)response;
        TeLogDebug(@"sentStartProvisionPduAndPublicKeyPdu error = %lu",(unsigned long)failedPdu.errorCode);
    }else{
        TeLogDebug(@"sentStartProvisionPduAndPublicKeyPdu:no handel this response data");
    }
}

- (void)sentStartProvisionPduAndPublicKeyPduTimeout {
    TeLogInfo(@"sentStartProvisionPduAndPublicKeyPduTimeout");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentStartProvisionPduAndPublicKeyPduTimeout) object:nil];
    });
    if (self.provisionResponseBlock) {
        self.provisionResponseBlock(nil);
    }
}

- (void)sentProvisionConfirmationPduWithResponse:(SigProvisioningPdu *)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisionConfirmationPduTimeout) object:nil];
    });
    if (response.provisionType == SigProvisioningPduType_confirmation) {
        SigProvisioningConfirmationPdu *confirmationPdu = (SigProvisioningConfirmationPdu *)response;
        TeLogInfo(@"device confirmation back:%@",[LibTools convertDataToHexStr:confirmationPdu.confirmation]);
        [self.provisioningData provisionerDidObtainWithDeviceConfirmation:confirmationPdu.confirmation];
        if ([[self.provisioningData provisionerConfirmation] isEqualToData:confirmationPdu.confirmation]) {
            TeLogDebug(@"Confirmation of device is equal to confirmation of provisioner!");
            self.state = ProvisioningState_fail;
            return;
        }
        __weak typeof(self) weakSelf = self;
        [self sentProvisionRandomPduWithTimeout:kProvisionRandomTimeout callback:^(SigProvisioningPdu * _Nullable response) {
            [weakSelf sentProvisionRandomPduWithResponse:response];
        }];
    }else if (!response || response.provisionType == SigProvisioningPduType_failed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisionConfirmationPduTimeout) object:nil];
        });
        self.state = ProvisioningState_fail;
        SigProvisioningFailedPdu *failedPdu = (SigProvisioningFailedPdu *)response;
        TeLogDebug(@"sentProvisionConfirmationPdu error = %lu",(unsigned long)failedPdu.errorCode);
    }else{
        TeLogDebug(@"sentProvisionConfirmationPdu:no handel this response data");
    }
}

- (void)sentProvisionConfirmationPduTimeout {
    TeLogInfo(@"sentProvisionConfirmationPduTimeout");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisionConfirmationPduTimeout) object:nil];
    });
    if (self.provisionResponseBlock) {
        self.provisionResponseBlock(nil);
    }
}

- (void)sentProvisionRandomPduWithResponse:(SigProvisioningPdu *)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisionRandomPduTimeout) object:nil];
    });
    if (response.provisionType == SigProvisioningPduType_random) {
        SigProvisioningRandomPdu *randomPdu = (SigProvisioningRandomPdu *)response;
        TeLogInfo(@"device random back:%@",randomPdu.random);
        [self.provisioningData provisionerDidObtainWithDeviceRandom:randomPdu.random];
        if ([self.provisioningData.provisionerRandom isEqualToData:randomPdu.random]) {
            TeLogDebug(@"Random of device is equal to random of provisioner!");
            self.state = ProvisioningState_fail;
            return;
        }
        if (![self.provisioningData validateConfirmation]) {
            TeLogDebug(@"validate Confirmation fail");
            self.state = ProvisioningState_fail;
            return;
        }
        __weak typeof(self) weakSelf = self;
        [self sentProvisionEncryptedDataWithMicPduWithTimeout:kSentProvisionEncryptedDataWithMicTimeout callback:^(SigProvisioningPdu * _Nullable response) {
            [weakSelf sentProvisionEncryptedDataWithMicPduWithResponse:response];
        }];
    }else if (!response || response.provisionType == SigProvisioningPduType_failed) {
        self.state = ProvisioningState_fail;
        SigProvisioningFailedPdu *failedPdu = (SigProvisioningFailedPdu *)response;
        TeLogDebug(@"sentProvisionRandomPdu error = %lu",(unsigned long)failedPdu.errorCode);
    }else{
        TeLogDebug(@"sentProvisionRandomPdu:no handel this response data");
    }
}

- (void)sentProvisionRandomPduTimeout {
    TeLogInfo(@"sentProvisionRandomPduTimeout");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisionRandomPduTimeout) object:nil];
    });
    if (self.provisionResponseBlock) {
        self.provisionResponseBlock(nil);
    }
}

- (void)sentProvisionEncryptedDataWithMicPduWithResponse:(SigProvisioningPdu *)response {
    TeLogInfo(@"\n\n==========provision end.\n\n");
    TeLogInfo(@"device provision result back:%@",response.pduData);
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisionEncryptedDataWithMicPduTimeout) object:nil];
    });
    if (response.provisionType == SigProvisioningPduType_complete) {
        [self provisionSuccess];
        [SigBearer.share setBearerProvisioned:YES];
        if (self.provisionSuccessBlock) {
            self.provisionSuccessBlock(self.unprovisionedDevice.uuid,self.unicastAddress);
        }
    }else if (!response || response.provisionType == SigProvisioningPduType_failed) {
        self.state = ProvisioningState_fail;
        SigProvisioningFailedPdu *failedPdu = (SigProvisioningFailedPdu *)response;
        TeLogDebug(@"sentProvisionEncryptedDataWithMic error = %lu",(unsigned long)failedPdu.errorCode);
    }else{
        TeLogDebug(@"sentProvisionEncryptedDataWithMic:no handel this response data");
    }
    self.provisionResponseBlock = nil;
}

- (void)sentProvisionEncryptedDataWithMicPduTimeout {
    TeLogInfo(@"sentProvisionEncryptedDataWithMicPduTimeout");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisionEncryptedDataWithMicPduTimeout) object:nil];
    });
    if (self.provisionResponseBlock) {
        self.provisionResponseBlock(nil);
    }
}


/// The Provisioner sends a Provisioning Record Request PDU to request a provisioning record fragment (a part of a provisioning record; see Section 5.4.2.6) from the device.
/// @param recordID Identifies the provisioning record for which the request is made (see Section 5.4.2.6).
/// @param fragmentOffset The starting offset of the requested fragment in the provisioning record data.
/// @param fragmentMaximumSize The maximum size of the provisioning record fragment that the Provisioner can receive.
/// @param timeout timeout of this pdu.
/// @param block response of this pdu.
- (void)sentProvisioningRecordRequestWithRecordID:(UInt16)recordID fragmentOffset:(UInt16)fragmentOffset fragmentMaximumSize:(UInt16)fragmentMaximumSize timeout:(NSTimeInterval)timeout callback:(prvisionResponseCallBack)block {
    TeLogInfo(@"\n\n==========provision: Record Request PDU\n\n");
    self.provisionResponseBlock = block;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisioningRecordRequestTimeout) object:nil];
        [self performSelector:@selector(sentProvisioningRecordRequestTimeout) withObject:nil afterDelay:timeout];
    });
    
    SigProvisioningRecordRequestPdu *pdu = [[SigProvisioningRecordRequestPdu alloc] initWithRecordID:recordID fragmentOffset:fragmentOffset fragmentMaximumSize:fragmentMaximumSize];
    self.state = ProvisioningState_recordRequest;
    [self sendPdu:pdu];
}

- (void)sentProvisioningRecordRequestWithResponse:(SigProvisioningPdu *)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisioningRecordRequestTimeout) object:nil];
    });
    if (response.provisionType == SigProvisioningPduType_recordResponse) {
        SigProvisioningRecordResponsePdu *recordResponsePdu = (SigProvisioningRecordResponsePdu *)response;
        self.state = ProvisioningState_recordResponse;
        self.totalLength = recordResponsePdu.totalLength;
        NSMutableData *mData = [NSMutableData dataWithData:self.certificateDict[@(self.currentRecordID)]];
        [mData appendData:recordResponsePdu.data];
        self.certificateDict[@(self.currentRecordID)] = mData;
    }else if (!response || response.provisionType == SigProvisioningPduType_failed) {
        self.state = ProvisioningState_fail;
        SigProvisioningFailedPdu *failedPdu = (SigProvisioningFailedPdu *)response;
        TeLogDebug(@"sentProvisioningRecordRequest error = %lu",(unsigned long)failedPdu.errorCode);
    }else{
        TeLogDebug(@"sentProvisioningRecordRequest:no handel this response data");
    }
}

- (void)sentProvisioningRecordRequestTimeout {
    TeLogInfo(@"sentProvisioningRecordRequestTimeout");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisioningRecordRequestTimeout) object:nil];
    });
    if (self.provisionResponseBlock) {
        self.provisionResponseBlock(nil);
    }
}

/// The Provisioner sends a Provisioning Records Get PDU to request the list of IDs of the provisioning records that are stored on a device.
/// @param timeout timeout of this pdu.
/// @param block response of this pdu.
- (void)sentProvisioningRecordsGetWithTimeout:(NSTimeInterval)timeout callback:(prvisionResponseCallBack)block {
    TeLogInfo(@"\n\n==========provision: Records Get PDU\n\n");
    self.provisionResponseBlock = block;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisioningRecordsGetTimeout) object:nil];
        [self performSelector:@selector(sentProvisioningRecordsGetTimeout) withObject:nil afterDelay:timeout];
    });
    
    SigProvisioningRecordsGetPdu *pdu = [[SigProvisioningRecordsGetPdu alloc] init];
    self.state = ProvisioningState_recordsGet;
    [self sendPdu:pdu];
}

- (void)sentProvisioningRecordsGetWithResponse:(SigProvisioningPdu *)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisioningRecordsGetTimeout) object:nil];
    });
    if (response.provisionType == SigProvisioningPduType_recordsList) {
        SigProvisioningRecordsListPdu *recordsListPdu = (SigProvisioningRecordsListPdu *)response;
        self.state = ProvisioningState_recordsList;
        TeLogInfo(@"response=%@,data=%@,recordsList=%@",response,recordsListPdu.pduData,recordsListPdu.recordsList);
        if ([recordsListPdu.recordsList containsObject:@(SigProvisioningRecordID_DeviceCertificate)]) {
            //5.4.2.6.3 Provisioning records,recordID=1是Device Certificate的数据。
            self.recordsListPdu = recordsListPdu;
            [self getCertificate];
        } else {
            self.state = ProvisioningState_fail;
            TeLogDebug(@"sentProvisioningRecordsGet error = %@",@"Certificate-based device hasn`t recordID=1.");
        }
    }else if (!response || response.provisionType == SigProvisioningPduType_failed) {
        self.state = ProvisioningState_fail;
        SigProvisioningFailedPdu *failedPdu = (SigProvisioningFailedPdu *)response;
        TeLogDebug(@"sentProvisioningRecordsGet error = %lu",(unsigned long)failedPdu.errorCode);
    }else{
        TeLogDebug(@"sentProvisioningRecordsGet:no handel this response data");
    }
}

- (void)sentProvisioningRecordsGetTimeout {
    TeLogInfo(@"sentProvisioningRecordsGetTimeout");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sentProvisioningRecordsGetTimeout) object:nil];
    });
    if (self.provisionResponseBlock) {
        self.provisionResponseBlock(nil);
    }
}

- (void)getCertificate {
    self.certificateDict = [NSMutableDictionary dictionary];
    
    __weak typeof(self) weakSelf = self;
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperationWithBlock:^{
        //这个block语句块在子线程中执行
        NSLog(@"operationQueue");
        NSArray *list = [NSArray arrayWithArray:weakSelf.recordsListPdu.recordsList];
        for (NSNumber *recordNumber in list) {
            UInt16 recordID = (UInt16)[recordNumber intValue];
            weakSelf.currentRecordID = recordID;
            weakSelf.totalLength = 0;
            weakSelf.certificateDict[recordNumber] = [NSMutableData data];
            BOOL result = [weakSelf getCertificateFragmentWithRecordID:recordID];
            do {
                if (result) {
                    if (weakSelf.certificateDict[recordNumber].length == weakSelf.totalLength) {
                        //获取证书所有分段完成
                        break;
                    } else {
                        //继续获取下一分段证书
                        result = [weakSelf getCertificateFragmentWithRecordID:recordID];
                    }
                } else {
                    //获取证书失败
                    break;
                }
            } while (weakSelf.certificateDict[recordNumber].length != weakSelf.totalLength);
        }
        
        if (weakSelf.certificateDict.count > 0) {
            NSData *root = SigDataSource.share.defaultRootCertificateData;
            BOOL result = [OpenSSLHelper.share checkUserCertificates:weakSelf.certificateDict.allValues withRootCertificate:root];
            if (result == NO) {
                TeLogDebug(@"=====>根证书验证失败,check certificate fail.");
                weakSelf.state = ProvisioningState_fail;
                return;
            }
        }

        NSData *publicKey = [OpenSSLHelper.share checkCertificate:weakSelf.certificateDict[@(SigProvisioningRecordID_DeviceCertificate)] withSuperCertificate:weakSelf.certificateDict[@(SigProvisioningRecordID_IntermediateCertificate1)]];
        if (publicKey && publicKey.length == 64) {
            NSData *tem = [OpenSSLHelper.share getStaticOOBDataFromCertificate:weakSelf.certificateDict[@(SigProvisioningRecordID_DeviceCertificate)]];
            if (tem && tem.length) {
                weakSelf.staticOobData = [NSData dataWithData:tem];
            }
            TeLogInfo(@"=====>获取证书成功,deviceCertificateData=%@,publicKey=%@,staticOOB=%@",[LibTools convertDataToHexStr:weakSelf.certificateDict[@(SigProvisioningRecordID_DeviceCertificate)]],[LibTools convertDataToHexStr:publicKey],[LibTools convertDataToHexStr:weakSelf.staticOobData])
            weakSelf.devicePublicKey = publicKey;
            weakSelf.state = ProvisioningState_ready;
            [weakSelf getCapabilitiesWithTimeout:kGetCapabilitiesTimeout callback:^(SigProvisioningPdu * _Nullable response) {
                [weakSelf getCapabilitiesResultWithResponse:response];
            }];
        } else {
            TeLogDebug(@"=====>证书验证失败,check certificate fail.");
            weakSelf.state = ProvisioningState_fail;
        }
    }];
}

- (BOOL)getCertificateFragmentWithRecordID:(UInt16)recordID {
    __weak typeof(self) weakSelf = self;
    __block BOOL getSuccess = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self sentProvisioningRecordRequestWithRecordID:recordID fragmentOffset:self.certificateDict[@(self.currentRecordID)].length fragmentMaximumSize:kFragmentMaximumSize timeout:2 callback:^(SigProvisioningPdu * _Nullable response) {
        [weakSelf sentProvisioningRecordRequestWithResponse:response];
        if (response && response.provisionType == SigProvisioningPduType_recordResponse) {
            getSuccess = YES;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    //Most provide 2 seconds to getDeviceCertificate
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2.0));
    return getSuccess;
}

/// 当SDK不支持EPA功能时，默认都使用SigFipsP256EllipticCurve_CMAC_AES128。
- (Algorithm)getCurrentProvisionAlgorithm {
    Algorithm algorithm = Algorithm_fipsP256EllipticCurve;
#if SUPPORTEPA
    if (SigDataSource.share.fipsP256EllipticCurve == SigFipsP256EllipticCurve_CMAC_AES128) {
        algorithm = Algorithm_fipsP256EllipticCurve;
    } else if (SigDataSource.share.fipsP256EllipticCurve == SigFipsP256EllipticCurve_HMAC_SHA256) {
        algorithm = Algorithm_fipsP256EllipticCurve_HMAC_SHA256;
    } else if (SigDataSource.share.fipsP256EllipticCurve == SigFipsP256EllipticCurve_auto) {
        if (self.provisioningCapabilities.algorithms.fipsP256EllipticCurve_HMAC_SHA256 == 1) {
            algorithm = Algorithm_fipsP256EllipticCurve_HMAC_SHA256;
        } else if (self.provisioningCapabilities.algorithms.fipsP256EllipticCurve == 1) {
            algorithm = Algorithm_fipsP256EllipticCurve;
        }
    }
#endif
    return algorithm;
}

@end
