/********************************************************************************************************
 * @file     BlobBlockStartMessage.java 
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


import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class BlobBlockStartMessage extends UpdatingMessage {


    /**
     * Block number of the incoming block
     * 2 bytes
     */
    private int blockNumber;

    /**
     * Chunk size (in octets) for the incoming block
     * 2 bytes
     */
    private int chunkSize;


    public static BlobBlockStartMessage getSimple(int destinationAddress, int appKeyIndex,
                                                  int blockNumber,
                                                  int chunkSize) {
        BlobBlockStartMessage message = new BlobBlockStartMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        message.blockNumber = blockNumber;
        message.chunkSize = chunkSize;
        return message;
    }

    public BlobBlockStartMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getOpcode() {
        return Opcode.BLOB_BLOCK_START.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.BLOB_BLOCK_STATUS.value;
    }

    @Override
    public byte[] getParams() {
        return ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN)
                .putShort((short) blockNumber)
                .putShort((short) chunkSize).array();
    }

    public void setBlockNumber(int blockNumber) {
        this.blockNumber = blockNumber;
    }

    public void setChunkSize(int chunkSize) {
        this.chunkSize = chunkSize;
    }
}
