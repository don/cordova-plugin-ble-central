/********************************************************************************************************
 * @file     FastProvisioningController.java 
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
package com.telink.ble.mesh.core.access;

import android.os.Handler;
import android.os.HandlerThread;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.MeshMessage;
import com.telink.ble.mesh.core.message.NotificationMessage;
import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.fastpv.MeshAddressStatusMessage;
import com.telink.ble.mesh.core.message.fastpv.MeshConfirmRequestMessage;
import com.telink.ble.mesh.core.message.fastpv.MeshGetAddressMessage;
import com.telink.ble.mesh.core.message.fastpv.MeshProvisionCompleteMessage;
import com.telink.ble.mesh.core.message.fastpv.MeshSetAddressMessage;
import com.telink.ble.mesh.core.message.fastpv.MeshSetNetInfoMessage;
import com.telink.ble.mesh.core.message.fastpv.ResetNetworkMessage;
import com.telink.ble.mesh.entity.FastProvisioningConfiguration;
import com.telink.ble.mesh.entity.FastProvisioningDevice;
import com.telink.ble.mesh.foundation.MeshConfiguration;
import com.telink.ble.mesh.util.Arrays;
import com.telink.ble.mesh.util.MeshLogger;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;


/**
 * fast provisioning flow:
 * 1. connect to unprovisioned device
 * 2. send vendor command VD_MESH_RESET_NETWORK to 0xFFFF on proxy handle (user define)
 * 3. reset provisioner mesh netKey/keyIndex and appKey/keyIndex ivIndex to default after 2000ms
 * 4. send VD_MESH_ADDR_GET command to address 0xFFFF , pid and mac will response when device received command
 * cache mesh address status until timeout
 * 5. send VD_MESH_ADDR_SET command to default unicast address one by one
 * 6. send VD_MESH_PROV_DATA_SET to 0xFFFF: setting network info
 * 7. send VD_MESH_PROV_CONFIRM : if receive device response VD_MESH_PROV_CONFIRM_STS when it do not received network info,
 *  resend VD_MESH_PROV_DATA_SET
 * 8. if no device response, send VD_MESH_PROV_COMPLETE to set network back
 *
 * <p>
 * Created by kee on 2019/9/26.
 */
public class FastProvisioningController {

    private final String LOG_TAG = "FastProv";

    /**
     * 5 minutes
     */
    private static final int FLOW_TIMEOUT = 5 * 60 * 1000;

    // provisioner delay after command delay
    private static final int PROVISIONER_DELAY = 500;

    /**
     * mesh get address timeout
     */
    private static final int FAST_SCANNING_TIMEOUT = 3500;

    /**
     * confirm check timeout
     */
    private static final int CONFIRM_CHECK_TIMEOUT = 3000;

    private static final int ROUND_MAX = 10;
    /**
     * opcode:
     * #define VD_MESH_RESET_NETWORK 0xC5
     * #define VD_MESH_ADDR_GET 0xC6
     * #define VD_MESH_ADDR_GET_STS 0xC7
     * #define VD_MESH_ADDR_SET 0xC8
     * #define VD_MESH_ADDR_SET_STS 0xC9
     * #define VD_MESH_PROV_DATA_SET 0xCA
     * #define VD_MESH_PROV_CONFIRM 0xCB
     * #define VD_MESH_PROV_CONFIRM_STS 0xCC
     * #define VD_MESH_PROV_COMPLETE 0xCD
     * <p>
     * FAST_PROV_IDLE,
     * FAST_PROV_START,
     * FAST_PROV_RESET_NETWORK,
     * FAST_PROV_GET_ADDR,
     * FAST_PROV_GET_ADDR_RETRY,
     * FAST_PROV_SET_ADDR,
     * FAST_PROV_NET_INFO,
     * FAST_PROV_CONFIRM,
     * FAST_PROV_CONFIRM_OK,
     * FAST_PROV_COMPLETE,
     * FAST_PROV_TIME_OUT,
     */

    public static final int STATE_IDLE = 0x10;

    public static final int STATE_RESET_NETWORK = 0x11;

    public static final int STATE_GET_ADDR = 0x12;

    public static final int STATE_SET_ADDR = 0x13;

    public static final int STATE_SET_ADDR_SUCCESS = 0x16;

    public static final int STATE_SET_NET_INFO = 0x14;

    public static final int STATE_CONFIRM = 0x15;


