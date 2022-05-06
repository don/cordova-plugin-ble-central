/********************************************************************************************************
 * @file     UnsegmentedControlMessagePDU.java 
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
package com.telink.ble.mesh.core.networking.transport.lower;

import java.nio.ByteBuffer;

/**
 * Created by kee on 2019/8/16.
 */

public class UnsegmentedControlMessagePDU extends LowerTransportPDU {

    /**
     * 1 bit
     */
    final int seg = 0;

    /**
     * 0x00 = Segment Acknowledgment
     * 0x01 to 0x7F = Opcode of the Transport Control message
     * 7 bits
     */
    private int opcode;

    /**
     * 0 ~ 88 bits
     */
    byte[] params;


    @Override
    public byte[] toByteArray() {
        byte header = (byte) ((seg << 7) | (opcode));
        if (params == null) {
            return new byte[]{header};
        }
        ByteBuffer byteBuffer = ByteBuffer.allocate(1 + params.length);
        byteBuffer.put(header).put(params);
        return byteBuffer.array();
    }



    @Override
    public int getType() {
        return TYPE_UNSEGMENTED_CONTROL_MESSAGE;
    }

    @Override
    public boolean segmented() {
        return false;
    }
}
