/********************************************************************************************************
 * @file     ModelPublicationSetMessage.java 
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
import com.telink.ble.mesh.entity.ModelPublication;

/**
 * Created by kee on 2019/8/12.
 */

public class ModelPublicationSetMessage extends ConfigMessage {

    private ModelPublication modelPublication;

    public ModelPublicationSetMessage(int destinationAddress, ModelPublication modelPublication) {
        super(destinationAddress);
        this.modelPublication = modelPublication;
        this.responseOpcode = Opcode.CFG_MODEL_PUB_STATUS.value;
        this.responseMax = 1;
    }

    public ModelPublicationSetMessage(int destinationAddress) {
        super(destinationAddress);
    }

    @Override
    public int getOpcode() {
        return Opcode.CFG_MODEL_PUB_SET.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.CFG_MODEL_PUB_STATUS.value;
    }

    @Override
    public byte[] getParams() {
        return modelPublication.toBytes();
    }

    public void setModelPublication(ModelPublication modelPublication) {
        this.modelPublication = modelPublication;
    }
}
