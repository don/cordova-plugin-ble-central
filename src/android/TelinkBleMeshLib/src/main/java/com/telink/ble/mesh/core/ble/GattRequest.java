/********************************************************************************************************
 * @file     GattRequest.java 
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

package com.telink.ble.mesh.core.ble;


import com.telink.ble.mesh.util.Arrays;

import java.util.UUID;

public class GattRequest {

    public UUID serviceUUID;
    public UUID characteristicUUID;
    public UUID descriptorUUID;
    public RequestType type;
    public byte[] data;
    public Object tag;
    public int delay;
    public Callback callback;

    public GattRequest() {
        this(null, null, RequestType.WRITE);
    }

    public GattRequest(UUID serviceUUID, UUID characteristicUUID, RequestType type) {
        this(serviceUUID, characteristicUUID, type, null);
    }

    public GattRequest(UUID serviceUUID, UUID characteristicUUID, RequestType type,
                       byte[] data) {
        this(serviceUUID, characteristicUUID, type, data, null);
    }

    public GattRequest(UUID serviceUUID, UUID characteristicUUID, RequestType type,
                       byte[] data, Object tag) {

        this.serviceUUID = serviceUUID;
        this.characteristicUUID = characteristicUUID;
        this.type = type;
        this.data = data;
        this.tag = tag;
    }

    public static GattRequest newInstance() {
        return new GattRequest();
    }

    public void clear() {
        this.serviceUUID = null;
        this.characteristicUUID = null;
        this.descriptorUUID = null;
        this.data = null;
    }

    @Override
    public String toString() {
        String d;
        if (data != null) {
            d = Arrays.bytesToHexString(this.data);
        } else {
            d = "null";
        }
        return "{ tag : " + this.tag + ", type : " + this.type
                + " CHARACTERISTIC_UUID :" + characteristicUUID.toString() + " data: " + d + " delay :" + delay + "}";
    }

    public enum RequestType {
        READ, READ_DESCRIPTOR, WRITE, WRITE_NO_RESPONSE, WRITE_DESCRIPTOR, ENABLE_NOTIFY, DISABLE_NOTIFY
    }

    public interface Callback {

        void success(GattRequest request, Object obj);

        void error(GattRequest request, String errorMsg);

        /**
         * @return retry
         */
        boolean timeout(GattRequest request);
    }
}
