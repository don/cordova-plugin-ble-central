/********************************************************************************************************
 * @file     BlobChunkTransferMessage.java 
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
package com.telink.ble.mesh.core.message.firmwareupdate.blobtransfer;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatingMessage;
import com.telink.ble.mesh.util.Arrays;


import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class BlobChunkTransferMessage extends UpdatingMessage {


    /**
     * The chunk’s number in a set of chunks in a block
     * 2 bytes
     */
    private int chunkNumber;

    /**
     * Binary data from the current block
     */
    private byte[] chunkData;


    public static BlobChunkTransferMessage getSimple(int destinationAddress, int appKeyIndex,
                                                     int chunkNumber,
                                                     byte[] chunkData) {
        BlobChunkTransferMessage message = new BlobChunkTransferMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        message.chunkNumber = chunkNumber;
        message.chunkData = chunkData;
        return message;
    }

    public BlobChunkTransferMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getOpcode() {
        return Opcode.BLOB_CHUNK_TRANSFER.value;
    }

    @Override
    public int getResponseOpcode() {
        return OPCODE_INVALID;
    }

    @Override
    public byte[] getParams() {
        ByteBuffer bf = ByteBuffer.allocate(2 + chunkData.length).order(ByteOrder.LITTLE_ENDIAN)
                .putShort((short) chunkNumber)
                .put(chunkData);
        return bf.array();
    }

    @Override
    public String toString() {
        return "BlobChunkTransferMessage{" +
                "chunkNumber=" + chunkNumber +
                ", chunkData=" + Arrays.bytesToHexString(chunkData) +
                '}';
    }

    public void setChunkNumber(int chunkNumber) {
        this.chunkNumber = chunkNumber;
    }

    public void setChunkData(byte[] chunkData) {
        this.chunkData = chunkData;
    }
}
