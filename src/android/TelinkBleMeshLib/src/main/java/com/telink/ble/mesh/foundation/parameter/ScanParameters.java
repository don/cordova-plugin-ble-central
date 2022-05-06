/********************************************************************************************************
 * @file     ScanParameters.java 
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


import com.telink.ble.mesh.core.ble.LeScanFilter;
import com.telink.ble.mesh.core.ble.UUIDInfo;

import java.util.UUID;

/**
 * Scan params
 * Created by kee on 2017/11/23.
 */

public class ScanParameters extends Parameters {
    private LeScanFilter filter;

    public ScanParameters() {
        filter = new LeScanFilter();
    }

    public static ScanParameters getDefault(boolean provisioned, boolean single) {
        ScanParameters parameters = new ScanParameters();

        if (provisioned) {
            parameters.filter.uuidInclude = new UUID[]{UUIDInfo.SERVICE_PROXY};
        } else {
            parameters.filter.uuidInclude = new UUID[]{UUIDInfo.SERVICE_PROVISION};
        }
        parameters.setScanFilter(parameters.filter);
        parameters.singleMode(single);
        return parameters;
    }

    public void setIncludeMacs(String[] macs) {
        if (filter != null)
            filter.macInclude = macs;
    }

    public void setExcludeMacs(String[] macs) {
        if (filter != null)
            filter.macExclude = macs;
    }

    public void singleMode(boolean single) {
        this.set(SCAN_SINGLE_MODE, single);
    }

}
