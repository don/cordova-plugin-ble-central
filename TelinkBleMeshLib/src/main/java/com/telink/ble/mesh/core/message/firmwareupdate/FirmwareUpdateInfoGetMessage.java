/********************************************************************************************************
 * @file     FirmwareUpdateInfoGetMessage.java 
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

import com.telink.ble.mesh.core.message.Opcode;

public class FirmwareUpdateInfoGetMessage extends UpdatingMessage {

    /**
     * Index of the first requested entry from the Firmware Information List state
     * 1 byte
     */
    private byte firstIndex;

    /**
     * Maximum number of entries that the server includes in a Firmware Update Information Status message
     * 1 byte
     */
    private byte entriesLimit;


    public static FirmwareUpdateInfoGetMessage getSimple(int destinationAddress, int appKeyIndex) {
        FirmwareUpdateInfoGetMessage message = new FirmwareUpdateInfoGetMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        message.firstIndex = 0;
        message.entriesLimit = 1;
        return message;
    }

    public FirmwareUpdateInfoGetMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    @Override
    public int getOpcode() {
        return Opcode.FIRMWARE_UPDATE_INFORMATION_GET.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.FIRMWARE_UPDATE_INFORMATION_STATUS.value;
    }

    @Override
    public byte[] getParams() {
        return new byte[]{firstIndex, entriesLimit};
    }

    public void setFirstIndex(byte firstIndex) {
        this.firstIndex = firstIndex;
    }

    public void setEntriesLimit(byte entriesLimit) {
        this.entriesLimit = entriesLimit;
    }
}
