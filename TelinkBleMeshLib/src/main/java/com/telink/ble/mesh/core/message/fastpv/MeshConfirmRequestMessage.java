/********************************************************************************************************
 * @file     MeshConfirmRequestMessage.java 
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

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.generic.GenericMessage;


public class MeshConfirmRequestMessage extends GenericMessage {

    public static MeshConfirmRequestMessage getSimple(int destinationAddress, int appKeyIndex) {
        MeshConfirmRequestMessage message = new MeshConfirmRequestMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(0);
        message.setRetryCnt(1);
        return message;
    }

    public MeshConfirmRequestMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getOpcode() {
        return Opcode.VD_MESH_PROV_CONFIRM.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.VD_MESH_PROV_CONFIRM_STS.value;
    }

    @Override
    public byte[] getParams() {
        return null;
    }

}
