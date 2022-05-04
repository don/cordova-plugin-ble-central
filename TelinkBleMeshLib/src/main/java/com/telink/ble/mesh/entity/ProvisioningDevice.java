/********************************************************************************************************
 * @file ProvisioningDevice.java
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
package com.telink.ble.mesh.entity;

import android.bluetooth.BluetoothDevice;
import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.provisioning.pdu.ProvisioningCapabilityPDU;
import com.telink.ble.mesh.util.Arrays;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * Model for provisioning flow
 * Created by kee on 2019/9/4.
 */

public class ProvisioningDevice implements Parcelable {

    /**
     * 16: key
     * 2: key index
     * 1: flags
     * 4: iv index
     * 2: unicast adr
     */
    private static final int DATA_PDU_LEN = 16 + 2 + 1 + 4 + 2;

    private BluetoothDevice bluetoothDevice;

    protected byte[] deviceUUID;


    /**
     * OOB Information
     * Bit - Description
     * 0 - Other
     * 1 - Electronic / URI
     * 2 - 2D machine-readable code
     * 3 - Bar code
     * 4 - Near Field Communication (NFC)
     * 5 - Number
     * 6 - String
     * 7 - Support for certificate-based provisioning
     * 8 - Support for provisioning records
     * 9 - Reserved for Future Use
     * 10 - Reserved for Future Use
     * 11 - On box
     * 12 - Inside box
     * 13 - On piece of paper
     * 14 - Inside manual
     * 15 - On device
     */
    protected int oobInfo;

    protected byte[] networkKey;

    protected int networkKeyIndex;

    /**
     * 1 bit
     */
    protected byte keyRefreshFlag;

    /**
     * 1 bit
     */
    protected byte ivUpdateFlag;

    /**
     * 4 bytes
     */
    protected int ivIndex;

    /**
     * unicast address for primary element
     * 2 bytes
     */
    protected int unicastAddress;


    /**
     * auth value for static oob AuthMethod
     * {@link com.telink.ble.mesh.core.provisioning.AuthenticationMethod#StaticOOB}
     */
    protected byte[] authValue = null;

    /**
     * auto use no-OOB if auth value is null
     */
    protected boolean autoUseNoOOB = false;

//    private ProvisioningParams provisioningParams;

    protected int provisioningState;

    /**
     * valued when generating provisioning data
     */
    protected byte[] deviceKey = null;

    protected ProvisioningCapabilityPDU deviceCapability = null;

    public ProvisioningDevice(BluetoothDevice bluetoothDevice, byte[] deviceUUID, int unicastAddress) {
        this.bluetoothDevice = bluetoothDevice;
        this.deviceUUID = deviceUUID;
        this.unicastAddress = unicastAddress;
    }

    public ProvisioningDevice(BluetoothDevice bluetoothDevice, byte[] deviceUUID, byte[] networkKey, int networkKeyIndex, byte keyRefreshFlag, byte ivUpdateFlag, int ivIndex, int unicastAddress) {
        this.bluetoothDevice = bluetoothDevice;
        this.deviceUUID = deviceUUID;
        this.networkKey = networkKey;
        this.networkKeyIndex = networkKeyIndex;
        this.keyRefreshFlag = keyRefreshFlag;
        this.ivUpdateFlag = ivUpdateFlag;
        this.ivIndex = ivIndex;
        this.unicastAddress = unicastAddress;
    }


    public ProvisioningDevice() {
    }

    protected ProvisioningDevice(Parcel in) {
        bluetoothDevice = in.readParcelable(BluetoothDevice.class.getClassLoader());
        deviceUUID = in.createByteArray();
        oobInfo = in.readInt();
        networkKey = in.createByteArray();
        networkKeyIndex = in.readInt();
        keyRefreshFlag = in.readByte();
        ivUpdateFlag = in.readByte();
        ivIndex = in.readInt();
        unicastAddress = in.readInt();
        authValue = in.createByteArray();
        provisioningState = in.readInt();
        deviceKey = in.createByteArray();
    }

    public static final Creator<ProvisioningDevice> CREATOR = new Creator<ProvisioningDevice>() {
        @Override
        public ProvisioningDevice createFromParcel(Parcel in) {
            return new ProvisioningDevice(in);
        }

        @Override
        public ProvisioningDevice[] newArray(int size) {
            return new ProvisioningDevice[size];
        }
    };

