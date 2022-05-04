/********************************************************************************************************
 * @file     LinkOpenMessage.java 
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
package com.telink.ble.mesh.core.message.rp;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.generic.GenericMessage;


public class LinkOpenMessage extends RemoteProvisionMessage {

    /**
     * 16 bytes
     */
    private byte[] uuid;

    public static LinkOpenMessage getSimple(int destinationAddress, int rspMax, byte[] uuid) {
        LinkOpenMessage message = new LinkOpenMessage(destinationAddress);
        message.setResponseMax(rspMax);
        message.uuid = uuid;
        return message;
    }

    public LinkOpenMessage(int destinationAddress) {
        super(destinationAddress);
    }

    @Override
    public int getOpcode() {
        return Opcode.REMOTE_PROV_LINK_OPEN.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.REMOTE_PROV_LINK_STS.value;
    }

    @Override
    public byte[] getParams() {
        return uuid;
    }

    public void setUuid(byte[] uuid) {
        this.uuid = uuid;
    }
}
