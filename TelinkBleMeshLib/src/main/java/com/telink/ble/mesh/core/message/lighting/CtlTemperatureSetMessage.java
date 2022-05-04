/********************************************************************************************************
 * @file     CtlTemperatureSetMessage.java 
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
import com.telink.ble.mesh.core.message.generic.GenericMessage;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * include CLT Temperature set and CTL Temperature set no ack
 * by {@link #ack}
 * Created by kee on 2019/8/14.
 */
public class CtlTemperatureSetMessage extends GenericMessage {

    private int temperature;

    private int deltaUV;

    // transaction id
    private byte tid = 0;

    private byte transitionTime = 0;

    private byte delay = 0;

    private boolean ack = false;

    private boolean isComplete = false;

    public static CtlTemperatureSetMessage getSimple(int address, int appKeyIndex, int temperature, int deltaUV, boolean ack, int rspMax) {
        CtlTemperatureSetMessage message = new CtlTemperatureSetMessage(address, appKeyIndex);
        message.temperature = temperature;
        message.deltaUV = deltaUV;
        message.ack = ack;
        message.setResponseMax(rspMax);
        return message;
    }

    public CtlTemperatureSetMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
        setTidPosition(4);
    }

    @Override
    public int getResponseOpcode() {
        return ack ? Opcode.LIGHT_CTL_TEMP_STATUS.value : super.getResponseOpcode();
    }

    @Override
    public int getOpcode() {
        return ack ? Opcode.LIGHT_CTL_TEMP_SET.value : Opcode.LIGHT_CTL_TEMP_SET_NOACK.value;
    }

    @Override
    public byte[] getParams() {
        return
                isComplete ?
                        ByteBuffer.allocate(7).order(ByteOrder.LITTLE_ENDIAN)
                                .putShort((short) temperature)
                                .putShort((short) deltaUV)
                                .put(tid)
                                .put(transitionTime)
                                .put(delay).array()
                        :
                        ByteBuffer.allocate(5).order(ByteOrder.LITTLE_ENDIAN)
                                .putShort((short) temperature)
                                .putShort((short) deltaUV)
                                .put(tid).array();
    }

    public void setTemperature(int temperature) {
        this.temperature = temperature;
    }

    public void setDeltaUV(int deltaUV) {
        this.deltaUV = deltaUV;
    }

    public void setTid(byte tid) {
        this.tid = tid;
    }

    public void setTransitionTime(byte transitionTime) {
        this.transitionTime = transitionTime;
    }

    public void setDelay(byte delay) {
        this.delay = delay;
    }

    public void setAck(boolean ack) {
        this.ack = ack;
    }

    public void setComplete(boolean complete) {
        isComplete = complete;
    }
}
