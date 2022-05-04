/********************************************************************************************************
 * @file     MeshConfiguration.java 
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
package com.telink.ble.mesh.foundation;

import android.util.SparseArray;

import java.util.Arrays;

/**
 * Mesh info use when provisioning/binding/auto connecting
 * NO variable can be NULL
 * Created by kee on 2019/9/6.
 */

public class MeshConfiguration {

    /**
     * network key index
     */
    public int netKeyIndex;

    /**
     * network key
     */
    public byte[] networkKey;

    /**
     * appKeyIndex and appKey map
     */
    public SparseArray<byte[]> appKeyMap;

    /**
     * iv index
     */
    public int ivIndex;

    /**
     * sequence number used in network pdu
     */
    public int sequenceNumber;

    /**
     * provisioner address
     */
    public int localAddress;

    /**
     * unicastAddress and deviceKey map, required for mesh configuration message
     */
    public SparseArray<byte[]> deviceKeyMap;

    public int getDefaultAppKeyIndex() {
        return appKeyMap.size() > 0 ? appKeyMap.keyAt(0) : 0;
    }

    public byte[] getDefaultAppKey() {
        return appKeyMap.size() > 0 ? appKeyMap.valueAt(0) : null;
    }
}