    public static final int STATE_FAIL = 0x18;

    public static final int STATE_SUCCESS = 0x19;


    private int state;

    private Handler delayHandler;

    private AccessBridge accessBridge;

    private FastProvisioningConfiguration configuration;

    // cached address message
    private ArrayList<FastProvisioningDevice> provisioningDeviceList = new ArrayList<>();

    /**
     * mesh setting index
     * set device mesh address one by one
     */
    private int settingIndex;

    /**
     * origin mesh config
     */
    private MeshConfiguration originMeshConfiguration;

    /**
     * if need retry after
     */
    private boolean confirmRetryNeeded = false;

    private static final int CONFIRM_RETRY_MAX = 5;

    private int confirmRetryCnt = 0;

    public FastProvisioningController(HandlerThread handlerThread) {
        delayHandler = new Handler(handlerThread.getLooper());
    }

    public void register(AccessBridge accessBridge) {
        this.accessBridge = accessBridge;
    }

    public FastProvisioningConfiguration getConfiguration() {
        return configuration;
    }

    public void init(FastProvisioningConfiguration configuration, MeshConfiguration meshConfiguration) {
        this.configuration = configuration;
        this.originMeshConfiguration = meshConfiguration;
    }

    public void begin() {
        log("begin");
        delayHandler.removeCallbacks(flowTimeoutTask);
        delayHandler.postDelayed(flowTimeoutTask, FLOW_TIMEOUT);
        resetNetwork();
    }

    public void clear() {
        this.state = STATE_IDLE;
        if (delayHandler != null) {
            delayHandler.removeCallbacksAndMessages(null);
        }
        provisioningDeviceList.clear();
    }

    public void stop() {
        if (this.state != STATE_IDLE) {
            sendCompleteMessage();
        }
        clear();
    }

    private Runnable flowTimeoutTask = new Runnable() {
        @Override
        public void run() {
            onFastProvisionComplete(false, "fast provision timeout");
        }
    };

    /**
     * reset network to default
     */
    private void resetNetwork() {

        // send reset message by local network info
        ResetNetworkMessage resetMessage = ResetNetworkMessage.getSimple(0xFFFF,
                originMeshConfiguration.getDefaultAppKeyIndex(),
                this.configuration.getResetDelay());
        if (this.onMeshMessagePrepared(resetMessage)) {
            // if reset message sent, start reset timer
            onStateUpdate(STATE_RESET_NETWORK, "reset provisioner network", null);
            delayHandler.removeCallbacks(resetNetworkTask);
            delayHandler.postDelayed(resetNetworkTask, PROVISIONER_DELAY + configuration.getResetDelay());
        } else {
            onFastProvisionComplete(false, "reset command send err");
        }
    }

    private Runnable resetNetworkTask = new Runnable() {
        @Override
        public void run() {
            restartScanningTimeoutTask();
            startFastScanning();
        }
    };

    // get address
    private void startFastScanning() {
        onStateUpdate(STATE_GET_ADDR, "mesh get address", null);
        MeshGetAddressMessage getAddressMessage = MeshGetAddressMessage.getSimple(0xFFFF, configuration.getDefaultAppKeyIndex(), ROUND_MAX, configuration.getScanningPid());
        onMeshMessagePrepared(getAddressMessage);
    }

    private void restartScanningTimeoutTask() {
        delayHandler.removeCallbacks(fastScanningTimeoutTask);
        delayHandler.postDelayed(fastScanningTimeoutTask, FAST_SCANNING_TIMEOUT);
    }

    private Runnable fastScanningTimeoutTask = new Runnable() {
        @Override
        public void run() {
            if (provisioningDeviceList.size() > 0) {
                settingIndex = -1;
                setNextMeshAddress();
            } else {
                onFastProvisionComplete(false, "no device found");
            }
        }
    };

