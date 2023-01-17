/********************************************************************************************************
 * @file     SDKLibCommand.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/9/4
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

#import "SDKLibCommand.h"
#import "SigECCEncryptHelper.h"
#import "SigKeyBindManager.h"

@interface SDKLibCommand ()
//@property (nonatomic,strong) NSTimer *busyTimer;

@end

@implementation SDKLibCommand

- (instancetype)init{
    if (self = [super init]) {
        _retryCount = kAcknowledgeMessageDefaultRetryCount;
        _responseSourceArray = [NSMutableArray array];
        _timeout = SigDataSource.share.defaultReliableIntervalOfNotLPN;
        _hadRetryCount = 0;
        _hadReceiveAllResponse = NO;
//        _needTid = NO;
        _tidPosition = 0;
        _tid = 0;
        _curNetkey = SigMeshLib.share.dataSource.curNetkeyModel;
        _curAppkey = SigMeshLib.share.dataSource.curAppkeyModel;
        _curIvIndex = SigMeshLib.share.dataSource.curNetkeyModel.ivIndex;
    }
    return self;
}


#pragma mark - config（open API）

+ (SigMessageHandle *)configAppKeyAddWithDestination:(UInt16)destination appkeyModel:(SigAppkeyModel *)appkeyModel retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigAppKeyStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigAppKeyAdd *config = [[SigConfigAppKeyAdd alloc] initWithApplicationKey:appkeyModel];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseAppKeyStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configAppKeyUpdateWithDestination:(UInt16)destination appkeyModel:(SigAppkeyModel *)appkeyModel retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigAppKeyStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigAppKeyUpdate *config = [[SigConfigAppKeyUpdate alloc] initWithApplicationKey:appkeyModel];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseAppKeyStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configAppKeyDeleteWithDestination:(UInt16)destination appkeyModel:(SigAppkeyModel *)appkeyModel retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigAppKeyStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigAppKeyDelete *config = [[SigConfigAppKeyDelete alloc] initWithApplicationKey:appkeyModel];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseAppKeyStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configAppKeyGetWithDestination:(UInt16)destination networkKeyIndex:(UInt16)networkKeyIndex retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigAppKeyListMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigAppKeyGet *config = [[SigConfigAppKeyGet alloc] initWithNetworkKeyIndex:networkKeyIndex];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseAppKeyListCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configBeaconGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigBeaconStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigBeaconGet *config = [[SigConfigBeaconGet alloc] init];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseBeaconStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configBeaconSetWithDestination:(UInt16)destination secureNetworkBeaconState:(SigSecureNetworkBeaconState)secureNetworkBeaconState retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigBeaconStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigBeaconSet *config = [[SigConfigBeaconSet alloc] initWithEnable:secureNetworkBeaconState];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseBeaconStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configCompositionDataGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigCompositionDataStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigCompositionDataGet *config = [[SigConfigCompositionDataGet alloc] initWithPage:0xFF];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseCompositionDataStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
//    command.timeout = 3.0;//GATT-LPN固件返回SigConfigCompositionData比较慢，当前接口设置超时为3秒。
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configDefaultTtlGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigDefaultTtlStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigDefaultTtlGet *config = [[SigConfigDefaultTtlGet alloc] init];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseDefaultTtlStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configDefaultTtlSetWithDestination:(UInt16)destination ttl:(UInt8)ttl retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigDefaultTtlStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigDefaultTtlSet *config = [[SigConfigDefaultTtlSet alloc] initWithTtl:ttl];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseDefaultTtlStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configFriendGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigFriendStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigFriendGet *config = [[SigConfigFriendGet alloc] init];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseFriendStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configFriendSetWithDestination:(UInt16)destination nodeFeaturesState:(SigNodeFeaturesState)nodeFeaturesState retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigFriendStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigFriendSet *config = [[SigConfigFriendSet alloc] initWithEnable:nodeFeaturesState];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseFriendStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configGATTProxyGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigGATTProxyStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigGATTProxyGet *config = [[SigConfigGATTProxyGet alloc] init];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseGATTProxyStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configGATTProxySetWithDestination:(UInt16)destination nodeGATTProxyState:(SigNodeGATTProxyState)nodeGATTProxyState retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigGATTProxyStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigGATTProxySet *config = [[SigConfigGATTProxySet alloc] initWithEnable:nodeGATTProxyState];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseGATTProxyStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configKeyRefreshPhaseGetWithDestination:(UInt16)destination netKeyIndex:(UInt16)netKeyIndex retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigKeyRefreshPhaseStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigKeyRefreshPhaseGet *config = [[SigConfigKeyRefreshPhaseGet alloc] initWithNetKeyIndex:netKeyIndex];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseKeyRefreshPhaseStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configKeyRefreshPhaseSetWithDestination:(UInt16)destination netKeyIndex:(UInt16)netKeyIndex transition:(SigControllableKeyRefreshTransitionValues)transition retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigKeyRefreshPhaseStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigKeyRefreshPhaseSet *config = [[SigConfigKeyRefreshPhaseSet alloc] initWithNetKeyIndex:netKeyIndex transition:transition];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseKeyRefreshPhaseStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configModelPublicationGetWithDestination:(UInt16)destination elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigModelPublicationStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigModelPublicationGet *config = [[SigConfigModelPublicationGet alloc] initWithElementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseModelPublicationStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configModelPublicationSetWithDestination:(UInt16)destination publish:(SigPublish *)publish elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigModelPublicationStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigModelPublicationSet *config = [[SigConfigModelPublicationSet alloc] initWithPublish:publish toElementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseModelPublicationStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configModelPublicationVirtualAddressSetWithDestination:(UInt16)destination publish:(SigPublish *)publish elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigModelPublicationStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigModelPublicationVirtualAddressSet *config = [[SigConfigModelPublicationVirtualAddressSet alloc] initWithPublish:publish toElementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseModelPublicationStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

/*
---> Sending - Access PDU, source:(0001)->destination: (0008) Op Code: (0000801B), parameters: (080000C000FF), accessPdu=801B080000C000FF
<--- Response - Access PDU, source:(0008)->destination: (0001) Op Code: (0000801F), parameters: (00080000C000FF), accessPdu=801F00080000C000FF receieved (decrypted using key: <SigDeviceKeySet: 0x282840300>)
*/
+ (SigMessageHandle *)configModelSubscriptionAddWithDestination:(UInt16)destination toGroupAddress:(UInt16)groupAddress elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigModelSubscriptionStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigModelSubscriptionAdd *config = [[SigConfigModelSubscriptionAdd alloc] initWithGroupAddress:groupAddress toElementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseModelSubscriptionStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configModelSubscriptionDeleteWithDestination:(UInt16)destination groupAddress:(UInt16)groupAddress elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigModelSubscriptionStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigModelSubscriptionDelete *config = [[SigConfigModelSubscriptionDelete alloc] initWithGroupAddress:groupAddress elementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseModelSubscriptionStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configModelSubscriptionDeleteAllWithDestination:(UInt16)destination elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigModelSubscriptionStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigModelSubscriptionDeleteAll *config = [[SigConfigModelSubscriptionDeleteAll alloc] initWithElementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseModelSubscriptionStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configModelSubscriptionOverwriteWithDestination:(UInt16)destination groupAddress:(UInt16)groupAddress elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigModelSubscriptionStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigModelSubscriptionOverwrite *config = [[SigConfigModelSubscriptionOverwrite alloc] initWithGroupAddress:groupAddress elementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseModelSubscriptionStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configModelSubscriptionVirtualAddressAddWithDestination:(UInt16)destination virtualLabel:(CBUUID *)virtualLabel elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigModelSubscriptionStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigModelSubscriptionVirtualAddressAdd *config = [[SigConfigModelSubscriptionVirtualAddressAdd alloc] initWithVirtualLabel:virtualLabel elementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseModelSubscriptionStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configModelSubscriptionVirtualAddressDeleteWithDestination:(UInt16)destination virtualLabel:(CBUUID *)virtualLabel elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigModelSubscriptionStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigModelSubscriptionVirtualAddressDelete *config = [[SigConfigModelSubscriptionVirtualAddressDelete alloc] initWithVirtualLabel:virtualLabel elementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseModelSubscriptionStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configModelSubscriptionVirtualAddressOverwriteWithDestination:(UInt16)destination virtualLabel:(CBUUID *)virtualLabel elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigModelSubscriptionStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigModelSubscriptionVirtualAddressOverwrite *config = [[SigConfigModelSubscriptionVirtualAddressOverwrite alloc] initWithVirtualLabel:virtualLabel elementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseModelSubscriptionStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configNetworkTransmitGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigNetworkTransmitStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigNetworkTransmitGet *config = [[SigConfigNetworkTransmitGet alloc] init];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseNetworkTransmitStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configNetworkTransmitSetWithDestination:(UInt16)destination networkTransmitCount:(UInt8)networkTransmitCount networkTransmitIntervalSteps:(UInt8)networkTransmitIntervalSteps retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigNetworkTransmitStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigNetworkTransmitSet *config = [[SigConfigNetworkTransmitSet alloc] initWithCount:networkTransmitCount steps:networkTransmitIntervalSteps];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseNetworkTransmitStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configRelayGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigRelayStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigRelayGet *config = [[SigConfigRelayGet alloc] init];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseRelayStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configRelaySetWithDestination:(UInt16)destination relay:(SigNodeRelayState)relay networkTransmitCount:(UInt8)networkTransmitCount networkTransmitIntervalSteps:(UInt8)networkTransmitIntervalSteps retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigRelayStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigRelaySet *config = [[SigConfigRelaySet alloc] initWithCount:networkTransmitCount steps:networkTransmitIntervalSteps];
    config.state = relay;
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseRelayStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configSIGModelSubscriptionGetWithDestination:(UInt16)destination elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigSIGModelSubscriptionListMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigSIGModelSubscriptionGet *config = [[SigConfigSIGModelSubscriptionGet alloc] initWithElementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSIGModelSubscriptionListCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configVendorModelSubscriptionGetWithDestination:(UInt16)destination elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigVendorModelSubscriptionListMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigVendorModelSubscriptionGet *config = [[SigConfigVendorModelSubscriptionGet alloc] initWithElementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseVendorModelSubscriptionListCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configLowPowerNodePollTimeoutGetWithDestination:(UInt16)destination LPNAddress:(UInt16)LPNAddress retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigLowPowerNodePollTimeoutStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigLowPowerNodePollTimeoutGet *config = [[SigConfigLowPowerNodePollTimeoutGet alloc] initWithLPNAddress:LPNAddress];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLowPowerNodePollTimeoutStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configHeartbeatPublicationGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigHeartbeatPublicationStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigHeartbeatPublicationGet *config = [[SigConfigHeartbeatPublicationGet alloc] init];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseHeartbeatPublicationStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configHeartbeatPublicationSetWithDestination:(UInt16)destination countLog:(UInt8)countLog periodLog:(UInt8)periodLog ttl:(UInt8)ttl features:(SigFeatures)features netKeyIndex:(UInt16)netKeyIndex retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigHeartbeatPublicationStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigHeartbeatPublicationSet *config = [[SigConfigHeartbeatPublicationSet alloc] initWithDestination:destination countLog:countLog periodLog:periodLog ttl:ttl features:features netKeyIndex:netKeyIndex];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseHeartbeatPublicationStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configHeartbeatSubscriptionGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigHeartbeatSubscriptionStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigHeartbeatSubscriptionGet *config = [[SigConfigHeartbeatSubscriptionGet alloc] init];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseHeartbeatSubscriptionStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configHeartbeatSubscriptionSetWithDestination:(UInt16)destination source:(UInt16)source periodLog:(UInt8)periodLog retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigHeartbeatSubscriptionStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigHeartbeatSubscriptionSet *config = [[SigConfigHeartbeatSubscriptionSet alloc] initWithSource:source destination:destination periodLog:periodLog];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseHeartbeatSubscriptionStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configModelAppBindWithDestination:(UInt16)destination applicationKeyIndex:(UInt16)applicationKeyIndex elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigModelAppStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigModelAppBind *config = [[SigConfigModelAppBind alloc] initWithApplicationKeyIndex:applicationKeyIndex elementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseModelAppStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configModelAppUnbindWithDestination:(UInt16)destination applicationKeyIndex:(UInt16)applicationKeyIndex elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigModelAppStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigModelAppUnbind *config = [[SigConfigModelAppUnbind alloc] initWithApplicationKeyIndex:applicationKeyIndex elementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseModelAppStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configNetKeyAddWithDestination:(UInt16)destination NetworkKeyIndex:(UInt16)networkKeyIndex networkKeyData:(NSData *)networkKeyData retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigNetKeyStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigNetKeyAdd *config = [[SigConfigNetKeyAdd alloc] initWithNetworkKeyIndex:networkKeyIndex networkKeyData:networkKeyData];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseNetKeyStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configNetKeyDeleteWithDestination:(UInt16)destination NetworkKeyIndex:(UInt16)networkKeyIndex retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigNetKeyStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigNetKeyDelete *config = [[SigConfigNetKeyDelete alloc] initWithNetworkKeyIndex:networkKeyIndex];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseNetKeyStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configNetKeyGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigNetKeyListMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigNetKeyGet *config = [[SigConfigNetKeyGet alloc] init];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseNetKeyListCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configNetKeyUpdateWithDestination:(UInt16)destination networkKeyIndex:(UInt16)networkKeyIndex networkKeyData:(NSData *)networkKeyData retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigNetKeyStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigNetKeyUpdate *config = [[SigConfigNetKeyUpdate alloc] initWithNetworkKeyIndex:networkKeyIndex networkKeyData:networkKeyData];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseNetKeyStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.retryCount = retryCount;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configNodeIdentityGetWithDestination:(UInt16)destination netKeyIndex:(UInt16)netKeyIndex retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigNodeIdentityStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigConfigNodeIdentityGet *config = [[SigConfigNodeIdentityGet alloc] initWithNetKeyIndex:netKeyIndex];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseNodeIdentityStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configNodeIdentitySetWithDestination:(UInt16)destination netKeyIndex:(UInt16)netKeyIndex identity:(SigNodeIdentityState)identity retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigNodeIdentityStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigConfigNodeIdentitySet *config = [[SigConfigNodeIdentitySet alloc] initWithNetKeyIndex:netKeyIndex identity:identity];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseNodeIdentityStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)resetNodeWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigNodeResetStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigNodeReset *config = [[SigConfigNodeReset alloc] init];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseNodeResetStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configSIGModelAppGetWithDestination:(UInt16)destination elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigSIGModelAppListMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigSIGModelAppGet *config = [[SigConfigSIGModelAppGet alloc] initWithElementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSIGModelAppListCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}

+ (SigMessageHandle *)configVendorModelAppGetWithDestination:(UInt16)destination elementAddress:(UInt16)elementAddress modelIdentifier:(UInt16)modelIdentifier companyIdentifier:(UInt16)companyIdentifier retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseConfigVendorModelAppListMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    SigConfigVendorModelAppGet *config = [[SigConfigVendorModelAppGet alloc] initWithElementAddress:elementAddress modelIdentifier:modelIdentifier companyIdentifier:companyIdentifier];
    command.curMeshMessage = config;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseVendorModelAppListCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendConfigMessage:config toDestination:destination command:command];
}


#pragma mark - control and access（open API）

+ (SigMessageHandle *)genericOnOffGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseGenericOnOffStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigGenericOnOffGet *message = [[SigGenericOnOffGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseOnOffStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericOnOffSetWithDestination:(UInt16)destination isOn:(BOOL)isOn retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseGenericOnOffStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigGenericOnOffSet *message = [[SigGenericOnOffSet alloc] initWithIsOn:isOn];
        msg = message;
    } else {
        SigGenericOnOffSetUnacknowledged *message = [[SigGenericOnOffSetUnacknowledged alloc] initWithIsOn:isOn];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseOnOffStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericOnOffSetDestination:(UInt16)destination isOn:(BOOL)isOn transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseGenericOnOffStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigGenericOnOffSet *message = [[SigGenericOnOffSet alloc] initWithIsOn:isOn];
        message.transitionTime = transitionTime;
        message.delay = delay;
        msg = message;
    } else {
        SigGenericOnOffSetUnacknowledged *message = [[SigGenericOnOffSetUnacknowledged alloc] initWithIsOn:isOn];
        message.transitionTime = transitionTime;
        message.delay = delay;
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseOnOffStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericLevelGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseGenericLevelStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigGenericLevelGet *message = [[SigGenericLevelGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLevelStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericLevelSetWithDestination:(UInt16)destination level:(UInt16)level transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseGenericLevelStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigGenericLevelSet *message = [[SigGenericLevelSet alloc] initWithLevel:level];
        message.transitionTime = transitionTime;
        message.delay = delay;
        msg = message;
    } else {
        SigGenericLevelSetUnacknowledged *message = [[SigGenericLevelSetUnacknowledged alloc] initWithLevel:level];
        message.transitionTime = transitionTime;
        message.delay = delay;
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLevelStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericLevelSetWithDestination:(UInt16)destination level:(UInt16)level retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseGenericLevelStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    return [self genericLevelSetWithDestination:destination level:level transitionTime:nil delay:0 retryCount:retryCount responseMaxCount:responseMaxCount ack:ack successCallback:successCallback resultCallback:resultCallback];
}

+ (SigMessageHandle *)genericDeltaSetWithDestination:(UInt16)destination delta:(UInt32)delta transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseGenericLevelStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigGenericDeltaSet *message = [[SigGenericDeltaSet alloc] initWithDelta:delta];
        message.transitionTime = transitionTime;
        message.delay = delay;
        msg = message;
    } else {
        SigGenericDeltaSetUnacknowledged *message = [[SigGenericDeltaSetUnacknowledged alloc] initWithDelta:delta];
        message.transitionTime = transitionTime;
        message.delay = delay;
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLevelStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericDeltaSetWithDestination:(UInt16)destination delta:(UInt32)delta retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseGenericLevelStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    return [self genericDeltaSetWithDestination:destination delta:delta transitionTime:nil delay:0 retryCount:retryCount responseMaxCount:responseMaxCount ack:ack successCallback:successCallback resultCallback:resultCallback];
}

+ (SigMessageHandle *)genericMoveSetWithDestination:(UInt16)destination deltaLevel:(UInt16)deltaLevel transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseGenericLevelStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigGenericMoveSet *message = [[SigGenericMoveSet alloc] initWithDeltaLevel:deltaLevel];
        message.transitionTime = transitionTime;
        message.delay = delay;
        msg = message;
    } else {
        SigGenericMoveSetUnacknowledged *message = [[SigGenericMoveSetUnacknowledged alloc] initWithDeltaLevel:deltaLevel];
        message.transitionTime = transitionTime;
        message.delay = delay;
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLevelStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericMoveSetWithDestination:(UInt16)destination deltaLevel:(UInt16)deltaLevel retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseGenericLevelStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    return [self genericMoveSetWithDestination:destination deltaLevel:deltaLevel transitionTime:nil delay:0 retryCount:retryCount responseMaxCount:responseMaxCount ack:ack successCallback:successCallback resultCallback:resultCallback];
}

+ (SigMessageHandle *)genericDefaultTransitionTimeGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseGenericDefaultTransitionTimeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigGenericDefaultTransitionTimeGet *message = [[SigGenericDefaultTransitionTimeGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseDefaultTransitionTimeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericDefaultTransitionTimeSetWithDestination:(UInt16)destination defaultTransitionTime:(nonnull SigTransitionTime *)defaultTransitionTime retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseGenericDefaultTransitionTimeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigGenericDefaultTransitionTimeSet *message = [[SigGenericDefaultTransitionTimeSet alloc] initWithTransitionTime:defaultTransitionTime];
        msg = message;
    } else {
        SigGenericDefaultTransitionTimeSetUnacknowledged *message = [[SigGenericDefaultTransitionTimeSetUnacknowledged alloc] initWithTransitionTime:defaultTransitionTime];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseDefaultTransitionTimeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericOnPowerUpGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseGenericOnPowerUpStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigGenericOnPowerUpGet *message = [[SigGenericOnPowerUpGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseOnPowerUpStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericOnPowerUpSetWithDestination:(UInt16)destination onPowerUp:(SigOnPowerUp)onPowerUp retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseGenericOnPowerUpStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigGenericOnPowerUpSet *message = [[SigGenericOnPowerUpSet alloc] initWithState:onPowerUp];
        msg = message;
    } else {
        SigGenericOnPowerUpSetUnacknowledged *message = [[SigGenericOnPowerUpSetUnacknowledged alloc] initWithState:onPowerUp];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseOnPowerUpStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericPowerLevelGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseGenericPowerLevelStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigGenericPowerLevelGet *message = [[SigGenericPowerLevelGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responsePowerLevelStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericPowerLevelSetWithDestination:(UInt16)destination power:(UInt16)power transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseGenericLevelStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigGenericPowerLevelSet *message = [[SigGenericPowerLevelSet alloc] initWithPower:power];
        message.transitionTime = transitionTime;
        message.delay = delay;
        msg = message;
    } else {
        SigGenericPowerLevelSetUnacknowledged *message = [[SigGenericPowerLevelSetUnacknowledged alloc] initWithPower:power];
        message.transitionTime = transitionTime;
        message.delay = delay;
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLevelStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericPowerLevelSetWithDestination:(UInt16)destination power:(UInt16)power retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseGenericLevelStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    return [self genericPowerLevelSetWithDestination:destination power:power transitionTime:nil delay:0 retryCount:retryCount responseMaxCount:responseMaxCount ack:ack successCallback:successCallback resultCallback:resultCallback];
}

+ (SigMessageHandle *)genericPowerLastGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseGenericPowerLastStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigGenericPowerLastGet *message = [[SigGenericPowerLastGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responsePowerLastStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericPowerDefaultGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseGenericPowerDefaultStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigGenericPowerDefaultGet *message = [[SigGenericPowerDefaultGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responsePowerDefaultStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericPowerRangeGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseGenericPowerRangeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigGenericPowerRangeGet *message = [[SigGenericPowerRangeGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responsePowerRangeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericPowerDefaultSetWithDestination:(UInt16)destination power:(UInt16)power retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseGenericPowerDefaultStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigGenericPowerDefaultSet *message = [[SigGenericPowerDefaultSet alloc] initWithPower:power];
        msg = message;
    } else {
        SigGenericPowerDefaultSetUnacknowledged *message = [[SigGenericPowerDefaultSetUnacknowledged alloc] initWithPower:power];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responsePowerDefaultStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericPowerRangeSetWithDestination:(UInt16)destination rangeMin:(UInt16)rangeMin rangeMax:(UInt16)rangeMax retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseGenericPowerRangeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigGenericPowerRangeSet *message = [[SigGenericPowerRangeSet alloc] initWithRangeMin:rangeMin rangeMax:rangeMax];
        msg = message;
    } else {
        SigGenericPowerRangeSetUnacknowledged *message = [[SigGenericPowerRangeSetUnacknowledged alloc] initWithRangeMin:rangeMin rangeMax:rangeMax];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responsePowerRangeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)genericBatteryGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseGenericBatteryStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigGenericBatteryGet *message = [[SigGenericBatteryGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseBatteryStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sensorDescriptorGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseSensorDescriptorStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigSensorDescriptorGet *message = [[SigSensorDescriptorGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSensorDescriptorStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sensorDescriptorGetWithDestination:(UInt16)destination propertyID:(UInt16)propertyID retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseSensorDescriptorStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigSensorDescriptorGet *message = [[SigSensorDescriptorGet alloc] initWithPropertyID:propertyID];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSensorDescriptorStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sensorGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseSensorStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigSensorGet *message = [[SigSensorGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSensorStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sensorGetWithDestination:(UInt16)destination propertyID:(UInt16)propertyID retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseSensorStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigSensorGet *message = [[SigSensorGet alloc] initWithPropertyID:propertyID];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSensorStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sensorColumnGetWithDestination:(UInt16)destination propertyID:(UInt16)propertyID rawValueX:(NSData *)rawValueX retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseSensorColumnStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigSensorColumnGet *message = [[SigSensorColumnGet alloc] initWithPropertyID:propertyID rawValueX:rawValueX];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSensorColumnStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sensorSeriesGetWithDestination:(UInt16)destination propertyID:(UInt16)propertyID rawValueX1Data:(NSData *)rawValueX1Data rawValueX2Data:(NSData *)rawValueX2Data retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseSensorSeriesStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigSensorSeriesGet *message = [[SigSensorSeriesGet alloc] initWithPropertyID:propertyID rawValueX1Data:rawValueX1Data rawValueX2Data:rawValueX2Data];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSensorSeriesStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sensorCadenceGetWithDestination:(UInt16)destination propertyID:(UInt16)propertyID retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseSensorCadenceStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigSensorCadenceGet *message = [[SigSensorCadenceGet alloc] initWithPropertyID:propertyID];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSensorCadenceStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sensorCadenceSetWithDestination:(UInt16)destination propertyID:(UInt16)propertyID cadenceData:(NSData *)cadenceData retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseSensorCadenceStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigSensorCadenceSet *message = [[SigSensorCadenceSet alloc] init];
        message.cadenceData = cadenceData;
        msg = message;
    } else {
        SigSensorCadenceSetUnacknowledged *message = [[SigSensorCadenceSetUnacknowledged alloc] init];
        message.cadenceData = cadenceData;
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSensorCadenceStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sensorSettingsGetWithDestination:(UInt16)destination propertyID:(UInt16)propertyID retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseSensorSettingsStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigSensorSettingsGet *message = [[SigSensorSettingsGet alloc] initWithPropertyID:propertyID];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSensorSettingsStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sensorSettingGetWithDestination:(UInt16)destination propertyID:(UInt16)propertyID settingPropertyID:(UInt16)settingPpropertyID retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseSensorSettingStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigSensorSettingGet *message = [[SigSensorSettingGet alloc] initWithPropertyID:propertyID settingPropertyID:settingPpropertyID];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSensorSettingStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sensorSettingSetWithDestination:(UInt16)destination propertyID:(UInt16)propertyID settingPropertyID:(UInt16)settingPpropertyID settingRaw:(NSData *)settingRaw retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseSensorSettingStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigSensorSettingSet *message = [[SigSensorSettingSet alloc] initWithPropertyID:propertyID settingPropertyID:settingPpropertyID settingRaw:settingRaw];
        msg = message;
    } else {
        SigSensorSettingSetUnacknowledged *message = [[SigSensorSettingSetUnacknowledged alloc] initWithPropertyID:propertyID settingPropertyID:settingPpropertyID settingRaw:settingRaw];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSensorSettingStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)timeGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseTimeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigTimeGet *message = [[SigTimeGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseTimeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)timeSetWithDestination:(UInt16)destination timeModel:(SigTimeModel *)timeModel retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseTimeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigTimeSet *message = [[SigTimeSet alloc] initWithTimeModel:timeModel];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseTimeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)timeStatusWithDestination:(UInt16)destination timeModel:(SigTimeModel *)timeModel retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(_Nullable responseTimeStatusMessageBlock)successCallback resultCallback:(_Nullable resultBlock)resultCallback {
    SigTimeStatus *message = [[SigTimeStatus alloc] init];
    message.timeModel = timeModel;
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseTimeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)timeRoleGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseTimeRoleStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigTimeRoleGet *message = [[SigTimeRoleGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseTimeRoleStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)timeRoleSetWithDestination:(UInt16)destination timeRole:(SigTimeRole)timeRole retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseTimeRoleStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigTimeRoleSet *message = [[SigTimeRoleSet alloc] initWithTimeRole:timeRole];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseTimeRoleStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)timeZoneGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseTimeZoneStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigTimeZoneGet *message = [[SigTimeZoneGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseTimeZoneStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)timeZoneSetWithDestination:(UInt16)destination timeZoneOffsetNew:(UInt8)timeZoneOffsetNew TAIOfZoneChange:(UInt64)TAIOfZoneChange retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseTimeZoneStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigTimeZoneSet *message = [[SigTimeZoneSet alloc] initWithTimeZoneOffsetNew:timeZoneOffsetNew TAIOfZoneChange:TAIOfZoneChange];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseTimeZoneStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)TAI_UTC_DeltaGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseTAI_UTC_DeltaStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigTAI_UTC_DeltaGet *message = [[SigTAI_UTC_DeltaGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseTAI_UTC_DeltaStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)TAI_UTC_DeltaSetWithDestination:(UInt16)destination TAI_UTC_DeltaNew:(UInt16)TAI_UTC_DeltaNew padding:(UInt8)padding TAIOfDeltaChange:(UInt64)TAIOfDeltaChange retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseTAI_UTC_DeltaStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigTAI_UTC_DeltaSet *message = [[SigTAI_UTC_DeltaSet alloc] initWithTAI_UTC_DeltaNew:TAI_UTC_DeltaNew padding:padding TAIOfDeltaChange:TAIOfDeltaChange];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseTAI_UTC_DeltaStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sceneGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseSceneStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigSceneGet *message = [[SigSceneGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSceneStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sceneRecallWithDestination:(UInt16)destination sceneNumber:(UInt16)sceneNumber transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseSceneStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigSceneRecall *message = [[SigSceneRecall alloc] initWithSceneNumber:sceneNumber transitionTime:transitionTime delay:delay];
        msg = message;
    } else {
        SigSceneRecallUnacknowledged *message = [[SigSceneRecallUnacknowledged alloc] initWithSceneNumber:sceneNumber transitionTime:transitionTime delay:delay];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSceneStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sceneRecallWithDestination:(UInt16)destination sceneNumber:(UInt16)sceneNumber retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseSceneStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    return [self sceneRecallWithDestination:destination sceneNumber:sceneNumber transitionTime:nil delay:0 retryCount:retryCount responseMaxCount:responseMaxCount ack:ack successCallback:successCallback resultCallback:resultCallback];
}

+ (SigMessageHandle *)sceneRegisterGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseSceneRegisterStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigSceneRegisterGet *message = [[SigSceneRegisterGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSceneRegisterStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sceneStoreWithDestination:(UInt16)destination sceneNumber:(UInt16)sceneNumber retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseSceneRegisterStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigSceneStore *message = [[SigSceneStore alloc] initWithSceneNumber:sceneNumber];
        msg = message;
    } else {
        SigSceneStoreUnacknowledged *message = [[SigSceneStoreUnacknowledged alloc] initWithSceneNumber:sceneNumber];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSceneRegisterStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)sceneDeleteWithDestination:(UInt16)destination sceneNumber:(UInt16)sceneNumber retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseSceneRegisterStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigSceneDelete *message = [[SigSceneDelete alloc] initWithSceneNumber:sceneNumber];
        msg = message;
    } else {
        SigSceneDeleteUnacknowledged *message = [[SigSceneDeleteUnacknowledged alloc] initWithSceneNumber:sceneNumber];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSceneRegisterStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)schedulerActionGetWithDestination:(UInt16)destination schedulerIndex:(UInt8)schedulerIndex retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseSchedulerActionStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigSchedulerActionGet *message = [[SigSchedulerActionGet alloc] initWithIndex:schedulerIndex];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSchedulerActionStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)schedulerGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseSchedulerStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigSchedulerGet *message = [[SigSchedulerGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSchedulerStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)schedulerActionSetWithDestination:(UInt16)destination schedulerModel:(SchedulerModel *)schedulerModel retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseSchedulerActionStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigSchedulerActionSet *message = [[SigSchedulerActionSet alloc] initWithSchedulerModel:schedulerModel];
        msg = message;
    } else {
        SigSchedulerActionSetUnacknowledged *message = [[SigSchedulerActionSetUnacknowledged alloc] initWithSchedulerModel:schedulerModel];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseSchedulerActionStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLightnessGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightLightnessStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightLightnessGet *message = [[SigLightLightnessGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLightnessStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLightnessSetWithDestination:(UInt16)destination lightness:(UInt16)lightness transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightLightnessStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightLightnessSet *message = [[SigLightLightnessSet alloc] initWithLightness:lightness transitionTime:transitionTime delay:delay];
        msg = message;
    } else {
        SigLightLightnessSetUnacknowledged *message = [[SigLightLightnessSetUnacknowledged alloc] initWithLightness:lightness transitionTime:transitionTime delay:delay];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLightnessStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLightnessSetWithDestination:(UInt16)destination lightness:(UInt16)lightness retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightLightnessStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    return [self lightLightnessSetWithDestination:destination lightness:lightness transitionTime:nil delay:0 retryCount:retryCount responseMaxCount:responseMaxCount ack:ack successCallback:successCallback resultCallback:resultCallback];
}

+ (SigMessageHandle *)lightLightnessLinearGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightLightnessLinearStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightLightnessLinearGet *message = [[SigLightLightnessLinearGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLightnessLinearStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLightnessLinearSetWithDestination:(UInt16)destination lightness:(UInt16)lightness transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightLightnessLinearStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightLightnessLinearSet *message = [[SigLightLightnessLinearSet alloc] initWithLightness:lightness transitionTime:transitionTime delay:delay];
        msg = message;
    } else {
        SigLightLightnessLinearSetUnacknowledged *message = [[SigLightLightnessLinearSetUnacknowledged alloc] initWithLightness:lightness transitionTime:transitionTime delay:delay];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLightnessLinearStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLightnessLinearSetWithDestination:(UInt16)destination lightness:(UInt16)lightness retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightLightnessLinearStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    return [self lightLightnessLinearSetWithDestination:destination lightness:lightness transitionTime:nil delay:0 retryCount:retryCount responseMaxCount:responseMaxCount ack:ack successCallback:successCallback resultCallback:resultCallback];
}

+ (SigMessageHandle *)lightLightnessLastGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightLightnessLastStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightLightnessLastGet *message = [[SigLightLightnessLastGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLightnessLastStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLightnessDefaultGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightLightnessDefaultStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightLightnessDefaultGet *message = [[SigLightLightnessDefaultGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLightnessDefaultStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLightnessRangeGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightLightnessRangeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightLightnessRangeGet *message = [[SigLightLightnessRangeGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLightnessRangeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLightnessDefaultSetWithDestination:(UInt16)destination lightness:(UInt16)lightness retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightLightnessDefaultStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightLightnessDefaultSet *message = [[SigLightLightnessDefaultSet alloc] initWithLightness:lightness];
        msg = message;
    } else {
        SigLightLightnessDefaultSetUnacknowledged *message = [[SigLightLightnessDefaultSetUnacknowledged alloc] initWithLightness:lightness];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLightnessDefaultStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLightnessRangeSetWithDestination:(UInt16)destination rangeMin:(UInt16)rangeMin rangeMax:(UInt16)rangeMax retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightLightnessRangeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightLightnessRangeSet *message = [[SigLightLightnessRangeSet alloc] initWithRangeMin:rangeMin rangeMax:rangeMax];
        msg = message;
    } else {
        SigLightLightnessRangeSetUnacknowledged *message = [[SigLightLightnessRangeSetUnacknowledged alloc] initWithRangeMin:rangeMin rangeMax:rangeMax];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLightnessRangeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightCTLGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightCTLStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightCTLGet *message = [[SigLightCTLGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightCTLStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightCTLSetWithDestination:(UInt16)destination lightness:(UInt16)lightness temperature:(UInt16)temperature deltaUV:(UInt16)deltaUV transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightCTLStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightCTLSet *message = [[SigLightCTLSet alloc] initWithCTLLightness:lightness CTLTemperature:temperature CTLDeltaUV:deltaUV transitionTime:transitionTime delay:delay];
        msg = message;
    } else {
        SigLightCTLSetUnacknowledged *message = [[SigLightCTLSetUnacknowledged alloc] initWithCTLLightness:lightness CTLTemperature:temperature CTLDeltaUV:deltaUV transitionTime:transitionTime delay:delay];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightCTLStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightCTLSetWithDestination:(UInt16)destination lightness:(UInt16)lightness temperature:(UInt16)temperature deltaUV:(UInt16)deltaUV retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightCTLStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    return [self lightCTLSetWithDestination:destination lightness:lightness temperature:temperature deltaUV:deltaUV transitionTime:nil delay:0 retryCount:retryCount responseMaxCount:responseMaxCount ack:ack successCallback:successCallback resultCallback:resultCallback];
}

+ (SigMessageHandle *)lightCTLTemperatureGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightCTLTemperatureStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightCTLTemperatureGet *message = [[SigLightCTLTemperatureGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightCTLTemperatureStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightCTLTemperatureRangeGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightCTLTemperatureRangeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightCTLTemperatureRangeGet *message = [[SigLightCTLTemperatureRangeGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightCTLTemperatureRangeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightCTLTemperatureSetWithDestination:(UInt16)destination temperature:(UInt16)temperature deltaUV:(UInt16)deltaUV transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightCTLTemperatureStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightCTLTemperatureSet *message = [[SigLightCTLTemperatureSet alloc] initWithCTLTemperature:temperature CTLDeltaUV:deltaUV transitionTime:transitionTime delay:delay];
        msg = message;
    } else {
        SigLightCTLTemperatureSetUnacknowledged *message = [[SigLightCTLTemperatureSetUnacknowledged alloc] initWithCTLTemperature:temperature CTLDeltaUV:deltaUV transitionTime:transitionTime delay:delay];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightCTLTemperatureStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightCTLTemperatureSetWithDestination:(UInt16)destination temperature:(UInt16)temperature deltaUV:(UInt16)deltaUV retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightCTLTemperatureStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    return [self lightCTLTemperatureSetWithDestination:destination temperature:temperature deltaUV:deltaUV transitionTime:nil delay:0 retryCount:retryCount responseMaxCount:responseMaxCount ack:ack successCallback:successCallback resultCallback:resultCallback];
}

+ (SigMessageHandle *)lightCTLDefaultGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightCTLDefaultStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightCTLDefaultGet *message = [[SigLightCTLDefaultGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightCTLDefaultStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightCTLDefaultSetWithDestination:(UInt16)destination lightness:(UInt16)lightness temperature:(UInt16)temperature deltaUV:(UInt16)deltaUV retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightCTLDefaultStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightCTLDefaultSet *message = [[SigLightCTLDefaultSet alloc] initWithLightness:lightness temperature:temperature deltaUV:deltaUV];
        msg = message;
    } else {
        SigLightCTLDefaultSetUnacknowledged *message = [[SigLightCTLDefaultSetUnacknowledged alloc] initWithLightness:lightness temperature:temperature deltaUV:deltaUV];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightCTLDefaultStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightCTLTemperatureRangeSetWithDestination:(UInt16)destination rangeMin:(UInt16)rangeMin rangeMax:(UInt16)rangeMax retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightCTLTemperatureRangeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightCTLTemperatureRangeSet *message = [[SigLightCTLTemperatureRangeSet alloc] initWithRangeMin:rangeMin rangeMax:rangeMax];
        msg = message;
    } else {
        SigLightCTLTemperatureRangeSetUnacknowledged *message = [[SigLightCTLTemperatureRangeSetUnacknowledged alloc] initWithRangeMin:rangeMin rangeMax:rangeMax];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightCTLTemperatureRangeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightHSLGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightHSLStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightHSLGet *message = [[SigLightHSLGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightHSLStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightHSLHueGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightHSLHueStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightHSLHueGet *message = [[SigLightHSLHueGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightHSLHueStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightHSLHueSetWithDestination:(UInt16)destination hue:(UInt16)hue transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightHSLHueStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightHSLHueSet *message = [[SigLightHSLHueSet alloc] initWithHue:hue transitionTime:transitionTime delay:delay];
        msg = message;
    } else {
        SigLightHSLHueSetUnacknowledged *message = [[SigLightHSLHueSetUnacknowledged alloc] initWithHue:hue transitionTime:transitionTime delay:delay];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightHSLHueStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightHSLHueSetWithDestination:(UInt16)destination hue:(UInt16)hue retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightHSLHueStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    return [self lightHSLHueSetWithDestination:destination hue:hue transitionTime:nil delay:0 retryCount:retryCount responseMaxCount:responseMaxCount ack:ack successCallback:successCallback resultCallback:resultCallback];
}

+ (SigMessageHandle *)lightHSLSaturationGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightHSLSaturationStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightHSLSaturationGet *message = [[SigLightHSLSaturationGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightHSLSaturationStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightHSLSaturationSetWithDestination:(UInt16)destination saturation:(UInt16)saturation transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightHSLSaturationStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightHSLSaturationSet *message = [[SigLightHSLSaturationSet alloc] initWithSaturation:saturation transitionTime:transitionTime delay:delay];
        msg = message;
    } else {
        SigLightHSLSaturationSetUnacknowledged *message = [[SigLightHSLSaturationSetUnacknowledged alloc] initWithSaturation:saturation transitionTime:transitionTime delay:delay];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightHSLSaturationStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightHSLSaturationSetWithDestination:(UInt16)destination saturation:(UInt16)saturation retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightHSLSaturationStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    return [self lightHSLSaturationSetWithDestination:destination saturation:saturation transitionTime:nil delay:0 retryCount:retryCount responseMaxCount:responseMaxCount ack:ack successCallback:successCallback resultCallback:resultCallback];
}

+ (SigMessageHandle *)lightHSLSetWithDestination:(UInt16)destination HSLLight:(UInt16)HSLLight HSLHue:(UInt16)HSLHue HSLSaturation:(UInt16)HSLSaturation transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightHSLStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightHSLSet *message = [[SigLightHSLSet alloc] initWithHSLLightness:HSLLight HSLHue:HSLHue HSLSaturation:HSLSaturation transitionTime:transitionTime delay:delay];
        msg = message;
    } else {
        SigLightHSLSetUnacknowledged *message = [[SigLightHSLSetUnacknowledged alloc] initWithHSLLightness:HSLLight HSLHue:HSLHue HSLSaturation:HSLSaturation transitionTime:transitionTime delay:delay];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightHSLStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightHSLSetWithDestination:(UInt16)destination HSLLight:(UInt16)HSLLight HSLHue:(UInt16)HSLHue HSLSaturation:(UInt16)HSLSaturation retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightHSLStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    return [self lightHSLSetWithDestination:destination HSLLight:HSLLight HSLHue:HSLHue HSLSaturation:HSLSaturation transitionTime:nil delay:0 retryCount:retryCount responseMaxCount:responseMaxCount ack:ack successCallback:successCallback resultCallback:resultCallback];
}

+ (SigMessageHandle *)lightHSLTargetGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightHSLTargetStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightHSLTargetGet *message = [[SigLightHSLTargetGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightHSLTargetStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightHSLDefaultGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightHSLDefaultStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightHSLDefaultGet *message = [[SigLightHSLDefaultGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightHSLDefaultStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightHSLRangeGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightHSLRangeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightHSLRangeGet *message = [[SigLightHSLRangeGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightHSLRangeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightHSLDefaultSetWithDestination:(UInt16)destination light:(UInt16)light hue:(UInt16)hue saturation:(UInt16)saturation retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightHSLDefaultStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightHSLDefaultSet *message = [[SigLightHSLDefaultSet alloc] initWithLightness:light hue:hue saturation:saturation];
        msg = message;
    } else {
        SigLightHSLDefaultSetUnacknowledged *message = [[SigLightHSLDefaultSetUnacknowledged alloc] initWithLightness:light hue:hue saturation:saturation];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightHSLDefaultStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightHSLRangeSetWithDestination:(UInt16)destination hueRangeMin:(UInt16)hueRangeMin hueRangeMax:(UInt16)hueRangeMax saturationRangeMin:(UInt16)saturationRangeMin saturationRangeMax:(UInt16)saturationRangeMax retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightHSLRangeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightHSLRangeSet *message = [[SigLightHSLRangeSet alloc] initWithHueRangeMin:hueRangeMin hueRangeMax:hueRangeMax saturationRangeMin:saturationRangeMin saturationRangeMax:saturationRangeMax];
        msg = message;
    } else {
        SigLightHSLRangeSetUnacknowledged *message = [[SigLightHSLRangeSetUnacknowledged alloc] initWithHueRangeMin:hueRangeMin hueRangeMax:hueRangeMax saturationRangeMin:saturationRangeMin saturationRangeMax:saturationRangeMax];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightHSLRangeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightXyLGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightXyLStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightXyLGet *message = [[SigLightXyLGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightXyLStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightXyLSetWithDestination:(UInt16)destination xyLLightness:(UInt16)xyLLightness xyLx:(UInt16)xyLx xyLy:(UInt16)xyLy transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightXyLStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightXyLSet *message = [[SigLightXyLSet alloc] initWithXyLLightness:xyLLightness xyLX:xyLx xyLY:xyLy transitionTime:transitionTime delay:delay];
        msg = message;
    } else {
        SigLightXyLSetUnacknowledged *message = [[SigLightXyLSetUnacknowledged alloc] initWithXyLLightness:xyLLightness xyLX:xyLx xyLY:xyLy transitionTime:transitionTime delay:delay];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightXyLStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightXyLSetWithDestination:(UInt16)destination xyLLightness:(UInt16)xyLLightness xyLx:(UInt16)xyLx xyLy:(UInt16)xyLy retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightXyLStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    return [self lightXyLSetWithDestination:destination xyLLightness:xyLLightness xyLx:xyLx xyLy:xyLy transitionTime:nil delay:0 retryCount:retryCount responseMaxCount:responseMaxCount ack:ack successCallback:successCallback resultCallback:resultCallback];
}

+ (SigMessageHandle *)lightXyLTargetGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightXyLTargetStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightXyLTargetGet *message = [[SigLightXyLTargetGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightXyLTargetStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightXyLDefaultGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightXyLDefaultStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightXyLDefaultGet *message = [[SigLightXyLDefaultGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightXyLDefaultStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightXyLRangeGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightXyLRangeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightXyLRangeGet *message = [[SigLightXyLRangeGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightXyLRangeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightXyLDefaultSetWithDestination:(UInt16)destination lightness:(UInt16)lightness xyLx:(UInt16)xyLx xyLy:(UInt16)xyLy retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightXyLDefaultStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightXyLDefaultSet *message = [[SigLightXyLDefaultSet alloc] initWithLightness:lightness xyLX:xyLx xyLY:xyLy];
        msg = message;
    } else {
        SigLightXyLDefaultSetUnacknowledged *message = [[SigLightXyLDefaultSetUnacknowledged alloc] initWithLightness:lightness xyLX:xyLx xyLY:xyLy];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightXyLDefaultStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightXyLRangeSetWithDestination:(UInt16)destination xyLxRangeMin:(UInt16)xyLxRangeMin xyLxRangeMax:(UInt16)xyLxRangeMax xyLyRangeMin:(UInt16)xyLyRangeMin xyLyRangeMax:(UInt16)xyLyRangeMax retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightXyLRangeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightXyLRangeSet *message = [[SigLightXyLRangeSet alloc] initWithXyLXRangeMin:xyLxRangeMin xyLXRangeMax:xyLxRangeMax xyLYRangeMin:xyLyRangeMin xyLYRangeMax:xyLyRangeMax];
        msg = message;
    } else {
        SigLightXyLRangeSetUnacknowledged *message = [[SigLightXyLRangeSetUnacknowledged alloc] initWithXyLXRangeMin:xyLxRangeMin xyLXRangeMax:xyLxRangeMax xyLYRangeMin:xyLyRangeMin xyLYRangeMax:xyLyRangeMax];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightXyLRangeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLCModeGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightLCModeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightLCModeGet *message = [[SigLightLCModeGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLCModeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLCModeSetWithDestination:(UInt16)destination enable:(BOOL)enable retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightLCModeStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightLCModeSet *message = [[SigLightLCModeSet alloc] initWithMode:enable?0x01:0x00];
        msg = message;
    } else {
        SigLightLCModeSetUnacknowledged *message = [[SigLightLCModeSetUnacknowledged alloc] initWithMode:enable?0x01:0x00];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLCModeStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLCOMGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightLCOMStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightLCOMGet *message = [[SigLightLCOMGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLCOMStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLCOMSetWithDestination:(UInt16)destination enable:(BOOL)enable retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightLCOMStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightLCOMSet *message = [[SigLightLCOMSet alloc] initWithMode:enable?0x01:0x00];
        msg = message;
    } else {
        SigLightLCOMSetUnacknowledged *message = [[SigLightLCOMSetUnacknowledged alloc] initWithMode:enable?0x01:0x00];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLCOMStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLCLightOnOffGetWithDestination:(UInt16)destination retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightLCLightOnOffStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightLCLightOnOffGet *message = [[SigLightLCLightOnOffGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLCLightOnOffStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLCLightOnOffSetWithDestination:(UInt16)destination isOn:(BOOL)isOn transitionTime:(nullable SigTransitionTime *)transitionTime delay:(UInt8)delay retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightLCLightOnOffStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightLCLightOnOffSet *message = [[SigLightLCLightOnOffSet alloc] init];
        message.lightOnOff = isOn;
        message.transitionTime = transitionTime;
        message.delay = delay;
        msg = message;
    } else {
        SigLightLCLightOnOffSetUnacknowledged *message = [[SigLightLCLightOnOffSetUnacknowledged alloc] init];
        message.lightOnOff = isOn;
        message.transitionTime = transitionTime;
        message.delay = delay;
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLCLightOnOffStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLCLightOnOffSetWithDestination:(UInt16)destination isOn:(BOOL)isOn retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightLCLightOnOffStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    return [self lightLCLightOnOffSetWithDestination:destination isOn:isOn transitionTime:nil delay:0 retryCount:retryCount responseMaxCount:responseMaxCount ack:ack successCallback:successCallback resultCallback:resultCallback];
}

+ (SigMessageHandle *)lightLCPropertyGetWithDestination:(UInt16)destination propertyID:(UInt16)propertyID retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount successCallback:(responseLightLCPropertyStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigLightLCPropertyGet *message = [[SigLightLCPropertyGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLCPropertyStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (SigMessageHandle *)lightLCPropertySetWithDestination:(UInt16)destination propertyID:(UInt16)propertyID propertyValue:(NSData *)propertyValue retryCount:(NSInteger)retryCount responseMaxCount:(NSInteger)responseMaxCount ack:(BOOL)ack successCallback:(responseLightLCPropertyStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigMeshMessage *msg;
    if (ack) {
        SigLightLCPropertySet *message = [[SigLightLCPropertySet alloc] initWithLightLCPropertyID:propertyID lightLCPropertyValue:propertyValue];
        msg = message;
    } else {
        SigLightLCPropertySetUnacknowledged *message = [[SigLightLCPropertySetUnacknowledged alloc] initWithLightLCPropertyID:propertyID lightLCPropertyValue:propertyValue];
        msg = message;
        if (successCallback != nil || resultCallback != nil) {
            TeLogWarn(@"ack is NO, successCallback and failCallback need set to nil.");
            successCallback = nil;
            resultCallback = nil;
        }
        if (retryCount != 0) {
            TeLogWarn(@"ack is NO, retryCount need set to 0.");
            retryCount = 0;
        }
        if (responseMaxCount != 0) {
            TeLogWarn(@"ack is NO, responseMaxCount need set to 0.");
            responseMaxCount = 0;
        }
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = msg;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseLightLCPropertyStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    command.retryCount = retryCount;
    return [SigMeshLib.share sendMeshMessage:msg fromLocalElement:nil toDestination:[[SigMeshAddress alloc] initWithAddress:destination] usingApplicationKey:SigMeshLib.share.dataSource.curAppkeyModel command:command];
}

+ (void)setType:(SigProxyFilerType)type successCallback:(responseFilterStatusMessageBlock)successCallback failCallback:(resultBlock)failCallback {
    SigSetFilterType *message = [[SigSetFilterType alloc] initWithType:type];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseFilterStatusCallBack = successCallback;
    command.resultCallback = failCallback;
//    command.timeout = kSDKLibCommandTimeout;
    [SigMeshLib.share sendSigProxyConfigurationMessage:message command:command];
}

+ (void)resetFilterWithSuccessCallback:(responseFilterStatusMessageBlock)successCallback failCallback:(resultBlock)failCallback {
    SigSetFilterType *message = [[SigSetFilterType alloc] initWithType:SigProxyFilerType_whitelist];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseFilterStatusCallBack = successCallback;
    command.resultCallback = failCallback;
    [SigMeshLib.share sendSigProxyConfigurationMessage:message command:command];
}

+ (void)addAddressesToFilterWithAddresses:(NSArray <NSNumber *>*)addresses successCallback:(responseFilterStatusMessageBlock)successCallback failCallback:(resultBlock)failCallback {
    SigAddAddressesToFilter *message = [[SigAddAddressesToFilter alloc] initWithAddresses:addresses];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseFilterStatusCallBack = successCallback;
    command.resultCallback = failCallback;
//    command.timeout = kSDKLibCommandTimeout;
    [SigMeshLib.share sendSigProxyConfigurationMessage:message command:command];
}

+ (void)removeAddressesFromFilterWithAddresses:(NSArray <NSNumber *>*)addresses successCallback:(responseFilterStatusMessageBlock)successCallback failCallback:(resultBlock)failCallback {
    SigRemoveAddressesFromFilter *message = [[SigRemoveAddressesFromFilter alloc] initWithAddresses:addresses];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseFilterStatusCallBack = successCallback;
    command.resultCallback = failCallback;
    [SigMeshLib.share sendSigProxyConfigurationMessage:message command:command];
}

+ (void)setFilterForProvisioner:(SigProvisionerModel *)provisioner successCallback:(responseFilterStatusMessageBlock)successCallback finishCallback:(resultBlock)failCallback {
    SigNodeModel *node = provisioner.node;
    if (!node) {
        TeLogError(@"provisioner.node = nil.");
        return;
    }
    NSMutableArray *addresses = [NSMutableArray array];
    if (node.elements && node.elements.count > 0) {
        NSArray *elements = [NSArray arrayWithArray:node.elements];
        for (SigElementModel *element in elements) {
            element.parentNodeAddress = node.address;
            // Add Unicast Addresses of all Elements of the Provisioner's Node.
            [addresses addObject:@(element.unicastAddress)];
            // Add all addresses that the Node's Models are subscribed to.
            NSArray *models = [NSArray arrayWithArray:element.models];
            for (SigModelIDModel *model in models) {
                if (model.subscribe && model.subscribe.count > 0) {
                    NSArray *subscribe = [NSArray arrayWithArray:model.subscribe];
                    for (NSString *addr in subscribe) {
                        UInt16 indAddr = [LibTools uint16From16String:addr];
                        [addresses addObject:@(indAddr)];
                    }
                }
            }
        }
    } else {
        [addresses addObject:@(node.address)];
    }

    // Add All Nodes group address.
    [addresses addObject:@(kMeshAddress_allNodes)];
    // Submit.
    __weak typeof(self) weakSelf = self;
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperationWithBlock:^{
        //这个block语句块在子线程中执行
        if (SigMeshLib.share.meshPrivateBeacon && (SigMeshLib.share.sendBeaconType == AppSendBeaconType_auto || SigMeshLib.share.sendBeaconType == AppSendBeaconType_meshPrivateBeacon)) {
            [weakSelf sendMeshPrivateBeacon];
        } else {
            [weakSelf sendSecureNetworkBeacon];
        }
        [NSThread sleepForTimeInterval:0.1];
        TeLogVerbose(@"filter addresses:%@",addresses);
        [self setType:SigProxyFilerType_whitelist successCallback:^(UInt16 source, UInt16 destination, SigFilterStatus * _Nonnull responseMessage) {
//            TeLogVerbose(@"filter type:%@",responseMessage);
            //逻辑1.for循环每次只添加一个地址            
            //逻辑2.一次添加多个地址
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf addAddressesToFilterWithAddresses:addresses successCallback:^(UInt16 source, UInt16 destination, SigFilterStatus * _Nonnull responseMessage) {
//                    TeLogVerbose(@"responseMessage.listSize=%d",responseMessage.listSize);
                    SigMeshLib.share.dataSource.unicastAddressOfConnected = source;
                    if (successCallback) {
                        successCallback(source,destination,responseMessage);
                    }
                } failCallback:^(BOOL isResponseAll, NSError * _Nonnull error) {
//                    TeLogVerbose(@"add address,isResponseAll=%d,error:%@",isResponseAll,error);
                    if (failCallback) {
                        failCallback(error==nil,error);
                    }
                }];
            });
        } failCallback:^(BOOL isResponseAll, NSError * _Nonnull error) {
//            TeLogVerbose(@"filter type,isResponseAll=%d,error:%@",isResponseAll,error);
            if (error != nil) {
                if (failCallback) {
                    failCallback(NO,error);
                }
            }
        }];

    }];
}


#pragma mark - API by Telink

+ (nullable NSError *)telinkApiGetOnlineStatueFromUUIDWithResponseMaxCount:(int)responseMaxCount successCallback:(responseGenericOnOffStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    SigGenericOnOffGet *message = [[SigGenericOnOffGet alloc] init];
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.responseOnOffStatusCallBack = successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = responseMaxCount;
    return [SigMeshLib.share sendTelinkApiGetOnlineStatueFromUUIDWithMessage:message command:command];
}

+ (void)readOTACharachteristicWithTimeout:(NSTimeInterval)timeout complete:(bleReadOTACharachteristicCallback)complete {
    [SigBluetooth.share readOTACharachteristicWithTimeout:timeout complete:complete];
}

+ (void)cancelReadOTACharachteristic {
    [SigBluetooth.share cancelReadOTACharachteristic];
}

+ (nullable NSError *)sendIniCommandModel:(IniCommandModel *)model successCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    NSError *err = nil;
    UInt16 op = model.opcode;
    if (model.opcode > 0xff) {
        op = ((model.opcode & 0xff) << 8) | (model.opcode >> 8);
    }
    if (model.vendorId > 0 && model.responseOpcode == 0) {
        model.retryCount = 0;
        TeLogWarn(@"change retryCount to 0.");
    }
    BOOL reliable = [self isReliableCommandWithOpcode:op vendorOpcodeResponse:model.responseOpcode];
    if ([SigHelper.share isUnicastAddress:model.address] && reliable && model.responseMax > 1) {
        model.responseMax = 1;
        TeLogWarn(@"change responseMax to 1.");
    }
    SigIniMeshMessage *message = [[SigIniMeshMessage alloc] initWithParameters:model.commandData];
    if (model.vendorId) {
        message.opCode = (op << 16) | ((model.vendorId & 0xff) << 8) | (model.vendorId >> 8);
        //vendor的控制指令的tid特殊处理:添加tid在commandData里面tidPosition-1的位置。
        if (model.tidPosition) {
            NSMutableData *mData = [NSMutableData dataWithData:model.commandData];
            UInt8 tid = model.tid;
            [mData replaceBytesInRange:NSMakeRange(model.tidPosition-1, 1) withBytes:&tid length:1];
            message.parameters = mData;
        } else {
            message.parameters = [NSData dataWithData:model.commandData];
        }
    } else {
        message.opCode = op;
    }
    if (model.responseOpcode) {
        if (model.vendorId) {
            message.responseOpCode = (model.responseOpcode << 16) | ((model.vendorId & 0xff) << 8) | (model.vendorId >> 8);
        } else {
            message.responseOpCode = model.responseOpcode;
        }
    } else {
        message.responseOpCode = [SigHelper.share getResponseOpcodeWithSendOpcode:op];
    }
    SDKLibCommand *command = [[SDKLibCommand alloc] init];
    command.curMeshMessage = message;
    command.responseAllMessageCallBack = (responseAllMessageBlock)successCallback;
    command.resultCallback = resultCallback;
    command.responseMaxCount = model.responseMax;
    command.retryCount = model.retryCount;
    command.curNetkey = model.curNetkey;
    command.curAppkey = model.curAppkey;
    command.curIvIndex = model.curIvIndex;
    command.hadRetryCount = 0;
    command.tidPosition = model.tidPosition;
    command.tid = model.tid;
    if (model.timeout) {
        command.timeout = model.timeout;
    }

    if (model.isEncryptByDeviceKey) {
        //mesh数据使用DeviceKey进行加密
        [SigMeshLib.share sendConfigMessage:(SigConfigMessage *)message toDestination:model.address command:command];
    } else {
        SigMeshAddress *destination = [[SigMeshAddress alloc] initWithAddress:model.address];
        if (model.meshAddressModel) {
            destination = model.meshAddressModel;
        }
        //mesh数据使用AppKey进行加密
        [SigMeshLib.share sendMeshMessage:message fromLocalElement:nil toDestination:destination usingApplicationKey:model.curAppkey command:command];
    }
    return err;
}

+ (nullable NSError *)sendOpINIData:(NSData *)iniData successCallback:(responseAllMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    IniCommandModel *model = [[IniCommandModel alloc] initWithIniCommandData:iniData];
    if (SigMeshLib.share.dataSource.curNetkeyModel.index != model.netkeyIndex) {
        BOOL has = NO;
        for (SigNetkeyModel *netkey in SigMeshLib.share.dataSource.netKeys) {
            if (netkey.index == model.netkeyIndex) {
                has = YES;
                SigMeshLib.share.dataSource.curNetkeyModel = netkey;
                break;
            }
        }
        if (!has) {
            TeLogError(@"%@",kSigMeshLibCommandInvalidNetKeyIndexErrorMessage);
            NSError *error = [NSError errorWithDomain:kSigMeshLibCommandInvalidNetKeyIndexErrorMessage code:kSigMeshLibCommandInvalidNetKeyIndexErrorCode userInfo:nil];
            return error;
        }
    }
    if (SigMeshLib.share.dataSource.curAppkeyModel.index != model.appkeyIndex) {
        BOOL has = NO;
        for (SigAppkeyModel *appkey in SigMeshLib.share.dataSource.appKeys) {
            if (appkey.index == model.appkeyIndex) {
                has = YES;
                SigMeshLib.share.dataSource.curAppkeyModel = appkey;
                break;
            }
        }
        if (!has) {
            TeLogError(@"%@",kSigMeshLibCommandInvalidAppKeyIndexErrorMessage);
            NSError *error = [NSError errorWithDomain:kSigMeshLibCommandInvalidAppKeyIndexErrorMessage code:kSigMeshLibCommandInvalidAppKeyIndexErrorCode userInfo:nil];
            return error;
        }
    }
    return [self sendIniCommandModel:model successCallback:successCallback resultCallback:resultCallback];
}

+ (BOOL)isReliableCommandWithOpcode:(UInt16)opcode vendorOpcodeResponse:(UInt32)vendorOpcodeResponse {
    if ([SigHelper.share getOpCodeTypeWithOpcode:opcode] == SigOpCodeType_vendor3) {
        return ((vendorOpcodeResponse & 0xff) != 0);
    } else {
        int responseOpCode = [SigHelper.share getResponseOpcodeWithSendOpcode:opcode];
        return responseOpCode != 0;
    }
}

+ (void)startMeshSDK {
    //初始化本地存储的mesh网络数据
    [SigMeshLib.share.dataSource configData];

    //初始化ECC算法的公钥(iphone 6s耗时0.6~1.3秒，放到背景线程调用)
    [SigECCEncryptHelper.share performSelectorInBackground:@selector(eccInit) withObject:nil];

    //初始化添加设备的参数
    [SigAddDeviceManager.share setNeedDisconnectBetweenProvisionToKeyBind:NO];
    
    //初始化蓝牙
    [[SigBluetooth share] bleInit:^(CBCentralManager * _Nonnull central) {
        TeLogInfo(@"finish init SigBluetooth.");
        [SigMeshLib share];
    }];
    
//    ///默认为NO，连接速度更加快。设置为YES，表示扫描到的设备必须包含MacAddress，有些客户在添加流程需要通过MacAddress获取三元组信息，需要使用YES。
//    [SigBluetooth.share setWaitScanRseponseEnabel:YES];
}

+ (BOOL)isBLEInitFinish {
    return [SigBluetooth.share isBLEInitFinish];
}

+ (void)sendSecureNetworkBeacon {
    if (SigMeshLib.share.secureNetworkBeacon) {
        //APP端已经接收到设备端上报的SecureNetworkBeacon,无需处理。

    } else {
        //APP端未接收到设备端上报的SecureNetworkBeacon,需要根据APP端的SequenceNumber生成SecureNetworkBeacon。
        if (SigMeshLib.share.dataSource.getCurrentProvisionerIntSequenceNumber >= 0xc00000) {
            SigSecureNetworkBeacon *beacon = [[SigSecureNetworkBeacon alloc] initWithKeyRefreshFlag:NO ivUpdateActive:YES networkId:SigMeshLib.share.dataSource.curNetkeyModel.networkId ivIndex:SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.index+1 usingNetworkKey:SigMeshLib.share.dataSource.curNetkeyModel];
            SigMeshLib.share.secureNetworkBeacon = beacon;
        } else {
            SigSecureNetworkBeacon *beacon = [[SigSecureNetworkBeacon alloc] initWithKeyRefreshFlag:NO ivUpdateActive:NO networkId:SigMeshLib.share.dataSource.curNetkeyModel.networkId ivIndex:SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.index usingNetworkKey:SigMeshLib.share.dataSource.curNetkeyModel];
            SigMeshLib.share.secureNetworkBeacon = beacon;
        }
        
    }
    SigSecureNetworkBeacon *beacon = SigMeshLib.share.secureNetworkBeacon;
    TeLogInfo(@"send SecureNetworkBeacon=%@",beacon);
    [SigBearer.share sendBlePdu:beacon ofType:SigPduType_meshBeacon];
}

+ (void)sendMeshPrivateBeacon {
    if (SigMeshLib.share.meshPrivateBeacon) {
        //APP端已经接收到设备端上报的meshPrivateBeacon,无需处理。

    } else {
        //APP端未接收到设备端上报的meshPrivateBeacon,需要根据APP端的SequenceNumber生成meshPrivateBeacon。
        if (SigMeshLib.share.dataSource.getCurrentProvisionerIntSequenceNumber >= 0xc00000) {
            SigMeshPrivateBeacon *beacon = [[SigMeshPrivateBeacon alloc] initWithKeyRefreshFlag:NO ivUpdateActive:YES ivIndex:SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.index+1 randomData:[LibTools createRandomDataWithLength:13] usingNetworkKey:SigMeshLib.share.dataSource.curNetkeyModel];
            SigMeshLib.share.meshPrivateBeacon = beacon;
        } else {
            SigMeshPrivateBeacon *beacon = [[SigMeshPrivateBeacon alloc] initWithKeyRefreshFlag:NO ivUpdateActive:NO ivIndex:SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.index randomData:[LibTools createRandomDataWithLength:13] usingNetworkKey:SigMeshLib.share.dataSource.curNetkeyModel];
            SigMeshLib.share.meshPrivateBeacon = beacon;
        }
    }
    SigMeshPrivateBeacon *beacon = SigMeshLib.share.meshPrivateBeacon;
    TeLogInfo(@"send meshPrivateBeacon=%@",beacon);
    [SigBearer.share sendBlePdu:beacon ofType:SigPduType_meshBeacon];
}

+ (void)updateIvIndexWithKeyRefreshFlag:(BOOL)keyRefreshFlag ivUpdateActive:(BOOL)ivUpdateActive networkId:(NSData *)networkId ivIndex:(UInt32)ivIndex usingNetworkKey:(SigNetkeyModel *)networkKey {
    SigSecureNetworkBeacon *beacon = [[SigSecureNetworkBeacon alloc] initWithKeyRefreshFlag:keyRefreshFlag ivUpdateActive:ivUpdateActive networkId:networkId ivIndex:ivIndex usingNetworkKey:networkKey];
    TeLogInfo(@"send updateIvIndex SecureNetworkBeacon=%@",[LibTools convertDataToHexStr:beacon.pduData]);
//    if (NSThread.currentThread.isMainThread) {
//        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
//        [operationQueue addOperationWithBlock:^{
            //这个block语句块在子线程中执行
            [SigBearer.share sendBlePdu:beacon ofType:SigPduType_meshBeacon];
//        }];
//    }
}

+ (void)statusNowTime {
    //time_auth = 1;//每次无条件接受这个时间指令。
    UInt64 seconds = (UInt64)[LibTools secondsFrome2000];
    [NSTimeZone resetSystemTimeZone]; // 重置手机系统的时区
    NSInteger offset = [NSTimeZone localTimeZone].secondsFromGMT;
    UInt8 zoneOffset = (UInt8)(offset/60/15+64);//时区=分/15+64
    SigTimeModel *timeModel = [[SigTimeModel alloc] initWithTAISeconds:seconds subSeconds:0 uncertainty:0 timeAuthority:1 TAI_UTC_Delta:0 timeZoneOffset:zoneOffset];
    [self timeStatusWithDestination:kMeshAddress_allNodes timeModel:timeModel retryCount:0 responseMaxCount:0 successCallback:nil resultCallback:nil];
}

+ (void)publishNodeTimeModelWithNodeAddress:(UInt16)address successCallback:(responseConfigModelPublicationStatusMessageBlock)successCallback resultCallback:(resultBlock)resultCallback {
    //publish time model
    UInt32 option = kSigModel_TimeServer_ID;
    SigNodeModel *node = [SigMeshLib.share.dataSource getNodeWithAddress:address];
    if (node == nil) {
        TeLogError(@"there has not a node that address is 0x%x",address);
        if (resultCallback) {
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"there has not a node that address is 0x%x",address] code:0 userInfo:nil];
            resultCallback(NO,error);
        }
        return;
    }
    NSArray *elementAddresses = [node getAddressesWithModelID:@(option)];
    if (elementAddresses.count > 0) {
        TeLogVerbose(@"SDK need publish time");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UInt16 eleAdr = [elementAddresses.firstObject intValue];
            //周期，20秒上报一次。ttl:0xff（表示采用节点默认参数）。
            SigRetransmit *retransmit = [[SigRetransmit alloc] initWithPublishRetransmitCount:5 intervalSteps:2];
            SigPublish *publish = [[SigPublish alloc] initWithDestination:kMeshAddress_allNodes withKeyIndex:SigMeshLib.share.dataSource.curAppkeyModel.index friendshipCredentialsFlag:0 ttl:0xff periodSteps:kTimePublishInterval periodResolution:1 retransmit:retransmit];
            SigModelIDModel *modelID = [node getModelIDModelWithModelID:option andElementAddress:eleAdr];
            [SDKLibCommand configModelPublicationSetWithDestination:address publish:publish elementAddress:eleAdr modelIdentifier:modelID.getIntModelIdentifier companyIdentifier:modelID.getIntCompanyIdentifier retryCount:SigMeshLib.share.dataSource.defaultRetryCount responseMaxCount:1 successCallback:successCallback resultCallback:resultCallback];
        });
    }else{
        TeLogError(@"there has not a time model of node that address is 0x%x",address);
        if (resultCallback) {
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"there has not a time model of node that address is 0x%x",address] code:0 userInfo:nil];
            resultCallback(NO,error);
        }
        return;
    }
}

/**
 function 1:AUTO if you need do provision , you should call this method, and it'll call back what you need
 
 @param address address of new device
 @param networkKey network key, which provsion need, you can see it as password of the mesh
 @param netkeyIndex netkey index
 @param appkeyModel appkey model
 @param unicastAddress address of remote device
 @param uuid uuid of remote device
 @param type KeyBindType_Normal是普通添加模式，KeyBindType_Quick是快速添加模式
 @param isAuto 添加完成一个设备后，是否自动扫描添加下一个设备
 @param provisionSuccess call back when a device provision successful
 @param provisionFail call back when a device provision fail
 @param keyBindSuccess call back when a device keybind successful
 @param keyBindFail call back when a device keybind fail
 @param finish finish add the available devices list to the mesh
 */
+ (void)startAddDeviceWithNextAddress:(UInt16)address networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex appkeyModel:(SigAppkeyModel *)appkeyModel unicastAddress:(UInt16)unicastAddress uuid:(nullable NSData *)uuid keyBindType:(KeyBindType)type productID:(UInt16)productID cpsData:(nullable NSData *)cpsData isAutoAddNextDevice:(BOOL)isAuto provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess provisionFail:(ErrorBlock)provisionFail keyBindSuccess:(addDevice_keyBindSuccessCallBack)keyBindSuccess keyBindFail:(ErrorBlock)keyBindFail finish:(AddDeviceFinishCallBack)finish {
    [SigAddDeviceManager.share startAddDeviceWithNextAddress:address networkKey:networkKey netkeyIndex:netkeyIndex appkeyModel:appkeyModel unicastAddress:unicastAddress uuid:uuid keyBindType:type productID:productID cpsData:cpsData isAutoAddNextDevice:isAuto provisionSuccess:provisionSuccess provisionFail:provisionFail keyBindSuccess:keyBindSuccess keyBindFail:keyBindFail finish:finish];
}


/**
function 1:special if you need do provision , you should call this method, and it'll call back what you need

@param address address of new device
@param networkKey network key, which provsion need, you can see it as password of the mesh
@param netkeyIndex netkey index
@param peripheral device need add to mesh
@param provisionType ProvisionType_NoOOB or ProvisionType_StaticOOB.
@param staticOOBData oob for ProvisionType_StaticOOB.
@param type KeyBindType_Normal是普通添加模式，KeyBindType_Quick是快速添加模式
@param provisionSuccess call back when a device provision successful
@param provisionFail call back when a device provision fail
@param keyBindSuccess call back when a device keybind successful
@param keyBindFail call back when a device keybind fail
*/
+ (void)startAddDeviceWithNextAddress:(UInt16)address networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex appkeyModel:(SigAppkeyModel *)appkeyModel peripheral:(CBPeripheral *)peripheral provisionType:(ProvisionType)provisionType staticOOBData:(nullable NSData *)staticOOBData keyBindType:(KeyBindType)type productID:(UInt16)productID cpsData:(nullable NSData *)cpsData provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess provisionFail:(ErrorBlock)provisionFail keyBindSuccess:(addDevice_keyBindSuccessCallBack)keyBindSuccess keyBindFail:(ErrorBlock)keyBindFail{
    [SigAddDeviceManager.share startAddDeviceWithNextAddress:(UInt16)address networkKey:networkKey netkeyIndex:netkeyIndex appkeyModel:appkeyModel peripheral:peripheral provisionType:provisionType staticOOBData:staticOOBData keyBindType:type productID:productID cpsData:cpsData provisionSuccess:provisionSuccess provisionFail:provisionFail keyBindSuccess:keyBindSuccess keyBindFail:keyBindFail];
}


/// Add Single Device (provision+keyBind)
/// @param configModel all config message of add device.
/// @param provisionSuccess callback when provision success.
/// @param provisionFail callback when provision fail.
/// @param keyBindSuccess callback when keybind success.
/// @param keyBindFail callback when keybind fail.
+ (void)startAddDeviceWithSigAddConfigModel:(SigAddConfigModel *)configModel provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess provisionFail:(ErrorBlock)provisionFail keyBindSuccess:(addDevice_keyBindSuccessCallBack)keyBindSuccess keyBindFail:(ErrorBlock)keyBindFail {
    [SigAddDeviceManager.share startAddDeviceWithSigAddConfigModel:configModel provisionSuccess:provisionSuccess provisionFail:provisionFail keyBindSuccess:keyBindSuccess keyBindFail:keyBindFail];
}


/// provision
/// @param peripheral CBPeripheral of CoreBluetooth will be provision.
/// @param unicastAddress address of new device.
/// @param networkKey networkKey
/// @param netkeyIndex netkeyIndex
/// @param provisionType ProvisionType_NoOOB means oob data is 16 bytes zero data, ProvisionType_StaticOOB means oob data is get from HTTP API.
/// @param staticOOBData oob data get from HTTP API when provisionType is ProvisionType_StaticOOB.
/// @param provisionSuccess callback when provision success.
/// @param fail callback when provision fail.
+ (void)startProvisionWithPeripheral:(CBPeripheral *)peripheral unicastAddress:(UInt16)unicastAddress networkKey:(NSData *)networkKey netkeyIndex:(UInt16)netkeyIndex provisionType:(ProvisionType)provisionType staticOOBData:(NSData *)staticOOBData provisionSuccess:(addDevice_prvisionSuccessCallBack)provisionSuccess fail:(ErrorBlock)fail {
    if (provisionType == ProvisionType_NoOOB) {
        TeLogVerbose(@"start noOob provision.");
        [SigProvisioningManager.share provisionWithUnicastAddress:unicastAddress networkKey:networkKey netkeyIndex:netkeyIndex provisionSuccess:provisionSuccess fail:fail];
    } else if (provisionType == ProvisionType_StaticOOB) {
        TeLogVerbose(@"start staticOob provision.");
        [SigProvisioningManager.share provisionWithUnicastAddress:unicastAddress networkKey:networkKey netkeyIndex:netkeyIndex staticOobData:staticOOBData provisionSuccess:provisionSuccess fail:fail];
    } else {
        TeLogError(@"unsupport provision type.");
    }
}


/// keybind
/// @param peripheral CBPeripheral of CoreBluetooth will be keybind.
/// @param unicastAddress address of new device.
/// @param appkey appkey
/// @param appkeyIndex appkeyIndex
/// @param netkeyIndex netkeyIndex
/// @param keyBindType KeyBindType_Normal means add appkey and model bind, KeyBindType_Fast means just add appkey.
/// @param productID the productID info need to save in node when keyBindType is KeyBindType_Fast.
/// @param cpsData the elements info need to save in node when keyBindType is KeyBindType_Fast.
/// @param keyBindSuccess callback when keybind success.
/// @param fail callback when provision fail.
+ (void)startKeyBindWithPeripheral:(CBPeripheral *)peripheral unicastAddress:(UInt16)unicastAddress appKey:(NSData *)appkey appkeyIndex:(UInt16)appkeyIndex netkeyIndex:(UInt16)netkeyIndex keyBindType:(KeyBindType)keyBindType productID:(UInt16)productID cpsData:(NSData *)cpsData keyBindSuccess:(addDevice_keyBindSuccessCallBack)keyBindSuccess fail:(ErrorBlock)fail {
    [SigBearer.share connectAndReadServicesWithPeripheral:peripheral result:^(BOOL successful) {
        if (successful) {
            SigAppkeyModel *appkeyModel = [SigMeshLib.share.dataSource getAppkeyModelWithAppkeyIndex:appkeyIndex];
            if (!appkeyModel || ![appkeyModel.getDataKey isEqualToData:appkey] || netkeyIndex != appkeyModel.boundNetKey) {
                TeLogVerbose(@"appkey is error.");
                if (fail) {
                    NSError *err = [NSError errorWithDomain:@"appkey is error." code:-1 userInfo:nil];
                    fail(err);
                }
                return;
            }
            [SigKeyBindManager.share keyBind:unicastAddress appkeyModel:appkeyModel keyBindType:keyBindType productID:productID cpsData:cpsData keyBindSuccess:keyBindSuccess fail:fail];
        } else {
            if (fail) {
                NSError *err = [NSError errorWithDomain:@"connect fail." code:-1 userInfo:nil];
                fail(err);
            }
        }
    }];
}

/// Do key bound(纯keyBind接口)
+ (void)keyBind:(UInt16)address appkeyModel:(SigAppkeyModel *)appkeyModel keyBindType:(KeyBindType)type productID:(UInt16)productID cpsData:(nullable NSData *)cpsData keyBindSuccess:(addDevice_keyBindSuccessCallBack)keyBindSuccess fail:(ErrorBlock)fail {
    [SigKeyBindManager.share keyBind:address appkeyModel:appkeyModel keyBindType:type productID:productID cpsData:cpsData keyBindSuccess:keyBindSuccess fail:fail];
}

+ (CBCharacteristic *)getCharacteristicWithUUIDString:(NSString *)uuid OfPeripheral:(CBPeripheral *)peripheral {
    return [SigBluetooth.share getCharacteristicWithUUIDString:uuid OfPeripheral:peripheral];
}

+ (void)setBluetoothCentralUpdateStateCallback:(_Nullable bleCentralUpdateStateCallback)bluetoothCentralUpdateStateCallback {
    [SigBluetooth.share setBluetoothCentralUpdateStateCallback:bluetoothCentralUpdateStateCallback];
}

/// 开始连接SigDataSource这个单列的mesh网络。内部会10秒重试一次，直到连接成功或者调用了停止连接`stopMeshConnectWithComplete:`
+ (void)startMeshConnectWithComplete:(nullable startMeshConnectResultBlock)complete {
    [SigBearer.share startMeshConnectWithComplete:complete];
}

/// 断开一个mesh网络的连接，切换不同的mesh网络时使用。
+ (void)stopMeshConnectWithComplete:(nullable stopMeshConnectResultBlock)complete {
    [SigBearer.share stopMeshConnectWithComplete:complete];
}

#pragma mark Scan API
+ (void)scanUnprovisionedDevicesWithResult:(bleScanPeripheralCallback)result {
    [SigBluetooth.share scanUnprovisionedDevicesWithResult:result];
}

+ (void)scanProvisionedDevicesWithResult:(bleScanPeripheralCallback)result {
    [SigBluetooth.share scanProvisionedDevicesWithResult:result];
}

+ (void)scanWithServiceUUIDs:(NSArray <CBUUID *>* _Nonnull)UUIDs checkNetworkEnable:(BOOL)checkNetworkEnable result:(bleScanPeripheralCallback)result {
    [SigBluetooth.share scanWithServiceUUIDs:UUIDs checkNetworkEnable:checkNetworkEnable result:result];
}

+ (void)scanMeshNodeWithPeripheralUUID:(NSString *)peripheralUUID timeout:(NSTimeInterval)timeout resultBlock:(bleScanSpecialPeripheralCallback)block {
    [SigBluetooth.share scanMeshNodeWithPeripheralUUID:peripheralUUID timeout:timeout resultBlock:block];
}

+ (void)stopScan {
    [SigBluetooth.share stopScan];
}

@end
