/********************************************************************************************************
 * @file LightnessSetMessage.java
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date Sep. 30, 2010
 *
 * @par Copyright (c) 2010, Telink Semiconductor (Shanghai) Co., Ltd.
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

/**
 * include lightness set and lightness set no ack
 * by {@link #ack}
 * Created by kee on 2019/8/14.
 */
public class LightnessSetMessage extends GenericMessage {
    // 2 bytes
    private int lightness;

    // transaction id
    private byte tid = 0;

    private byte transitionTime = 0;

    private byte delay = 0;

    private boolean ack = false;

    private boolean isComplete = false;

    public static LightnessSetMessage getSimple(int address, int appKeyIndex, int lightness, boolean ack, int rspMax) {
        LightnessSetMessage message = new LightnessSetMessage(address, appKeyIndex);
        message.lightness = lightness;
        message.ack = ack;
        message.setResponseMax(rspMax);
        return message;
    }

    public LightnessSetMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
        setTidPosition(2);
    }

    @Override
    public int getResponseOpcode() {
        return ack ? Opcode.LIGHTNESS_STATUS.value : super.getResponseOpcode();
    }

    @Override
    public int getOpcode() {
        return ack ? Opcode.LIGHTNESS_SET.value : Opcode.LIGHTNESS_SET_NOACK.value;
    }

    @Override
    public byte[] getParams() {
        return
                isComplete ?
                        new byte[]{
                                (byte) this.lightness,
                                (byte) (this.lightness >> 8),
                                this.tid,
                                this.transitionTime,
                                this.delay
                        }
                        :
                        new byte[]{
                                (byte) this.lightness,
                                (byte) (this.lightness >> 8),
                                this.tid
                        };
    }

    public void setLightness(int lightness) {
        this.lightness = lightness;
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
