/********************************************************************************************************
 * @file     LeScanFilter.java 
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


import java.util.UUID;

/**
 * Created by kee on 2018/7/19.
 */

public class LeScanFilter {

    // null means not in filter

    public UUID[] uuidInclude = null;

    public String[] macInclude = null;

    public String[] macExclude = null;

//    public int[] companyIdInclude = null;

    public String[] nameInclude = null;
}
