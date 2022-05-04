/********************************************************************************************************
 * @file     ScanReportStatusMessage.java 
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

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.StatusMessage;

import java.nio.ByteOrder;

/**
 * Created by kee on 2019/8/20.
 */

public class ScanReportStatusMessage extends StatusMessage implements Parcelable {

    private byte rssi;

    // 16 bytes
    private byte[] uuid;

    // 2 bytes
    private int oob;

    public ScanReportStatusMessage() {
    }

    protected ScanReportStatusMessage(Parcel in) {
        rssi = in.readByte();
        uuid = in.createByteArray();
        oob = in.readInt();
    }

    public static final Creator<ScanReportStatusMessage> CREATOR = new Creator<ScanReportStatusMessage>() {
        @Override
        public ScanReportStatusMessage createFromParcel(Parcel in) {
            return new ScanReportStatusMessage(in);
        }

        @Override
        public ScanReportStatusMessage[] newArray(int size) {
            return new ScanReportStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        this.rssi = params[index++];
        this.uuid = new byte[16];
        System.arraycopy(params, index, this.uuid, 0, this.uuid.length);
        index += this.uuid.length;
        this.oob = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte(rssi);
        dest.writeByteArray(uuid);
        dest.writeInt(oob);
    }

    public byte getRssi() {
        return rssi;
    }

    public byte[] getUuid() {
        return uuid;
    }

    public int getOob() {
        return oob;
    }
}
