/********************************************************************************************************
 * @file     BlobPartialBlockReportMessage.java 
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
package com.telink.ble.mesh.core.message.firmwareupdate.blobtransfer;

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.message.StatusMessage;

import java.nio.charset.Charset;
import java.util.ArrayList;

public class BlobPartialBlockReportMessage extends StatusMessage implements Parcelable {

    /**
     * List of chunks requested by the server
     * using UTF-8
     */
    private ArrayList<Integer> encodedMissingChunks;


    public BlobPartialBlockReportMessage() {

    }


    protected BlobPartialBlockReportMessage(Parcel in) {
        encodedMissingChunks = new ArrayList<>();
        in.readList(encodedMissingChunks, null);
    }

    public static final Creator<BlobPartialBlockReportMessage> CREATOR = new Creator<BlobPartialBlockReportMessage>() {
        @Override
        public BlobPartialBlockReportMessage createFromParcel(Parcel in) {
            return new BlobPartialBlockReportMessage(in);
        }

        @Override
        public BlobPartialBlockReportMessage[] newArray(int size) {
            return new BlobPartialBlockReportMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        encodedMissingChunks = new ArrayList<>();
        String decodeMissingChunks = new String(params, Charset.forName("UTF-8"));
        for (char c : decodeMissingChunks.toCharArray()) {
            encodedMissingChunks.add(c & 0xFFFF);
        }
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeList(encodedMissingChunks);
    }

    public ArrayList<Integer> getEncodedMissingChunks() {
        return encodedMissingChunks;
    }
}
