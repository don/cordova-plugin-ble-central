/********************************************************************************************************
 * @file     BindingDevice.java 
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
package com.telink.ble.mesh.entity;

import android.os.Parcel;
import android.os.Parcelable;

import com.telink.ble.mesh.core.access.BindingBearer;

/**
 * Created by kee on 2019/9/6.
 */

public class BindingDevice implements Parcelable {

    /**
     * network key index,
     * if the index value is -1, it would be replaced by {@link com.telink.ble.mesh.foundation.MeshConfiguration#netKeyIndex}
     */
    private int netKeyIndex = -1;

    /**
     * device unicast address
     */
    private int meshAddress;

    private byte[] deviceUUID;

    /**
     * model and appKey map, null means bind all models
     */
//    private SparseIntArray modelAppKeyMap;

    /**
     * app key index, should be contained in NetworkingController#appKeyMap
     */
    private int appKeyIndex;

    /**
     * models bound at this key
     */
    private int[] models;

    /**
     * binding bearer
     * {@link BindingBearer#GattOnly} and {@link BindingBearer#Any}
     */
    private BindingBearer bearer = BindingBearer.GattOnly;

    /**
     * default bound is private action defined by telink, for faster binding
     * if valued by true, when node received app key, it will bind all models automatically;
     */
    private boolean defaultBound = false;

    private CompositionData compositionData;

    public BindingDevice() {
    }

    public BindingDevice(int meshAddress, byte[] deviceUUID, int appKeyIndex) {
        this.meshAddress = meshAddress;
        this.deviceUUID = deviceUUID;
        this.appKeyIndex = appKeyIndex;
        this.models = null;
        this.bearer = BindingBearer.GattOnly;
    }

    public BindingDevice(int meshAddress, byte[] deviceUUID, int appKeyIndex, int[] models, BindingBearer bearer) {
        this.meshAddress = meshAddress;
        this.deviceUUID = deviceUUID;
        this.appKeyIndex = appKeyIndex;
        this.models = models;
        this.bearer = bearer;
    }

    protected BindingDevice(Parcel in) {
        netKeyIndex = in.readInt();
        meshAddress = in.readInt();
        deviceUUID = in.createByteArray();
        appKeyIndex = in.readInt();
        models = in.createIntArray();
        defaultBound = in.readByte() != 0;
        compositionData = in.readParcelable(CompositionData.class.getClassLoader());
    }

    public static final Creator<BindingDevice> CREATOR = new Creator<BindingDevice>() {
        @Override
        public BindingDevice createFromParcel(Parcel in) {
            return new BindingDevice(in);
        }

        @Override
        public BindingDevice[] newArray(int size) {
            return new BindingDevice[size];
        }
    };

    public int getNetKeyIndex() {
        return netKeyIndex;
    }

    public void setNetKeyIndex(int netKeyIndex) {
        this.netKeyIndex = netKeyIndex;
    }

    public int getMeshAddress() {
        return meshAddress;
    }

    public void setMeshAddress(int meshAddress) {
        this.meshAddress = meshAddress;
    }

    public byte[] getDeviceUUID() {
        return deviceUUID;
    }

    public void setDeviceUUID(byte[] deviceUUID) {
        this.deviceUUID = deviceUUID;
    }

    public int getAppKeyIndex() {
        return appKeyIndex;
    }

    public void setAppKeyIndex(int appKeyIndex) {
        this.appKeyIndex = appKeyIndex;
    }

    public int[] getModels() {
        return models;
    }

    public void setModels(int[] models) {
        this.models = models;
    }

    public BindingBearer getBearer() {
        return bearer;
    }

    public void setBearer(BindingBearer bearer) {
        this.bearer = bearer;
    }

    public boolean isDefaultBound() {
        return defaultBound;
    }

    public void setDefaultBound(boolean defaultBound) {
        this.defaultBound = defaultBound;
    }

    public CompositionData getCompositionData() {
        return compositionData;
    }

    public void setCompositionData(CompositionData compositionData) {
        this.compositionData = compositionData;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(netKeyIndex);
        dest.writeInt(meshAddress);
        dest.writeByteArray(deviceUUID);
        dest.writeInt(appKeyIndex);
        dest.writeIntArray(models);
        dest.writeByte((byte) (defaultBound ? 1 : 0));
        dest.writeParcelable(compositionData, flags);
    }
}
