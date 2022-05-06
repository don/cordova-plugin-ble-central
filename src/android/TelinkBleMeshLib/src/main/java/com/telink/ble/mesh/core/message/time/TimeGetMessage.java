/********************************************************************************************************
 * @file     TimeGetMessage.java 
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
package com.telink.ble.mesh.core.message.time;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.lighting.LightingMessage;

/**
 * Created by kee on 2019/9/19.
 */

public class TimeGetMessage extends LightingMessage {

    public static TimeGetMessage getSimple(int destinationAddress, int appKeyIndex, int rspMax) {
        TimeGetMessage message = new TimeGetMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(rspMax);
        return message;
    }

    public TimeGetMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getOpcode() {
        return Opcode.TIME_STATUS.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.TIME_STATUS.value;
    }
}
