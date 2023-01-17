/********************************************************************************************************
 * @file     CheckSampleData.m
 *
 * @brief    A concise description.
 *
 * @author   Telink, 梁家誌
 * @date     2021/3/12
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

#import <XCTest/XCTest.h>
#import "TelinkSigMeshLibExtensions/TelinkSigMeshLib.h"
//#import "TelinkSigMeshLib/TelinkSigMeshLib.h"
#import "OpenSSLHelper.h"
#import "OpenSSLHelper+EPA.h"
#import "SigNetworkManager.h"
#import "SigAccessLayer.h"
#import "SigAccessPdu.h"
#import "SigUpperTransportLayer.h"
#import "SigUpperTransportPdu.h"
#import "SigLowerTransportLayer.h"
#import "SigLowerTransportPdu.h"
#import "SigSegmentedAccessMessage.h"
#import "SigSegmentedControlMessage.h"


#import "GMEllipticCurveCrypto.h"


@interface CheckSampleData : XCTestCase

@end

@implementation CheckSampleData

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


/*
 Mesh profile v1.1,page.644
 8 Sampledata
 */

/// 8.1.1 s1 SALT generation function(AES-CMAC)
- (void)testS1Founction {
    NSData *result1 = [OpenSSLHelper.share calculateSalt:[@"test" dataUsingEncoding:NSASCIIStringEncoding]];
    NSData *result2 = [LibTools nsstringToHex:@"b73cefbd641ef2ea598c2b6efb62f79c"];
    XCTAssertEqualObjects(result1, result2);
}

/// 8.1.2 k1 function （参数K1 T为内部计算出的参数，不return到外部）
- (void)testK1Founction {
    NSData *result1 = [OpenSSLHelper.share calculateK1WithN:[LibTools nsstringToHex:@"3216d1509884b533248541792b877f98"] salt:[LibTools nsstringToHex:@"2ba14ffa0df84a2831938d57d276cab4"] andP:[LibTools nsstringToHex:@"5a09d60797eeb4478aada59db3352a0d"]];
    NSData *result2 = [LibTools nsstringToHex:@"f6ed15a8934afbe7d83e8dcb57fcf5d7"];
    XCTAssertEqualObjects(result1, result2);
}

/// 8.1.3 k2 function (managed flooding) （参数k2 s1(smk2) 、k2 T、k2 T0、k2 T1、k2 T2、k2 T3为内部计算出的参数，不return到外部）
- (void)testK2Founction1 {
    NSData *result1 = [OpenSSLHelper.share calculateK2WithN:[LibTools nsstringToHex:@"f7a2a44f8e8a8029064f173ddc1e2b00"] andP:[LibTools nsstringToHex:@"00"]];
    /*
     NID:7f
     EncryptionKey: 9f589181a0f50de73c8070c7a6d27f46
     PrivacyKey: 4c715bd4a64b938f99b453351653124f
     */
    NSData *result2 = [LibTools nsstringToHex:@"7f9f589181a0f50de73c8070c7a6d27f464c715bd4a64b938f99b453351653124f"];
    XCTAssertEqualObjects(result1, result2);
}

/// 8.1.4 k2 function (friendship) （参数k2 s1(smk2) 、k2 T、k2 T0、k2 T1、k2 T2、k2 T3为内部计算出的参数，不return到外部）
- (void)testK2Founction2 {
    NSData *result1 = [OpenSSLHelper.share calculateK2WithN:[LibTools nsstringToHex:@"f7a2a44f8e8a8029064f173ddc1e2b00"] andP:[LibTools nsstringToHex:@"010203040506070809"]];
    /*
     NID:73
     EncryptionKey: 11efec0642774992510fb5929646df49
     PrivacyKey: d4d7cc0dfa772d836a8df9df5510d7a7
     */
    NSData *result2 = [LibTools nsstringToHex:@"7311efec0642774992510fb5929646df49d4d7cc0dfa772d836a8df9df5510d7a7"];
    XCTAssertEqualObjects(result1, result2);
}

/// 8.1.5 k3 function（参数k3 SALT、k3 T、k3 CMAC(“id64”||0x01)为内部计算出的参数，不return到外部）
- (void)testK3Founction {
    NSData *result1 = [OpenSSLHelper.share calculateK3WithN:[LibTools nsstringToHex:@"f7a2a44f8e8a8029064f173ddc1e2b00"]];
    NSData *result2 = [LibTools nsstringToHex:@"ff046958233db014"];
    XCTAssertEqualObjects(result1, result2);
}

/// 8.1.6 k4 function（参数k4 SALT、k4T k4CMAC(“id6”||0x01)为内部计算出的参数，不return到外部）
- (void)testK4Founction {
    UInt8 result1 = [OpenSSLHelper.share calculateK4WithN:[LibTools nsstringToHex:@"3216d1509884b533248541792b877f98"]];
    UInt8 result2 = 0x38;
    XCTAssertEqual(result1, result2);
}

/// 8.2.1 Application key AID(K4)（参数k4 SALT、k4T k4CMAC(“id6”||0x01)为内部计算出的参数，不return到外部）
- (void)testApplicationKeyAID {
    UInt8 result1 = [OpenSSLHelper.share calculateK4WithN:[LibTools nsstringToHex:@"63964771734fbd76e3b40519d1d94a48"]];
    UInt8 result2 = 0x26;
    XCTAssertEqual(result1, result2);
}

/// 8.2.2 Encryption and privacy keys (managed flooding)（K2）（参数k2 s1(smk2) 、k2 T、k2 T0、k2 T1、k2 T2、k2 T3为内部计算出的参数，不return到外部）
- (void)testEncryptionAndPrivacyKeysOfManagedFlooding {
    NSData *result1 = [OpenSSLHelper.share calculateK2WithN:[LibTools nsstringToHex:@"7dd7364cd842ad18c17c2b820c84c3d6"] andP:[LibTools nsstringToHex:@"00"]];
    /*
     NID:68
     EncryptionKey: 0953fa93e7caac9638f58820220a398e
     PrivacyKey: 4c715bd4a64b938f99b453351653124f
     */
    NSData *result2 = [LibTools nsstringToHex:@"680953fa93e7caac9638f58820220a398e8b84eedec100067d670971dd2aa700cf"];
    XCTAssertEqualObjects(result1, result2);
}

/// 8.2.3 Encryption and privacy keys (friendship) （参数k2 s1(smk2) 、k2 T、k2 T0、k2 T1、k2 T2、k2 T3为内部计算出的参数，不return到外部）
- (void)testEncryptionAndPrivacyKeysOfFriendship {
    NSData *result1 = [OpenSSLHelper.share calculateK2WithN:[LibTools nsstringToHex:@"7dd7364cd842ad18c17c2b820c84c3d6"] andP:[LibTools nsstringToHex:@"01120123450000072f"]];
    /*
     NID:5e
     EncryptionKey: be635105434859f484fc798e043ce40e
     PrivacyKey: 5d396d4b54d3cbafe943e051fe9a4eb8
     */
    NSData *result2 = [LibTools nsstringToHex:@"5ebe635105434859f484fc798e043ce40e5d396d4b54d3cbafe943e051fe9a4eb8"];
    XCTAssertEqualObjects(result1, result2);
}

/// 8.2.4 Encryption and privacy keys (Directed)（参数k2 s1(smk2) 、k2 T、k2 T0、k2 T1、k2 T2、k2 T3为内部计算出的参数，不return到外部）
- (void)testEncryptionAndPrivacyKeysOfDirected {
    NSData *result1 = [OpenSSLHelper.share calculateK2WithN:[LibTools nsstringToHex:@"7dd7364cd842ad18c17c2b820c84c3d6"] andP:[LibTools nsstringToHex:@"02"]];
    /*
     NID:0d
     EncryptionKey: b47a02c6cc9b4ac4cb9b88e765c9ade4
     PrivacyKey: 9bf7ab5a5ad415fbd77e07bb808f4865
     */
    NSData *result2 = [LibTools nsstringToHex:@"0db47a02c6cc9b4ac4cb9b88e765c9ade49bf7ab5a5ad415fbd77e07bb808f4865"];
    XCTAssertEqualObjects(result1, result2);
}

/// 8.2.5 Network ID（参数k3 SALT、k3 T、k3 CMAC(“id64”||0x01)为内部计算出的参数，不return到外部）
- (void)testNetworkID {
    NSData *result1 = [OpenSSLHelper.share calculateK3WithN:[LibTools nsstringToHex:@"7dd7364cd842ad18c17c2b820c84c3d6"]];
    NSData *result2 = [LibTools nsstringToHex:@"3ecaff672f673370"];
    XCTAssertEqualObjects(result1, result2);
}

