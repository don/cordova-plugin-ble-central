/********************************************************************************************************
 * @file     AppKeyStatusMessage.java 
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
package com.telink.ble.mesh.core.message.config;

import android.os.Parcel;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.StatusMessage;

import java.nio.ByteOrder;

/**
 * Created by kee on 2019/9/10.
 */

public class AppKeyStatusMessage extends StatusMessage {

    /**
     * 1 byte
     */
    private byte status;

    /**
     * 12 bits
     */
    private int netKeyIndex;

    /**
     * 12 bits
     */
    private int appKeyIndex;


    public AppKeyStatusMessage() {
    }

    protected AppKeyStatusMessage(Parcel in) {
        status = in.readByte();
        netKeyIndex = in.readInt();
        appKeyIndex = in.readInt();
    }

    public static final Creator<AppKeyStatusMessage> CREATOR = new Creator<AppKeyStatusMessage>() {
        @Override
        public AppKeyStatusMessage createFromParcel(Parcel in) {
            return new AppKeyStatusMessage(in);
        }

        @Override
        public AppKeyStatusMessage[] newArray(int size) {
            return new AppKeyStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        status = params[0];

        int netAppKeyIndex = MeshUtils.bytes2Integer(new byte[]{
                params[1], params[2], params[3],
        }, ByteOrder.LITTLE_ENDIAN);

        this.netKeyIndex = netAppKeyIndex & 0x0FFF;
        this.appKeyIndex = (netAppKeyIndex >> 12) & 0x0FFF;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte(status);
        dest.writeInt(netKeyIndex);
        dest.writeInt(appKeyIndex);
    }

    public byte getStatus() {
        return status;
    }

    public int getNetKeyIndex() {
        return netKeyIndex;
    }

    public int getAppKeyIndex() {
        return appKeyIndex;
    }

}

