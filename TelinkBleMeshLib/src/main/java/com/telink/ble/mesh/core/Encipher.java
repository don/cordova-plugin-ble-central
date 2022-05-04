/********************************************************************************************************
 * @file Encipher.java
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
package com.telink.ble.mesh.core;

import com.telink.ble.mesh.util.MeshLogger;

import org.spongycastle.crypto.BlockCipher;
import org.spongycastle.crypto.CipherParameters;
import org.spongycastle.crypto.InvalidCipherTextException;
import org.spongycastle.crypto.engines.AESEngine;
import org.spongycastle.crypto.engines.AESLightEngine;
import org.spongycastle.crypto.macs.CMac;
import org.spongycastle.crypto.modes.CCMBlockCipher;
import org.spongycastle.crypto.params.AEADParameters;
import org.spongycastle.crypto.params.KeyParameter;
import org.spongycastle.jce.ECNamedCurveTable;
import org.spongycastle.jce.interfaces.ECPublicKey;
import org.spongycastle.jce.spec.ECNamedCurveParameterSpec;
import org.spongycastle.jce.spec.ECParameterSpec;
import org.spongycastle.jce.spec.ECPublicKeySpec;
import org.spongycastle.math.ec.ECCurve;
import org.spongycastle.math.ec.ECPoint;
import org.spongycastle.util.BigIntegers;

import java.io.ByteArrayInputStream;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.security.InvalidKeyException;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.PrivateKey;
import java.security.Signature;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.security.spec.InvalidKeySpecException;

import javax.crypto.KeyAgreement;

/**
 * Created by kee on 2019/7/19.
 */

public final class Encipher {

    private static final byte[] SALT_INPUT_K2 = "smk2".getBytes();

    private static final byte[] SALT_INPUT_K3 = "smk3".getBytes();

    private static final byte[] SALT_INPUT_K4 = "smk4".getBytes();

    //    private static final byte[] SALT_INPUT_SMK4 = "smk4".getBytes();
    //  “id6” || 0x01
    private static final byte[] SALT_K3_M = new byte[]{0x69, 0x64, 0x36, 0x34, 0x01};

    // //  “id64” || 0x01
    private static final byte[] SALT_K4_M = new byte[]{0x69, 0x64, 0x36, 0x01};

    private static final byte[] SALT_NKIK = "nkik".getBytes();

    private static final byte[] SALT_BKIK = "nkbk".getBytes();

    private static final byte[] SALT_ID128 = "id128".getBytes();

    // 48 bit
    private static final byte[] NODE_IDENTITY_HASH_PADDING = new byte[]{0, 0, 0, 0, 0, 0};

    public static final byte[] PRCK = "prck".getBytes();

    public static final byte[] PRSK = "prsk".getBytes();

    public static final byte[] PRSN = "prsn".getBytes();

    public static final byte[] PRDK = "prdk".getBytes();


    public static KeyPair generateKeyPair() {
        try {
            // secp256r1
            ECNamedCurveParameterSpec ecParamSpec = ECNamedCurveTable.getParameterSpec("P-256");
            KeyPairGenerator generator = KeyPairGenerator.getInstance("ECDH", "SC");
            generator.initialize(ecParamSpec);

            return generator.generateKeyPair();
        } catch (Exception e) {
            MeshLogger.log("generate key pair err!");
            return null;
        }
    }

