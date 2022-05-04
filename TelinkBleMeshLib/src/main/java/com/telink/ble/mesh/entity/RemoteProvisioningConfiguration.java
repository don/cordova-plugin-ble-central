/********************************************************************************************************
 * @file     RemoteProvisioningConfiguration.java 
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
package com.telink.ble.mesh.entity;

/**
 * remote provisioning configurations
 * Created by kee on 2019/11/27.
 */

public class RemoteProvisioningConfiguration {
    // scan for 2 devices
    private static final int DEFAULT_SCAN_LIMIT = 2;

    // scan 3 seconds
    private static final int DEFAULT_SCAN_TIMEOUT = 3;

    // if app key binding needed
    private boolean bindNeed = true;

    // default bind
    private boolean defaultBind = false;

    private int scanLimit;

    private int scanTimeout;

    private int provisioningIndex;


    public RemoteProvisioningConfiguration(int provisioningIndex) {
        this.provisioningIndex = provisioningIndex;
    }

    public boolean isBindNeed() {
        return bindNeed;
    }

    public void setBindNeed(boolean bindNeed) {
        this.bindNeed = bindNeed;
    }

    public boolean isDefaultBind() {
        return defaultBind;
    }

    public void setDefaultBind(boolean defaultBind) {
        this.defaultBind = defaultBind;
    }

    public int getScanLimit() {
        return scanLimit;
    }

    public void setScanLimit(int scanLimit) {
        this.scanLimit = scanLimit;
    }

    public int getScanTimeout() {
        return scanTimeout;
    }

    public void setScanTimeout(int scanTimeout) {
        this.scanTimeout = scanTimeout;
    }

    public int getProvisioningIndex() {
        return provisioningIndex;
    }

    public void setProvisioningIndex(int provisioningIndex) {
        this.provisioningIndex = provisioningIndex;
    }
}
