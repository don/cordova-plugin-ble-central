/********************************************************************************************************
 * @file     ProvisioningPDUOutboundReportMessage.java 
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

public class ProvisioningPDUOutboundReportMessage extends StatusMessage implements Parcelable {

    private byte outboundPDUNumber;


    public ProvisioningPDUOutboundReportMessage() {
    }


    protected ProvisioningPDUOutboundReportMessage(Parcel in) {
        outboundPDUNumber = in.readByte();
    }

    public static final Creator<ProvisioningPDUOutboundReportMessage> CREATOR = new Creator<ProvisioningPDUOutboundReportMessage>() {
        @Override
        public ProvisioningPDUOutboundReportMessage createFromParcel(Parcel in) {
            return new ProvisioningPDUOutboundReportMessage(in);
        }

        @Override
        public ProvisioningPDUOutboundReportMessage[] newArray(int size) {
            return new ProvisioningPDUOutboundReportMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        this.outboundPDUNumber = params[0];
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte(outboundPDUNumber);
    }

    public byte getOutboundPDUNumber() {
        return outboundPDUNumber;
    }
}
