/********************************************************************************************************
 * @file     SigAccessPdu.h
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

@class SigUpperTransportPdu,SigMeshAddress;

/// 3.7.3 Access payload
/// - seeAlso: Mesh_v1.0.pdf  (page.92)
@interface SigAccessPdu : NSObject
/// Operation Code. Size is 1, 2, or 3 bytes.
@property (nonatomic,assign) UInt32 opCode;
/// Application Parameters. Size is 0 ~ 379.
@property (nonatomic,strong) NSData *parameters;
/// Number of packets for this PDU.
///
/// Number of Packets | Maximum useful access payload size (octets)
///            | 32 bit TransMIC    | 64 bit TransMIC
/// -----------------+---------------------+-------------------------
/// 1                      | 11 (unsegmented) | n/a
/// 1                      | 8 (segmented)       | 4 (segmented)
/// 2                      | 20                          | 16
/// 3                      | 32                          | 28
/// n                      | (n×12)-4                 | (n×12)-8
/// 32                    | 380                        | 376
- (int)segmentsCount;




/// The Mesh Message that is being sent, or `nil`, when the message
/// was received.
@property (nonatomic,strong) SigMeshMessage *message;
/// The local Element that is sending the message, or `nil` when the
/// message was received.
@property (nonatomic,strong) SigElementModel *localElement;
/// Whether sending this message has been initiated by the user.
@property (nonatomic,assign) BOOL userInitiated;
/// Source Address.
@property (nonatomic,assign) UInt16 source;
/// Destination Address.
@property (nonatomic,strong) SigMeshAddress *destination;
/// The Access Layer PDU data that will be sent.
@property (nonatomic,strong) NSData *accessPdu;

@property (nonatomic,assign) SigLowerTransportPduType isAccessMessage;
/// Whether the outgoind message will be sent as segmented, or not.
- (BOOL)isSegmented;

- (instancetype)initFromUpperTransportPdu:(SigUpperTransportPdu *)pdu;

- (instancetype)initFromMeshMessage:(SigMeshMessage *)message sentFromLocalElement:(SigElementModel *)localElement toDestination:(SigMeshAddress *)destination userInitiated:(BOOL)userInitiated;

@end

NS_ASSUME_NONNULL_END
