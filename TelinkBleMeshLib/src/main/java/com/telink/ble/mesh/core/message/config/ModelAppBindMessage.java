/********************************************************************************************************
 * @file     ModelAppBindMessage.java 
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

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * Created by kee on 2019/8/12.
 */

public class ModelAppBindMessage extends ConfigMessage {

    /**
     * Address of the element
     * 2 bytes
     */
    private int elementAddress;

    /**
     * Index of the AppKey
     * 2 bytes, really 12 bit used
     */
    private int appKeyIndex;

    /**
     * SIG Model ID or Vendor Model ID
     * if SIG: 2 bytes
     * else : 4 bytes
     */
    private int modelIdentifier;

    private boolean isSigModel = true;

    public ModelAppBindMessage(int destinationAddress) {
        super(destinationAddress);
    }

    public void setElementAddress(int elementAddress) {
        this.elementAddress = elementAddress;
    }

    public void setAppKeyIndex(int appKeyIndex) {
        this.appKeyIndex = appKeyIndex;
    }

    public void setModelIdentifier(int modelIdentifier) {
        this.modelIdentifier = modelIdentifier;
    }

    public void setSigModel(boolean sigModel) {
        isSigModel = sigModel;
    }

    @Override
    public int getOpcode() {
        return Opcode.MODE_APP_BIND.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.MODE_APP_STATUS.value;
    }

    @Override
    public byte[] getParams() {
        // check if sig model or vendor model
//        boolean isSigModel = isSigModel(this.modelIdentifier);
        int bufferSize = isSigModel ? 6 : 8;
        ByteBuffer paramsBuffer = ByteBuffer.allocate(bufferSize).order(ByteOrder.LITTLE_ENDIAN)
                .putShort((short) this.elementAddress)
                .putShort((short) this.appKeyIndex);
        if (isSigModel) {
            paramsBuffer.putShort((short) this.modelIdentifier);
        } else {
            paramsBuffer.putInt(this.modelIdentifier);
        }
        return paramsBuffer.array();
    }

    /**
     * @deprecated
     */
    private boolean isSigModel(int modelIdentifier) {
        return modelIdentifier <= 0xFFFF;
    }

}
