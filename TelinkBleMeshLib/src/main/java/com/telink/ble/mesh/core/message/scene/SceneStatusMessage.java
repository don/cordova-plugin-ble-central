/********************************************************************************************************
 * @file     SceneStatusMessage.java 
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

public class SceneStatusMessage extends StatusMessage implements Parcelable {

    private static final int DATA_LEN_COMPLETE = 6;

    private byte statusCode;

    private int currentScene;

    private int targetScene;

    private byte remainingTime;

    /**
     * tag of is complete message
     */
    private boolean isComplete = false;

    public SceneStatusMessage() {
    }

    protected SceneStatusMessage(Parcel in) {
        statusCode = in.readByte();
        currentScene = in.readInt();
        targetScene = in.readInt();
        remainingTime = in.readByte();
        isComplete = in.readByte() != 0;
    }

    public static final Creator<SceneStatusMessage> CREATOR = new Creator<SceneStatusMessage>() {
        @Override
        public SceneStatusMessage createFromParcel(Parcel in) {
            return new SceneStatusMessage(in);
        }

        @Override
        public SceneStatusMessage[] newArray(int size) {
            return new SceneStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        this.statusCode = params[index++];
        this.currentScene = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        if (params.length == DATA_LEN_COMPLETE) {
            this.isComplete = true;
            this.targetScene = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
            index += 2;
            remainingTime = params[index];
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
        dest.writeInt(targetScene);
        dest.writeByte(remainingTime);
        dest.writeByte((byte) (isComplete ? 1 : 0));
    }

    public byte getStatusCode() {
        return statusCode;
    }

    public int getCurrentScene() {
        return currentScene;
    }

    public int getTargetScene() {
        return targetScene;
    }

    public byte getRemainingTime() {
        return remainingTime;
    }

    public boolean isComplete() {
        return isComplete;
    }
}
