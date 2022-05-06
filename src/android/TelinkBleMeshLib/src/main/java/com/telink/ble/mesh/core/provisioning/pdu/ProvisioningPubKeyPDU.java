/********************************************************************************************************
 * @file     ProvisioningPubKeyPDU.java 
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
package com.telink.ble.mesh.core.provisioning.pdu;


/**
 * Created by kee on 2019/7/18.
 */

public class ProvisioningPubKeyPDU implements ProvisioningStatePDU {
    private static final int LEN = 64;
    // 32 bytes
    public byte[] x;
    public byte[] y;

    private byte[] rawData;

    public static ProvisioningPubKeyPDU fromBytes(byte[] data) {
        if (data.length != LEN) return null;

        ProvisioningPubKeyPDU pubKeyPDU = new ProvisioningPubKeyPDU();
        pubKeyPDU.rawData = data;
        pubKeyPDU.x = new byte[32];
        pubKeyPDU.y = new byte[32];

        System.arraycopy(data, 0, pubKeyPDU.x, 0, 32);
        System.arraycopy(data, 32, pubKeyPDU.y, 0, 32);

        return pubKeyPDU;
    }

    @Override
    public byte[] toBytes() {
        if (rawData != null) return rawData;
        if (x == null || y == null) return null;
        byte[] re = new byte[LEN];
        System.arraycopy(x, 0, re, 0, x.length);
        System.arraycopy(y, 0, re, 32, y.length);
        return re;
    }

    @Override
    public byte getState() {
        return ProvisioningPDU.TYPE_PUBLIC_KEY;
    }
}
