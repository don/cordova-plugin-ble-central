/********************************************************************************************************
 * @file     TelinkSigMeshLibTests.m
 *
 * @brief    A concise description.
 *
 * @author   Telink, 梁家誌
 * @date     2020/10/29
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
#import "OpenSSLHelper.h"
/*需要使用模拟器运行测试单元，且需要替换到模拟器的TelinkEncryptLib！！！*/

@interface TelinkSigMeshLibTests : XCTestCase

@end

@implementation TelinkSigMeshLibTests

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

//- (void)testCreateMeshNetWork {
//    [SDKLibCommand startMeshSDK];
//    //1.netKey
//    XCTAssertEqual(SigDataSource.share.netKeys.count, 1);
//    XCTAssertEqualObjects(SigDataSource.share.netKeys.firstObject, SigDataSource.share.curNetkeyModel);
//    XCTAssertEqualObjects(SigDataSource.share.netKeys.firstObject.key, SigDataSource.share.curNetkeyModel.key);
//    XCTAssertEqual(SigDataSource.share.curNetkeyModel.key.length, 2*16);
//    XCTAssertEqual(SigDataSource.share.curNetkeyModel.index, 0);
//    XCTAssertEqual(SigDataSource.share.curNetkeyModel.phase, 0);
//    XCTAssertNotNil(SigDataSource.share.curNetkeyModel.timestamp);
//    XCTAssertEqualObjects(SigDataSource.share.curNetkeyModel.oldKey, @"00000000000000000000000000000000");
//    XCTAssertNotNil(SigDataSource.share.curNetkeyModel.name);
//    XCTAssertEqualObjects(SigDataSource.share.curNetkeyModel.minSecurity, @"secure");
//    XCTAssertEqualObjects(SigDataSource.share.curNetkeyModel.key, [LibTools meshUUIDToUUID:SigDataSource.share.meshUUID]);
//
//    //2.appKey
//    XCTAssertEqual(SigDataSource.share.appKeys.count, 1);
//    XCTAssertEqualObjects(SigDataSource.share.appKeys.firstObject, SigDataSource.share.curAppkeyModel);
//    XCTAssertEqual(SigDataSource.share.curAppkeyModel.key.length, 2*16);
//    XCTAssertEqualObjects(SigDataSource.share.curAppkeyModel.oldKey, @"00000000000000000000000000000000");
//    XCTAssertNotNil(SigDataSource.share.curAppkeyModel.name);
//    XCTAssertEqual(SigDataSource.share.curAppkeyModel.boundNetKey, 0);
//    XCTAssertEqual(SigDataSource.share.curAppkeyModel.index, 0);
//
//    //3.provisioner
//    XCTAssertEqual(SigDataSource.share.provisioners.count, 1);
//    XCTAssertEqualObjects(SigDataSource.share.provisioners.firstObject, SigDataSource.share.curProvisionerModel);
//    XCTAssertEqual(SigDataSource.share.curProvisionerModel.UUID.length, 2*16);
//    XCTAssertEqual(SigDataSource.share.curProvisionerModel.allocatedGroupRange.count, 1);
//    XCTAssertEqual(SigDataSource.share.curProvisionerModel.allocatedGroupRange.firstObject.lowIntAddress, 0xc000);
//    XCTAssertEqual(SigDataSource.share.curProvisionerModel.allocatedGroupRange.firstObject.hightIntAddress, 0xc0ff);
//    XCTAssertEqual(SigDataSource.share.curProvisionerModel.allocatedUnicastRange.count, 1);
//    XCTAssertEqual(SigDataSource.share.curProvisionerModel.allocatedUnicastRange.firstObject.lowIntAddress, 0x0001);
//    XCTAssertEqual(SigDataSource.share.curProvisionerModel.allocatedUnicastRange.firstObject.hightIntAddress, 0x03ff);
//    XCTAssertEqual(SigDataSource.share.curProvisionerModel.allocatedSceneRange.count, 1);
//    XCTAssertEqualObjects(SigDataSource.share.curProvisionerModel.allocatedSceneRange.firstObject.firstScene, @"0001");
//    XCTAssertEqualObjects(SigDataSource.share.curProvisionerModel.allocatedSceneRange.firstObject.lastScene, @"000F");
//    XCTAssertEqualObjects(SigDataSource.share.curProvisionerModel.provisionerName, @"Telink iOS provisioner");
//    XCTAssertEqualObjects(SigDataSource.share.curProvisionerModel.UUID, SigDataSource.share.getCurrentProvisionerUUID);
//
//    //4.node
//    XCTAssertEqual(SigDataSource.share.nodes.count, 1);
//    XCTAssertEqualObjects(SigDataSource.share.nodes.firstObject, SigDataSource.share.curLocationNodeModel);
//    XCTAssertEqualObjects(SigDataSource.share.curLocationNodeModel.UUID, SigDataSource.share.curProvisionerModel.UUID, @"provisioner的UUID与locationNode的UUID不相等！");
//    XCTAssertTrue(SigDataSource.share.curLocationNodeModel.secureNetworkBeacon);
//    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.defaultTTL, TTL_DEFAULT);
//    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.features.proxyFeature, SigNodeFeaturesState_notSupported);
//    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.features.friendFeature, SigNodeFeaturesState_notEnabled);
//    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.features.relayFeature, SigNodeFeaturesState_notSupported);
//    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.relayRetransmit.relayRetransmitCount, 3);
//    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.relayRetransmit.relayRetransmitIntervalSteps, 10);
//    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.address, 1);
//    XCTAssertEqualObjects(SigDataSource.share.curLocationNodeModel.name, @"Telink iOS provisioner node");
//    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.elements.count, 1);
//    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.elements.firstObject.parentNodeAddress, 1);
//    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.deviceKey.length, 2*16);
//
//    //5.group
//    XCTAssertEqual(SigDataSource.share.groups.count, 8);
//
//    //6.other
//    XCTAssertEqualObjects(SigDataSource.share.schema, @"http://json-schema.org/draft-04/schema#");
//    XCTAssertEqualObjects(SigDataSource.share.meshName, @"Telink-Sig-Mesh");
//    XCTAssertEqualObjects(SigDataSource.share.version, @"1.0.0");
//    XCTAssertNotNil(SigDataSource.share.timestamp);
//    XCTAssertEqualObjects(SigDataSource.share.ivIndex, @"00000000");
//
//    NSLog(@"==========finish!");
//}

