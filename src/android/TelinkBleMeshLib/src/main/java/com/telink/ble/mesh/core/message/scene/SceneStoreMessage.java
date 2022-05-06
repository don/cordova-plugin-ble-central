/********************************************************************************************************
 * @file     SceneStoreMessage.java 
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

/**
 * scene store
 * Created by kee on 2019/8/14.
 */
public class SceneStoreMessage extends GenericMessage {

    // scene id
    private int sceneNumber;

    private boolean ack;

    public static SceneStoreMessage getSimple(int address, int appKeyIndex, int sceneNumber, boolean ack, int rspMax) {
        SceneStoreMessage message = new SceneStoreMessage(address, appKeyIndex);
        message.sceneNumber = sceneNumber;
        message.ack = ack;
        message.setResponseMax(rspMax);
        return message;
    }

    public SceneStoreMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getResponseOpcode() {
        return ack ? Opcode.SCENE_REG_STATUS.value : super.getResponseOpcode();
    }

    @Override
    public int getOpcode() {
        return ack ? Opcode.SCENE_STORE.value : Opcode.SCENE_STORE_NOACK.value;
    }

    @Override
    public byte[] getParams() {
        return new byte[]{(byte) sceneNumber, (byte) (sceneNumber >> 8)};
    }

    public void setSceneNumber(int sceneNumber) {
        this.sceneNumber = sceneNumber;
    }

    public void setAck(boolean ack) {
        this.ack = ack;
    }
}
