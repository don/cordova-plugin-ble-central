/********************************************************************************************************
 * @file BridgingTableStatusMessage.java
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

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.StatusMessage;

import java.nio.ByteOrder;

/**
 * Created by kee on 2021/1/14.
 */
public class BridgingTableStatusMessage extends StatusMessage implements Parcelable {

    /**
     * Status Code for the requesting message
     * 8 bits
     */
    private int status;

    /**
     * Allowed directions for bridged traffic or bridged traffic not allowed
     * 8 bits
     */
    private byte currentDirections;

    /**
     * NetKey Index of the first subnet
     * 12 bits
     */
    public int netKeyIndex1;

    /**
     * NetKey Index of the second subnet
     * 12 bits
     */
    public int netKeyIndex2;

    /**
     * Address of the node in the first subnet
     * 16 bits
     */
    public int address1;

    /**
     * Address of the node in the second subnet
     * 16 bits
     */
    public int address2;


    public BridgingTableStatusMessage() {
    }


    protected BridgingTableStatusMessage(Parcel in) {
        status = in.readInt();
        currentDirections = in.readByte();
        netKeyIndex1 = in.readInt();
        netKeyIndex2 = in.readInt();
        address1 = in.readInt();
        address2 = in.readInt();
    }

    public static final Creator<BridgingTableStatusMessage> CREATOR = new Creator<BridgingTableStatusMessage>() {
        @Override
        public BridgingTableStatusMessage createFromParcel(Parcel in) {
            return new BridgingTableStatusMessage(in);
        }

        @Override
        public BridgingTableStatusMessage[] newArray(int size) {
            return new BridgingTableStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        this.status = params[index++] & 0xFF;
        this.currentDirections = params[index++];

        int netKeyIndexes = MeshUtils.bytes2Integer(new byte[]{
                params[index++], params[index++], params[index++],
        }, ByteOrder.LITTLE_ENDIAN);

        this.netKeyIndex1 = netKeyIndexes & 0x0FFF;
        this.netKeyIndex2 = (netKeyIndexes >> 12) & 0x0FFF;


        this.address1 = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.address2 = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
    }


    public int getStatus() {
        return status;
    }

    public byte getCurrentDirections() {
        return currentDirections;
    }

    public int getNetKeyIndex1() {
        return netKeyIndex1;
    }

    public int getNetKeyIndex2() {
        return netKeyIndex2;
    }

    public int getAddress1() {
        return address1;
    }

    public int getAddress2() {
        return address2;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(status);
        dest.writeByte(currentDirections);
        dest.writeInt(netKeyIndex1);
        dest.writeInt(netKeyIndex2);
        dest.writeInt(address1);
        dest.writeInt(address2);
    }
}