- (void)testDeviceCertificate {
    //协议
//    NSString *str = @"308202b43082025aa00302010202021000300a06082a8648ce3d0403023081a7310b30090603550406130246493110300e06035504080c07557573696d6161310e300c06035504070c054573706f6f31183016060355040a0c0f4578616d706c6520436f6d70616e7931193017060355040b0c10456d6265646465642044657669636573311d301b06035504030c14656d6265646465642e6578616d706c652e636f6d3122302006092a864886f70d0109011613737570706f7274406578616d706c652e636f6d301e170d3138313131363037333434365a170d3139313131363037333434365a308193310b30090603550406130246493110300e06035504080c07557573696d6161310e300c06035504070c054573706f6f31183016060355040a0c0f4578616d706c6520436f6d70616e7931193017060355040b0c10456d6265646465642044657669636573312d302b06035504030c2462303964633834372d353430382d343063632d396335342d3066653863383734323965373059301306072a8648ce3d020106082a8648ce3d030107034200048d0297ccb3e7c76b152e0fb025e4e71e3929a0f09d2b8c45f168b87e16041de44b024cb80634fcd0706c24a833eddb2eb57151510316c9893ee4b4bc85f6de59a3818730818430090603551d1304023000300b0603551d0f040403020308301d0603551d0e0416041428bc426a68db6396708571e4cfc9721ce98b6815301f0603551d23041830168014c37eea546a026d7ccef5f4a0d3f5a8d49826a34a302a06146982e19de491eac0c283999caa83fd8cc3d0d367041204104e54346f7046725a7444516856597767300a06082a8648ce3d0403020348003045022100c55974bb14b7a6825698ab3f35f87d6070685d263857f451439acbeeaf15fa2102207767f5beca9e28dde98a9eb76b8691dc938bd98555a7c13244b313cc2d69a325".uppercaseString;
    //固件8258_mesh_CERTIFY_CERT1
//    NSString *str = @"308201F93082019FA00302010202021000300A06082A8648CE3D0403023045310B30090603550406130241553113301106035504080C0A536F6D652D53746174653121301F060355040A0C18496E7465726E6574205769646769747320507479204C7464301E170D3231303132373035343933315A170D3331303132353035343933315A3045310B30090603550406130241553113301106035504080C0A536F6D652D53746174653121301F060355040A0C18496E7465726E6574205769646769747320507479204C74643059301306072A8648CE3D020106082A8648CE3D03010703420004C87B8390F47AF888F0FDC323E0A08AFFBEAAEA15CCE714C77FFA3275EDCF3550994D8465E5F27B5902C8B7032040C31C50AF2FF6A957A3D2E928848C8B89327BA37F307D30580603551D230451304FA149A4473045310B30090603550406130241553113301106035504080C0A536F6D652D53746174653121301F060355040A0C18496E7465726E6574205769646769747320507479204C74648202100030090603551D1304023000300B0603551D0F0404030204F030090603551D1104023000300A06082A8648CE3D040302034800304502205C4DA8FBB2E781962E8A8E848726CAF4950AE6D2FFEEBDEBAF9FC06DC277AF8802210088196CEF2EF0D3BAFF2D3E8132E9BF5D2ADCB406ABBEFCEB48FC45F11FCC30D4".uppercaseString;
    //固件8258_mesh_CERTIFY_CERT2（时间过期证书）
    NSString *str = @"308201f93082019fa00302010202021000300a06082a8648ce3d0403023045310b30090603550406130241553113301106035504080c0a536f6d652d53746174653121301f060355040a0c18496e7465726e6574205769646769747320507479204c7464301e170d3231303132373036303230365a170d3231303132393036303230365a3045310b30090603550406130241553113301106035504080c0a536f6d652d53746174653121301f060355040a0c18496e7465726e6574205769646769747320507479204c74643059301306072a8648ce3d020106082a8648ce3d0301070342000451c02670d822f087e9e40048ef6a52dd05a62d86c56440587c85e94afb87de93149bafd3d6c4fad1025c5d70c83d52559b6d59fb4e54cbc5503cfe8924f7710ba37f307d30580603551d230451304fa149a4473045310b30090603550406130241553113301106035504080c0a536f6d652d53746174653121301f060355040a0c18496e7465726e6574205769646769747320507479204c74648202100030090603551d1304023000300b0603551d0f0404030204f030090603551d1104023000300a06082a8648ce3d0403020348003045022100dd0a6a2e4db0af037f809ef919bba7390e5cd77a7be14c2bc48f4c3d74c04eee022025283264cb7c0375b39e429336dada89b245951200bc5d43dd18eef0daea8864".uppercaseString;
    //cert_self
//    NSString *str = @"308202e7308201cfa003020102020101300d06092a864886f70d01010b050030213112301006035504030c09636572745f73656c66310b300906035504061302434e301e170d3231303330313130313335365a170d3232303330313130313335365a30213112301006035504030c09636572745f73656c66310b300906035504061302434e30820122300d06092a864886f70d01010105000382010f003082010a0282010100b939503ceb2be1a1d2f936eba0ee96790b2c779f19847f9e97c14a3f076a48ae0499ce85e50bc8c2c4de9fcc7b10dfc9935f1116e401aa8f0f81f0b1c7a58cb9a347625ea1fd8200113fb0fb2d17741230bd1d81bc5c5e63d6fd0770c48bd40b1163c6a28fc9d56e4f631fd0aa746d197d933de647b304a713bf29cd9b602f64fd545ca88a480ccf897d787c649efcaf96de1de884109c6548c94642b3d9223f92f3640cc0f2e8cc3ea57fb184643f22247983e57b4869a3f1064eb9be057a525de7394959057ac230180f65a64a0041aa103d49aa089fab610f75b0f87e93535c59f8fa729d5cd6b094d8c606998e411ebbf114a08cd9684eb2cf029a717a2d0203010001a32a3028300e0603551d0f0101ff0404030205a030160603551d250101ff040c300a06082b06010505070304300d06092a864886f70d01010b0500038201010061718ff2107ccb1f7c265f35201ee7f220e9aaa9ae280efe21b75acf8522657aed007ade7e108ccc19a82b369b91b8ebdb23793706996af499f92a1ed770f9ee56efc7fff4c41b4511509b2da54226496f9093c57e8a9b928f29c1870c2ec3b36a0bfc21ef745dd13145d96b897d593a9df7672442aba02062ee44ad0110f44fe2a700f6eb4861869e68a6101e45e0904decabc9e7a64faa4ad27a070faade31ffaac4f88127bd6631fc7144d5b0ecf69fe68b92f5121bacd6ed31b2ec7c94dbfeae031c25e8c7acd8ba67cf02495e8b58ef9d7e29cae048c25ce3e2896435ffd60ce2ee4dfc5c6fba7fab946187d0c89ff61c661e5d5a237af742ca41cd2c96".uppercaseString;
  NSData *data = [LibTools nsstringToHex:str];
    NSData *publicKey = [OpenSSLHelper.share getStaticOOBDataFromCertificate:data];
    TeLogInfo(@"=====>获取证书成功,deviceCertificateData=%@,publicKey=%@",[LibTools convertDataToHexStr:data],[LibTools convertDataToHexStr:publicKey])
}

