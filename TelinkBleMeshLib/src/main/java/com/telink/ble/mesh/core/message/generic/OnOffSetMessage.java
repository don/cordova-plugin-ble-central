/********************************************************************************************************
 * @file     OnOffSetMessage.java 
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
 * include on off set and on off set no ack
 * by {@link #ack}
 * Created by kee on 2019/8/14.
 */
public class OnOffSetMessage extends GenericMessage {

    public static final byte ON = 1;

    public static final byte OFF = 0;

    // 1: on, 0: off
    private byte onOff;

    private byte tid = 0;

    private byte transitionTime = 0;

    private byte delay = 0;

    private boolean ack = false;

    private boolean isComplete = false;

    public static OnOffSetMessage getSimple(int address, int appKeyIndex, int onOff, boolean ack, int rspMax) {
        OnOffSetMessage message = new OnOffSetMessage(address, appKeyIndex);
        message.onOff = (byte) onOff;
        message.ack = ack;
        message.setTidPosition(1);
        message.setResponseMax(rspMax);
        // for test
        //        message.ack = false;
//        message.isComplete = true;
        return message;
    }

    public OnOffSetMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getResponseOpcode() {
        return ack ? Opcode.G_ONOFF_STATUS.value : super.getResponseOpcode();
    }

    @Override
    public int getOpcode() {
        return ack ? Opcode.G_ONOFF_SET.value : Opcode.G_ONOFF_SET_NOACK.value;
    }

    @Override
    public byte[] getParams() {
        /*byte[] realParams = isComplete ?
                new byte[]{
                        this.onOff,
                        this.tid,
                        this.transitionTime,
                        this.delay
                }
                :
                new byte[]{
                        this.onOff,
                        this.tid
                }
                ;
        byte[] params = new byte[378];
        System.arraycopy(realParams, 0, params, 0, realParams.length);
        return params;*/
        return
                isComplete ?
                        new byte[]{
                                this.onOff,
                                this.tid,
                                this.transitionTime,
                                this.delay
                        }
                        :
                        new byte[]{
                                this.onOff,
                                this.tid
                        }
                ;
    }

    public void setOnOff(byte onOff) {
        this.onOff = onOff;
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
