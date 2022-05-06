/********************************************************************************************************
 * @file StatusNotificationEvent.java
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
package com.telink.ble.mesh.foundation.event;

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.message.NotificationMessage;
import com.telink.ble.mesh.foundation.Event;

/**
 * Mesh Status Message Event
 * event will dispatched when received mesh status
 * For known messages, registering in MeshStatus.Container is suggested
 * If StatusMessage is registered in {@link com.telink.ble.mesh.core.message.MeshStatus.Container}
 * the eventType of the status event will be valued by the className (Class.getName),
 * otherwise, it will be valued by {@link #EVENT_TYPE_NOTIFICATION_MESSAGE_UNKNOWN}
 * <p>
 * Created by kee on 2019/9/12.
 */
public class StatusNotificationEvent extends Event<String> implements Parcelable {
    /**
     * all unrecognized notification
     */
    public static final String EVENT_TYPE_NOTIFICATION_MESSAGE_UNKNOWN = "com.telink.ble.mesh.EVENT_TYPE_NOTIFICATION_MESSAGE_UNKNOWN";

    /**
     * event message
     */
    private NotificationMessage notificationMessage;

    public StatusNotificationEvent(Object sender, String type, NotificationMessage notificationMessage) {
        super(sender, type);
        this.notificationMessage = notificationMessage;
    }

    protected StatusNotificationEvent(Parcel in) {
        notificationMessage = in.readParcelable(NotificationMessage.class.getClassLoader());
    }

    public static final Creator<StatusNotificationEvent> CREATOR = new Creator<StatusNotificationEvent>() {
        @Override
        public StatusNotificationEvent createFromParcel(Parcel in) {
            return new StatusNotificationEvent(in);
        }

        @Override
        public StatusNotificationEvent[] newArray(int size) {
            return new StatusNotificationEvent[size];
        }
    };

    public NotificationMessage getNotificationMessage() {
        return notificationMessage;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeParcelable(notificationMessage, flags);
    }
}
