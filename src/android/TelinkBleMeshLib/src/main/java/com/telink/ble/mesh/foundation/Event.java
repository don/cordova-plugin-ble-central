/********************************************************************************************************
 * @file     Event.java 
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

package com.telink.ble.mesh.foundation;

import android.os.Parcel;
import android.os.Parcelable;

public abstract class Event<T> implements Parcelable {

    protected Object sender;
    protected T type;
    protected ThreadMode threadMode = ThreadMode.Default;


    public Event() {
    }

    public Event(Object sender, T type) {
        this(sender, type, ThreadMode.Default);
    }

    public Event(Object sender, T type, ThreadMode threadMode) {
        this.sender = sender;
        this.type = type;
        this.threadMode = threadMode;
    }

    public Object getSender() {
        return sender;
    }

    public T getType() {
        return type;
    }

    public ThreadMode getThreadMode() {
        return this.threadMode;
    }

    public Event<T> setThreadMode(ThreadMode mode) {
        this.threadMode = mode;
        return this;
    }

    public enum ThreadMode {
        Background, Main, Default,
        ;
    }
}