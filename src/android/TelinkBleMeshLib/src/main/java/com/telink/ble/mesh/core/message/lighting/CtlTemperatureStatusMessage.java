/********************************************************************************************************
 * @file     CtlTemperatureStatusMessage.java 
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
 * Created by kee on 2019/8/20.
 */

public class CtlTemperatureStatusMessage extends StatusMessage implements Parcelable {

    private static final int DATA_LEN_COMPLETE = 9;


    private int presentTemperature;

    private int presentDeltaUV;

    private int targetTemperature;

    private int targetDeltaUV;


    private byte remainingTime;

    /**
     * tag of is complete message
     */
    private boolean isComplete = false;

    public CtlTemperatureStatusMessage() {
    }

    protected CtlTemperatureStatusMessage(Parcel in) {
        presentTemperature = in.readInt();
        presentDeltaUV = in.readInt();
        targetTemperature = in.readInt();
        targetDeltaUV = in.readInt();
        remainingTime = in.readByte();
        isComplete = in.readByte() != 0;
    }

    public static final Creator<CtlTemperatureStatusMessage> CREATOR = new Creator<CtlTemperatureStatusMessage>() {
        @Override
        public CtlTemperatureStatusMessage createFromParcel(Parcel in) {
            return new CtlTemperatureStatusMessage(in);
        }

        @Override
        public CtlTemperatureStatusMessage[] newArray(int size) {
            return new CtlTemperatureStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        this.presentTemperature = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.presentDeltaUV = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        if (params.length == DATA_LEN_COMPLETE) {
            this.isComplete = true;
            this.targetTemperature = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
            index += 2;
            this.targetDeltaUV = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
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
        dest.writeInt(presentTemperature);
        dest.writeInt(presentDeltaUV);
        dest.writeInt(targetTemperature);
        dest.writeInt(targetDeltaUV);
        dest.writeByte(remainingTime);
        dest.writeByte((byte) (isComplete ? 1 : 0));
    }

    public int getPresentTemperature() {
        return presentTemperature;
    }

    public int getPresentDeltaUV() {
        return presentDeltaUV;
    }

    public int getTargetTemperature() {
        return targetTemperature;
    }

    public int getTargetDeltaUV() {
        return targetDeltaUV;
    }

    public byte getRemainingTime() {
        return remainingTime;
    }

    public boolean isComplete() {
        return isComplete;
    }
}
