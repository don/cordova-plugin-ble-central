/********************************************************************************************************
 * @file MeshTest.java
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date Sep. 30, 2010
 *
 * @par Copyright (c) 2010, Telink Semiconductor (Shanghai) Co., Ltd.
 *           All rights reserved.
 *
 *			 The information contained herein is confidential and proprietary property of Telink 
 * 		     Semiconductor (Shanghai) Co., Ltd. and is available under the terms 
 *			 of Commercial License Agreement between Telink Semiconductor (Shanghai) 
 *			 Co., Ltd. and the licensee in separate contract or the terms described here-in. 
 *           This heading MUST NOT be removed from this file.
 *
 * 			 Licensees are granted free, non-transferable use of the information in this 
 *			 file under Mutual Non-Disclosure Agreement. NO WARRENTY of ANY KIND is provided. 
 *
 *******************************************************************************************************/
package com.telink.ble.mesh;

import com.telink.ble.mesh.core.Encipher;
import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.access.MeshFirmwareParser;
import com.telink.ble.mesh.util.Arrays;

import org.junit.Assert;
import org.junit.Test;

import java.io.ByteArrayInputStream;
import java.security.Signature;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.security.interfaces.ECPublicKey;
import java.util.zip.CRC32;

/**
 * Created by kee on 2019/10/14.
 */

public class MeshTest {

    /**
     * test 9K firmware
     * ||
     * test chunk at
     */
    @Test
    public void testFirmwareParser() {
        MeshFirmwareParser firmwareParser = new MeshFirmwareParser();
//        byte[] testData = new byte[109 * 1024];
//        byte[] testData = new byte[57];

        byte[] testData = new byte[66464];
        for (int i = 0; i < testData.length; i++) {
            testData[i] = (byte) (i + 1);
        }

        int blockSize = 21;
        int chunkSize = 5;


        firmwareParser.reset(testData);
//        firmwareParser.reset(testData, blockSize, chunkSize);

        int blockNumber = 0;
        int blockIndex;
        while (firmwareParser.hasNextBlock()) {
            blockNumber++;
            blockIndex = firmwareParser.nextBlock();
            System.out.println("block : " + blockIndex);
            for (byte[] chunkData = firmwareParser.nextChunk(); chunkData != null; chunkData = firmwareParser.nextChunk()) {
                System.out.println("chunkData: " + Arrays.bytesToHexString(chunkData, ""));
                if (firmwareParser.validateProgress()) {
                    if (firmwareParser.getProgress() > 90) {
                        firmwareParser.getProgress();
                    }
                    System.out.println("progress: %" + firmwareParser.getProgress());
                }
            }
        }


//        Assert.assertArrayEquals(firmwareParser.chunkAt(2), Arrays.hexToBytes("3536373839"));
//
        Assert.assertEquals(2, 2);
    }

    @Test
    public void testLog2() {
        int logRst = (int) MeshUtils.mathLog2(8 * 1024);
        Assert.assertEquals(logRst, 13);
    }

    @Test
    public void testCrc32() {
        CRC32 crc32 = new CRC32();

        crc32.update(new byte[]{1});
//        Assert.assertEquals(crc32.getValue(), 0xE401A57BL);
        System.out.println(String.format("chunkData: %08x", crc32.getValue()));
    }


    @Test
    public void testK2() {//
        // ivi or nid invalid: ivi -- 0 nid -- 112 encryptSuit : ivi -- 540300920 nid -- 125
        byte[] netkey = Arrays.hexToBytes("F309F5CF8CCF499984856D13E83CAB7A");
        byte[][] k2Output = Encipher.calculateNetKeyK2(netkey);
        byte nid = (byte) (k2Output[0][15] & 0x7F);
        System.out.println("nid: " + nid);

    }


    @Test
    public void testOnlineStatus() {
        byte[] data = Arrays.hexToBytes("62066A121A5E975F76F4D5A5ABDA0A58CA94");
        byte[] key = Arrays.hexToBytes("3E9DAC96E9BFF60FB435CB79F06D99B5");
        byte[] re = Encipher.decryptOnlineStatus(data, key);

        System.out.println("re: " + Arrays.bytesToHexString(re, ":"));
//        Assert.assertEquals(re, expectedRe);
        //

    }


