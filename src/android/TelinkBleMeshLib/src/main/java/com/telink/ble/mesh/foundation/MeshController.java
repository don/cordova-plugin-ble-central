/********************************************************************************************************
 * @file MeshController.java
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
package com.telink.ble.mesh.foundation;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGattService;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.ParcelUuid;
import android.text.TextUtils;
import android.util.SparseArray;

import com.telink.ble.mesh.core.Encipher;
import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.access.AccessBridge;
import com.telink.ble.mesh.core.access.BindingBearer;
import com.telink.ble.mesh.core.access.BindingController;
import com.telink.ble.mesh.core.access.FastProvisioningController;
import com.telink.ble.mesh.core.access.FirmwareUpdatingController;
import com.telink.ble.mesh.core.access.RemoteProvisioningController;
import com.telink.ble.mesh.core.ble.BleScanner;
import com.telink.ble.mesh.core.ble.GattConnection;
import com.telink.ble.mesh.core.ble.GattOtaController;
import com.telink.ble.mesh.core.ble.GattRequest;
import com.telink.ble.mesh.core.ble.LeScanFilter;
import com.telink.ble.mesh.core.ble.LeScanSetting;
import com.telink.ble.mesh.core.ble.MeshScanRecord;
import com.telink.ble.mesh.core.ble.UUIDInfo;
import com.telink.ble.mesh.core.message.MeshMessage;
import com.telink.ble.mesh.core.message.NotificationMessage;
import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.StatusMessage;
import com.telink.ble.mesh.core.message.config.ConfigStatus;
import com.telink.ble.mesh.core.message.config.NodeIdentity;
import com.telink.ble.mesh.core.message.config.NodeIdentitySetMessage;
import com.telink.ble.mesh.core.message.config.NodeIdentityStatusMessage;
import com.telink.ble.mesh.core.networking.NetworkingBridge;
import com.telink.ble.mesh.core.networking.NetworkingController;
import com.telink.ble.mesh.core.provisioning.ProvisioningBridge;
import com.telink.ble.mesh.core.provisioning.ProvisioningController;
import com.telink.ble.mesh.core.proxy.ProxyPDU;
import com.telink.ble.mesh.entity.AdvertisingDevice;
import com.telink.ble.mesh.entity.BindingDevice;
import com.telink.ble.mesh.entity.ConnectionFilter;
import com.telink.ble.mesh.entity.FastProvisioningConfiguration;
import com.telink.ble.mesh.entity.FastProvisioningDevice;
import com.telink.ble.mesh.entity.FirmwareUpdateConfiguration;
import com.telink.ble.mesh.entity.MeshUpdatingDevice;
import com.telink.ble.mesh.entity.ProvisioningDevice;
import com.telink.ble.mesh.entity.RemoteProvisioningDevice;
import com.telink.ble.mesh.foundation.event.AutoConnectEvent;
import com.telink.ble.mesh.foundation.event.BindingEvent;
import com.telink.ble.mesh.foundation.event.BluetoothEvent;
import com.telink.ble.mesh.foundation.event.FastProvisioningEvent;
import com.telink.ble.mesh.foundation.event.FirmwareUpdatingEvent;
import com.telink.ble.mesh.foundation.event.GattConnectionEvent;
import com.telink.ble.mesh.foundation.event.GattNotificationEvent;
import com.telink.ble.mesh.foundation.event.GattOtaEvent;
import com.telink.ble.mesh.foundation.event.MeshEvent;
import com.telink.ble.mesh.foundation.event.NetworkInfoUpdateEvent;
import com.telink.ble.mesh.foundation.event.OnlineStatusEvent;
import com.telink.ble.mesh.foundation.event.ProvisioningEvent;
import com.telink.ble.mesh.foundation.event.ReliableMessageProcessEvent;
import com.telink.ble.mesh.foundation.event.RemoteProvisioningEvent;
import com.telink.ble.mesh.foundation.event.ScanEvent;
import com.telink.ble.mesh.foundation.event.StatusNotificationEvent;
import com.telink.ble.mesh.foundation.parameter.AutoConnectParameters;
import com.telink.ble.mesh.foundation.parameter.BindingParameters;
import com.telink.ble.mesh.foundation.parameter.FastProvisioningParameters;
import com.telink.ble.mesh.foundation.parameter.GattConnectionParameters;
import com.telink.ble.mesh.foundation.parameter.GattOtaParameters;
import com.telink.ble.mesh.foundation.parameter.MeshOtaParameters;
import com.telink.ble.mesh.foundation.parameter.Parameters;
import com.telink.ble.mesh.foundation.parameter.ProvisioningParameters;
import com.telink.ble.mesh.foundation.parameter.ScanParameters;
import com.telink.ble.mesh.util.Arrays;
import com.telink.ble.mesh.util.ContextUtil;
import com.telink.ble.mesh.util.MeshLogger;

import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * Created by kee on 2018/12/11.
 */

public final class MeshController implements ProvisioningBridge, NetworkingBridge, AccessBridge {
    private final String LOG_TAG = "MeshController";

    /**
     * proxy node advertising networkId
     */
    private static final int PROXY_ADV_TYPE_NETWORK_ID = 0x00;

    /**
     * onCommandPrepared
     * proxy node advertising nodeIdentity
     */
    private static final int PROXY_ADV_TYPE_NODE_IDENTITY = 0x01;


    /**
     * period of scanning for node identity when binding
     */
    private static final long BINDING_NODE_IDENTITY_SCAN_PERIOD = 8 * 1000;
    /**
     * scanning controller for bluetooth device scan
     */
    private BleScanner mBleScanner;

    /**
     * gatt controller for gatt connection
     */
    private GattConnection mGattConnection;

//    private Handler mMainThreadHandler = new Handler();

    private Context mContext;

    private HandlerThread handlerThread;

    private Handler mDelayHandler;


    /*
     * controllers
     */
    private ProvisioningController mProvisioningController;

    // mesh network
    private NetworkingController mNetworkingController;

    // key binding
    private BindingController mBindingController;

    // mesh ota
//    private MeshUpdatingController mMeshUpdatingController;

    // firmware update
    private FirmwareUpdatingController mFirmwareUpdatingController;

    /**
     * rely on ProvisioningController
     */
    private RemoteProvisioningController mRemoteProvisioningController;

    private FastProvisioningController mFastProvisioningController;

    private GattOtaController mGattOtaController;

    private Mode actionMode = Mode.MODE_IDLE;

    /**
     * parameters for different action
     */
    private Parameters mActionParams;

    /**
     * is disconnecting when reconnect
     */
    private boolean isDisconnectWaiting = false;
    /**
     * lock for scanning
     */
    private final Object SCAN_LOCK = new Object();

    private boolean isScanning = false;

    private Set<AdvertisingDevice> advDevices = new LinkedHashSet<>();

    private MeshConfiguration meshConfiguration;

    private byte[] networkId = null;

    private byte[] networkIdentityKey = null;

    private byte[] networkBeaconKey = null;

    private boolean isLogin = false;

    /**
     * action started flag when provisioning, binding, ota,  mesh-updating
     */
    private boolean isActionStarted = false;

//    private boolean isProvisionProcessing = false;

//    private boolean isKeyBindProcessing = false;

    private static final int MAX_CONNECT_RETRY = 3;

    private int connectRetry = 0;

    private EventCallback eventCallback;

    /**
     * direct connected device unicast address
     */
    private int directDeviceAddress = 0;

    /**
     * OTA reconnect
     * used when ota target device's advertising identification Type is NetworkID,
     * set to node identity when first connect mesh network, and reconnect by node identity
     */
    private boolean isProxyReconnect = false;

    /**
     * binding target valued when device scanned
     */
    private BluetoothDevice reconnectTarget;

    /**
     * for binding on flex bearer
     */
    private long bindingStartTick = 0;