    private void setNextMeshAddress() {
        settingIndex++;
        if (provisioningDeviceList.size() > settingIndex) {
            FastProvisioningDevice provisioningDevice = provisioningDeviceList.get(settingIndex);
            if (provisioningDevice != null) {
                log(String.format("mesh set next address: mac -- %s originAddress -- %04X newAddress -- %04X index -- %02d",
                        Arrays.bytesToHexString(provisioningDevice.getMac()),
                        provisioningDevice.getOriginAddress(),
                        provisioningDevice.getNewAddress(), settingIndex));
                onStateUpdate(STATE_SET_ADDR, "mesh set address", provisioningDevice);

                MeshSetAddressMessage setAddressMessage = MeshSetAddressMessage.getSimple(
                        provisioningDevice.getOriginAddress(),
                        configuration.getDefaultAppKeyIndex(),
                        Arrays.reverse(provisioningDevice.getMac()),
                        provisioningDevice.getNewAddress()
                );
                onMeshMessagePrepared(setAddressMessage);
            } else {
                log("provisioning device not found");
            }

        } else {
            log("all device set address complete");
            confirmRetryCnt = 0;
            setMeshNetInfo();
        }
    }

    private void setMeshNetInfo() {
        onStateUpdate(STATE_SET_NET_INFO, "mesh set net info", null);
        byte[] netInfoData = getNetInfoData();
        MeshSetNetInfoMessage setNetInfoMessage = MeshSetNetInfoMessage.getSimple(0xFFFF,
                configuration.getDefaultAppKeyIndex(),
                netInfoData);
        onMeshMessagePrepared(setNetInfoMessage);

        sendConfirmRequest();
    }

    private void sendConfirmRequest() {
        onStateUpdate(STATE_CONFIRM, "fast provision confirming", null);
        confirmRetryNeeded = false;
        MeshConfirmRequestMessage confirmRequestMessage = MeshConfirmRequestMessage.getSimple(0xFFFF, configuration.getDefaultAppKeyIndex());
        onMeshMessagePrepared(confirmRequestMessage);
        delayHandler.postDelayed(confirmCheckTimeoutTask, CONFIRM_CHECK_TIMEOUT);
    }

    private Runnable confirmCheckTimeoutTask = new Runnable() {
        @Override
        public void run() {
            if (confirmRetryNeeded) {
                confirmRetryCnt++;
                if (confirmRetryCnt > CONFIRM_RETRY_MAX) {
                    onFastProvisionComplete(false, "confirm check retry max");
                } else {
                    setMeshNetInfo();
//                    sendConfirmRequest();
                }
            } else {
                onFastProvisionComplete(true, "confirm check success");
            }
        }
    };

    //

