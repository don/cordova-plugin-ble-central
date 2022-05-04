/********************************************************************************************************
 * @file     MeshSetAddressMessage.java 
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


import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class MeshSetAddressMessage extends GenericMessage {

    private byte[] mac;
    private int newMeshAddress;

    public static MeshSetAddressMessage getSimple(int destinationAddress, int appKeyIndex, byte[] mac, int newMeshAddress) {
        MeshSetAddressMessage message = new MeshSetAddressMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        message.mac = mac;
        message.newMeshAddress = newMeshAddress;
        return message;
    }

    public MeshSetAddressMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getOpcode() {
        return Opcode.VD_MESH_ADDR_SET.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.VD_MESH_ADDR_SET_STS.value;
    }

    @Override
    public byte[] getParams() {
        return ByteBuffer.allocate(8).order(ByteOrder.LITTLE_ENDIAN).put(mac).putShort((short) newMeshAddress).array();
    }

    public void setMac(byte[] mac) {
        this.mac = mac;
    }

    public void setNewMeshAddress(int newMeshAddress) {
        this.newMeshAddress = newMeshAddress;
    }
}
