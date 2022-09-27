/********************************************************************************************************
 * @file     SigNetworkLayer.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SigLowerTransportPdu,SigNetworkManager,SigSegmentAcknowledgmentMessage;

@interface SigNetworkLayer : NSObject
@property (nonatomic,strong) SigNetworkManager *networkManager;
@property (nonatomic,strong) SigDataSource *meshNetwork;
//@property (nonatomic,strong) NSCache <NSData *, NSNull *>*networkMessageCache;
//@property (nonatomic,strong) NSUserDefaults *defaults;
@property (nonatomic,strong) SigIvIndex *ivIndex;
@property (nonatomic,strong) SigNetkeyModel *networkKey;
@property (nonatomic,strong,nullable) SigSegmentAcknowledgmentMessage *lastNeedSendAckMessage;

- (instancetype)initWithNetworkManager:(SigNetworkManager *)networkManager;

/// This method handles the received PDU of given type and
/// passes it to Upper Transport Layer.
///
/// - parameter pdu:  The data received.
/// - parameter type: The PDU type.
- (void)handleIncomingPdu:(NSData *)pdu ofType:(SigPduType)type;

- (void)sendLowerTransportPdu:(SigLowerTransportPdu *)pdu ofType:(SigPduType)type withTtl:(UInt8)ttl ivIndex:(SigIvIndex *)ivIndex;

/// This method tries to send the Lower Transport Message of given type to the
/// given destination address. If the local Provisioner does not exist, or
/// does not have Unicast Address assigned, this method does nothing.
///
/// - parameter pdu:  The Lower Transport PDU to be sent.
/// - parameter type: The PDU type.
/// - parameter ttl:  The initial TTL (Time To Live) value of the message.
/// - throws: This method may throw when the `transmitter` is not set, or has
///           failed to send the PDU.
- (void)sendLowerTransportPdu:(SigLowerTransportPdu *)pdu ofType:(SigPduType)type withTtl:(UInt8)ttl;

/// This method tries to send the Proxy Configuration Message.
///
/// The Proxy Filter object will be informed about the success or a failure.
///
/// - parameter message: The Proxy Confifuration message to be sent.
- (void)sendSigProxyConfigurationMessage:(SigProxyConfigurationMessage *)message;

/// Updates the information about the Network Key known to the current Proxy Server.
/// The Network Key is required to send Proxy Configuration Messages that can be
/// decoded by the connected Proxy.
///
/// If the method detects that the Proxy has just been connected, or was reconnected,
/// it will initiate the Proxy Filter with local Provisioner's Unicast Address and
/// the `Address.allNodes` group address.
///
/// - parameter networkKey: The Network Key known to the connected Proxy.
//- (void)updateProxyFilterUsingNetworkKey:(SigNetkeyModel *)networkKey;

@end

NS_ASSUME_NONNULL_END
