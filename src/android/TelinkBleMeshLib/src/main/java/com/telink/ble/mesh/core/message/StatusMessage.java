/********************************************************************************************************
 * @file StatusMessage.java
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
package com.telink.ble.mesh.core.message;

import android.os.Parcelable;

import com.telink.ble.mesh.core.networking.AccessLayerPDU;

/**
 * status notification by acknowledged message
 * Created by kee on 2019/8/20.
 */
public abstract class StatusMessage implements Parcelable {

    public StatusMessage() {

    }


//    public abstract int getDataLength();

    /**
     * parse status message with access layer pdu params
     * {@link AccessLayerPDU#params}
     */
    public abstract void parse(byte[] params);


    /**
     * create new StatusMessage by opcode
     *
     * @return result can be null when target opcode is not registered in MeshStatus
     * {@link MeshStatus.Container}
     */
    public static StatusMessage createByAccessMessage(int opcode, byte[] params) {

        Class messageClass = MeshStatus.Container.getMessageClass(opcode);
        if (messageClass != null) {
            Object msgClass = null;
            try {
                msgClass = messageClass.newInstance();
            } catch (InstantiationException | IllegalAccessException e) {
                e.printStackTrace();
            }
            if (msgClass instanceof StatusMessage) {
                StatusMessage statusMessage = (StatusMessage) msgClass;
                statusMessage.parse(params);
                return statusMessage;
            }
        }

        return null;
    }


}


/**
 * ALL status message opcode
 */
    /*

        Opcode messageOpcode = Opcode.valueOf(opcode);
        StatusMessage statusMessage = null;
        if (messageOpcode == null) return null;
        switch (messageOpcode) {
            case COMPOSITION_DATA_STATUS:
            case HEALTH_CURRENT_STATUS:
            case HEALTH_FAULT_STATUS:
            case HEARTBEAT_PUB_STATUS:
            case APPKEY_STATUS:
            case HEALTH_ATTENTION_STATUS:
            case CFG_BEACON_STATUS:
            case CFG_DEFAULT_TTL_STATUS:
            case CFG_FRIEND_STATUS:
            case CFG_GATT_PROXY_STATUS:
            case CFG_KEY_REFRESH_PHASE_STATUS:
            case CFG_MODEL_PUB_STATUS:
            case CFG_MODEL_SUB_STATUS:
            case CFG_NW_TRANSMIT_STATUS:
            case CFG_RELAY_STATUS:
            case CFG_LPN_POLL_TIMEOUT_STATUS:
            case HEALTH_PERIOD_STATUS:
            case HEARTBEAT_SUB_STATUS:
            case MODE_APP_STATUS:
            case NETKEY_STATUS:
            case NODE_ID_STATUS:
            case NODE_RESET_STATUS:

            case G_ONOFF_STATUS:
                statusMessage = new OnOffStatusMessage();
                break;
            case G_LEVEL_STATUS:
            case G_DEF_TRANS_TIME_STATUS:
            case G_ON_POWER_UP_STATUS:
            case G_POWER_LEVEL_STATUS:
            case G_POWER_LEVEL_LAST_STATUS:
            case G_POWER_DEF_STATUS:
            case G_POWER_LEVEL_RANGE_STATUS:
            case G_BATTERY_STATUS:
            case G_LOCATION_GLOBAL_STATUS:
            case G_LOCATION_LOCAL_STATUS:
            case LIGHTNESS_STATUS:
            case LIGHTNESS_LINEAR_STATUS:
            case LIGHTNESS_LAST_STATUS:
            case LIGHTNESS_DEFULT_STATUS:
            case LIGHTNESS_RANGE_STATUS:
            case LIGHT_CTL_STATUS:
            case LIGHT_CTL_TEMP_RANGE_STATUS:
            case LIGHT_CTL_TEMP_STATUS:
            case LIGHT_CTL_DEFULT_STATUS:
            case LIGHT_HSL_HUE_STATUS:
            case LIGHT_HSL_SAT_STATUS:
            case LIGHT_HSL_STATUS:
            case LIGHT_HSL_TARGET_STATUS:
            case LIGHT_HSL_DEF_STATUS:
            case LIGHT_HSL_RANGE_STATUS:
            case TIME_STATUS:
            case TIME_ROLE_STATUS:
            case TIME_ZONE_STATUS:
            case TAI_UTC_DELTA_STATUS:
            case SCHD_ACTION_STATUS:
            case SCHD_STATUS:
            case SCENE_STATUS:
            case SCENE_REG_STATUS:


                break;
        }

     */