- (void)testRootCertificate {
    //固件证书
    NSData *staticOOB = [OpenSSLHelper.share getStaticOOBDataFromCertificate:[LibTools nsstringToHex:@"3082027F30820224A003020102020103300A06082A8648CE3D04030230818F310B30090603550406130255533113301106035504080C0A57617368696E67746F6E31163014060355040A0C0D426C7565746F6F746820534947310C300A060355040B0C03505453311F301D06035504030C16496E7465726D65646961746520417574686F726974793124302206092A864886F70D0109011615737570706F727440626C7565746F6F74682E636F6D301E170D3139303731383138353533365A170D3330313030343138353533365A3077310B30090603550406130255533113301106035504080C0A57617368696E67746F6E31163014060355040A0C0D426C7565746F6F746820534947310C300A060355040B0C03505453312D302B06035504030C2430303142444330382D313032312D304230452D304130432D3030304230453041304330303059301306072A8648CE3D020106082A8648CE3D03010703420004F465E43FF23D3F1B9DC7DFC04DA8758184DBC966204796ECCF0D6CF5E16500CC0201D048BCBBD899EEEFC424164E33C201C2B010CA6B4D43A8A155CAD8ECB279A3818730818430090603551D1304023000300B0603551D0F040403020308301D0603551D0E04160414E262F3584AB688EC882EA528ED8E5C442A71369F301F0603551D230418301680144ABE293903A8BB49FF1D327CFEB80985F4109C21302A06146982E19DE491EAC0C283999CAA83FD8CC3D0D3670412041000000000000000000102030405060708300A06082A8648CE3D0403020349003046022100F7B504477EC2E5796644A0C5A95D864BF001CF96A5A180E243432CCE28FC5F9E0221008D816BEE11C36CDC1890189EDB85DF9A26998063EAC8EA55330B7F75003FEB98"]];
    NSLog(@"staticOOB========%@",staticOOB);
}