    /**
     * @param success true: no confirm response, all device provision success
     *                false: other error
     */
    private void onFastProvisionComplete(final boolean success, String desc) {
        log("complete: " + desc + " success?" + success);
        sendCompleteMessage();
        delayHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                clear();
                onStateUpdate(success ? STATE_SUCCESS : STATE_FAIL, "fast provision complete", null);
            }
        }, PROVISIONER_DELAY + configuration.getResetDelay());
    }

    private void sendCompleteMessage() {
        MeshProvisionCompleteMessage completeMessage = MeshProvisionCompleteMessage.getSimple(0xFFFF,
                configuration.getDefaultAppKeyIndex(),
                configuration.getResetDelay());
        onMeshMessagePrepared(completeMessage);
    }

    private boolean onMeshMessagePrepared(MeshMessage meshMessage) {
        log("mesh message prepared: " + meshMessage.getClass().getSimpleName()
                + String.format(" opcode: 0x%04X -- dst: 0x%04X", meshMessage.getOpcode(), meshMessage.getDestinationAddress()));
        if (accessBridge != null) {
            boolean isMessageSent = accessBridge.onAccessMessagePrepared(meshMessage, AccessBridge.MODE_FIRMWARE_UPDATING);
            if (!isMessageSent) {
                log("message send error");
            }
            return isMessageSent;
        }
        return false;
    }

    private int getProvisioningMeshAddress(int pid) {
        int elementCount = configuration.getElementCount(pid);
        if (elementCount != 0) {
            int address = configuration.getProvisioningIndex();
            if (MeshUtils.validUnicastAddress(address)) {
                configuration.increaseProvisioningIndex(elementCount);
                return address;
            } else {
                log("invalid address", MeshLogger.LEVEL_WARN);
            }
        } else {
            log("pid not found", MeshLogger.LEVEL_WARN);
        }
        return 0;
    }

    public void onFastProvisioningCommandComplete(boolean success, int opcode, int rspMax, int rspCount) {

        if (opcode == Opcode.VD_MESH_ADDR_SET.value && state == STATE_SET_ADDR) {
            if (!success) {
                setNextMeshAddress();
            }
        }

    }


    public void onMessageNotification(NotificationMessage message) {
        Opcode opcode = Opcode.valueOf(message.getOpcode());
        log("message notification: " + opcode);
        if (opcode == null) return;
        switch (opcode) {
            case VD_MESH_ADDR_GET_STS:
                if (state == STATE_GET_ADDR) {

                    MeshAddressStatusMessage statusMessage = (MeshAddressStatusMessage) message.getStatusMessage();
                    int originAddress = message.getSrc();
                    int pid = statusMessage.getPid();
                    log("device address notify: " + Arrays.bytesToHexString(statusMessage.getMac()));
                    int newAddress = getProvisioningMeshAddress(pid);
                    if (newAddress != 0) {
                        int elementCount = configuration.getElementCount(pid);
                        FastProvisioningDevice fastProvisioningDevice = new FastProvisioningDevice(
                                originAddress,
                                newAddress,
                                pid,
                                elementCount,
                                statusMessage.getMac());
                        if (!provisioningDeviceList.contains(fastProvisioningDevice)) {
                            provisioningDeviceList.add(fastProvisioningDevice);
                            restartScanningTimeoutTask();
                        } else {
                            log("provisioning device exists: " + Arrays.bytesToHexString(statusMessage.getMac()));
                        }
                    }

                }


                break;

            case VD_MESH_ADDR_SET_STS: {
                if (state == STATE_SET_ADDR) {
                    int srcAdr = message.getSrc();
                    FastProvisioningDevice device = getProvisioningDeviceByAddress(srcAdr);
                    if (device != null) {
                        onStateUpdate(STATE_SET_ADDR_SUCCESS, "device set address success", device);
                        setNextMeshAddress();
                    }
                }
            }

            break;

            case VD_MESH_PROV_CONFIRM_STS: {
                if (state == STATE_CONFIRM) {
                    confirmRetryNeeded = true;
                }
            }
            break;
        }
    }


    private FastProvisioningDevice getProvisioningDeviceByAddress(int meshAddress) {
        for (FastProvisioningDevice device : provisioningDeviceList) {
            if (device.getOriginAddress() == meshAddress) {
                return device;
            }
        }
        return null;
    }

    private void onStateUpdate(int state, String desc, Object obj) {
        this.state = state;
        if (accessBridge != null) {
            accessBridge.onAccessStateChanged(state, desc, AccessBridge.MODE_FAST_PROVISION, obj);
        }
    }

    private void log(String logMessage) {
        log(logMessage, MeshLogger.LEVEL_DEBUG);
    }

    private void log(String logMessage, int level) {
        MeshLogger.log(logMessage, LOG_TAG, level);
    }

    public byte[] getNetInfoData() {

        byte[] netKey = originMeshConfiguration.networkKey;
        int netKeyIndex = originMeshConfiguration.netKeyIndex;
        int appKeyIndex = originMeshConfiguration.getDefaultAppKeyIndex();
        byte[] appKey = originMeshConfiguration.getDefaultAppKey();
        if (appKey == null) {
            throw new RuntimeException("app key not found!");
        }

        int ivIndex = originMeshConfiguration.ivIndex;
        byte ivUpdateFlag = 0;


        byte[] pvData = new byte[25];
        System.arraycopy(netKey, 0, pvData, 0, 16);

        // key index : little-endian
        pvData[16] = (byte) (netKeyIndex & 0xFF);
        pvData[17] = (byte) ((netKeyIndex >> 8) & 0xFF);
        // iv update flag
        pvData[18] = ivUpdateFlag;

        // iv index : big-endian
        pvData[19] = (byte) ((ivIndex >> 24) & 0xFF);
        pvData[20] = (byte) ((ivIndex >> 16) & 0xFF);
        pvData[21] = (byte) ((ivIndex >> 8) & 0xFF);
        pvData[22] = (byte) ((ivIndex) & 0xFF);
        // ignore address
        //        pvData[23] = (byte) (adr & 0xFF);
        //        pvData[24] = (byte) ((adr >> 8) & 0xFF);

        int netAppKeyIndex = (netKeyIndex & 0x0FFF) | ((appKeyIndex & 0x0FFF) << 12);
        byte[] indexesBuf = MeshUtils.integer2Bytes(netAppKeyIndex, 3, ByteOrder.LITTLE_ENDIAN);
        return ByteBuffer.allocate(25 + 19).order(ByteOrder.LITTLE_ENDIAN).put(pvData)
                .put(indexesBuf)
                .put(appKey).array();
    }

}
