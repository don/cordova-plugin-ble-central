/********************************************************************************************************
 * @file     CompositionData.java 
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

import com.telink.ble.mesh.core.message.MeshSigModel;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by kee on 2019/8/12.
 */
public class CompositionData implements Serializable, Parcelable {
    /**
     * bit 0 Relay feature support: 0 = False, 1 = True
     */
    private static final int FEATURE_RELAY = 0b0001;

    /**
     * bit 1 Proxy feature support: 0 = False, 1 = True
     */
    private static final int FEATURE_PROXY = 0b0010;

    /**
     * bit 2 Friend feature support: 0 = False, 1 = True
     */
    private static final int FEATURE_FRIEND = 0b0100;

    /**
     * bit 3 Low Power feature support: 0 = False, 1 = True
     */
    private static final int FEATURE_LOW_POWER = 0b1000;


    /**
     * Contains a 16-bit company identifier assigned by the Bluetooth SIG
     */
    public int cid;

    /**
     * Contains a 16-bit vendor-assigned product identifier
     */
    public int pid;

    /**
     * Contains a 16-bit vendor-assigned product version identifier
     */
    public int vid;

    /**
     * Contains a 16-bit value representing the minimum number of replay protection list entries in a device
     */
    public int crpl;

    /**
     * supported features
     * 16 bits
     */
    public int features;

    public List<Element> elements;

    public CompositionData() {

    }

    protected CompositionData(Parcel in) {
        cid = in.readInt();
        pid = in.readInt();
        vid = in.readInt();
        crpl = in.readInt();
        features = in.readInt();
    }


    public static final Creator<CompositionData> CREATOR = new Creator<CompositionData>() {
        @Override
        public CompositionData createFromParcel(Parcel in) {
            return new CompositionData(in);
        }

        @Override
        public CompositionData[] newArray(int size) {
            return new CompositionData[size];
        }
    };

    public static CompositionData from(byte[] data) {
        int index = 0;
        CompositionData cpsData = new CompositionData();
        cpsData.cid = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8);
        cpsData.pid = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8);
        cpsData.vid = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8);
        cpsData.crpl = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8);
        cpsData.features = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8);

        cpsData.elements = new ArrayList<>();
        while (index < data.length) {
            Element element = new Element();
            element.location = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8);
            element.sigNum = (data[index++] & 0xFF);
            element.vendorNum = (data[index++] & 0xFF);

            element.sigModels = new ArrayList<>();
            for (int i = 0; i < element.sigNum; i++) {
                element.sigModels.add((data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8));
            }

            element.vendorModels = new ArrayList<>();
            for (int j = 0; j < element.vendorNum; j++) {
                //sample 11 02 01 00 cid: 11 02 modelId: 01 00 -> 0x00010211
                element.vendorModels.add(((data[index++] & 0xFF)) | ((data[index++] & 0xFF) << 8) |
                        ((data[index++] & 0xFF) << 16) | ((data[index++] & 0xFF) << 24));
            }

            cpsData.elements.add(element);
        }

        return cpsData;
    }

    /**
     * @param configExcept config model not include
     * @deprecated
     */
    public List<Integer> getAllModels(boolean configExcept) {
        if (elements == null) return null;
        List<Integer> models = new ArrayList<>();
        for (Element ele : elements) {
            if (ele.sigModels != null) {
                if (!configExcept) {
                    models.addAll(ele.sigModels);
                } else {
                    for (int modelId : ele.sigModels) {
                        if (!MeshSigModel.isConfigurationModel(modelId)) {
                            models.add(modelId);
                        }
                    }
                }

            }
            if (ele.vendorModels != null) {
                models.addAll(ele.vendorModels);
            }
        }

        return models;
    }

    public int getElementOffset(int modelId) {
        int offset = 0;
        for (Element ele : elements) {
            if (ele.sigModels != null && ele.sigModels.contains(modelId)) {
                return offset;
            }
            if (ele.vendorModels != null && ele.vendorModels.contains(modelId)) {
                return offset;
            }
            offset++;
        }
        return -1;
    }

    public boolean relaySupport() {
        return (features & FEATURE_RELAY) != 0;
    }

    public boolean proxySupport() {
        return (features & FEATURE_PROXY) != 0;
    }

    public boolean friendSupport() {
        return (features & FEATURE_FRIEND) != 0;
    }

    public boolean lowPowerSupport() {
        return (features & FEATURE_LOW_POWER) != 0;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(cid);
        dest.writeInt(pid);
        dest.writeInt(vid);
        dest.writeInt(crpl);
        dest.writeInt(features);
        dest.writeTypedList(elements);
    }


    public static class Element implements Serializable, Parcelable {

        /**
         * 2 bytes
         * Contains a location descriptor
         */
        public int location;

        /**
         * 1 byte
         * Contains a count of SIG Model IDs in this element
         */
        public int sigNum;

        /**
         * 1 byte
         * Contains a count of Vendor Model IDs in this element
         */
        public int vendorNum;

        /**
         * Contains a sequence of NumS SIG Model IDs
         */
        public List<Integer> sigModels;

        /**
         * Contains a sequence of NumV Vendor Model IDs
         */
        public List<Integer> vendorModels;

        public Element(){}

        protected Element(Parcel in) {
            location = in.readInt();
            sigNum = in.readInt();
            vendorNum = in.readInt();
        }

        public static final Creator<Element> CREATOR = new Creator<Element>() {
            @Override
            public Element createFromParcel(Parcel in) {
                return new Element(in);
            }

            @Override
            public Element[] newArray(int size) {
                return new Element[size];
            }
        };

        public boolean containModel(int sigModelId) {
            if (sigModels == null || sigModels.size() == 0) return false;
            for (int modelId : sigModels) {
                if (sigModelId == modelId) return true;
            }
            return false;
        }

        @Override
        public int describeContents() {
            return 0;
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeInt(location);
            dest.writeInt(sigNum);
            dest.writeInt(vendorNum);
        }
    }

    @Override
    public String toString() {
        StringBuilder elementInfo = new StringBuilder();
        Element element;
        for (int i = 0; i < elements.size(); i++) {
            element = elements.get(i);
            elementInfo.append("element ").append(i).append(" : \n");
            elementInfo.append("SIG\n");
            String sig;
            for (int j = 0; j < element.sigModels.size(); j++) {
                sig = String.format("%04X", element.sigModels.get(j));
                elementInfo.append(sig).append("\n");
            }
            elementInfo.append("VENDOR\n");
            for (int j = 0; j < element.vendorModels.size(); j++) {
                elementInfo.append(String.format("%08X", element.vendorModels.get(j))).append("\n");
            }
        }

        return "CompositionData{" +
                "cid=" + String.format("%04X", cid) +
                ", pid=" + String.format("%04X", pid) +
                ", vid=" + String.format("%04X", vid) +
                ", crpl=" + String.format("%04X", crpl) +
                ", features=" + String.format("%04X", features) +
                ", elements=" + elementInfo +
                '}';
    }
}


