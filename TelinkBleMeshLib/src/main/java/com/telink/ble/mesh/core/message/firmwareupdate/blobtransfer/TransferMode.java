/********************************************************************************************************
 * @file     TransferMode.java 
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
package com.telink.ble.mesh.core.message.firmwareupdate.blobtransfer;

/**
 * The Transfer Mode state is a 2-bit value that indicates the mode of the BLOB transfer
 */
public enum TransferMode {

    NONE(0x00, "No Active Transfer"),

    PUSH(0x01, "Push BLOB Transfer Mode"),

    PULL(0x02, "Pull BLOB Transfer Mode"),

    Prohibited(0x03, "Prohibited");

    public final int mode;
    public final String desc;

    TransferMode(int mode, String desc) {
        this.mode = mode;
        this.desc = desc;
    }

    public static TransferMode valueOf(int mode) {
        for (TransferMode status : values()) {
            if (status.mode == mode) return status;
        }
        return Prohibited;
    }
}