/// 8.2.6 IdentityKey （参数K1 T为内部计算出的参数，不return到外部）
- (void)testIdentityKey {
    NSData *result1 = [OpenSSLHelper.share calculateK1WithN:[LibTools nsstringToHex:@"7dd7364cd842ad18c17c2b820c84c3d6"] salt:[LibTools nsstringToHex:@"f8795a1aabf182e4f163d86e245e19f4"] andP:[LibTools nsstringToHex:@"696431323801"]];
    NSData *result2 = [LibTools nsstringToHex:@"84396c435ac48560b5965385253e210c"];
    XCTAssertEqualObjects(result1, result2);
}

/// 8.2.7 BeaconKey （参数K1 T为内部计算出的参数，不return到外部）
- (void)testBeaconKey {
    NSData *result1 = [OpenSSLHelper.share calculateK1WithN:[LibTools nsstringToHex:@"7dd7364cd842ad18c17c2b820c84c3d6"] salt:[LibTools nsstringToHex:@"2c24619ab793c1233f6e226738393dec"] andP:[LibTools nsstringToHex:@"696431323801"]];
    NSData *result2 = [LibTools nsstringToHex:@"5423d967da639a99cb02231a83f7d254"];
    XCTAssertEqualObjects(result1, result2);
}

/// 8.2.8 PrivateBeaconKey, 8.2.8.1 Sample #1 （参数K1 T为内部计算出的参数，不return到外部）
- (void)testPrivateBeaconKeySample1 {
    NSData *result1 = [OpenSSLHelper.share calculateK1WithN:[LibTools nsstringToHex:@"3bbb6f1fbd53e157417f308ce7aec58f"] salt:[LibTools nsstringToHex:@"2c8b71fb5d95e86cfb753bfee3ab934f"] andP:[LibTools nsstringToHex:@"696431323801"]];
    NSData *result2 = [LibTools nsstringToHex:@"ca478cdac626b7a8522d7272dd124f26"];
    XCTAssertEqualObjects(result1, result2);
}

/// 8.2.8 PrivateBeaconKey, 8.2.8.2 Sample #2 （参数K1 T为内部计算出的参数，不return到外部）
- (void)testPrivateBeaconKeySample2 {
    NSData *result1 = [OpenSSLHelper.share calculateK1WithN:[LibTools nsstringToHex:@"db662f48d477740621f5e301cdd69611"] salt:[LibTools nsstringToHex:@"2c8b71fb5d95e86cfb753bfee3ab934f"] andP:[LibTools nsstringToHex:@"696431323801"]];
    NSData *result2 = [LibTools nsstringToHex:@"0f30694a3a91b616a48a54701053cb90"];
    XCTAssertEqualObjects(result1, result2);
}


/*
 1. message#1#2#3#4#5#7#9#10#12#14
 Transport Control Message->UpperTransportControlPDU->LowerTransportUnsegmentedControlPDU->NetworkPDU
 2. message#6#8(重发segment1的数据包)#19(只有一个segment)#20(同前)#24(vendor command)
 Access Payload->UpperTransportAccessPDU->LowerTransportSegmentedAccessPDU->NetworkPDU
 3. message#16#18#21(vendor command)#22(同前)#23(同前)
 Access Payload->UpperTransportAccessPDU->LowerTransportUnsegmentedAccessPDU->NetworkPDU
 4. message#11#13#15#17
 ->NetworkPDU

 */

/*该测试单元的XCTAssertEqualObjects有可能不准确，所以加上XCTAssert(NO);进行辅助判断！*/
/*最好直接跑整个类的测试单元，而不是只跑当前一个测试方法*/
/// 8.3.6 Message #6, A Configuration Client sends a Config AppKey Add message to the Low Power node. This message is sent in two segments.
- (void)testMeshMessage6 {
    [SDKLibCommand startMeshSDK];
    SigDataSource *defaultMesh = [[SigDataSource alloc] initDefaultMesh];
    defaultMesh.ivIndex = @"12345678";
    [defaultMesh setLocationSno:0x3129ab];
    SigNetkeyModel *netkeyModel = defaultMesh.netKeys.firstObject;
    netkeyModel.key = @"7dd7364cd842ad18c17c2b820c84c3d6".uppercaseString;
    netkeyModel.index = 0x456;
    SigAppkeyModel *appkeyModel = defaultMesh.appKeys.firstObject;
    appkeyModel.key = @"63964771734fbd76e3b40519d1d94a48".uppercaseString;
    appkeyModel.index = 0x123;
    appkeyModel.boundNetKey = 0x456;
    SigNodeModel *provisionerNode = defaultMesh.curLocationNodeModel;
    [provisionerNode setAddress:3];
    provisionerNode.defaultTTL = 4;//先取provisionerNode的ttl，如果该ttl无效，再取SigMeshLib.share.defaultTtl。
    SigNodeModel *node = [[SigNodeModel alloc] init];
    [node setAddress:0x1201];
    node.deviceKey = @"9d6dd0e96eb25dc19a40ed9914f8f03f";
    [defaultMesh.nodes addObject:node];
    SigMeshLib.share.defaultTtl = 4;//先取provisionerNode的ttl，如果该ttl无效，再取SigMeshLib.share.defaultTtl。
    SigMeshLib.share.dataSource = defaultMesh;
    SigMeshLib.share.dataSource.unicastAddressOfConnected = node.address;

    [SDKLibCommand configAppKeyAddWithDestination:node.address appkeyModel:appkeyModel retryCount:0 responseMaxCount:1 successCallback:^(UInt16 source, UInt16 destination, SigConfigAppKeyStatus * _Nonnull responseMessage) {

    } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *accessPayload1 = SigNetworkManager.share.accessLayer.accessPdu.accessPdu;
            NSData *accessPayload2 = [LibTools nsstringToHex:@"0056341263964771734fbd76e3b40519d1d94a48"];
            XCTAssertEqualObjects(accessPayload1, accessPayload2);
            NSData *upperTransportPDU1 = SigNetworkManager.share.upperTransportLayer.upperTransportPdu.transportPdu;
            NSData *upperTransportPDU2 = [LibTools nsstringToHex:@"ee9dddfd2169326d23f3afdfcfdc18c52fdef772e0e17308"];
            XCTAssertEqualObjects(upperTransportPDU1, upperTransportPDU2);
            NSLog(@"accessPayload1=%@,accessPayload2=%@",accessPayload1,accessPayload2);
            NSLog(@"upperTransportPDU1=%@,upperTransportPDU2=%@",upperTransportPDU1,upperTransportPDU2);

            if (SigNetworkManager.share.lowerTransportLayer.outgoingSegments && SigNetworkManager.share.lowerTransportLayer.outgoingSegments.count) {
                NSArray *array = [NSArray arrayWithArray:SigNetworkManager.share.lowerTransportLayer.outgoingSegments.allValues.firstObject];
                for (SigSegmentedAccessMessage *segmentedAccessMessage in array) {
                    if ([array indexOfObject:segmentedAccessMessage] == 0) {
                        NSData *upperTransportPDUSegment1 = segmentedAccessMessage.upperTransportPdu;
                        NSData *upperTransportPDUSegment2 = [LibTools nsstringToHex:@"ee9dddfd2169326d23f3afdf"];
                        XCTAssertEqualObjects(upperTransportPDUSegment1, upperTransportPDUSegment2);
                        NSData *LowerTransportPDUSegment1 = segmentedAccessMessage.transportPdu;
                        NSData *LowerTransportPDUSegment2 = [LibTools nsstringToHex:@"8026ac01ee9dddfd2169326d23f3afdf"];
                        XCTAssertEqualObjects(LowerTransportPDUSegment1, LowerTransportPDUSegment2);
                        NSData *networkPduSegment1 = segmentedAccessMessage.networkPdu.pduData;
                        NSData *networkPduSegment2 = [LibTools nsstringToHex:@"68cab5c5348a230afba8c63d4e686364979deaf4fd40961145939cda0e"];
                        XCTAssertEqualObjects(networkPduSegment1, networkPduSegment2);

                        NSLog(@"upperTransportPDUSegment1=%@,upperTransportPDUSegment2=%@",upperTransportPDUSegment1,upperTransportPDUSegment2);
                        NSLog(@"LowerTransportPDUSegment1=%@,LowerTransportPDUSegment2=%@",LowerTransportPDUSegment1,LowerTransportPDUSegment2);
                        NSLog(@"networkPduSegment1=%@,networkPduSegment2=%@",networkPduSegment1,networkPduSegment2);
                        BOOL upperTransportPDUSegmentResult = [upperTransportPDUSegment1 isEqualToData:upperTransportPDUSegment2];
                        XCTAssert(upperTransportPDUSegmentResult);
                        BOOL LowerTransportPDUSegmentResult = [LowerTransportPDUSegment1 isEqualToData:LowerTransportPDUSegment2];
                        XCTAssert(LowerTransportPDUSegmentResult);
                        BOOL networkPduSegmentResult = [networkPduSegment1 isEqualToData:networkPduSegment2];
                        XCTAssert(networkPduSegmentResult);
                        if (!upperTransportPDUSegmentResult || !LowerTransportPDUSegmentResult || !networkPduSegmentResult) {
                            XCTAssert(NO);
                        }
                    }
                    if ([array indexOfObject:segmentedAccessMessage] == 1) {
                        NSData *upperTransportPDUSegment1 = segmentedAccessMessage.upperTransportPdu;
                        NSData *upperTransportPDUSegment2 = [LibTools nsstringToHex:@"cfdc18c52fdef772e0e17308"];
                        XCTAssertEqualObjects(upperTransportPDUSegment1, upperTransportPDUSegment2);
                        NSData *LowerTransportPDUSegment1 = segmentedAccessMessage.transportPdu;
                        NSData *LowerTransportPDUSegment2 = [LibTools nsstringToHex:@"8026ac21cfdc18c52fdef772e0e17308"];
                        XCTAssertEqualObjects(LowerTransportPDUSegment1, LowerTransportPDUSegment2);
                        NSData *networkPduSegment1 = segmentedAccessMessage.networkPdu.pduData;
                        NSData *networkPduSegment2 = [LibTools nsstringToHex:@"681615b5dd4a846cae0c032bf0746f44f1b8cc8ce5edc57e55beed49c0"];
                        XCTAssertEqualObjects(networkPduSegment1, networkPduSegment2);

                        NSLog(@"upperTransportPDUSegment1=%@,upperTransportPDUSegment2=%@",upperTransportPDUSegment1,upperTransportPDUSegment2);
                        NSLog(@"LowerTransportPDUSegment1=%@,LowerTransportPDUSegment2=%@",LowerTransportPDUSegment1,LowerTransportPDUSegment2);
                        NSLog(@"networkPduSegment1=%@,networkPduSegment2=%@",networkPduSegment1,networkPduSegment2);
                        BOOL upperTransportPDUSegmentResult = [upperTransportPDUSegment1 isEqualToData:upperTransportPDUSegment2];
                        XCTAssert(upperTransportPDUSegmentResult);
                        BOOL LowerTransportPDUSegmentResult = [LowerTransportPDUSegment1 isEqualToData:LowerTransportPDUSegment2];
                        XCTAssert(LowerTransportPDUSegmentResult);
                        BOOL networkPduSegmentResult = [networkPduSegment1 isEqualToData:networkPduSegment2];
                        XCTAssert(networkPduSegmentResult);
                        if (!upperTransportPDUSegmentResult || !LowerTransportPDUSegmentResult || !networkPduSegmentResult) {
                            XCTAssert(NO);
                        }
                    }
                }
            }

            BOOL accessPayloadResult = [accessPayload1 isEqualToData:accessPayload2];
            XCTAssert(accessPayloadResult);
            BOOL upperTransportPDUResult = [upperTransportPDU1 isEqualToData:upperTransportPDU2];
            XCTAssert(upperTransportPDUResult);
            if (!accessPayloadResult || !upperTransportPDUResult) {
                XCTAssert(NO);
            }
        });
    }];
}

