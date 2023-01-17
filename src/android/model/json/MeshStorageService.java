/********************************************************************************************************
 * @file MeshStorageService.java
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
package com.megster.cordova.ble.central.model.json;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.MeshSigModel;
import com.telink.ble.mesh.entity.CompositionData;
import com.telink.ble.mesh.entity.Scheduler;
import com.telink.ble.mesh.entity.TransitionTime;
import com.megster.cordova.ble.central.model.GroupInfo;
import com.megster.cordova.ble.central.model.MeshAppKey;
import com.megster.cordova.ble.central.model.MeshInfo;
import com.megster.cordova.ble.central.model.MeshNetKey;
import com.megster.cordova.ble.central.model.NodeInfo;
import com.megster.cordova.ble.central.model.PublishModel;
import com.megster.cordova.ble.central.model.Scene;
import com.telink.ble.mesh.util.Arrays;
import com.telink.ble.mesh.util.FileSystem;
import com.telink.ble.mesh.util.MeshLogger;
import com.megster.cordova.ble.central.model.json.AddressRange;
import java.io.File;
import java.nio.ByteOrder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class MeshStorageService {
    private static MeshStorageService instance = new MeshStorageService();

    public static final String JSON_FILE = "mesh.json";

    private static final byte[] VC_TOOL_CPS = new byte[]{
            (byte) 0x00, (byte) 0x00, (byte) 0x01, (byte) 0x01, (byte) 0x33, (byte) 0x31, (byte) 0xE8, (byte) 0x03,
            (byte) 0x04, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x17, (byte) 0x01, (byte) 0x00, (byte) 0x00,
            (byte) 0x01, (byte) 0x00, (byte) 0x02, (byte) 0x00, (byte) 0x03, (byte) 0x00, (byte) 0x05, (byte) 0x00,
            (byte) 0x00, (byte) 0xFE, (byte) 0x01, (byte) 0xFE, (byte) 0x02, (byte) 0xFE, (byte) 0x03, (byte) 0xFE,
            (byte) 0x00, (byte) 0xFF, (byte) 0x01, (byte) 0xFF, (byte) 0x02, (byte) 0x12, (byte) 0x01, (byte) 0x10,
            (byte) 0x03, (byte) 0x10, (byte) 0x05, (byte) 0x10, (byte) 0x08, (byte) 0x10, (byte) 0x05, (byte) 0x12,
            (byte) 0x08, (byte) 0x12, (byte) 0x02, (byte) 0x13, (byte) 0x05, (byte) 0x13, (byte) 0x09, (byte) 0x13,
            (byte) 0x11, (byte) 0x13, (byte) 0x15, (byte) 0x10, (byte) 0x11, (byte) 0x02, (byte) 0x01, (byte) 0x00
    };

    private Gson mGson;

    private MeshStorageService() {
        mGson = new GsonBuilder().setPrettyPrinting().create();
    }

    public static MeshStorageService getInstance() {
        return instance;
    }


    /**
     * import external data
     *
     * @param mesh check if outer mesh#uuid equals inner mesh#uuid
     * @return import success
     */
    public MeshInfo importExternal(String jsonStr, MeshInfo mesh) throws Exception {

        MeshStorage tempStorage = mGson.fromJson(jsonStr, MeshStorage.class);
        if (!validStorageData(tempStorage)) {
            return null;
        }
        MeshInfo tmpMesh = (MeshInfo) mesh.clone();
        if (updateLocalMesh(tempStorage, tmpMesh)) {
            return tmpMesh;
        }


        // sync devices
        /*mesh.devices = tempMesh.devices;
        mesh.scenes = tempMesh.scenes;
        if (!tempMesh.provisionerUUID.equals(mesh.provisionerUUID)) {
            mesh.networkKey = tempMesh.networkKey;
            mesh.netKeyIndex = tempMesh.netKeyIndex;

            mesh.appKey = tempMesh.appKey;
            mesh.appKeyIndex = tempMesh.appKeyIndex;
            AddressRange unicastRange = tempMesh.unicastRange;
            int unicastStart = unicastRange.high + 1;
            mesh.unicastRange = new AddressRange(unicastStart, unicastStart + 0xFF);
            mesh.localAddress = unicastStart;
            mesh.pvIndex = unicastStart + 1;
            mesh.ivIndex = tempMesh.ivIndex;
        } else {
            // if is the same provisioner, sync pvIndex
            mesh.pvIndex = tempMesh.pvIndex;
            mesh.sno = tempMesh.sno;
        }*/
        return null;
    }

    private boolean validStorageData(MeshStorage meshStorage) {
        return meshStorage != null && meshStorage.provisioners != null && meshStorage.provisioners.size() != 0;
    }


    /**
     * save mesh to json file
     *
     * @return file
     */
    public File exportMeshToJson(File dir, String filename, MeshInfo mesh, List<MeshNetKey> selectedNetKeys) {
        MeshStorage meshStorage = meshToJson(mesh, selectedNetKeys);
        String jsonData = mGson.toJson(meshStorage);
        return FileSystem.writeString(dir, filename, jsonData);
    }

    /**
     * @return json string
     */
    public String meshToJsonString(MeshInfo meshInfo, List<MeshNetKey> selectedNetKeys) {
        MeshStorage meshStorage = meshToJson(meshInfo, selectedNetKeys);
        return mGson.toJson(meshStorage);
    }

    /**
     * convert mesh instance to MeshStorage instance, for JSON export
     *
     * @param mesh instance
     */
    private MeshStorage meshToJson(MeshInfo mesh, List<MeshNetKey> selectedNetKeys) {
        MeshStorage meshStorage = new MeshStorage();

        meshStorage.meshUUID = Arrays.bytesToHexString(MeshUtils.generateRandom(16), "").toUpperCase();
//        long time = MeshUtils.getTaiTime();

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX", Locale.getDefault());
        String formattedDate = sdf.format(new Date());
        MeshLogger.d("time : " + formattedDate);
        meshStorage.timestamp = formattedDate;

        // add all netKey
        meshStorage.netKeys = new ArrayList<>();
        MeshStorage.ApplicationKey appKey;
        meshStorage.appKeys = new ArrayList<>();
        // for (MeshNetKey meshNetKey : mesh.meshNetKeyList) {
        for (MeshNetKey meshNetKey : selectedNetKeys) {
            MeshStorage.NetworkKey netKey = new MeshStorage.NetworkKey();
//            netKey.name = "Telink Network Key";
            netKey.name = meshNetKey.name;
            netKey.index = meshNetKey.index;
            netKey.phase = 0;
            // secure | insecure
            netKey.minSecurity = "secure";
            netKey.timestamp = meshStorage.timestamp;
            netKey.key = Arrays.bytesToHexString(meshNetKey.key, "").toUpperCase();
            meshStorage.netKeys.add(netKey);

            // find bound app keys
            for (MeshAppKey ak : mesh.appKeyList) {
                if (ak.boundNetKeyIndex == meshNetKey.index) {
                    appKey = new MeshStorage.ApplicationKey();
                    appKey.name = ak.name;
                    appKey.index = ak.index;
                    appKey.key = Arrays.bytesToHexString(ak.key, "").toUpperCase();
                    // bound network key index
                    appKey.boundNetKey = ak.boundNetKeyIndex;
                    meshStorage.appKeys.add(appKey);
                    break;
                }
            }

        }


        // add default appKey
        /*MeshStorage.ApplicationKey appKey;
        meshStorage.appKeys = new ArrayList<>();
        for (MeshAppKey ak : mesh.appKeyList) {
            appKey = new MeshStorage.ApplicationKey();
            appKey.name = "Telink Application Key";
            appKey.index = ak.index;
            appKey.key = Arrays.bytesToHexString(ak.key, "").toUpperCase();

            // bound network key index
            appKey.boundNetKey = ak.boundNetKeyIndex;
            meshStorage.appKeys.add(appKey);
        }*/

        meshStorage.groups = new ArrayList<>();
//        String[] groupNames = context.getResources().getStringArray(R.array.group_name);
        List<GroupInfo> groups = mesh.groups;
        for (int i = 0; i < groups.size(); i++) {
            MeshStorage.Group group = new MeshStorage.Group();
            group.address = String.format("%04X", groups.get(i).address);
            group.name = groups.get(i).name;
            meshStorage.groups.add(group);
        }


        // create default provisioner
        MeshStorage.Provisioner provisioner = new MeshStorage.Provisioner();
        provisioner.UUID = mesh.provisionerUUID;
        provisioner.provisionerName = "Telink Provisioner";
        // create uncast range, default: 0x0001 -- 0x00FF
        provisioner.allocatedUnicastRange = new ArrayList<>();


        for (AddressRange range : mesh.unicastRange) {
            provisioner.allocatedUnicastRange.add(
                    new MeshStorage.Provisioner.AddressRange(String.format("%04X", range.low), String.format("%04X", range.high))
            );
        }

        provisioner.allocatedGroupRange = new ArrayList<>();
        provisioner.allocatedGroupRange.add(new MeshStorage.Provisioner.AddressRange("C000", "C0FF"));
        provisioner.allocatedSceneRange = new ArrayList<>();
        provisioner.allocatedSceneRange.add(new MeshStorage.Provisioner.SceneRange(String.format("%04X", 0x01),
                String.format("%04X", 0x0F)));

        meshStorage.provisioners = new ArrayList<>();
        meshStorage.provisioners.add(provisioner);


        /**
         * create node info by provisioner info
         */
        MeshStorage.Node localNode = new MeshStorage.Node();
        // bind provisioner and node
        localNode.UUID = provisioner.UUID;
//        localNode.sno = String.format("%08X", mesh.sequenceNumber);
        localNode.unicastAddress = String.format("%04X", mesh.localAddress);
        MeshLogger.log("alloc address: " + localNode.unicastAddress);
        localNode.name = "Provisioner Node";

        // add default netKey in node
        localNode.netKeys = new ArrayList<>();
        localNode.netKeys.add(new MeshStorage.NodeKey(0, false));

        // add default appKey in node
        localNode.appKeys = new ArrayList<>();
        localNode.appKeys.add(new MeshStorage.NodeKey(0, false));

        localNode.deviceKey = MeshStorage.Defaults.LOCAL_DEVICE_KEY;

        localNode.security = MeshSecurity.Secure.getDesc();

        getLocalElements(localNode, mesh.getDefaultAppKeyIndex());
        if (meshStorage.nodes == null) {
            meshStorage.nodes = new ArrayList<>();
        }
        meshStorage.nodes.add(localNode);

        if (mesh.nodes != null) {
            for (NodeInfo deviceInfo : mesh.nodes) {
                meshStorage.nodes.add(convertDeviceInfoToNode(deviceInfo, mesh.getDefaultAppKeyIndex()));
            }
        }

        meshStorage.ivIndex = String.format("%08X", mesh.ivIndex);

        /*
         * convert [mesh.scenes] to [meshStorage.scenes]
         */
        meshStorage.scenes = new ArrayList<>();
        if (mesh.scenes != null) {
            MeshStorage.Scene scene;
            for (Scene meshScene : mesh.scenes) {
                scene = new MeshStorage.Scene();
                scene.number = String.format("%04X", meshScene.id);
                scene.name = meshScene.name;
                if (meshScene.states != null) {
                    scene.addresses = new ArrayList<>();
                    for (Scene.SceneState state : meshScene.states) {
                        scene.addresses.add(String.format("%04X", state.address));
                    }
                }
                meshStorage.scenes.add(scene);
            }
        }

        return meshStorage;
    }

    /**
     * convert meshStorage to mesh instance
     *
     * @param meshStorage imported from json object or web cloud
     * @return mesh
     */
    public boolean updateLocalMesh(MeshStorage meshStorage, MeshInfo mesh) {
//        Mesh mesh = new Mesh();

        // import all network keys
        mesh.meshNetKeyList = new ArrayList<>();
        for (MeshStorage.NetworkKey networkKey : meshStorage.netKeys) {
            MeshLogger.d("import netkey : " + networkKey.key);
            mesh.meshNetKeyList.add(
                    new MeshNetKey(networkKey.name, networkKey.index, Arrays.hexToBytes(networkKey.key))
            );

        }

        mesh.appKeyList = new ArrayList<>();
        for (MeshStorage.ApplicationKey applicationKey : meshStorage.appKeys) {
            mesh.appKeyList.add(new MeshAppKey(applicationKey.name, applicationKey.index, Arrays.hexToBytes(applicationKey.key), applicationKey.boundNetKey));
        }

//        MeshStorage.Provisioner provisioner = meshStorage.provisioners.get(0);
//        mesh.provisionerUUID = provisioner.UUID;
        if (meshStorage.provisioners == null || meshStorage.provisioners.size() == 0) {
            return false;
        }

        MeshStorage.Provisioner localProvisioner = null;
        int maxRangeHigh = -1;
        int tmpHigh;
        for (MeshStorage.Provisioner provisioner : meshStorage.provisioners) {
            if (mesh.provisionerUUID.equals(provisioner.UUID)) {
                localProvisioner = provisioner;
                maxRangeHigh = -1;
                break;
            } else {
                for (MeshStorage.Provisioner.AddressRange unRange :
                        provisioner.allocatedUnicastRange) {
                    tmpHigh = MeshUtils.hexString2Int(unRange.highAddress, ByteOrder.BIG_ENDIAN);
                    if (maxRangeHigh == -1 || maxRangeHigh < tmpHigh) {
                        maxRangeHigh = tmpHigh;
                    }
                }
            }
        }

        /*
        if (!tempMesh.provisionerUUID.equals(mesh.provisionerUUID)) {
            mesh.networkKey = tempMesh.networkKey;
            mesh.netKeyIndex = tempMesh.netKeyIndex;

            mesh.appKey = tempMesh.appKey;
            mesh.appKeyIndex = tempMesh.appKeyIndex;
            AddressRange unicastRange = tempMesh.unicastRange;
            int unicastStart = unicastRange.high + 1;
            mesh.unicastRange = new AddressRange(unicastStart, unicastStart + 0xFF);
            mesh.localAddress = unicastStart;
            mesh.pvIndex = unicastStart + 1;
            mesh.ivIndex = tempMesh.ivIndex;
        } else {

            mesh.pvIndex = tempMesh.pvIndex;
            mesh.sno = tempMesh.sno;
        }
         */
        if (localProvisioner == null) {
            int low = maxRangeHigh + 1;

            if (low + 0xFF > MeshUtils.UNICAST_ADDRESS_MAX) {
                MeshLogger.d("no available unicast range");
                return false;
            }
            final int high = low + 0x03FF;
            mesh.unicastRange = new ArrayList<AddressRange>();
            mesh.unicastRange.add(new AddressRange(low, high));
            mesh.localAddress = low;
            mesh.resetProvisionIndex(low + 1);
            mesh.addressTopLimit = high;
            mesh.sequenceNumber = 0;
//            MeshStorage.Provisioner.AddressRange unicastRange = localProvisioner.allocatedUnicastRange.get(0);
//
//            mesh.unicastRange = new AddressRange(low, high);
        }


//        mesh.groupRange = new AddressRange(0xC000, 0xC0FF);

//        mesh.sceneRange = new AddressRange(0x01, 0x0F);


        if (TextUtils.isEmpty(meshStorage.ivIndex)) {
            mesh.ivIndex = MeshStorage.Defaults.IV_INDEX;
        } else {
            mesh.ivIndex = MeshUtils.hexString2Int(meshStorage.ivIndex, ByteOrder.BIG_ENDIAN);
        }

        mesh.groups = new ArrayList<>();

        if (meshStorage.groups != null) {
            GroupInfo group;
            for (MeshStorage.Group gp : meshStorage.groups) {
                group = new GroupInfo();
                group.name = gp.name;
                group.address = MeshUtils.hexString2Int(gp.address, ByteOrder.BIG_ENDIAN);
                mesh.groups.add(group);
            }
        }

        mesh.nodes = new ArrayList<>();
        if (meshStorage.nodes != null) {
            NodeInfo deviceInfo;
            for (MeshStorage.Node node : meshStorage.nodes) {
                if (!isProvisionerNode(meshStorage, node)) {
                    deviceInfo = new NodeInfo();
                    deviceInfo.meshAddress = MeshUtils.hexString2Int(node.unicastAddress, ByteOrder.BIG_ENDIAN);
                    deviceInfo.deviceUUID = (Arrays.hexToBytes(node.UUID.replace(":", "").replace("-", "")));
                    deviceInfo.elementCnt = node.elements == null ? 0 : node.elements.size();
                    deviceInfo.deviceKey = Arrays.hexToBytes(node.deviceKey);

                    List<Integer> subList = new ArrayList<>();
                    PublishModel publishModel;
                    if (node.elements != null) {
                        for (MeshStorage.Element element : node.elements) {
                            if (element.models == null) {
                                continue;
                            }
                            for (MeshStorage.Model model : element.models) {

                                if (model.subscribe != null) {
                                    int subAdr;
                                    for (String sub : model.subscribe) {
                                        subAdr = MeshUtils.hexString2Int(sub, ByteOrder.BIG_ENDIAN);
                                        if (!subList.contains(subAdr)) {
                                            subList.add(subAdr);
                                        }
                                    }
                                }
                                if (model.publish != null) {
                                    MeshStorage.Publish publish = model.publish;
                                    int pubAddress = MeshUtils.hexString2Int(publish.address, ByteOrder.BIG_ENDIAN);
                                    // pub address from vc-tool， default is 0
                                    if (pubAddress != 0 && publish.period != null) {
                                        int elementAddress = element.index + MeshUtils.hexString2Int(node.unicastAddress, ByteOrder.BIG_ENDIAN);
                                        int interval = (publish.retransmit.interval / 50) - 1;
                                        int transmit = publish.retransmit.count | (interval << 3);
                                        int periodTime = publish.period.numberOfSteps * publish.period.resolution;
                                        publishModel = new PublishModel(elementAddress,
                                                MeshUtils.hexString2Int(model.modelId, ByteOrder.BIG_ENDIAN),
                                                MeshUtils.hexString2Int(publish.address, ByteOrder.BIG_ENDIAN),
                                                periodTime,
                                                publish.ttl,
                                                publish.credentials,
                                                transmit);
                                        deviceInfo.setPublishModel(publishModel);
                                    }

                                }
                            }
                        }
                    }


                    deviceInfo.subList = subList;
//                    deviceInfo.setPublishModel();
                    deviceInfo.bound = (node.appKeys != null && node.appKeys.size() != 0);

                    deviceInfo.compositionData = convertNodeToNodeInfo(node);

                    if (node.schedulers != null) {
                        deviceInfo.schedulers = new ArrayList<>();
                        for (MeshStorage.NodeScheduler nodeScheduler : node.schedulers) {
                            deviceInfo.schedulers.add(parseNodeScheduler(nodeScheduler));
                        }
                    }

                    mesh.nodes.add(deviceInfo);
                } else {
//                    mesh.localAddress = Integer.valueOf(node.unicastAddress, 16);

                }
            }
        }

        mesh.scenes = new ArrayList<>();
        if (meshStorage.scenes != null && meshStorage.scenes.size() != 0) {
            Scene scene;
            for (MeshStorage.Scene outerScene : meshStorage.scenes) {
                scene = new Scene();
                scene.id = MeshUtils.hexString2Int(outerScene.number, ByteOrder.BIG_ENDIAN);
                scene.name = outerScene.name;
                if (outerScene.addresses != null) {
                    scene.states = new ArrayList<>(outerScene.addresses.size());
                    for (String adrInScene : outerScene.addresses) {
                        // import scene state
                        scene.states.add(new Scene.SceneState(MeshUtils.hexString2Int(adrInScene, ByteOrder.BIG_ENDIAN)));
                    }
                }
                mesh.scenes.add(scene);
            }
        }
        return true;
    }


    // convert nodeInfo(mesh.java) to node(json)
    public MeshStorage.Node convertDeviceInfoToNode(NodeInfo deviceInfo, int appKeyIndex) {
        MeshStorage.Node node = new MeshStorage.Node();
        node.UUID = Arrays.bytesToHexString(deviceInfo.deviceUUID).toUpperCase();
        node.unicastAddress = String.format("%04X", deviceInfo.meshAddress);

        if (deviceInfo.deviceKey != null) {
            node.deviceKey = Arrays.bytesToHexString(deviceInfo.deviceKey, "").toUpperCase();
        }
        node.elements = new ArrayList<>(deviceInfo.elementCnt);

        if (deviceInfo.compositionData != null) {
            node.deviceKey = Arrays.bytesToHexString(deviceInfo.deviceKey, "").toUpperCase();
            node.cid = String.format("%04X", deviceInfo.compositionData.cid);
            node.pid = String.format("%04X", deviceInfo.compositionData.pid);
            node.vid = String.format("%04X", deviceInfo.compositionData.vid);
            node.crpl = String.format("%04X", deviceInfo.compositionData.crpl);
            int features = deviceInfo.compositionData.features;
            // value in supported node is 1, value in unsupported node is 0 (as 2 in json)
            // closed
            node.features = new MeshStorage.Features((features & 0b0001) == 0 ? 2 : 1,
                    (features & 0b0010) == 0 ? 2 : 1,
                    (features & 0b0100) == 0 ? 2 : 1,
                    (features & 0b1000) == 0 ? 2 : 1);
            /*node.features = new MeshStorage.Features(features & 0b0001,
                    features & 0b0010,
                    features & 0b0100,
                    features & 0b1000);*/


            PublishModel publishModel = deviceInfo.getPublishModel();

            if (deviceInfo.compositionData.elements != null) {
                List<CompositionData.Element> elements = deviceInfo.compositionData.elements;
                MeshStorage.Element element;
                for (int i = 0; i < elements.size(); i++) {
                    CompositionData.Element ele = elements.get(i);
                    element = new MeshStorage.Element();
                    element.index = i;
                    element.location = String.format("%04X", ele.location);

                    element.models = new ArrayList<>();
                    MeshStorage.Model model;

                    if (ele.sigNum != 0 && ele.sigModels != null) {
                        for (int modelId : ele.sigModels) {
                            model = new MeshStorage.Model();
                            model.modelId = String.format("%04X", modelId);
                            model.bind = new ArrayList<>();
                            model.bind.add(appKeyIndex);

                            model.subscribe = new ArrayList<>();
                            if (inDefaultSubModel(modelId)) {
                                for (int subAdr : deviceInfo.subList) {
                                    model.subscribe.add(String.format("%04X", subAdr));
                                }
                            }

                            if (publishModel != null && publishModel.modelId == modelId) {
                                final MeshStorage.Publish publish = new MeshStorage.Publish();
                                publish.address = String.format("%04X", publishModel.address);
                                publish.index = 0;

                                publish.ttl = publishModel.ttl;
                                TransitionTime transitionTime = TransitionTime.fromTime(publishModel.period);
                                MeshStorage.PublishPeriod period = new MeshStorage.PublishPeriod();
                                period.numberOfSteps = transitionTime.getNumber() & 0xFF;
                                period.resolution = transitionTime.getResolution();
//                                publish.period = publishModel.period;
                                publish.period = period;
                                publish.credentials = publishModel.credential;
                                publish.retransmit = new MeshStorage.Transmit(publishModel.getTransmitCount()
                                        , (publishModel.getTransmitInterval() + 1) * 50);

                                model.publish = publish;
                            }

                            element.models.add(model);
                        }
                    }

                    if (ele.vendorNum != 0 && ele.vendorModels != null) {

                        for (int modelId : ele.vendorModels) {
                            model = new MeshStorage.Model();
                            model.modelId = String.format("%08X", modelId);
                            model.bind = new ArrayList<>();
                            model.bind.add(appKeyIndex);
                            element.models.add(model);
                        }
                    }
                    node.elements.add(element);
                }
            }
        } else {

            // create elements
            for (int i = 0; i < deviceInfo.elementCnt; i++) {
                node.elements.add(new MeshStorage.Element());
            }
        }
        node.netKeys = new ArrayList<>();
        node.netKeys.add(new MeshStorage.NodeKey(0, false));
        node.configComplete = true;
        node.name = "Common Node";

        // check if appKey list exists to confirm device bound state
        if (deviceInfo.bound) {
            node.appKeys = new ArrayList<>();
            node.appKeys.add(new MeshStorage.NodeKey(0, false));
        }

        node.security = MeshSecurity.Secure.getDesc();


        if (deviceInfo.schedulers != null) {
            node.schedulers = new ArrayList<>();
            for (Scheduler deviceScheduler : deviceInfo.schedulers) {
                node.schedulers.add(MeshStorage.NodeScheduler.fromScheduler(deviceScheduler));
            }
        }

        if (deviceInfo.subList != null) {
            node.subList = new ArrayList<Integer>();
            node.subList.addAll(deviceInfo.subList);
        }

        return node;
    }

    private void getLocalElements(MeshStorage.Node node, int appKeyIndex) {

        node.elements = new ArrayList<>();
        CompositionData compositionData = CompositionData.from(VC_TOOL_CPS);

        List<CompositionData.Element> elements = compositionData.elements;
        MeshStorage.Element element;
        for (int i = 0; i < elements.size(); i++) {
            CompositionData.Element ele = elements.get(i);
            element = new MeshStorage.Element();
            element.index = i;
            element.location = String.format("%04X", ele.location);

            element.models = new ArrayList<>();
            MeshStorage.Model model;

            if (ele.sigNum != 0 && ele.sigModels != null) {
                for (int modelId : ele.sigModels) {
                    model = new MeshStorage.Model();
                    model.modelId = String.format("%04X", modelId);
                    model.bind = new ArrayList<>();
                    model.bind.add(appKeyIndex);

                    model.subscribe = new ArrayList<>();

                    element.models.add(model);
                }
            }

            if (ele.vendorNum != 0 && ele.vendorModels != null) {

                for (int modelId : ele.vendorModels) {
                    model = new MeshStorage.Model();
                    model.modelId = String.format("%08X", modelId);
                    model.bind = new ArrayList<>();
                    model.bind.add(appKeyIndex);
                    element.models.add(model);
                }
            }
            node.elements.add(element);
        }
    }

    //
    private boolean inDefaultSubModel(int modelId) {
        MeshSigModel[] models = MeshSigModel.getDefaultSubList();
        for (MeshSigModel model : models) {
            if (model.modelId == modelId) {
                return true;
            }
        }
        return false;
    }


    /**
     * convert node in json to composition data
     */
    public CompositionData convertNodeToNodeInfo(MeshStorage.Node node) {

        CompositionData compositionData = new CompositionData();

        compositionData.cid = node.cid == null || node.cid.equals("") ? 0 : MeshUtils.hexString2Int(node.cid, ByteOrder.BIG_ENDIAN);
        compositionData.pid = node.pid == null || node.pid.equals("") ? 0 : MeshUtils.hexString2Int(node.pid, ByteOrder.BIG_ENDIAN);
        compositionData.vid = node.vid == null || node.vid.equals("") ? 0 : MeshUtils.hexString2Int(node.vid, ByteOrder.BIG_ENDIAN);
        compositionData.crpl = node.crpl == null || node.crpl.equals("") ? 0 : MeshUtils.hexString2Int(node.crpl, ByteOrder.BIG_ENDIAN);

        //value 2 : unsupported
        int relaySpt = 0, proxySpt = 0, friendSpt = 0, lowPowerSpt = 0;
        if (node.features != null) {
            relaySpt = node.features.relay == 1 ? 0b0001 : 0;
            proxySpt = node.features.proxy == 1 ? 0b0010 : 0;
            friendSpt = node.features.friend == 1 ? 0b0100 : 0;
            lowPowerSpt = node.features.lowPower == 1 ? 0b1000 : 0;
        }
        compositionData.features = relaySpt | proxySpt | friendSpt | lowPowerSpt;


        compositionData.elements = new ArrayList<>();


        if (node.elements != null) {
            CompositionData.Element infoEle;
            for (MeshStorage.Element element : node.elements) {
                infoEle = new CompositionData.Element();

                infoEle.sigModels = new ArrayList<>();
                infoEle.vendorModels = new ArrayList<>();
                if (element.models != null && element.models.size() != 0) {
                    int modelId;
                    for (MeshStorage.Model model : element.models) {

                        // check if is vendor model
                        if (model.modelId != null && !model.modelId.equals("")) {
                            modelId = MeshUtils.hexString2Int(model.modelId, ByteOrder.BIG_ENDIAN);
                            // Integer.valueOf(model.modelId, 16);
                            if ((model.modelId.length()) > 4) {
                                infoEle.vendorModels.add(modelId);
                            } else {
                                infoEle.sigModels.add(modelId);
                            }
                        }

                    }
                    infoEle.sigNum = infoEle.sigModels.size();
                    infoEle.vendorNum = infoEle.vendorModels.size();
                } else {
                    infoEle.sigNum = 0;
                    infoEle.vendorNum = 0;
                }
                infoEle.location = element.location == null || element.location.equals("") ? 0 : MeshUtils.hexString2Int(element.location, ByteOrder.BIG_ENDIAN);
                compositionData.elements.add(infoEle);
            }
        }
        return compositionData;
    }


    // check if node is provisioner
    private boolean isProvisionerNode(MeshStorage meshStorage, MeshStorage.Node node) {
        for (MeshStorage.Provisioner provisioner : meshStorage.provisioners) {
            if (provisioner.UUID.equals(node.UUID)) {
                return true;
            }
        }
        return false;
    }

    /**
     * parse node scheduler to device scheduler
     */
    private Scheduler parseNodeScheduler(MeshStorage.NodeScheduler nodeScheduler) {
        return new Scheduler.Builder()
                .setIndex(nodeScheduler.index)
                .setYear((byte) nodeScheduler.year)
                .setMonth((short) nodeScheduler.month)
                .setDay((byte) nodeScheduler.day)
                .setHour((byte) nodeScheduler.hour)
                .setMinute((byte) nodeScheduler.minute)
                .setSecond((byte) nodeScheduler.second)
                .setWeek((byte) nodeScheduler.week)
                .setAction((byte) nodeScheduler.action)
                .setTransTime((byte) nodeScheduler.transTime)
                .setSceneId((short) nodeScheduler.sceneId).build();
    }


}
