/********************************************************************************************************
 * @file     ScanStatusMessage.java 
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
package com.telink.ble.mesh.core.message.rp;

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.message.StatusMessage;

/**
 * Created by kee on 2019/8/20.
 */

public class ScanStatusMessage extends StatusMessage implements Parcelable {

    private byte status;

    private byte rpScanningState;

    private byte scannedItemsLimit;

    private byte timeout;

    public ScanStatusMessage() {
    }


    protected ScanStatusMessage(Parcel in) {
        status = in.readByte();
        rpScanningState = in.readByte();
        scannedItemsLimit = in.readByte();
        timeout = in.readByte();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte(status);
        dest.writeByte(rpScanningState);
        dest.writeByte(scannedItemsLimit);
        dest.writeByte(timeout);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<ScanStatusMessage> CREATOR = new Creator<ScanStatusMessage>() {
        @Override
        public ScanStatusMessage createFromParcel(Parcel in) {
            return new ScanStatusMessage(in);
        }

        @Override
        public ScanStatusMessage[] newArray(int size) {
            return new ScanStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        this.status = params[index++];
        this.rpScanningState = params[index++];
        this.scannedItemsLimit = params[index++];
        this.timeout = params[index];
    }

    public byte getStatus() {
        return status;
    }

    public byte getRpScanningState() {
        return rpScanningState;
    }

    public byte getScannedItemsLimit() {
        return scannedItemsLimit;
    }

    public byte getTimeout() {
        return timeout;
    }
}