/// 8.3.24 Message #24, The Low Power node sends a vendor command to a virtual address using a 64-bit TransMIC..
- (void)testMeshMessage24 {
    [SDKLibCommand startMeshSDK];
    SigDataSource *defaultMesh = [[SigDataSource alloc] initDefaultMesh];
    defaultMesh.ivIndex = @"12345677";
    [defaultMesh setLocationSno:0x7080d];
    defaultMesh.security = SigMeshMessageSecurityHigh;
    SigNetkeyModel *netkeyModel = defaultMesh.netKeys.firstObject;
    netkeyModel.key = @"7dd7364cd842ad18c17c2b820c84c3d6".uppercaseString;
//    netkeyModel.index = 0x456;
    SigAppkeyModel *appkeyModel = defaultMesh.appKeys.firstObject;
    appkeyModel.key = @"63964771734fbd76e3b40519d1d94a48".uppercaseString;
//    appkeyModel.index = 0x123;
//    appkeyModel.boundNetKey = 0x456;
    SigNodeModel *provisionerNode = defaultMesh.curLocationNodeModel;
    [provisionerNode setAddress:0x1234];
    provisionerNode.defaultTTL = 3;//先取provisionerNode的ttl，如果该ttl无效，再取SigMeshLib.share.defaultTtl。
    SigNodeModel *node = [[SigNodeModel alloc] init];
    [node setAddress:0x9736];
    [defaultMesh.nodes addObject:node];
    SigMeshLib.share.defaultTtl = 3;//先取provisionerNode的ttl，如果该ttl无效，再取SigMeshLib.share.defaultTtl。
    SigMeshLib.share.dataSource = defaultMesh;
    SigMeshLib.share.dataSource.unicastAddressOfConnected = node.address;
    SigMeshLib.share.dataSource.curNetkeyModel.ivIndex.index = [LibTools uint32From16String:defaultMesh.ivIndex];

    IniCommandModel *m = [[IniCommandModel alloc] initVendorModelIniCommandWithNetkeyIndex:defaultMesh.curNetkeyModel.index appkeyIndex:defaultMesh.curAppkeyModel.index retryCount:0 responseMax:1 address:node.address opcode:0x2A vendorId:0xA responseOpcode:0x2B needTid:NO tid:0 commandData:[LibTools nsstringToHex:@"576f726c64"]];
    m.curAppkey = defaultMesh.curAppkeyModel;
    m.curNetkey = defaultMesh.curNetkeyModel;
    m.curIvIndex = SigMeshLib.share.dataSource.curNetkeyModel.ivIndex;
    m.meshAddressModel = [[SigMeshAddress alloc] initWithVirtualLabel:[CBUUID UUIDWithString:[LibTools UUIDToMeshUUID:@"f4a002c7fb1e4ca0a469a021de0db875"]]];
    [SDKLibCommand sendIniCommandModel:m successCallback:^(UInt16 source, UInt16 destination, SigMeshMessage * _Nonnull responseMessage) {

    } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *accessPayload1 = SigNetworkManager.share.accessLayer.accessPdu.accessPdu;
            NSData *accessPayload2 = [LibTools nsstringToHex:@"ea0a00576f726c64"];
            XCTAssertEqualObjects(accessPayload1, accessPayload2);
            NSData *upperTransportPDU1 = SigNetworkManager.share.upperTransportLayer.upperTransportPdu.transportPdu;
            NSData *upperTransportPDU2 = [LibTools nsstringToHex:@"ee9dddfd2169326d23f3afdfcfdc18c52fdef772e0e17308"];
            XCTAssertEqualObjects(upperTransportPDU1, upperTransportPDU2);
            NSLog(@"accessPayload1=%@,accessPayload2=%@",accessPayload1,accessPayload2);
            NSLog(@"upperTransportPDU1=%@,upperTransportPDU2=%@",upperTransportPDU1,upperTransportPDU2);

            if (SigNetworkManager.share.lowerTransportLayer.outgoingSegments && SigNetworkManager.share.lowerTransportLayer.outgoingSegments.count) {
                NSArray *array = [NSArray arrayWithArray:SigNetworkManager.share.lowerTransportLayer.outgoingSegments.allValues.firstObject];
                for (SigSegmentedAccessMessage *segmentedAccessMessage in array) {
                    if ([array indexOfObject:segmentedAccessMessage] == 0) {
                        NSData *upperTransportPDUSegment1 = segmentedAccessMessage.upperTransportPdu;
                        NSData *upperTransportPDUSegment2 = [LibTools nsstringToHex:@"ee9dddfd2169326d23f3afdf"];
                        XCTAssertEqualObjects(upperTransportPDUSegment1, upperTransportPDUSegment2);
                        NSData *LowerTransportPDUSegment1 = segmentedAccessMessage.transportPdu;
                        NSData *LowerTransportPDUSegment2 = [LibTools nsstringToHex:@"8026ac01ee9dddfd2169326d23f3afdf"];
                        XCTAssertEqualObjects(LowerTransportPDUSegment1, LowerTransportPDUSegment2);
                        NSData *networkPduSegment1 = segmentedAccessMessage.networkPdu.pduData;
                        NSData *networkPduSegment2 = [LibTools nsstringToHex:@"68cab5c5348a230afba8c63d4e686364979deaf4fd40961145939cda0e"];
                        XCTAssertEqualObjects(networkPduSegment1, networkPduSegment2);

                        NSLog(@"upperTransportPDUSegment1=%@,upperTransportPDUSegment2=%@",upperTransportPDUSegment1,upperTransportPDUSegment2);
                        NSLog(@"LowerTransportPDUSegment1=%@,LowerTransportPDUSegment2=%@",LowerTransportPDUSegment1,LowerTransportPDUSegment2);
                        NSLog(@"networkPduSegment1=%@,networkPduSegment2=%@",networkPduSegment1,networkPduSegment2);
                        BOOL upperTransportPDUSegmentResult = [upperTransportPDUSegment1 isEqualToData:upperTransportPDUSegment2];
                        XCTAssert(upperTransportPDUSegmentResult);
                        BOOL LowerTransportPDUSegmentResult = [LowerTransportPDUSegment1 isEqualToData:LowerTransportPDUSegment2];
                        XCTAssert(LowerTransportPDUSegmentResult);
                        BOOL networkPduSegmentResult = [networkPduSegment1 isEqualToData:networkPduSegment2];
                        XCTAssert(networkPduSegmentResult);
                        if (!upperTransportPDUSegmentResult || !LowerTransportPDUSegmentResult || !networkPduSegmentResult) {
                            XCTAssert(NO);
                        }
                    }
                    if ([array indexOfObject:segmentedAccessMessage] == 1) {
                        NSData *upperTransportPDUSegment1 = segmentedAccessMessage.upperTransportPdu;
                        NSData *upperTransportPDUSegment2 = [LibTools nsstringToHex:@"cfdc18c52fdef772e0e17308"];
                        XCTAssertEqualObjects(upperTransportPDUSegment1, upperTransportPDUSegment2);
                        NSData *LowerTransportPDUSegment1 = segmentedAccessMessage.transportPdu;
                        NSData *LowerTransportPDUSegment2 = [LibTools nsstringToHex:@"8026ac21cfdc18c52fdef772e0e17308"];
                        XCTAssertEqualObjects(LowerTransportPDUSegment1, LowerTransportPDUSegment2);
                        NSData *networkPduSegment1 = segmentedAccessMessage.networkPdu.pduData;
                        NSData *networkPduSegment2 = [LibTools nsstringToHex:@"681615b5dd4a846cae0c032bf0746f44f1b8cc8ce5edc57e55beed49c0"];
                        XCTAssertEqualObjects(networkPduSegment1, networkPduSegment2);

                        NSLog(@"upperTransportPDUSegment1=%@,upperTransportPDUSegment2=%@",upperTransportPDUSegment1,upperTransportPDUSegment2);
                        NSLog(@"LowerTransportPDUSegment1=%@,LowerTransportPDUSegment2=%@",LowerTransportPDUSegment1,LowerTransportPDUSegment2);
                        NSLog(@"networkPduSegment1=%@,networkPduSegment2=%@",networkPduSegment1,networkPduSegment2);
                        BOOL upperTransportPDUSegmentResult = [upperTransportPDUSegment1 isEqualToData:upperTransportPDUSegment2];
                        XCTAssert(upperTransportPDUSegmentResult);
                        BOOL LowerTransportPDUSegmentResult = [LowerTransportPDUSegment1 isEqualToData:LowerTransportPDUSegment2];
                        XCTAssert(LowerTransportPDUSegmentResult);
                        BOOL networkPduSegmentResult = [networkPduSegment1 isEqualToData:networkPduSegment2];
                        XCTAssert(networkPduSegmentResult);
                        if (!upperTransportPDUSegmentResult || !LowerTransportPDUSegmentResult || !networkPduSegmentResult) {
                            XCTAssert(NO);
                        }
                    }
                }
            }

            BOOL accessPayloadResult = [accessPayload1 isEqualToData:accessPayload2];
            XCTAssert(accessPayloadResult);
            BOOL upperTransportPDUResult = [upperTransportPDU1 isEqualToData:upperTransportPDU2];
            XCTAssert(upperTransportPDUResult);
            if (!accessPayloadResult || !upperTransportPDUResult) {
                XCTAssert(NO);
            }
        });
    }];
}

