/********************************************************************************************************
 * @file     BlobTransferCancelMessage.java 
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

public class BlobTransferCancelMessage extends UpdatingMessage {

    /**
     * BLOB identifier
     * 64 bits
     */
    private long blobId;

    public static BlobTransferCancelMessage getSimple(int destinationAddress, int appKeyIndex,
                                                      long blobId) {
        BlobTransferCancelMessage message = new BlobTransferCancelMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        message.blobId = blobId;
        return message;
    }

    public BlobTransferCancelMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getOpcode() {
        return Opcode.BLOB_TRANSFER_CANCEL.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.BLOB_TRANSFER_STATUS.value;
    }

    @Override
    public byte[] getParams() {
        return ByteBuffer.allocate(16).order(ByteOrder.LITTLE_ENDIAN)
                .putLong(blobId)
                .array();
    }

    public void setBlobId(long blobId) {
        this.blobId = blobId;
    }
}
