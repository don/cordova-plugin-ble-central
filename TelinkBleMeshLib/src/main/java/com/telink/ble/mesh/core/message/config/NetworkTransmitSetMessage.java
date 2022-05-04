/********************************************************************************************************
 * @file     NetworkTransmitSetMessage.java 
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
 * set network transmit params
 * Network transmit params are used when node sending network pdu from self -- source address is self --
 * Meanwhile relay params are used when relay network pdu, generally smaller than network transmit
 * Created by kee on 2020/03/20.
 */

public class NetworkTransmitSetMessage extends ConfigMessage {


    // networkTransmitCount, default is 5
    private int count;


    // networkTransmitIntervalSteps, default is 2
    // transmission interval = (Network Transmit Interval Steps + 1) * 10
    private int intervalSteps;

    public NetworkTransmitSetMessage(int destinationAddress) {
        super(destinationAddress);
    }

    public void setCount(int count) {
        this.count = count;
    }

    public void setIntervalSteps(int intervalSteps) {
        this.intervalSteps = intervalSteps;
    }

    @Override
    public int getOpcode() {
        return Opcode.CFG_NW_TRANSMIT_SET.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.CFG_NW_TRANSMIT_STATUS.value;
    }

    @Override
    public byte[] getParams() {
        return new byte[]{
                (byte) ((count & 0b111) | (intervalSteps << 3))
        };
    }


}
