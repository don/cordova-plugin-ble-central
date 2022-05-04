/********************************************************************************************************
 * @file     SegmentAcknowledgmentMessage.java 
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

import com.telink.ble.mesh.core.MeshUtils;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * Created by kee on 2019/8/16.
 */

public class SegmentAcknowledgmentMessage extends UnsegmentedControlMessagePDU {
    public static final int DATA_LEN = 7;

    /**
     * 1 bit
     */
    private final int seg = 0;

    /**
     * 7 bits
     */
    private final int opcode = 0x00;

    /**
     * The OBO field shall be set to 0 by a node that is directly addressed by the received message
     * and shall be set to 1 by a Friend node that is acknowledging this message on behalf of a Low Power node.
     * <p>
     * As provisioner, obo is always 0
     * 1 bit
     */
    private final int obo = 0;

    /**
     * SeqZero of the Upper Transport PDU
     */
    private int seqZero;

    private final int rfu = 0;

    /**
     * Block acknowledgment for segments
     * 32 bits
     * If bit n is set to 0, then segment n is not being acknowledged.
     * Any bits for segments larger than SegN shall be set to 0 and ignored upon receipt.
     */
    private int blockAck = 0;

    public boolean parse(byte[] lowerTransportData) {
        if (lowerTransportData.length != DATA_LEN) return false;
//        int seqZero = ((lowerTransportData[1] & 0x7F) << 6) | ((lowerTransportData[2] & 0xFF) >> 2);
        int seqZero = MeshUtils.bytes2Integer(new byte[]{lowerTransportData[1], lowerTransportData[2]}
                , ByteOrder.BIG_ENDIAN);
        seqZero = (seqZero & 0x7FFF) >> 2;
        this.seqZero = seqZero;
        this.blockAck = MeshUtils.bytes2Integer(new byte[]{
                lowerTransportData[3],
                lowerTransportData[4],
                lowerTransportData[5],
                lowerTransportData[6],
        }, ByteOrder.BIG_ENDIAN);
        return true;
    }

    public SegmentAcknowledgmentMessage() {
    }

    public SegmentAcknowledgmentMessage(int seqZero, int blockAck) {
        this.seqZero = seqZero;
        this.blockAck = blockAck;
    }

    @Override
    public byte[] toByteArray() {
        return ByteBuffer.allocate(DATA_LEN).order(ByteOrder.BIG_ENDIAN)
                .put((byte) ((seg << 7) | opcode))
                .put((byte) ((obo << 7) | ((seqZero >> 6) & 0x7F)))
                .put((byte) (((seqZero << 2) & 0xFC) | rfu))
                .putInt(blockAck).array();

    }

    @Override
    public String toString() {
        return "SegmentAcknowledgmentMessage{" +
                "seg=" + seg +
                ", opcode=" + opcode +
                ", obo=" + obo +
                ", seqZero=" + seqZero +
                ", rfu=" + rfu +
                ", blockAck=" + blockAck +
                '}';
    }

    public int getSeqZero() {
        return seqZero;
    }

    public int getBlockAck() {
        return blockAck;
    }
}
