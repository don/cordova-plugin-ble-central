/********************************************************************************************************
 * @file     AccessBridge.java 
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
package com.telink.ble.mesh.core.access;

import com.telink.ble.mesh.core.message.MeshMessage;

/**
 * Created by kee on 2019/9/11.
 */

public interface AccessBridge {

    /**
     * BINDING flow
     */
    int MODE_BINDING = 1;

    /**
     * firmware updating (mesh ota)
     */
    int MODE_FIRMWARE_UPDATING = 2;

    // remote provision
    int MODE_REMOTE_PROVISIONING = 3;

    int MODE_FAST_PROVISION = 4;

    /**
     * prepared to send mesh message
     *
     * @return if message sent
     */
    boolean onAccessMessagePrepared(MeshMessage meshMessage, int mode);

    /**
     * @param state binding state
     * @param desc  desc
     */
    void onAccessStateChanged(int state, String desc, int mode, Object obj);
}