    void start(Context context) {

        handlerThread = new HandlerThread("Mesh-Controller");
        handlerThread.start();
        mDelayHandler = new Handler(handlerThread.getLooper());

        mContext = context.getApplicationContext();
        initScanningController(handlerThread);
        initGattConnection(handlerThread);
        initGattOtaController();
        initProvisioningController(handlerThread);
        initNetworkingController(handlerThread);
        initAccessController(handlerThread);

        IntentFilter filter = new IntentFilter();
        filter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED);
        mContext.registerReceiver(mBluetoothReceiver, filter);
    }


    private BroadcastReceiver mBluetoothReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action == null) return;
            if (BluetoothAdapter.ACTION_STATE_CHANGED.equals(action)) {
                int state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, 0);
                onBluetoothStateUpdate(state);
            }
        }
    };

    void stop() {
        this.actionMode = Mode.MODE_IDLE;
        this.directDeviceAddress = 0;
        this.isLogin = false;
        stopScan();
        if (advDevices != null) {
            advDevices.clear();
        }

        if (mGattConnection != null) {
            mGattConnection.disconnect();
            mGattConnection.setConnectionCallback(null);
            mGattConnection = null;
        }

        if (mProvisioningController != null) {
            mProvisioningController.clear();
            mProvisioningController = null;
        }

        if (mNetworkingController != null) {
            mNetworkingController.clear();
            mNetworkingController = null;
        }

        if (mBindingController != null) {
            mBindingController.clear();
            mBindingController = null;
        }

        if (mFirmwareUpdatingController != null) {
            mFirmwareUpdatingController.clear();
            mFirmwareUpdatingController = null;
        }

        if (mDelayHandler != null) {
            mDelayHandler.removeCallbacksAndMessages(null);
            mDelayHandler = null;
        }

        if (handlerThread != null) {
            handlerThread.quitSafely();
            handlerThread = null;
        }

        mContext.unregisterReceiver(mBluetoothReceiver);
    }

    Mode getMode() {
        return actionMode;
    }


    void checkBluetoothState() {
        BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
        onBluetoothStateUpdate(adapter.getState());
    }

    private void onBluetoothStateUpdate(int state) {
        String stateInfo;
        switch (state) {
            case BluetoothAdapter.STATE_OFF:
                stateInfo = ("bluetooth disabled");
                if (mGattConnection != null) {
                    mGattConnection.disconnect();
                }
                break;
            case BluetoothAdapter.STATE_ON:
                stateInfo = ("bluetooth enabled");
                break;
            case BluetoothAdapter.STATE_TURNING_OFF:
                stateInfo = ("bluetooth turning off");
                break;
            case BluetoothAdapter.STATE_TURNING_ON:
                stateInfo = ("bluetooth turning on");
                break;
            default:
                stateInfo = "unknown";
                break;
        }
        onBluetoothEvent(state, stateInfo);
    }

    void setupMeshNetwork(MeshConfiguration configuration) {
        this.meshConfiguration = configuration;
        this.networkId = Encipher.k3(configuration.networkKey);
        this.networkIdentityKey = Encipher.generateIdentityKey(configuration.networkKey);
        this.networkBeaconKey = Encipher.generateBeaconKey(configuration.networkKey);
        mNetworkingController.setup(configuration);
//        mNetworkingController.proxyFilterInit(); //  for test
    }

    void removeDevice(int meshAddress) {
        this.meshConfiguration.deviceKeyMap.remove(meshAddress);
        mNetworkingController.removeDeviceKey(meshAddress);
        if (this.actionMode == Mode.MODE_AUTO_CONNECT) {
            validateAutoConnectTargets();
        }
    }

    private void initScanningController(HandlerThread handlerThread) {
        mBleScanner = new BleScanner(BleScanner.ScannerType.DEFAULT, handlerThread);
        mBleScanner.setScannerCallback(this.scanCallback);
    }

    private void initGattConnection(HandlerThread handlerThread) {
        mGattConnection = new GattConnection(mContext, handlerThread);
        mGattConnection.setConnectionCallback(connectionCallback);
    }

    private void initGattOtaController() {
        mGattOtaController = new GattOtaController(mGattConnection);
        mGattOtaController.setCallback(gattOtaCallback);
    }

    private void initProvisioningController(HandlerThread handlerThread) {
        mProvisioningController = new ProvisioningController(handlerThread);
        mProvisioningController.setProvisioningBridge(this);
    }

    private void initNetworkingController(HandlerThread handlerThread) {
        mNetworkingController = new NetworkingController(handlerThread);
        mNetworkingController.setNetworkingBridge(this);
    }

    private void initAccessController(HandlerThread handlerThread) {
        mBindingController = new BindingController(handlerThread);
        mBindingController.register(this);

        mFirmwareUpdatingController = new FirmwareUpdatingController(handlerThread);
        mFirmwareUpdatingController.register(this);

        mRemoteProvisioningController = new RemoteProvisioningController(handlerThread);
        mRemoteProvisioningController.register(this);

        mFastProvisioningController = new FastProvisioningController(handlerThread);
        mFastProvisioningController.register(this);
    }


    boolean isProxyLogin() {
        return isLogin;
    }

    int getDirectNodeAddress() {
        return directDeviceAddress;
    }

    public void idle(boolean disconnect) {
        log("---idle--- " + disconnect);
        mDelayHandler.removeCallbacksAndMessages(null);
        validateActionMode(Mode.MODE_IDLE);
        if (disconnect) {
            mGattConnection.disconnect();
        }
        stopScan();
    }

    public boolean isBluetoothEnabled() {
        return mBleScanner.isEnabled();
    }

    public void enableBluetooth() {
        mBleScanner.enableBluetooth();
    }

    public String getCurDeviceMac() {
        if (mGattConnection.isConnected()) {
            return mGattConnection.getMacAddress();
        }
        return null;
    }

    public void stopScan() {
        isScanning = false;
        mBleScanner.stopScan();
    }

    public void connect(final BluetoothDevice device) {
        stopScan();
        mGattConnection.connect(device);
    }

    public void disconnect() {
        mGattConnection.disconnect();
    }

    public void startScan(ScanParameters scanParameters) {
        if (!validateActionMode(Mode.MODE_SCAN)) return;
        mDelayHandler.removeCallbacksAndMessages(null);
        this.actionMode = Mode.MODE_SCAN;
        advDevices.clear();
        this.mActionParams = scanParameters;
        resetAction();
        if (!mGattConnection.disconnect()) {
            startScan();
        } else {
            log("waiting for disconnect...");
        }
    }

    private void startScan() {
        log("start scan: " + actionMode);
        LeScanFilter filter = (LeScanFilter) mActionParams.get(Parameters.SCAN_FILTERS);
        long timeout = mActionParams.getLong(Parameters.COMMON_SCAN_TIMEOUT, 10 * 1000);
        long spacing = mActionParams.getLong(Parameters.COMMON_SCAN_MIN_SPACING, 500);
        LeScanSetting scanSetting = new LeScanSetting(spacing, timeout);
        mBleScanner.startScan(filter, scanSetting);
    }


    boolean startProvisioning(ProvisioningParameters parameters) {
        log("start provision");
        if (!validateActionMode(Mode.MODE_PROVISION)) return false;
        mDelayHandler.removeCallbacksAndMessages(null);
        this.actionMode = Mode.MODE_PROVISION;
        this.mProvisioningController.setProvisioningBridge(this);
        this.mActionParams = parameters;
        resetAction();
        ProvisioningDevice provisioningDevice = (ProvisioningDevice) parameters.get(Parameters.ACTION_PROVISIONING_TARGET);
        rebuildProvisioningDevice(provisioningDevice);
        if (mGattConnection.disconnect()) {
            this.isDisconnectWaiting = true;
        } else {
            connect(provisioningDevice.getBluetoothDevice());
        }
        return true;
    }

    private void rebuildProvisioningDevice(ProvisioningDevice provisioningDevice) {
        provisioningDevice.setIvIndex(this.meshConfiguration.ivIndex);
        provisioningDevice.setNetworkKey(this.meshConfiguration.networkKey);
        provisioningDevice.setNetworkKeyIndex(this.meshConfiguration.netKeyIndex);
        provisioningDevice.setIvUpdateFlag((byte) 0);
        provisioningDevice.setKeyRefreshFlag((byte) 0);
    }

    void startBinding(BindingParameters bindingParameters) {
        if (!validateActionMode(Mode.MODE_BIND)) {
            log("binding currently");
            return;
        }
        mDelayHandler.removeCallbacksAndMessages(null);
        BindingDevice bindingDevice = (BindingDevice) bindingParameters.get(Parameters.ACTION_BINDING_TARGET);

        if (!MeshUtils.validUnicastAddress(bindingDevice.getMeshAddress())) {
            log("start bind fail: node address invalid", MeshLogger.LEVEL_WARN);
            onBindingFail("node address invalid");
            return;
        }

        this.mActionParams = bindingParameters;
        this.actionMode = Mode.MODE_BIND;
        this.reconnectTarget = null;
        resetAction();

        // if mac address
        int bindingTarget = bindingDevice.getMeshAddress();
        BindingBearer bindingBearer = bindingDevice.getBearer();
        if (mGattConnection.isProxyNodeConnected() && (directDeviceAddress == bindingTarget || bindingBearer == BindingBearer.Any || bindingBearer == BindingBearer.Flex)) {
            onConnectSuccess();
        } else {
            this.bindingStartTick = System.currentTimeMillis();
            if (mGattConnection.disconnect()) {
                // waiting for callback
                isDisconnectWaiting = true;
            } else {
                startScan();
            }
        }
    }

    void startRemoteProvision(RemoteProvisioningDevice remoteProvisioningDevice) {
        if (!validateActionMode(Mode.MODE_REMOTE_PROVISION)) {
            log("remote provisioning currently");
            return;
        }
        mDelayHandler.removeCallbacksAndMessages(null);
        if (!mGattConnection.isProxyNodeConnected()) {
            onRemoteProvisioningComplete(RemoteProvisioningEvent.EVENT_TYPE_REMOTE_PROVISIONING_FAIL,
                    remoteProvisioningDevice, "proxy node not connected");
            return;
        }
        this.actionMode = Mode.MODE_REMOTE_PROVISION;
        rebuildProvisioningDevice(remoteProvisioningDevice);
        mRemoteProvisioningController.begin(this.mProvisioningController, remoteProvisioningDevice);
    }

    void startFastProvision(FastProvisioningParameters parameters) {
        if (!validateActionMode(Mode.MODE_FAST_PROVISION)) {
            log("fast provisioning currently");
            return;
        }
        this.actionMode = Mode.MODE_FAST_PROVISION;
        mDelayHandler.removeCallbacksAndMessages(null);
        this.mActionParams = parameters;
        FastProvisioningConfiguration fastProvisioningConfiguration = (FastProvisioningConfiguration) parameters.get(Parameters.ACTION_FAST_PROVISION_CONFIG);
        mFastProvisioningController.init(fastProvisioningConfiguration, meshConfiguration);
        if (mGattConnection.isProxyNodeConnected()) {
            onConnectSuccess();
        } else {
            startScan();
        }
    }


    void autoConnect(AutoConnectParameters parameters) {
        if (!validateActionMode(Mode.MODE_AUTO_CONNECT)) {
            log("auto connect currently");
            return;
        }
        mDelayHandler.removeCallbacksAndMessages(null);
        this.mActionParams = parameters;
        log("auto connect");
        this.actionMode = Mode.MODE_AUTO_CONNECT;
        if (!validateAutoConnectTargets()) {
            return;
        }
        if (mGattConnection.isProxyNodeConnected()) {
            if (isLogin) {
                onAutoConnectSuccess();
            } else {
                proxyFilterInit();
            }
        } else {
            if (mGattConnection.disconnect()) {
                // waiting for disconnected
                isDisconnectWaiting = true;
            } else {
                startScan();
            }
        }
    }


    void startGattOta(GattOtaParameters otaParameters) {
        if (!validateActionMode(Mode.MODE_OTA)) {
            log("ota running currently");
            return;
        }
        mDelayHandler.removeCallbacksAndMessages(null);
        this.mActionParams = otaParameters;
        this.actionMode = Mode.MODE_OTA;
        this.isProxyReconnect = false;
        this.reconnectTarget = null;
        resetAction();
        ConnectionFilter filter = (ConnectionFilter) otaParameters.get(Parameters.ACTION_CONNECTION_FILTER);
        // && directDeviceAddress == meshAddress
        if (validateGattConnection(filter)) {
            onConnectSuccess();
        } else {
            startSafetyScan();
        }
    }

    void startGattConnection(GattConnectionParameters connectionParameters) {
        if (!validateActionMode(Mode.MODE_GATT_CONNECTION)) {
            log("gatt connection running currently");
        }

        mDelayHandler.removeCallbacksAndMessages(null);
        this.mActionParams = connectionParameters;
        this.actionMode = Mode.MODE_GATT_CONNECTION;
        this.isProxyReconnect = false;
        this.reconnectTarget = null;
        resetAction();
        ConnectionFilter filter = (ConnectionFilter) connectionParameters.get(Parameters.ACTION_CONNECTION_FILTER);
        if (validateGattConnection(filter)) {
            onConnectSuccess();
        } else {
            startSafetyScan();
        }
    }

    private boolean validateGattConnection(ConnectionFilter filter) {
        if (!mGattConnection.isProxyNodeConnected()) {
            return false;
        }

        if (filter.type == ConnectionFilter.TYPE_DEVICE_NAME) {
            String name = (String) filter.target;
            String connectName = mGattConnection.getDeviceName();
            return !TextUtils.isEmpty(connectName)
                    && !TextUtils.isEmpty(name)
                    && connectName.equals(name);
        } else if (filter.type == ConnectionFilter.TYPE_MAC_ADDRESS) {
            String mac = (String) filter.target;
            String connectMac = mGattConnection.getMacAddress();
            return !TextUtils.isEmpty(connectMac)
                    && !TextUtils.isEmpty(mac)
                    && connectMac.equalsIgnoreCase(mac);
        } else if (filter.type == ConnectionFilter.TYPE_MESH_ADDRESS) {
            return true;
        }
        return false;
    }

    boolean sendGattRequest(GattRequest request) {
        return mGattConnection.sendRequest(request);
    }

    int getMtu() {
        return mGattConnection.getMtu();
    }

    void startMeshOTA(MeshOtaParameters meshOtaParameters) {
        if (!validateActionMode(Mode.MODE_MESH_OTA)) {
            log("mesh updating running currently");
            return;
        }
        mDelayHandler.removeCallbacksAndMessages(null);
        this.mActionParams = meshOtaParameters;
        this.actionMode = Mode.MODE_MESH_OTA;
        resetAction();
        if (mGattConnection.isProxyNodeConnected()) {
            onConnectSuccess();
        } else {
            startSafetyScan();
        }
    }

    void stopMeshOta() {
        if (actionMode != Mode.MODE_MESH_OTA) {
            log("mesh updating stop: not running...");
            return;
        }
        mFirmwareUpdatingController.stop();
    }

    private void startSafetyScan() {
        if (mGattConnection.disconnect()) {
            // waiting for callback
            isDisconnectWaiting = true;
        } else {
            startScan();
        }
    }

    private boolean validateActionMode(Mode targetMode) {
        if (actionMode == targetMode) {
            return false;
        } else {
            /*if (actionMode == MODE_AUTO_CONNECT) {
                onMeshEvent(MeshEvent.EVENT_TYPE_DISCONNECTED);
            }*/
            if (actionMode == Mode.MODE_REMOTE_PROVISION) {
                mRemoteProvisioningController.clear();
            } else if (actionMode == Mode.MODE_PROVISION) {
                mProvisioningController.clear();
            } else if (actionMode == Mode.MODE_BIND) {
                mBindingController.clear();
            } else if (actionMode == Mode.MODE_MESH_OTA) {
                mFirmwareUpdatingController.clear();
            } else if (actionMode == Mode.MODE_FAST_PROVISION) {
                mFastProvisioningController.clear();
                isLogin = false;
            }
            actionMode = targetMode;
            return true;
        }
    }

    private void startGattOta() {
        byte[] otaFirmware = (byte[]) mActionParams.get(Parameters.ACTION_OTA_FIRMWARE);
        if (otaFirmware == null) {
            onOtaComplete(false, "firmware not found");
        } else {
            onActionStart();
            mGattOtaController.begin(otaFirmware);
        }
    }

    private boolean validateAutoConnectTargets() {

        if (meshConfiguration.deviceKeyMap.size() == 0) {
            idle(false);
            onMeshEvent(MeshEvent.EVENT_TYPE_MESH_EMPTY, "mesh empty");
            return false;
        }
//        AutoConnectFilterType filterType = (AutoConnectFilterType) mActionParams.get(Parameters.ACTION_AUTO_CONNECT_FILTER_TYPE);
        /*if (!filterType.isNetworkIdSupport) {
            if (meshConfiguration.deviceKeyMap.size() == 0) {
                idle(true);
                onMeshEvent(MeshEvent.EVENT_TYPE_MESH_EMPTY, "mesh empty");
                return false;
            }
        }*/
        return true;
    }

    public void onGattConnectionComplete(boolean success, String desc) {
        resetAction();
        this.idle(false);
        String evenType = success ?
                GattConnectionEvent.EVENT_TYPE_CONNECT_SUCCESS : GattConnectionEvent.EVENT_TYPE_CONNECT_FAIL;
        GattConnectionEvent event = new GattConnectionEvent(this, evenType, desc);
        onEventPrepared(event);
    }

    private void onBluetoothEvent(int state, String desc) {
        log("bluetooth event: " + state + " -- " + desc);
        BluetoothEvent event = new BluetoothEvent(this, BluetoothEvent.EVENT_TYPE_BLUETOOTH_STATE_CHANGE);
        event.setState(state);
        event.setDesc(desc);
        onEventPrepared(event);
    }

    private void onMeshEvent(String eventType, String desc) {
        MeshEvent meshEvent = new MeshEvent(this, eventType, desc);
        onEventPrepared(meshEvent);
    }

    private void onReliableMessageProcessEvent(String eventType, boolean success, int opcode, int rspMax, int rspCount, String desc) {
        ReliableMessageProcessEvent event = new ReliableMessageProcessEvent(this, eventType, success, opcode, rspMax, rspCount, desc);
        onEventPrepared(event);
    }

    private void onEventPrepared(Event event) {
        if (eventCallback != null) {
            eventCallback.onEventPrepared(event);
        }
    }

    private void onActionStart() {
        isActionStarted = true;
    }

    private void resetAction() {
        isActionStarted = false;
        connectRetry = 0;
    }

    /**
     * connected and filter set success
     */
    private void onAutoConnectSuccess() {
        onAutoConnectEvent(AutoConnectEvent.EVENT_TYPE_AUTO_CONNECT_LOGIN);
    }


    private void onAutoConnectEvent(String eventType) {
        AutoConnectEvent autoConnectEvent = new AutoConnectEvent(this, eventType, this.directDeviceAddress);
        onEventPrepared(autoConnectEvent);
    }

    public boolean getOnlineStatus() {
        return isLogin && mGattConnection.enableOnlineStatus();
    }

    public void resetDELState(boolean enable) {
        if (mNetworkingController != null) {
            mNetworkingController.enableDLE(enable);
        }
    }


    /**
     * send mesh message
     * include config message and common message
     */
    public boolean sendMeshMessage(MeshMessage meshMessage) {
        if (!isLogin) {
            log("not login when sending message");
            return false;
        }
        log("send mesh message: " + meshMessage.getClass().getSimpleName()
                + String.format(" opcode: 0x%04X -- dst: 0x%04X", meshMessage.getOpcode(), meshMessage.getDestinationAddress())
                + " isReliable: " + meshMessage.isReliable()
                + " retryCnt: " + meshMessage.getRetryCnt()
                + " rspMax: " + meshMessage.getResponseMax());
        final boolean sent = mNetworkingController.sendMeshMessage(meshMessage);
        if (meshMessage.isReliable()) {
            if (sent) {
                // sent
                onReliableMessageProcessEvent(ReliableMessageProcessEvent.EVENT_TYPE_MSG_PROCESSING,
                        false,
                        meshMessage.getOpcode(),
                        meshMessage.getResponseMax(),
                        0,
                        "mesh message processing");
            } else {
                // busy
                onReliableMessageProcessEvent(ReliableMessageProcessEvent.EVENT_TYPE_MSG_PROCESS_BUSY,
                        false,
                        meshMessage.getOpcode(),
                        meshMessage.getResponseMax(),
                        0,
                        "mesh message send fail: busy");
            }
        }
        return sent;
    }

    private void proxyFilterInit() {
        log("filter init start");
        mNetworkingController.proxyFilterInit();
    }

    /**
     * post online_status event
     */
    private void onOnlineStatusNotify(byte[] data) {
        OnlineStatusEvent onlineStatusEvent = new OnlineStatusEvent(this, data);
        onEventPrepared(onlineStatusEvent);
    }

    /**
     * gatt notification
     *
     * @param completePacket online_status raw data or mesh complete data
     */
    private void onGattNotification(byte[] completePacket) {
        if (completePacket.length > 1) {
            byte proxyPduType = (byte) (completePacket[0] & ProxyPDU.BITS_TYPE);

            byte[] payloadData = new byte[completePacket.length - 1];
            System.arraycopy(completePacket, 1, payloadData, 0, payloadData.length);

            switch (proxyPduType) {
                case ProxyPDU.TYPE_PROVISIONING_PDU:
                    // provision packet
                    if (mProvisioningController != null && isActionStarted) {
                        mProvisioningController.pushNotification(payloadData);
                    }
                    break;

                case ProxyPDU.TYPE_NETWORK_PDU:

                    // proxy packet
                    if (mNetworkingController != null) {
                        mNetworkingController.parseNetworkPdu(payloadData);
                    }
                    break;

                case ProxyPDU.TYPE_PROXY_CONFIGURATION:
                    if (mNetworkingController != null) {
                        mNetworkingController.parseProxyConfigurationPdu(payloadData);
                    }
                    break;


                case ProxyPDU.TYPE_MESH_BEACON:
                    if (mNetworkingController != null) {
                        mNetworkingController.parseMeshBeacon(payloadData, this.networkId, this.networkBeaconKey);
                    }
                    break;
            }
        }
    }

    private void onUnexpectedNotify(UUID serviceUUID, UUID characteristicUUID, byte[] data) {
        GattNotificationEvent event = new GattNotificationEvent(this, GattNotificationEvent.EVENT_TYPE_UNEXPECTED_NOTIFY,
                serviceUUID, characteristicUUID, data);
        onEventPrepared(event);
    }


    private void onConnectSuccess() {

        if (actionMode == Mode.MODE_PROVISION) {
            ProvisioningDevice provisioningDevice = (ProvisioningDevice) mActionParams.get(Parameters.ACTION_PROVISIONING_TARGET);
            onProvisionBegin(provisioningDevice, "provision begin");
            onActionStart();
            mProvisioningController.begin(provisioningDevice);
        } else if (actionMode == Mode.MODE_FAST_PROVISION) {
            onProxyLoginSuccess();
        } else {
            boolean isFilterInitNeeded
                    = mActionParams.getBool(Parameters.COMMON_PROXY_FILTER_INIT_NEEDED, false);

            if ((!isLogin && isFilterInitNeeded) || (directDeviceAddress == 0)) {
                proxyFilterInit();
            } else {
                // no need to init proxy filter
                onProxyLoginSuccess();
            }
        }
    }

    private void setNodeIdentity(int targetAddress) {
        log(String.format("set node for %04X", targetAddress));
        NodeIdentitySetMessage message = new NodeIdentitySetMessage(targetAddress);
        message.setNetKeyIndex(meshConfiguration.netKeyIndex);
        message.setIdentity(NodeIdentity.RUNNING.code);
        sendMeshMessage(message);
    }

    private void onProxyLoginSuccess() {
        isLogin = true;
        switch (actionMode) {
            case MODE_AUTO_CONNECT:
                this.onAutoConnectSuccess();
                break;

            case MODE_BIND:
                mDelayHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        onActionStart();
                        BindingDevice bindingDevice = (BindingDevice) mActionParams.get(Parameters.ACTION_BINDING_TARGET);
                        int netKeyIndex = bindingDevice.getNetKeyIndex();
                        if (netKeyIndex == -1) {
                            netKeyIndex = meshConfiguration.netKeyIndex;
                        }
                        mBindingController.begin(netKeyIndex,
                                meshConfiguration.appKeyMap.get(bindingDevice.getAppKeyIndex()), bindingDevice);
                    }
                }, 500);
                break;

            case MODE_OTA: {
                int address = checkConnectionTarget();
                if (address != -1) {
                    setNodeIdentity(address);
                } else {
                    startGattOta();
                }
                break;
            }


            case MODE_GATT_CONNECTION: {
                int address = checkConnectionTarget();
                if (address != -1) {
                    setNodeIdentity(address);
                } else {
                    onGattConnectionComplete(true, "connect success");
                }
                break;
            }


            case MODE_MESH_OTA:
                onActionStart();
                FirmwareUpdateConfiguration configuration = (FirmwareUpdateConfiguration) mActionParams.get(Parameters.ACTION_MESH_OTA_CONFIG);
                rebuildFirmwareUpdatingDevices(configuration);
                mFirmwareUpdatingController.begin(configuration);
                break;

            case MODE_FAST_PROVISION:
                onActionStart();
                mFastProvisioningController.begin();
                break;

        }
    }

    /**
     * @return if setNode identity needed
     */
    private int checkConnectionTarget() {
        final ConnectionFilter filter = (ConnectionFilter) mActionParams.get(Parameters.ACTION_CONNECTION_FILTER);
        if (filter.type != ConnectionFilter.TYPE_MESH_ADDRESS) {
            return -1;
        }
        int targetAdr = (int) filter.target;
        if (directDeviceAddress != targetAdr) {
            return targetAdr;
        }
        return -1;
    }

    /**
     * move direct device to last
     */
    private void rebuildFirmwareUpdatingDevices(FirmwareUpdateConfiguration configuration) {
        List<MeshUpdatingDevice> devices = configuration.getUpdatingDevices();
        Iterator<MeshUpdatingDevice> iterator = devices.iterator();
        MeshUpdatingDevice device;
        MeshUpdatingDevice directDevice = null;
        while (iterator.hasNext()) {
            device = iterator.next();
            if (device.getMeshAddress() == directDeviceAddress) {
                directDevice = device;
                iterator.remove();
            }
        }
        if (directDevice != null) {
            devices.add(directDevice);
            if (devices.size() == 1) {
                // update gatt connection when OTA start
//                mGattConnection.requestConnectionPriority(BluetoothGatt.CONNECTION_PRIORITY_HIGH);
                configuration.setSingleAndDirect(true);
                configuration.setDleLength(mNetworkingController.getSegmentAccessLength());
            } else {
                configuration.setSingleAndDirect(false);
            }

        }
    }


    private void onConnectionInterrupt() {
        String desc = "connection interrupt";
        switch (actionMode) {
            case MODE_PROVISION:
                ProvisioningDevice device = mProvisioningController.getProvisioningDevice();
                onProvisionFailed(device, desc);
                break;
            case MODE_BIND:
                onBindingFail(desc);
                break;

            case MODE_OTA:
                onOtaComplete(false, desc);
                break;

            case MODE_MESH_OTA:
                onMeshUpdatingComplete();
                onMeshUpdatingEvent(FirmwareUpdatingEvent.EVENT_TYPE_UPDATING_FAIL,
                        null,
                        desc, -1);
                break;

            case MODE_FAST_PROVISION:
                onFastProvisioningComplete(false, "connection interrupt");
                break;
        }
    }

    private void onConnectionFail() {
        String desc = "connect fail";
        switch (actionMode) {
            case MODE_PROVISION:
                ProvisioningDevice provisioningDevice = (ProvisioningDevice) mActionParams.get(Parameters.ACTION_PROVISIONING_TARGET);
                onProvisionFailed(provisioningDevice, "connect fail");
                break;
            case MODE_BIND:
                onBindingFail(desc);
                break;

            case MODE_OTA:
                onOtaComplete(false, desc);
                break;

            case MODE_MESH_OTA:
                onMeshUpdatingComplete();
                onMeshUpdatingEvent(FirmwareUpdatingEvent.EVENT_TYPE_UPDATING_FAIL,
                        null,
                        desc, -1);
                break;

            case MODE_FAST_PROVISION:
                onFastProvisioningComplete(false, "connect fail");
                break;

            case MODE_GATT_CONNECTION:
                onGattConnectionComplete(false, "connect fail");
                break;
        }
    }


    private void onGattDisconnected() {
        mDelayHandler.removeCallbacksAndMessages(null);
        onMeshEvent(MeshEvent.EVENT_TYPE_DISCONNECTED, "disconnected when: " + actionMode);
        mNetworkingController.clear();
        if (isDisconnectWaiting) {
            isDisconnectWaiting = false;
            connectRetry = -1;
        }
        isLogin = false;
        directDeviceAddress = 0;
        if (actionMode != Mode.MODE_IDLE) {
            mDelayHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    switch (actionMode) {
                        case MODE_SCAN:
                        case MODE_AUTO_CONNECT:
                            startScan();
                            break;

                        case MODE_PROVISION:
                        case MODE_BIND:
                        case MODE_OTA:
                        case MODE_GATT_CONNECTION:
                        case MODE_MESH_OTA:
                        case MODE_FAST_PROVISION:
                            if (isActionStarted) {
                                onConnectionInterrupt();
                            } else {
                                connectRetry++;
                                if (connectRetry >= MAX_CONNECT_RETRY) {
                                    // connect retry max
                                    onConnectionFail();
                                } else {
                                    // reconnect when provision and re-scan when other mode
                                    if (actionMode == Mode.MODE_PROVISION) {
                                        ProvisioningDevice provisioningDevice = (ProvisioningDevice) mActionParams.get(Parameters.ACTION_PROVISIONING_TARGET);
                                        log("provisioning connect retry: " + connectRetry);
                                        connect(provisioningDevice.getBluetoothDevice());
                                    } else if (actionMode == Mode.MODE_BIND
                                            || actionMode == Mode.MODE_GATT_CONNECTION
                                            || actionMode == Mode.MODE_OTA) {
                                        final BluetoothDevice device = reconnectTarget;
                                        if (device != null) {
                                            connect(device);
                                        } else {
                                            startScan();
                                        }
                                    } else {
                                        startScan();
                                    }
                                }
                            }
                            break;

                        case MODE_REMOTE_PROVISION:
                            RemoteProvisioningDevice device = mRemoteProvisioningController.getProvisioningDevice();
                            mRemoteProvisioningController.clear();
                            onRemoteProvisioningComplete(RemoteProvisioningEvent.EVENT_TYPE_REMOTE_PROVISIONING_FAIL, device, "connection interrupt");
                            break;
                    }
                }
            }, 500);
        }

    }

    private void onOtaComplete(boolean success, String desc) {
        resetAction();
        this.idle(false);
        String evenType = success ?
                GattOtaEvent.EVENT_TYPE_OTA_SUCCESS : GattOtaEvent.EVENT_TYPE_OTA_FAIL;
        onOtaEvent(evenType, 0, desc);
    }

    private void onOtaProgress(int progress) {
        onOtaEvent(GattOtaEvent.EVENT_TYPE_OTA_PROGRESS, progress, "ota progress update");
    }

    private void onOtaEvent(String eventType, int progress, String desc) {
//        int meshAddress = mActionParams.getInt(Parameters.ACTION_CONNECTION_MESH_ADDRESS, -1);
        GattOtaEvent otaEvent = new GattOtaEvent(this, eventType, progress, desc);
        onEventPrepared(otaEvent);
    }


    private GattConnection.ConnectionCallback connectionCallback = new GattConnection.ConnectionCallback() {
        @Override
        public void onConnected() { /* ignore */}

        @Override
        public void onDisconnected() {
            MeshController.this.onGattDisconnected();
        }

        @Override
        public void onServicesDiscovered(List<BluetoothGattService> services) {
            mDelayHandler.removeCallbacksAndMessages(null);

            mDelayHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    if (actionMode == Mode.MODE_PROVISION) {
                        mGattConnection.provisionInit();
                    } else {
                        mGattConnection.proxyInit();
                        mNetworkingController.checkSequenceNumber(networkId, networkBeaconKey);
                    }

                    mDelayHandler.postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            onConnectSuccess();
                        }
                    }, 100);
                }
            }, 500);
        }

        @Override
        public void onNotify(UUID serviceUUID, UUID charUUID, byte[] data) {
            if (charUUID.equals(UUIDInfo.CHARACTERISTIC_ONLINE_STATUS)) {
                log("online status encrypted data: " + Arrays.bytesToHexString(data, ":"));
                MeshLogger.d("online data: " + Arrays.bytesToHexString(data));
                MeshLogger.d("online key: " + Arrays.bytesToHexString(networkBeaconKey));
                byte[] decrypted = Encipher.decryptOnlineStatus(data, networkBeaconKey);
                MeshLogger.d("online dec: " + Arrays.bytesToHexString(decrypted));
                if (decrypted != null) {
                    log("online status decrypted data: " + Arrays.bytesToHexString(decrypted, ":"));
                    onOnlineStatusNotify(decrypted);
                } else {
                    log("online status decrypt err");
                }
            } else if (charUUID.equals(UUIDInfo.CHARACTERISTIC_PROXY_OUT) || charUUID.equals(UUIDInfo.CHARACTERISTIC_PB_OUT)) {
                onGattNotification(data);
            } else {
                onUnexpectedNotify(serviceUUID, charUUID, data);
            }
        }
    };

    private GattOtaController.GattOtaCallback gattOtaCallback = new GattOtaController.GattOtaCallback() {

        @Override
        public void onOtaStateChanged(int state) {
            switch (state) {
                case GattOtaController.OTA_STATE_FAILURE:
                    onOtaComplete(false, "gatt command fail");
                    break;

                case GattOtaController.OTA_STATE_SUCCESS:
                    onOtaComplete(true, "ota complete");
                    break;

                case GattOtaController.OTA_STATE_PROGRESS:
                    onOtaProgress(mGattOtaController.getOtaProgress());
                    break;
            }
        }
    };


    private void onDeviceFound(AdvertisingDevice device) {
        log("on device found: " + device.device.getAddress());
        if (advDevices.add(device)) {
            ScanEvent scanEvent = new ScanEvent(this, ScanEvent.EVENT_TYPE_DEVICE_FOUND, device);
            onEventPrepared(scanEvent);
        } else {
            log("Device already exist");
        }
    }

    private void onScanFail() {
//        idle(false);
        ScanEvent scanEvent = new ScanEvent(this, ScanEvent.EVENT_TYPE_SCAN_FAIL, null);
        onEventPrepared(scanEvent);
    }

    private void onScanTimeout(boolean anyDeviceFound) {
        log("scanning timeout: " + actionMode);
        switch (actionMode) {
            case MODE_SCAN:
                onScanTimeoutEvent();
                break;

            case MODE_BIND:
                onBindingFail("device not found when scanning");
                break;

            case MODE_AUTO_CONNECT:
                mDelayHandler.postDelayed(restartScanTask, 3 * 1000);
                break;

            case MODE_OTA:
                onOtaComplete(false, "ota fail: scan timeout");
                break;

            case MODE_GATT_CONNECTION:
                onGattConnectionComplete(false, "connection fail: scan timeout");
                break;

            case MODE_FAST_PROVISION:
                this.onFastProvisioningComplete(false, "no unprovisioned device found");
                break;
        }
        if (!anyDeviceFound && !ContextUtil.isLocationEnable(mContext)) {
            onLocationDisableWarning();
        }

    }

    private Runnable restartScanTask = new Runnable() {
        @Override
        public void run() {
            if (actionMode == Mode.MODE_AUTO_CONNECT)
                startScan();
        }
    };

    private void onScanTimeoutEvent() {
        idle(false);
        ScanEvent scanEvent = new ScanEvent(this, ScanEvent.EVENT_TYPE_SCAN_TIMEOUT, null);
        onEventPrepared(scanEvent);
    }

    private void onLocationDisableWarning() {
        ScanEvent scanEvent = new ScanEvent(this, ScanEvent.EVENT_TYPE_SCAN_LOCATION_WARNING, null);
        onEventPrepared(scanEvent);
    }

    /**
     * validate advertising device when auto connect {@link Mode#MODE_AUTO_CONNECT}
     *
     * @param scanRecord
     * @return
     */
    private boolean validateProxyAdv(byte[] scanRecord) {
        MeshScanRecord sr = MeshScanRecord.parseFromBytes(scanRecord);
        if (sr == null) return false;
        byte[] serviceData = sr.getServiceData(ParcelUuid.fromString(UUIDInfo.SERVICE_PROXY.toString()));
        if (serviceData != null && serviceData.length >= 9) {
            int type = serviceData[0];
            if (type == PROXY_ADV_TYPE_NETWORK_ID) {
                // validate network id matches
                final int networkIdLen = 8;
                byte[] advertisingNetworkId = new byte[networkIdLen];
                System.arraycopy(serviceData, 1, advertisingNetworkId, 0, networkIdLen);
                boolean networkIdCheck = Arrays.equals(networkId, advertisingNetworkId);
                log("check network id pass? " + networkIdCheck);
                return networkIdCheck;
            } else if (type == PROXY_ADV_TYPE_NODE_IDENTITY) {
                boolean nodeIdentityCheck = validateNodeIdentity(serviceData);
                log("check node identity pass? " + nodeIdentityCheck);
                return nodeIdentityCheck;
            }
        }
        return false;
    }


    private boolean validateNodeIdentity(byte[] serviceData) {
        if (this.networkIdentityKey == null || meshConfiguration.deviceKeyMap.size() == 0 || serviceData.length < 17)
            return false;

        // hash and random data length
        final int dataLen = 8;
        byte[] advHash;
        byte[] random;
        SparseArray<byte[]> deviceKeyMap = meshConfiguration.deviceKeyMap;
        int nodeAddress;
        for (int i = 0; i < deviceKeyMap.size(); i++) {
            nodeAddress = deviceKeyMap.keyAt(i);

            int index = 1;
            advHash = new byte[dataLen];
            System.arraycopy(serviceData, index, advHash, 0, dataLen);
            index += dataLen;

            random = new byte[dataLen];
            System.arraycopy(serviceData, index, random, 0, dataLen);
            byte[] hash = Encipher.generateNodeIdentityHash(networkIdentityKey, random, nodeAddress);
            if (Arrays.equals(advHash, hash)) {
                directDeviceAddress = nodeAddress;
                log("reset direct device address");
                return true;
            }
        }

        return false;
    }

    private boolean validateTargetNodeIdentity(byte[] scanRecord, int nodeAddress) {
        MeshScanRecord sr = MeshScanRecord.parseFromBytes(scanRecord);
        byte[] serviceData = sr.getServiceData(ParcelUuid.fromString(UUIDInfo.SERVICE_PROXY.toString()));
//        AutoConnectFilterType filterType = (AutoConnectFilterType) mActionParams.get(Parameters.ACTION_AUTO_CONNECT_FILTER_TYPE);
        if (serviceData != null && serviceData.length >= 9) {
            int type = serviceData[0];
            if (type == PROXY_ADV_TYPE_NODE_IDENTITY) {
                final int dataLen = 8;
                int index = 1;
                byte[] advHash = new byte[dataLen];
                System.arraycopy(serviceData, index, advHash, 0, dataLen);
                index += dataLen;

                byte[] random = new byte[dataLen];
                System.arraycopy(serviceData, index, random, 0, dataLen);
                byte[] hash = Encipher.generateNodeIdentityHash(networkIdentityKey, random, nodeAddress);
                return Arrays.equals(advHash, hash);
            }
        }
        return false;
    }


    private void onScanFilter(final BluetoothDevice device, final int rssi, final byte[] scanRecord) {
        synchronized (SCAN_LOCK) {
            if (!isScanning) return;
            boolean connectIntent = false;
            if (actionMode == Mode.MODE_AUTO_CONNECT) {
                connectIntent = validateProxyAdv(scanRecord);
            } else if (actionMode == Mode.MODE_OTA || actionMode == Mode.MODE_GATT_CONNECTION) {
                final ConnectionFilter filter = (ConnectionFilter) mActionParams.get(Parameters.ACTION_CONNECTION_FILTER);
                if (filter == null) {
                    return;
                }
                switch (filter.type) {
                    case ConnectionFilter.TYPE_MESH_ADDRESS:
                        int nodeAddress = (int) filter.target;
                        if (isProxyReconnect) {
                            connectIntent = validateTargetNodeIdentity(scanRecord, nodeAddress);
                            log("connection check node identity pass? " + connectIntent);
                        } else {
                            connectIntent = validateProxyAdv(scanRecord);
                        }
                        if (connectIntent && directDeviceAddress == nodeAddress) {
                            reconnectTarget = device;
                        }
                        break;

                    case ConnectionFilter.TYPE_MAC_ADDRESS:
                        String mac = (String) filter.target;
                        connectIntent = mac.equalsIgnoreCase(device.getAddress());
                        if (connectIntent) {
                            reconnectTarget = device;
                            MeshLogger.d("connect by mac address: " + mac);
                        }
                        break;

                    case ConnectionFilter.TYPE_DEVICE_NAME:
                        String name = (String) filter.target;
                        connectIntent = !TextUtils.isEmpty(device.getName()) && !TextUtils.isEmpty(name) && device.getName().equals(name);
                        if (connectIntent) {
                            reconnectTarget = device;
                            MeshLogger.d("connect by name: " + name);
                        }
                        break;
                }


            } else if (actionMode == Mode.MODE_BIND) {
                BindingDevice bindingDevice = (BindingDevice) mActionParams.get(Parameters.ACTION_BINDING_TARGET);

                if (bindingDevice.getBearer() == BindingBearer.GattOnly) {
                    connectIntent = validateTargetNodeIdentity(scanRecord, bindingDevice.getMeshAddress());
                    log("bind check node identity pass? " + connectIntent);
                } else if (bindingDevice.getBearer() == BindingBearer.Flex) {
                    if (System.currentTimeMillis() - bindingStartTick > BINDING_NODE_IDENTITY_SCAN_PERIOD) {
                        connectIntent = validateProxyAdv(scanRecord);
                    } else {
                        connectIntent = validateTargetNodeIdentity(scanRecord, bindingDevice.getMeshAddress());
                    }
                } else {
                    connectIntent = validateProxyAdv(scanRecord);
                }
                if (connectIntent && directDeviceAddress == bindingDevice.getMeshAddress()) {
                    reconnectTarget = device;
                }/*
                BindingDevice bindingDevice = (BindingDevice) mActionParams.get(Parameters.ACTION_BINDING_TARGET);
                if (bindingDevice.getBearer() == BindingBearer.GattOnly) {
                    connectIntent = validateTargetNodeIdentity(scanRecord, bindingDevice.getMeshAddress());
                    log("bind check node identity pass? " + connectIntent);
                } else {
                    connectIntent = validateProxyAdv(scanRecord);
                }*/
            } else if (actionMode == Mode.MODE_FAST_PROVISION) {
                connectIntent = true;
            } else if (actionMode == Mode.MODE_SCAN) {
                boolean single = mActionParams.getBool(Parameters.SCAN_SINGLE_MODE, false);
                if (single) {
                    stopScan();
                }
                onDeviceFound(new AdvertisingDevice(device, rssi, scanRecord));
            }

            if (connectIntent) {
                isScanning = false;
                connect(device);
            }
        }
    }

    private BleScanner.ScannerCallback scanCallback = new BleScanner.ScannerCallback() {
        @Override
        public void onLeScan(BluetoothDevice device, int rssi, byte[] scanRecord) {
            log("scan:" + device.getName() + " --mac: " + device.getAddress() + " --record: " + Arrays.bytesToHexString(scanRecord, ":"));
//            if (!device.getAddress().contains("FF:FF:BB:CC:DD")) return;
            onScanFilter(device, rssi, scanRecord);
        }

        @Override
        public void onScanFail(int errorCode) {
            isScanning = false;
            MeshController.this.onScanFail();
        }

        @Override
        public void onStartedScan() {
            isScanning = true;
        }

        @Override
        public void onStoppedScan() {

        }

        @Override
        public void onScanTimeout(boolean anyDeviceFound) {
            MeshController.this.onScanTimeout(anyDeviceFound);
        }
    };

    private void postProvisioningEvent(String eventType, ProvisioningDevice provisioningDevice, String desc) {

        ProvisioningEvent provisioningEvent = new ProvisioningEvent(this, eventType, provisioningDevice, desc);
        onEventPrepared(provisioningEvent);
    }

    private void onProvisionBegin(ProvisioningDevice device, String desc) {
        postProvisioningEvent(ProvisioningEvent.EVENT_TYPE_PROVISION_BEGIN, device, desc);
    }

    private void onProvisionFailed(ProvisioningDevice provisioningDevice, String desc) {
        log("provisioning failed: " + desc + " -- " + provisioningDevice.getUnicastAddress());
        onProvisionComplete();
        postProvisioningEvent(ProvisioningEvent.EVENT_TYPE_PROVISION_FAIL, provisioningDevice, desc);
    }

    private void onProvisionSuccess(ProvisioningDevice provisioningDevice, String desc) {
        onProvisionComplete();
        this.directDeviceAddress = provisioningDevice.getUnicastAddress();
        postProvisioningEvent(ProvisioningEvent.EVENT_TYPE_PROVISION_SUCCESS, provisioningDevice, desc);
    }

    private void onProvisionComplete() {
        isActionStarted = false;
        idle(false);
    }

    @Override
    public void onProvisionStateChanged(int state, String desc) {
        switch (state) {
            case ProvisioningController.STATE_COMPLETE:
                ProvisioningDevice device = mProvisioningController.getProvisioningDevice();
                updateDeviceKeyMap(device.getUnicastAddress(), device.getDeviceKey());
                onProvisionSuccess(device, desc);
                log("provision success");
                break;

            case ProvisioningController.STATE_FAILED:
                log("provision failed, " + desc);
                device = mProvisioningController.getProvisioningDevice();
                onProvisionFailed(device, desc);
                break;

            case ProvisioningController.STATE_CAPABILITY:
                log("on device capability received");
                break;
        }
    }


    @Override
    public void onCommandPrepared(byte type, byte[] data) {
        if (mGattConnection != null) {
            mGattConnection.sendMeshData(type, data);
        }

    }

    @Override
    public void onNetworkInfoUpdate(int sequenceNumber, int ivIndex) {

        this.meshConfiguration.sequenceNumber = sequenceNumber;
        if (actionMode != Mode.MODE_FAST_PROVISION) {
            this.meshConfiguration.ivIndex = ivIndex;
        }
        handleNetworkInfoUpdate(sequenceNumber, this.meshConfiguration.ivIndex);
    }

    public void handleNetworkInfoUpdate(int sequenceNumber, int ivIndex) {
        log("handleNetworkInfoUpdate : " + sequenceNumber + " -- " + ivIndex);

        NetworkInfoUpdateEvent networkInfoUpdateEvent = new NetworkInfoUpdateEvent(this,
                NetworkInfoUpdateEvent.EVENT_TYPE_NETWORKD_INFO_UPDATE,
                sequenceNumber, ivIndex);
        onEventPrepared(networkInfoUpdateEvent);
    }

    @Override
    public void onMeshMessageReceived(int src, int dst, int opcode, byte[] params) {
        log(String.format("mesh model message received: src -- 0x%04X | dst -- 0x%04X | opcode -- 0x%04X | params -- ", src, dst, opcode)
                + Arrays.bytesToHexString(params, "") + " | action mode -- " + actionMode);
        NotificationMessage notificationMessage = new NotificationMessage(src, dst, opcode, params);
        onInnerMessageHandle(notificationMessage);
        if (actionMode == Mode.MODE_BIND) {
            mBindingController.onMessageNotification(notificationMessage);
        } else if (actionMode == Mode.MODE_MESH_OTA) {

            mFirmwareUpdatingController.onMessageNotification(notificationMessage);
        } else if (actionMode == Mode.MODE_REMOTE_PROVISION) {
            mRemoteProvisioningController.onMessageNotification(notificationMessage);
        } else if (actionMode == Mode.MODE_FAST_PROVISION) {
            mFastProvisioningController.onMessageNotification(notificationMessage);
        }
        this.onMeshMessageNotification(notificationMessage);
    }


    @Override
    public void onProxyInitComplete(boolean success, int address) {
        log("filter init complete, success? " + success);
        if (success) {
            this.directDeviceAddress = address;
            onProxyLoginSuccess();
        } else {
            log("proxy init fail!", MeshLogger.LEVEL_WARN);
            mGattConnection.disconnect();
        }
    }

    @Override
    public void onHeartbeatMessageReceived(int src, int dst, byte[] data) {

    }

    @Override
    public void onReliableMessageComplete(boolean success, int opcode, int rspMax, int rspCount) {
        if (actionMode == Mode.MODE_BIND) {
            mBindingController.onBindingCommandComplete(success, opcode, rspMax, rspCount);
        } else if (actionMode == Mode.MODE_MESH_OTA) {
            mFirmwareUpdatingController.onUpdatingCommandComplete(success, opcode, rspMax, rspCount);
        } else if (actionMode == Mode.MODE_REMOTE_PROVISION) {
            mRemoteProvisioningController.onRemoteProvisioningCommandComplete(success, opcode, rspMax, rspCount);
        } else if (actionMode == Mode.MODE_FAST_PROVISION) {
            mFastProvisioningController.onFastProvisioningCommandComplete(success, opcode, rspMax, rspCount);
        }
        if (!success) {
            onInnerMessageFailed(opcode);
        }
        onReliableMessageProcessEvent(ReliableMessageProcessEvent.EVENT_TYPE_MSG_PROCESS_COMPLETE,
                success, opcode, rspMax, rspCount, "mesh message send complete");
    }

    @Override
    public void onSegmentMessageComplete(boolean success) {
        if (actionMode == Mode.MODE_MESH_OTA) {
            mFirmwareUpdatingController.onSegmentComplete(success);
        }
    }

    public void onInnerMessageFailed(int opcode) {
        if (opcode == Opcode.NODE_ID_SET.value) {
            if (actionMode == Mode.MODE_OTA) {
                onOtaComplete(false, "node identity set failed");
            } else if (actionMode == Mode.MODE_GATT_CONNECTION) {
                onGattConnectionComplete(false, "node identity set failed");
            }
        }
    }

    // , int src, int dst, int opcode, byte[] params
    private void onInnerMessageHandle(NotificationMessage notificationMessage) {
        int src = notificationMessage.getSrc();
        int opcode = notificationMessage.getOpcode();
        if (opcode == Opcode.NODE_RESET_STATUS.value) {
            /*
             * handle node reset message, update mesh configuration info
             */
            this.meshConfiguration.deviceKeyMap.delete(src);
            if (this.actionMode == Mode.MODE_AUTO_CONNECT) {
                validateAutoConnectTargets();
            }
        } else if (opcode == Opcode.NODE_ID_STATUS.value
                && (this.actionMode == Mode.MODE_OTA || this.actionMode == Mode.MODE_GATT_CONNECTION)) {
            // response of NodeIdentitySet
//            1 check if//
            NodeIdentityStatusMessage identityStatusMessage = (NodeIdentityStatusMessage) notificationMessage.getStatusMessage();
            ConnectionFilter filter = (ConnectionFilter) mActionParams.get(Parameters.ACTION_CONNECTION_FILTER);
            if (filter.type == ConnectionFilter.TYPE_MESH_ADDRESS) {
                int target = (int) filter.target;
                onNodeIdentityStatusMessageReceived(src, identityStatusMessage, target);
            }
        }
    }

    private void onNodeIdentityStatusMessageReceived(int src, NodeIdentityStatusMessage identityStatusMessage, int connectionTarget) {

//        int connectionTarget = mActionParams.getInt(Parameters.ACTION_CONNECTION_MESH_ADDRESS, -1);
        if (src == connectionTarget) {
            final int status = identityStatusMessage.getStatus();
            boolean success = false;
            String desc = "";

            if (status == ConfigStatus.SUCCESS.code) {
                final int identity = identityStatusMessage.getIdentity();
                if (identity == NodeIdentity.RUNNING.code) {
                    // reconnect target device
                    log("reconnect target device");
                    success = true;
                } else {
                    // node identity check error
                    desc = "node identity check error: " + identity;
                }
            } else {
                desc = "node identity status error: " + status;
            }

            if (success) {
                this.isProxyReconnect = true;
                startSafetyScan();
            } else {
                if (actionMode == Mode.MODE_OTA) {
                    onOtaComplete(false, desc);
                } else if (actionMode == Mode.MODE_GATT_CONNECTION) {
                    onGattConnectionComplete(false, desc);
                }
            }
        }
    }

    private void onMeshMessageNotification(NotificationMessage notificationMessage) {
        String eventType;
        StatusMessage statusMessage = notificationMessage.getStatusMessage();

        // if message can be parsed
        if (statusMessage == null) {
            eventType = StatusNotificationEvent.EVENT_TYPE_NOTIFICATION_MESSAGE_UNKNOWN;
        } else {
            eventType = statusMessage.getClass().getName();
        }

        log("mesh message notification: " + eventType);
        StatusNotificationEvent statusNotificationEvent = new StatusNotificationEvent(this,
                eventType,
                notificationMessage);
        onEventPrepared(statusNotificationEvent);
    }


    @Override
    public boolean onAccessMessagePrepared(MeshMessage meshMessage, int mode) {
        return this.sendMeshMessage(meshMessage);
    }

    /********************************************************
     * binding event
     ********************************************************/
    private void onBindingSuccess(String desc) {
        onBindingComplete();

        BindingDevice bindingDevice = mBindingController.getBindingDevice();
        BindingEvent bindingEvent = new BindingEvent(this, BindingEvent.EVENT_TYPE_BIND_SUCCESS, bindingDevice, desc);
        onEventPrepared(bindingEvent);
    }

    private void onBindingFail(String desc) {
        onBindingComplete();

        BindingDevice bindingDevice = (BindingDevice) mActionParams.get(Parameters.ACTION_BINDING_TARGET);
        BindingEvent bindingEvent = new BindingEvent(this, BindingEvent.EVENT_TYPE_BIND_FAIL, bindingDevice, desc);
        onEventPrepared(bindingEvent);
    }

    private void onBindingComplete() {
        mNetworkingController.clear();
        isActionStarted = false;
        idle(false);
    }

    private void onMeshUpdatingEvent(String eventType, MeshUpdatingDevice device, String desc, int progress) {
        FirmwareUpdatingEvent updatingEvent = new FirmwareUpdatingEvent(this, eventType);
        updatingEvent.setUpdatingDevice(device);
        updatingEvent.setDesc(desc);
        updatingEvent.setProgress(progress);
        onEventPrepared(updatingEvent);
    }

    private void onMeshUpdatingComplete() {
        isActionStarted = false;
        idle(false);
    }

    private void onRemoteProvisioningComplete(String eventType, RemoteProvisioningDevice device, String desc) {
        idle(false);
        RemoteProvisioningEvent event = new RemoteProvisioningEvent(this, eventType);
        event.setRemoteProvisioningDevice(device);
        event.setDesc(desc);
        onEventPrepared(event);
    }

    private void updateDeviceKeyMap(int address, byte[] deviceKey) {
        this.mNetworkingController.addDeviceKey(address, deviceKey);
        this.meshConfiguration.deviceKeyMap.put(address, deviceKey);
    }

    /**
     * access state changed
     */
    @Override
    public void onAccessStateChanged(int state, String desc, int mode, Object obj) {
        log("access state changed: " + state + " -- " + desc);
        if (actionMode == Mode.MODE_BIND && mode == AccessBridge.MODE_BINDING) {
            if (state == BindingController.STATE_FAIL) {
                onBindingFail(desc);
            } else if (state == BindingController.STATE_SUCCESS) {
                onBindingSuccess(desc);
            }
        } else if (actionMode == Mode.MODE_MESH_OTA && mode == AccessBridge.MODE_FIRMWARE_UPDATING) {
            switch (state) {
                case FirmwareUpdatingController.STATE_SUCCESS:
                    // at least one device success
                    onMeshUpdatingComplete();
                    onMeshUpdatingEvent(FirmwareUpdatingEvent.EVENT_TYPE_UPDATING_SUCCESS, null, desc, -1);
                    break;
                case FirmwareUpdatingController.STATE_FAIL:
                    onMeshUpdatingComplete();
                    onMeshUpdatingEvent(FirmwareUpdatingEvent.EVENT_TYPE_UPDATING_FAIL, null, desc, -1);
                    break;

                case FirmwareUpdatingController.STATE_DEVICE_FAIL:
                    onMeshUpdatingEvent(FirmwareUpdatingEvent.EVENT_TYPE_DEVICE_FAIL, (MeshUpdatingDevice) obj, desc, -1);
                    break;

                case FirmwareUpdatingController.STATE_DEVICE_SUCCESS:
                    onMeshUpdatingEvent(FirmwareUpdatingEvent.EVENT_TYPE_DEVICE_SUCCESS, (MeshUpdatingDevice) obj, desc, -1);
                    break;

                case FirmwareUpdatingController.STATE_PROGRESS:
                    int progress = (int) obj;
                    onMeshUpdatingEvent(FirmwareUpdatingEvent.EVENT_TYPE_UPDATING_PROGRESS, null, desc, progress);
                    break;

                case FirmwareUpdatingController.STATE_STOPPED:
                    onMeshUpdatingComplete();
                    onMeshUpdatingEvent(FirmwareUpdatingEvent.EVENT_TYPE_UPDATING_STOPPED, null, desc, -1);
                    break;

                case FirmwareUpdatingController.STATE_PREPARED:
                    onMeshUpdatingEvent(FirmwareUpdatingEvent.EVENT_TYPE_UPDATING_PREPARED, null, desc, -1);
                    break;
            }
        } else if (actionMode == Mode.MODE_REMOTE_PROVISION && mode == AccessBridge.MODE_REMOTE_PROVISIONING) {
            if (state == RemoteProvisioningController.STATE_PROVISION_FAIL) {
                onRemoteProvisioningComplete(RemoteProvisioningEvent.EVENT_TYPE_REMOTE_PROVISIONING_FAIL, (RemoteProvisioningDevice) obj, "remote provisioning fail");
            } else if (state == RemoteProvisioningController.STATE_PROVISION_SUCCESS) {
                RemoteProvisioningDevice device = (RemoteProvisioningDevice) obj;
                updateDeviceKeyMap(device.getUnicastAddress(), device.getDeviceKey());
                onRemoteProvisioningComplete(RemoteProvisioningEvent.EVENT_TYPE_REMOTE_PROVISIONING_SUCCESS, device, "remote provisioning success");
            }
        } else if (actionMode == Mode.MODE_FAST_PROVISION && mode == AccessBridge.MODE_FAST_PROVISION) {
            if (state == FastProvisioningController.STATE_RESET_NETWORK) {
                switchNetworking(false);
            } else if (state == FastProvisioningController.STATE_SUCCESS
                    || state == FastProvisioningController.STATE_FAIL) {
                onFastProvisioningComplete(state == FastProvisioningController.STATE_SUCCESS, desc);
            } else if (state == FastProvisioningController.STATE_SET_ADDR_SUCCESS) {
                FastProvisioningDevice device = (FastProvisioningDevice) obj;

                /*
                 * add device key into map
                 */
                updateDeviceKeyMap(device.getNewAddress(), device.getDeviceKey());


                /**
                 * post event
                 */
                String eventType = FastProvisioningEvent.EVENT_TYPE_FAST_PROVISIONING_ADDRESS_SET;
                FastProvisioningEvent event = new FastProvisioningEvent(this, eventType);
                event.setFastProvisioningDevice(device);
                onEventPrepared(event);
            }
        }
    }

    private void onFastProvisioningComplete(boolean success, String desc) {
        switchNetworking(true);
        this.isLogin = false;
        idle(false);
        resetAction();
        String eventType = success ? FastProvisioningEvent.EVENT_TYPE_FAST_PROVISIONING_SUCCESS :
                FastProvisioningEvent.EVENT_TYPE_FAST_PROVISIONING_FAIL;
        FastProvisioningEvent event = new FastProvisioningEvent(this, eventType);
        event.setDesc(desc);
        onEventPrepared(event);
    }

    /**
     * @param pvComplete if fast provision action complete
     *                   true: change networking config back
     *                   false: change networking config to default
     */
    public void switchNetworking(boolean pvComplete) {
        log("switch networking: " + pvComplete);
        if (pvComplete) {
            log("setup config back: " + this.meshConfiguration.ivIndex);
            mNetworkingController.setup(this.meshConfiguration);
        } else {
            FastProvisioningConfiguration configuration = mFastProvisioningController.getConfiguration();
            MeshConfiguration meshConfiguration = new MeshConfiguration();
            meshConfiguration.sequenceNumber = this.meshConfiguration.sequenceNumber;
            meshConfiguration.ivIndex = configuration.getIvIndex();
            meshConfiguration.deviceKeyMap = new SparseArray<>();
            meshConfiguration.netKeyIndex = configuration.getDefaultNetworkKeyIndex();
            meshConfiguration.networkKey = configuration.getDefaultNetworkKey();

            meshConfiguration.appKeyMap = new SparseArray<>();
            meshConfiguration.appKeyMap.put(
                    configuration.getDefaultAppKeyIndex(), configuration.getDefaultAppKey()
            );
            meshConfiguration.localAddress = this.meshConfiguration.localAddress;
            log("setup config fast: " + meshConfiguration.ivIndex);
            mNetworkingController.setup(meshConfiguration);
        }
    }


    public void setEventCallback(EventCallback callback) {
        this.eventCallback = callback;
    }

    interface EventCallback {
        void onEventPrepared(Event<String> event);
    }

    public enum Mode {
        /*
         * Action modes
         *
         *
         * MODE_IDLE: no scan and connect actions
         */
        MODE_IDLE,


        /**
         * scan
         */
        MODE_SCAN,

        /**
         * MODE_PROVISION: auto scan, connect, provision
         */
        MODE_PROVISION,

        /**
         * MODE_AUTO_CONNECT: auto scan, connect, get device state
         */
        MODE_AUTO_CONNECT,

        /**
         * MODE_OTA: auto scan, connect, start ota
         */
        MODE_OTA,

        /**
         * bind app key
         * connect target device without scan
         */
        MODE_BIND,

        /**
         * remote provision
         */
        MODE_REMOTE_PROVISION,

        /**
         * remote bind
         */
        MODE_REMOTE_BIND,

        /**
         * fast provision
         */
        MODE_FAST_PROVISION,

        /**
         * mesh firmware updating
         * (mesh ota)
         */
        MODE_MESH_OTA,

        /**
         * gatt connection
         */
        MODE_GATT_CONNECTION;
    }


    private void log(String logMessage) {
        log(logMessage, MeshLogger.LEVEL_DEBUG);
    }

    private void log(String logMessage, int level) {
        MeshLogger.log(logMessage, LOG_TAG, level);
    }

}
