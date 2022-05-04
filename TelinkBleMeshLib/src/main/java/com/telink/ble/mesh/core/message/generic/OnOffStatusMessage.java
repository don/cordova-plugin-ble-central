/********************************************************************************************************
 * @file     OnOffStatusMessage.java 
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
package com.telink.ble.mesh.core.message.generic;

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.message.StatusMessage;

/**
 * Created by kee on 2019/8/20.
 */

public class OnOffStatusMessage extends StatusMessage implements Parcelable {

    private static final int DATA_LEN_COMPLETE = 3;

    private byte presentOnOff;

    /**
     * The target value of the Generic OnOff state (optional).
     */
    private byte targetOnOff;

    private byte remainingTime;

    private boolean isComplete = false;

    public OnOffStatusMessage() {
    }


    protected OnOffStatusMessage(Parcel in) {
        presentOnOff = in.readByte();
        targetOnOff = in.readByte();
        remainingTime = in.readByte();
        isComplete = in.readByte() != 0;
    }

    public static final Creator<OnOffStatusMessage> CREATOR = new Creator<OnOffStatusMessage>() {
        @Override
        public OnOffStatusMessage createFromParcel(Parcel in) {
            return new OnOffStatusMessage(in);
        }

        @Override
        public OnOffStatusMessage[] newArray(int size) {
            return new OnOffStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        this.presentOnOff = params[0];
        if (params.length == DATA_LEN_COMPLETE) {
            this.isComplete = true;
            this.targetOnOff = params[1];
            this.remainingTime = params[2];
        }
    }

    public byte getPresentOnOff() {
        return presentOnOff;
    }

    public byte getTargetOnOff() {
        return targetOnOff;
    }

    public byte getRemainingTime() {
        return remainingTime;
    }

    public boolean isComplete() {
        return isComplete;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeByte(presentOnOff);
        dest.writeByte(targetOnOff);
        dest.writeByte(remainingTime);
        dest.writeByte((byte) (isComplete ? 1 : 0));
    }
}
