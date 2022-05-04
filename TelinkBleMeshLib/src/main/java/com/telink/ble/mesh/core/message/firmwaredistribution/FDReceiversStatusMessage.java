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

public class FDReceiversStatusMessage extends StatusMessage implements Parcelable {

    /**
     * Status Code for the requesting message
     * 1 byte
     */
    private int status;

    /**
     * Receivers List Count
     * The number of entries in the Distribution Receivers List state
     * 2 bytes
     */
    private int receiversListCount;

    public FDReceiversStatusMessage() {
    }


    protected FDReceiversStatusMessage(Parcel in) {
        status = in.readInt();
        receiversListCount = in.readInt();
    }

    public static final Creator<FDReceiversStatusMessage> CREATOR = new Creator<FDReceiversStatusMessage>() {
        @Override
        public FDReceiversStatusMessage createFromParcel(Parcel in) {
            return new FDReceiversStatusMessage(in);
        }

        @Override
        public FDReceiversStatusMessage[] newArray(int size) {
            return new FDReceiversStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        this.status = params[index++] & 0xFF;
        this.receiversListCount = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
    }

    public int getStatus() {
        return status;
    }

    public int getReceiversListCount() {
        return receiversListCount;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(status);
        dest.writeInt(receiversListCount);
    }

    @Override
    public String toString() {
        return "FirmwareDistributionReceiversStatus{" +
                "status=" + status +
                ", receiversListCount=" + receiversListCount +
                '}';
    }
}
