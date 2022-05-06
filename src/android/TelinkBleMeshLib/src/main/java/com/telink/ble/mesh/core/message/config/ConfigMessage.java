/********************************************************************************************************
 * @file     ConfigMessage.java 
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
package com.telink.ble.mesh.core.message.config;

import com.telink.ble.mesh.core.message.MeshMessage;
import com.telink.ble.mesh.core.networking.AccessType;

import androidx.annotation.IntRange;

/**
 * configuration message
 * Created by kee on 2019/8/14.
 */
public abstract class ConfigMessage extends MeshMessage {

    public ConfigMessage(@IntRange(from = 1, to = 0x7FFF) int destinationAddress) {
        this.destinationAddress = destinationAddress;
        // default rsp max
        this.responseMax = 1;
    }

    /**
     * for config message , AKF is 0
     *
     * @return application key flag
     */
    @Override
    public AccessType getAccessType() {
        return AccessType.DEVICE;
    }

}
