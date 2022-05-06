/********************************************************************************************************
 * @file     ModelAppStatusMessage.java 
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

public class ModelAppStatusMessage extends StatusMessage implements Parcelable {

    private static final int MODEL_STATUS_SIG_LEN = 7;

    private static final int MODEL_STATUS_VENDOR_LEN = 9;

    private byte status;

    private int elementAddress;

    private int appKeyIndex;

    /**
     * 2 or 4 bytes
     */
    private int modelIdentifier;

    public ModelAppStatusMessage() {
    }

    protected ModelAppStatusMessage(Parcel in) {
        status = in.readByte();
        elementAddress = in.readInt();
        appKeyIndex = in.readInt();
        modelIdentifier = in.readInt();
    }

    public static final Creator<ModelAppStatusMessage> CREATOR = new Creator<ModelAppStatusMessage>() {
        @Override
        public ModelAppStatusMessage createFromParcel(Parcel in) {
            return new ModelAppStatusMessage(in);
        }

        @Override
        public ModelAppStatusMessage[] newArray(int size) {
            return new ModelAppStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        status = params[index++];

        elementAddress = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        appKeyIndex = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        int modelIdLen;
        if (params.length == MODEL_STATUS_SIG_LEN) {
            modelIdLen = 2;
        } else {
            modelIdLen = 4;
        }
        modelIdentifier = MeshUtils.bytes2Integer(params, index, modelIdLen, ByteOrder.LITTLE_ENDIAN);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte(status);
        dest.writeInt(elementAddress);
        dest.writeInt(appKeyIndex);
        dest.writeInt(modelIdentifier);
    }

    public byte getStatus() {
        return status;
    }

    public int getElementAddress() {
        return elementAddress;
    }

    public int getAppKeyIndex() {
        return appKeyIndex;
    }

    public int getModelIdentifier() {
        return modelIdentifier;
    }
}
