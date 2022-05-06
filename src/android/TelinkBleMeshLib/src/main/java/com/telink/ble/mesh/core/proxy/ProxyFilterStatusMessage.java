/********************************************************************************************************
 * @file     ProxyFilterStatusMessage.java 
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

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * Created by kee on 2019/8/26.
 */
public class ProxyFilterStatusMessage extends ProxyConfigurationMessage {

    private static final int DATA_LEN = 4;
    /**
     * White list or black list.
     */
    private byte filterType;

    /**
     * Number of addresses in the proxy filter list.
     */
    private int listSize;

    public static ProxyFilterStatusMessage fromBytes(byte[] data) {
        if (data.length != DATA_LEN) {
            return null;
        }
        ProxyFilterStatusMessage instance = new ProxyFilterStatusMessage();
        int index = 0;
        byte opcode = data[index++];
        if (opcode != OPCODE_FILTER_STATUS) return null;
        instance.filterType = data[index++];
        instance.listSize = MeshUtils.bytes2Integer(data, index, 2, ByteOrder.BIG_ENDIAN);
        return instance;
    }

    @Override
    public byte getOpcode() {
        return OPCODE_FILTER_STATUS;
    }

    @Override
    public byte[] toByteArray() {
        return ByteBuffer.allocate(DATA_LEN)
                .order(ByteOrder.BIG_ENDIAN)
                .put(filterType)
                .putShort((short) listSize)
                .array();
    }

    public byte getFilterType() {
        return filterType;
    }

    public int getListSize() {
        return listSize;
    }
}
