/********************************************************************************************************
 * @file     MeshUpdatingDevice.java 
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

/**
 * Mesh firmware updating device
 * Created by kee on 2019/10/10.
 */
public class MeshUpdatingDevice implements Parcelable {

    public static final int STATE_INITIAL = 0;
    public static final int STATE_SUCCESS = 1;
    public static final int STATE_FAIL = 2;

    /**
     * unicast address
     */
    private int meshAddress;

    /**
     * element address at updating model
     *
     * @see com.telink.ble.mesh.core.message.MeshSigModel#SIG_MD_OBJ_TRANSFER_S
     */
    private int updatingEleAddress;

    private int state = STATE_INITIAL;

    public MeshUpdatingDevice() {
    }

    protected MeshUpdatingDevice(Parcel in) {
        meshAddress = in.readInt();
        updatingEleAddress = in.readInt();
        state = in.readInt();
    }

    public static final Creator<MeshUpdatingDevice> CREATOR = new Creator<MeshUpdatingDevice>() {
        @Override
        public MeshUpdatingDevice createFromParcel(Parcel in) {
            return new MeshUpdatingDevice(in);
        }

        @Override
        public MeshUpdatingDevice[] newArray(int size) {
            return new MeshUpdatingDevice[size];
        }
    };

    public int getMeshAddress() {
        return meshAddress;
    }

    public void setMeshAddress(int meshAddress) {
        this.meshAddress = meshAddress;
    }

    public int getUpdatingEleAddress() {
        return updatingEleAddress;
    }

    public void setUpdatingEleAddress(int updatingEleAddress) {
        this.updatingEleAddress = updatingEleAddress;
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(meshAddress);
        dest.writeInt(updatingEleAddress);
        dest.writeInt(state);
    }
}
