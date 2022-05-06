/********************************************************************************************************
 * @file ProvisioningRecordRequestPDU.java
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date Sep. 30, 2010
 *
 * @par Copyright (c) 2010, Telink Semiconductor (Shanghai) Co., Ltd.
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
package com.telink.ble.mesh.core.provisioning.pdu;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * The Provisioner sends a Provisioning Record Request PDU to request a provisioning record fragment
 */
public class ProvisioningRecordRequestPDU implements ProvisioningStatePDU {

    /**
     * Identifies the provisioning record for which the request is made
     * 2 bytes
     */
    public int recordID;

    /**
     * The starting offset of the requested fragment in the provisioning record data
     * 2 bytes
     */
    public int fragmentOffset;

    /**
     * The maximum size of the provisioning record fragment that the Provisioner can receive
     * 2 bytes
     */
    public int fragmentMaxSize;


    public ProvisioningRecordRequestPDU(int recordID, int fragmentOffset, int fragmentMaxSize) {
        this.recordID = recordID;
        this.fragmentOffset = fragmentOffset;
        this.fragmentMaxSize = fragmentMaxSize;
    }

    @Override
    public byte[] toBytes() {
        return ByteBuffer.allocate(6).order(ByteOrder.BIG_ENDIAN).putShort((short) recordID)
                .putShort((short) fragmentOffset)
                .putShort((short) fragmentMaxSize).array();
    }

    @Override
    public byte getState() {
        return ProvisioningPDU.TYPE_RECORD_REQUEST;
    }
}
