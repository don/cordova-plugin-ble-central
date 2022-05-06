/********************************************************************************************************
 * @file     LogInfo.java 
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
package com.telink.ble.mesh.util;


import java.io.Serializable;

/**
 * Created by kee on 2019/1/11.
 */

public class LogInfo implements Serializable {
    public String tag;
    public long millis;
    public int level;
    public String logMessage;
    public long threadId;
    public String threadName;

    public LogInfo(String tag, String logMessage, int level) {
        this.tag = tag;
        this.level = level;
        this.logMessage = logMessage;
        this.millis = System.currentTimeMillis();
        this.threadId = Thread.currentThread().getId();
        this.threadName = Thread.currentThread().getName();
    }


}
