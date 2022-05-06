/********************************************************************************************************
 * @file     ProxyConfigurationPDU.java 
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
package com.telink.ble.mesh.core.proxy;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.networking.NetworkLayerPDU;
import com.telink.ble.mesh.core.networking.NonceGenerator;

import java.nio.ByteOrder;

/**
 * Created by kee on 2019/8/26.
 */

public class ProxyConfigurationPDU extends NetworkLayerPDU {

    public static final byte ctl = 1;

    public static final byte ttl = 0;

    public static final byte dst = 0x00;

    public ProxyConfigurationPDU(NetworkEncryptionSuite encryptionSuite) {
        super(encryptionSuite);
    }

    @Override
    protected byte[] generateNonce() {
        byte[] seqNo = MeshUtils.integer2Bytes(getSeq(), 3, ByteOrder.BIG_ENDIAN);
        return NonceGenerator.generateProxyNonce(seqNo, getSrc(), this.encryptionSuite.ivIndex);
    }
}
