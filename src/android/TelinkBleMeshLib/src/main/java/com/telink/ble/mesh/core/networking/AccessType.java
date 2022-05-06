/********************************************************************************************************
 * @file     AccessType.java 
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
package com.telink.ble.mesh.core.networking;


/**
 * Access Command
 * Created by kee on 2019/8/12.
 */
public enum AccessType {
    /**
     * for common model and vendor model
     * use application key for encryption/decryption
     */
    APPLICATION(1),

    /**
     * for config model settings
     * use device key for encryption/decryption
     */
    DEVICE(0);


    public static AccessType getByAkf(byte akf) {
        for (AccessType at :
                values()) {
            if (at.akf == akf) {
                return at;
            }
        }
        return null;
    }

    public final byte akf;

    AccessType(int akf) {
        this.akf = (byte) akf;
    }


}
