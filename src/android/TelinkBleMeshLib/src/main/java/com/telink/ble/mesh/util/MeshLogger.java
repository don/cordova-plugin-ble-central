/********************************************************************************************************
 * @file     MeshLogger.java 
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

import android.util.Log;

import java.util.ArrayList;
import java.util.List;

public class MeshLogger {

    public static final int LEVEL_VERBOSE = 0;

    public static final int LEVEL_DEBUG = 1;

    public static final int LEVEL_INFO = 2;

    public static final int LEVEL_WARN = 3;

    public static final int LEVEL_ERROR = 4;


    public static List<LogInfo> logInfoList = new ArrayList<>();


    public static final String DEFAULT_TAG = "SIG-Mesh";

    public static final int DEFAULT_LEVEL = LEVEL_DEBUG;

    // Logger.getGlobal();
//    public static Logger logger = Logger.getLogger(GLOBAL_TAG);

    private static boolean print = true;

    private static boolean record = false;


    public static void enableRecord(boolean enable) {
        record = enable;
    }

    public static void enablePrint(boolean enable) {
        print = enable;
    }

    public static void log(String logMessage) {
        log(logMessage, DEFAULT_TAG);
    }

    public static void log(String logMessage, String tag) {
        log(logMessage, tag, DEFAULT_LEVEL);
    }

    public static void log(String logMessage, int level) {
        log(logMessage, DEFAULT_TAG, level);
    }


    public static void v(String logMessage) {
        log(logMessage, LEVEL_VERBOSE);
    }

    public static void d(String logMessage) {
        log(logMessage, LEVEL_DEBUG);
    }

    public static void i(String logMessage) {
        log(logMessage, LEVEL_INFO);
    }

    public static void w(String logMessage) {
        log(logMessage, LEVEL_WARN);
    }

    public static void e(String logMessage) {
        log(logMessage, LEVEL_ERROR);
    }


    public static void log(String logMessage, String tag, int level) {
        if (print) {
            switch (level) {
                case LEVEL_VERBOSE:
                    Log.v(tag, logMessage);
                    break;
                case LEVEL_INFO:
                    Log.i(tag, logMessage);
                    break;

                case LEVEL_WARN:
                    Log.w(tag, logMessage);
                    break;

                case LEVEL_ERROR:
                    Log.e(tag, logMessage);
                    break;

                case LEVEL_DEBUG:
                default:
                    Log.d(tag, logMessage);
            }
        }

        if (record) {
            logInfoList.add(new LogInfo(tag, logMessage, level));
        }
    }
}
