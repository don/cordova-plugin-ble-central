/********************************************************************************************************
 * @file     HeartbeatStatus.java 
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
package com.telink.ble.mesh.core.message;

import com.telink.ble.mesh.core.MeshUtils;

import java.nio.ByteOrder;

/**
 * Created by kee on 2019/8/23.
 */
public class HeartbeatStatus {

    /**
     * Reserved for Future Use
     */
    private int rfu;

    /**
     * 7 bits
     * Initial TTL used when sending the message
     */
    private int initTTL;

    /**
     * Bit field of currently active features of the node
     */
    private int features;

    public void parse(byte[] transportPdu) {
        this.rfu = (transportPdu[0] & 0xFF) >> 7;
        this.initTTL = transportPdu[0] & 0x7F;
        this.features = MeshUtils.bytes2Integer(new byte[]{transportPdu[1], transportPdu[2]},
                ByteOrder.BIG_ENDIAN);
    }


    public int getRfu() {
        return rfu;
    }

    public int getInitTTL() {
        return initTTL;
    }

    public int getFeatures() {
        return features;
    }
}
