/********************************************************************************************************
 * @file     GattOtaEvent.java 
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

import com.telink.ble.mesh.foundation.Event;

/**
 * Created by kee on 2017/8/30.
 */

public class GattOtaEvent extends Event<String> {

    public static final String EVENT_TYPE_OTA_SUCCESS = "com.telink.sig.mesh.OTA_SUCCESS";

    public static final String EVENT_TYPE_OTA_FAIL = "com.telink.sig.mesh.OTA_FAIL";

    public static final String EVENT_TYPE_OTA_PROGRESS = "com.telink.sig.mesh.OTA_PROGRESS";

    private int progress;
    private String desc;


    public GattOtaEvent(Object sender, String type, int progress, String desc) {
        super(sender, type);
        this.progress = progress;
        this.desc = desc;
    }

    protected GattOtaEvent(Parcel in) {
        progress = in.readInt();
        desc = in.readString();
    }

    public static final Creator<GattOtaEvent> CREATOR = new Creator<GattOtaEvent>() {
        @Override
        public GattOtaEvent createFromParcel(Parcel in) {
            return new GattOtaEvent(in);
        }

        @Override
        public GattOtaEvent[] newArray(int size) {
            return new GattOtaEvent[size];
        }
    };

    public String getDesc() {
        return desc;
    }


    public int getProgress() {
        return progress;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(progress);
        dest.writeString(desc);
    }
}
