package com.megster.cordova.ble.central.model;

import android.bluetooth.BluetoothDevice;
import android.graphics.Color;

import com.telink.ble.mesh.util.LogInfo;
import com.telink.ble.mesh.util.MeshLogger;

import java.util.ArrayList;
import java.util.List;

public class NetworkingDevice {

    public NetworkingState state = NetworkingState.IDLE;

    public BluetoothDevice bluetoothDevice;

    /**
     * oob info in scan record
     */
    public int oobInfo;

    public NodeInfo nodeInfo;

    public List<LogInfo> logs = new ArrayList<>();

    public boolean logExpand = false;

    public static final String TAG_SCAN = "scan";

    public static final String TAG_PROVISION = "provision";

    public static final String TAG_BIND = "bind";

    public static final String TAG_PUB_SET = "pub-set";

    public NetworkingDevice(NodeInfo nodeInfo) {
        this.nodeInfo = nodeInfo;
    }

    public int getStateColor() {
        return Color.YELLOW;
    }

    public boolean isProcessing() {
        return state == NetworkingState.PROVISIONING || state == NetworkingState.BINDING || state == NetworkingState.TIME_PUB_SETTING;
    }

    public void addLog(String tag, String log) {
        logs.add(new LogInfo(tag, log, MeshLogger.LEVEL_DEBUG));
    }
}
