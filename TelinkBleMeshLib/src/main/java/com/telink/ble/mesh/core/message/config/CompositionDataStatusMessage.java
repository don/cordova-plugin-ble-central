/********************************************************************************************************
 * @file     CompositionDataStatusMessage.java 
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

import com.telink.ble.mesh.core.message.StatusMessage;
import com.telink.ble.mesh.entity.CompositionData;

/**
 * node reset status is empty message
 * Created by kee on 2019/9/18.
 */

public class CompositionDataStatusMessage extends StatusMessage implements Parcelable {

    private byte page;

    private CompositionData compositionData;

    public CompositionDataStatusMessage() {
    }

    protected CompositionDataStatusMessage(Parcel in) {
        page = in.readByte();
        compositionData = in.readParcelable(CompositionData.class.getClassLoader());
    }

    public static final Creator<CompositionDataStatusMessage> CREATOR = new Creator<CompositionDataStatusMessage>() {
        @Override
        public CompositionDataStatusMessage createFromParcel(Parcel in) {
            return new CompositionDataStatusMessage(in);
        }

        @Override
        public CompositionDataStatusMessage[] newArray(int size) {
            return new CompositionDataStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        page = params[0];
        byte[] cpsData = new byte[params.length - 1];
        System.arraycopy(params, 1, cpsData, 0, cpsData.length);
        compositionData = CompositionData.from(cpsData);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte(page);
        dest.writeParcelable(compositionData, flags);
    }

    public byte getPage() {
        return page;
    }

    public CompositionData getCompositionData() {
        return compositionData;
    }
}
