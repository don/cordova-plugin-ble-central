/********************************************************************************************************
 * @file     ModelSubscriptionStatusMessage.java 
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
import android.os.Parcelable;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.StatusMessage;

import java.nio.ByteOrder;

/**
 * Created by kee on 2019/9/10.
 */

public class ModelSubscriptionStatusMessage extends StatusMessage implements Parcelable {

    private static final int DATA_LEN_SIG = 7;

    private static final int DATA_LEN_VENDOR = 9;

    private byte status;

    private int elementAddress;

    /**
     * group address
     */
    private int address;

    /**
     * 2 or 4 bytes
     * determined by sig
     */
    private int modelIdentifier;

    /**
     * is sig or vendor
     */
    private boolean isSig = true;


    public ModelSubscriptionStatusMessage() {
    }


    protected ModelSubscriptionStatusMessage(Parcel in) {
        status = in.readByte();
        elementAddress = in.readInt();
        address = in.readInt();
        modelIdentifier = in.readInt();
        isSig = in.readByte() != 0;
    }

    public static final Creator<ModelSubscriptionStatusMessage> CREATOR = new Creator<ModelSubscriptionStatusMessage>() {
        @Override
        public ModelSubscriptionStatusMessage createFromParcel(Parcel in) {
            return new ModelSubscriptionStatusMessage(in);
        }

        @Override
        public ModelSubscriptionStatusMessage[] newArray(int size) {
            return new ModelSubscriptionStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        isSig = params.length == DATA_LEN_SIG;

        int index = 0;
        status = params[index++];
        elementAddress = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        address = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        modelIdentifier = MeshUtils.bytes2Integer(params, index, isSig ? 2 : 4, ByteOrder.LITTLE_ENDIAN);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte(status);
        dest.writeInt(elementAddress);
        dest.writeInt(address);
        dest.writeInt(modelIdentifier);
        dest.writeByte((byte) (isSig ? 1 : 0));
    }

    public byte getStatus() {
        return status;
    }

    public int getElementAddress() {
        return elementAddress;
    }

    public int getAddress() {
        return address;
    }

    public int getModelIdentifier() {
        return modelIdentifier;
    }

    public boolean isSig() {
        return isSig;
    }

    @Override
    public String toString() {
        return "ModelSubscriptionStatusMessage{" +
                "status=" + status +
                ", elementAddress=" + elementAddress +
                ", address=" + address +
                ", modelIdentifier=" + modelIdentifier +
                ", isSig=" + isSig +
                '}';
    }
}

