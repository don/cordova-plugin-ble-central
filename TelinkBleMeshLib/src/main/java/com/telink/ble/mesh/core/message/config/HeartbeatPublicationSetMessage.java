/********************************************************************************************************
 * @file     HeartbeatPublicationSetMessage.java 
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
 * Created by kee on 2019/8/23.
 */

public class HeartbeatPublicationSetMessage extends ConfigMessage {

    private int destination;

    private byte countLog;

    private byte periodLog;

    private byte hbTtl;

    // 2 bytes
    private int features;

    // 2 bytes
    private int netKeyIndex;

    public HeartbeatPublicationSetMessage(int destinationAddress) {
        super(destinationAddress);
    }

    @Override
    public int getOpcode() {
        return Opcode.HEARTBEAT_PUB_SET.value;
    }

    @Override
    public byte[] getParams() {
        ByteBuffer byteBuffer = ByteBuffer.allocate(9).order(ByteOrder.LITTLE_ENDIAN);
        byteBuffer.putShort((short) destination)
                .put(countLog)
                .put(periodLog)
                .put(hbTtl)
                .putShort((short) features)
                .putShort((short) netKeyIndex);
        return byteBuffer.array();
    }

    public void setDestination(int destination) {
        this.destination = destination;
    }

    public void setCountLog(byte countLog) {
        this.countLog = countLog;
    }

    public void setPeriodLog(byte periodLog) {
        this.periodLog = periodLog;
    }

    public void setHbTtl(byte hbTtl) {
        this.hbTtl = hbTtl;
    }

    public void setFeatures(int features) {
        this.features = features;
    }

    public void setNetKeyIndex(int netKeyIndex) {
        this.netKeyIndex = netKeyIndex;
    }
}
