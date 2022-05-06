/********************************************************************************************************
 * @file     NodeIdentityStatusMessage.java 
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

public class NodeIdentityStatusMessage extends StatusMessage implements Parcelable {

    /**
     * 1 byte
     */
    private int status;

    /**
     * 2 bytes
     */
    private int netKeyIndex;

    /**
     * 1 byte
     */
    private int identity;

    public NodeIdentityStatusMessage() {
    }


    protected NodeIdentityStatusMessage(Parcel in) {
        status = in.readInt();
        netKeyIndex = in.readInt();
        identity = in.readInt();
    }

    public static final Creator<NodeIdentityStatusMessage> CREATOR = new Creator<NodeIdentityStatusMessage>() {
        @Override
        public NodeIdentityStatusMessage createFromParcel(Parcel in) {
            return new NodeIdentityStatusMessage(in);
        }

        @Override
        public NodeIdentityStatusMessage[] newArray(int size) {
            return new NodeIdentityStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        status = params[index++] & 0xFF;
        netKeyIndex = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        identity = params[index] & 0xFF;
    }

    public int getStatus() {
        return status;
    }

    public int getNetKeyIndex() {
        return netKeyIndex;
    }

    public int getIdentity() {
        return identity;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(status);
        dest.writeInt(netKeyIndex);
        dest.writeInt(identity);
    }
}
