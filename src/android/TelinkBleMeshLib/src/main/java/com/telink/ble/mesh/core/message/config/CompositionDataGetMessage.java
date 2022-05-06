/********************************************************************************************************
 * @file     CompositionDataGetMessage.java 
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

import com.telink.ble.mesh.core.message.Opcode;

/**
 * Created by kee on 2019/8/12.
 */

public class CompositionDataGetMessage extends ConfigMessage {


    public CompositionDataGetMessage(int destinationAddress) {
        super(destinationAddress);
    }

    @Override
    public int getOpcode() {
        return Opcode.COMPOSITION_DATA_GET.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.COMPOSITION_DATA_STATUS.value;
    }

    @Override
    public byte[] getParams() {
        return new byte[]{(byte) 0xFF};
    }


}
