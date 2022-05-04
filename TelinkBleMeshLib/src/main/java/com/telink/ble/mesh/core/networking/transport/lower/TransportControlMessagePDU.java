/********************************************************************************************************
 * @file     TransportControlMessagePDU.java 
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
package com.telink.ble.mesh.core.networking.transport.lower;

/**
 * Created by kee on 2019/8/22.
 */

public abstract class TransportControlMessagePDU extends LowerTransportPDU {
    public static final int CONTROL_MESSAGE_OPCODE_SEG_ACK = 0x00;


    /*
    other values defined in
    spec#3.6.5.11 Summary of opcodes
     */

    public static final int CONTROL_MESSAGE_OPCODE_HEARTBEAT = 0x0A;

}
