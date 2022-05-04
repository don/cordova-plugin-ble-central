/********************************************************************************************************
 * @file     SceneRecallMessage.java 
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
package com.telink.ble.mesh.core.message.scene;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.generic.GenericMessage;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * SCENE recall and XX no ack
 * by {@link #ack}
 * Created by kee on 2019/8/14.
 */
public class SceneRecallMessage extends GenericMessage {

    private int sceneNumber;

    // transition id
    private byte tid = 0;

    private byte transitionTime = 0;

    private byte delay = 0;

    private boolean ack = false;

    private boolean isComplete = false;

    public static SceneRecallMessage getSimple(int address, int appKeyIndex, int sceneNumber, boolean ack, int rspMax) {
        SceneRecallMessage message = new SceneRecallMessage(address, appKeyIndex);
        message.sceneNumber = sceneNumber;
        message.ack = ack;
        message.setResponseMax(rspMax);
        return message;
    }

    public SceneRecallMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
        setTidPosition(2);
    }

    @Override
    public int getResponseOpcode() {
        return ack ? Opcode.SCENE_STATUS.value : super.getResponseOpcode();
    }

    @Override
    public int getOpcode() {
        return ack ? Opcode.SCENE_RECALL.value : Opcode.SCENE_RECALL_NOACK.value;
    }

    @Override
    public byte[] getParams() {
        return
                isComplete ?
                        ByteBuffer.allocate(5).order(ByteOrder.LITTLE_ENDIAN)
                                .putShort((short) sceneNumber)
                                .put(tid)
                                .put(transitionTime)
                                .put(delay).array()
                        :
                        ByteBuffer.allocate(3).order(ByteOrder.LITTLE_ENDIAN)
                                .putShort((short) sceneNumber)
                                .put(tid).array();
    }

    public void setSceneNumber(int sceneNumber) {
        this.sceneNumber = sceneNumber;
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
