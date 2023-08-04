/********************************************************************************************************
 * @file PublishModel.java
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date Sep. 30, 2017
 *
 * @par Copyright (c) 2017, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
 *
 *          Licensed under the Apache License, Version 2.0 (the "License");
 *          you may not use this file except in compliance with the License.
 *          You may obtain a copy of the License at
 *
 *              http://www.apache.org/licenses/LICENSE-2.0
 *
 *          Unless required by applicable law or agreed to in writing, software
 *          distributed under the License is distributed on an "AS IS" BASIS,
 *          WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *          See the License for the specific language governing permissions and
 *          limitations under the License.
 *******************************************************************************************************/
package com.megster.cordova.ble.central.model;


import java.io.Serializable;

/**
 * for model status publication
 * Created by kee on 2018/12/18.
 */
public class PublishModel implements Serializable {

    public static final int CREDENTIAL_FLAG_DEFAULT = 0b0;

    public static final int RFU_DEFAULT = 0x0C;

    // 0 for time model
    // 30 s
    // use default ttl in device
    public static final int TTL_DEFAULT = 0xFF;

    // 0 for time model
    /**
     * default retransmit: 0x15
     * 0b 00010 101
     * count: 0x05, step: 0x02
     */
    public static final int RETRANSMIT_COUNT_DEFAULT = 0x05;


    public static final int RETRANSMIT_INTERVAL_STEP_DEFAULT = 0x02;


    public int elementAddress;

    public int modelId;

    public int address;

//    public byte[] params;

    public int period;

    public int ttl;

    public int credential;

    public int transmit;


    public PublishModel(int elementAddress, int modelId, int address, int period) {
        this(elementAddress, modelId, address, period, TTL_DEFAULT, CREDENTIAL_FLAG_DEFAULT,
                (byte) ((RETRANSMIT_COUNT_DEFAULT & 0b111) | (RETRANSMIT_INTERVAL_STEP_DEFAULT << 3)));
    }


    public PublishModel(int elementAddress, int modelId, int address, int period, int ttl, int credential, int transmit) {
        this.elementAddress = elementAddress;
        this.modelId = modelId;
        this.address = address;
        this.period = period;
        this.ttl = ttl;
        this.credential = credential;
        this.transmit = transmit;
    }

    // higher 5 bit
    public int getTransmitInterval() {
        return (transmit & 0xFF) >> 3;
    }

    // lower 3 bit
    public int getTransmitCount() {
        return (transmit & 0xFF) & 0b111;
    }


}
