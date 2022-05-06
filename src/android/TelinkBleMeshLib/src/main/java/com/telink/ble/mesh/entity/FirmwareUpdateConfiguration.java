/********************************************************************************************************
 * @file     FirmwareUpdateConfiguration.java 
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
package com.telink.ble.mesh.entity;

import java.util.List;

/**
 * Created by kee on 2019/9/6.
 */

public class FirmwareUpdateConfiguration {
    private List<MeshUpdatingDevice> updatingDevices;
    private byte[] firmwareData;
    private byte[] metadata;
    private int appKeyIndex;
    private int groupAddress;

//    private int companyId = 0x0211;

//    private int firmwareId = 0xFF000021;

    private long blobId = 0x8877665544332211L;

    private boolean singleAndDirect = false;

    private int dleLength;

    public FirmwareUpdateConfiguration(List<MeshUpdatingDevice> updatingDevices,
                                       byte[] firmwareData,
                                       byte[] metadata,
                                       int appKeyIndex,
                                       int groupAddress) {
        this.updatingDevices = updatingDevices;
        this.firmwareData = firmwareData;
        this.metadata = metadata;
        this.appKeyIndex = appKeyIndex;
        this.groupAddress = groupAddress;
    }

    public List<MeshUpdatingDevice> getUpdatingDevices() {
        return updatingDevices;
    }

    public byte[] getFirmwareData() {
        return firmwareData;
    }

    public int getAppKeyIndex() {
        return appKeyIndex;
    }

    public int getGroupAddress() {
        return groupAddress;
    }

    public long getBlobId() {
        return blobId;
    }

    public boolean isSingleAndDirect() {
        return singleAndDirect;
    }

    public void setSingleAndDirect(boolean singleAndDirect) {
        this.singleAndDirect = singleAndDirect;
    }

    public int getDleLength() {
        return dleLength;
    }

    public void setDleLength(int dleLength) {
        this.dleLength = dleLength;
    }

    public byte[] getMetadata() {
        return metadata;
    }

    @Override
    public String toString() {
        return "FirmwareUpdateConfiguration{" +
                "updatingDevices=" + updatingDevices.size() +
                ", firmwareData=" + firmwareData.length +
                ", metadata=" + metadata.length +
                ", appKeyIndex=" + appKeyIndex +
                ", groupAddress=" + groupAddress +

                ", blobId=" + blobId +
                '}';
    }
}
