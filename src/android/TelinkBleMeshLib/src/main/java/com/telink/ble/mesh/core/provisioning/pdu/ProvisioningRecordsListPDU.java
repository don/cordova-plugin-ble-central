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

import java.io.ByteArrayInputStream;
import java.nio.ByteOrder;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.List;


/**
 * Created by kee on 2019/7/18.
 */

public class ProvisioningRecordsListPDU implements ProvisioningStatePDU {


    public byte[] rawData;
    /**
     * Bitmask indicating the provisioning extensions supported by the device
     * 2 bytes
     */
    public int provisioningExtensions;

    /**
     * Lists the Record IDs of the provisioning records stored on the device
     */
    public List<Integer> recordsList;

    public static ProvisioningRecordsListPDU fromBytes(byte[] data) {

        int index = 0;
        ProvisioningRecordsListPDU recordsListPDU = new ProvisioningRecordsListPDU();
        recordsListPDU.rawData = data;
        recordsListPDU.provisioningExtensions = MeshUtils.bytes2Integer(data, index, 2, ByteOrder.BIG_ENDIAN);
        index += 2;

        if (data.length > index) {
            final int listSize = (data.length - index) / 2;
            recordsListPDU.recordsList = new ArrayList<>(listSize);
            int recordID;
            for (int i = 0; i < listSize; i++) {
                recordID = MeshUtils.bytes2Integer(data, index, 2, ByteOrder.BIG_ENDIAN);
                recordsListPDU.recordsList.add(recordID);
                index += 2;
            }
        }
        return recordsListPDU;

    }


    @Override
    public byte getState() {
        return ProvisioningPDU.TYPE_RECORDS_LIST;
    }

    @Override
    public byte[] toBytes() {
        return rawData;
    }
}
