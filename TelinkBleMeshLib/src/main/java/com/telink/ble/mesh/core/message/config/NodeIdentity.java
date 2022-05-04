/********************************************************************************************************
 * @file     NodeIdentity.java 
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

public enum NodeIdentity {
    STOPPED(0, "Node Identity for a subnet is stopped"),

    RUNNING(1, "Node Identity for a subnet is running"),

    UNSUPPORTED(2, "Node Identity is not supported"),

    UNKNOWN_ERROR(0xFF, "unknown error");

    public final int code;
    public final String desc;

    NodeIdentity(int code, String desc) {
        this.code = code;
        this.desc = desc;
    }

    public static NodeIdentity valueOf(int code) {
        for (NodeIdentity status : values()) {
            if (status.code == code) return status;
        }
        return UNKNOWN_ERROR;
    }
}
