/********************************************************************************************************
 * @file     DeviceCapability.java 
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

/**
 * Created by kee on 2018/12/11.
 */

public class DeviceCapability {
    private static final int CPB_DATA_LEN = 11;

    private byte[] rawData;

    private DeviceCapability() {
    }

    public static DeviceCapability getCapability(byte[] data) {
        if (data == null || data.length != CPB_DATA_LEN) {
            return null;
        }
        DeviceCapability capability = new DeviceCapability();
        capability.rawData = data;
        return capability;
    }

    public int getElementCnt() {
        return rawData[0];
    }

    public int getAlgorithms() {
        return ((rawData[1] & 0xFF) << 8) | (rawData[2] & 0xFF);
    }

    public int getPublicKeyType() {
        return rawData[3];
    }

    public int getStaticOOBType() {
        return rawData[4];
    }

    public int getOutputOOBSize() {
        return rawData[5];
    }

    public int getOutputOOBAction() {
        return ((rawData[6] & 0xFF) << 8) | (rawData[7] & 0xFF);
    }

    public int getInputOOBSize() {
        return rawData[8];
    }

    public int getInputOOBAction() {
        return ((rawData[9] & 0xFF) << 8) | (rawData[10] & 0xFF);
    }
}
