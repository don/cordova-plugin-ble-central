/********************************************************************************************************
 * @file     OnOffGetMessage.java 
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
package com.telink.ble.mesh.core.message.generic;

import com.telink.ble.mesh.core.message.Opcode;

/**
 * Created by kee on 2019/8/20.
 */

public class OnOffGetMessage extends GenericMessage {


    public static OnOffGetMessage getSimple(int destinationAddress, int appKeyIndex, int rspMax) {
        OnOffGetMessage message = new OnOffGetMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(rspMax);
        return message;
    }

    public OnOffGetMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getOpcode() {
        return Opcode.G_ONOFF_GET.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.G_ONOFF_STATUS.value;
    }

    @Override
    public byte[] getParams() {
        return null;
    }

}