- (void)testInitDefaultMeshNetWork {
    SigDataSource *defaultMesh = [[SigDataSource alloc] initDefaultMesh];
    //1.netKey
    XCTAssertEqual(defaultMesh.netKeys.count, 1);
    XCTAssertEqualObjects(defaultMesh.netKeys.firstObject, defaultMesh.curNetkeyModel);
    XCTAssertEqualObjects(defaultMesh.netKeys.firstObject.key, defaultMesh.curNetkeyModel.key);
    XCTAssertEqual(defaultMesh.curNetkeyModel.key.length, 2*16);
    XCTAssertEqual(defaultMesh.curNetkeyModel.index, 0);
    XCTAssertEqual(defaultMesh.curNetkeyModel.phase, 0);
    XCTAssertNotNil(defaultMesh.curNetkeyModel.timestamp);
    XCTAssertEqualObjects(defaultMesh.curNetkeyModel.oldKey, @"00000000000000000000000000000000");
    XCTAssertNotNil(defaultMesh.curNetkeyModel.name);
    XCTAssertEqualObjects(defaultMesh.curNetkeyModel.minSecurity, @"secure");
    XCTAssertEqualObjects(defaultMesh.curNetkeyModel.key, defaultMesh.meshUUID);
    
    //2.appKey
    XCTAssertEqual(defaultMesh.appKeys.count, 1);
    XCTAssertEqualObjects(defaultMesh.appKeys.firstObject, defaultMesh.curAppkeyModel);
    XCTAssertEqual(defaultMesh.curAppkeyModel.key.length, 2*16);
    XCTAssertEqualObjects(defaultMesh.curAppkeyModel.oldKey, @"00000000000000000000000000000000");
    XCTAssertNotNil(defaultMesh.curAppkeyModel.name);
    XCTAssertEqual(defaultMesh.curAppkeyModel.boundNetKey, 0);
    XCTAssertEqual(defaultMesh.curAppkeyModel.index, 0);
    
    //3.provisioner
    XCTAssertEqual(defaultMesh.provisioners.count, 1);
    XCTAssertEqualObjects(defaultMesh.provisioners.firstObject, defaultMesh.curProvisionerModel);
    XCTAssertEqual(defaultMesh.curProvisionerModel.UUID.length, 2*16);
    XCTAssertEqual(defaultMesh.curProvisionerModel.allocatedGroupRange.count, 1);
    XCTAssertEqual(defaultMesh.curProvisionerModel.allocatedGroupRange.firstObject.lowIntAddress, 0xc000);
    XCTAssertEqual(defaultMesh.curProvisionerModel.allocatedGroupRange.firstObject.hightIntAddress, 0xc0ff);
    XCTAssertEqual(defaultMesh.curProvisionerModel.allocatedUnicastRange.count, 1);
    XCTAssertEqual(defaultMesh.curProvisionerModel.allocatedUnicastRange.firstObject.lowIntAddress, 0x0001);
    XCTAssertEqual(defaultMesh.curProvisionerModel.allocatedUnicastRange.firstObject.hightIntAddress, 0x03ff);
    XCTAssertEqual(defaultMesh.curProvisionerModel.allocatedSceneRange.count, 1);
    XCTAssertEqualObjects(defaultMesh.curProvisionerModel.allocatedSceneRange.firstObject.firstScene, @"0001");
    XCTAssertEqualObjects(defaultMesh.curProvisionerModel.allocatedSceneRange.firstObject.lastScene, @"000F");
    XCTAssertEqualObjects(defaultMesh.curProvisionerModel.provisionerName, @"Telink iOS provisioner");
    XCTAssertEqualObjects(defaultMesh.curProvisionerModel.UUID, defaultMesh.getCurrentProvisionerUUID);
    
    //4.node
    XCTAssertEqual(defaultMesh.nodes.count, 1);
    XCTAssertEqualObjects(defaultMesh.nodes.firstObject, defaultMesh.curLocationNodeModel);
    XCTAssertEqualObjects(defaultMesh.curLocationNodeModel.UUID, defaultMesh.curProvisionerModel.UUID, @"provisioner的UUID与locationNode的UUID不相等！");
    XCTAssertTrue(defaultMesh.curLocationNodeModel.secureNetworkBeacon);
    XCTAssertEqual(defaultMesh.curLocationNodeModel.defaultTTL, TTL_DEFAULT);
    XCTAssertEqual(defaultMesh.curLocationNodeModel.features.proxyFeature, SigNodeFeaturesState_notSupported);
    XCTAssertEqual(defaultMesh.curLocationNodeModel.features.friendFeature, SigNodeFeaturesState_notEnabled);
    XCTAssertEqual(defaultMesh.curLocationNodeModel.features.relayFeature, SigNodeFeaturesState_notSupported);
    XCTAssertEqual(defaultMesh.curLocationNodeModel.relayRetransmit.relayRetransmitCount, 5);
    XCTAssertEqual(defaultMesh.curLocationNodeModel.relayRetransmit.relayRetransmitIntervalSteps, 2);
    XCTAssertEqual(defaultMesh.curLocationNodeModel.address, 1);
    XCTAssertEqualObjects(defaultMesh.curLocationNodeModel.name, @"Telink iOS provisioner node");
    XCTAssertEqual(defaultMesh.curLocationNodeModel.elements.count, 1);
    XCTAssertEqual(defaultMesh.curLocationNodeModel.elements.firstObject.parentNodeAddress, 1);
    XCTAssertEqual(defaultMesh.curLocationNodeModel.deviceKey.length, 2*16);
    
    //5.group
    XCTAssertEqual(defaultMesh.groups.count, 8);
    
    //6.other
    XCTAssertEqualObjects(defaultMesh.schema, @"http://json-schema.org/draft-04/schema#");
    XCTAssertEqualObjects(defaultMesh.meshName, @"Telink-Sig-Mesh");
    XCTAssertEqualObjects(defaultMesh.version, @"1.0.0");
    XCTAssertNotNil(defaultMesh.timestamp);
    XCTAssertEqualObjects(defaultMesh.ivIndex, @"00000000");
    
    //7.scanLsit and sno
    XCTAssertEqual(defaultMesh.scanList.count, 0);
//    XCTAssertEqual(defaultMesh.getCurrentProvisionerIntSequenceNumber, 0);
    
    //8.添加设备的地址
    XCTAssertEqual(defaultMesh.provisionAddress, 2);
    XCTAssertEqual(defaultMesh.getNextUnicastAddressOfProvision, 2);
    SigNodeModel *node1 = [[SigNodeModel alloc] initWithNode:defaultMesh.curLocationNodeModel];
    node1.unicastAddress = [NSString stringWithFormat:@"%04X",0xFF];
    [defaultMesh.nodes addObject:node1];
    XCTAssertEqual(defaultMesh.getNextUnicastAddressOfProvision, 0xFF+1);
    SigNodeModel *node2 = [[SigNodeModel alloc] initWithNode:defaultMesh.curLocationNodeModel];
    node2.unicastAddress = [NSString stringWithFormat:@"%04X",0x3FF];
    [defaultMesh.nodes addObject:node2];
    XCTAssertEqual(defaultMesh.getNextUnicastAddressOfProvision, 0x3FF+1);

    XCTAssertEqual(defaultMesh.curProvisionerModel.allocatedUnicastRange.firstObject.hightIntAddress, 0x3FF);
    SigRangeModel *model = [[SigRangeModel alloc] initWithMaxHighAddressUnicast:0x4FF];
    [defaultMesh.curProvisionerModel.allocatedUnicastRange addObject:model];
    XCTAssertEqual(defaultMesh.getNextUnicastAddressOfProvision, 0x4FF+1);

    NSLog(@"==========finish!");
}

