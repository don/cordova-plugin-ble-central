/********************************************************************************************************
 * @file     OpcodeType.java 
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
package com.telink.ble.mesh.core.message;

import com.telink.ble.mesh.core.MeshUtils;

public enum OpcodeType {
    SIG_1(1),
    SIG_2(2),
    VENDOR(3);

    public final int length;

    OpcodeType(int length) {
        this.length = length;
    }

    /**
     * @param opFst first byte of opcode
     */
    public static OpcodeType getByFirstByte(byte opFst) {
        return (opFst & MeshUtils.bit(7)) != 0
                ?
                ((opFst & MeshUtils.bit(6)) != 0 ? VENDOR : SIG_2)
                :
                SIG_1;
    }
}
