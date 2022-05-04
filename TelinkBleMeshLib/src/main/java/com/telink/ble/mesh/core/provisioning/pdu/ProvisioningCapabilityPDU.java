/********************************************************************************************************
 * @file     ProvisioningCapabilityPDU.java 
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
package com.telink.ble.mesh.core.provisioning.pdu;

/**
 * Created by kee on 2019/7/18.
 */
// 03:01:
// 02:00:01:00:00:00:00:00:00:00:00
// from device
public class ProvisioningCapabilityPDU implements ProvisioningStatePDU {

    private static final int LEN = 11;

    public byte[] rawData;


    /**
     * Number of elements supported by the device
     * 1 byte
     * 0: Prohibited
     * 0x01-0xFF
     */
    public byte eleNum;

    /**
     * Supported algorithms and other capabilities
     * 2 bytes
     * bit-0: FIPS P-256 Elliptic Curve
     * bit-1--15: Reserved for Future Use
     */
    public short algorithms;

    /**
     * Supported public key types
     * 1 byte
     * bit-0: Public Key OOB information available
     * bit-1--7: Prohibited
     */
    public byte publicKeyType;

    /**
     * Supported static OOB Types
     * 1 byte
     * bit 0: Static OOB information available
     * bit 1–7: Prohibited
     */
    public byte staticOOBType;

    /**
     * Maximum size of Output OOB supported
     * 1 byte
     * 0x00: The device does not support output OOB
     * 0x01–0x08: Maximum size in octets supported by the device
     * 0x09–0xFF: Reserved for Future Use
     */
    public byte outputOOBSize;

    /**
     * Supported Output OOB Actions
     * 2 bytes
     * bit-0: Blink
     * bit-1: Beep
     * bit-2: Vibrate
     * bit-3: Output Numeric
     * bit-4: Output Alphanumeric, Array of octets
     * other bits are RFU
     */
    public short outputOOBAction;

    /**
     * Maximum size in octets of Input OOB supported
     * 1 byte
     * 0x00: The device does not support Input OOB
     * 0x01–0x08: Maximum supported size in octets supported by the device
     * 0x09–0xFF: Reserved for Future Use
     */
    public byte inputOOBSize;

    /**
     * Supported Input OOB Actions
     * 2 bytes
     * bit-0: Push
     * bit-1: Twist
     * bit-2:Input Number
     * bit-3: Input Alphanumeric, Array of octets
     * bit-4--15 Reserved for Future Use
     */
    public short inputOOBAction;

    public static ProvisioningCapabilityPDU fromBytes(byte[] data) {
        if (data == null || data.length < LEN) {
            return null;
        }

        ProvisioningCapabilityPDU capability = new ProvisioningCapabilityPDU();
        capability.rawData = data;
        int index = 0;
        capability.eleNum = data[index++];
        capability.algorithms = (short) (((data[index++] & 0xFF) << 8) | (data[index++] & 0xFF));
        capability.publicKeyType = data[index++];
        capability.staticOOBType = data[index++];
        capability.outputOOBSize = data[index++];
        capability.outputOOBAction = (short) (((data[index++] & 0xFF) << 8) | (data[index++] & 0xFF));
        capability.inputOOBSize = data[index++];
        capability.inputOOBAction = (short) (((data[index++] & 0xFF) << 8) | (data[index] & 0xFF));
        return capability;
    }

    @Override
    public String toString() {
        return "ProvisioningCapabilityPDU{" +
                "eleNum=" + eleNum +
                ", algorithms=" + algorithms +
                ", publicKeyType=" + publicKeyType +
                ", staticOOBType=" + staticOOBType +
                ", outputOOBSize=" + outputOOBSize +
                ", outputOOBAction=" + outputOOBAction +
                ", inputOOBSize=" + inputOOBSize +
                ", inputOOBAction=" + inputOOBAction +
                '}';
    }

    @Override
    public byte[] toBytes() {
        return rawData;
    }

    @Override
    public byte getState() {
        return ProvisioningPDU.TYPE_CAPABILITIES;
    }

    public boolean staticOOBSupported() {
        return staticOOBType != 0;
    }
}
