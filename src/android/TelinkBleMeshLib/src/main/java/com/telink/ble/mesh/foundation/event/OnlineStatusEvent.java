/********************************************************************************************************
 * @file     OnlineStatusEvent.java 
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

import com.telink.ble.mesh.entity.OnlineStatusInfo;
import com.telink.ble.mesh.foundation.Event;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by kee on 2019/9/4.
 */

public class OnlineStatusEvent extends Event<String> implements Parcelable {

    public static final String EVENT_TYPE_ONLINE_STATUS_NOTIFY = "com.telink.ble.mesh.EVENT_TYPE_ONLINE_STATUS_NOTIFY";

    private List<OnlineStatusInfo> onlineStatusInfoList;

    public OnlineStatusEvent(Object sender, byte[] onlineStatusData) {
        this(sender, EVENT_TYPE_ONLINE_STATUS_NOTIFY);
        this.onlineStatusInfoList = parseOnlineStatusData(onlineStatusData);
    }

    protected OnlineStatusEvent(Parcel in) {
        onlineStatusInfoList = in.createTypedArrayList(OnlineStatusInfo.CREATOR);
    }

    public static final Creator<OnlineStatusEvent> CREATOR = new Creator<OnlineStatusEvent>() {
        @Override
        public OnlineStatusEvent createFromParcel(Parcel in) {
            return new OnlineStatusEvent(in);
        }

        @Override
        public OnlineStatusEvent[] newArray(int size) {
            return new OnlineStatusEvent[size];
        }
    };

    private List<OnlineStatusInfo> parseOnlineStatusData(byte[] rawData) {
        if (rawData == null || rawData.length < 4) return null;
        final int len = rawData.length;
        final int MIN_NODE_LEN = 3;
        int index = 0;
        byte type = rawData[index++];
        if (type != 0x62) {
            return null;
        }

        // low 4 bit
        int nodeLen = rawData[index++] & 0x0F;

        int statusLen = nodeLen - MIN_NODE_LEN;
        if (statusLen <= 0) return null;

        int sno = (rawData[index++] & 0xFF) | ((rawData[index++] & 0xFF) << 8);

        List<OnlineStatusInfo> statusInfoList = null;

        int address;
        byte sn;
        byte[] status;
        OnlineStatusInfo statusInfo;
        while (index + nodeLen <= len) {
            // 15 bit
            address = (rawData[index++] & 0xFF) | ((rawData[index++] & 0x7F) << 8);

            sn = rawData[index++];
            status = new byte[statusLen];

            System.arraycopy(rawData, index, status, 0, statusLen);
            index += statusLen;

            if (address == 0x00)
                break;


            statusInfo = new OnlineStatusInfo();
            statusInfo.address = address;
            statusInfo.sn = sn;
            statusInfo.status = status;
            if (statusInfoList == null) {
                statusInfoList = new ArrayList<>();
            }
            statusInfoList.add(statusInfo);
        }

        return statusInfoList;
    }

    public OnlineStatusEvent(Object sender, String type) {
        super(sender, type);
    }


    public List<OnlineStatusInfo> getOnlineStatusInfoList() {
        return onlineStatusInfoList;
    }

    public void setOnlineStatusInfoList(List<OnlineStatusInfo> onlineStatusInfoList) {
        this.onlineStatusInfoList = onlineStatusInfoList;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeTypedList(onlineStatusInfoList);
    }
}
