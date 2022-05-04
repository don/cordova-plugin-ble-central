/********************************************************************************************************
 * @file     UUIDInfo.java 
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

import java.util.UUID;

/**
 * Created by kee on 2018/7/19.
 */

public class UUIDInfo {

    public static final UUID SERVICE_UUID_OTA = UUID.fromString("00010203-0405-0607-0809-0A0B0C0D1912");
    public static final UUID CHARACTERISTIC_UUID_OTA = UUID.fromString("00010203-0405-0607-0809-0A0B0C0D2B12");

    public static final UUID SERVICE_MESH_FLEX = UUID.fromString("00007FDD-0000-1000-8000-00805F9B34FB");

    public static final UUID SERVICE_PROVISION = UUID.fromString("00001827-0000-1000-8000-00805F9B34FB");
    public static final UUID CHARACTERISTIC_PB_IN = UUID.fromString("00002ADB-0000-1000-8000-00805F9B34FB");
    public static final UUID CHARACTERISTIC_PB_OUT = UUID.fromString("00002ADC-0000-1000-8000-00805F9B34FB");

    public static final UUID SERVICE_PROXY = UUID.fromString("00001828-0000-1000-8000-00805F9B34FB");
    public static final UUID CHARACTERISTIC_PROXY_IN = UUID.fromString("00002ADD-0000-1000-8000-00805F9B34FB");
    public static final UUID CHARACTERISTIC_PROXY_OUT = UUID.fromString("00002ADE-0000-1000-8000-00805F9B34FB");

    public static final UUID SERVICE_ONLINE_STATUS = UUID.fromString("00010203-0405-0607-0809-0A0B0C0D1A10");
    public static final UUID CHARACTERISTIC_ONLINE_STATUS = UUID.fromString("00010203-0405-0607-0809-0A0B0C0D1A11");

    public static final UUID DESCRIPTOR_CFG_UUID = UUID.fromString("00002902-0000-1000-8000-00805F9B34FB");

    public static final UUID SERVICE_DEVICE_INFO = UUID.fromString("0000180A-0000-1000-8000-00805F9B34FB");

    public static final UUID CHARACTERISTIC_FW_VERSION = UUID.fromString("00002A26-0000-1000-8000-00805F9B34FB");


}
