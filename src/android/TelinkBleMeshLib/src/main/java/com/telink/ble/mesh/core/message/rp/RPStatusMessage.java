/********************************************************************************************************
 * @file     RPStatusMessage.java 
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
package com.telink.ble.mesh.core.message.rp;

import com.telink.ble.mesh.core.message.StatusMessage;

/**
 * Created by kee on 2019/8/20.
 */

public abstract class RPStatusMessage extends StatusMessage {

    /**
     * defines status codes for Remote Provisioning Server messages that contain a status code.
     */
    
    public static final byte CODE_SUCCESS = 0x00;

    public static final byte CODE_SCANNING_CANNOT_START = 0x01;

    public static final byte CODE_INVALID_STATE = 0x02;

    public static final byte CODE_LIMITED_RESOURCES = 0x03;

    public static final byte CODE_LINK_CANNOT_OPEN = 0x04;

    public static final byte CODE_LINK_OPEN_FAILED = 0x05;

    public static final byte CODE_LINK_CLOSED_BY_DEVICE = 0x06;

    public static final byte CODE_LINK_CLOSED_BY_SERVER = 0x07;

    public static final byte CODE_LINK_CLOSED_BY_CLIENT = 0x08;

    public static final byte CODE_LINK_CLOSED_AS_CANNOT_RECEIVE_PDU = 0x09;

    public static final byte CODE_LINK_CLOSED_AS_CANNOT_SEND_PDU = 0x0A;

    public static final byte CODE_LINK_CLOSED_AS_CANNOT_DELIVER_PDU_REPORT = 0x0B;

    public static final byte CODE_LINK_CLOSED_AS_CANNOT_DELIVER_PDU_OUTBOUND_REPORT = 0x0C;

}
