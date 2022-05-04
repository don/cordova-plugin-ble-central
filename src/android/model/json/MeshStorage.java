/********************************************************************************************************
 * @file     MeshStorage.java
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
package com.megster.cordova.ble.central.model.json;


import com.telink.ble.mesh.core.message.MeshMessage;
import com.telink.ble.mesh.entity.Scheduler;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by kee on 2018/9/10.
 *
 * change type of period in publish from integer to object
 * add HeartbeatPublication and HeartbeatSubscription
 */

public class MeshStorage {

    public interface Defaults {
        String Schema = "http://json-schema.org/draft-04/schema#";
        String Version = "1.0.0";
        String Id = "http://www.bluetooth.com/specifications/assigned-numbers/mesh-profile/cdb-schema.json#";
        String MeshName = "Telink-Sig-Mesh";

        int IV_INDEX = 0;

        String KEY_INVALID = "00000000000000000000000000000000";

        String ADDRESS_INVALID = "0000";

        String LOCAL_DEVICE_KEY = "00112233445566778899AABBCCDDEEFF";
    }

    public String $schema = Defaults.Schema;

    public String id = Defaults.Id;

    public String version = Defaults.Version;

    public String meshName = Defaults.MeshName;

    public String meshUUID;

    public String timestamp;

    public List<Provisioner> provisioners;

    public List<NetworkKey> netKeys;

    public List<ApplicationKey> appKeys;

    /**
     * contains a local node (phone), its UUID is the same with provisioner uuid
     */
    public List<Node> nodes;

    public List<Group> groups;

    public List<Scene> scenes;

    /**
     * custom
     */
    public String ivIndex = String.format("%08X", Defaults.IV_INDEX);

    public static class Provisioner {
        public String provisionerName;

        public String UUID;

        public List<AddressRange> allocatedUnicastRange;
        public List<AddressRange> allocatedGroupRange;
        public List<SceneRange> allocatedSceneRange;

        public static class AddressRange {
            public AddressRange(String lowAddress, String highAddress) {
                this.lowAddress = lowAddress;
                this.highAddress = highAddress;
            }

            public String lowAddress;
            public String highAddress;
        }

        public static class SceneRange {
            public SceneRange(String firstScene, String lastScene) {
                this.firstScene = firstScene;
                this.lastScene = lastScene;
            }

            public String firstScene;
            public String lastScene;
        }
    }

    public static class NetworkKey {
        public String name;

        // 0 -- 4095
        public int index;

        // 0,1,2
        public int phase;
        public String key;
        public String minSecurity;
        public String oldKey = Defaults.KEY_INVALID;
        public String timestamp;
    }

    public static class ApplicationKey {
        public String name;
        public int index;
        public int boundNetKey;
        public String key;
        public String oldKey = Defaults.KEY_INVALID;
    }

    /**
     * only contains one netKey and appKey currently
     */
    public static class Node {

        // custom: not in doc
//        public String macAddress;

        /**
         * sequence number
         * custom value
         * big endian string convert by mesh.sno
         * valued only when node is provisioner
         *
         * @see com.megster.cordova.ble.central.model.MeshInfo#sequenceNumber
         */
//        public String sno;

        public String UUID;
        public String unicastAddress;
        public String deviceKey;
        public String security;
        public List<NodeKey> netKeys;
        public boolean configComplete;
        public String name;
        public String cid;
        public String pid;
        public String vid;
        public String crpl;
        public Features features;
        public boolean secureNetworkBeacon = true;
        public int defaultTTL = MeshMessage.DEFAULT_TTL;
        public Transmit networkTransmit;
        public Transmit relayRetransmit;
        public List<NodeKey> appKeys;
        public List<Element> elements;
        public boolean blacklisted;

        // heartbeatPub
        public HeartbeatPublication heartbeatPub;
        // heartbeatSub
        public List<HeartbeatSubscription> heartbeatSub;


        // custom data for scheduler
        public List<NodeScheduler> schedulers;
    }

    public static class NodeScheduler {
        public byte index;

        public long year;
        public long month;
        public long day;
        public long hour;
        public long minute;
        public long second;
        public long week;
        public long action;
        public long transTime;
        public int sceneId;

        public static NodeScheduler fromScheduler(Scheduler scheduler) {
            NodeScheduler nodeScheduler = new NodeScheduler();
            nodeScheduler.index = scheduler.getIndex();

            Scheduler.Register register = scheduler.getRegister();
            nodeScheduler.year = register.getYear();
            nodeScheduler.month = register.getMonth();
            nodeScheduler.day = register.getDay();
            nodeScheduler.hour = register.getHour();
            nodeScheduler.minute = register.getMinute();
            nodeScheduler.second = register.getSecond();
            nodeScheduler.week = register.getWeek();
            nodeScheduler.action = register.getAction();
            nodeScheduler.transTime = register.getTransTime();
            nodeScheduler.sceneId = register.getSceneId();
            return nodeScheduler;
        }
    }

    public static class Features {
        public int relay;
        public int proxy;
        public int friend;
        public int lowPower;

        public Features(int relay, int proxy, int friend, int lowPower) {
            this.relay = relay;
            this.proxy = proxy;
            this.friend = friend;
            this.lowPower = lowPower;
        }
    }

    //Network transmit && Relay retransmit
    public static class Transmit {
        // 0--7
        public int count;
        // 10--120
        public int interval;

        public Transmit(int count, int interval) {
            this.count = count;
            this.interval = interval;
        }
    }

    // node network key && node application key
    public static class NodeKey {
        public int index;
        public boolean updated;

        public NodeKey(int index, boolean updated) {
            this.index = index;
            this.updated = updated;
        }
    }

    public static class Element {
        public String name;
        public int index;
        public String location;
        public List<Model> models;
    }

    public static class Model {
        public String modelId;
        public List<String> subscribe = new ArrayList<>();
        public Publish publish;
        public List<Integer> bind;
    }

    public static class Publish {
        public String address;
        public int index;
        public int ttl;
        public PublishPeriod period;
        public int credentials;
        public Transmit retransmit;
    }

    public static class PublishPeriod {
        /**
         * The numberOfStepa property contains an integer from 0 to 63 that represents the number of steps used
         * to calculate the publish period .
         */
        public int numberOfSteps;

        /**
         * The resolution property contains an integer that represents the publish step resolution in milliseconds.
         * The allowed values are: 100, 1000, 10000, and 600000.
         */
        public int resolution;
    }

    public static class HeartbeatPublication {
        public String address;
        public int period;
        public int ttl;
        public int index;
        public List<String> features;
    }

    public static class HeartbeatSubscription {
        public String source;
        public String destination;
        public int period;
    }


    public static class Group {
        public String name;
        public String address;
        public String parentAddress = Defaults.ADDRESS_INVALID;
    }

    public static class Scene {
        public String name;
        public List<String> addresses;
        public String number;
    }

}
