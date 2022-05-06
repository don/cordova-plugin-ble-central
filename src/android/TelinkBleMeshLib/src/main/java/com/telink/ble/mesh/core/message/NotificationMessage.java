/********************************************************************************************************
 * @file     NotificationMessage.java 
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
package com.telink.ble.mesh.core.message;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * NotificationMessage is used to notify mesh status changed
 * <p>
 * Created by kee on 2019/9/3.
 */
public class NotificationMessage implements Parcelable {
    private int src;
    private int dst;
    private int opcode;

    // params raw data
    private byte[] params;

    /**
     * parsed message by params, if opcode is registered in {@link MeshStatus.Container}
     * otherwise statusMessage will be null
     */
    private StatusMessage statusMessage;

    public NotificationMessage(int src, int dst, int opcode, byte[] params) {
        this.src = src;
        this.dst = dst;
        this.opcode = opcode;
        this.params = params;
        parseStatusMessage();
    }

    private void parseStatusMessage() {
        this.statusMessage = StatusMessage.createByAccessMessage(opcode, params);
    }


    protected NotificationMessage(Parcel in) {
        src = in.readInt();
        dst = in.readInt();
        opcode = in.readInt();
        params = in.createByteArray();
        statusMessage = in.readParcelable(StatusMessage.class.getClassLoader());
    }

    public static final Creator<NotificationMessage> CREATOR = new Creator<NotificationMessage>() {
        @Override
        public NotificationMessage createFromParcel(Parcel in) {
            return new NotificationMessage(in);
        }

        @Override
        public NotificationMessage[] newArray(int size) {
            return new NotificationMessage[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(src);
        dest.writeInt(dst);
        dest.writeInt(opcode);
        dest.writeByteArray(params);
        dest.writeParcelable(statusMessage, flags);
    }

    public int getSrc() {
        return src;
    }

    public void setSrc(int src) {
        this.src = src;
    }

    public int getDst() {
        return dst;
    }

    public void setDst(int dst) {
        this.dst = dst;
    }

    public int getOpcode() {
        return opcode;
    }

    public void setOpcode(int opcode) {
        this.opcode = opcode;
    }

    public byte[] getParams() {
        return params;
    }

    public void setParams(byte[] params) {
        this.params = params;
    }

    public StatusMessage getStatusMessage() {
        return statusMessage;
    }

    public void setStatusMessage(StatusMessage statusMessage) {
        this.statusMessage = statusMessage;
    }
}
