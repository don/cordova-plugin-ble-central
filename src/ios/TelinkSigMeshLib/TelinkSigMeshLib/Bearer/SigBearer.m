/********************************************************************************************************
 * @file     SigBearer.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/8/23
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

#import "SigBearer.h"
#import "ProxyProtocolHandler.h"

@implementation SigPudModel
@end


@interface SigBearer ()<SigBearerDelegate>

#pragma  mark - Properties

@property (nonatomic, strong) SigBluetooth *ble;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
/// The protocol used for segmentation and reassembly.
@property (nonatomic, strong) ProxyProtocolHandler *protocolHandler;
/// The queue of PDUs to be sent. Used if the perpheral is busy.
@property (nonatomic, strong) NSMutableArray <NSData *>*queue;
/// A flag indicating whether `open()` method was called.
@property (nonatomic, assign) BOOL isOpened;//init NO.

@property (nonatomic,copy) bearerOperationResultCallback bearerOpenCallback;
@property (nonatomic,copy) bearerOperationResultCallback bearerCloseCallback;
@property (nonatomic,copy) startMeshConnectResultBlock startMeshConnectCallback;
@property (nonatomic,copy) stopMeshConnectResultBlock stopMeshConnectCallback;

/// flag current node whether had provisioned.
@property (nonatomic, assign) BOOL provisioned;//default is YES.
@property (nonatomic, assign) BOOL hasScaned1828;//default is NO.
@property (nonatomic,strong) NSMutableDictionary <CBPeripheral *,NSNumber *>*scanedPeripheralDict;
@property (nonatomic, strong) NSThread *receiveThread;

@end

@implementation SigBearer

#pragma  mark - Computed properties

+ (SigBearer *)share {
    static SigBearer *shareManager = nil;
    static dispatch_once_t tempOnce=0;
    dispatch_once(&tempOnce, ^{
        shareManager = [[SigBearer alloc] init];
        shareManager.ble = [SigBluetooth share];
        shareManager.queue = [NSMutableArray array];
        shareManager.delegate = shareManager;
        shareManager.provisioned = YES;
        shareManager.hasScaned1828 = NO;
        shareManager.isSending = NO;
        shareManager.protocolHandler = [[ProxyProtocolHandler alloc] init];
        shareManager.scanedPeripheralDict = [[NSMutableDictionary alloc] init];
        [shareManager initThread];
    });
    return shareManager;
}

- (void)initThread{
    _receiveThread = [[NSThread alloc] initWithTarget:self selector:@selector(startThread) object:nil];
    _receiveThread.name = @"SigBearer Thread";
    [_receiveThread start];
}

#pragma mark - Private
- (void)startThread{
    [NSTimer scheduledTimerWithTimeInterval:[[NSDate distantFuture] timeIntervalSinceNow] target:self selector:@selector(nullFunc) userInfo:nil repeats:NO];
    while (1) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (void)nullFunc{}

- (void)receiveOnlineStatueData:(NSData *)data {
    [self performSelector:@selector(anasislyOnlineStatueDataFromUUID:) onThread:self.receiveThread withObject:data waitUntilDone:NO];
}

- (void)anasislyOnlineStatueDataFromUUID:(NSData *)data{
    TeLogInfo(@"onlineStatus解密前=%@",[LibTools convertDataToHexStr:data]);
    NSData *beaconKey = SigMeshLib.share.dataSource.curNetkeyModel.keys.beaconKey;
    NSData *outputData = [NSData dataWithData:[self decryptionOnlineStatusPacketWithInputData:data networkBeaconKey:beaconKey]];
    if (outputData == nil || outputData.length == 0) {
        return;
    }
    UInt8 *byte = (UInt8 *)outputData.bytes;
    TeLogInfo(@"onlineStatus解密后=%@",[LibTools convertDataToHexStr:[NSData dataWithBytes:byte length:data.length]]);

    UInt8 opcodeInt=0,statusDataLength=6,statusCount=0;
    memcpy(&opcodeInt, byte, 1);
    memcpy(&statusDataLength, byte + 1, 1);
    statusCount = (UInt8)(data.length-4-2)/statusDataLength;//减去OPCode+length+snumber+CRC
    
    for (int i=0; i<statusCount; i++) {
        UInt16 address = 0;
        memcpy(&address, byte + 4 + statusDataLength*i, 2);
        if (address == 0) {
            continue;
        }
        SigNodeModel *device = [SigMeshLib.share.dataSource getNodeWithAddress:address];
        if (device) {
            UInt8 stateInt=0,bright100=0,temperature100=0;
            if (statusDataLength > 2) {
                memcpy(&stateInt, byte + 4 + statusDataLength*i + 2, 1);
            }
            if (statusDataLength > 3) {
                memcpy(&bright100, byte + 4 + statusDataLength*i + 3, 1);
            }
            if (statusDataLength > 4) {
                memcpy(&temperature100, byte + 4 + statusDataLength*i + 4, 1);
            }

            DeviceState state = stateInt == 0 ? DeviceStateOutOfLine : (bright100 == 0 ? DeviceStateOff : DeviceStateOn);
            [device updateOnlineStatusWithDeviceState:state  bright100:bright100 temperature100:temperature100];
            [SigMeshLib.share updateOnlineStatusWithDeviceAddress:address deviceState:state bright100:bright100 temperature100:temperature100];
        }
    }
}

- (NSData *)decryptionOnlineStatusPacketWithInputData:(NSData *)inputData networkBeaconKey:(NSData *)networkBeaconKey {
    UInt8 *beaconKeyByte = (UInt8 *)networkBeaconKey.bytes;
    UInt8 *byte = (UInt8 *)inputData.bytes;
    UInt8 allLen = inputData.length;
    UInt8 ivLen = 4;
    UInt8 micLen = 2;
    UInt8 len = allLen - ivLen - micLen;
    UInt8 e[16], r[16];
    UInt8 outputByte[1024];
    memset (outputByte, 0, 1024);
    memcpy (outputByte, byte, inputData.length);

    ///////////////// calculate enc ////////////////////////
    memset (r, 0, 16);
    memcpy (r+1, byte, ivLen);
    for (int i=0; i<len; i++)
    {
        if ((i&15) == 0)
        {
            aes128_ecb_encrypt(r,16,beaconKeyByte,e);
            r[0]++;
        }
        outputByte[ivLen+i] ^= e[i & 15];
    }

    ///////////// calculate mic ///////////////////////
    memset (r, 0, 16);
    memcpy (r, byte, ivLen);
    r[ivLen] = len;
    aes128_ecb_encrypt(r,16,beaconKeyByte,e);
    memcpy (r, e, 16);
    for (int i=0; i<len; i++)
    {
        r[i & 15] ^= outputByte[ivLen+i];

        if ((i&15) == 15 || i == len - 1)
        {
            aes128_ecb_encrypt(r,16,beaconKeyByte,e);
            memcpy (r, e, 16);
        }
    }

    for (int i=0; i<micLen; i++)
    {
        if (outputByte[ivLen+len+i] != r[i])
        {
            TeLogError(@"The packet of onlineStatus decryption fail.");
            return nil;//Failed
        }
    }
    NSData *outputData = [NSData dataWithBytes:outputByte length:inputData.length];
    return outputData;
}

- (void)changePeripheral:(CBPeripheral *)peripheral result:(_Nullable bearerChangePeripheralCallback)block {
    if (peripheral == nil) {
        if (block) {
            block(NO);
            return;
        }
    }
    if ([self.peripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
        [self blockState];
        if (block) {
            block(YES);
        }
    }else{
        BOOL isNull = self.peripheral == nil;
        self.peripheral = peripheral;
        if (isNull) {
            [self blockState];
            if (block) {
                block(YES);
            }
        }else{
            [SigBluetooth.share cancelAllConnecttionWithComplete:^{
                [self blockState];
                if (block) {
                    block(YES);
                }
            }];
        }
    }
}

- (void)changePeripheralIdentifierUuid:(NSString *)uuid result:(bearerChangePeripheralCallback)block {
    CBPeripheral *p = [SigBluetooth.share getPeripheralWithUUID:uuid];
    [self changePeripheral:p result:block];
}

- (BOOL)isOpen {
    return [self.ble getCharacteristicWithUUIDString:kPROXY_Out_CharacteristicsID OfPeripheral:self.peripheral].isNotifying || [self.ble getCharacteristicWithUUIDString:kPBGATT_Out_CharacteristicsID OfPeripheral:self.peripheral].isNotifying;
}

- (BOOL)isProvisioned {
    return _provisioned;
}

- (CBPeripheral *)getCurrentPeripheral {
    return self.peripheral;
}

#pragma  mark - Private

- (void)blockState {
    __weak typeof(self) weakSelf = self;
//    [self.ble setBluetoothCentralUpdateStateCallback:^(CBCentralManagerState state) {
//        if (weakSelf.isOpened) {
//            [weakSelf openWithResult:^(BOOL successful) {
//                TeLogInfo(@"ble power on, open bearer %@.",successful?@"success":@"fail");
//            }];
//        } else {
//            TeLogInfo(@"ble power.");
//        }
//    }];
    [self.ble setBluetoothDisconnectCallback:^(CBPeripheral * _Nonnull peripheral, NSError * _Nonnull error) {
        SigMeshLib.share.dataSource.unicastAddressOfConnected = 0;
        [SigMeshLib.share cleanAllCommandsAndRetryWhenMeshDisconnected];
        if ([weakSelf.dataDelegate respondsToSelector:@selector(bearer:didCloseWithError:)]) {
            [weakSelf.dataDelegate bearer:weakSelf didCloseWithError:error];
        }
        if (weakSelf.isAutoReconnect && weakSelf.isProvisioned) {
            [weakSelf performSelectorOnMainThread:@selector(startAutoConnect) withObject:nil waitUntilDone:YES];
        }
    }];
    [self.ble setBluetoothIsReadyToSendWriteWithoutResponseCallback:^(CBPeripheral * _Nonnull peripheral) {
        [weakSelf shouldSendNextPacketData];
    }];
    [self.ble setBluetoothDidUpdateValueForCharacteristicCallback:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError * _Nullable error) {
        if (![peripheral isEqual:weakSelf.peripheral]) {
            TeLogDebug(@"value is not notify from currentPeripheral.");
            return;
        }
        if (!characteristic || characteristic.value.length == 0) {
            TeLogDebug(@"value is empty.");
            return;
        }

        SigPudModel *message = [weakSelf.protocolHandler reassembleData:characteristic.value];
        if (message) {
            if ([weakSelf.delegate respondsToSelector:@selector(bearer:didDeliverData:ofType:)]) {
                [weakSelf.delegate bearer:weakSelf didDeliverData:message.pduData ofType:message.pduType];
            }
        }
    }];
    [self.ble setBluetoothDidUpdateOnlineStatusValueCallback:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError * _Nullable error) {
        if (![peripheral isEqual:weakSelf.peripheral]) {
            TeLogDebug(@"value is not notify from currentPeripheral.");
            return;
        }
        if (!characteristic || characteristic.value.length == 0) {
            TeLogDebug(@"value is empty.");
            return;
        }
        [weakSelf receiveOnlineStatueData:characteristic.value];
    }];
}

- (void)shouldSendNextPacketData {
    if (self.queue.count == 0) {
//        TeLogDebug(@"")
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shouldSendNextPacketData) object:nil];
        });
        if (self.sendPacketFinishBlock) {
            self.sendPacketFinishBlock();
        }
        return;
    } else {
        TeLogDebug(@"")
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shouldSendNextPacketData) object:nil];
            [self performSelector:@selector(shouldSendNextPacketData) withObject:nil afterDelay:0.5];
        });
        NSData *packet = self.queue.firstObject;
        [self.queue removeObjectAtIndex:0];
        [self showSendData:packet forCharacteristic:self.characteristic];
        [self.peripheral writeValue:packet forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
    }
}

- (void)showSendData:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic {
    if ([characteristic.UUID.UUIDString isEqualToString:kPBGATT_In_CharacteristicsID]) {
//        TeLogInfo(@"---> to:GATT, length:%d",data.length);
        TeLogInfo(@"---> to:GATT, length:%d,%@",data.length,[LibTools convertDataToHexStr:data]);
    } else if ([characteristic.UUID.UUIDString isEqualToString:kPROXY_In_CharacteristicsID]) {
        TeLogInfo(@"---> to:PROXY, length:%d",data.length);
    } else if ([characteristic.UUID.UUIDString isEqualToString:kOnlineStatusCharacteristicsID]) {
        TeLogInfo(@"---> to:OnlineStatusCharacteristic, length:%d,value:%@",data.length,[LibTools convertDataToHexStr:data]);
    } else if ([characteristic.UUID.UUIDString isEqualToString:kOTA_CharacteristicsID]) {
        TeLogVerbose(@"---> to:GATT-OTA, length:%d",data.length);
    } else if ([characteristic.UUID.UUIDString isEqualToString:kMeshOTA_CharacteristicsID]) {
        TeLogInfo(@"---> to:MESH-OTA, length:%d",data.length);
    } else {
        TeLogInfo(@"---> to:%@, length:%d,value:%@",characteristic.UUID.UUIDString,data.length,[LibTools convertDataToHexStr:data]);
    }
}

#pragma  mark - Public API

- (void)openWithResult:(bearerOperationResultCallback)block {
    self.bearerOpenCallback = block;
    __weak typeof(self) weakSelf = self;
    SigNodeModel *node = [SigMeshLib.share.dataSource getNodeWithUUID:self.peripheral.identifier.UUIDString];
    if (node == nil) {
        SigScanRspModel *scanModel = [SigMeshLib.share.dataSource getScanRspModelWithUUID:self.peripheral.identifier.UUIDString];
        TeLogDebug(@"start connected scanModel.macAddress=%@",scanModel.macAddress);
    } else {
        TeLogDebug(@"start connected node.macAddress=%@",node.macAddress);
    }
    [self.ble connectPeripheral:self.peripheral timeout:5.0 resultBlock:^(CBPeripheral * _Nonnull peripheral, BOOL successful) {
        if (successful) {
            [SigBluetooth.share discoverServicesOfPeripheral:peripheral timeout:5.0 resultBlock:^(CBPeripheral * _Nonnull peripheral, BOOL successful) {
                if (successful) {
                    NSMutableArray *characteristics = [NSMutableArray array];
                    CBCharacteristic *gattOutCharacteristic = [SigBluetooth.share getCharacteristicWithUUIDString:kPBGATT_Out_CharacteristicsID OfPeripheral:peripheral];
                    CBCharacteristic *proxyOutCharacteristic = [SigBluetooth.share getCharacteristicWithUUIDString:kPROXY_Out_CharacteristicsID OfPeripheral:peripheral];
                    if (gattOutCharacteristic && (gattOutCharacteristic.properties & CBCharacteristicPropertyNotify)) {
                        [characteristics addObject:gattOutCharacteristic];
                    }
                    if (proxyOutCharacteristic && (proxyOutCharacteristic.properties & CBCharacteristicPropertyNotify)) {
                        [characteristics addObject:proxyOutCharacteristic];
                    }
                    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
                    [operationQueue addOperationWithBlock:^{
                        //这个block语句块在子线程中执行
                        __block BOOL hasSuccess = NO;
                        for (CBCharacteristic *c in characteristics) {
                            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                            [SigBluetooth.share changeNotifyToState:YES Peripheral:peripheral characteristic:c timeout:5.0 resultBlock:^(CBPeripheral * _Nonnull peripheral, CBCharacteristic * _Nonnull characteristic, NSError * _Nullable error) {
                                if (!hasSuccess) {
                                    hasSuccess = characteristic.isNotifying;
                                }
                                dispatch_semaphore_signal(semaphore);
                            }];
                            //Most provide 5 seconds to change notify state.
                            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 5.0));
                        }
                        [weakSelf openResult:hasSuccess];
                    }];
                }else{
                    [weakSelf openResult:NO];
                }
            }];
        }else{
            if (block) {
                [weakSelf openResult:NO];
            }
        }
    }];
    _isOpened = YES;
}

- (void)closeWithResult:(bearerOperationResultCallback)block {
    self.bearerCloseCallback = block;
    __weak typeof(self) weakSelf = self;
    [self.ble cancelConnectionPeripheral:self.peripheral timeout:2.0 resultBlock:^(CBPeripheral * _Nonnull peripheral, BOOL successful) {
//        TeLogVerbose(@"callback disconnected peripheral=%@,successful=%d",peripheral,successful);
        [weakSelf closeResult:successful];
    }];
    _isOpened = NO;
}

- (void)openResult:(BOOL)isSuccess {
    if (isSuccess) {
        [self stopAutoConnect];
    }
    if (self.bearerOpenCallback) {
        self.bearerOpenCallback(isSuccess);
//#warning 待完善
        self.bearerOpenCallback = nil;
    }
    if (isSuccess) {
        if ([self.dataDelegate respondsToSelector:@selector(bearerDidConnectedAndDiscoverServices:)]) {
            [self.dataDelegate bearerDidConnectedAndDiscoverServices:self];
        }
    }
}

- (void)closeResult:(BOOL)isSuccess {
    if (self.bearerCloseCallback) {
        self.bearerCloseCallback(isSuccess);
//        self.bearerCloseCallback = nil;
    }
//    if ([self.dataDelegate respondsToSelector:@selector(bearer:didCloseWithError:)]) {
//        NSError *error = nil;
//        [self.dataDelegate bearer:self didCloseWithError:error];
//    }
}

- (void)connectAndReadServicesWithPeripheral:(CBPeripheral *)peripheral result:(bearerOperationResultCallback)result {
    __weak typeof(self) weakSelf = self;
    if ([self.getCurrentPeripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString] && peripheral.state == CBPeripheralStateConnected) {
        TeLogVerbose(@"peripheral.state = CBPeripheralStateConnected.");
        if (result) {
            result(YES);
        }
    } else {
        [self closeWithResult:^(BOOL successful) {
            if (successful) {
                [weakSelf changePeripheral:peripheral result:^(BOOL successful) {
                    if (successful) {
                        [weakSelf openWithResult:^(BOOL successful) {
                            if (successful) {
                                if (result) {
                                    result(YES);
                                }
                            } else {
                                if (result) {
                                    result(NO);
                                }
                            }
                        }];
                    }else{
                        if (result) {
                            result(NO);
                        }
                    }
                }];
            }else{
                if (result) {
                    result(NO);
                }
            }
        }];
    }
}

- (void)sentPcakets:(NSArray <NSData *>*)packets toCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type complete:(SendPacketsFinishCallback)complete {
    self.sendPacketFinishBlock = complete;
    [self sentPcakets:packets toCharacteristic:characteristic type:type];
}

- (void)sentPcakets:(NSArray <NSData *>*)packets toCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type {
    if (packets == nil || packets.count == 0) {
        TeLogError(@"current packets is empty.");
        if (self.sendPacketFinishBlock) {
            self.sendPacketFinishBlock();
        }
        return;
    }
    if (characteristic == nil) {
        TeLogError(@"current characteristic is empty.");
        if (self.sendPacketFinishBlock) {
            self.sendPacketFinishBlock();
        }
        return;
    }

    // On iOS 11+ only the first packet is sent here. When the peripheral is ready to send more data, a `peripheralIsReady(toSendWriteWithoutResponse:)` callback will be called, which will send the next packet.
    if (@available(iOS 11.0, *)) {
        @synchronized (self) {
            BOOL queueWasEmpty = _queue.count == 0;
            [_queue addObjectsFromArray:packets];
            self.characteristic = characteristic;
            
            // Don't look at `basePeripheral.canSendWriteWithoutResponse`. If often returns `false` even when nothing was sent before and no callback is called afterwards. Just assume, that the first packet can always be sent.
            if (queueWasEmpty) {
                NSData *packet = _queue.firstObject;
                [_queue removeObjectAtIndex:0];
                [self showSendData:packet forCharacteristic:characteristic];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shouldSendNextPacketData) object:nil];
                    // if no call back of setBluetoothIsReadyToSendWriteWithoutResponseCallback within 500ms, send next packet.
                    [self performSelector:@selector(shouldSendNextPacketData) withObject:nil afterDelay:0.5];
                });
                [SigBearer.share.getCurrentPeripheral writeValue:packet forCharacteristic:characteristic type:type];
            }
        }
    } else {
        // For iOS versions before 11, the data must be just sent in a loop. This may not work if there is more than ~20 packets to be sent, as a buffer may overflow. The solution would be to add some delays, but let's hope it will work as is. For now.
        // TODO: Handle very long packets on iOS 9 and 10.
        for (NSData *packet in packets) {
            [self showSendData:packet forCharacteristic:characteristic];
            [SigBearer.share.getCurrentPeripheral writeValue:packet forCharacteristic:characteristic type:type];
        }
        if (self.sendPacketFinishBlock) {
            self.sendPacketFinishBlock();
        }
    }

}

- (void)sendBlePdu:(SigPdu *)pdu ofType:(SigPduType)type {
    if (!pdu || !pdu.pduData || pdu.pduData.length == 0) {
        TeLogError(@"current data is empty.");
        return;
    }
    
    NSInteger mtu = [self.getCurrentPeripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse];
//    NSInteger mtu = 20;
    NSArray *packets = [self.protocolHandler segmentWithData:pdu.pduData messageType:type mtu:mtu];
//    TeLogVerbose(@"pdu.pduData.length=%d,sentPcakets:%@",pdu.pduData.length,packets);

    CBCharacteristic *c = nil;
    if (type == SigPduType_provisioningPdu) {
        c = [SigBluetooth.share getCharacteristicWithUUIDString:kPBGATT_In_CharacteristicsID OfPeripheral:SigBearer.share.getCurrentPeripheral];
    } else {
        c = [SigBluetooth.share getCharacteristicWithUUIDString:kPROXY_In_CharacteristicsID OfPeripheral:SigBearer.share.getCurrentPeripheral];
    }
    //写法1.只负责压包，运行该函数完成不等于发送完成。
//    [self sentPcakets:packets toCharacteristic:c type:CBCharacteristicWriteWithoutResponse];
    //写法2.等待所有压包都发送完成
    self.isSending = YES;
    for (NSData *pack in packets) {
        if (c == nil) {
            TeLogError(@"current characteristic is empty, needn`t send packet!");
            break;
        }
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [self sentPcakets:@[pack] toCharacteristic:c type:CBCharacteristicWriteWithoutResponse complete:^{
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2.0));
    }
    self.isSending = NO;
}

- (void)sendOTAData:(NSData *)data complete:(SendPacketsFinishCallback)complete {
    CBPeripheral *p = SigBearer.share.getCurrentPeripheral;
    CBCharacteristic *c = [SigBluetooth.share getCharacteristicWithUUIDString:kOTA_CharacteristicsID OfPeripheral:p];
    [self sentPcakets:@[data] toCharacteristic:c type:CBCharacteristicWriteWithoutResponse complete:complete];
}

- (void)sendOTAData:(NSData *)data {
    CBPeripheral *p = SigBearer.share.getCurrentPeripheral;
    CBCharacteristic *c = [SigBluetooth.share getCharacteristicWithUUIDString:kOTA_CharacteristicsID OfPeripheral:p];
    [p writeValue:data forCharacteristic:c type:CBCharacteristicWriteWithoutResponse];
}

- (void)setBearerProvisioned:(BOOL)provisioned {
    _provisioned = provisioned;
}

#pragma  mark - delegate
- (void)bearer:(SigBearer *)bearer didDeliverData:(NSData *)data ofType:(SigPduType)type {
    if (type == SigPduType_provisioningPdu) {
        if (data.length < 1) {
            return;
        }
        UInt8 type = 0;
        memcpy(&type, data.bytes, 1);
        Class MessageType = [SigProvisioningPdu getProvisioningPduClassWithProvisioningPduType:type];
        if (MessageType != nil) {
            SigProvisioningPdu *msg = [[MessageType alloc] initWithParameters:data];
            if (msg) {
                if (SigProvisioningManager.share.provisionResponseBlock) {
                    SigProvisioningManager.share.provisionResponseBlock(msg);
                }
            } else {
                TeLogDebug(@"the response is not valid.");
                return;
            }
        } else {
            TeLogDebug(@"parsing the response fail.");
            return;
        }
    }else{
        [SigMeshLib.share bearerDidDeliverData:data type:type];
    }
}

#pragma  mark - auto reconnect

/// 开始连接SigDataSource这个单例的mesh网络。
- (void)startMeshConnectWithComplete:(nullable startMeshConnectResultBlock)complete {
    if (complete) {
        self.startMeshConnectCallback = complete;
    }
    self.isAutoReconnect = YES;
    if (self.getCurrentPeripheral && self.getCurrentPeripheral.state == CBPeripheralStateConnected && [SigBluetooth.share isWorkNormal] && [SigMeshLib.share.dataSource existPeripheralUUIDString:self.getCurrentPeripheral.identifier.UUIDString]) {
        [self startMeshConnectSuccess];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(meshConnectTimeout) object:nil];
            [self performSelector:@selector(meshConnectTimeout) withObject:nil afterDelay:kStartMeshConnectTimeout];
        });
        self.hasScaned1828 = NO;
        __weak typeof(self) weakSelf = self;
        [SigBluetooth.share cancelAllConnecttionWithComplete:^{
            [weakSelf startScanMeshNode];
        }];
    }
}

/// 断开一个mesh网络的连接，切换不同的mesh网络时使用。
- (void)stopMeshConnectWithComplete:(nullable stopMeshConnectResultBlock)complete {
    self.isAutoReconnect = NO;
    self.stopMeshConnectCallback = complete;
    [SigBluetooth.share stopScan];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(meshConnectTimeout) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectRssiHightestPeripheral) object:nil];
    });
    __weak typeof(self) weakSelf = self;
    [SigBluetooth.share cancelAllConnecttionWithComplete:^{
        if (weakSelf.stopMeshConnectCallback) {
            weakSelf.stopMeshConnectCallback(YES);
        }
    }];
}

- (void)startScanMeshNode {
    __weak typeof(self) weakSelf = self;
    self.scanedPeripheralDict = [[NSMutableDictionary alloc] init];
    [SigBluetooth.share scanProvisionedDevicesWithResult:^(CBPeripheral * _Nonnull peripheral, NSDictionary<NSString *,id> * _Nonnull advertisementData, NSNumber * _Nonnull RSSI, BOOL unprovisioned) {
        if (!unprovisioned) {
            [weakSelf savePeripheralToLocal:peripheral rssi:RSSI];
            if (RSSI.intValue >= -70) {
                [weakSelf connectRssiHighterPeripheral:peripheral];
            }else{
                [weakSelf scanProvisionedDevicesSuccess];
            }
        }
    }];
}

- (void)savePeripheralToLocal:(CBPeripheral *)tempPeripheral rssi:(NSNumber *)rssi{
    self.scanedPeripheralDict[tempPeripheral] = rssi;
}

- (void)scanProvisionedDevicesSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(meshConnectTimeout) object:nil];
        if (!self.hasScaned1828) {
            self.hasScaned1828 = YES;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectRssiHightestPeripheral) object:nil];
            [self performSelector:@selector(connectRssiHightestPeripheral) withObject:nil afterDelay:1.0];
        }
    });
}

- (void)meshConnectTimeout {
    TeLogDebug(@"");
    __weak typeof(self) weakSelf = self;
    if (self.isAutoReconnect) {
        [weakSelf startMeshConnectFail];
    } else {
        [self stopMeshConnectWithComplete:^(BOOL successful) {
            [weakSelf startMeshConnectFail];
        }];
    }
}

- (void)startAutoConnect {
    TeLogInfo(@"startAutoConnect");
    [self stopAutoConnect];
    if (SigMeshLib.share.dataSource.curNodes.count > 0) {
        [self startMeshConnectWithComplete:self.startMeshConnectCallback];
    }
}

/// Stop auto connect(停止自动连接流程)
- (void)stopAutoConnect {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(meshConnectTimeout) object:nil];
    });
}

/// 正常扫描流程：1秒内扫描到RSSI大于“-50”的设备，直接连接。
- (void)connectRssiHighterPeripheral:(CBPeripheral *)peripheral {
//    TeLogInfo(@"peripheral.uuid=%@",peripheral.identifier.UUIDString);
    [SigBluetooth.share stopScan];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(meshConnectTimeout) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectRssiHightestPeripheral) object:nil];
    });
    [self normalConnectPeripheral:peripheral];
}

/// 正常扫描流程：扫描到第一个设备1秒后连接RSSI最大的设备
- (void)connectRssiHightestPeripheral {
//    TeLogInfo(@"");
    [SigBluetooth.share stopScan];
    CBPeripheral *peripheral = [self getHightestRSSIPeripheral];
    if (peripheral) {
        [self normalConnectPeripheral:peripheral];
    } else {
        TeLogError(@"逻辑异常：SDK缓存中并未扫描到设备。");
    }
}

- (CBPeripheral *)getHightestRSSIPeripheral {
    if (!self.scanedPeripheralDict || self.scanedPeripheralDict.allKeys.count == 0) {
        return nil;
    }
    CBPeripheral *temP = self.scanedPeripheralDict.allKeys.firstObject;
    int temRssi = self.scanedPeripheralDict[temP].intValue;
    NSArray *allKeys = [NSArray arrayWithArray:self.scanedPeripheralDict.allKeys];
    for (CBPeripheral *tem in allKeys) {
        int value = self.scanedPeripheralDict[tem].intValue;
        if (value > temRssi) {
            temRssi = value;
            temP = tem;
        }
    }
    return temP;
}

- (void)normalConnectPeripheral:(CBPeripheral *)peripheral {
    __weak typeof(self) weakSelf = self;
    [self changePeripheral:peripheral result:^(BOOL successful) {
        if (successful) {
//            TeLogDebug(@"change to uuid:%@ success.",peripheral.identifier.UUIDString);
            [weakSelf openWithResult:^(BOOL successful) {
                if (successful) {
                    TeLogDebug(@"connected and read gatt list success.");
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [SDKLibCommand setFilterForProvisioner:SigMeshLib.share.dataSource.curProvisionerModel successCallback:^(UInt16 source, UInt16 destination, SigFilterStatus * _Nonnull responseMessage) {
                            TeLogDebug(@"set filter:%@ success.",peripheral.identifier.UUIDString);
                            [weakSelf startMeshConnectSuccess];
                        } finishCallback:^(BOOL isResponseAll, NSError * _Nonnull error) {
                            if (error) {
                                TeLogDebug(@"set filter:%@ fail.",peripheral.identifier.UUIDString);
                                [weakSelf startMeshConnectFail];
        //                        [weakSelf startAutoConnect];
                            }
                        }];
                    });
                } else {
                    TeLogDebug(@"read gatt list:%@ fail.",peripheral.identifier.UUIDString);
                    [weakSelf startMeshConnectFail];
//                        [weakSelf startAutoConnect];
                }
            }];
        } else {
//            TeLogDebug(@"change to uuid:%@ fail.",peripheral.identifier.UUIDString);
            [weakSelf startMeshConnectFail];
//            [weakSelf startAutoConnect];
        }
    }];
}

- (void)startMeshConnectSuccess {
    if (SigMeshLib.share.dataSource.hasNodeExistTimeModelID && SigMeshLib.share.dataSource.needPublishTimeModel) {
        [SDKLibCommand statusNowTime];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.dataDelegate respondsToSelector:@selector(bearerDidOpen:)]) {
                [self.dataDelegate bearerDidOpen:self];
            }
            if (self.startMeshConnectCallback) {
                self.startMeshConnectCallback(YES);
            }
        });
    }else{
        if ([self.dataDelegate respondsToSelector:@selector(bearerDidOpen:)]) {
            [self.dataDelegate bearerDidOpen:self];
        }
        if (self.startMeshConnectCallback) {
            self.startMeshConnectCallback(YES);
        }
    }
}

- (void)startMeshConnectFail {
//    if (self.startMeshConnectCallback) {
//        self.startMeshConnectCallback(NO);
//    }
    __weak typeof(self) weakSelf = self;
    [self closeWithResult:^(BOOL successful) {
        if (weakSelf.isAutoReconnect) {
            [weakSelf performSelectorOnMainThread:@selector(startAutoConnect) withObject:nil waitUntilDone:YES];
        }
    }];
}

@end