//- (void)testVirtualLabel {
//    NSData *salt = [OpenSSLHelper.share calculateSalt:[@"vtad" dataUsingEncoding:kCFStringEncodingASCII]];
//    NSData *hash = [OpenSSLHelper.share calculateCMAC:[LibTools nsstringToHex:[LibTools meshUUIDToUUID:@"f4a002c7fb1e4ca0a469a021de0db875"]] andKey:salt];
////    NSData *hash = [OpenSSLHelper.share calculateCMAC:[LibTools turnOverData:[LibTools nsstringToHex:[LibTools meshUUIDToUUID:@"f4a002c7fb1e4ca0a469a021de0db875"]]] andKey:salt];
//    UInt16 address = CFSwapInt16HostToBig([LibTools uint16FromBytes:[hash subdataWithRange:NSMakeRange(14, 2)]]);
//    address |= 0x8000;
//    address &= 0xBFFF;
//    XCTAssertEqual(address, 0x9736);
//}

/// 8.3.16 Message #16, The Low Power node has now received the complete Config AppKey Add message, so it responds to the segmented message with a status message. This is sent directly to the Configuration Client.
- (void)testMeshMessage16 {
    [SDKLibCommand startMeshSDK];
    SigDataSource *defaultMesh = [[SigDataSource alloc] initDefaultMesh];
    defaultMesh.ivIndex = @"12345678";
    [defaultMesh setLocationSno:0x000006];
    SigNetkeyModel *netkeyModel = defaultMesh.netKeys.firstObject;
    netkeyModel.key = @"7dd7364cd842ad18c17c2b820c84c3d6".uppercaseString;
    netkeyModel.index = 0x123;
    SigAppkeyModel *appkeyModel = defaultMesh.appKeys.firstObject;
    appkeyModel.key = @"63964771734fbd76e3b40519d1d94a48".uppercaseString;
    appkeyModel.index = 0x456;
    appkeyModel.boundNetKey = 0x123;
    SigNodeModel *provisionerNode = defaultMesh.curLocationNodeModel;
    [provisionerNode setAddress:0x1201];
    provisionerNode.defaultTTL = 0x0b;//先取provisionerNode的ttl，如果该ttl无效，再取SigMeshLib.share.defaultTtl。
    SigNodeModel *node = [[SigNodeModel alloc] init];
    [node setAddress:0x0003];
    node.deviceKey = @"9d6dd0e96eb25dc19a40ed9914f8f03f";
    [defaultMesh.nodes addObject:node];
    SigMeshLib.share.defaultTtl = 0x0b;//先取provisionerNode的ttl，如果该ttl无效，再取SigMeshLib.share.defaultTtl。
    SigMeshLib.share.dataSource = defaultMesh;
    SigMeshLib.share.dataSource.unicastAddressOfConnected = node.address;
    
    IniCommandModel *m = [[IniCommandModel alloc] initSigModelIniCommandWithNetkeyIndex:defaultMesh.curNetkeyModel.index appkeyIndex:defaultMesh.curAppkeyModel.index retryCount:0 responseMax:0 address:node.address opcode:SigOpCode_configAppKeyStatus commandData:[LibTools nsstringToHex:@"00563412"]];
    m.curAppkey = defaultMesh.curAppkeyModel;
    m.curNetkey = defaultMesh.curNetkeyModel;
    m.curIvIndex = SigMeshLib.share.dataSource.curNetkeyModel.ivIndex;
    m.meshAddressModel = [[SigMeshAddress alloc] initWithAddress:node.address];
    m.isEncryptByDeviceKey = YES;
    [SDKLibCommand sendIniCommandModel:m successCallback:^(UInt16 source, UInt16 destination, SigMeshMessage * _Nonnull responseMessage) {
        
    } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *accessPayload1 = SigNetworkManager.share.accessLayer.accessPdu.accessPdu;
            NSData *accessPayload2 = [LibTools nsstringToHex:@"800300563412"];
            XCTAssertEqualObjects(accessPayload1, accessPayload2);
            NSData *upperTransportPDU1 = SigNetworkManager.share.upperTransportLayer.upperTransportPdu.transportPdu;
            NSData *upperTransportPDU2 = [LibTools nsstringToHex:@"89511bf1d1a81c11dcef"];
            XCTAssertEqualObjects(upperTransportPDU1, upperTransportPDU2);
            NSLog(@"accessPayload1=%@,accessPayload2=%@",accessPayload1,accessPayload2);
            NSLog(@"upperTransportPDU1=%@,upperTransportPDU2=%@",upperTransportPDU1,upperTransportPDU2);
            
//            if (SigNetworkManager.share.lowerTransportLayer.outgoingSegments && SigNetworkManager.share.lowerTransportLayer.outgoingSegments.count) {
//                NSArray *array = [NSArray arrayWithArray:SigNetworkManager.share.lowerTransportLayer.outgoingSegments.allValues.firstObject];
//                for (SigSegmentedAccessMessage *segmentedAccessMessage in array) {
//                    if ([array indexOfObject:segmentedAccessMessage] == 0) {
//                        NSData *upperTransportPDUSegment1 = segmentedAccessMessage.upperTransportPdu;
//                        NSData *upperTransportPDUSegment2 = [LibTools nsstringToHex:@"ee9dddfd2169326d23f3afdf"];
//                        XCTAssertEqualObjects(upperTransportPDUSegment1, upperTransportPDUSegment2);
//                        NSData *LowerTransportPDUSegment1 = segmentedAccessMessage.transportPdu;
//                        NSData *LowerTransportPDUSegment2 = [LibTools nsstringToHex:@"8026ac01ee9dddfd2169326d23f3afdf"];
//                        XCTAssertEqualObjects(LowerTransportPDUSegment1, LowerTransportPDUSegment2);
//                        NSData *networkPduSegment1 = segmentedAccessMessage.networkPdu.pduData;
//                        NSData *networkPduSegment2 = [LibTools nsstringToHex:@"68cab5c5348a230afba8c63d4e686364979deaf4fd40961145939cda0e"];
//                        XCTAssertEqualObjects(networkPduSegment1, networkPduSegment2);
//
//                        NSLog(@"upperTransportPDUSegment1=%@,upperTransportPDUSegment2=%@",upperTransportPDUSegment1,upperTransportPDUSegment2);
//                        NSLog(@"LowerTransportPDUSegment1=%@,LowerTransportPDUSegment2=%@",LowerTransportPDUSegment1,LowerTransportPDUSegment2);
//                        NSLog(@"networkPduSegment1=%@,networkPduSegment2=%@",networkPduSegment1,networkPduSegment2);
//                        BOOL upperTransportPDUSegmentResult = [upperTransportPDUSegment1 isEqualToData:upperTransportPDUSegment2];
//                        XCTAssert(upperTransportPDUSegmentResult);
//                        BOOL LowerTransportPDUSegmentResult = [LowerTransportPDUSegment1 isEqualToData:LowerTransportPDUSegment2];
//                        XCTAssert(LowerTransportPDUSegmentResult);
//                        BOOL networkPduSegmentResult = [networkPduSegment1 isEqualToData:networkPduSegment2];
//                        XCTAssert(networkPduSegmentResult);
//                        if (!upperTransportPDUSegmentResult || !LowerTransportPDUSegmentResult || !networkPduSegmentResult) {
//                            XCTAssert(NO);
//                        }
//                    }
//                    if ([array indexOfObject:segmentedAccessMessage] == 1) {
//                        NSData *upperTransportPDUSegment1 = segmentedAccessMessage.upperTransportPdu;
//                        NSData *upperTransportPDUSegment2 = [LibTools nsstringToHex:@"cfdc18c52fdef772e0e17308"];
//                        XCTAssertEqualObjects(upperTransportPDUSegment1, upperTransportPDUSegment2);
//                        NSData *LowerTransportPDUSegment1 = segmentedAccessMessage.transportPdu;
//                        NSData *LowerTransportPDUSegment2 = [LibTools nsstringToHex:@"8026ac21cfdc18c52fdef772e0e17308"];
//                        XCTAssertEqualObjects(LowerTransportPDUSegment1, LowerTransportPDUSegment2);
//                        NSData *networkPduSegment1 = segmentedAccessMessage.networkPdu.pduData;
//                        NSData *networkPduSegment2 = [LibTools nsstringToHex:@"681615b5dd4a846cae0c032bf0746f44f1b8cc8ce5edc57e55beed49c0"];
//                        XCTAssertEqualObjects(networkPduSegment1, networkPduSegment2);
//
//                        NSLog(@"upperTransportPDUSegment1=%@,upperTransportPDUSegment2=%@",upperTransportPDUSegment1,upperTransportPDUSegment2);
//                        NSLog(@"LowerTransportPDUSegment1=%@,LowerTransportPDUSegment2=%@",LowerTransportPDUSegment1,LowerTransportPDUSegment2);
//                        NSLog(@"networkPduSegment1=%@,networkPduSegment2=%@",networkPduSegment1,networkPduSegment2);
//                        BOOL upperTransportPDUSegmentResult = [upperTransportPDUSegment1 isEqualToData:upperTransportPDUSegment2];
//                        XCTAssert(upperTransportPDUSegmentResult);
//                        BOOL LowerTransportPDUSegmentResult = [LowerTransportPDUSegment1 isEqualToData:LowerTransportPDUSegment2];
//                        XCTAssert(LowerTransportPDUSegmentResult);
//                        BOOL networkPduSegmentResult = [networkPduSegment1 isEqualToData:networkPduSegment2];
//                        XCTAssert(networkPduSegmentResult);
//                        if (!upperTransportPDUSegmentResult || !LowerTransportPDUSegmentResult || !networkPduSegmentResult) {
//                            XCTAssert(NO);
//                        }
//                    }
//                }
//            }
            
            if (SigNetworkManager.share.lowerTransportLayer.unSegmentLowerTransportPdu) {
                NSData *networkPduUnSegment1 = SigNetworkManager.share.lowerTransportLayer.unSegmentLowerTransportPdu.networkPdu.pduData;
                NSData *networkPduUnSegment2 = [LibTools nsstringToHex:@"68e80e5da5af0e6b9be7f5a642f2f98680e61c3a8b47f228"];
                XCTAssertEqualObjects(networkPduUnSegment1, networkPduUnSegment2);
            }
            
            BOOL accessPayloadResult = [accessPayload1 isEqualToData:accessPayload2];
            XCTAssert(accessPayloadResult);
            BOOL upperTransportPDUResult = [upperTransportPDU1 isEqualToData:upperTransportPDU2];
            XCTAssert(upperTransportPDUResult);
            if (!accessPayloadResult || !upperTransportPDUResult) {
                XCTAssert(NO);
            }
        });
    }];
}

