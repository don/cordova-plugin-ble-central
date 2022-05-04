/********************************************************************************************************
 * @file     LevelStatusMessage.java 
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

import android.os.Parcel;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.StatusMessage;

import java.nio.ByteOrder;

/**
 * Created by kee on 2019/9/3.
 */

public class LevelStatusMessage extends StatusMessage {

    private static final int DATA_LEN_COMPLETE = 5;

    /**
     * The present value of the Generic Level state.
     * 2 bytes
     */
    private int presentLevel;

    /**
     * The target value of the Generic Level state (Optional).
     * 2 bytes
     */
    private int targetLevel;

    private byte remainingTime;

    private boolean isComplete = false;

    public LevelStatusMessage() {
    }

    protected LevelStatusMessage(Parcel in) {
        presentLevel = in.readInt();
        targetLevel = in.readInt();
        remainingTime = in.readByte();
    }

    public static final Creator<LevelStatusMessage> CREATOR = new Creator<LevelStatusMessage>() {
        @Override
        public LevelStatusMessage createFromParcel(Parcel in) {
            return new LevelStatusMessage(in);
        }

        @Override
        public LevelStatusMessage[] newArray(int size) {
            return new LevelStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        this.presentLevel = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        if (params.length == DATA_LEN_COMPLETE) {
            this.isComplete = true;
            this.targetLevel = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
            index += 2;
            this.remainingTime = params[index];
        }
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(presentLevel);
        dest.writeInt(targetLevel);
        dest.writeByte(remainingTime);
    }

    public int getPresentLevel() {
        return presentLevel;
    }

    public int getTargetLevel() {
        return targetLevel;
    }

    public byte getRemainingTime() {
        return remainingTime;
    }

    public boolean isComplete() {
        return isComplete;
    }
}
