/********************************************************************************************************
 * @file     LinkCloseMessage.java 
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
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatingMessage;


public class LinkCloseMessage extends RemoteProvisionMessage {


    public static final byte REASON_SUCCESS = 0x00;

    public static final byte REASON_PROHIBITED = 0x01;

    public static final byte REASON_FAIL = 0x02;

    /**
     * 1 byte
     */
    private byte reason;

    public static LinkCloseMessage getSimple(int destinationAddress, int rspMax, byte reason) {
        LinkCloseMessage message = new LinkCloseMessage(destinationAddress);
        message.setResponseMax(rspMax);
        message.reason = reason;
        return message;
    }

    public LinkCloseMessage(int destinationAddress) {
        super(destinationAddress);
    }

    @Override
    public int getOpcode() {
        return Opcode.REMOTE_PROV_LINK_CLOSE.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.REMOTE_PROV_LINK_STS.value;
    }

    @Override
    public byte[] getParams() {
        return new byte[]{reason};
    }

    public void setReason(byte reason) {
        this.reason = reason;
    }
}
