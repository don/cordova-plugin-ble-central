/********************************************************************************************************
 * @file     ProvisioningPduSendMessage.java 
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


import java.nio.ByteBuffer;

public class ProvisioningPduSendMessage extends RemoteProvisionMessage {

    private byte outboundPDUNumber;

    /**
     * 16 bytes
     */
    private byte[] provisioningPDU;

    /**
     * @param destinationAddress server address
     */
    public static ProvisioningPduSendMessage getSimple(int destinationAddress, int rspMax,
                                                       byte outboundPDUNumber,
                                                       byte[] provisioningPDU) {
        ProvisioningPduSendMessage message = new ProvisioningPduSendMessage(destinationAddress);
        message.setResponseMax(rspMax);
        message.outboundPDUNumber = outboundPDUNumber;
        message.provisioningPDU = provisioningPDU;
        return message;
    }

    public ProvisioningPduSendMessage(int destinationAddress) {
        super(destinationAddress);
    }

    @Override
    public int getOpcode() {
        return Opcode.REMOTE_PROV_PDU_SEND.value;
    }

    @Override
    public int getResponseOpcode() {
        return OPCODE_INVALID;
//        return Opcode.REMOTE_PROV_PDU_OUTBOUND_REPORT.value;
    }

    @Override
    public byte[] getParams() {
        return ByteBuffer.allocate(1 + provisioningPDU.length)
                .put(outboundPDUNumber)
                .put(provisioningPDU).array();
    }

    public void setOutboundPDUNumber(byte outboundPDUNumber) {
        this.outboundPDUNumber = outboundPDUNumber;
    }

    public void setProvisioningPDU(byte[] provisioningPDU) {
        this.provisioningPDU = provisioningPDU;
    }
}
