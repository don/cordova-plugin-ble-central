/********************************************************************************************************
 * @file AppSettings.java
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

public abstract class AppSettings {
    /**
     * is online-status enabled
     */
    public static boolean ONLINE_STATUS_ENABLE = false;

    // draft feature
    public static final boolean DRAFT_FEATURES_ENABLE = false;


    public static final int PID_CT = 0x01;

    public static final int PID_HSL = 0x02;

    public static final int PID_PANEL = 0x07;

    public static final int PID_LPN = 0x0201;

    public static final int PID_REMOTE = 0x0301;

}
