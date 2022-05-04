/********************************************************************************************************
 * @file     HslSetMessage.java 
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
 * include HSL set and HSL set no ack
 * by {@link #ack}
 * Created by kee on 2019/8/14.
 */
public class HslSetMessage extends GenericMessage {

    private int lightness;

    private int hue;

    private int saturation;

    // transaction id
    private byte tid = 0;

    private byte transitionTime = 0;

    private byte delay = 0;

    private boolean ack = false;

    // if contains #transitionTime and #delay
    private boolean isComplete = false;

    public static HslSetMessage getSimple(int address, int appKeyIndex, int lightness, int hue, int saturation, boolean ack, int rspMax) {
        HslSetMessage message = new HslSetMessage(address, appKeyIndex);
        message.lightness = lightness;
        message.hue = hue;
        message.saturation = saturation;
        message.ack = ack;
        message.setResponseMax(rspMax);
        return message;
    }

    public HslSetMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
        setTidPosition(6);
    }

    @Override
    public int getResponseOpcode() {
        return ack ? Opcode.LIGHT_HSL_STATUS.value : super.getResponseOpcode();
    }

    @Override
    public int getOpcode() {
        return ack ? Opcode.LIGHT_HSL_SET.value : Opcode.LIGHT_HSL_SET_NOACK.value;
    }

    @Override
    public byte[] getParams() {
        return
                isComplete ?
                        ByteBuffer.allocate(9).order(ByteOrder.LITTLE_ENDIAN)
                                .putShort((short) lightness)
                                .putShort((short) hue)
                                .putShort((short) saturation)
                                .put(tid)
                                .put(transitionTime)
                                .put(delay).array()
                        :
                        ByteBuffer.allocate(7).order(ByteOrder.LITTLE_ENDIAN)
                                .putShort((short) lightness)
                                .putShort((short) hue)
                                .putShort((short) saturation)
                                .put(tid).array();
    }

    public void setLightness(int lightness) {
        this.lightness = lightness;
    }

    public void setHue(int hue) {
        this.hue = hue;
    }

    public void setSaturation(int saturation) {
        this.saturation = saturation;
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
