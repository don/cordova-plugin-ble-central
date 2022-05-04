/********************************************************************************************************
 * @file     MeshAddressStatusMessage.java 
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
package com.telink.ble.mesh.core.message.fastpv;

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.StatusMessage;

import java.nio.ByteOrder;
import java.util.Arrays;

/**
 * Created by kee on 2019/8/20.
 */

public class MeshAddressStatusMessage extends StatusMessage implements Parcelable {

    private byte[] mac;

    private int pid;


    public MeshAddressStatusMessage() {
    }


    protected MeshAddressStatusMessage(Parcel in) {
        mac = in.createByteArray();
        pid = in.readInt();
    }

    public static final Creator<MeshAddressStatusMessage> CREATOR = new Creator<MeshAddressStatusMessage>() {
        @Override
        public MeshAddressStatusMessage createFromParcel(Parcel in) {
            return new MeshAddressStatusMessage(in);
        }

        @Override
        public MeshAddressStatusMessage[] newArray(int size) {
            return new MeshAddressStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        final int macLen = 6;
        this.mac = new byte[6];
        System.arraycopy(params, 0, this.mac, 0, macLen);
        index += macLen;
        this.pid = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
    }


    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByteArray(mac);
        dest.writeInt(pid);
    }

    public byte[] getMac() {
        return mac;
    }

    public int getPid() {
        return pid;
    }

    @Override
    public String toString() {
        return "MeshAddressStatusMessage{" +
                "mac=" + Arrays.toString(mac) +
                ", pid=" + pid +
                '}';
    }
}
