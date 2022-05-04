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

import com.telink.ble.mesh.core.message.Opcode;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * Created by kee on 2019/8/12.
 */

public class NetKeyAddMessage extends ConfigMessage {


    public int netKeyIndex;

    public byte[] netKey;


    public NetKeyAddMessage(int destinationAddress) {
        super(destinationAddress);
    }

    public NetKeyAddMessage(int destinationAddress, int netKeyIndex, byte[] netKey) {
        super(destinationAddress);
        this.netKeyIndex = netKeyIndex;
        this.netKey = netKey;
    }

    @Override
    public int getOpcode() {
        return Opcode.NETKEY_ADD.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.NETKEY_STATUS.value;
    }

    @Override
    public byte[] getParams() {
        ByteBuffer paramsBuffer = ByteBuffer.allocate(2 + 16).order(ByteOrder.LITTLE_ENDIAN)
                .putShort((short) this.netKeyIndex)
                .put(netKey);
        return paramsBuffer.array();
    }


}