/*
 MshPRF_EPA_CR_r08.docx
 The following sample data shows a provisioning security functions computation when the Algorithm field is BTM_ECDH_P256_CMAC_AES128_AES_CCM.
 */
- (void)testCMAC_AES128 {
    GMEllipticCurveCrypto *crypto = [GMEllipticCurveCrypto cryptoForKey:[LibTools nsstringToHex:@"06a516693c9aa31a6084545d0c5db641b48572b97203ddffb7ac73f7d0457663"]];
    crypto.compressedPublicKey = NO;
    NSLog(@"crypto.publicKey=%@,crypto.privateKey=%@",[LibTools convertDataToHexStr:crypto.publicKey],[LibTools convertDataToHexStr:crypto.privateKey]);
    
    NSData *devicePublicKey = [LibTools nsstringToHex:@"f465e43ff23d3f1b9dc7dfc04da8758184dbc966204796eccf0d6cf5e16500cc0201d048bcbbd899eeefc424164e33c201c2b010ca6b4d43a8a155cad8ecb279"];
    UInt8 tem = 0x04;
    NSMutableData *devicePublicKeyData = [NSMutableData dataWithBytes:&tem length:1];
    [devicePublicKeyData appendData:devicePublicKey];
    GMEllipticCurveCrypto *deviceKeyCrypto = [GMEllipticCurveCrypto cryptoForKey:devicePublicKeyData];
    deviceKeyCrypto.compressedPublicKey = YES;
    NSData *sharedSecretKeyData = [LibTools nsstringToHex:@"ab85843a2f6d883f62e5684b38e307335fe6e1945ecd19604105c6f23221eb69"];
    NSData *sharedSecretKeyDataResult = [crypto sharedSecretForPublicKey:deviceKeyCrypto.publicKey];
    XCTAssertEqualObjects(sharedSecretKeyData, sharedSecretKeyDataResult);

    NSData *confirmationInputs = [LibTools nsstringToHex:@"00010001000000000000000000000000002c31a47b5779809ef44cb5eaaf5c3e43d5f8faad4a8794cb987e9b03745c78dd919512183898dfbecd52e2408e43871fd021109117bd3ed4eaf8437743715d4ff465e43ff23d3f1b9dc7dfc04da8758184dbc966204796eccf0d6cf5e16500cc0201d048bcbbd899eeefc424164e33c201c2b010ca6b4d43a8a155cad8ecb279"];
    NSData *confirmationSalt = [LibTools nsstringToHex:@"5faabe187337c71cc6c973369dcaa79a"];
    NSData *confirmationSaltResult = [OpenSSLHelper.share calculateSalt:confirmationInputs];
    XCTAssertEqualObjects(confirmationSalt, confirmationSaltResult);

    NSData *confirmationKey = [LibTools nsstringToHex:@"e31fe046c68ec339c425fc6629f0336f"];
    NSData *confirmationKeyResult = [OpenSSLHelper.share calculateK1WithN:sharedSecretKeyData salt:confirmationSalt andP:[@"prck" dataUsingEncoding:NSASCIIStringEncoding]];
    XCTAssertEqualObjects(confirmationKey, confirmationKeyResult);

    NSData *randomProvisioner = [LibTools nsstringToHex:@"8b19ac31d58b124c946209b5db1021b9"];
    NSData *authValue = [LibTools nsstringToHex:@"00000000000000000000000000000000"];
    NSMutableData *confirmationProvisionerInput = [NSMutableData dataWithData:randomProvisioner];
    [confirmationProvisionerInput appendData:authValue];
    NSData *confirmationProvisioner  = [LibTools nsstringToHex:@"b38a114dfdca1fe153bd2c1e0dc46ac2"];
    NSData *confirmationProvisionerResult  = [OpenSSLHelper.share calculateCMAC:confirmationProvisionerInput andKey:confirmationKey];
    XCTAssertEqualObjects(confirmationProvisioner, confirmationProvisionerResult);

    NSData *randomDevice = [LibTools nsstringToHex:@"55a2a2bca04cd32ff6f346bd0a0c1a3a"];
    NSMutableData *confirmationDeviceInput = [NSMutableData dataWithData:randomDevice];
    [confirmationDeviceInput appendData:authValue];
    NSData *confirmationDevice  = [LibTools nsstringToHex:@"eeba521c196b52cc2e37aa40329f554e"];
    NSData *confirmationDeviceResult  = [OpenSSLHelper.share calculateCMAC:confirmationDeviceInput andKey:confirmationKey];
    XCTAssertEqualObjects(confirmationDevice, confirmationDeviceResult);
    
    /*
     The Session key shall be derived using the formula:
     ProvisioningSalt = s1(ConfirmationSalt || RandomProvisioner || RandomDevice)
     SessionKey = k1(ECDHSecret, ProvisioningSalt, “prsk”)
     The nonce shall be the 13 least significant octets of:
     SessionNonce = k1(ECDHSecret, ProvisioningSalt, “prsn”)
     DevKey = k1(ECDHSecret, ProvisioningSalt, “prdk”)
     */
    NSData *provisioningSaltInput = [LibTools nsstringToHex:@"5faabe187337c71cc6c973369dcaa79a8b19ac31d58b124c946209b5db1021b955a2a2bca04cd32ff6f346bd0a0c1a3a"];
    NSData *provisioningSalt = [LibTools nsstringToHex:@"a21c7d45f201cf9489a2fb57145015b4"];
    NSData *provisioningSaltResult = [OpenSSLHelper.share calculateSalt:provisioningSaltInput];
    XCTAssertEqualObjects(provisioningSalt, provisioningSaltResult);

    NSData *sessionKey = [LibTools nsstringToHex:@"c80253af86b33dfa450bbdb2a191fea3"];
    NSData *sessionKeyResult = [OpenSSLHelper.share calculateK1WithN:sharedSecretKeyData salt:provisioningSalt andP:[@"prsk" dataUsingEncoding:NSASCIIStringEncoding]];
    XCTAssertEqualObjects(sessionKey, sessionKeyResult);

    NSData *sessionNonceFull = [LibTools nsstringToHex:@"c5e02eda7ddbe78b5f62b81d6847487e"];
    NSData *sessionNonce = [LibTools nsstringToHex:@"da7ddbe78b5f62b81d6847487e"];
    NSData *sessionNonceResult = [OpenSSLHelper.share calculateK1WithN:sharedSecretKeyData salt:provisioningSalt andP:[@"prsn" dataUsingEncoding:NSASCIIStringEncoding]];
    XCTAssertEqualObjects(sessionNonceFull, sessionNonceResult);
    XCTAssertEqualObjects(sessionNonce, [sessionNonceResult subdataWithRange:NSMakeRange(3, sessionNonceResult.length-3)]);

    NSData *data = [LibTools nsstringToHex:@"efb2255e6422d330088e09bb015ed707056700010203040b0c"];
    NSData *dataEncrypted = [LibTools nsstringToHex:@"d0bd7f4a89a2ff6222af59a90a60ad58acfe3123356f5cec29"];
    NSData *dataMIC = [LibTools nsstringToHex:@"73e0ec50783b10c7"];
    NSData *dataEncryptedMIC = [LibTools nsstringToHex:@"d0bd7f4a89a2ff6222af59a90a60ad58acfe3123356f5cec2973e0ec50783b10c7"];
    NSData *dataEncryptedMICResult = [[OpenSSLHelper share] calculateCCM:data withKey:sessionKey nonce:sessionNonce andMICSize:8 withAdditionalData:nil];
    XCTAssertEqualObjects(dataEncryptedMIC, dataEncryptedMICResult);

    NSData *deviceKey = [LibTools nsstringToHex:@"0520adad5e0142aa3e325087b4ec16d8"];
    NSData *deviceKeyResult = [OpenSSLHelper.share calculateK1WithN:sharedSecretKeyData salt:provisioningSalt andP:[@"prdk" dataUsingEncoding:NSASCIIStringEncoding]];
    XCTAssertEqualObjects(deviceKey, deviceKeyResult);
}

