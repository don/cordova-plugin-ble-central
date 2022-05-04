/********************************************************************************************************
 * @file     ProvisioningInvitePDU.java 
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
package com.telink.ble.mesh.core.provisioning.pdu;

/**
 * Created by kee on 2019/7/19.
 */

public class ProvisioningInvitePDU implements ProvisioningStatePDU {


    // Attention Timer state
    public byte attentionDuration;

    public ProvisioningInvitePDU(byte attentionDuration) {
        this.attentionDuration = attentionDuration;
    }

    @Override
    public byte[] toBytes() {
        return new byte[]{attentionDuration};
    }

    @Override
    public byte getState() {
        return ProvisioningPDU.TYPE_INVITE;
    }
}
