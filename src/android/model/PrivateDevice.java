/********************************************************************************************************
 * @file PrivateDevice.java
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date Sep. 30, 2010
 *
 * @par Copyright (c) 2010, Telink Semiconductor (Shanghai) Co., Ltd.
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
package com.megster.cordova.ble.central.model;

import com.telink.ble.mesh.entity.BindingDevice;

/**
 * used in default-bind and fast-provision mode
 * vid , pid and composition raw data
 * {@link BindingDevice#isDefaultBound()}
 * Created by kee on 2019/2/27.
 */
public enum PrivateDevice {

    PANEL(0x0211, 0x07, "panel",
            new byte[]{(byte) 0x11, (byte) 0x02,
                    (byte) 0x07, (byte) 0x00,
                    (byte) 0x32, (byte) 0x37,
                    (byte) 0x69, (byte) 0x00, (byte) 0x07, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x11, (byte) 0x02, (byte) 0x00, (byte) 0x00
                    , (byte) 0x02, (byte) 0x00, (byte) 0x03, (byte) 0x00, (byte) 0x04, (byte) 0x00, (byte) 0x05, (byte) 0x00, (byte) 0x00, (byte) 0xfe, (byte) 0x01, (byte) 0xfe, (byte) 0x02, (byte) 0xfe, (byte) 0x00, (byte) 0xff
                    , (byte) 0x01, (byte) 0xff, (byte) 0x00, (byte) 0x12, (byte) 0x01, (byte) 0x12, (byte) 0x00, (byte) 0x10, (byte) 0x03, (byte) 0x12, (byte) 0x04, (byte) 0x12, (byte) 0x06, (byte) 0x12, (byte) 0x07, (byte) 0x12
                    , (byte) 0x11, (byte) 0x02, (byte) 0x00, (byte) 0x00, (byte) 0x11, (byte) 0x02, (byte) 0x01, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x05, (byte) 0x01, (byte) 0x00, (byte) 0x10, (byte) 0x03, (byte) 0x12
                    , (byte) 0x04, (byte) 0x12, (byte) 0x06, (byte) 0x12, (byte) 0x07, (byte) 0x12, (byte) 0x11, (byte) 0x02, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x05, (byte) 0x01, (byte) 0x00, (byte) 0x10
                    , (byte) 0x03, (byte) 0x12, (byte) 0x04, (byte) 0x12, (byte) 0x06, (byte) 0x12, (byte) 0x07, (byte) 0x12, (byte) 0x11, (byte) 0x02, (byte) 0x00, (byte) 0x00}),

    CT(0x0211, 0x01, "ct",
            new byte[]{
                    (byte) 0x11, (byte) 0x02,
                    (byte) 0x01, (byte) 0x00,
                    (byte) 0x32, (byte) 0x37,
                    (byte) 0x69, (byte) 0x00, (byte) 0x07, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x19, (byte) 0x01, (byte) 0x00, (byte) 0x00
                    , (byte) 0x02, (byte) 0x00, (byte) 0x03, (byte) 0x00, (byte) 0x04, (byte) 0x00, (byte) 0x05, (byte) 0x00, (byte) 0x00, (byte) 0xfe, (byte) 0x01, (byte) 0xfe, (byte) 0x02, (byte) 0xfe, (byte) 0x00, (byte) 0xff
                    , (byte) 0x01, (byte) 0xff, (byte) 0x00, (byte) 0x12, (byte) 0x01, (byte) 0x12, (byte) 0x00, (byte) 0x10, (byte) 0x02, (byte) 0x10, (byte) 0x04, (byte) 0x10, (byte) 0x06, (byte) 0x10, (byte) 0x07, (byte) 0x10
                    , (byte) 0x03, (byte) 0x12, (byte) 0x04, (byte) 0x12, (byte) 0x06, (byte) 0x12, (byte) 0x07, (byte) 0x12, (byte) 0x00, (byte) 0x13, (byte) 0x01, (byte) 0x13, (byte) 0x03, (byte) 0x13, (byte) 0x04, (byte) 0x13
                    , (byte) 0x11, (byte) 0x02, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x02, (byte) 0x00, (byte) 0x02, (byte) 0x10, (byte) 0x06, (byte) 0x13}),
    HSL(0x0211, 0x02, "hsl",
            new byte[]{
                    (byte) 0x11, (byte) 0x02, // cid
                    (byte) 0x02, (byte) 0x00, // pid
                    (byte) 0x33, (byte) 0x31, // vid
                    (byte) 0x69, (byte) 0x00, (byte) 0x07, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x11, (byte) 0x01, (byte) 0x00, (byte) 0x00, (byte) 0x02, (byte) 0x00, (byte) 0x03, (byte) 0x00, (byte) 0x04, (byte) 0x00,
                    (byte) 0x00, (byte) 0xFE, (byte) 0x01, (byte) 0xFE, (byte) 0x00, (byte) 0xFF, (byte) 0x01, (byte) 0xFF, (byte) 0x00, (byte) 0x10, (byte) 0x02, (byte) 0x10, (byte) 0x04, (byte) 0x10, (byte) 0x06, (byte) 0x10,
                    (byte) 0x07, (byte) 0x10, (byte) 0x00, (byte) 0x13, (byte) 0x01, (byte) 0x13, (byte) 0x07, (byte) 0x13, (byte) 0x08, (byte) 0x13, (byte) 0x11, (byte) 0x02, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x00,
                    (byte) 0x02, (byte) 0x00, (byte) 0x02, (byte) 0x10, (byte) 0x0A, (byte) 0x13, (byte) 0x00, (byte) 0x00, (byte) 0x02, (byte) 0x00, (byte) 0x02, (byte) 0x10, (byte) 0x0B, (byte) 0x13
            });


    PrivateDevice(int vid, int pid, String name, byte[] cpsData) {
        this.vid = vid;
        this.pid = pid;
        this.name = name;
        this.cpsData = cpsData;
    }

    private final int vid;
    private final int pid;
    private final String name;
    private final byte[] cpsData;

    public int getVid() {
        return vid;
    }

    public int getPid() {
        return pid;
    }

    public String getName() {
        return name;
    }

    public byte[] getCpsData() {
        return cpsData;
    }

    /**
     * check private device
     *
     * @param deviceUUID deviceUUID from scanRecord
     * @return preset device
     */
    public static PrivateDevice filter(byte[] deviceUUID) {
        if (deviceUUID.length < 3) return null;
        int vid = (deviceUUID[0] & 0xFF) + (((deviceUUID[1] & 0xFF) << 8));
        int pid = deviceUUID[2] & 0xFF;
        PrivateDevice[] values = PrivateDevice.values();
        for (PrivateDevice device :
                values) {
            if (device.vid == vid && device.pid == pid) {
                return device;
            }
        }
        return null;

    }
}
