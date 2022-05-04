/********************************************************************************************************
 * @file     HslGetMessage.java 
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
package com.telink.ble.mesh.core.message.lighting;

import com.telink.ble.mesh.core.message.Opcode;

/**
 * Created by kee on 2019/9/19.
 */

public class HslGetMessage extends LightingMessage {

    public static HslGetMessage getSimple(int destinationAddress, int appKeyIndex, int rspMax) {
        HslGetMessage message = new HslGetMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(rspMax);
        return message;
    }

    public HslGetMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getOpcode() {
        return Opcode.LIGHT_HSL_GET.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.LIGHT_HSL_STATUS.value;
    }
}
