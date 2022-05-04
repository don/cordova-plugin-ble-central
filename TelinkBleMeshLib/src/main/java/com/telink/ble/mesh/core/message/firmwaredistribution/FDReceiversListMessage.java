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

import com.telink.ble.mesh.core.message.StatusMessage;

import java.util.List;

/**
 * response to a Firmware Distribution Receivers Get message
 *
 * @see FDReceiversGetMessage
 */
public class FDReceiversListMessage extends StatusMessage implements Parcelable {

    /**
     * Receivers List Count
     * The number of entries in the Distribution Receivers List state
     * 2 bytes
     */
    private int receiversListCount;


    /**
     * First Index
     * 2 bytes
     */
    private int firstIndex;

    /**
     * List of entries
     * Optional
     */
    private List<DistributionReceiver> List;

    public FDReceiversListMessage() {
    }

    protected FDReceiversListMessage(Parcel in) {
        receiversListCount = in.readInt();
        firstIndex = in.readInt();
    }

    public static final Creator<FDReceiversListMessage> CREATOR = new Creator<FDReceiversListMessage>() {
        @Override
        public FDReceiversListMessage createFromParcel(Parcel in) {
            return new FDReceiversListMessage(in);
        }

        @Override
        public FDReceiversListMessage[] newArray(int size) {
            return new FDReceiversListMessage[size];
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
        dest.writeInt(receiversListCount);
        dest.writeInt(firstIndex);
    }

    static public class DistributionReceiver {
        /**
         * Address
         * 15 least significant bits of the unicast address of the Updating node
         * 15 bits
         */
        public int address;
        /**
         * Retrieved Update Phase
         * Retrieved Update Phase state of the Updating node
         * 4 bits
         */
        public byte retrievedUpdatePhase;
        /**
         * Update Status
         * Status of the last operation with the Firmware Update Server
         * 3	bits
         */
        public byte updateStatus;

        /**
         * Transfer Status
         * Status of the last operation with the BLOB Transfer Server
         * 4 bits
         */
        public byte transferStatus;


        /**
         * Transfer Progress
         * Progress of the BLOB transfer in 2 percent increments
         * 6 bits
         */
        public byte transferProgress;

        /**
         * Update Firmware Image Index
         * Index of the firmware image on the Firmware Information List state that is being updated.
         * 8 bits
         */
        public byte imageIndex;

    }
}
