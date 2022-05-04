/********************************************************************************************************
 * @file     UpdateStatus.java 
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
package com.telink.ble.mesh.core.message.firmwareupdate;

public enum UpdateStatus {

    SUCCESS(0x00, "The message was processed successfully"),

    METADATA_CHECK_FAILED(0x01, "The metadata check failed"),

    INVALID_FIRMWARE_ID(0x02, "The message contains a Firmware ID value that is not expected"),

    OUT_OF_RESOURCES(0x03, "Insufficient resources on the node"),

    BLOB_TRANSFER_BUSY(0x04, "Another BLOB transfer is in progress"),

    INVALID_COMMAND(0x05, "The operation cannot be performed while the server is in the current phase"),

    TEMPORARILY_UNAVAILABLE(0x06, "The server cannot start a firmware update"),

    INTERNAL_ERROR(0x07, "An internal error occurred on the node"),

    UNKNOWN_ERROR(0xFF, "unknown error");

    public final int code;
    public final String desc;

    UpdateStatus(int code, String desc) {
        this.code = code;
        this.desc = desc;
    }

    public static UpdateStatus valueOf(int code) {
        for (UpdateStatus status : values()) {
            if (status.code == code) return status;
        }
        return UNKNOWN_ERROR;
    }
}
