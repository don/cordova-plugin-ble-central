/********************************************************************************************************
 * @file     SceneRegisterStatusMessage.java 
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

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.StatusMessage;

import java.nio.ByteOrder;

/**
 * Created by kee on 2019/8/20.
 */

public class SceneRegisterStatusMessage extends StatusMessage implements Parcelable {

    private byte statusCode;

    private int currentScene;

    private int[] scenes;

    public SceneRegisterStatusMessage() {
    }

    protected SceneRegisterStatusMessage(Parcel in) {
        statusCode = in.readByte();
        currentScene = in.readInt();
        scenes = in.createIntArray();
    }

    public static final Creator<SceneRegisterStatusMessage> CREATOR = new Creator<SceneRegisterStatusMessage>() {
        @Override
        public SceneRegisterStatusMessage createFromParcel(Parcel in) {
            return new SceneRegisterStatusMessage(in);
        }

        @Override
        public SceneRegisterStatusMessage[] newArray(int size) {
            return new SceneRegisterStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        this.statusCode = params[index++];
        this.currentScene = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        int rst = params.length - index;
        if (rst > 0 && rst % 2 == 0) {
            scenes = new int[rst / 2];
            for (int i = 0; i < scenes.length; i++) {
                scenes[i] = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
                index += 2;
            }
        }
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte(statusCode);
        dest.writeInt(currentScene);
        dest.writeIntArray(scenes);
    }

    public byte getStatusCode() {
        return statusCode;
    }

    public int getCurrentScene() {
        return currentScene;
    }

    public int[] getScenes() {
        return scenes;
    }
}
