/********************************************************************************************************
 * @file     ScanEvent.java 
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

import com.telink.ble.mesh.entity.AdvertisingDevice;
import com.telink.ble.mesh.foundation.Event;

/**
 * Created by kee on 2019/9/5.
 */

public class ScanEvent extends Event<String> implements Parcelable {

    public static final String EVENT_TYPE_DEVICE_FOUND = "com.telink.ble.mesh.EVENT_TYPE_DEVICE_FOUND";

    public static final String EVENT_TYPE_SCAN_TIMEOUT = "com.telink.ble.mesh.EVENT_TYPE_SCAN_TIMEOUT";

    public static final String EVENT_TYPE_SCAN_FAIL = "com.telink.ble.mesh.EVENT_TYPE_SCAN_FAIL";

    public static final String EVENT_TYPE_SCAN_LOCATION_WARNING = "com.telink.ble.mesh.EVENT_TYPE_SCAN_LOCATION_WARNING";

    private AdvertisingDevice advertisingDevice;

    public ScanEvent(Object sender, String type, AdvertisingDevice advertisingDevice) {
        super(sender, type);
        this.advertisingDevice = advertisingDevice;
    }

    public ScanEvent(Object sender, String type) {
        super(sender, type);
    }

    protected ScanEvent(Parcel in) {
        advertisingDevice = in.readParcelable(AdvertisingDevice.class.getClassLoader());
    }

    public static final Creator<ScanEvent> CREATOR = new Creator<ScanEvent>() {
        @Override
        public ScanEvent createFromParcel(Parcel in) {
            return new ScanEvent(in);
        }

        @Override
        public ScanEvent[] newArray(int size) {
            return new ScanEvent[size];
        }
    };

    public AdvertisingDevice getAdvertisingDevice() {
        return advertisingDevice;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeParcelable(advertisingDevice, flags);
    }
}
