/********************************************************************************************************
 * @file     MoveSetMessage.java 
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

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * Created by kee on 2019/8/20.
 */

public class MoveSetMessage extends GenericMessage {

    private int deltaLevel;

    private byte tid;

    private byte transitionTime;

    private byte delay;

    private boolean ack;

    private boolean isComplete = false;

    public MoveSetMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
        setTidPosition(2);
    }


    @Override
    public int getOpcode() {
        return ack ? Opcode.G_MOVE_SET.value : Opcode.G_MOVE_SET_NOACK.value;
    }

    @Override
    public byte[] getParams() {
        return
                isComplete ?
                        ByteBuffer.allocate(5)
                                .order(ByteOrder.LITTLE_ENDIAN)
                                .putShort((short) deltaLevel)
                                .put(tid).put(transitionTime).put(delay).array()
                        :
                        ByteBuffer.allocate(3)
                                .order(ByteOrder.LITTLE_ENDIAN)
                                .putShort((short) deltaLevel)
                                .put(tid).array();
    }

    public void setDeltaLevel(int deltaLevel) {
        this.deltaLevel = deltaLevel;
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
