/********************************************************************************************************
 * @file     SigBluetooth.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/8/16
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

@protocol SigBluetoothDelegate <NSObject>
@optional
/// 需要过滤的设备，返回YES则过滤，返回NO则不过滤。
- (BOOL)needToBeFilteredNodeWithSigScanRspModel:(SigScanRspModel *)scanRspModel provisioned:(BOOL)provisioned peripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI;
@end


@interface SigBluetooth : NSObject
/// Default is NO.
@property (nonatomic,assign) BOOL waitScanRseponseEnabel;
/// new delagate function block since v3.2.3: all notify reporting by this block.
@property (nonatomic,copy,nullable) bleDidUpdateValueForCharacteristicCallback bluetoothDidUpdateValueCallback;
/// new delagate function block since v3.2.3: notify writeWithResponse by this block.
@property (nonatomic,copy,nullable) bleDidWriteValueForCharacteristicCallback bluetoothDidWriteValueCallback;
@property (nonatomic, weak) id <SigBluetoothDelegate>delegate;

+ (instancetype)new __attribute__((unavailable("please initialize by use .share or .share()")));
- (instancetype)init __attribute__((unavailable("please initialize by use .share or .share()")));


+ (SigBluetooth *)share;

#pragma  mark - Public


/// init system CBCentralManager, developer can scan CBPeripheral when CBCentralManager.state is CBCentralManagerStatePoweredOn.
/// @param result callback when CBCentralManager had inited.
- (void)bleInit:(bleInitSuccessCallback)result;
- (BOOL)isBLEInitFinish;

- (void)setBluetoothCentralUpdateStateCallback:(_Nullable bleCentralUpdateStateCallback)bluetoothCentralUpdateStateCallback;

- (void)setBluetoothDisconnectCallback:(_Nullable bleDisconnectCallback)bluetoothDisconnectCallback;

- (void)scanUnprovisionedDevicesWithResult:(bleScanPeripheralCallback)result;

- (void)scanProvisionedDevicesWithResult:(bleScanPeripheralCallback)result;

/// 自定义扫描接口，checkNetworkEnable表示是否对已经入网的1828设备进行NetworkID过滤，过滤则只能扫描到当前手机的本地mesh数据里面的设备。
- (void)scanWithServiceUUIDs:(NSArray <CBUUID *>* _Nonnull)UUIDs checkNetworkEnable:(BOOL)checkNetworkEnable result:(bleScanPeripheralCallback)result;

- (void)setBluetoothIsReadyToSendWriteWithoutResponseCallback:(bleIsReadyToSendWriteWithoutResponseCallback)bluetoothIsReadyToSendWriteWithoutResponseCallback;

- (void)setBluetoothDidUpdateValueForCharacteristicCallback:(bleDidUpdateValueForCharacteristicCallback)bluetoothDidUpdateValueForCharacteristicCallback;

- (void)setBluetoothDidUpdateOnlineStatusValueCallback:(bleDidUpdateValueForCharacteristicCallback)bluetoothDidUpdateOnlineStatusValueCallback;

- (void)scanMeshNodeWithPeripheralUUID:(NSString *)peripheralUUID timeout:(NSTimeInterval)timeout resultBlock:(bleScanSpecialPeripheralCallback)block;

- (void)stopScan;

- (void)connectPeripheral:(CBPeripheral *)peripheral timeout:(NSTimeInterval)timeout resultBlock:(bleConnectPeripheralCallback)block;

- (void)discoverServicesOfPeripheral:(CBPeripheral *)peripheral timeout:(NSTimeInterval)timeout resultBlock:(bleDiscoverServicesCallback)block;

- (void)changeNotifyToState:(BOOL)state Peripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic timeout:(NSTimeInterval)timeout resultBlock:(bleCharacteristicResultCallback)block;

- (void)cancelAllConnecttionWithComplete:(bleCancelAllConnectCallback)complete;
- (void)cancelConnectionPeripheral:(CBPeripheral *)peripheral timeout:(NSTimeInterval)timeout resultBlock:(bleCancelConnectCallback)block;

- (void)readOTACharachteristicWithTimeout:(NSTimeInterval)timeout complete:(bleReadOTACharachteristicCallback)complete;
- (void)cancelReadOTACharachteristic;

- (CBPeripheral *)getPeripheralWithUUID:(NSString *)uuidString;

- (CBCharacteristic *)getCharacteristicWithUUIDString:(NSString *)uuid OfPeripheral:(CBPeripheral *)peripheral;

- (BOOL)isWorkNormal;

#pragma mark - new gatt api since v3.2.3
- (BOOL)readCharachteristic:(CBCharacteristic *)characteristic ofPeripheral:(CBPeripheral *)peripheral;
- (BOOL)writeValue:(NSData *)value toPeripheral:(CBPeripheral *)peripheral forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type;

#pragma mark - new gatt api since v3.3.3
- (void)readCharachteristicWithCharacteristic:(CBCharacteristic *)characteristic ofPeripheral:(CBPeripheral *)peripheral timeout:(NSTimeInterval)timeout complete:(bleReadOTACharachteristicCallback)complete;

#pragma mark - new gatt api since v3.3.5
/// 打开蓝牙通道
- (void)openChannelWithPeripheral:(CBPeripheral *)peripheral PSM:(CBL2CAPPSM)psm timeout:(NSTimeInterval)timeout resultBlock:(openChannelResultCallback)block;

@end

NS_ASSUME_NONNULL_END
