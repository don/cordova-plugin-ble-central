/********************************************************************************************************
 * @file     ModelPublicationStatusMessage.java 
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
import com.telink.ble.mesh.entity.ModelPublication;

import java.nio.ByteOrder;

/**
 * Created by kee on 2019/9/10.
 */

public class ModelPublicationStatusMessage extends StatusMessage implements Parcelable {

    private byte status;

    private ModelPublication publication;

    public ModelPublicationStatusMessage() {
    }

    protected ModelPublicationStatusMessage(Parcel in) {
        status = in.readByte();
        publication = in.readParcelable(ModelPublication.class.getClassLoader());
    }

    public static final Creator<ModelPublicationStatusMessage> CREATOR = new Creator<ModelPublicationStatusMessage>() {
        @Override
        public ModelPublicationStatusMessage createFromParcel(Parcel in) {
            return new ModelPublicationStatusMessage(in);
        }

        @Override
        public ModelPublicationStatusMessage[] newArray(int size) {
            return new ModelPublicationStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] data) {
        int index = 0;
        this.status = data[index++];

        ModelPublication modelPublication = new ModelPublication();
        modelPublication.elementAddress = MeshUtils.bytes2Integer(data, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        modelPublication.publishAddress = MeshUtils.bytes2Integer(data, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        modelPublication.appKeyIndex = (data[index++] & 0xFF) | ((data[index] & 0b1111) << 8);

        modelPublication.credentialFlag = (data[index] >> 4) & 0b1;
        modelPublication.rfu = (data[index] >> 5) & 0b111;
        index++;

        modelPublication.ttl = data[index++];
        modelPublication.period = data[index++];
        modelPublication.retransmitCount = (data[index] >> 5) & 0b111;
        modelPublication.retransmitIntervalSteps = data[index++] & 0x1F;

        modelPublication.modelId = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8);
        if ((index + 2) <= data.length) {
            modelPublication.sig = true;
            modelPublication.modelId |= ((data[index++] & 0xFF) << 16) | ((data[index] & 0xFF) << 24);
        }
        this.publication = modelPublication;
    }


    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte(status);
        dest.writeParcelable(publication, flags);
    }

    public byte getStatus() {
        return status;
    }

    public ModelPublication getPublication() {
        return publication;
    }
}
