/********************************************************************************************************
 * @file     SegmentedControlMessagePDU.java 
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

public class SegmentedControlMessagePDU extends LowerTransportPDU {


    /**
     * 1 = Segmented MeshCommand
     */
    private final byte seg = 1;

    /**
     * 0x00 = Reserved
     * 0x01 to 0x7F = Opcode of the Transport Control message
     */
    private int opcode;

    private int RFU = 0;

    private int seqZero;

    /**
     * Segment Offset number
     */
    private int segO;

    /**
     * Last Segment number
     */
    private int segN;

    /**
     * Segment m of the Upper Transport Access PDU
     */
    private byte[] segmentM;


    @Override
    public int getType() {
        return TYPE_SEGMENTED_ACCESS_MESSAGE;
    }

    @Override
    public boolean segmented() {
        return true;
    }

    @Override
    public byte[] toByteArray() {
        int headerLength = 4;
        int payloadLength = segmentM.length;
        ByteBuffer resultBuffer = ByteBuffer.allocate(headerLength + payloadLength).order(ByteOrder.BIG_ENDIAN);
        resultBuffer.put((byte) ((seg << 7) | opcode));
        resultBuffer.put((byte) ((RFU << 7) | ((seqZero >> 6) & 0x7F)));
        resultBuffer.put((byte) (((seqZero << 2) & 0xFC) | ((segO >> 3) & 0x03)));
        resultBuffer.put((byte) (((segO << 5) & 0xE0) | ((segN) & 0x1F)));
        resultBuffer.put(segmentM);
        return resultBuffer.array();
    }

    public boolean parse(NetworkLayerPDU networkLayerPDU) {
        byte[] lowerTransportPdu = networkLayerPDU.getTransportPDU();
        this.opcode = (byte) (lowerTransportPdu[0] & 0x7F);
        this.RFU = (lowerTransportPdu[1] >> 7) & 0x01;
        this.seqZero = ((lowerTransportPdu[1] & 0x7F) << 6) | ((lowerTransportPdu[2] & 0xFC) >> 2);
        this.segO = ((lowerTransportPdu[2] & 0x03) << 3) | ((lowerTransportPdu[3] & 0xE0) >> 5);
        this.segN = ((lowerTransportPdu[3]) & 0x1F);

        this.segmentM = new byte[lowerTransportPdu.length - 4];
        System.arraycopy(lowerTransportPdu, 4, this.segmentM, 0, this.segmentM.length);
        return this.segmentM != null || this.segmentM.length >= 1;
    }


}