/*
 MshPRF_EPA_CR_r08.docx
 The following sample data shows a provisioning security functions computation when the Algorithm field is BTM_ECDH_P256_HMAC_SHA256_AES_CCM.
 */
- (void)testHMAC_SHA256 {
    NSData *authValue = [LibTools nsstringToHex:@"906d73a3c7a7cb3ff730dca68a46b9c18d673f50e078202311473ebbe253669f"];

    GMEllipticCurveCrypto *crypto = [GMEllipticCurveCrypto cryptoForKey:[LibTools nsstringToHex:@"06a516693c9aa31a6084545d0c5db641b48572b97203ddffb7ac73f7d0457663"]];
    crypto.compressedPublicKey = NO;
    NSLog(@"crypto.publicKey=%@,crypto.privateKey=%@",[LibTools convertDataToHexStr:crypto.publicKey],[LibTools convertDataToHexStr:crypto.privateKey]);
    
    NSData *devicePublicKey = [LibTools nsstringToHex:@"f465e43ff23d3f1b9dc7dfc04da8758184dbc966204796eccf0d6cf5e16500cc0201d048bcbbd899eeefc424164e33c201c2b010ca6b4d43a8a155cad8ecb279"];
    UInt8 tem = 0x04;
    NSMutableData *devicePublicKeyData = [NSMutableData dataWithBytes:&tem length:1];
    [devicePublicKeyData appendData:devicePublicKey];
    GMEllipticCurveCrypto *deviceKeyCrypto = [GMEllipticCurveCrypto cryptoForKey:devicePublicKeyData];
    deviceKeyCrypto.compressedPublicKey = YES;
    NSData *sharedSecretKeyData = [LibTools nsstringToHex:@"ab85843a2f6d883f62e5684b38e307335fe6e1945ecd19604105c6f23221eb69"];
    NSData *sharedSecretKeyDataResult = [crypto sharedSecretForPublicKey:deviceKeyCrypto.publicKey];
    XCTAssertEqualObjects(sharedSecretKeyData, sharedSecretKeyDataResult);

    NSData *confirmationInputs = [LibTools nsstringToHex:@"00010003000100000000000001000100002c31a47b5779809ef44cb5eaaf5c3e43d5f8faad4a8794cb987e9b03745c78dd919512183898dfbecd52e2408e43871fd021109117bd3ed4eaf8437743715d4ff465e43ff23d3f1b9dc7dfc04da8758184dbc966204796eccf0d6cf5e16500cc0201d048bcbbd899eeefc424164e33c201c2b010ca6b4d43a8a155cad8ecb279"];
    NSData *confirmationSalt = [LibTools nsstringToHex:@"a71141ba8cb6b40f4f52b622e1c091614c73fc308f871b78ca775e769bc3ae69"];
    NSData *confirmationSaltResult = [OpenSSLHelper.share calculateSalt2:confirmationInputs];
    XCTAssertEqualObjects(confirmationSalt, confirmationSaltResult);

    NSData *confirmationKey = [LibTools nsstringToHex:@"210c3c448152e8d59ef742aa7d22ee5ba59a38648bda6bf05c74f3e46fc2c0bb"];
    NSMutableData *n = [NSMutableData dataWithData:sharedSecretKeyData];
    [n appendData:authValue];
    NSData *confirmationKeyResult = [OpenSSLHelper.share calculateK5WithN:n salt:confirmationSalt andP:[@"prck256" dataUsingEncoding:NSASCIIStringEncoding]];
    XCTAssertEqualObjects(confirmationKey, confirmationKeyResult);

    NSData *randomProvisioner = [LibTools nsstringToHex:@"36f968b94a13000e64b223576390db6bcc6d62f02617c369ee3f5b3e89df7e1f"];
    NSData *confirmationProvisioner  = [LibTools nsstringToHex:@"c99b54617ae646f5f32cf7e1ea6fcc49fd69066078eba9580fa6c7031833e6c8"];
    NSData *confirmationProvisionerResult  = [OpenSSLHelper.share calculateHMAC_SHA256:randomProvisioner andKey:confirmationKey];
    XCTAssertEqualObjects(confirmationProvisioner, confirmationProvisionerResult);

    NSData *randomDevice = [LibTools nsstringToHex:@"5b9b1fc6a64b2de8bece53187ee989c6566db1fc7dc8580a73dafdd6211d56a5"];
    NSData *confirmationDevice  = [LibTools nsstringToHex:@"56e3722d291373d38c995d6f942c02928c96abb015c233557d7974b6e2df662b"];
    NSData *confirmationDeviceResult  = [OpenSSLHelper.share calculateHMAC_SHA256:randomDevice andKey:confirmationKey];
    XCTAssertEqualObjects(confirmationDevice, confirmationDeviceResult);
    
    /*
     The Session key shall be derived using the formula:
     ProvisioningSalt = s1(ConfirmationSalt || RandomProvisioner || RandomDevice)
     SessionKey = k1(ECDHSecret, ProvisioningSalt, “prsk”)
     The nonce shall be the 13 least significant octets of:
     SessionNonce = k1(ECDHSecret, ProvisioningSalt, “prsn”)
     DevKey = k1(ECDHSecret, ProvisioningSalt, “prdk”)
     */
    NSData *provisioningSaltInput = [LibTools nsstringToHex:@"a71141ba8cb6b40f4f52b622e1c091614c73fc308f871b78ca775e769bc3ae6936f968b94a13000e64b223576390db6bcc6d62f02617c369ee3f5b3e89df7e1f5b9b1fc6a64b2de8bece53187ee989c6566db1fc7dc8580a73dafdd6211d56a5"];
    NSData *provisioningSalt = [LibTools nsstringToHex:@"d1cb10ad8d51286067e348fc4b692122"];
    NSData *provisioningSaltResult = [OpenSSLHelper.share calculateSalt:provisioningSaltInput];
    XCTAssertEqualObjects(provisioningSalt, provisioningSaltResult);

    NSData *sessionKey = [LibTools nsstringToHex:@"df4a494da3d45405e402f1d6a6cea338"];
    NSData *sessionKeyResult = [OpenSSLHelper.share calculateK1WithN:sharedSecretKeyData salt:provisioningSalt andP:[@"prsk" dataUsingEncoding:NSASCIIStringEncoding]];
    XCTAssertEqualObjects(sessionKey, sessionKeyResult);

    NSData *sessionNonceFull = [LibTools nsstringToHex:@"caee0611b987db2ae41fbb9e96b80446"];
    NSData *sessionNonce = [LibTools nsstringToHex:@"11b987db2ae41fbb9e96b80446"];
    NSData *sessionNonceResult = [OpenSSLHelper.share calculateK1WithN:sharedSecretKeyData salt:provisioningSalt andP:[@"prsn" dataUsingEncoding:NSASCIIStringEncoding]];
    XCTAssertEqualObjects(sessionNonceFull, sessionNonceResult);
    XCTAssertEqualObjects(sessionNonce, [sessionNonceResult subdataWithRange:NSMakeRange(3, sessionNonceResult.length-3)]);

    NSData *data = [LibTools nsstringToHex:@"efb2255e6422d330088e09bb015ed707056700010203040b0c"];
    NSData *dataEncrypted = [LibTools nsstringToHex:@"f9df98cbb736be1f600659ac4c37821a82db31e410a03de769"];
    NSData *dataMIC = [LibTools nsstringToHex:@"3a2a0428fbdaf321"];
    NSData *dataEncryptedMIC = [LibTools nsstringToHex:@"f9df98cbb736be1f600659ac4c37821a82db31e410a03de7693a2a0428fbdaf321"];
    NSData *dataEncryptedMICResult = [[OpenSSLHelper share] calculateCCM:data withKey:sessionKey nonce:sessionNonce andMICSize:8 withAdditionalData:nil];
    XCTAssertEqualObjects(dataEncryptedMIC, dataEncryptedMICResult);
    
    NSData *deviceKey = [LibTools nsstringToHex:@"2770852a737cf05d8813768f22af3a2d"];
    NSData *deviceKeyResult = [OpenSSLHelper.share calculateK1WithN:sharedSecretKeyData salt:provisioningSalt andP:[@"prdk" dataUsingEncoding:NSASCIIStringEncoding]];
    XCTAssertEqualObjects(deviceKey, deviceKeyResult);

}