    public static byte[] generateECDH(byte[] xy, PrivateKey provisionerPrivateKey) {
        try {
            BigInteger x = BigIntegers.fromUnsignedByteArray(xy, 0, 32);
            BigInteger y = BigIntegers.fromUnsignedByteArray(xy, 32, 32);

            ECParameterSpec ecParameters = ECNamedCurveTable.getParameterSpec("secp256r1");
            ECCurve curve = ecParameters.getCurve();
            ECPoint ecPoint = curve.validatePoint(x, y);

            ECPublicKeySpec keySpec = new ECPublicKeySpec(ecPoint, ecParameters);
            KeyFactory keyFactory;
            keyFactory = KeyFactory.getInstance("ECDH", "SC");
            ECPublicKey publicKey = (ECPublicKey) keyFactory.generatePublic(keySpec);

            KeyAgreement keyAgreement = KeyAgreement.getInstance("ECDH", "SC");
            keyAgreement.init(provisionerPrivateKey);
            keyAgreement.doPhase(publicKey, true);
            return keyAgreement.generateSecret();
        } catch (NoSuchAlgorithmException | IllegalArgumentException | NoSuchProviderException | InvalidKeySpecException | InvalidKeyException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * aes-cmac
     * <p>
     * k is the 128-bit key
     * m is the variable length data to be authenticated
     */
    public static byte[] aesCmac(byte[] content, byte[] key) {
        CipherParameters cipherParameters = new KeyParameter(key);
        BlockCipher blockCipher = new AESEngine();
        CMac mac = new CMac(blockCipher);

        mac.init(cipherParameters);
        mac.update(content, 0, content.length);
        byte[] re = new byte[16];
        mac.doFinal(re, 0);
        return re;
    }

    private static final byte[] SALT_KEY_ZERO =
            {
                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
            };

    /**
     * S1
     * s1(M) = AES-CMAC ZERO (M)
     *
     * @param m input
     * @return re
     */
    public static byte[] generateSalt(byte[] m) {
        return aesCmac(m, SALT_KEY_ZERO);
    }

    /*
    The inputs to function k1 are:
N is 0 or more octets SALT is 128 bits
P is 0 or more octets
The key (T) is computed as follows: T = AES-CMAC SALT (N)
The output of the key generation function k1 is as follows: k1(N, SALT, P) = AES-CMACT (P)
     */


    /**
     * @param data    target data
     * @param k       key
     * @param n       nonce
     * @param micSize mic
     * @param encrypt true: encryption, false: decryption
     * @return result
     */
    public static byte[] ccm(byte[] data, byte[] k, byte[] n, int micSize, boolean encrypt) {
        byte[] result = new byte[data.length + (encrypt ? micSize : (-micSize))];
        CCMBlockCipher ccmBlockCipher = new CCMBlockCipher(new AESEngine());
        AEADParameters aeadParameters = new AEADParameters(new KeyParameter(k), micSize * 8, n);
        ccmBlockCipher.init(encrypt, aeadParameters);
        ccmBlockCipher.processBytes(data, 0, data.length, result, data.length);
        try {
            ccmBlockCipher.doFinal(result, 0);
            return result;
        } catch (InvalidCipherTextException e) {
            return null;
        }
    }


    public static byte[] aes(byte[] data, byte[] key) {
        final byte[] encrypted = new byte[data.length];
        final CipherParameters cipherParameters = new KeyParameter(key);
        final AESLightEngine engine = new AESLightEngine();
        engine.init(true, cipherParameters);
        engine.processBlock(data, 0, encrypted, 0);

        return encrypted;
    }


    public static byte[] k1(byte[] ecdh, byte[] salt, byte[] text) {
        byte[] t = aesCmac(ecdh, salt);
        return aesCmac(text, t);
    }

    public static byte[][] calculateNetKeyK2(byte[] netKey) {
        return k2(netKey, new byte[]{0});
    }

    public static byte[][] k2(byte[] data, byte[] p) {

        byte[] salt = generateSalt(SALT_INPUT_K2);
        byte[] t = aesCmac(data, salt);

        byte[] t0 = {};
        final ByteBuffer inputBufferT0 = ByteBuffer.allocate(t0.length + p.length + 1);
        inputBufferT0.put(t0);
        inputBufferT0.put(p);
        inputBufferT0.put((byte) 0x01);
        final byte[] t1 = aesCmac(inputBufferT0.array(), t);
//        final byte nid = (byte) (t1[15] & 0x7F);

        final ByteBuffer inputBufferT1 = ByteBuffer.allocate(t1.length + p.length + 1);
        inputBufferT1.put(t1);
        inputBufferT1.put(p);
        inputBufferT1.put((byte) 0x02);
        // encryptionKey
        final byte[] t2 = aesCmac(inputBufferT1.array(), t);

        final ByteBuffer inputBufferT2 = ByteBuffer.allocate(t2.length + p.length + 1);
        inputBufferT2.put(t2);
        inputBufferT2.put(p);
        inputBufferT2.put((byte) 0x03);
        // privacyKey
        final byte[] t3 = aesCmac(inputBufferT2.array(), t);

        return new byte[][]{t1, t2, t3};
    }

    public static byte[] k3(byte[] n) {
        byte[] salt = generateSalt(SALT_INPUT_K3);
        byte[] t = aesCmac(n, salt);
        byte[] result = aesCmac(SALT_K3_M, t);
        byte[] networkId = new byte[8];
        int srcOffset = result.length - networkId.length;
        System.arraycopy(result, srcOffset, networkId, 0, networkId.length);
        return networkId;
    }


    public static byte k4(byte[] n) {
        byte[] salt = generateSalt(SALT_INPUT_K4);
        byte[] t = aesCmac(n, salt);
        byte[] result = aesCmac(SALT_K4_M, t);
        return (byte) ((result[15]) & 0x3F);
    }

    public static byte[] generateNodeIdentityHash(byte[] identityKey, byte[] random, int src) {
        int length = NODE_IDENTITY_HASH_PADDING.length + random.length + 2;
        ByteBuffer bufferHashInput = ByteBuffer.allocate(length).order(ByteOrder.BIG_ENDIAN);
        bufferHashInput.put(NODE_IDENTITY_HASH_PADDING);
        bufferHashInput.put(random);
        bufferHashInput.putShort((short) src);
        byte[] hashInput = bufferHashInput.array();
        byte[] hash = aes(hashInput, identityKey);

        ByteBuffer buffer = ByteBuffer.allocate(8);
        buffer.put(hash, 8, 8);

        return buffer.array();
    }

    public static byte[] generateIdentityKey(byte[] networkKey) {
        byte[] salt = generateSalt(SALT_NKIK);
        ByteBuffer buffer = ByteBuffer.allocate(SALT_ID128.length + 1);
        buffer.put(SALT_ID128);
        buffer.put((byte) 0x01);
        byte[] p = buffer.array();
        return k1(networkKey, salt, p);
    }

    public static byte[] generateBeaconKey(byte[] networkKey) {
        byte[] salt = generateSalt(SALT_BKIK);
        ByteBuffer buffer = ByteBuffer.allocate(SALT_ID128.length + 1);
        buffer.put(SALT_ID128);
        buffer.put((byte) 0x01);
        byte[] p = buffer.array();
        return k1(networkKey, salt, p);
    }

    /**
     * @param data online status data
     * @param key  netKey->beaconKey
     * @return decryption result
     */
    public static byte[] decryptOnlineStatus(byte[] data, byte[] key) {
        final int ivLen = 4;
        byte[] iv = new byte[ivLen];
        System.arraycopy(data, 0, iv, 0, ivLen);

        final int micLen = 2;
        byte[] mic = new byte[micLen];
        int micIndex = data.length - micLen;
        System.arraycopy(data, micIndex, mic, 0, micLen);

        int len = data.length - ivLen - micLen;
        byte[] status = new byte[len];
        System.arraycopy(data, ivLen, status, 0, len);

//        int result = aes_att_decryption_packet_online_st(key, iv, ivLen, mic, micLen, status, len);

        byte[] e = new byte[16], r = new byte[16];

        ///////////////// calculate enc ////////////////////////
        System.arraycopy(iv, 0, r, 1, ivLen);

//        memcpy(r + 1, iv, iv_len);
        for (int i = 0; i < len; i++) {
            if ((i & 15) == 0) {
                e = aes(r, key);
                r[0]++;
            }
            status[i] ^= e[i & 15];
        }
        ///////////// calculate mic ///////////////////////
        r = new byte[16];
//        memset(r, 0, 16);
        System.arraycopy(iv, 0, r, 0, ivLen);
//        memcpy(r, iv, iv_len);
        r[ivLen] = (byte) len;
        r = aes(r, key);

        for (int i = 0; i < len; i++) {
            r[i & 15] ^= status[i];

            if ((i & 15) == 15 || i == len - 1) {
                r = aes(r, key);
            }
        }

        for (int i = 0; i < micLen; i++) {
            if (mic[i] != r[i]) {
                return null;            //Failed
            }
        }

        System.arraycopy(status, 0, data, ivLen, status.length);
        return data;
    }


    /**
     * check version & time & Serial Number
     * <p>
     * <p>
     * "ecdsa-with-SHA256"
     * check certificate data and return inner public key
     *
     * @param cerData certificate data formatted by x509 der
     * @return public key
     */
    public static byte[] checkCertificate(byte[] cerData) {
        CertificateFactory factory = null;
        try {
            factory = CertificateFactory.getInstance("X.509");

            X509Certificate certificate = (X509Certificate) factory.generateCertificate(new ByteArrayInputStream(cerData));
            if (certificate.getVersion() != 3) {
                MeshLogger.d("version check err");
                return null;
            }

            int serialNumber = certificate.getSerialNumber().intValue();
            if (serialNumber != 4096) {
                MeshLogger.d("serial number check err");
                return null;
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
            certificate.getExtendedKeyUsage();
//          byte[]  publicKey = certificate.getPublicKey().getEncoded();

            Signature verifier = Signature.getInstance(certificate.getSigAlgName(), "SC");
//            verifier.initVerify(certificate.getPublicKey()); // This cert is signed by CA
            verifier.initVerify(certificate); // This cert is signed by CA
            verifier.update(certificate.getTBSCertificate());  //TBS is to get the "To Be Signed" part of the certificate - .getEncoded() gets the whole cert, which includes the signature
            boolean result = verifier.verify(certificate.getSignature());


            java.security.interfaces.ECPublicKey pk = (java.security.interfaces.ECPublicKey) certificate.getPublicKey();
            byte[] keyX = pk.getW().getAffineX().toByteArray();
            if (keyX.length > 32) {
                byte[] x = new byte[32];
                System.arraycopy(keyX, 1, x, 0, 32);
                keyX = x;
            }
            byte[] keyY = pk.getW().getAffineY().toByteArray();
            if (keyY.length > 32) {
                byte[] y = new byte[32];
                System.arraycopy(keyY, 1, y, 0, 32);
                keyY = y;
            }

            byte[] pubKeyKey = new byte[keyX.length + keyY.length];
            System.arraycopy(keyX, 0, pubKeyKey, 0, keyX.length);
            System.arraycopy(keyY, 0, pubKeyKey, keyX.length, keyY.length);

            if (result) {
                System.out.println("signature validation pass");
//                return null;
                return pubKeyKey;
            } else {
                System.out.println("signature validation failed");
                return null;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
