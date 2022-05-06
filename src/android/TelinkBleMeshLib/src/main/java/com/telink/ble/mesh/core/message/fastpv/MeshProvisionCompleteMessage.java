/********************************************************************************************************
 * @file     MeshProvisionCompleteMessage.java 
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
package com.telink.ble.mesh.core.message.fastpv;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.generic.GenericMessage;


import java.nio.ByteOrder;

public class MeshProvisionCompleteMessage extends GenericMessage {

    /**
     * milliseconds
     * 2 bytes
     */
    private int delay;

    public static MeshProvisionCompleteMessage getSimple(int destinationAddress, int appKeyIndex, int delay) {
        MeshProvisionCompleteMessage message = new MeshProvisionCompleteMessage(destinationAddress, appKeyIndex);
        message.delay = delay;
        return message;
    }

    public MeshProvisionCompleteMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getOpcode() {
        return Opcode.VD_MESH_PROV_COMPLETE.value;
    }

    @Override
    public int getResponseOpcode() {
        return OPCODE_INVALID;
    }

    @Override
    public byte[] getParams() {
        return MeshUtils.integer2Bytes(delay, 2, ByteOrder.LITTLE_ENDIAN);
    }

    public void setDelay(int delay) {
        this.delay = delay;
    }
}
