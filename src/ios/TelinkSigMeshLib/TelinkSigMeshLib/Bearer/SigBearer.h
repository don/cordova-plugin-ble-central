/********************************************************************************************************
 * @file     SigBearer.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SigBearer,SigPdu;


typedef void(^bearerOperationResultCallback)(BOOL successful);
typedef void(^bearerChangePeripheralCallback)(BOOL successful);
typedef void(^startMeshConnectResultBlock)(BOOL successful);
typedef void(^stopMeshConnectResultBlock)(BOOL successful);
typedef void(^SendPacketsFinishCallback)(void);


@protocol SigBearerDelegate <NSObject>
@optional
/// Callback called when a packet has been received using the SigBearer. Data longer than MTU will automatically be reassembled using the bearer protocol if bearer implements segmentation.
/// @param bearer The SigBearer on which the data were received.
/// @param data The data received.
/// @param type The type of the received data.
- (void)bearer:(SigBearer *)bearer didDeliverData:(NSData *)data ofType:(SigPduType)type;
@end


@protocol SigBearerDataDelegate <NSObject>
@optional
/// Callback called when the Bearer is connected and discover services finish, and open notify finish.
/// @param bearer The Bearer.
- (void)bearerDidConnectedAndDiscoverServices:(SigBearer *)bearer;
/// Callback called when the Bearer is ready for use.
/// @param bearer The Bearer.
- (void)bearerDidOpen:(SigBearer *)bearer;
/// Callback called when the Bearer is no longer open.
/// @param bearer The Bearer.
/// @param error The reason of closing the Bearer, or `nil` if closing was intended.
- (void)bearer:(SigBearer *)bearer didCloseWithError:(NSError *)error;
@end


@interface SigPudModel : NSObject
@property (nonatomic,strong) NSData *pduData;
@property (nonatomic,assign) SigPduType pduType;
@end


@interface SigBearer : NSObject
/// SigBearerDelegate只用于SDK内部，外部不需要使用该delegate。
@property (nonatomic, weak) id <SigBearerDelegate>delegate;
/// SigBearerDataDelegate给用户使用，通知上层蓝牙连接成功、setFilter成功、蓝牙断开成功。
@property (nonatomic, weak) id <SigBearerDataDelegate>dataDelegate;
@property (nonatomic, assign) BOOL isAutoReconnect;//标记是否自动重连（ota和添加流程不需要自动重连）
@property (nonatomic, copy) SendPacketsFinishCallback sendPacketFinishBlock;
@property (nonatomic, assign) BOOL isSending;//标记是否正在发送数据

#pragma  mark - Public API


+ (instancetype)new __attribute__((unavailable("please initialize by use .share or .share()")));
- (instancetype)init __attribute__((unavailable("please initialize by use .share or .share()")));


+ (SigBearer *)share;

- (BOOL)isOpen;
- (BOOL)isProvisioned;
- (CBPeripheral *)getCurrentPeripheral;

- (void)changePeripheral:(CBPeripheral *)peripheral result:(_Nullable bearerChangePeripheralCallback)block;

- (void)changePeripheralIdentifierUuid:(NSString *)uuid result:(bearerChangePeripheralCallback)block;

/// This method opens the Bearer.
- (void)openWithResult:(bearerOperationResultCallback)block;

/// This method closes the Bearer.
- (void)closeWithResult:(bearerOperationResultCallback)block;

- (void)connectAndReadServicesWithPeripheral:(CBPeripheral *)peripheral result:(bearerOperationResultCallback)result;

- (void)sentPcakets:(NSArray <NSData *>*)packets toCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type complete:(SendPacketsFinishCallback)complete;
- (void)sentPcakets:(NSArray <NSData *>*)packets toCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type;

- (void)sendBlePdu:(SigPdu *)pdu ofType:(SigPduType)type;

- (void)sendOTAData:(NSData *)data complete:(SendPacketsFinishCallback)complete;
- (void)sendOTAData:(NSData *)data;

- (void)setBearerProvisioned:(BOOL)provisioned;

/// 开始连接SigDataSource这个单列的mesh网络。内部会10秒重试一次，直到连接成功或者调用了停止连接`stopMeshConnectWithComplete:`
- (void)startMeshConnectWithComplete:(nullable startMeshConnectResultBlock)complete;

/// 断开一个mesh网络的连接，切换不同的mesh网络时使用。
- (void)stopMeshConnectWithComplete:(nullable stopMeshConnectResultBlock)complete;

@end

NS_ASSUME_NONNULL_END
