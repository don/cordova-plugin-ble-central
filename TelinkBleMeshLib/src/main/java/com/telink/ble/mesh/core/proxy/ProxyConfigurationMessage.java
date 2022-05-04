/********************************************************************************************************
 * @file     ProxyConfigurationMessage.java 
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
package com.telink.ble.mesh.core.proxy;

/**
 * Created by kee on 2019/8/26.
 */

public abstract class ProxyConfigurationMessage {


    /**
     * Set Filter Type
     * Sent by a Proxy Client to set the proxy filter typeValue.
     */
    public static final byte OPCODE_SET_FILTER_TYPE = 0x00;

    /**
     * Add Addresses To Filter
     * Sent by a Proxy Client to add addresses to the proxy filter list.
     */
    public static final byte OPCODE_ADD_ADDRESS = 0x01;

    /**
     * Remove Addresses From Filter
     * Sent by a Proxy Client to remove addresses from the proxy filter list.
     */
    public static final byte OPCODE_REMOVE_ADDRESS = 0x02;

    /**
     * Filter Status
     * Acknowledgment by a Proxy Server to a Proxy Client to report the status of the proxy filter list.
     */
    public static final byte OPCODE_FILTER_STATUS = 0x03;


    public abstract byte getOpcode();

    public abstract byte[] toByteArray();

}
