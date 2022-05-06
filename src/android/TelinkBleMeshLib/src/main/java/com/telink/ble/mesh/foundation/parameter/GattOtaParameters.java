/********************************************************************************************************
 * @file     GattOtaParameters.java 
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
package com.telink.ble.mesh.foundation.parameter;

import com.telink.ble.mesh.entity.ConnectionFilter;

/**
 * Created by kee on 2017/11/23.
 */

public class GattOtaParameters extends Parameters {


    public GattOtaParameters(ConnectionFilter filter, byte[] firmware) {
        this.set(COMMON_PROXY_FILTER_INIT_NEEDED, true);
        this.set(ACTION_CONNECTION_FILTER, filter);
        this.setFirmware(firmware);
    }

    public void setFirmware(byte[] firmware) {
        this.set(ACTION_OTA_FIRMWARE, firmware);
    }

}
