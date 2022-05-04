/********************************************************************************************************
 * @file     BlobTransferStatusMessage.java 
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
import java.util.ArrayList;
import java.util.List;

public class BlobTransferStatusMessage extends StatusMessage implements Parcelable {

    /**
     * Status Code for the requesting message
     * lower 4 bits in first byte
     */
    private int status;

    /**
     * BLOB transfer mode
     * higher 2 bits in first byte
     */
    private int transferMode;

    /**
     * Transfer phase
     * 8 bits
     */
    private byte transferPhase;

    /**
     * BLOB identifier (Optional)
     * 64 bits
     */
    private long blobId;

    /**
     * BLOB size in octets
     * If the BLOB ID field is present, then the BLOB Size field may be present;
     * otherwise, the BLOB Size field shall not be present.
     * 32 bits
     */
    private int blobSize;

    /**
     * Indicates the block size
     * 8 bits
     * present if blobSize is present
     */
    private int blockSizeLog;

    /**
     * MTU size in octets
     * 16 bits
     * present if blobSize is present
     */
    private int transferMTUSize;

    /**
     * Bit field indicating blocks that were not received
     * length: Variable, currently 64 bits max
     * present if blobSize is present
     */
    private List<Integer> blocksNotReceived;

    public BlobTransferStatusMessage() {
    }


    protected BlobTransferStatusMessage(Parcel in) {
        status = in.readInt();
        transferMode = in.readInt();
        transferPhase = in.readByte();
        blobId = in.readLong();
        blobSize = in.readInt();
        blockSizeLog = in.readInt();
        transferMTUSize = in.readInt();
        blocksNotReceived = new ArrayList<>();
        in.readList(blocksNotReceived, null);
    }

    public static final Creator<BlobTransferStatusMessage> CREATOR = new Creator<BlobTransferStatusMessage>() {
        @Override
        public BlobTransferStatusMessage createFromParcel(Parcel in) {
            return new BlobTransferStatusMessage(in);
        }

        @Override
        public BlobTransferStatusMessage[] newArray(int size) {
            return new BlobTransferStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;
        this.status = params[index] & 0x0F;
        this.transferMode = (params[index++] >> 6) & 0x03;
        this.transferPhase = params[index++];

        if (params.length < 10) return;

        this.blobId = MeshUtils.bytes2Long(params, index, 8, ByteOrder.LITTLE_ENDIAN);
        index += 8;

        if (params.length == 10) return;

        this.blobSize = MeshUtils.bytes2Integer(params, index, 4, ByteOrder.LITTLE_ENDIAN);
        index += 4;
        this.blockSizeLog = params[index++] & 0xFF;
        this.transferMTUSize = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        this.blocksNotReceived = MeshUtils.parseMissingBitField(params, index);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(status);
        dest.writeInt(transferMode);
        dest.writeByte(transferPhase);
        dest.writeLong(blobId);
        dest.writeInt(blobSize);
        dest.writeInt(blockSizeLog);
        dest.writeInt(transferMTUSize);
        dest.writeList(blocksNotReceived);
    }

    public int getStatus() {
        return status;
    }

    public int getTransferMode() {
        return transferMode;
    }

    public byte getTransferPhase() {
        return transferPhase;
    }

    public long getBlobId() {
        return blobId;
    }

    public int getBlobSize() {
        return blobSize;
    }

    public int getBlockSizeLog() {
        return blockSizeLog;
    }

    public int getTransferMTUSize() {
        return transferMTUSize;
    }

    public List<Integer> getBlocksNotReceived() {
        return blocksNotReceived;
    }

    @Override
    public String toString() {
        return "BlobTransferStatusMessage{" +
                "status=" + status +
                ", transferMode=" + transferMode +
                ", transferPhase=" + transferPhase +
                ", blobId=0x" + Long.toHexString(blobId) +
                ", blobSize=" + blobSize +
                ", blockSizeLog=" + blockSizeLog +
                ", transferMTUSize=" + transferMTUSize +
                ", blocksNotReceived=" + blocksNotReceived +
                '}';
    }
}
