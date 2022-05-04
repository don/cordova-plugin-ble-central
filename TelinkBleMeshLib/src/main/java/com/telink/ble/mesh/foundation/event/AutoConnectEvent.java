/********************************************************************************************************
 * @file     AutoConnectEvent.java 
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
 * Created by kee on 2019/9/12.
 */

public class AutoConnectEvent extends Event<String> {
    public static final String EVENT_TYPE_AUTO_CONNECT_LOGIN = "com.telink.ble.mesh.EVENT_TYPE_AUTO_CONNECT_LOGIN";

//    public static final String EVENT_TYPE_AUTO_CONNECT_LOGOUT = "com.telink.ble.mesh.EVENT_TYPE_AUTO_CONNECT_LOGOUT";

    private int connectedAddress;

    public AutoConnectEvent(Object sender, String type, int connectedAddress) {
        super(sender, type);
        this.connectedAddress = connectedAddress;
    }

    protected AutoConnectEvent(Parcel in) {
        connectedAddress = in.readInt();
    }

    public static final Creator<AutoConnectEvent> CREATOR = new Creator<AutoConnectEvent>() {
        @Override
        public AutoConnectEvent createFromParcel(Parcel in) {
            return new AutoConnectEvent(in);
        }

        @Override
        public AutoConnectEvent[] newArray(int size) {
            return new AutoConnectEvent[size];
        }
    };

    public int getConnectedAddress() {
        return connectedAddress;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(connectedAddress);
    }
}
