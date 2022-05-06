/********************************************************************************************************
 * @file     AutoConnectFilterType.java 
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

/**
 * Created by kee on 2019/9/18.
 */

public enum AutoConnectFilterType {
    /**
     * node identity only
     */
    NODE_IDENTITY(true, false),
    /**
     * network id only
     */
    NETWORK_ID(false, true),
    /**
     * both supported
     */
    AUTO(true, true);

    public final boolean isNodeIdentitySupport;

    public final boolean isNetworkIdSupport;

    AutoConnectFilterType(boolean isNodeIdentitySupport, boolean isNetworkIdSupport) {
        this.isNodeIdentitySupport = isNodeIdentitySupport;
        this.isNetworkIdSupport = isNetworkIdSupport;
    }
}