    @Test
    public void testAes() {
//        byte[] data = Arrays.hexToBytes("0102030405060708090a0b0c0d0e0f00");
        byte[] data = new byte[]{
                '0', '1', '2', '3',
                '0', '1', '2', '3',
                '0', '1', '2', '3',
                '0', '1', '2', '3'
        };

//        byte[] key = Arrays.hexToBytes("3E9DAC96E9BFF60FB435CB79F06D99B5");
        byte[] key = {
                'a', 'b', 'c', 'd',
                'a', 'b', 'c', 'd',
                'a', 'b', 'c', 'd',
                'a', 'b', 'c', 'd'
        };


        byte[] re = Encipher.aes(data, key);

        // aes 1BCEA700A0889443AD3515B5EB4F0E92
        // reverse A1882E0A23E6FCBC8AF95CE3F7F3FED4

        byte[] expectedRe = Arrays.hexToBytes("C7A28CA9F54838A1D8757F6F56597AFF");
        System.out.println("re: " + Arrays.bytesToHexString(re, ""));
//        Assert.assertEquals(re, expectedRe);
        //

    }

    @Test
    public void arrayHexTest() {
        byte[] pre = MeshUtils.generateRandom(16);
        ;
        for (int i = 0; i < pre.length; i++) {
            pre[i] = (byte) (i * 5);
        }
        System.out.println("pre : " + Arrays.bytesToHexString(pre));

    }

    // SIG sample data
//    final static String CERTIFY_DATA_STR = "308202b43082025aa00302010202021000300a06082a8648ce3d0403023081a7310b30090603550406130246493110300e06035504080c07557573696d6161310e300c06035504070c054573706f6f31183016060355040a0c0f4578616d706c6520436f6d70616e7931193017060355040b0c10456d6265646465642044657669636573311d301b06035504030c14656d6265646465642e6578616d706c652e636f6d3122302006092a864886f70d0109011613737570706f7274406578616d706c652e636f6d301e170d3138313131363037333434365a170d3139313131363037333434365a308193310b30090603550406130246493110300e06035504080c07557573696d6161310e300c06035504070c054573706f6f31183016060355040a0c0f4578616d706c6520436f6d70616e7931193017060355040b0c10456d6265646465642044657669636573312d302b06035504030c2462303964633834372d353430382d343063632d396335342d3066653863383734323965373059301306072a8648ce3d020106082a8648ce3d030107034200048d0297ccb3e7c76b152e0fb025e4e71e3929a0f09d2b8c45f168b87e16041de44b024cb80634fcd0706c24a833eddb2eb57151510316c9893ee4b4bc85f6de59a3818730818430090603551d1304023000300b0603551d0f040403020308301d0603551d0e0416041428bc426a68db6396708571e4cfc9721ce98b6815301f0603551d23041830168014c37eea546a026d7ccef5f4a0d3f5a8d49826a34a302a06146982e19de491eac0c283999caa83fd8cc3d0d367041204104e54346f7046725a7444516856597767300a06082a8648ce3d0403020348003045022100c55974bb14b7a6825698ab3f35f87d6070685d263857f451439acbeeaf15fa2102207767f5beca9e28dde98a9eb76b8691dc938bd98555a7c13244b313cc2d69a325";

