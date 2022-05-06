/********************************************************************************************************
 * @file     ProvisioningParams.java 
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
package com.telink.ble.mesh.core.provisioning;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * @deprecated
 * @see com.telink.ble.mesh.entity.ProvisioningDevice
 */
public class ProvisioningParams {

    /**
     * 16: key
     * 2: key index
     * 1: flags
     * 4: iv index
     * 2: unicast adr
     */
    private static final int DATA_PDU_LEN = 16 + 2 + 1 + 4 + 2;

    private byte[] networkKey;

    private int networkKeyIndex;

    /*
     * 0
     Key Refresh Flag
     0: Key Refresh Phase 0 1: Key Refresh Phase 2
     1
     IV Update Flag
     0: Normal operation 1: IV Update active
     2–7
     Reserved for Future Use
     */

    /**
     * 1 bit
     */
    private byte keyRefreshFlag;

    /**
     * 1 bit
     */
    private byte ivUpdateFlag;

    /**
     * 4 bytes
     */
    private int ivIndex;

    /**
     * unicast address for primary element
     * 2 bytes
     */
    private int unicastAddress;


    public static ProvisioningParams getDefault(byte[] networkKey, int networkKeyIndex, int ivIndex, int unicastAddress) {
        ProvisioningParams params = new ProvisioningParams();
        params.networkKey = networkKey;
        params.networkKeyIndex = networkKeyIndex;
        params.keyRefreshFlag = 0;
        params.ivUpdateFlag = 0;
        params.ivIndex = ivIndex;
        params.unicastAddress = unicastAddress;
        return params;
    }

    public static ProvisioningParams getSimple(byte[] networkKey, int unicastAddress) {
        ProvisioningParams params = new ProvisioningParams();
        params.networkKey = networkKey;
        params.networkKeyIndex = 0;
        params.keyRefreshFlag = 0;
        params.ivUpdateFlag = 0;
        params.ivIndex = 0;
        params.unicastAddress = unicastAddress;
        return params;
    }


    public byte[] toProvisioningData() {
        byte flags = (byte) ((keyRefreshFlag & 0b01) | (ivUpdateFlag & 0b10));
        ByteBuffer buffer = ByteBuffer.allocate(DATA_PDU_LEN).order(ByteOrder.BIG_ENDIAN);
        buffer.put(networkKey)
                .putShort((short) networkKeyIndex)
                .put(flags)
                .putInt(ivIndex)
                .putShort((short) unicastAddress);
        return buffer.array();
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

    public void setUnicastAddress(int unicastAddress) {
        this.unicastAddress = unicastAddress;
    }
}
