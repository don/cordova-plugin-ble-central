/********************************************************************************************************
 * @file     LeScanSetting.java 
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
package com.telink.ble.mesh.core.ble;

/**
 * Created by kee on 2019/9/9.
 */

public class LeScanSetting {

    /**
     * time between last scanning start time
     */
    public long spacing;

    /**
     * time of scanning
     */
    public long timeout;

    public static LeScanSetting getDefault() {
        LeScanSetting setting = new LeScanSetting();
        setting.spacing = 5 * 1000;
        setting.timeout = 10 * 1000;
        return setting;
    }

    public LeScanSetting() {
    }

    public LeScanSetting(long spacing, long during) {
        this.spacing = spacing;
        this.timeout = during;
    }
}
