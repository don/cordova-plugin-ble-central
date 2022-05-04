/********************************************************************************************************
 * @file     ProvisioningPDUReportMessage.java 
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
import com.telink.ble.mesh.util.Arrays;


/**
 * Created by kee on 2019/8/20.
 */

public class ProvisioningPDUReportMessage extends StatusMessage implements Parcelable {

    private byte inboundPDUNumber;

    private byte[] provisioningPDU;

    public ProvisioningPDUReportMessage() {
    }


    protected ProvisioningPDUReportMessage(Parcel in) {
        inboundPDUNumber = in.readByte();
        provisioningPDU = in.createByteArray();
    }

    public static final Creator<ProvisioningPDUReportMessage> CREATOR = new Creator<ProvisioningPDUReportMessage>() {
        @Override
        public ProvisioningPDUReportMessage createFromParcel(Parcel in) {
            return new ProvisioningPDUReportMessage(in);
        }

        @Override
        public ProvisioningPDUReportMessage[] newArray(int size) {
            return new ProvisioningPDUReportMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        this.inboundPDUNumber = params[0];
        if (params.length > 1) {
            int pduLen = params.length - 1;
            provisioningPDU = new byte[pduLen];
            System.arraycopy(params, 1, this.provisioningPDU, 0, pduLen);
        }
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte(inboundPDUNumber);
        dest.writeByteArray(provisioningPDU);
    }

    public byte getInboundPDUNumber() {
        return inboundPDUNumber;
    }

    public byte[] getProvisioningPDU() {
        return provisioningPDU;
    }

    @Override
    public String toString() {
        return "ProvisioningPDUReportMessage{" +
                "inboundPDUNumber=" + inboundPDUNumber +
                ", provisioningPDU=" + Arrays.bytesToHexString(provisioningPDU) +
                '}';
    }
}
