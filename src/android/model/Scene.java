/********************************************************************************************************
 * @file Scene.java
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

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * scene
 * Created by kee on 2018/10/8.
 */

public class Scene implements Serializable {


    /**
     * scene name
     */
    public String name = "Telink-Scene";

    /**
     * scene id
     */
    public int id;

    public List<SceneState> states = new ArrayList<>();

    public static class SceneState implements Serializable {
        /**
         * address
         * device unicast address(0x01 -- 0x7FFF) or group address (C000 - 0xFEFF)
         */
        public int address;

        /**
         * on off value
         * -1 unknown
         */
        public int onOff;

        /**
         * lum(lightness 0-100) value
         * -1 unknown
         */
        public int lum;

        /**
         * temperature value
         * -1 unknown
         */
        public int temp;

        public SceneState() {
        }

        public SceneState(int address) {
            this.address = address;
            this.onOff = -1;
            this.lum = -1;
            this.temp = -1;
        }
    }


    //    public List<Group> innerGroups = new ArrayList<>();
//    public List<DeviceInfo> innerDevices = new ArrayList<>();

    public void saveFromDeviceInfo(NodeInfo deviceInfo) {
        for (SceneState state : states) {
            if (state.address == deviceInfo.meshAddress) {
                state.onOff = deviceInfo.getOnOff();
                state.lum = deviceInfo.lum;
                state.temp = deviceInfo.temp;
                return;
            }
        }
        SceneState state = new SceneState();
        state.address = deviceInfo.meshAddress;
        state.onOff = deviceInfo.getOnOff();
        state.lum = deviceInfo.lum;
        state.temp = deviceInfo.temp;
        states.add(state);
    }

    public void removeByAddress(int address) {
        Iterator<SceneState> iterator = states.iterator();
        while (iterator.hasNext()) {
            if (iterator.next().address == address) {
                iterator.remove();
                return;
            }
        }
    }

    /*public void insertDevice(DeviceInfo deviceInfo) {
        for (DeviceInfo device : innerDevices) {
            if (device.meshAddress == deviceInfo.meshAddress) {
                device.macAddress = deviceInfo.macAddress;
                device.setOnOff(deviceInfo.getOnOff());
                device.lum = deviceInfo.lum;
                device.temp = deviceInfo.temp;
                return;
            }
        }
        DeviceInfo device = new DeviceInfo();
        device.meshAddress = deviceInfo.meshAddress;
        device.macAddress = deviceInfo.macAddress;
        device.setOnOff(deviceInfo.getOnOff());
        device.lum = deviceInfo.lum;
        device.temp = deviceInfo.temp;
        innerDevices.add(device);
    }*/

    /*public void deleteDevice(int address) {
        Iterator<DeviceInfo> iterator = innerDevices.iterator();
        while (iterator.hasNext()) {
            if (iterator.next().meshAddress == address) {
                iterator.remove();
                return;
            }
        }
    }*/

    /*public boolean contains(Group group) {
        for (Group inner : innerGroups) {
            if (inner.address == group.address) {
                return true;
            }
        }
        return false;
    }*/

    public boolean contains(NodeInfo device) {
        for (SceneState inner : states) {
            if (inner.address == device.meshAddress) {
                return true;
            }
        }
        return false;
    }
}
