/********************************************************************************************************
 * @file     SigHearbeatMessage.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/9/16
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

@class SigControlMessage;

@interface SigHearbeatMessage : NSObject
/// Source Address.
@property (nonatomic,assign) UInt16 source;
/// Destination Address.
@property (nonatomic,assign) UInt16 destination;
/// Message Op Code.
@property (nonatomic,assign) UInt8 opCode;
/// Initial TTL used when sending the message.
@property (nonatomic,assign) UInt8 initTtl;
/// Currently active features of the node.
@property (nonatomic,assign) SigFeatures features;

- (instancetype)initFromControlMessage:(SigControlMessage *)message;

/// Creates a Heartbeat message.
///
/// - parameter ttl:         Initial TTL used when sending the message.
/// - parameter features:    Currently active features of the node.
/// - parameter source:      The source address.
/// - parameter destination: The destination address.
- (instancetype)initWithInitialTtl:(UInt8)ttl features:(SigFeatures)features fromSource:(UInt16)source targettingDestination:(UInt16)destination;

@end

NS_ASSUME_NONNULL_END
