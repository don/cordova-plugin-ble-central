/********************************************************************************************************
 * @file     ContextUtil.java 
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

import android.content.Context;
import android.location.LocationManager;
import android.os.Build;

/**
 * Operations with Android context
 * Created by Administrator on 2017/4/11.
 */
public class ContextUtil {
    public static final int SDK_VERSION = Build.VERSION.SDK_INT;

    public static boolean isLocationEnable(final Context context) {
        LocationManager locationManager
                = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
        if (locationManager == null) return false;
        boolean gps = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
        boolean network = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
        return gps || network;
    }


    public static boolean versionAboveL() {
        return SDK_VERSION >= Build.VERSION_CODES.LOLLIPOP;
    }

    public static boolean versionAboveN() {
        return SDK_VERSION >= Build.VERSION_CODES.N;
    }

    public static boolean versionIsN() {
        return SDK_VERSION == Build.VERSION_CODES.N;
    }
}
