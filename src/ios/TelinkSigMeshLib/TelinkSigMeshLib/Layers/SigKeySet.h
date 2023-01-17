/********************************************************************************************************
 * @file     SigKeySet.h
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/9/28
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

@interface SigKeySet : NSObject
/// The Network Key used to encrypt the message.
@property (nonatomic,strong) SigNetkeyModel *networkKey;
/// The Access Layer key used to encrypt the message.
@property (nonatomic,strong) NSData *accessKey;
/// Application Key identifier, or `nil` for Device Key.
@property (nonatomic,assign) UInt8 aid;
@end

@interface SigAccessKeySet : SigKeySet
@property (nonatomic,strong) SigAppkeyModel *applicationKey;
- (instancetype)initWithApplicationKey:(SigAppkeyModel *)applicationKey;
- (SigNetkeyModel *)networkKey;
- (NSData *)accessKey;
- (UInt8)aid;
@end

@interface SigDeviceKeySet : SigKeySet
@property (nonatomic,assign) BOOL isInitAid;
@property (nonatomic,strong) SigNodeModel *node;
- (NSData *)accessKey;
- (instancetype)initWithNetworkKey:(SigNetkeyModel *)networkKey node:(SigNodeModel *)node;
@end

NS_ASSUME_NONNULL_END
