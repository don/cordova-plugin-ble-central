/********************************************************************************************************
 * @file     NetworkInfoUpdateEvent.java 
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

public class NetworkInfoUpdateEvent extends Event<String> implements Parcelable {

    public static final String EVENT_TYPE_NETWORKD_INFO_UPDATE = "com.telink.ble.mesh.EVENT_TYPE_NETWORKD_INFO_UPDATE";

    private int sequenceNumber;

    private int ivIndex;

    public NetworkInfoUpdateEvent(Object sender, String type, int sequenceNumber, int ivIndex) {
        super(sender, type);
        this.sequenceNumber = sequenceNumber;
        this.ivIndex = ivIndex;
    }

    protected NetworkInfoUpdateEvent(Parcel in) {
        sequenceNumber = in.readInt();
        ivIndex = in.readInt();
    }

    public static final Creator<NetworkInfoUpdateEvent> CREATOR = new Creator<NetworkInfoUpdateEvent>() {
        @Override
        public NetworkInfoUpdateEvent createFromParcel(Parcel in) {
            return new NetworkInfoUpdateEvent(in);
        }

        @Override
        public NetworkInfoUpdateEvent[] newArray(int size) {
            return new NetworkInfoUpdateEvent[size];
        }
    };

    public int getSequenceNumber() {
        return sequenceNumber;
    }

    public int getIvIndex() {
        return ivIndex;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(sequenceNumber);
        dest.writeInt(ivIndex);
    }
}
