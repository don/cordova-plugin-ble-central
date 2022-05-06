/********************************************************************************************************
 * @file     NetworkTransmitStatusMessage.java 
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
package com.telink.ble.mesh.core.message.config;

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.message.StatusMessage;

/**
 * Created by kee on 2019/9/10.
 */

public class NetworkTransmitStatusMessage extends StatusMessage implements Parcelable {

    private int count;

    private int intervalSteps;


    public NetworkTransmitStatusMessage() {
    }


    protected NetworkTransmitStatusMessage(Parcel in) {
        count = in.readInt();
        intervalSteps = in.readInt();
    }

    public static final Creator<NetworkTransmitStatusMessage> CREATOR = new Creator<NetworkTransmitStatusMessage>() {
        @Override
        public NetworkTransmitStatusMessage createFromParcel(Parcel in) {
            return new NetworkTransmitStatusMessage(in);
        }

        @Override
        public NetworkTransmitStatusMessage[] newArray(int size) {
            return new NetworkTransmitStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] data) {
        int index = 0;
        this.count = data[0] & 0b111;
        this.intervalSteps = (data[0] & 0xFF) >> 3;
    }

    public int getCount() {
        return count;
    }

    public int getIntervalSteps() {
        return intervalSteps;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(count);
        dest.writeInt(intervalSteps);
    }
}