    public byte[] generateProvisioningData() {
        byte flags = (byte) ((keyRefreshFlag & 0b01) | (ivUpdateFlag & 0b10));
        ByteBuffer buffer = ByteBuffer.allocate(DATA_PDU_LEN).order(ByteOrder.BIG_ENDIAN);
        buffer.put(networkKey)
                .putShort((short) networkKeyIndex)
                .put(flags)
                .putInt(ivIndex)
                .putShort((short) unicastAddress);
        return buffer.array();
    }


    public int getOobInfo() {
        return oobInfo;
    }

    public void setOobInfo(int oobInfo) {
        this.oobInfo = oobInfo;
    }

    public BluetoothDevice getBluetoothDevice() {
        return bluetoothDevice;
    }

    public byte[] getDeviceUUID() {
        return deviceUUID;
    }

    public byte[] getNetworkKey() {
        return networkKey;
    }

    public void setNetworkKey(byte[] networkKey) {
        this.networkKey = networkKey;
    }

    public int getNetworkKeyIndex() {
        return networkKeyIndex;
    }

    public void setNetworkKeyIndex(int networkKeyIndex) {
        this.networkKeyIndex = networkKeyIndex;
    }

    public byte getKeyRefreshFlag() {
        return keyRefreshFlag;
    }

    public void setKeyRefreshFlag(byte keyRefreshFlag) {
        this.keyRefreshFlag = keyRefreshFlag;
    }

    public byte getIvUpdateFlag() {
        return ivUpdateFlag;
    }

    public void setIvUpdateFlag(byte ivUpdateFlag) {
        this.ivUpdateFlag = ivUpdateFlag;
    }

    public int getIvIndex() {
        return ivIndex;
    }

    public void setIvIndex(int ivIndex) {
        this.ivIndex = ivIndex;
    }

    public int getUnicastAddress() {
        return unicastAddress;
    }

    public byte[] getAuthValue() {
        return authValue;
    }

    public void setAuthValue(byte[] authValue) {
        this.authValue = authValue;
    }

    public int getProvisioningState() {
        return provisioningState;
    }

    public void setProvisioningState(int provisioningState) {
        this.provisioningState = provisioningState;
    }

    public byte[] getDeviceKey() {
        return deviceKey;
    }

    public void setDeviceKey(byte[] deviceKey) {
        this.deviceKey = deviceKey;
    }

    public ProvisioningCapabilityPDU getDeviceCapability() {
        return deviceCapability;
    }

    public void setDeviceCapability(ProvisioningCapabilityPDU deviceCapability) {
        this.deviceCapability = deviceCapability;
    }

    public void setUnicastAddress(int unicastAddress) {
        this.unicastAddress = unicastAddress;
    }

    public boolean isAutoUseNoOOB() {
        return autoUseNoOOB;
    }

    public void setAutoUseNoOOB(boolean autoUseNoOOB) {
        this.autoUseNoOOB = autoUseNoOOB;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeParcelable(bluetoothDevice, flags);
        dest.writeByteArray(deviceUUID);
        dest.writeInt(oobInfo);
        dest.writeByteArray(networkKey);
        dest.writeInt(networkKeyIndex);
        dest.writeByte(keyRefreshFlag);
        dest.writeByte(ivUpdateFlag);
        dest.writeInt(ivIndex);
        dest.writeInt(unicastAddress);
        dest.writeByteArray(authValue);
        dest.writeInt(provisioningState);
        dest.writeByteArray(deviceKey);
    }

    @Override
    public String toString() {
        return "ProvisioningDevice{" +
                "deviceUUID=" + Arrays.bytesToHexString(deviceUUID) +
                ", oobInfo=0b" + Integer.toBinaryString(oobInfo) +
                ", networkKey=" + Arrays.bytesToHexString(networkKey) +
                ", networkKeyIndex=" + networkKeyIndex +
                ", keyRefreshFlag=" + keyRefreshFlag +
                ", ivUpdateFlag=" + ivUpdateFlag +
                ", ivIndex=0x" + Long.toHexString(ivIndex) +
                ", unicastAddress=0x" + Integer.toHexString(unicastAddress) +
                ", authValue=" + Arrays.bytesToHexString(authValue) +
                ", autoUseNoOOB=" + autoUseNoOOB +
                ", provisioningState=" + provisioningState +
                ", deviceKey=" + Arrays.bytesToHexString(deviceKey) +

                '}';
    }
}
