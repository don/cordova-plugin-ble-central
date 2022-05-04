/********************************************************************************************************
 * @file     FastProvisioningDevice.java 
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
import android.os.Parcelable;

import com.telink.ble.mesh.util.Arrays;

/**
 * Model for provisioning flow
 * Created by kee on 2019/9/4.
 */
// advertisingDevice is null
public class FastProvisioningDevice implements Parcelable {

    private int originAddress;

    private int newAddress;

    private int pid;

    private int elementCount;

    private byte[] mac;

    private byte[] deviceKey;


    public FastProvisioningDevice() {

    }

    public FastProvisioningDevice(int originAddress, int newAddress, int pid, int elementCount, byte[] mac) {
        this.originAddress = originAddress;
        this.newAddress = newAddress;
        this.pid = pid;
        this.elementCount = elementCount;
        this.mac = Arrays.reverse(mac);
        this.deviceKey = new byte[16];
        System.arraycopy(mac, 0, deviceKey, 0, 6);
    }

    protected FastProvisioningDevice(Parcel in) {
        originAddress = in.readInt();
        newAddress = in.readInt();
        pid = in.readInt();
        elementCount = in.readInt();
        mac = in.createByteArray();
        deviceKey = in.createByteArray();
    }

    public static final Creator<FastProvisioningDevice> CREATOR = new Creator<FastProvisioningDevice>() {
        @Override
        public FastProvisioningDevice createFromParcel(Parcel in) {
            return new FastProvisioningDevice(in);
        }

        @Override
        public FastProvisioningDevice[] newArray(int size) {
            return new FastProvisioningDevice[size];
        }
    };

    public byte[] getMac() {
        return mac;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        FastProvisioningDevice device = (FastProvisioningDevice) o;
        return java.util.Arrays.equals(mac, device.mac);
    }

    @Override
    public int hashCode() {
        return java.util.Arrays.hashCode(mac);
    }

    public int getOriginAddress() {
        return originAddress;
    }

    public void setOriginAddress(int originAddress) {
        this.originAddress = originAddress;
    }

    public int getNewAddress() {
        return newAddress;
    }

    public void setNewAddress(int newAddress) {
        this.newAddress = newAddress;
    }

    public int getPid() {
        return pid;
    }

    public void setPid(int pid) {
        this.pid = pid;
    }

    public void setMac(byte[] mac) {
        this.mac = mac;
    }

    public byte[] getDeviceKey() {
        return deviceKey;
    }

    public void setDeviceKey(byte[] deviceKey) {
        this.deviceKey = deviceKey;
    }

    public int getElementCount() {
        return elementCount;
    }

    public void setElementCount(int elementCount) {
        this.elementCount = elementCount;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(originAddress);
        dest.writeInt(newAddress);
        dest.writeInt(pid);
        dest.writeInt(elementCount);
        dest.writeByteArray(mac);
        dest.writeByteArray(deviceKey);
    }

    @Override
    public String toString() {
        return "FastProvisioningDevice{" +
                "originAddress=" + originAddress +
                ", newAddress=" + newAddress +
                ", pid=" + pid +
                ", elementCount=" + elementCount +
                ", mac=" + java.util.Arrays.toString(mac) +
                ", deviceKey=" + java.util.Arrays.toString(deviceKey) +
                '}';
    }
}
