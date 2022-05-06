/********************************************************************************************************
 * @file     NetworkLayerPDU.java 
 *
 * @brief    for TLSR chips
 *
 * @author	 telink
 * @date     Sep. 30, 2010
 *
 * @par      Copyright (c) 2010, Telink Semiconductor (Shanghai) Co., Ltd.
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
package com.telink.ble.mesh.core.networking;


import com.telink.ble.mesh.core.Encipher;
import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.util.MeshLogger;


import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class NetworkLayerPDU {

    /**
     * Least significant bit of IV Index
     * 1 bit
     */
    private byte ivi;

    /**
     * network id
     * 7 bits
     * Value derived from the NetKey used to identify the Encryption Key and Privacy Key used to secure this PDU
     */
    private byte nid;

    /**
     * Network Control
     * 1 bit
     * determine if the message is part of a Control MeshCommand or an Access MeshCommand
     */
    private byte ctl;

    /**
     * Time To Live
     * 7 bits
     * value:
     * 0 = has not been relayed and will not be relayed
     * 1 = may have been relayed, but will not be relayed
     * 2 to 126 = may have been relayed and can be relayed
     * 127 = has not been relayed and can be relayed
     */
    private byte ttl;

    /**
     * Sequence Number
     * 24 bits == 3 bytes
     */
    private int seq;

    /**
     * Source Address
     * 16 bits == 2 bytes
     * shall be unicast address
     */
    private int src;

    /**
     * Destination Address
     * 16 bits == 2 bytes
     * shall be a unicast address, a group address, or a virtual address
     */
    private int dst;

    /**
     * Transport Protocol Data Unit
     * 8 to 128 bits
     * When the CTL bit is 0, the TransportPDU field shall be a maximum of 128 bits.
     * When the CTL bit is 1, the TransportPDU field shall be a maximum of 96 bits.
     */
    private byte[] transportPDU;

    /**
     * MeshCommand Integrity Check for Network
     * 32 or 64 bits
     * When the CTL bit is 0, the NetMIC field shall be 32 bits.
     * When the CTL bit is 1, the NetMIC field shall be 64 bits.
     */
