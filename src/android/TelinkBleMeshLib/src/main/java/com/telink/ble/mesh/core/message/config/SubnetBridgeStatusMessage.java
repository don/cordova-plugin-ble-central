/********************************************************************************************************
 * @file NodeIdentityStatusMessage.java
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
package com.telink.ble.mesh.core.message.config;

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.message.StatusMessage;

/**
 * Created by kee on 2019/9/10.
 */

public class SubnetBridgeStatusMessage extends StatusMessage implements Parcelable {

    /**
     * 1 byte
     * 0x00	Subnet bridge functionality is disabled.
     * 0x01	Subnet bridge functionality is enabled.
     */
    private byte subnetBridgeState;

    public SubnetBridgeStatusMessage() {
    }


    protected SubnetBridgeStatusMessage(Parcel in) {
        subnetBridgeState = in.readByte();
    }

    public static final Creator<SubnetBridgeStatusMessage> CREATOR = new Creator<SubnetBridgeStatusMessage>() {
        @Override
        public SubnetBridgeStatusMessage createFromParcel(Parcel in) {
            return new SubnetBridgeStatusMessage(in);
        }

        @Override
        public SubnetBridgeStatusMessage[] newArray(int size) {
            return new SubnetBridgeStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        subnetBridgeState = params[0];
    }

    public byte getSubnetBridgeState() {
        return subnetBridgeState;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte(subnetBridgeState);
    }
}