- (void)testSigOpcodesAggregatorSequence {
    SigOpcodesAggregatorItemModel *model1 = [[SigOpcodesAggregatorItemModel alloc] initWithSigMeshMessage:[[SigGenericOnOffGet alloc] init]];
    SigOpcodesAggregatorItemModel *model2 = [[SigOpcodesAggregatorItemModel alloc] initWithSigMeshMessage:[[SigLightCTLGet alloc] init]];
    SigOpcodesAggregatorItemModel *model3 = [[SigOpcodesAggregatorItemModel alloc] initWithSigMeshMessage:[[SigLightHSLGet alloc] init]];
    NSArray *items = @[model1,model2,model3];
    SigOpcodesAggregatorSequence *message = [[SigOpcodesAggregatorSequence alloc] initWithElementAddress:0x0002 items:items];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [SDKLibCommand sendSigOpcodesAggregatorSequenceMessage:message retryCount:SigMeshLib.share.dataSource.defaultRetryCount responseMaxCount:items.count successCallback:^(UInt16 source, UInt16 destination, SigOpcodesAggregatorStatus * _Nonnull responseMessage) {
        TeLogInfo(@"SigOpcodesAggregatorSequence=%@,source=%d,destination=%d",[LibTools convertDataToHexStr:responseMessage.parameters],source,destination);
    } resultCallback:^(BOOL isResponseAll, NSError * _Nullable error) {
        TeLogInfo(@"isResponseAll=%d,error=%@",isResponseAll,error);
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self createSigOpcodesAggregatorStatus];
    });
    //Most provide 3 seconds to firmwareDistributionReceiversGet every node.
    dispatch_semaphore_wait(semaphore, (dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 60.0))));
}

