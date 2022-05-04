/********************************************************************************************************
 * @file     RemoteProvisioningDevice.java 
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

import android.os.Parcel;

import com.telink.ble.mesh.core.message.rp.ScanReportStatusMessage;
import com.telink.ble.mesh.util.Arrays;

/**
 * Model for provisioning flow
 * Created by kee on 2019/9/4.
 */
// advertisingDevice is null
public class RemoteProvisioningDevice extends ProvisioningDevice {

    private byte rssi;

    private byte[] uuid = null;

    // proxy address
    private int serverAddress;


    public RemoteProvisioningDevice(byte rssi, byte[] uuid, int serverAddress) {
        this.rssi = rssi;
        this.uuid = uuid;
        this.serverAddress = serverAddress;
    }

    protected RemoteProvisioningDevice(Parcel in) {
        super(in);
        rssi = in.readByte();
        uuid = in.createByteArray();
        serverAddress = in.readInt();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        super.writeToParcel(dest, flags);
        dest.writeByte(rssi);
        dest.writeByteArray(uuid);
        dest.writeInt(serverAddress);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<RemoteProvisioningDevice> CREATOR = new Creator<RemoteProvisioningDevice>() {
        @Override
        public RemoteProvisioningDevice createFromParcel(Parcel in) {
            return new RemoteProvisioningDevice(in);
        }

        @Override
        public RemoteProvisioningDevice[] newArray(int size) {
            return new RemoteProvisioningDevice[size];
        }
    };

    public byte getRssi() {
        return rssi;
    }

    public byte[] getUuid() {
        return uuid;
    }

    public int getServerAddress() {
        return serverAddress;
    }

    public void setRssi(byte rssi) {
        this.rssi = rssi;
    }

    public void setUuid(byte[] uuid) {
        this.uuid = uuid;
    }

    public void setServerAddress(int serverAddress) {
        this.serverAddress = serverAddress;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        RemoteProvisioningDevice device = (RemoteProvisioningDevice) o;
        return java.util.Arrays.equals(uuid, device.uuid);
    }

    @Override
    public int hashCode() {
        return java.util.Arrays.hashCode(uuid);
    }


}