- (void)testResetMeshNetWork {
    [SigDataSource.share resetMesh];
    //1.netKey
    XCTAssertEqual(SigDataSource.share.netKeys.count, 1);
    XCTAssertEqualObjects(SigDataSource.share.netKeys.firstObject, SigDataSource.share.curNetkeyModel);
    XCTAssertEqualObjects(SigDataSource.share.netKeys.firstObject.key, SigDataSource.share.curNetkeyModel.key);
    XCTAssertEqual(SigDataSource.share.curNetkeyModel.key.length, 2*16);
    XCTAssertEqual(SigDataSource.share.curNetkeyModel.index, 0);
    XCTAssertEqual(SigDataSource.share.curNetkeyModel.phase, 0);
    XCTAssertNotNil(SigDataSource.share.curNetkeyModel.timestamp);
    XCTAssertEqualObjects(SigDataSource.share.curNetkeyModel.oldKey, @"00000000000000000000000000000000");
    XCTAssertNotNil(SigDataSource.share.curNetkeyModel.name);
    XCTAssertEqualObjects(SigDataSource.share.curNetkeyModel.minSecurity, @"secure");
    XCTAssertEqualObjects(SigDataSource.share.curNetkeyModel.key, SigDataSource.share.meshUUID);
    
    //2.appKey
    XCTAssertEqual(SigDataSource.share.appKeys.count, 1);
    XCTAssertEqualObjects(SigDataSource.share.appKeys.firstObject, SigDataSource.share.curAppkeyModel);
    XCTAssertEqual(SigDataSource.share.curAppkeyModel.key.length, 2*16);
    XCTAssertEqualObjects(SigDataSource.share.curAppkeyModel.oldKey, @"00000000000000000000000000000000");
    XCTAssertNotNil(SigDataSource.share.curAppkeyModel.name);
    XCTAssertEqual(SigDataSource.share.curAppkeyModel.boundNetKey, 0);
    XCTAssertEqual(SigDataSource.share.curAppkeyModel.index, 0);
    
    //3.provisioner
    XCTAssertEqual(SigDataSource.share.provisioners.count, 1);
    XCTAssertEqualObjects(SigDataSource.share.provisioners.firstObject, SigDataSource.share.curProvisionerModel);
    XCTAssertEqual(SigDataSource.share.curProvisionerModel.UUID.length, 2*16);
    XCTAssertEqual(SigDataSource.share.curProvisionerModel.allocatedGroupRange.count, 1);
    XCTAssertEqual(SigDataSource.share.curProvisionerModel.allocatedGroupRange.firstObject.lowIntAddress, 0xc000);
    XCTAssertEqual(SigDataSource.share.curProvisionerModel.allocatedGroupRange.firstObject.hightIntAddress, 0xc0ff);
    XCTAssertEqual(SigDataSource.share.curProvisionerModel.allocatedUnicastRange.count, 1);
    XCTAssertEqual(SigDataSource.share.curProvisionerModel.allocatedUnicastRange.firstObject.lowIntAddress, 0x0001);
    XCTAssertEqual(SigDataSource.share.curProvisionerModel.allocatedUnicastRange.firstObject.hightIntAddress, 0x03ff);
    XCTAssertEqual(SigDataSource.share.curProvisionerModel.allocatedSceneRange.count, 1);
    XCTAssertEqualObjects(SigDataSource.share.curProvisionerModel.allocatedSceneRange.firstObject.firstScene, @"0001");
    XCTAssertEqualObjects(SigDataSource.share.curProvisionerModel.allocatedSceneRange.firstObject.lastScene, @"000F");
    XCTAssertEqualObjects(SigDataSource.share.curProvisionerModel.provisionerName, @"Telink iOS provisioner");
    XCTAssertEqualObjects(SigDataSource.share.curProvisionerModel.UUID, SigDataSource.share.getCurrentProvisionerUUID);
    
    //4.node
    XCTAssertEqual(SigDataSource.share.nodes.count, 1);
    XCTAssertEqualObjects(SigDataSource.share.nodes.firstObject, SigDataSource.share.curLocationNodeModel);
    XCTAssertEqualObjects(SigDataSource.share.curLocationNodeModel.UUID, SigDataSource.share.curProvisionerModel.UUID, @"provisioner的UUID与locationNode的UUID不相等！");
    XCTAssertTrue(SigDataSource.share.curLocationNodeModel.secureNetworkBeacon);
    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.defaultTTL, TTL_DEFAULT);
    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.features.proxyFeature, SigNodeFeaturesState_notSupported);
    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.features.friendFeature, SigNodeFeaturesState_notEnabled);
    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.features.relayFeature, SigNodeFeaturesState_notSupported);
    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.relayRetransmit.relayRetransmitCount, 5);
    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.relayRetransmit.relayRetransmitIntervalSteps, 2);
    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.address, 1);
    XCTAssertEqualObjects(SigDataSource.share.curLocationNodeModel.name, @"Telink iOS provisioner node");
    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.elements.count, 1);
    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.elements.firstObject.parentNodeAddress, 1);
    XCTAssertEqual(SigDataSource.share.curLocationNodeModel.deviceKey.length, 2*16);
    
    //5.group
    XCTAssertEqual(SigDataSource.share.groups.count, 8);
    
    //6.other
    XCTAssertEqualObjects(SigDataSource.share.schema, @"http://json-schema.org/draft-04/schema#");
    XCTAssertEqualObjects(SigDataSource.share.meshName, @"Telink-Sig-Mesh");
    XCTAssertEqualObjects(SigDataSource.share.version, @"1.0.0");
    XCTAssertNotNil(SigDataSource.share.timestamp);
    XCTAssertEqualObjects(SigDataSource.share.ivIndex, @"00000000");
    
    //7.scanLsit and sno
    XCTAssertEqual(SigDataSource.share.scanList.count, 0);
    XCTAssertEqual(SigDataSource.share.getCurrentProvisionerIntSequenceNumber, 0);
    
    NSLog(@"==========finish!");
}


@end
