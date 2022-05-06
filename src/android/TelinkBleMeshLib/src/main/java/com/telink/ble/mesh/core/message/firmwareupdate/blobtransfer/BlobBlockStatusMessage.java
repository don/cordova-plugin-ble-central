/********************************************************************************************************
 * @file     BlobBlockStatusMessage.java 
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

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.StatusMessage;

import java.nio.ByteOrder;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;

public class BlobBlockStatusMessage extends StatusMessage implements Parcelable {

    /**
     * All chunks in the block are missing.
     */
    public static final int FORMAT_ALL_CHUNKS_MISSING = 0x00;

    /**
     * All chunks in the block have been received.
     */
    public static final int FORMAT_NO_CHUNKS_MISSING = 0x01;

    /**
     * At least one chunk has been received and at least one chunk is missing.
     */
    public static final int FORMAT_SOME_CHUNKS_MISSING = 0x02;

    /**
     * List of chunks requested by the server
     */
    public static final int FORMAT_ENCODED_MISSING_CHUNKS = 0x03;

    /**
     * Status Code for the requesting message
     * lower 4 bits in first byte
     *
     * @see TransferStatus
     */
    private int status;

    /**
     * Indicates the format used to report missing chunks
     * higher 2 bits in first byte
     */
    private int format;

    /**
     * Transfer phase
     */
    // remote in R06 -- 20200618
//    private int transferPhase;

    /**
     * Block number of the current block
     * 16 bits
     */
    private int blockNumber;

    /**
     * Chunk Size (in octets) for the current block
     * 16 bits
     */
    private int chunkSize;

    /**
     * Bit field of missing chunks for this block
     */
    private List<Integer> missingChunks;

    /**
     * List of chunks requested by the server
     * using UTF-8
     */
    private List<Integer> encodedMissingChunks;


    public BlobBlockStatusMessage() {
    }


    protected BlobBlockStatusMessage(Parcel in) {
        status = in.readInt();
        format = in.readInt();
//        transferPhase = in.readInt();
        blockNumber = in.readInt();
        chunkSize = in.readInt();
        missingChunks = new ArrayList<>();
        in.readList(missingChunks, null);
        encodedMissingChunks = new ArrayList<>();
        in.readList(encodedMissingChunks, null);
    }

    public static final Creator<BlobBlockStatusMessage> CREATOR = new Creator<BlobBlockStatusMessage>() {
        @Override
        public BlobBlockStatusMessage createFromParcel(Parcel in) {
            return new BlobBlockStatusMessage(in);
        }

        @Override
        public BlobBlockStatusMessage[] newArray(int size) {
            return new BlobBlockStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        this.status = params[index] & 0x0F;
        this.format = (params[index++] >> 6) & 0x03;
//        transferPhase = params[index++] & 0xFF;
        this.blockNumber = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.chunkSize = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        if (format == FORMAT_SOME_CHUNKS_MISSING) {
            missingChunks = MeshUtils.parseMissingBitField(params, index);
        } else if (format == FORMAT_ENCODED_MISSING_CHUNKS) {
            encodedMissingChunks = new ArrayList<>();
            byte[] missing = new byte[params.length - index];
            System.arraycopy(params, index, missing, 0, missing.length);
            String decodeMissingChunks = new String(missing, Charset.forName("UTF-8"));
            for (char c : decodeMissingChunks.toCharArray()) {
                encodedMissingChunks.add(c & 0xFFFF);
            }
        }
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(status);
        dest.writeInt(format);
//        dest.writeInt(transferPhase);
        dest.writeInt(blockNumber);
        dest.writeInt(chunkSize);
        dest.writeList(missingChunks);
        dest.writeList(encodedMissingChunks);
    }

    public int getStatus() {
        return status;
    }

    public int getFormat() {
        return format;
    }

    public int getBlockNumber() {
        return blockNumber;
    }

    public long getChunkSize() {
        return chunkSize;
    }

    public List<Integer> getMissingChunks() {
        return missingChunks;
    }

    public List<Integer> getEncodedMissingChunks() {
        return encodedMissingChunks;
    }

    @Override
    public String toString() {
        return "BlobBlockStatusMessage{" +
                "status=" + status +
                ", format=" + format +
                ", blockNumber=" + blockNumber +
                ", chunkSize=" + chunkSize +
                ", missingChunks=" + (missingChunks == null ? "null" : missingChunks.size()) +
                ", encodedMissingChunks=" + (encodedMissingChunks == null ? "null" : encodedMissingChunks.size()) +
                '}';
    }
}
