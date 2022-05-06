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

/**
 * The Firmware Distribution Status message is an unacknowledged message sent by a Firmware Distribution Server to report the status of a firmware image distribution.
 * A Firmware Distribution Status message is sent as a response to:
 * Firmware Distribution Get message,
 * Firmware Distribution Start message, Firmware Distribution Cancel message,
 * Firmware Distribution Apply message.
 */
public class FDStatusMessage extends StatusMessage implements Parcelable {

    /**
     * Status
     * Status Code for the requesting message
     * 8 bits
     */
    public int status;

    /**
     * Distribution Phase
     * Phase of the firmware image distribution
     * 8 bits
     */
    public int distPhase;

    /**
     * Distribution Multicast Address
     * Multicast address used in firmware image distribution
     * (Optional)
     * 16 bits
     */
    public int distMulticastAddress;

    /**
     * Distribution AppKey Index
     * Index of an application key used in a firmware image distribution
     * 16 bits
     */
    public int distAppKeyIndex;

    /**
     * Distribution TTL
     * Time To Live value used in a firmware image distribution
     * 8 bits
     */
    public int distTTL;

    /**
     * Distribution Timeout Base
     * Used to compute the timeout of the firmware image distribution
     * 16 bits
     */
    public int distTimeoutBase;

    /**
     * Distribution Transfer Mode
     * Mode of the transfer
     * 2 bits
     */
    public int distTransferMode;

    /**
     * Update Policy
     * Firmware update policy
     * 1 bit
     */
    public int updatePolicy;

    /**
     * RFU
     * Reserved for Future Use
     * 5 bits
     */
    public int RFU;

    /**
     * Distribution Firmware Image Index
     * The index of the firmware image in the Firmware Images List state used during firmware image distribution (C.1)
     * 16 bits
     */
    public int distImageIndex;

    public FDStatusMessage() {
    }


    protected FDStatusMessage(Parcel in) {
        status = in.readInt();
        distPhase = in.readInt();
        distMulticastAddress = in.readInt();
        distAppKeyIndex = in.readInt();
        distTTL = in.readInt();
        distTimeoutBase = in.readInt();
        distTransferMode = in.readInt();
        updatePolicy = in.readInt();
        RFU = in.readInt();
        distImageIndex = in.readInt();
    }

    public static final Creator<FDStatusMessage> CREATOR = new Creator<FDStatusMessage>() {
        @Override
        public FDStatusMessage createFromParcel(Parcel in) {
            return new FDStatusMessage(in);
        }

        @Override
        public FDStatusMessage[] newArray(int size) {
            return new FDStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        this.status = params[index++] & 0xFF;
        this.distPhase = params[index++] & 0xFF;
        if (params.length == 2) {
            // distMulticastAddress is not present
            return;
        }

        // distMulticastAddress is present
        this.distMulticastAddress = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.distAppKeyIndex = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        this.distTTL = params[index++] & 0xFF;
        this.distTimeoutBase = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        this.distTransferMode = params[index] & 0b11;

        this.updatePolicy = (params[index] >> 2) & 0b01;

        this.RFU = (params[index] >> 3) & 0x1F;

        this.distImageIndex = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(status);
        dest.writeInt(distPhase);
        dest.writeInt(distMulticastAddress);
        dest.writeInt(distAppKeyIndex);
        dest.writeInt(distTTL);
        dest.writeInt(distTimeoutBase);
        dest.writeInt(distTransferMode);
        dest.writeInt(updatePolicy);
        dest.writeInt(RFU);
        dest.writeInt(distImageIndex);
    }
}
