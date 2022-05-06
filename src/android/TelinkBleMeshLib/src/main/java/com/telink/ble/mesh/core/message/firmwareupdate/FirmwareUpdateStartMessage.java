/********************************************************************************************************
 * @file     FirmwareUpdateStartMessage.java 
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
package com.telink.ble.mesh.core.message.firmwareupdate;

import com.telink.ble.mesh.core.message.Opcode;


import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class FirmwareUpdateStartMessage extends UpdatingMessage {

    /**
     * default ttl
     */
    public static final byte DEFAULT_UPDATE_TTL = 10;

    /**
     * Time To Live value to use during firmware image transfer
     * 1 byte
     */
    private byte updateTtl = DEFAULT_UPDATE_TTL;

    /**
     * Used to compute the timeout of the firmware image transfer
     * Client Timeout = [12,000 * (Client Timeout Base + 1) + 100 * Transfer TTL] milliseconds
     * using blockSize
     * 2 bytes
     */
    private int updateTimeoutBase;

    /**
     * BLOB identifier for the firmware image
     * 8 bytes
     */
    private long updateBLOBID;

    /**
     * Index of the firmware image in the Firmware Information List state to be updated
     * 1 byte
     */
    private int updateFirmwareImageIndex;

    /**
     * Vendor-specific firmware metadata
     * If the value of the Incoming Firmware Metadata Length field is greater than 0,
     * the Incoming Firmware Metadata field shall be present.
     * 1-255 bytes
     */
    private byte[] metadata;

    public static FirmwareUpdateStartMessage getSimple(int destinationAddress, int appKeyIndex,
                                                       int updateTimeoutBase, long blobId, byte[] metadata) {
        FirmwareUpdateStartMessage message = new FirmwareUpdateStartMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        message.updateTimeoutBase = updateTimeoutBase;
        message.updateBLOBID = blobId;
        message.updateFirmwareImageIndex = 0;
        message.metadata = metadata;
        return message;
    }

    public FirmwareUpdateStartMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getOpcode() {
        return Opcode.FIRMWARE_UPDATE_START.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.FIRMWARE_UPDATE_STATUS.value;
    }

    @Override
    public byte[] getParams() {
        final int len = 12 + metadata.length;
        ByteBuffer bf = ByteBuffer.allocate(len).order(ByteOrder.LITTLE_ENDIAN)
                .put(updateTtl).putShort((short) updateTimeoutBase)
                .putLong(updateBLOBID).put((byte) updateFirmwareImageIndex).put(metadata);
        return bf.array();
    }

    public void setUpdateTtl(byte updateTtl) {
        this.updateTtl = updateTtl;
    }

    public void setUpdateTimeoutBase(int updateTimeoutBase) {
        this.updateTimeoutBase = updateTimeoutBase;
    }

    public void setUpdateBLOBID(long updateBLOBID) {
        this.updateBLOBID = updateBLOBID;
    }

    public void setUpdateFirmwareImageIndex(int updateFirmwareImageIndex) {
        this.updateFirmwareImageIndex = updateFirmwareImageIndex;
    }

    public void setMetadata(byte[] metadata) {
        this.metadata = metadata;
    }
}
