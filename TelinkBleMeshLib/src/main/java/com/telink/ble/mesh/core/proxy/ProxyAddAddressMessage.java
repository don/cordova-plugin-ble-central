/********************************************************************************************************
 * @file     ProxyAddAddressMessage.java 
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


import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import androidx.annotation.NonNull;

/**
 * Created by kee on 2019/8/26.
 */

public class ProxyAddAddressMessage extends ProxyConfigurationMessage {

    private int[] addressArray;

    public ProxyAddAddressMessage(@NonNull int[] addressArray) {
        this.addressArray = addressArray;
    }

    @Override
    public byte getOpcode() {
        return OPCODE_ADD_ADDRESS;
    }

    @Override
    public byte[] toByteArray() {
        int len = 1 + addressArray.length * 2;
        ByteBuffer buffer = ByteBuffer.allocate(len).order(ByteOrder.BIG_ENDIAN).put(getOpcode());
        for (int address : addressArray) {
            buffer.putShort((short) address);
        }
        return buffer.array();
    }
}
