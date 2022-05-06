/********************************************************************************************************
 * @file     SchedulerActionSetMessage.java 
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
import com.telink.ble.mesh.entity.Scheduler;

/**
 * include Scheduler Action set and Scheduler Action set no ack
 * by {@link #ack}
 * Created by kee on 2019/8/14.
 */
public class SchedulerActionSetMessage extends GenericMessage {

    private Scheduler scheduler;

    private boolean ack = false;

    public static SchedulerActionSetMessage getSimple(int address, int appKeyIndex, Scheduler scheduler, boolean ack, int rspMax) {
        SchedulerActionSetMessage message = new SchedulerActionSetMessage(address, appKeyIndex);
        message.scheduler = scheduler;
        message.ack = ack;
        message.setResponseMax(rspMax);
        return message;
    }

    public SchedulerActionSetMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getResponseOpcode() {
        return ack ? Opcode.SCHD_ACTION_STATUS.value : super.getResponseOpcode();
    }

    @Override
    public int getOpcode() {
        return ack ? Opcode.SCHD_ACTION_SET.value : Opcode.SCHD_ACTION_SET_NOACK.value;
    }

    @Override
    public byte[] getParams() {
        return scheduler.toBytes();
    }

    public void setScheduler(Scheduler scheduler) {
        this.scheduler = scheduler;
    }

    public void setAck(boolean ack) {
        this.ack = ack;
    }
}
