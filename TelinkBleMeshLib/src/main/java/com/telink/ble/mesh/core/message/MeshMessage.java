/********************************************************************************************************
 * @file     MeshMessage.java 
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

import com.telink.ble.mesh.core.networking.AccessLayerPDU;
import com.telink.ble.mesh.core.networking.AccessType;

/**
 * Created by kee on 2019/8/14.
 */
public class MeshMessage {

    /**
     * access message
     */
    public static final int CTL_ACCESS = 0;

    /**
     * control message
     * never used by api
     */
    public static final int CTL_CONTROL = 1;

    /**
     * default retry count
     */
    public static final int DEFAULT_RETRY_CNT = 2;

    /**
     * default szmic
     */
    public static final int DEFAULT_ASZMIC = 0;

    /**
     * invalid opcode
     */
    public static final int OPCODE_INVALID = -1;

    public static final int DEFAULT_TTL = 10;

    /**
     * message opcode
     * {@link AccessLayerPDU#opcode}
     */
    protected int opcode;

    /**
     * message params
     * {@link AccessLayerPDU#params}
     */
    protected byte[] params;

    /**
     * device key or appliction key determined by accessType {@link #accessType}
     */
    protected byte[] accessKey;

    /**
     * access typeValue
     *
     * @see AccessType#DEVICE for config message
     * @see AccessType#APPLICATION for common message
     */
    protected AccessType accessType = AccessType.APPLICATION;

    /**
     * only used when accessType==APPLICATION
     */
    protected int appKeyIndex;

    /**
     * 0: 4 bytes trans mic
     * 1: 8 bytes trans mic
     */
    protected int szmic = DEFAULT_ASZMIC;

    protected int sourceAddress;

    protected int destinationAddress;

    protected int ctl = CTL_ACCESS;

    protected int ttl = DEFAULT_TTL;

    protected int retryCnt = DEFAULT_RETRY_CNT;

    protected int responseMax = 0;

    /**
     * if message contains tid
     *
     * @see com.telink.ble.mesh.core.networking.NetworkingController#tid
     */
//    protected boolean containsTid = false;



//    boolean reliable = false;

    /**
     * message response opcode
     * defines message is reliable {@link #isReliable()}
     */
    protected int responseOpcode = OPCODE_INVALID;

    /**
     * tid position in params
     * if message dose not contains tid, tid position should be invalid value (such as -1)
     */
    protected int tidPosition = -1;

    protected boolean isSegmented = false;

    /**
     * if true, message will be cached and checked completion by message response or retryCnt == 0
     * if false, message will not be cached and checked
     */
    public boolean isReliable() {
        return getResponseOpcode() != OPCODE_INVALID;
    }

    public int getResponseOpcode() {
        return responseOpcode;
    }

    public void setResponseOpcode(int responseOpcode) {
        this.responseOpcode = responseOpcode;
    }

    public int getTidPosition() {
        return tidPosition;
    }

    public void setTidPosition(int tidPosition) {
        this.tidPosition = tidPosition;
    }

    public int getOpcode() {
        return opcode;
    }

    public void setOpcode(int opcode) {
        this.opcode = opcode;
    }

    public byte[] getParams() {
        return params;
    }

    public void setParams(byte[] params) {
        this.params = params;
    }

    public int getRetryCnt() {
        return retryCnt;
    }

    public void setRetryCnt(int retryCnt) {
        this.retryCnt = retryCnt;
    }

    public int getResponseMax() {
        return responseMax;
    }

    public void setResponseMax(int responseMax) {
        this.responseMax = responseMax;
    }

    public AccessType getAccessType() {
        return accessType;
    }

    public void setAccessType(AccessType accessType) {
        this.accessType = accessType;
    }

    public int getCtl() {
        return this.ctl;
    }

    /**
     * @deprecated
     */
    public void setCtl(int ctl) {
        this.ctl = ctl;
    }

    public int getTtl() {
        return ttl;
    }

    public void setTtl(int ttl) {
        this.ttl = ttl;
    }

    /**
     * mic size
     */
    public int getSzmic() {
        return szmic;
    }

    public void setSzmic(int szmic) {
        this.szmic = szmic;
    }

    public byte[] getAccessKey() {
        return accessKey;
    }

    public void setAccessKey(byte[] accessKey) {
        this.accessKey = accessKey;
    }

    public int getSourceAddress() {
        return sourceAddress;
    }

    public void setSourceAddress(int sourceAddress) {
        this.sourceAddress = sourceAddress;
    }

    public int getDestinationAddress() {
        return destinationAddress;
    }

    public void setDestinationAddress(int destinationAddress) {
        this.destinationAddress = destinationAddress;
    }

    public int getAppKeyIndex() {
        return appKeyIndex;
    }

    public void setAppKeyIndex(int appKeyIndex) {
        this.appKeyIndex = appKeyIndex;
    }

    public boolean isSegmented() {
        return isSegmented;
    }

    public void setSegmented(boolean segmented) {
        isSegmented = segmented;
    }
}
