/********************************************************************************************************
 * @file ProvisioningPubKeyPDU.java
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


import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.util.Arrays;

import java.nio.ByteOrder;

/**
 * Created by kee on 2019/7/18.
 */

public class ProvisioningRecordResponsePDU implements ProvisioningStatePDU {


    /**
     * status success
     */
    public static final byte STATUS_SUCCESS = 0x00;

    /**
     * status Requested Record Is Not Present
     */
    public static final byte STATUS_RECORD_NOT_PRESENT = 0x01;

    /**
     * status Requested Offset Is Out Of Bounds
     */
    public static final byte STATUS_OFFSET_OUT_OF_BOUNDS = 0x02;

    public byte[] rawData;
    /**
     * Indicates whether or not the request was handled successfully
     */
    public byte status;

    /**
     *
     */
    public int recordID;

    public int fragmentOffset;

    public int totalLength;

    public byte[] data;


    public static ProvisioningRecordResponsePDU fromBytes(byte[] data) {

        int index = 0;
        ProvisioningRecordResponsePDU responsePDU = new ProvisioningRecordResponsePDU();
        responsePDU.rawData = data;
        responsePDU.status = data[index++];
        responsePDU.recordID = MeshUtils.bytes2Integer(data, index, 2, ByteOrder.BIG_ENDIAN);
        index += 2;

        responsePDU.fragmentOffset = MeshUtils.bytes2Integer(data, index, 2, ByteOrder.BIG_ENDIAN);
        index += 2;

        responsePDU.totalLength = MeshUtils.bytes2Integer(data, index, 2, ByteOrder.BIG_ENDIAN);
        index += 2;

        responsePDU.data = new byte[data.length - index];
        System.arraycopy(data, index, responsePDU.data, 0, responsePDU.data.length);
        return responsePDU;
    }


    @Override
    public byte getState() {
        return ProvisioningPDU.TYPE_RECORD_RESPONSE;
    }

    @Override
    public byte[] toBytes() {
        return rawData;
    }

    @Override
    public String toString() {
        return "ProvisioningRecordResponsePDU{" +
                "status=" + status +
                ", recordID=" + recordID +
                ", fragmentOffset=" + fragmentOffset +
                ", totalLength=" + totalLength +
                ", data=" + Arrays.bytesToHexString(data) +
                '}';
    }
}