//    private int transMic;
    protected NetworkEncryptionSuite encryptionSuite;

    public NetworkLayerPDU(NetworkEncryptionSuite encryptionSuite) {
        this.encryptionSuite = encryptionSuite;
    }

    /*public NetworkLayerPDU(int ivIndex, byte[] encryptionKey, byte[] privacyKey, int nid) {
        this.ivIndex = ivIndex;
        this.encryptionKey = encryptionKey;
        this.privacyKey = privacyKey;
        this.nid = nid;
    }*/


    public byte[] generateEncryptedPayload() {
        final byte iviNid = (byte) ((ivi << 7) | nid);
        final byte ctlTTL = (byte) ((ctl << 7) | ttl);

        final byte[] encryptedPayload = encryptNetworkPduPayload(transportPDU);
//        MeshLogger.log("encryptedPayload: " + Arrays.bytesToHexString(encryptedPayload, ""));
        final byte[] privacyRandom = createPrivacyRandom(encryptedPayload);
        final byte[] pecb = createPECB(privacyRandom);
//        MeshLogger.log("pecb: " + Arrays.bytesToHexString(pecb, ""));

        final byte[] header = createObfuscatedNetworkHeader(ctlTTL, seq, src, pecb);
//        MeshLogger.log("obfuscateNetworkHeader: " + Arrays.bytesToHexString(header, ""));

        return ByteBuffer.allocate(1 + header.length + encryptedPayload.length).order(ByteOrder.BIG_ENDIAN)
                .put(iviNid)
                .put(header)
                .put(encryptedPayload)
                .array();
    }

    private byte[] createObfuscatedNetworkHeader(final byte ctlTTL, int sno, final int src, final byte[] pecb) {

        byte[] seqNo = MeshUtils.integer2Bytes(sno, 3, ByteOrder.BIG_ENDIAN);
        final ByteBuffer buffer = ByteBuffer.allocate(1 + seqNo.length + 2).order(ByteOrder.BIG_ENDIAN);
        buffer.put(ctlTTL);
        buffer.put(seqNo);   //sequence number
        buffer.putShort((short) src);       //source address

        final byte[] headerBuffer = buffer.array();

//        MeshLogger.log("NetworkHeader: " + Arrays.bytesToHexString(headerBuffer, ""));

        final ByteBuffer bufferPECB = ByteBuffer.allocate(6);
        bufferPECB.put(pecb, 0, 6);

        final byte[] obfuscated = new byte[6];
        for (int i = 0; i < 6; i++)
            obfuscated[i] = (byte) (headerBuffer[i] ^ pecb[i]);

        return obfuscated;
    }

    private byte[] createPECB(byte[] privacyRandom) {
        final ByteBuffer buffer = ByteBuffer.allocate(5 + privacyRandom.length + 4);
        buffer.order(ByteOrder.BIG_ENDIAN);
        buffer.put(new byte[]{0x00, 0x00, 0x00, 0x00, 0x00});
        buffer.putInt(this.encryptionSuite.ivIndex);
        buffer.put(privacyRandom);
        final byte[] temp = buffer.array();
        return Encipher.aes(temp, this.encryptionSuite.privacyKey);
    }

    private byte[] createPrivacyRandom(byte[] encryptedUpperTransportPDU) {
        final byte[] privacyRandom = new byte[7];
        System.arraycopy(encryptedUpperTransportPDU, 0, privacyRandom, 0, privacyRandom.length);
        return privacyRandom;
    }


    private byte[] encryptNetworkPduPayload(byte[] lowerPDU) {
        // seqNo 3 bytes
//        byte ctlTTL = (byte) ((ctl << 7) | ttl);
//        byte[] seqNo = MeshUtils.integer2Bytes(seq, 3, ByteOrder.BIG_ENDIAN);
//        final byte[] networkNonce = NonceGenerator.generateNetworkNonce(ctlTTL, seqNo, src, this.encryptionSuite.ivIndex);
        byte[] networkNonce = generateNonce();
//        MeshLogger.log("networkNonce: " + Arrays.bytesToHexString(networkNonce, ""));
        final byte[] unencryptedNetworkPayload = ByteBuffer.allocate(2 + lowerPDU.length).order(ByteOrder.BIG_ENDIAN).putShort((short) dst).put(lowerPDU).array();
        return Encipher.ccm(unencryptedNetworkPayload, this.encryptionSuite.encryptionKey, networkNonce, getMicLen(), true);
    }

    protected byte[] generateNonce() {
        byte ctlTTL = (byte) ((ctl << 7) | ttl);
        byte[] seqNo = MeshUtils.integer2Bytes(seq, 3, ByteOrder.BIG_ENDIAN);
        return NonceGenerator.generateNetworkNonce(ctlTTL, seqNo, src, this.encryptionSuite.ivIndex);
    }

    private int getMicLen() {
        return ctl == 0 ? 4 : 8;
    }

    /**
     * parse
     */
    public byte[] parseObfuscatedNetworkHeader(byte[] pdu) {
        final ByteBuffer obfuscatedNetworkBuffer = ByteBuffer.allocate(6);
        obfuscatedNetworkBuffer.order(ByteOrder.BIG_ENDIAN);
        obfuscatedNetworkBuffer.put(pdu, 1, 6);
        final byte[] obfuscatedData = obfuscatedNetworkBuffer.array();

        final ByteBuffer privacyRandomBuffer = ByteBuffer.allocate(7);
        privacyRandomBuffer.order(ByteOrder.BIG_ENDIAN);
        privacyRandomBuffer.put(pdu, 7, 7);
        final byte[] privacyRandom = createPrivacyRandom(privacyRandomBuffer.array());

        final byte[] pecb = createPECB(privacyRandom);
        final byte[] deobfuscatedData = new byte[6];

        for (int i = 0; i < 6; i++)
            deobfuscatedData[i] = (byte) (obfuscatedData[i] ^ pecb[i]);

        return deobfuscatedData;
    }

    public boolean parse(byte[] pduData) {

        int iviNid = pduData[0] & 0xFF;
        int ivi = iviNid >> 7;
        int nid = iviNid & 0x7F;
        MeshLogger.i("ivi -- " + ivi + " nid -- " + nid);
        if (!validateNetworkPdu(ivi, nid)) {
            MeshLogger.i("ivi or nid invalid: ivi -- " + ivi + " nid -- " + nid +
                    " encryptSuit : ivi -- " + encryptionSuite.ivIndex + " nid -- " + encryptionSuite.nid);
            return false;
        }

        byte[] originalHeader = this.parseObfuscatedNetworkHeader(pduData);
        int ctlTtl = originalHeader[0];
        int ctl = (ctlTtl >> 7) & 0x01;
        int ttl = ctlTtl & 0x7F;
        byte[] sequenceNumber = ByteBuffer.allocate(3).order(ByteOrder.BIG_ENDIAN).put(originalHeader, 1, 3).array();
        int src = (((originalHeader[4] & 0xFF) << 8) + (originalHeader[5] & 0xFF));
        this.setIvi((byte) ivi);
        this.setNid((byte) nid);
        this.setCtl((byte) ctl);
        this.setTtl((byte) ttl);
        this.setSeq(MeshUtils.bytes2Integer(sequenceNumber, ByteOrder.BIG_ENDIAN));
        this.setSrc(src);

        byte[] networkNonce = generateNonce();
//        byte[] networkNonce = NonceGenerator.generateNetworkNonce((byte) ctlTtl, sequenceNumber, src, this.encryptionSuite.ivIndex);


        final int dstTransportLen = pduData.length - (1 + originalHeader.length);

        final byte[] dstTransportPayload = new byte[dstTransportLen];
        System.arraycopy(pduData, 7, dstTransportPayload, 0, dstTransportLen);

        // decrypted dest + transport(lower) payload
        final byte[] decDstTransportPayload = Encipher.ccm(dstTransportPayload, this.encryptionSuite.encryptionKey, networkNonce, getMicLen(), false);

        if (decDstTransportPayload == null) {
            MeshLogger.i("network layer decrypt err");
            return false;
        }

        int dstAdr = ((decDstTransportPayload[0] & 0xFF) << 8) | (decDstTransportPayload[1] & 0xFF);

        byte[] lowerTransportPdu = new byte[decDstTransportPayload.length - 2];
        System.arraycopy(decDstTransportPayload, 2, lowerTransportPdu, 0, lowerTransportPdu.length);

        this.dst = dstAdr;
        this.setTransportPDU(lowerTransportPdu);
        return true;
    }

    private boolean validateNetworkPdu(int ivi, int nid) {
        return nid == this.encryptionSuite.nid && ivi == (this.encryptionSuite.ivIndex & 0b01);
    }

    public byte getIvi() {
        return ivi;
    }

    public void setIvi(byte ivi) {
        this.ivi = ivi;
    }

    public byte getNid() {
        return nid;
    }

    public void setNid(byte nid) {
        this.nid = nid;
    }

    public byte getCtl() {
        return ctl;
    }

    public void setCtl(byte ctl) {
        this.ctl = ctl;
    }

    public byte getTtl() {
        return ttl;
    }

    public void setTtl(byte ttl) {
        this.ttl = ttl;
    }

    public int getSeq() {
        return seq;
    }

    public void setSeq(int seq) {
        this.seq = seq;
    }

    public int getSrc() {
        return src;
    }

    public void setSrc(int src) {
        this.src = src;
    }

    public int getDst() {
        return dst;
    }

    public void setDst(int dst) {
        this.dst = dst;
    }

    public byte[] getTransportPDU() {
        return transportPDU;
    }

    public void setTransportPDU(byte[] transportPDU) {
        this.transportPDU = transportPDU;
    }

    public static class NetworkEncryptionSuite {

        // for encryption
        public int ivIndex;

        protected byte[] encryptionKey;


        protected byte[] privacyKey;

        protected int nid;

        public NetworkEncryptionSuite(int ivIndex, byte[] encryptionKey, byte[] privacyKey, int nid) {
            this.ivIndex = ivIndex;
            this.encryptionKey = encryptionKey;
            this.privacyKey = privacyKey;
            this.nid = nid;
        }
    }
}

