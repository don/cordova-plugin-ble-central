/********************************************************************************************************
 * @file     SigLowerTransportPdu.h
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

@interface SigLowerTransportPdu : NSObject
@property (nonatomic,strong) SigNetworkPdu *networkPduModel;

/// Source Address.
@property (nonatomic,assign) UInt16 source;
/// Destination Address.
@property (nonatomic,assign) UInt16 destination;
/// The Network Key used to decode/encode the PDU.
@property (nonatomic,strong) SigNetkeyModel *networkKey;
@property (nonatomic,strong) SigIvIndex *ivIndex;
/// Message type.
@property (nonatomic,assign) SigLowerTransportPduType type;
/// The raw data of Lower Transport Layer PDU.
@property (nonatomic,strong) NSData *transportPdu;
/// The raw data of Upper Transport Layer PDU.
@property (nonatomic,strong) NSData *upperTransportPdu;

@property (nonatomic,strong) SigNetworkPdu *networkPdu;

@end

NS_ASSUME_NONNULL_END