- (void)createSigOpcodesAggregatorStatus {
    SigOpcodesAggregatorItemModel *model1 = [[SigOpcodesAggregatorItemModel alloc] initWithSigMeshMessage:[[SigGenericOnOffStatus alloc] initWithIsOn:YES targetState:YES remainingTime:nil]];
    SigOpcodesAggregatorItemModel *model2 = [[SigOpcodesAggregatorItemModel alloc] initWithSigMeshMessage:[[SigLightCTLStatus alloc] initWithPresentCTLLightness:[LibTools lumToLightness:100] presentCTLTemperature:[LibTools temp100ToTemp:100] targetCTLLightness:[LibTools lumToLightness:100] targetCTLTemperature:[LibTools temp100ToTemp:100] remainingTime:nil]];
    SigOpcodesAggregatorItemModel *model3 = [[SigOpcodesAggregatorItemModel alloc] initWithSigMeshMessage:[[SigLightHSLStatus alloc] initWithHSLLightness:[LibTools lumToLightness:100] HSLHue:[LibTools lumToLightness:100] HSLSaturation:[LibTools lumToLightness:100] remainingTime:nil]];
    NSArray *items = @[model1,model2,model3];
    SigOpcodesAggregatorStatus *responseMessage = [[SigOpcodesAggregatorStatus alloc] initWithStatus:SigConfigMessageStatus_success elementAddress:0x0002 items:items];
    dispatch_async(SigMeshLib.share.delegateQueue, ^{
        if ([SigMeshLib.share.delegate respondsToSelector:@selector(didReceiveMessage:sentFromSource:toDestination:)]) {
            [SigMeshLib.share.delegate didReceiveMessage:responseMessage sentFromSource:0x0002 toDestination:SigMeshLib.share.dataSource.curLocationNodeModel.address];
        }
    });
}

- (void)testMeshPrivateBeacon1 {
    SigNetkeyModel *model = [[SigNetkeyModel alloc] init];
    model.key = @"f7a2a44f8e8a8029064f173ddc1e2b00";
    SigMeshPrivateBeacon *beacon = [[SigMeshPrivateBeacon alloc] initWithKeyRefreshFlag:NO ivUpdateActive:YES ivIndex:[LibTools uint32From16String:@"1010abcd"] randomData:[LibTools nsstringToHex:@"435f18f85cf78a3121f58478a5"] usingNetworkKey:model];
    NSData *obfuscatedPrivateBeaconData = [LibTools nsstringToHex:@"61e488e7cb"];
    NSData *Authentication_Tag = [LibTools nsstringToHex:@"f3174f022a514741"];

    XCTAssertEqualObjects(beacon.obfuscatedPrivateBeaconData, obfuscatedPrivateBeaconData);
    XCTAssertEqualObjects(beacon.authenticationTag, Authentication_Tag);
}

- (void)testReceiveMeshPrivateBeacon1 {
    SigNetkeyModel *model = [[SigNetkeyModel alloc] init];
    model.key = @"f7a2a44f8e8a8029064f173ddc1e2b00";
    NSString *ivIndexString = @"1010abcd";
    SigMeshLib.share.dataSource.ivIndex = ivIndexString;
    UInt32 iv32 = [LibTools uint32From16String:ivIndexString];
    model.ivIndex = [[SigIvIndex alloc] initWithIndex:iv32 updateActive:YES];
    model.phase = normalOperation;
    SigMeshPrivateBeacon *beacon = [[SigMeshPrivateBeacon alloc] initWithDecodePdu:[LibTools nsstringToHex:@"02435f18f85cf78a3121f58478a561e488e7cbf3174f022a514741"] usingNetworkKey:model];
    NSData *obfuscatedPrivateBeaconData = [LibTools nsstringToHex:@"61e488e7cb"];
    NSData *Authentication_Tag = [LibTools nsstringToHex:@"f3174f022a514741"];

    XCTAssertEqualObjects(beacon.obfuscatedPrivateBeaconData, obfuscatedPrivateBeaconData);
    XCTAssertEqualObjects(beacon.authenticationTag, Authentication_Tag);
    XCTAssertEqual(beacon.ivIndex, iv32);
    XCTAssertEqual(beacon.keyRefreshFlag, NO);
    XCTAssertEqual(beacon.ivUpdateActive, YES);
}

- (void)testMeshPrivateBeacon2 {
    SigNetkeyModel *model = [[SigNetkeyModel alloc] init];
    model.key = @"3bbb6f1fbd53e157417f308ce7aec58f";
    SigMeshPrivateBeacon *beacon = [[SigMeshPrivateBeacon alloc] initWithKeyRefreshFlag:NO ivUpdateActive:NO ivIndex:[LibTools uint32From16String:@"00000000"] randomData:[LibTools nsstringToHex:@"1b998f82927535ea6f3076f422"] usingNetworkKey:model];
    NSData *obfuscatedPrivateBeaconData = [LibTools nsstringToHex:@"ce827408ab"];
    NSData *Authentication_Tag = [LibTools nsstringToHex:@"2f0ffb94cf97f881"];

    XCTAssertEqualObjects(beacon.obfuscatedPrivateBeaconData, obfuscatedPrivateBeaconData);
    XCTAssertEqualObjects(beacon.authenticationTag, Authentication_Tag);
}

- (void)testReceiveMeshPrivateBeacon2 {    
    SigNetkeyModel *model = [[SigNetkeyModel alloc] init];
    model.key = @"3bbb6f1fbd53e157417f308ce7aec58f";
    NSString *ivIndexString = @"00000000";
    SigMeshLib.share.dataSource.ivIndex = ivIndexString;
    UInt32 iv32 = [LibTools uint32From16String:ivIndexString];
    model.ivIndex = [[SigIvIndex alloc] initWithIndex:iv32 updateActive:NO];
    model.phase = normalOperation;
    SigMeshPrivateBeacon *beacon = [[SigMeshPrivateBeacon alloc] initWithDecodePdu:[LibTools nsstringToHex:@"021b998f82927535ea6f3076f422ce827408ab2f0ffb94cf97f881"] usingNetworkKey:model];
    NSData *obfuscatedPrivateBeaconData = [LibTools nsstringToHex:@"ce827408ab"];
    NSData *Authentication_Tag = [LibTools nsstringToHex:@"2f0ffb94cf97f881"];

    XCTAssertEqualObjects(beacon.obfuscatedPrivateBeaconData, obfuscatedPrivateBeaconData);
    XCTAssertEqualObjects(beacon.authenticationTag, Authentication_Tag);
    XCTAssertEqual(beacon.ivIndex, iv32);
    XCTAssertEqual(beacon.keyRefreshFlag, NO);
    XCTAssertEqual(beacon.ivUpdateActive, NO);
}

- (void)testNodeIdentity {
    SigNetkeyModel *model = [[SigNetkeyModel alloc] init];
    model.key = @"7dd7364cd842ad18c17c2b820c84c3d6";
    SigNodeModel *node = [[SigNodeModel alloc] init];
    node.unicastAddress = @"1201";
    NSData *AdvertisementDataServiceData = [LibTools nsstringToHex:@"0100861765aefcc57b34ae608fbbc1f2c6"];
    BOOL result = [SigDataSource.share matchNodeIdentityWithAdvertisementDataServiceData:AdvertisementDataServiceData peripheralUUIDString:@"7dd7364cd842ad18c17c2b820c84c3d6" nodes:@[node] networkKey:model];
    XCTAssertTrue(result);
}

- (void)testPrivateNetworkIdentity {
    SigNetkeyModel *model = [[SigNetkeyModel alloc] init];
    model.key = @"7dd7364cd842ad18c17c2b820c84c3d6";
    NSData *AdvertisementDataServiceData = [LibTools nsstringToHex:@"02d30f7229ef04543534ae608fbbc1f2c6"];
    BOOL result = [SigDataSource.share matchPrivateNetworkIdentityWithAdvertisementDataServiceData:AdvertisementDataServiceData peripheralUUIDString:@"7dd7364cd842ad18c17c2b820c84c3d6" networkKey:model];
    XCTAssertTrue(result);
}

- (void)testPrivateNodeIdentity {
    SigNetkeyModel *model = [[SigNetkeyModel alloc] init];
    model.key = @"7dd7364cd842ad18c17c2b820c84c3d6";
    SigNodeModel *node = [[SigNodeModel alloc] init];
    node.unicastAddress = @"1201";
    NSData *AdvertisementDataServiceData = [LibTools nsstringToHex:@"032c64a8cbca65bfe134ae608fbbc1f2c6"];
    BOOL result = [SigDataSource.share matchPrivateNodeIdentityWithAdvertisementDataServiceData:AdvertisementDataServiceData peripheralUUIDString:@"7dd7364cd842ad18c17c2b820c84c3d6" nodes:@[node] networkKey:model];
    XCTAssertTrue(result);
}

@end
