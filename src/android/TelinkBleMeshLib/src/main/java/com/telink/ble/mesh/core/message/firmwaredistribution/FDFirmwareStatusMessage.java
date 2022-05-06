/********************************************************************************************************
 * @file BlobTransferStatusMessage.java
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date Sep. 30, 2010
 *
 * @par Copyright (c) 2010, Telink Semiconductor (Shanghai) Co., Ltd.
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
package com.telink.ble.mesh.core.message.firmwaredistribution;

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.StatusMessage;

import java.nio.ByteOrder;

public class FDFirmwareStatusMessage extends StatusMessage implements Parcelable {

    /**
     * Status Code for the requesting message
     * 1 byte
     */
    public int status;

    /**
     * Entry Count
     * The number of firmware images stored on the Firmware Distribution Server
     * 2 bytes
     */
    public int entryCount;

    /**
     * Distribution Firmware Image Index
     * Index of the firmware image in the Firmware Images List state
     * 2 bytes
     */
    public int distImageIndex;

    /**
     * Firmware ID
     * Identifies associated firmware image
     * Variable length
     */
    public byte[] firmwareID;

    public FDFirmwareStatusMessage() {
    }


    protected FDFirmwareStatusMessage(Parcel in) {
        status = in.readInt();
        entryCount = in.readInt();
        distImageIndex = in.readInt();
        firmwareID = in.createByteArray();
    }

    public static final Creator<FDFirmwareStatusMessage> CREATOR = new Creator<FDFirmwareStatusMessage>() {
        @Override
        public FDFirmwareStatusMessage createFromParcel(Parcel in) {
            return new FDFirmwareStatusMessage(in);
        }

        @Override
        public FDFirmwareStatusMessage[] newArray(int size) {
            return new FDFirmwareStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        this.status = params[index++] & 0xFF;
        this.entryCount = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        this.distImageIndex = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        if (params.length == 5) return;
        this.firmwareID = new byte[params.length - index];
        System.arraycopy(params, index, this.firmwareID, 0, this.firmwareID.length);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(status);
        dest.writeInt(entryCount);
        dest.writeInt(distImageIndex);
        dest.writeByteArray(firmwareID);
    }
}
