/********************************************************************************************************
 * @file     ScanStartMessage.java 
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
package com.telink.ble.mesh.core.message.rp;

import com.telink.ble.mesh.core.message.Opcode;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class ScanStartMessage extends RemoteProvisionMessage {

    /**
     * 1 bytes
     */
    private byte scannedItemsLimit;

    /**
     * 1 bytes
     */
    private byte timeout;

    /**
     * Device UUID (Optional)
     */
    private byte[] uuid;

    public static ScanStartMessage getSimple(int destinationAddress, int rspMax, byte scannedItemsLimit, byte timeout) {
        ScanStartMessage message = new ScanStartMessage(destinationAddress);
        message.setResponseMax(rspMax);
        message.scannedItemsLimit = scannedItemsLimit;
        message.timeout = timeout;
        return message;
    }

    public ScanStartMessage(int destinationAddress) {
        super(destinationAddress);
    }

    @Override
    public int getOpcode() {
        return Opcode.REMOTE_PROV_SCAN_START.value;
    }

    @Override
    public int getResponseOpcode() {
//        return Opcode.REMOTE_PROV_SCAN_STS.value;
        return super.getResponseOpcode();
    }

    @Override
    public byte[] getParams() {
        int len = uuid == null ? 2 : 18;
        ByteBuffer bf = ByteBuffer.allocate(len).order(ByteOrder.LITTLE_ENDIAN)
                .put(scannedItemsLimit).put(timeout);
        if (uuid != null) {
            bf.put(uuid);
        }
        return bf.array();
    }

    public void setScannedItemsLimit(byte scannedItemsLimit) {
        this.scannedItemsLimit = scannedItemsLimit;
    }

    public void setTimeout(byte timeout) {
        this.timeout = timeout;
    }

    public void setUuid(byte[] uuid) {
        this.uuid = uuid;
    }
}
