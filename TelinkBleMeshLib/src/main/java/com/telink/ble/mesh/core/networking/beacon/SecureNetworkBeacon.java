/********************************************************************************************************
 * @file     SecureNetworkBeacon.java 
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
package com.telink.ble.mesh.core.networking.beacon;

import com.telink.ble.mesh.core.Encipher;
import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.util.Arrays;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class SecureNetworkBeacon extends MeshBeaconPDU {

    private static final int LENGTH_PAYLOAD = 22;

    private static final int MASK_KEY_REFRESH = 0b01;

    private static final int MASK_IV_UPDATE = 0b10;

    private final byte beaconType = BEACON_TYPE_SECURE_NETWORK;

    /**
     * Contains the Key Refresh Flag and IV Update Flag
     */
    private byte flags;

    /**
     * Contains the value of the Network ID
     * 8 bytes
     */
    private byte[] networkID;

    /**
     * Contains the current IV Index
     * 4 bytes
     * big endian
     */
    private int ivIndex;

    /**
     * Authenticates security network beacon
     * 8 bytes
     */
    private byte[] authenticationValue;


    /**
     * @return if is key refreshing
     */
    public boolean isKeyRefreshing() {
        return (flags & MASK_KEY_REFRESH) != 0;
    }

    /**
     * @return if is iv updating
     */
    public boolean isIvUpdating() {
        return (flags & MASK_IV_UPDATE) != 0;
    }

    public static SecureNetworkBeacon from(byte[] payload) {
        if (payload.length != LENGTH_PAYLOAD) {
            return null;
        }
        int index = 0;
        final byte beaconType = payload[index++];
        if (beaconType != BEACON_TYPE_SECURE_NETWORK) return null;
        SecureNetworkBeacon beacon = new SecureNetworkBeacon();
        beacon.flags = payload[index++];
        beacon.networkID = new byte[8];
        System.arraycopy(payload, index, beacon.networkID, 0, beacon.networkID.length);
        index += beacon.networkID.length;
        beacon.ivIndex = MeshUtils.bytes2Integer(payload, index, 4, ByteOrder.BIG_ENDIAN);
        index += 4;
        beacon.authenticationValue = new byte[8];
        System.arraycopy(payload, index, beacon.authenticationValue, 0, beacon.authenticationValue.length);
        return beacon;
    }

    public static SecureNetworkBeacon createIvUpdatingBeacon(int curIvIndex, byte[] networkId, byte[] beaconKey, boolean updating) {
        SecureNetworkBeacon networkBeacon = new SecureNetworkBeacon();
        networkBeacon.flags = (byte) (updating ? 0b10 : 0);
        networkBeacon.networkID = networkId;
        networkBeacon.ivIndex = updating ? curIvIndex + 1 : curIvIndex;

        final int calLen = 1 + 8 + 4;
        ByteBuffer buffer = ByteBuffer.allocate(calLen).order(ByteOrder.BIG_ENDIAN);
        buffer.put(networkBeacon.flags);
        buffer.put(networkBeacon.networkID);
        buffer.putInt(networkBeacon.ivIndex);
        byte[] auth = Encipher.aesCmac(buffer.array(), beaconKey);
        byte[] authCal = new byte[8];
        System.arraycopy(auth, 0, authCal, 0, authCal.length);
        networkBeacon.authenticationValue = authCal;
        return networkBeacon;
    }

    public boolean validateAuthValue(byte[] networkID, byte[] beaconKey) {
        if (!Arrays.equals(this.networkID, networkID)) return false;
        if (authenticationValue == null) return false;

        // flags, networkId, ivIndex
        final int calLen = 1 + 8 + 4;
        ByteBuffer buffer = ByteBuffer.allocate(calLen).order(ByteOrder.BIG_ENDIAN);
        buffer.put(flags);
        buffer.put(networkID);
        buffer.putInt(ivIndex);
        byte[] auth = Encipher.aesCmac(buffer.array(), beaconKey);
        byte[] authCal = new byte[8];
        System.arraycopy(auth, 0, authCal, 0, authCal.length);
        return Arrays.equals(authCal, this.authenticationValue);
    }

    @Override
    public String toString() {
        return "SecureNetworkBeacon{" +
                "beaconType=" + beaconType +
                ", flags=" + flags +
                ", networkID=" + Arrays.bytesToHexString(networkID, "") +
                ", ivIndex=0x" + String.format("%08X", ivIndex) +
                ", authenticationValue=" + Arrays.bytesToHexString(authenticationValue, "") +
                '}';
    }

    public byte getBeaconType() {
        return beaconType;
    }


    public byte getFlags() {
        return flags;
    }

    public void setFlags(byte flags) {
        this.flags = flags;
    }

    public byte[] getNetworkID() {
        return networkID;
    }

    public void setNetworkID(byte[] networkID) {
        this.networkID = networkID;
    }

    public int getIvIndex() {
        return ivIndex;
    }

    public void setIvIndex(int ivIndex) {
        this.ivIndex = ivIndex;
    }

    public byte[] getAuthenticationValue() {
        return authenticationValue;
    }

    public void setAuthenticationValue(byte[] authenticationValue) {
        this.authenticationValue = authenticationValue;
    }

    @Override
    public byte[] toBytes() {
        ByteBuffer buffer1 = ByteBuffer.allocate(LENGTH_PAYLOAD).order(ByteOrder.BIG_ENDIAN);
        buffer1.put(beaconType).put(flags).put(networkID)
                .putInt(ivIndex).put(authenticationValue);
        return buffer1.array();

    }
}
