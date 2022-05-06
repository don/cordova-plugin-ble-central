/********************************************************************************************************
 * @file     UnsegmentedAccessMessagePDU.java 
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
package com.telink.ble.mesh.core.networking.transport.lower;

import com.telink.ble.mesh.core.networking.NetworkLayerPDU;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * Created by kee on 2019/8/9.
 */

public class UnsegmentedAccessMessagePDU extends LowerTransportPDU {

    // segment
    /**
     * 1 bit
     * 0: unsegmented , means a single PDU
     * 1: segment
     */
    private final byte seg = 0;

    /**
     * 1 bit
     * Application Key Flag
     */
    private byte akf;

    /**
     * 6 bits
     * Application key identifier
     */
    private byte aid;

    /**
     * 40 to 120 bits
     */
    private byte[] upperTransportPDU;

    public UnsegmentedAccessMessagePDU() {

    }


    public UnsegmentedAccessMessagePDU(byte akf, byte aid, byte[] upperTransportPDU) {
        this.akf = akf;
        this.aid = aid;
        this.upperTransportPDU = upperTransportPDU;
    }

    @Override
    public int getType() {
        return TYPE_UNSEGMENTED_ACCESS_MESSAGE;
    }

    @Override
    public boolean segmented() {
        return false;
    }

    @Override
    public byte[] toByteArray() {
        byte oct0 = (byte) ((seg << 7) | (akf << 6) | aid);
        ByteBuffer lowerTransportBuffer = ByteBuffer.allocate(1 + upperTransportPDU.length).order(ByteOrder.BIG_ENDIAN);
        lowerTransportBuffer.put(oct0);
        lowerTransportBuffer.put(upperTransportPDU);
        return lowerTransportBuffer.array();
    }

    public boolean parse(NetworkLayerPDU networkLayerPDU) {
        byte[] lowerTransportData = networkLayerPDU.getTransportPDU();
        byte header = lowerTransportData[0]; //Lower transport pdu starts here
        this.akf = (byte) ((header >> 6) & 0x01);
        this.aid = (byte) (header & 0x3F);
        byte[] upperTransportPDU = new byte[lowerTransportData.length - 1];
        System.arraycopy(lowerTransportData, 1, upperTransportPDU, 0, upperTransportPDU.length);
        this.upperTransportPDU = upperTransportPDU;
        return upperTransportPDU.length != 0;
    }


    public byte getSeg() {
        return seg;
    }

    public byte getAkf() {
        return akf;
    }

    public void setAkf(byte akf) {
        this.akf = akf;
    }

    public byte getAid() {
        return aid;
    }

    public void setAid(byte aid) {
        this.aid = aid;
    }

    public byte[] getUpperTransportPDU() {
        return upperTransportPDU;
    }

    public void setUpperTransportPDU(byte[] upperTransportPDU) {
        this.upperTransportPDU = upperTransportPDU;
    }
}
