/********************************************************************************************************
 * @file     SchedulerStatusMessage.java 
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
package com.telink.ble.mesh.core.message.scheduler;

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.StatusMessage;

import java.nio.ByteOrder;

/**
 * Created by kee on 2019/8/20.
 */

public class SchedulerStatusMessage extends StatusMessage implements Parcelable {


    /**
     * Bit field indicating defined Actions in the Schedule Register
     */
    private int schedules;

    public SchedulerStatusMessage() {
    }

    protected SchedulerStatusMessage(Parcel in) {
        schedules = in.readInt();
    }

    public static final Creator<SchedulerStatusMessage> CREATOR = new Creator<SchedulerStatusMessage>() {
        @Override
        public SchedulerStatusMessage createFromParcel(Parcel in) {
            return new SchedulerStatusMessage(in);
        }

        @Override
        public SchedulerStatusMessage[] newArray(int size) {
            return new SchedulerStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        this.schedules = MeshUtils.bytes2Integer(params, ByteOrder.LITTLE_ENDIAN);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(schedules);
    }

    public long getSchedules() {
        return schedules;
    }
}
