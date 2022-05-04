/********************************************************************************************************
 * @file     MeshBeaconPDU.java 
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
package com.telink.ble.mesh.core.networking.beacon;

import com.telink.ble.mesh.core.provisioning.pdu.PDU;

/**
 * Created by kee on 2019/11/18.
 */

public abstract class MeshBeaconPDU implements PDU {

    public static final byte BEACON_TYPE_UNPROVISIONED_DEVICE = 0x00;

    public static final byte BEACON_TYPE_SECURE_NETWORK = 0x01;

    protected byte beaconType;

    protected byte[] beaconData;


}
