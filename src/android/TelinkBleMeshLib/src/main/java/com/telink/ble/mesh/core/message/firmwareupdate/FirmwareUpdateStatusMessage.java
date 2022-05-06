/********************************************************************************************************
 * @file     FirmwareUpdateStatusMessage.java 
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
package com.telink.ble.mesh.core.message.firmwareupdate;

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.StatusMessage;

import java.nio.ByteOrder;

public class FirmwareUpdateStatusMessage extends StatusMessage implements Parcelable {


    /**
     * @see UpdateStatus
     * 3 lower bits in first byte
     */
    private int status;

    /**
     * 3 higher bits in first byte (2 bits rfu)
     */
    private int phase;

    /**
     * Time To Live value to use during firmware image transfer
     * 1 byte
     */
    private byte updateTtl;


    /**
     * 5 bits (3 bits rfu)
     */
    private int additionalInfo;

    /**
     * Used to compute the timeout of the firmware image transfer
     * Client Timeout = [12,000 * (Client Timeout Base + 1) + 100 * Transfer TTL] milliseconds
     * using blockSize
     * 2 bytes
     */
    private int updateTimeoutBase;

    /**
     * BLOB identifier for the firmware image
     * 8 bytes
     */
    private long updateBLOBID;

    /**
     * length: 1 byte
     */
    private int updateFirmwareImageIndex;

    /**
     * If the Update TTL field is present,
     * the Additional Information field, Update Timeout field, BLOB ID field, and Installed Firmware ID field shall be present;
     * otherwise, the Additional Information field, Update Timeout field, BLOB ID field, and Installed Firmware ID field shall not be present.
     */
    private boolean isComplete = false;

    public FirmwareUpdateStatusMessage() {
    }


    protected FirmwareUpdateStatusMessage(Parcel in) {
        status = in.readInt();
        phase = in.readInt();
        updateTtl = in.readByte();
        additionalInfo = in.readInt();
        updateTimeoutBase = in.readInt();
        updateBLOBID = in.readLong();
        updateFirmwareImageIndex = in.readInt();
        isComplete = in.readByte() != 0;
    }

    public static final Creator<FirmwareUpdateStatusMessage> CREATOR = new Creator<FirmwareUpdateStatusMessage>() {
        @Override
        public FirmwareUpdateStatusMessage createFromParcel(Parcel in) {
            return new FirmwareUpdateStatusMessage(in);
        }

        @Override
        public FirmwareUpdateStatusMessage[] newArray(int size) {
            return new FirmwareUpdateStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;

        this.status = params[index] & 0x07;

        this.phase = (params[index] & 0xFF) >> 5;

        isComplete = params.length > 1;
        if (!isComplete) return;
        index++;

        this.updateTtl = params[index++];

        this.additionalInfo = (params[index++] & 0x1F);

        this.updateTimeoutBase = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        this.updateBLOBID = MeshUtils.bytes2Integer(params, index, 8, ByteOrder.LITTLE_ENDIAN);
        index += 8;

        this.updateFirmwareImageIndex = params[index] & 0xFF;

    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(status);
        dest.writeInt(phase);
        dest.writeByte(updateTtl);
        dest.writeInt(additionalInfo);
        dest.writeInt(updateTimeoutBase);
        dest.writeLong(updateBLOBID);
        dest.writeInt(updateFirmwareImageIndex);
        dest.writeByte((byte) (isComplete ? 1 : 0));
    }

    public int getStatus() {
        return status;
    }

    public int getPhase() {
        return phase;
    }

    public byte getUpdateTtl() {
        return updateTtl;
    }

    public int getAdditionalInfo() {
        return additionalInfo;
    }

    public int getUpdateTimeoutBase() {
        return updateTimeoutBase;
    }

    public long getUpdateBLOBID() {
        return updateBLOBID;
    }

    public int getUpdateFirmwareImageIndex() {
        return updateFirmwareImageIndex;
    }

    public boolean isComplete() {
        return isComplete;
    }

    @Override
    public String toString() {
        return "FirmwareUpdateStatusMessage{" +
                "status=" + status +
                ", phase=" + phase +
                ", updateTtl=" + updateTtl +
                ", additionalInfo=" + additionalInfo +
                ", updateTimeoutBase=" + updateTimeoutBase +
                ", updateBLOBID=0x" + Long.toHexString(updateBLOBID) +
                ", updateFirmwareImageIndex=" + updateFirmwareImageIndex +
                ", isComplete=" + isComplete +
                '}';
    }
}
