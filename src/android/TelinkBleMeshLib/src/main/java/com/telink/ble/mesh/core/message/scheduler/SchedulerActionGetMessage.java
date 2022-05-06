/********************************************************************************************************
 * @file     SchedulerActionGetMessage.java 
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
package com.telink.ble.mesh.core.message.scheduler;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.generic.GenericMessage;

/**
 * scheduler action get
 * Created by kee on 2019/8/14.
 */
public class SchedulerActionGetMessage extends GenericMessage {

    // scene id
    private byte index;


    public static SchedulerActionGetMessage getSimple(int address, int appKeyIndex, byte schedulerIndex, int rspMax) {
        SchedulerActionGetMessage message = new SchedulerActionGetMessage(address, appKeyIndex);
        message.index = schedulerIndex;
        message.setResponseMax(rspMax);
        return message;
    }

    public SchedulerActionGetMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.SCHD_ACTION_STATUS.value;
    }

    @Override
    public int getOpcode() {
        return Opcode.SCHD_ACTION_GET.value;
    }

    @Override
    public byte[] getParams() {
        return new byte[]{index};
    }

    public void setIndex(byte index) {
        this.index = index;
    }
}
