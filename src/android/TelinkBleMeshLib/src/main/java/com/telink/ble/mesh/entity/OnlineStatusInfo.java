/********************************************************************************************************
 * @file     OnlineStatusInfo.java 
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

package com.telink.ble.mesh.entity;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * online status
 */
public class OnlineStatusInfo implements Parcelable {

    public int address;

//        byte rsv; // 1 bit

    // sn: 0 offline
    public byte sn;

    public byte[] status;

    public OnlineStatusInfo() {
    }

    protected OnlineStatusInfo(Parcel in) {
        address = in.readInt();
        sn = in.readByte();
        status = in.createByteArray();
    }

    public static final Creator<OnlineStatusInfo> CREATOR = new Creator<OnlineStatusInfo>() {
        @Override
        public OnlineStatusInfo createFromParcel(Parcel in) {
            return new OnlineStatusInfo(in);
        }

        @Override
        public OnlineStatusInfo[] newArray(int size) {
            return new OnlineStatusInfo[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(address);
        dest.writeByte(sn);
        dest.writeByteArray(status);
    }
}