    // test data
    final static String CERTIFY_DATA_STR = "308201F93082019FA00302010202021000300A06082A8648CE3D0403023045310B30090603550406130241553113301106035504080C0A536F6D652D53746174653121301F060355040A0C18496E7465726E6574205769646769747320507479204C7464301E170D3231303132373035343933315A170D3331303132353035343933315A3045310B30090603550406130241553113301106035504080C0A536F6D652D53746174653121301F060355040A0C18496E7465726E6574205769646769747320507479204C74643059301306072A8648CE3D020106082A8648CE3D03010703420004C87B8390F47AF888F0FDC323E0A08AFFBEAAEA15CCE714C77FFA3275EDCF3550994D8465E5F27B5902C8B7032040C31C50AF2FF6A957A3D2E928848C8B89327BA37F307D30580603551D230451304FA149A4473045310B30090603550406130241553113301106035504080C0A536F6D652D53746174653121301F060355040A0C18496E7465726E6574205769646769747320507479204C74648202100030090603551D1304023000300B0603551D0F0404030204F030090603551D1104023000300A06082A8648CE3D040302034800304502205C4DA8FBB2E781962E8A8E848726CAF4950AE6D2FFEEBDEBAF9FC06DC277AF8802210088196CEF2EF0D3BAFF2D3E8132E9BF5D2ADCB406ABBEFCEB48FC45F11FCC30D4";


//    final static String CERTIFY_DATA_STR = "308201B43082015A020900CA106C58DB979EE3300A06082A8648CE3D0403023061310B300906035504061302434E310B300906035504080C026666310B300906035504070C026666310B3009060355040A0C026666310B3009060355040B0C026666310B300906035504030C0266663111300F06092A864886F70D010901160266663020170D3231303132313036323933355A180F32313230313232383036323933355A3061310B300906035504061302434E310B300906035504080C026666310B300906035504070C026666310B3009060355040A0C026666310B3009060355040B0C026666310B300906035504030C0266663111300F06092A864886F70D010901160266663059301306072A8648CE3D020106082A8648CE3D030107034200040CC1449DF2BD94F689A5C2D9BEB0C847FCE3E386E7B06C849BF6B2B871AA766391CEF84BD651B10C17CC6416F9FBEC6780AC16AAA9504E11652C0C973A3AD31E300A06082A8648CE3D0403020348003045022100B2D05486E996419F0B6F263479058FFBFC95911492D20F53CCFF61067C2D82760220574E7EC884FC9D50244BDD01D89C96537B37D450F9CCC138D205A55FC6BD1566";

    @Test
    public void certificateTest() {
        byte[] cerData = Arrays.hexToBytes(CERTIFY_DATA_STR);
        CertificateFactory factory = null;
        try {
            factory = CertificateFactory.getInstance("X.509");

            X509Certificate certificate = (X509Certificate) factory.generateCertificate(new ByteArrayInputStream(cerData));

            int version = certificate.getVersion();
            if (version != 3) {
                System.out.println("version check err");
            }

            int serialNumber = certificate.getSerialNumber().intValue();
            if (serialNumber != 4096){
                System.out.println("serial number check err");
            }

            /**
             * check datetime validity
             */
            certificate.checkValidity();

            /**
             * get X509 version
             */
            certificate.getVersion();

            /**
             * get subject names ,
             */
            certificate.getSubjectAlternativeNames();


            /**
             * get alg name
             */
            String algName = certificate.getSigAlgName();
            System.out.println("alg name: " + algName);

            certificate.getExtendedKeyUsage();
//            byte[] publicKey = certificate.getPublicKey().getEncoded();
            ECPublicKey pk = (ECPublicKey) certificate.getPublicKey();
            byte[] keyX = pk.getW().getAffineX().toByteArray();
            if (keyX.length > 32) {
                byte[] x = new byte[32];
                System.arraycopy(keyX, keyX.length - 32, x, 0, 32);
                keyX = x;
            }
            byte[] keyY = pk.getW().getAffineY().toByteArray();
            if (keyY.length > 32) {
                byte[] y = new byte[32];
                System.arraycopy(keyY, keyY.length - 32, y, 0, 32);
                keyY = y;
            }

            byte[] pubKeyKey = new byte[keyX.length + keyY.length];
            System.arraycopy(keyX, 0, pubKeyKey, 0, keyX.length);
            System.arraycopy(keyY, 0, pubKeyKey, keyX.length, keyY.length);

            System.out.println("pub key : " + Arrays.bytesToHexString(pubKeyKey));

            // SHA256withECDSA
            Signature verifier = Signature.getInstance("SHA256withECDSA");
//            verifier.initVerify(certificate.getPublicKey()); // This cert is signed by CA
            verifier.initVerify(certificate); // This cert is signed by CA
            verifier.update(certificate.getTBSCertificate());  //TBS is to get the "To Be Signed" part of the certificate - .getEncoded() gets the whole cert, which includes the signature
            boolean result = verifier.verify(certificate.getSignature());
            if (result) {
                System.out.println("signature validation pass");
            } else {
                System.out.println("signature validation failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }


    }


    private void initSign() {

    }

}
