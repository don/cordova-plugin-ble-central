/********************************************************************************************************
 * @file     SigMessageHandle.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/10/25
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

/// The mesh message handle is returned upon sending a mesh message
/// and allows the message to be cancelled.
///
/// Only segmented or acknowledged messages may be cancelled.
/// Unsegmented unacknowledged messages are sent almost instantaneously
/// (depending on the connection interval and message size)
/// and therefore cannot be cancelled.
///
/// The handle contains information about the message that was sent:
/// its opcode, source and destination addresses.
@interface SigMessageHandle : NSObject
@property (nonatomic,assign) UInt32 opCode;
@property (nonatomic,assign) UInt16 source;
@property (nonatomic,assign) UInt16 destination;
@property (nonatomic,strong) SigMeshLib *manager;
@property (nonatomic,strong) SDKLibCommand *command;

//- (instancetype)initForMessage:(SigMeshMessage *)message sentFromSource:(UInt16)source toDestination:(UInt16)destination usingManager:(SigMeshLib *)manager;

- (instancetype)initForSDKLibCommand:(SDKLibCommand *)command usingManager:(SigMeshLib *)manager;

/// Cancels sending the message.
///
/// Only segmented or acknowledged messages may be cancelled.
/// Unsegmented unacknowledged messages are sent almost instantaneously
/// (depending on the connection interval and message size)
/// and therefore cannot be cancelled.
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
