/********************************************************************************************************
 * @file     ReliableMessageProcessEvent.java 
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
 * Created by kee on 2017/8/30.
 */

public class ReliableMessageProcessEvent extends Event<String> implements Parcelable {

    /**
     * mesh message send fail, because of busy
     */
    public static final String EVENT_TYPE_MSG_PROCESS_BUSY = "com.telink.sig.mesh.EVENT_TYPE_CMD_ERROR_BUSY";

    /**
     * mesh message processing
     */
    public static final String EVENT_TYPE_MSG_PROCESSING = "com.telink.sig.mesh.EVENT_TYPE_CMD_PROCESSING";

    /**
     * mesh message send complete, success or retry max
     */
    public static final String EVENT_TYPE_MSG_PROCESS_COMPLETE = "com.telink.sig.mesh.EVENT_TYPE_CMD_COMPLETE";

    private boolean success;

    // message opcode
    private int opcode;
    // message response max
    private int rspMax;

    // message response count
    private int rspCount;

    // event description
    private String desc;


    public ReliableMessageProcessEvent(Object sender, String type) {
        super(sender, type);
    }

    public ReliableMessageProcessEvent(Object sender, String type, boolean success, int opcode, int rspMax, int rspCount, String desc) {
        super(sender, type);
        this.success = success;
        this.opcode = opcode;
        this.rspMax = rspMax;
        this.rspCount = rspCount;
        this.desc = desc;
    }


    protected ReliableMessageProcessEvent(Parcel in) {
        success = in.readByte() != 0;
        opcode = in.readInt();
        rspMax = in.readInt();
        rspCount = in.readInt();
        desc = in.readString();
    }

    public static final Creator<ReliableMessageProcessEvent> CREATOR = new Creator<ReliableMessageProcessEvent>() {
        @Override
        public ReliableMessageProcessEvent createFromParcel(Parcel in) {
            return new ReliableMessageProcessEvent(in);
        }

        @Override
        public ReliableMessageProcessEvent[] newArray(int size) {
            return new ReliableMessageProcessEvent[size];
        }
    };

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public int getOpcode() {
        return opcode;
    }

    public void setOpcode(int opcode) {
        this.opcode = opcode;
    }

    public int getRspMax() {
        return rspMax;
    }

    public void setRspMax(int rspMax) {
        this.rspMax = rspMax;
    }

    public int getRspCount() {
        return rspCount;
    }

    public void setRspCount(int rspCount) {
        this.rspCount = rspCount;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }


    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte((byte) (success ? 1 : 0));
        dest.writeInt(opcode);
        dest.writeInt(rspMax);
        dest.writeInt(rspCount);
        dest.writeString(desc);
    }
}
