/********************************************************************************************************
 * @file     NodeResetStatusMessage.java 
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

/**
 * node reset status is empty message
 * Created by kee on 2019/9/18.
 */

public class NodeResetStatusMessage extends StatusMessage implements Parcelable {

    public NodeResetStatusMessage() {
    }

    protected NodeResetStatusMessage(Parcel in) {

    }

    public static final Creator<NodeResetStatusMessage> CREATOR = new Creator<NodeResetStatusMessage>() {
        @Override
        public NodeResetStatusMessage createFromParcel(Parcel in) {
            return new NodeResetStatusMessage(in);
        }

        @Override
        public NodeResetStatusMessage[] newArray(int size) {
            return new NodeResetStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {

    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
    }
}
