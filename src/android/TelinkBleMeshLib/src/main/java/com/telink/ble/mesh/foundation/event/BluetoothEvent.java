/********************************************************************************************************
 * @file     BluetoothEvent.java 
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
package com.telink.ble.mesh.foundation.event;

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.foundation.Event;

/**
 * Created by kee on 2019/9/4.
 */

public class BluetoothEvent extends Event<String> implements Parcelable {

    public static final String EVENT_TYPE_BLUETOOTH_STATE_CHANGE = "com.telink.ble.mesh.EVENT_TYPE_BLUETOOTH_STATE_CHANGE";

    private int state;

    private String desc;

    public BluetoothEvent(Object sender, String type) {
        super(sender, type);
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    protected BluetoothEvent(Parcel in) {
        state = in.readInt();
        desc = in.readString();
    }

    public static final Creator<BluetoothEvent> CREATOR = new Creator<BluetoothEvent>() {
        @Override
        public BluetoothEvent createFromParcel(Parcel in) {
            return new BluetoothEvent(in);
        }

        @Override
        public BluetoothEvent[] newArray(int size) {
            return new BluetoothEvent[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(state);
        dest.writeString(desc);
    }
}
