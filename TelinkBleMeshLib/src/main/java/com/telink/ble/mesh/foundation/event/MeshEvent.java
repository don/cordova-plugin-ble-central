/********************************************************************************************************
 * @file     MeshEvent.java 
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
 * Created by kee on 2019/9/4.
 */

public class MeshEvent extends Event<String> {

    public static final String EVENT_TYPE_MESH_EMPTY = "com.telink.ble.mesh.MESH_EMPTY";

    public static final String EVENT_TYPE_DISCONNECTED = "com.telink.ble.mesh.EVENT_TYPE_DISCONNECTED";

    public static final String EVENT_TYPE_MESH_RESET = "com.telink.sig.mesh.EVENT_TYPE_MESH_RESET";

    private String desc;

    public MeshEvent(Object sender, String type, String desc) {
        super(sender, type);
        this.desc = desc;
    }

    protected MeshEvent(Parcel in) {
        desc = in.readString();
    }

    public static final Creator<MeshEvent> CREATOR = new Creator<MeshEvent>() {
        @Override
        public MeshEvent createFromParcel(Parcel in) {
            return new MeshEvent(in);
        }

        @Override
        public MeshEvent[] newArray(int size) {
            return new MeshEvent[size];
        }
    };

    public String getDesc() {
        return desc;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(desc);
    }
}
