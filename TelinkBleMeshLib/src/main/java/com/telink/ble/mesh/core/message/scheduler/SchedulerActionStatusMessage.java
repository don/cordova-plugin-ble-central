/********************************************************************************************************
 * @file     SchedulerActionStatusMessage.java 
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

import com.telink.ble.mesh.core.message.StatusMessage;
import com.telink.ble.mesh.entity.Scheduler;

/**
 * Created by kee on 2019/8/20.
 */

public class SchedulerActionStatusMessage extends StatusMessage implements Parcelable {

    private Scheduler scheduler;

    public SchedulerActionStatusMessage() {
    }

    protected SchedulerActionStatusMessage(Parcel in) {
        scheduler = in.readParcelable(Scheduler.class.getClassLoader());
    }

    public static final Creator<SchedulerActionStatusMessage> CREATOR = new Creator<SchedulerActionStatusMessage>() {
        @Override
        public SchedulerActionStatusMessage createFromParcel(Parcel in) {
            return new SchedulerActionStatusMessage(in);
        }

        @Override
        public SchedulerActionStatusMessage[] newArray(int size) {
            return new SchedulerActionStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        this.scheduler = Scheduler.fromBytes(params);
    }

    public Scheduler getScheduler() {
        return scheduler;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeParcelable(scheduler, flags);
    }
}
