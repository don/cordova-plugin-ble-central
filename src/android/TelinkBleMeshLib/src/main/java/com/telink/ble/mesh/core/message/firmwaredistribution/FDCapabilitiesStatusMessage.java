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
 * Firmware Distribution Capabilities Status
 * response to a Firmware Distributor Capabilities Get message
 *
 * @see FDCapabilitiesGetMessage
 */
public class FDCapabilitiesStatusMessage extends StatusMessage implements Parcelable {

    /**
     * Max Distribution Receivers List Size
     * Maximum number of entries in the Distribution Receivers List state
     * 2 bytes
     */
    public int maxReceiversListSize;

    /**
     * Max Firmware Images List Size
     * Maximum number of entries in the Firmware Images List state
     * 2 bytes
     */
    private int maxImagesListSize;

    /**
     * Max Firmware Image Size
     * Maximum size of one firmware image (in octets)
     * 4 bytes
     */
    private int maxImageSize;

    /**
     * Max Upload Space
     * Total space dedicated to storage of firmware images (in octets)
     * 4 bytes
     */
    private int maxUploadSpace;

    /**
     * Remaining Upload Space
     * Remaining available space in firmware image storage (in octets)
     * 4 bytes
     */
    private int remainingUploadSpace;


    /**
     * Out-of-Band Retrieval Supported
     * Value of the Out-of-Band Retrieval Supported state
     * 1 byte
     */
    private int oobRetrievalSupported;

    /**
     * Supported URI Scheme Names
     * Value of the Supported URI Scheme Names state
     * Variable
     */
    private byte[] uriSchemeNames;


    public FDCapabilitiesStatusMessage() {
    }

    protected FDCapabilitiesStatusMessage(Parcel in) {
        maxReceiversListSize = in.readInt();
        maxImagesListSize = in.readInt();
        maxImageSize = in.readInt();
        maxUploadSpace = in.readInt();
        remainingUploadSpace = in.readInt();
        oobRetrievalSupported = in.readInt();
        uriSchemeNames = in.createByteArray();
    }

    public static final Creator<FDCapabilitiesStatusMessage> CREATOR = new Creator<FDCapabilitiesStatusMessage>() {
        @Override
        public FDCapabilitiesStatusMessage createFromParcel(Parcel in) {
            return new FDCapabilitiesStatusMessage(in);
        }

        @Override
        public FDCapabilitiesStatusMessage[] newArray(int size) {
            return new FDCapabilitiesStatusMessage[size];
        }
    };

    @Override
    public void parse(byte[] params) {
        int index = 0;

        this.maxReceiversListSize = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        this.maxImagesListSize = MeshUtils.bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        maxImageSize = MeshUtils.bytes2Integer(params, index, 4, ByteOrder.LITTLE_ENDIAN);
        index += 4;

        maxUploadSpace = MeshUtils.bytes2Integer(params, index, 4, ByteOrder.LITTLE_ENDIAN);
        index += 4;

        remainingUploadSpace = MeshUtils.bytes2Integer(params, index, 4, ByteOrder.LITTLE_ENDIAN);
        index += 4;

        oobRetrievalSupported = params[index++] & 0xFF;

        if (oobRetrievalSupported == DistributorCapabilities.OOBRetrievalSupported.SUPPORTED.value) {
            uriSchemeNames = new byte[params.length - index];
            System.arraycopy(params, index, uriSchemeNames, 0, uriSchemeNames.length);
        } else {
            uriSchemeNames = null;
        }
    }

    public int getMaxReceiversListSize() {
        return maxReceiversListSize;
    }

    public void setMaxReceiversListSize(int maxReceiversListSize) {
        this.maxReceiversListSize = maxReceiversListSize;
    }

    public int getMaxImagesListSize() {
        return maxImagesListSize;
    }

    public void setMaxImagesListSize(int maxImagesListSize) {
        this.maxImagesListSize = maxImagesListSize;
    }

    public int getMaxImageSize() {
        return maxImageSize;
    }

    public void setMaxImageSize(int maxImageSize) {
        this.maxImageSize = maxImageSize;
    }

    public int getMaxUploadSpace() {
        return maxUploadSpace;
    }

    public void setMaxUploadSpace(int maxUploadSpace) {
        this.maxUploadSpace = maxUploadSpace;
    }

    public int getRemainingUploadSpace() {
        return remainingUploadSpace;
    }

    public void setRemainingUploadSpace(int remainingUploadSpace) {
        this.remainingUploadSpace = remainingUploadSpace;
    }

    public int getOobRetrievalSupported() {
        return oobRetrievalSupported;
    }

    public void setOobRetrievalSupported(int oobRetrievalSupported) {
        this.oobRetrievalSupported = oobRetrievalSupported;
    }

    public byte[] getUriSchemeNames() {
        return uriSchemeNames;
    }

    public void setUriSchemeNames(byte[] uriSchemeNames) {
        this.uriSchemeNames = uriSchemeNames;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(maxReceiversListSize);
        dest.writeInt(maxImagesListSize);
        dest.writeInt(maxImageSize);
        dest.writeInt(maxUploadSpace);
        dest.writeInt(remainingUploadSpace);
        dest.writeInt(oobRetrievalSupported);
        dest.writeByteArray(uriSchemeNames);
    }
}
