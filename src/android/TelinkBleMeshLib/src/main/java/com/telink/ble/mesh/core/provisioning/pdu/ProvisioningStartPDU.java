/********************************************************************************************************
 * @file     ProvisioningStartPDU.java 
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

import com.telink.ble.mesh.core.provisioning.AuthenticationMethod;

/**
 * Created by kee on 2019/7/18.
 */

public class ProvisioningStartPDU implements ProvisioningStatePDU {
    private static final int LEN = 5;

    /**
     * The algorithm used for provisioning
     * 0x00: FIPS P-256 Elliptic Curve
     * 0x01–0xFF: Reserved for Future Use
     */
    public byte algorithm;

    /**
     * Public Key used
     * 0x00: No OOB Public Key is used
     * 0x01: OOB Public Key is used
     * 0x02–0xFF: Prohibited
     */
    public byte publicKey;

    /**
     * Authentication Method used
     * 0x00: No OOB authentication is used
     * 0x01: Static OOB authentication is used
     * 0x02: Output OOB authentication is used
     * 0x03: Input OOB authentication is used
     * 0x04–0xFF: Prohibited
     */
    public byte authenticationMethod;

    /**
     * Selected Output OOB Action or Input OOB Action or 0x00
     */
    public byte authenticationAction;

    /**
     * Size of the Output OOB used or size of the Input OOB used or 0x00
     */
    public byte authenticationSize;

    public static ProvisioningStartPDU getSimple(boolean staticOOBSupported) {
        ProvisioningStartPDU startPDU = new ProvisioningStartPDU();
        startPDU.algorithm = 0;
        startPDU.publicKey = 0;
        startPDU.authenticationMethod = staticOOBSupported ? AuthenticationMethod.StaticOOB.value :
                AuthenticationMethod.NoOOB.value;
        startPDU.authenticationAction = 0;
        startPDU.authenticationSize = 0;
        return startPDU;
    }

    public void setPublicKey(boolean publicKeyEnable) {
        this.publicKey = (byte) (publicKeyEnable ? 1 : 0);
    }

    @Override
    public byte[] toBytes() {
        return new byte[]{
                algorithm,
                publicKey,
                authenticationMethod,
                authenticationAction,
                authenticationSize
        };
    }

    @Override
    public byte getState() {
        return ProvisioningPDU.TYPE_START;
    }
}
