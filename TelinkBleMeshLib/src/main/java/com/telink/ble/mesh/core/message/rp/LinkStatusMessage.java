/********************************************************************************************************
 * @file     LinkStatusMessage.java 
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
package com.telink.ble.mesh.core.message.rp;

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.message.StatusMessage;

/**
 * Created by kee on 2019/8/20.
 */

public class LinkStatusMessage extends StatusMessage implements Parcelable {

    private byte status;

    private byte rpState;


    public LinkStatusMessage() {
    }

    protected LinkStatusMessage(Parcel in) {
        status = in.readByte();
        rpState = in.readByte();
    }

    public static final Creator<LinkStatusMessage> CREATOR = new Creator<LinkStatusMessage>() {
        @Override
        public LinkStatusMessage createFromParcel(Parcel in) {
            return new LinkStatusMessage(in);
        }

        @Override
        public LinkStatusMessage[] newArray(int size) {
            return new LinkStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        this.status = params[index++];
        this.rpState = params[index++];
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte(status);
        dest.writeByte(rpState);
    }

    public byte getRpState() {
        return rpState;
    }

    public byte getStatus() {
        return status;
    }


    @Override
    public String toString() {
        return "LinkStatusMessage{" +
                "status=" + status +
                ", rpState=" + rpState +
                '}';
    }
}
