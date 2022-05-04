/********************************************************************************************************
 * @file AppKeyAddMessage.java
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
package com.telink.ble.mesh.core.message.config;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.Opcode;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * Created by kee on 2021/1/14.
 */
public class BridgingTableAddMessage extends ConfigMessage {

    /**
     * Allowed directions for the bridged traffic
     * 8 bits
     */
    public byte directions;

    /**
     * NetKey Index of the first subnet
     * 12 bits
     */
    public int netKeyIndex1;

    /**
     * NetKey Index of the second subnet
     * 12 bits
     */
    public int netKeyIndex2;

    /**
     * Address of the node in the first subnet
     * 16 bits
     */
    public int address1;

    /**
     * Address of the node in the second subnet
     * 16 bits
     */
    public int address2;


    public BridgingTableAddMessage(int destinationAddress) {
        super(destinationAddress);
    }

    @Override
    public int getOpcode() {
        return Opcode.BRIDGING_TABLE_ADD.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.BRIDGING_TABLE_STATUS.value;
    }

    @Override
    public byte[] getParams() {
        int netKeyIndexes = (netKeyIndex1 & 0x0FFF) | ((netKeyIndex2 & 0x0FFF) << 12);
        byte[] indexesBuf = MeshUtils.integer2Bytes(netKeyIndexes, 3, ByteOrder.LITTLE_ENDIAN);
        return ByteBuffer.allocate(8).order(ByteOrder.LITTLE_ENDIAN)
                .put(directions)
                .put(indexesBuf)
                .putShort((short) address1)
                .putShort((short) address2).array();
    }


}
