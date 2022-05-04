/********************************************************************************************************
 * @file AutoConnectEvent.java
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date Sep. 30, 2010
 *
 * @par Copyright (c) 2010, Telink Semiconductor (Shanghai) Co., Ltd.
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

import java.util.UUID;

/**
 * Created by kee on 2019/9/12.
 */

public class GattNotificationEvent extends Event<String> implements Parcelable {
    public static final String EVENT_TYPE_UNEXPECTED_NOTIFY = "com.telink.ble.mesh.EVENT_TYPE_UNEXPECTED_NOTIFY";

    private UUID serviceUUID;
    private UUID characteristicUUID;
    private byte[] data;


    public GattNotificationEvent(Object sender, String type, UUID serviceUUID, UUID characteristicUUID, byte[] data) {
        super(sender, type);
        this.serviceUUID = serviceUUID;
        this.characteristicUUID = characteristicUUID;
        this.data = data;
    }

    protected GattNotificationEvent(Parcel in) {
        serviceUUID = UUID.fromString(in.readString());
        characteristicUUID = UUID.fromString(in.readString());
        data = in.createByteArray();
    }


    public UUID getServiceUUID() {
        return serviceUUID;
    }

    public UUID getCharacteristicUUID() {
        return characteristicUUID;
    }

    public byte[] getData() {
        return data;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(serviceUUID.toString());
        dest.writeString(characteristicUUID.toString());
        dest.writeByteArray(data);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<GattNotificationEvent> CREATOR = new Creator<GattNotificationEvent>() {
        @Override
        public GattNotificationEvent createFromParcel(Parcel in) {
            return new GattNotificationEvent(in);
        }

        @Override
        public GattNotificationEvent[] newArray(int size) {
            return new GattNotificationEvent[size];
        }
    };
}
