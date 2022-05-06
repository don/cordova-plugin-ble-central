/********************************************************************************************************
 * @file AppKeyAddMessage.java
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
package com.telink.ble.mesh.core.message.config;

import com.telink.ble.mesh.core.message.Opcode;

/**
 * Created by kee on 2021/1/14.
 */

public class SubnetBridgeGetMessage extends ConfigMessage {


    public SubnetBridgeGetMessage(int destinationAddress) {
        super(destinationAddress);
    }

    public SubnetBridgeGetMessage(int destinationAddress, byte bridgeState) {
        super(destinationAddress);
    }

    @Override
    public int getOpcode() {
        return Opcode.SUBNET_BRIDGE_GET.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.SUBNET_BRIDGE_STATUS.value;
    }

    @Override
    public byte[] getParams() {
        return null;
    }


}
