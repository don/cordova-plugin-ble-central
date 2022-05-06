/********************************************************************************************************
 * @file     HslTargetStatusMessage.java 
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

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.StatusMessage;

import java.nio.ByteOrder;

/**
 * There is no target info in status message
 * Created by kee on 2019/8/20.
 */
public class HslTargetStatusMessage extends StatusMessage implements Parcelable {

    private static final int DATA_LEN_COMPLETE = 7;

    private int targetLightness;

    private int targetHue;

    private int targetSaturation;

    private byte remainingTime;

    /**
     * tag of is complete message
     */
    private boolean isComplete = false;

    public HslTargetStatusMessage() {
    }

    protected HslTargetStatusMessage(Parcel in) {
        targetLightness = in.readInt();
        targetHue = in.readInt();
        targetSaturation = in.readInt();
        remainingTime = in.readByte();
        isComplete = in.readByte() != 0;
    }

    public static final Creator<HslTargetStatusMessage> CREATOR = new Creator<HslTargetStatusMessage>() {
        @Override
        public HslTargetStatusMessage createFromParcel(Parcel in) {
            return new HslTargetStatusMessage(in);
        }

        @Override
        public HslTargetStatusMessage[] newArray(int size) {
            return new HslTargetStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        this.targetLightness = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.targetHue = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.targetSaturation = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        if (params.length == DATA_LEN_COMPLETE) {
            this.isComplete = true;
            this.remainingTime = params[index];
        }
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(targetLightness);
        dest.writeInt(targetHue);
        dest.writeInt(targetSaturation);
        dest.writeByte(remainingTime);
        dest.writeByte((byte) (isComplete ? 1 : 0));
    }

    public int getTargetLightness() {
        return targetLightness;
    }

    public int getTargetHue() {
        return targetHue;
    }

    public int getTargetSaturation() {
        return targetSaturation;
    }

    public byte getRemainingTime() {
        return remainingTime;
    }

    public boolean isComplete() {
        return isComplete;
    }
}
