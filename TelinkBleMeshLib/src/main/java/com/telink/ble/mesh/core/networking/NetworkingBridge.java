/********************************************************************************************************
 * @file     NetworkingBridge.java 
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
package com.telink.ble.mesh.core.networking;

import com.telink.ble.mesh.core.proxy.ProxyPDU;

/**
 * Created by kee on 2019/8/15.
 */

public interface NetworkingBridge {

    /**
     * @param type proxy pdu typeValue {@link ProxyPDU#type}
     * @param data gatt data
     */
    void onCommandPrepared(byte type, byte[] data);

    /**
     * application layer should save updated network info
     */
    void onNetworkInfoUpdate(int sequenceNumber, int ivIndex);

    /**
     * mesh model message
     */
    void onMeshMessageReceived(int src, int dst, int opcode, byte[] params);

    /**
     * received proxy status message when set filter type, or add/remove address
     * @param address connected node unicast address
     */
    void onProxyInitComplete(boolean success, int address);


    /**
     * heartbeat message received
     *
     * @param data heartbeat data
     */
    void onHeartbeatMessageReceived(int src, int dst, byte[] data);

    /**
     * @param success  if response received
     * @param opcode   command opcode
     * @param rspMax   expect response max
     * @param rspCount received response count
     */
    void onReliableMessageComplete(boolean success, int opcode, int rspMax, int rspCount);

    void onSegmentMessageComplete(boolean success);
}
