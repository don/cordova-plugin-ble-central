/********************************************************************************************************
 * @file     BlobTransferStartMessage.java 
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

public class BlobTransferStartMessage extends UpdatingMessage {

    /**
     * BLOB transfer mode
     * higher 2 bits in first byte
     */
    private TransferMode transferMode = TransferMode.PUSH;

    /**
     * BLOB identifier
     * 64 bits
     */
    private long blobId;

    /**
     * BLOB size in octets
     * 32 bits
     */
    private int blobSize;

    /**
     * Indicates the block size
     * 8 bits
     */
    private int blockSizeLog;

    /**
     * MTU size supported by the client
     */
    private int clientMTUSize;


    public static BlobTransferStartMessage getSimple(int destinationAddress, int appKeyIndex,
                                                     long blobId,
                                                     int blobSize,
                                                     byte blockSizeLog,
                                                     int clientMTUSize) {
        BlobTransferStartMessage message = new BlobTransferStartMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        message.blobId = blobId;
        message.blobSize = blobSize;
        message.blockSizeLog = blockSizeLog;
        message.clientMTUSize = clientMTUSize;
        return message;
    }

    public BlobTransferStartMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getOpcode() {
        return Opcode.BLOB_TRANSFER_START.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.BLOB_TRANSFER_STATUS.value;
    }

    @Override
    public byte[] getParams() {
        final byte modeValue = (byte) (transferMode.mode << 6);

        return ByteBuffer.allocate(16).order(ByteOrder.LITTLE_ENDIAN)
                .put(modeValue)
                .putLong(blobId)
                .putInt(blobSize)
                .put((byte) blockSizeLog)
                .putShort((short) clientMTUSize).array();
    }

    public void setTransferMode(TransferMode transferMode) {
        this.transferMode = transferMode;
    }

    public void setBlobId(long blobId) {
        this.blobId = blobId;
    }

    public void setBlobSize(int blobSize) {
        this.blobSize = blobSize;
    }

    public void setBlockSizeLog(int blockSizeLog) {
        this.blockSizeLog = blockSizeLog;
    }

    public void setClientMTUSize(int clientMTUSize) {
        this.clientMTUSize = clientMTUSize;
    }
}
