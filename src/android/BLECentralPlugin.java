// (c) 2014-2016 Don Coleman
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package com.megster.cordova.ble.central;

import android.Manifest;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanSettings;
import android.location.LocationManager;
import android.os.ParcelUuid;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.Build;

import android.provider.Settings;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.apache.cordova.PermissionHelper;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

import java.util.*;

import static android.bluetooth.BluetoothDevice.DEVICE_TYPE_DUAL;
import static android.bluetooth.BluetoothDevice.DEVICE_TYPE_LE;

public class BLECentralPlugin extends CordovaPlugin {
    // permissions
    private static final String ACCESS_BACKGROUND_LOCATION = "android.permission.ACCESS_BACKGROUND_LOCATION"; // API 29
    private static final String BLUETOOTH_CONNECT =  "android.permission.BLUETOOTH_CONNECT" ; // API 31
    private static final String BLUETOOTH_SCAN =  "android.permission.BLUETOOTH_SCAN" ; // API 31

    // actions
    private static final String SCAN = "scan";
    private static final String START_SCAN = "startScan";
    private static final String STOP_SCAN = "stopScan";
    private static final String START_SCAN_WITH_OPTIONS = "startScanWithOptions";
    private static final String BONDED_DEVICES = "bondedDevices";
    private static final String LIST = "list";

    private static final String CONNECT = "connect";
    private static final String AUTOCONNECT = "autoConnect";
    private static final String DISCONNECT = "disconnect";

    private static final String QUEUE_CLEANUP = "queueCleanup";
    private static final String SET_PIN = "setPin";

    private static final String REQUEST_MTU = "requestMtu";
    private static final String REQUEST_CONNECTION_PRIORITY = "requestConnectionPriority";
    private final String CONNECTION_PRIORITY_HIGH = "high";
    private final String CONNECTION_PRIORITY_LOW = "low";
    private final String CONNECTION_PRIORITY_BALANCED = "balanced";
    private static final String REFRESH_DEVICE_CACHE = "refreshDeviceCache";

    private static final String READ = "read";
    private static final String WRITE = "write";
    private static final String WRITE_WITHOUT_RESPONSE = "writeWithoutResponse";

    private static final String READ_RSSI = "readRSSI";

    private static final String START_NOTIFICATION = "startNotification"; // register for characteristic notification
    private static final String STOP_NOTIFICATION = "stopNotification"; // remove characteristic notification

    private static final String IS_ENABLED = "isEnabled";
    private static final String IS_LOCATION_ENABLED = "isLocationEnabled";
    private static final String IS_CONNECTED  = "isConnected";

    private static final String SETTINGS = "showBluetoothSettings";
    private static final String ENABLE = "enable";

    private static final String START_STATE_NOTIFICATIONS = "startStateNotifications";
    private static final String STOP_STATE_NOTIFICATIONS = "stopStateNotifications";

    private static final String OPEN_L2CAP = "openL2Cap";
    private static final String CLOSE_L2CAP = "closeL2Cap";
    private static final String RECEIVE_L2CAP = "receiveDataL2Cap";
    private static final String WRITE_L2CAP = "writeL2Cap";

    private static final String START_LOCATION_STATE_NOTIFICATIONS = "startLocationStateNotifications";
    private static final String STOP_LOCATION_STATE_NOTIFICATIONS = "stopLocationStateNotifications";

    // callbacks
    CallbackContext discoverCallback;
    private CallbackContext enableBluetoothCallback;

    private static final String TAG = "BLEPlugin";
    private static final int REQUEST_ENABLE_BLUETOOTH = 1;

    BluetoothAdapter bluetoothAdapter;
    BluetoothLeScanner bluetoothLeScanner;

    // key is the MAC Address
    Map<String, Peripheral> peripherals = new LinkedHashMap<String, Peripheral>();

    // scan options
    boolean reportDuplicates = false;

    private static final int REQUEST_BLUETOOTH_SCAN = 2;
    private static final int REQUEST_BLUETOOTH_CONNECT = 3;
    private static final int REQUEST_BLUETOOTH_CONNECT_AUTO = 4;
    private static final int REQUEST_GET_BONDED_DEVICES = 5;
    private static final int REQUEST_LIST_KNOWN_DEVICES = 6;
    private static int COMPILE_SDK_VERSION = -1;
    private CallbackContext permissionCallback;
    private String deviceMacAddress;
    private UUID[] serviceUUIDs;
    private int scanSeconds;
    private ScanSettings scanSettings;

    // Bluetooth state notification
    CallbackContext stateCallback;
    BroadcastReceiver stateReceiver;
    Map<Integer, String> bluetoothStates = new Hashtable<Integer, String>() {{
        put(BluetoothAdapter.STATE_OFF, "off");
        put(BluetoothAdapter.STATE_TURNING_OFF, "turningOff");
        put(BluetoothAdapter.STATE_ON, "on");
        put(BluetoothAdapter.STATE_TURNING_ON, "turningOn");
    }};

    CallbackContext locationStateCallback;
    BroadcastReceiver locationStateReceiver;

    @Override
    protected void pluginInitialize() {
        if (COMPILE_SDK_VERSION == -1) {
            Context context = cordova.getContext();
            COMPILE_SDK_VERSION = context.getApplicationContext().getApplicationInfo().targetSdkVersion;
        }
    }

    @Override
    public void onDestroy() {
        removeStateListener();
        removeLocationStateListener();
        for(Peripheral peripheral : peripherals.values()) {
            peripheral.disconnect();
        }
    }

    @Override
    public void onReset() {
        removeStateListener();
        removeLocationStateListener();
        for(Peripheral peripheral : peripherals.values()) {
            peripheral.disconnect();
        }
    }

    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        LOG.d(TAG, "action = %s", action);

        if (bluetoothAdapter == null) {
            Activity activity = cordova.getActivity();
            boolean hardwareSupportsBLE = activity.getApplicationContext()
                    .getPackageManager()
                    .hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE) &&
                    Build.VERSION.SDK_INT >= 18;
            if (!hardwareSupportsBLE) {
                LOG.w(TAG, "This hardware does not support Bluetooth Low Energy.");
                callbackContext.error("This hardware does not support Bluetooth Low Energy.");
                return false;
            }
            BluetoothManager bluetoothManager = (BluetoothManager) activity.getSystemService(Context.BLUETOOTH_SERVICE);
            bluetoothAdapter = bluetoothManager.getAdapter();
            bluetoothLeScanner = bluetoothAdapter.getBluetoothLeScanner();
        }

        boolean validAction = true;

        if (action.equals(SCAN)) {

            UUID[] serviceUUIDs = parseServiceUUIDList(args.getJSONArray(0));
            int scanSeconds = args.getInt(1);
            resetScanOptions();
            findLowEnergyDevices(callbackContext, serviceUUIDs, scanSeconds);

        } else if (action.equals(START_SCAN)) {

            UUID[] serviceUUIDs = parseServiceUUIDList(args.getJSONArray(0));
            resetScanOptions();
            findLowEnergyDevices(callbackContext, serviceUUIDs, -1);

        } else if (action.equals(STOP_SCAN)) {

            bluetoothLeScanner.stopScan(leScanCallback);
            callbackContext.success();

        } else if (action.equals(LIST)) {

            listKnownDevices(callbackContext);

        } else if (action.equals(CONNECT)) {

            String macAddress = args.getString(0);
            connect(callbackContext, macAddress);

        } else if (action.equals(AUTOCONNECT)) {

            String macAddress = args.getString(0);
            autoConnect(callbackContext, macAddress);

        } else if (action.equals(DISCONNECT)) {

            String macAddress = args.getString(0);
            disconnect(callbackContext, macAddress);

        } else if (action.equals(QUEUE_CLEANUP)) {

            String macAddress = args.getString(0);
            queueCleanup(callbackContext, macAddress);

        } else if (action.equals(SET_PIN)) {

            String pin = args.getString(0);
            setPin(callbackContext, pin);

        } else if (action.equals(REQUEST_MTU)) {

            String macAddress = args.getString(0);
            int mtuValue = args.getInt(1);
            requestMtu(callbackContext, macAddress, mtuValue);

        } else if (action.equals(REQUEST_CONNECTION_PRIORITY)) {

            String macAddress = args.getString(0);
            String priority = args.getString(1);

            requestConnectionPriority(callbackContext, macAddress, priority);

        } else if (action.equals(REFRESH_DEVICE_CACHE)) {

            String macAddress = args.getString(0);
            long timeoutMillis = args.getLong(1);

            refreshDeviceCache(callbackContext, macAddress, timeoutMillis);

        } else if (action.equals(READ)) {

            String macAddress = args.getString(0);
            UUID serviceUUID = uuidFromString(args.getString(1));
            UUID characteristicUUID = uuidFromString(args.getString(2));
            read(callbackContext, macAddress, serviceUUID, characteristicUUID);

        } else if (action.equals(READ_RSSI)) {

            String macAddress = args.getString(0);
            readRSSI(callbackContext, macAddress);

        } else if (action.equals(WRITE)) {

            String macAddress = args.getString(0);
            UUID serviceUUID = uuidFromString(args.getString(1));
            UUID characteristicUUID = uuidFromString(args.getString(2));
            byte[] data = args.getArrayBuffer(3);
            int type = BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT;
            write(callbackContext, macAddress, serviceUUID, characteristicUUID, data, type);

        } else if (action.equals(WRITE_WITHOUT_RESPONSE)) {

            String macAddress = args.getString(0);
            UUID serviceUUID = uuidFromString(args.getString(1));
            UUID characteristicUUID = uuidFromString(args.getString(2));
            byte[] data = args.getArrayBuffer(3);
            int type = BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE;
            write(callbackContext, macAddress, serviceUUID, characteristicUUID, data, type);

        } else if (action.equals(START_NOTIFICATION)) {

            String macAddress = args.getString(0);
            UUID serviceUUID = uuidFromString(args.getString(1));
            UUID characteristicUUID = uuidFromString(args.getString(2));
            registerNotifyCallback(callbackContext, macAddress, serviceUUID, characteristicUUID);

        } else if (action.equals(STOP_NOTIFICATION)) {

            String macAddress = args.getString(0);
            UUID serviceUUID = uuidFromString(args.getString(1));
            UUID characteristicUUID = uuidFromString(args.getString(2));
            removeNotifyCallback(callbackContext, macAddress, serviceUUID, characteristicUUID);

        } else if (action.equals(IS_ENABLED)) {

            if (bluetoothAdapter.isEnabled()) {
                callbackContext.success();
            } else {
                callbackContext.error("Bluetooth is disabled.");
            }

        } else if (action.equals(IS_LOCATION_ENABLED)) {

            if (locationServicesEnabled()) {
                callbackContext.success();
            } else {
                callbackContext.error("Location services disabled.");
            }

        } else if (action.equals(IS_CONNECTED)) {

            String macAddress = args.getString(0);

            if (peripherals.containsKey(macAddress) && peripherals.get(macAddress).isConnected()) {
                callbackContext.success();
            } else {
                callbackContext.error("Not connected");
            }

        } else if (action.equals(SETTINGS)) {

            Intent intent = new Intent(Settings.ACTION_BLUETOOTH_SETTINGS);
            cordova.getActivity().startActivity(intent);
            callbackContext.success();

        } else if (action.equals(ENABLE)) {

            enableBluetoothCallback = callbackContext;
            Intent intent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            cordova.startActivityForResult(this, intent, REQUEST_ENABLE_BLUETOOTH);

        } else if (action.equals(START_STATE_NOTIFICATIONS)) {

            if (this.stateCallback != null) {
                callbackContext.error("State callback already registered.");
            } else {
                this.stateCallback = callbackContext;
                addStateListener();
                sendBluetoothStateChange(bluetoothAdapter.getState());
            }

        } else if (action.equals(STOP_STATE_NOTIFICATIONS)) {

            if (this.stateCallback != null) {
                // Clear callback in JavaScript without actually calling it
                PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
                result.setKeepCallback(false);
                this.stateCallback.sendPluginResult(result);
                this.stateCallback = null;
            }
            removeStateListener();
            callbackContext.success();

        } else if (action.equals(START_LOCATION_STATE_NOTIFICATIONS)) {

            if (this.locationStateCallback != null) {
                callbackContext.error("Location state callback already registered.");
            } else {
                this.locationStateCallback = callbackContext;
                addLocationStateListener();
                sendLocationStateChange();
            }

        } else if (action.equals(STOP_LOCATION_STATE_NOTIFICATIONS)) {

            if (this.locationStateCallback != null) {
                // Clear callback in JavaScript without actually calling it
                PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
                result.setKeepCallback(false);
                this.locationStateCallback.sendPluginResult(result);
                this.locationStateCallback = null;
            }
            removeLocationStateListener();
            callbackContext.success();

        } else if (action.equals(START_SCAN_WITH_OPTIONS)) {
            UUID[] serviceUUIDs = parseServiceUUIDList(args.getJSONArray(0));
            JSONObject options = args.getJSONObject(1);

            resetScanOptions();
            this.reportDuplicates = options.optBoolean("reportDuplicates", false);
            ScanSettings.Builder scanSettings = new ScanSettings.Builder();

            switch (options.optString("scanMode", "")) {
                case "":
                    break;
                case "lowPower":
                    scanSettings.setScanMode( ScanSettings.SCAN_MODE_LOW_POWER );
                    break;
                case "balanced":
                    scanSettings.setScanMode( ScanSettings.SCAN_MODE_BALANCED );
                    break;
                case "lowLatency":
                    scanSettings.setScanMode( ScanSettings.SCAN_MODE_LOW_LATENCY );
                    break;
                case "opportunistic":
                    scanSettings.setScanMode( ScanSettings.SCAN_MODE_OPPORTUNISTIC );
                    break;
                default:
                    callbackContext.error("scanMode must be one of: lowPower | balanced | lowLatency | opportunistic");
                    validAction = false;
                    break;
            }

            switch (options.optString("callbackType", "")) {
                case "":
                    break;
                case "all":
                    scanSettings.setCallbackType( ScanSettings.CALLBACK_TYPE_ALL_MATCHES );
                    break;
                case "first":
                    scanSettings.setCallbackType( ScanSettings.CALLBACK_TYPE_FIRST_MATCH );
                    break;
                case "lost":
                    scanSettings.setCallbackType( ScanSettings.CALLBACK_TYPE_MATCH_LOST );
                    break;
                default:
                    callbackContext.error("callbackType must be one of: all | first | lost");
                    validAction = false;
                    break;
            }

            switch (options.optString("matchMode", "")) {
                case "":
                    break;
                case "aggressive":
                    scanSettings.setMatchMode( ScanSettings.MATCH_MODE_AGGRESSIVE );
                    break;
                case "sticky":
                    scanSettings.setMatchMode( ScanSettings.MATCH_MODE_STICKY );
                    break;
                default:
                    callbackContext.error("matchMode must be one of: aggressive | sticky");
                    validAction = false;
                    break;
            }

            switch (options.optString("numOfMatches", "")) {
                case "":
                    break;
                case "one":
                    scanSettings.setNumOfMatches( ScanSettings.MATCH_NUM_ONE_ADVERTISEMENT );
                    break;
                case "few":
                    scanSettings.setNumOfMatches( ScanSettings.MATCH_NUM_FEW_ADVERTISEMENT );
                    break;
                case "max":
                    scanSettings.setNumOfMatches( ScanSettings.MATCH_NUM_MAX_ADVERTISEMENT );
                    break;
                default:
                    callbackContext.error("numOfMatches must be one of: one | few | max");
                    validAction = false;
                    break;
            }

            switch (options.optString("phy", "")) {
                case "":
                    break;
                case "1m":
                    scanSettings.setPhy( BluetoothDevice.PHY_LE_1M );
                    break;
                case "coded":
                    scanSettings.setPhy( BluetoothDevice.PHY_LE_CODED );
                    break;
                case "all":
                    scanSettings.setPhy( ScanSettings.PHY_LE_ALL_SUPPORTED );
                    break;
                default:
                    callbackContext.error("phy must be one of: 1m | coded | all");
                    validAction = false;
                    break;
            }

            if (validAction) {
                String LEGACY = "legacy";
                if (!options.isNull(LEGACY))
                    scanSettings.setLegacy( options.getBoolean(LEGACY) );

                long reportDelay = options.optLong("reportDelay", -1 );
                if (reportDelay >= 0L)
                    scanSettings.setReportDelay( reportDelay );

                findLowEnergyDevices(callbackContext, serviceUUIDs, -1, scanSettings.build() );
            }

        } else if (action.equals(BONDED_DEVICES)) {

            getBondedDevices(callbackContext);

        } else if (action.equals(OPEN_L2CAP)) {

            String macAddress = args.getString(0);
            int psm = args.getInt(1);
            JSONObject options = args.optJSONObject(2);
            boolean secureChannel = options != null && options.optBoolean("secureChannel", false);
            connectL2cap(callbackContext, macAddress, psm, secureChannel);

        } else if (action.equals(CLOSE_L2CAP)) {

            String macAddress = args.getString(0);
            int psm = args.getInt(1);
            disconnectL2cap(callbackContext, macAddress, psm);

        } else if (action.equals(WRITE_L2CAP)) {

            String macAddress = args.getString(0);
            int psm = args.getInt(1);
            byte[] data = args.getArrayBuffer(2);
            writeL2cap(callbackContext, macAddress, psm, data);

        } else if (action.equals(RECEIVE_L2CAP)) {

            String macAddress = args.getString(0);
            int psm = args.getInt(1);
            registerL2CapReceiver(callbackContext, macAddress, psm);

        } else {

            validAction = false;

        }

        return validAction;
    }

    private void getBondedDevices(CallbackContext callbackContext) {
        if (COMPILE_SDK_VERSION >= 31 && Build.VERSION.SDK_INT >= 31) { // (API 31) Build.VERSION_CODE.S
            if (!PermissionHelper.hasPermission(this, BLUETOOTH_CONNECT)) {
                permissionCallback = callbackContext;
                PermissionHelper.requestPermission(this, REQUEST_GET_BONDED_DEVICES, BLUETOOTH_CONNECT);
                return;
            }
        }

        JSONArray bonded = new JSONArray();
        Set<BluetoothDevice> bondedDevices =  bluetoothAdapter.getBondedDevices();

        for (BluetoothDevice device : bondedDevices) {
            device.getBondState();
            int type = device.getType();

            // just low energy devices (filters out classic and unknown devices)
            if (type == DEVICE_TYPE_LE || type == DEVICE_TYPE_DUAL) {
                Peripheral p = new Peripheral(device);
                bonded.put(p.asJSONObject());
            }
        }

        callbackContext.success(bonded);
    }

    private UUID[] parseServiceUUIDList(JSONArray jsonArray) throws JSONException {
        List<UUID> serviceUUIDs = new ArrayList<UUID>();

        for(int i = 0; i < jsonArray.length(); i++){
            String uuidString = jsonArray.getString(i);
            serviceUUIDs.add(uuidFromString(uuidString));
        }

        return serviceUUIDs.toArray(new UUID[jsonArray.length()]);
    }

    private void onBluetoothStateChange(Intent intent) {
        final String action = intent.getAction();

        if (action.equals(BluetoothAdapter.ACTION_STATE_CHANGED)) {
            final int state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR);
            sendBluetoothStateChange(state);
            if (state == BluetoothAdapter.STATE_OFF) {
               // #894 When Bluetooth is physically turned off the whole process might die, so the normal
                // onConnectionStateChange callbacks won't be invoked
                
                BluetoothManager bluetoothManager = (BluetoothManager) cordova.getActivity().getSystemService(Context.BLUETOOTH_SERVICE);
                for(Peripheral peripheral : peripherals.values()) {
                    if (!peripheral.isConnected()) continue;
                    
                    int connectedState = bluetoothManager.getConnectionState(peripheral.getDevice(), BluetoothProfile.GATT);
                    if (connectedState == BluetoothProfile.STATE_DISCONNECTED) {
                        peripheral.peripheralDisconnected("Bluetooth Disabled");
                    }
                }
            }
        }
    }

    private void sendBluetoothStateChange(int state) {
        if (this.stateCallback != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, this.bluetoothStates.get(state));
            result.setKeepCallback(true);
            this.stateCallback.sendPluginResult(result);
        }
    }

    private void addStateListener() {
        if (this.stateReceiver == null) {
            this.stateReceiver = new BroadcastReceiver() {
                @Override
                public void onReceive(Context context, Intent intent) {
                    onBluetoothStateChange(intent);
                }
            };
        }

        try {
            IntentFilter intentFilter = new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED);
            webView.getContext().registerReceiver(this.stateReceiver, intentFilter);
        } catch (Exception e) {
            LOG.e(TAG, "Error registering state receiver: " + e.getMessage(), e);
        }
    }

    private void removeStateListener() {
        if (this.stateReceiver != null) {
            try {
                webView.getContext().unregisterReceiver(this.stateReceiver);
            } catch (Exception e) {
                LOG.e(TAG, "Error unregistering state receiver: " + e.getMessage(), e);
            }
        }
        this.stateCallback = null;
        this.stateReceiver = null;
    }

    private void onLocationStateChange(Intent intent) {
        final String action = intent.getAction();

        if (LocationManager.PROVIDERS_CHANGED_ACTION.equals(action)) {
            sendLocationStateChange();
        }
    }

    private void sendLocationStateChange() {
        if (this.locationStateCallback != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, locationServicesEnabled());
            result.setKeepCallback(true);
            this.locationStateCallback.sendPluginResult(result);
        }
    }

    private void addLocationStateListener() {
        if (this.locationStateReceiver == null) {
            this.locationStateReceiver = new BroadcastReceiver() {
                @Override
                public void onReceive(Context context, Intent intent) {
                    onLocationStateChange(intent);
                }
            };
        }

        try {
            IntentFilter intentFilter = new IntentFilter(LocationManager.PROVIDERS_CHANGED_ACTION);
            intentFilter.addAction(Intent.ACTION_PROVIDER_CHANGED);
            webView.getContext().registerReceiver(this.locationStateReceiver, intentFilter);
        } catch (Exception e) {
            LOG.e(TAG, "Error registering location state receiver: " + e.getMessage(), e);
        }
    }

    private void removeLocationStateListener() {
        if (this.locationStateReceiver != null) {
            try {
                webView.getContext().unregisterReceiver(this.locationStateReceiver);
            } catch (Exception e) {
                LOG.e(TAG, "Error unregistering location state receiver: " + e.getMessage(), e);
            }
        }
        this.locationStateCallback = null;
        this.locationStateReceiver = null;
    }

    private void connect(CallbackContext callbackContext, String macAddress) {
        if (COMPILE_SDK_VERSION >= 31 && Build.VERSION.SDK_INT >= 31) { // (API 31) Build.VERSION_CODE.S
            if (!PermissionHelper.hasPermission(this, BLUETOOTH_CONNECT)) {
                permissionCallback = callbackContext;
                deviceMacAddress = macAddress;
                PermissionHelper.requestPermission(this, REQUEST_BLUETOOTH_CONNECT, BLUETOOTH_CONNECT);
                return;
            }
        }

        if (!peripherals.containsKey(macAddress) && BLECentralPlugin.this.bluetoothAdapter.checkBluetoothAddress(macAddress)) {
            BluetoothDevice device = BLECentralPlugin.this.bluetoothAdapter.getRemoteDevice(macAddress);
            Peripheral peripheral = new Peripheral(device);
            peripherals.put(macAddress, peripheral);
        }

        Peripheral peripheral = peripherals.get(macAddress);
        if (peripheral != null) {
            // #894: BLE adapter state listener required so disconnect can be fired on BLE disabled
            addStateListener();
            peripheral.connect(callbackContext, cordova.getActivity(), false);
        } else {
            callbackContext.error("Peripheral " + macAddress + " not found.");
        }

    }

    private void autoConnect(CallbackContext callbackContext, String macAddress) {

        if (COMPILE_SDK_VERSION >= 31 && Build.VERSION.SDK_INT >= 31) { // (API 31) Build.VERSION_CODE.S
            if (!PermissionHelper.hasPermission(this, BLUETOOTH_CONNECT)) {
                permissionCallback = callbackContext;
                deviceMacAddress = macAddress;
                PermissionHelper.requestPermission(this, REQUEST_BLUETOOTH_CONNECT_AUTO, BLUETOOTH_CONNECT);
                return;
            }
        }

        Peripheral peripheral = peripherals.get(macAddress);

        // allow auto-connect to connect to devices without scanning
        if (peripheral == null) {
            if (BluetoothAdapter.checkBluetoothAddress(macAddress)) {
                BluetoothDevice device = bluetoothAdapter.getRemoteDevice(macAddress);
                peripheral = new Peripheral(device);
                peripherals.put(device.getAddress(), peripheral);
            } else {
                callbackContext.error(macAddress + " is not a valid MAC address.");
                return;
            }
        }

        // #894: BLE adapter state listener required so disconnect can be fired on BLE disabled
        addStateListener();
        peripheral.connect(callbackContext, cordova.getActivity(), true);

    }

    private void disconnect(CallbackContext callbackContext, String macAddress) {

        Peripheral peripheral = peripherals.get(macAddress);
        if (peripheral != null) {
            peripheral.disconnect();
            callbackContext.success();
        } else {
            String message = "Peripheral " + macAddress + " not found.";
            LOG.w(TAG, message);
            callbackContext.error(message);
        }

    }

    private void queueCleanup(CallbackContext callbackContext, String macAddress) {
        Peripheral peripheral = peripherals.get(macAddress);
        if (peripheral != null) {
            peripheral.queueCleanup();
        }
        callbackContext.success();
    }

    BroadcastReceiver broadCastReceiver;
    private void setPin(CallbackContext callbackContext, final String pin) {

        try {
            if (broadCastReceiver != null) {
                webView.getContext().unregisterReceiver(broadCastReceiver);
            }

            broadCastReceiver = new BroadcastReceiver() {
                @Override
                public void onReceive(Context context, Intent intent) {
                    String action = intent.getAction();

                    if (BluetoothDevice.ACTION_PAIRING_REQUEST.equals(action)) {
                        BluetoothDevice bluetoothDevice = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                        int type = intent.getIntExtra(BluetoothDevice.EXTRA_PAIRING_VARIANT, BluetoothDevice.ERROR);

                        if (type == BluetoothDevice.PAIRING_VARIANT_PIN) {
                            bluetoothDevice.setPin(pin.getBytes());
                            abortBroadcast();
                        }
                    }
                }
            };

            IntentFilter intentFilter = new IntentFilter(BluetoothDevice.ACTION_PAIRING_REQUEST);
            intentFilter.setPriority(IntentFilter.SYSTEM_HIGH_PRIORITY);
            webView.getContext().registerReceiver(broadCastReceiver, intentFilter);

            callbackContext.success("OK");
        } catch (Exception e) {
            callbackContext.error("Error: " + e.getMessage());
            return;
        }
    }

    private void requestMtu(CallbackContext callbackContext, String macAddress, int mtuValue) {
        Peripheral peripheral = peripherals.get(macAddress);
        if (peripheral != null) {
            peripheral.requestMtu(callbackContext, mtuValue);
        } else {
            String message = "Peripheral " + macAddress + " not found.";
            LOG.w(TAG, message);
            callbackContext.error(message);
        }
    }

    private void requestConnectionPriority(CallbackContext callbackContext, String macAddress, String priority) {
        Peripheral peripheral = peripherals.get(macAddress);

        if (peripheral == null) {
            callbackContext.error("Peripheral " + macAddress + " not found.");
            return;
        }

        if (!peripheral.isConnected()) {
            callbackContext.error("Peripheral " + macAddress + " is not connected.");
            return;
        }

        int androidPriority = BluetoothGatt.CONNECTION_PRIORITY_BALANCED;
        if (priority.equals(CONNECTION_PRIORITY_LOW)) {
            androidPriority = BluetoothGatt.CONNECTION_PRIORITY_LOW_POWER;
        } else if (priority.equals(CONNECTION_PRIORITY_BALANCED)) {
            androidPriority = BluetoothGatt.CONNECTION_PRIORITY_BALANCED;
        } else if (priority.equals(CONNECTION_PRIORITY_HIGH)) {
            androidPriority = BluetoothGatt.CONNECTION_PRIORITY_HIGH;
        }
        peripheral.requestConnectionPriority(androidPriority);
        callbackContext.success();
    }

    private void refreshDeviceCache(CallbackContext callbackContext, String macAddress, long timeoutMillis) {

        Peripheral peripheral = peripherals.get(macAddress);

        if (peripheral != null) {
            peripheral.refreshDeviceCache(callbackContext, timeoutMillis);
        } else {
            String message = "Peripheral " + macAddress + " not found.";
            LOG.w(TAG, message);
            callbackContext.error(message);
        }
    }

    private void read(CallbackContext callbackContext, String macAddress, UUID serviceUUID, UUID characteristicUUID) {

        Peripheral peripheral = peripherals.get(macAddress);

        if (peripheral == null) {
            callbackContext.error("Peripheral " + macAddress + " not found.");
            return;
        }

        if (!peripheral.isConnected()) {
            callbackContext.error("Peripheral " + macAddress + " is not connected.");
            return;
        }

        //peripheral.readCharacteristic(callbackContext, serviceUUID, characteristicUUID);
        peripheral.queueRead(callbackContext, serviceUUID, characteristicUUID);

    }

    private void readRSSI(CallbackContext callbackContext, String macAddress) {

        Peripheral peripheral = peripherals.get(macAddress);

        if (peripheral == null) {
            callbackContext.error("Peripheral " + macAddress + " not found.");
            return;
        }

        if (!peripheral.isConnected()) {
            callbackContext.error("Peripheral " + macAddress + " is not connected.");
            return;
        }
        peripheral.queueReadRSSI(callbackContext);
    }

    private void write(CallbackContext callbackContext, String macAddress, UUID serviceUUID, UUID characteristicUUID,
                       byte[] data, int writeType) {

        Peripheral peripheral = peripherals.get(macAddress);

        if (peripheral == null) {
            callbackContext.error("Peripheral " + macAddress + " not found.");
            return;
        }

        if (!peripheral.isConnected()) {
            callbackContext.error("Peripheral " + macAddress + " is not connected.");
            return;
        }

        //peripheral.writeCharacteristic(callbackContext, serviceUUID, characteristicUUID, data, writeType);
        peripheral.queueWrite(callbackContext, serviceUUID, characteristicUUID, data, writeType);

    }

    private void connectL2cap(CallbackContext callbackContext, String macAddress, int psm, boolean secureChannel) {
        Peripheral peripheral = peripherals.get(macAddress);
        if (peripheral == null) {
            callbackContext.error("Peripheral " + macAddress + " not found.");
            return;
        }

        if (!peripheral.isConnected()) {
            callbackContext.error("Peripheral " + macAddress + " is not connected.");
            return;
        }

        peripheral.connectL2cap(callbackContext, psm, secureChannel);
    }

    private void disconnectL2cap(CallbackContext callbackContext, String macAddress, int psm) {

        Peripheral peripheral = peripherals.get(macAddress);
        if (peripheral != null) {
            peripheral.disconnectL2Cap(callbackContext, psm);
        }

        callbackContext.success();

    }

    private void writeL2cap(CallbackContext callbackContext, String macAddress, int psm, byte[] data) {

        Peripheral peripheral = peripherals.get(macAddress);

        if (peripheral == null) {
            callbackContext.error("Peripheral " + macAddress + " not found.");
            return;
        }

        if (!peripheral.isL2capConnected(psm)) {
            callbackContext.error("Peripheral " + macAddress + " L2Cap is not connected.");
            return;
        }

        cordova.getThreadPool().execute(() -> peripheral.writeL2CapChannel(callbackContext, psm, data));

    }

    private void registerL2CapReceiver(CallbackContext callbackContext, String macAddress, int psm) {

        Peripheral peripheral = peripherals.get(macAddress);

        if (peripheral == null) {
            callbackContext.error("Peripheral " + macAddress + " not found.");
            return;
        }

        peripheral.registerL2CapReceiver(callbackContext, psm);

    }

    private void registerNotifyCallback(CallbackContext callbackContext, String macAddress, UUID serviceUUID, UUID characteristicUUID) {

        Peripheral peripheral = peripherals.get(macAddress);
        if (peripheral != null) {

            if (!peripheral.isConnected()) {
                callbackContext.error("Peripheral " + macAddress + " is not connected.");
                return;
            }

            //peripheral.setOnDataCallback(serviceUUID, characteristicUUID, callbackContext);
            peripheral.queueRegisterNotifyCallback(callbackContext, serviceUUID, characteristicUUID);

        } else {

            callbackContext.error("Peripheral " + macAddress + " not found");

        }

    }

    private void removeNotifyCallback(CallbackContext callbackContext, String macAddress, UUID serviceUUID, UUID characteristicUUID) {

        Peripheral peripheral = peripherals.get(macAddress);
        if (peripheral != null) {

            if (!peripheral.isConnected()) {
                callbackContext.error("Peripheral " + macAddress + " is not connected.");
                return;
            }

            peripheral.queueRemoveNotifyCallback(callbackContext, serviceUUID, characteristicUUID);

        } else {

            callbackContext.error("Peripheral " + macAddress + " not found");

        }

    }

    private ScanCallback leScanCallback = new ScanCallback() {
        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            LOG.w(TAG, "Scan Result");
            super.onScanResult(callbackType, result);
            BluetoothDevice device = result.getDevice();
            String address = device.getAddress();
            boolean alreadyReported = peripherals.containsKey(address) && !peripherals.get(address).isUnscanned();

            if (!alreadyReported) {

                Peripheral peripheral = new Peripheral(device, result.getRssi(), result.getScanRecord().getBytes());
                peripherals.put(device.getAddress(), peripheral);

                if (discoverCallback != null) {
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, peripheral.asJSONObject());
                    pluginResult.setKeepCallback(true);
                    discoverCallback.sendPluginResult(pluginResult);
                }

            } else {
                Peripheral peripheral = peripherals.get(address);
                if (peripheral != null) {
                    peripheral.update(result.getRssi(), result.getScanRecord().getBytes());
                    if (reportDuplicates && discoverCallback != null) {
                        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, peripheral.asJSONObject());
                        pluginResult.setKeepCallback(true);
                        discoverCallback.sendPluginResult(pluginResult);
                    }
                }
            }
        }

        @Override
        public void onBatchScanResults(List<ScanResult> results) {
            super.onBatchScanResults(results);
        }

        @Override
        public void onScanFailed(int errorCode) {
            super.onScanFailed(errorCode);
        }
    };


    private void findLowEnergyDevices(CallbackContext callbackContext, UUID[] serviceUUIDs, int scanSeconds) {
        findLowEnergyDevices( callbackContext, serviceUUIDs, scanSeconds, new ScanSettings.Builder().build() );
    }

    private void findLowEnergyDevices(CallbackContext callbackContext, UUID[] serviceUUIDs, int scanSeconds, ScanSettings scanSettings) {

        if (!locationServicesEnabled() && Build.VERSION.SDK_INT < 31) {
            LOG.w(TAG, "Location Services are disabled");
        }

        List<String> missingPermissions = new ArrayList<String>();
        if (COMPILE_SDK_VERSION >= 31 && Build.VERSION.SDK_INT >= 31) { // (API 31) Build.VERSION_CODE.S
            if (!PermissionHelper.hasPermission(this, BLUETOOTH_SCAN)) {
                missingPermissions.add(BLUETOOTH_SCAN);
            }
            if (!PermissionHelper.hasPermission(this, BLUETOOTH_CONNECT)) {
                missingPermissions.add(BLUETOOTH_CONNECT);
            }
        } else if (COMPILE_SDK_VERSION >= 29 && Build.VERSION.SDK_INT >= 29) { // (API 29) Build.VERSION_CODES.Q
            if (!PermissionHelper.hasPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)) {
                missingPermissions.add(Manifest.permission.ACCESS_FINE_LOCATION);
            }

            String accessBackgroundLocation = this.preferences.getString("accessBackgroundLocation", "false");
            if (accessBackgroundLocation == "true" &&  !PermissionHelper.hasPermission(this, ACCESS_BACKGROUND_LOCATION)) {
                LOG.w(TAG, "ACCESS_BACKGROUND_LOCATION is being requested");
                missingPermissions.add(ACCESS_BACKGROUND_LOCATION);
            }
        } else {
            if(!PermissionHelper.hasPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION)) {
                missingPermissions.add(Manifest.permission.ACCESS_COARSE_LOCATION);
            }
        }

        if (missingPermissions.size() > 0) {
            // save info so we can call this method again after permissions are granted
            permissionCallback = callbackContext;
            this.serviceUUIDs = serviceUUIDs;
            this.scanSeconds = scanSeconds;
            this.scanSettings = scanSettings;
            PermissionHelper.requestPermissions(this, REQUEST_BLUETOOTH_SCAN, missingPermissions.toArray(new String[0]));
            return;
        }


        // return error if already scanning
        if (bluetoothAdapter.isDiscovering()) {
            LOG.w(TAG, "Tried to start scan while already running.");
            callbackContext.error("Tried to start scan while already running.");
            return;
        }

        // clear non-connected cached peripherals
        for(Iterator<Map.Entry<String, Peripheral>> iterator = peripherals.entrySet().iterator(); iterator.hasNext(); ) {
            Map.Entry<String, Peripheral> entry = iterator.next();
            Peripheral device = entry.getValue();
            boolean connecting = device.isConnecting();
            if (connecting){
                LOG.d(TAG, "Not removing connecting device: " + device.getDevice().getAddress());
            }
            if(!entry.getValue().isConnected() && !connecting) {
                iterator.remove();
            }
        }

        discoverCallback = callbackContext;
        bluetoothLeScanner = bluetoothAdapter.getBluetoothLeScanner();
        List<ScanFilter> filters = new ArrayList<ScanFilter>();
        if (serviceUUIDs != null && serviceUUIDs.length > 0) {
            for (UUID uuid : serviceUUIDs) {
                ScanFilter filter = new ScanFilter.Builder().setServiceUuid(
                        new ParcelUuid(uuid)).build();
                filters.add(filter);
            }
        }
        bluetoothLeScanner.startScan(filters, scanSettings, leScanCallback);

        if (scanSeconds > 0) {
            Handler handler = new Handler();
            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    LOG.d(TAG, "Stopping Scan");
                    bluetoothLeScanner.stopScan(leScanCallback);
                }
            }, scanSeconds * 1000);
        }

        PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
    }

    private boolean locationServicesEnabled() {
        int locationMode = 0;
        try {
            locationMode = Settings.Secure.getInt(cordova.getActivity().getContentResolver(), Settings.Secure.LOCATION_MODE);
        } catch (Settings.SettingNotFoundException e) {
            LOG.e(TAG, "Location Mode Setting Not Found", e);
        }
        return (locationMode > 0);
    }

    private void listKnownDevices(CallbackContext callbackContext) {
        if (COMPILE_SDK_VERSION >= 31 && Build.VERSION.SDK_INT >= 31) { // (API 31) Build.VERSION_CODE.S
            if (!PermissionHelper.hasPermission(this, BLUETOOTH_CONNECT)) {
                permissionCallback = callbackContext;
                PermissionHelper.requestPermission(this, REQUEST_LIST_KNOWN_DEVICES, BLUETOOTH_CONNECT);
                return;
            }
        }

        JSONArray json = new JSONArray();

        // do we care about consistent order? will peripherals.values() be in order?
        for (Map.Entry<String, Peripheral> entry : peripherals.entrySet()) {
            Peripheral peripheral = entry.getValue();
            if (!peripheral.isUnscanned()) {
                json.put(peripheral.asJSONObject());
            }
        }

        PluginResult result = new PluginResult(PluginResult.Status.OK, json);
        callbackContext.sendPluginResult(result);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {

        if (requestCode == REQUEST_ENABLE_BLUETOOTH) {

            if (resultCode == Activity.RESULT_OK) {
                LOG.d(TAG, "User enabled Bluetooth");
                if (enableBluetoothCallback != null) {
                    enableBluetoothCallback.success();
                }
            } else {
                LOG.d(TAG, "User did *NOT* enable Bluetooth");
                if (enableBluetoothCallback != null) {
                    enableBluetoothCallback.error("User did not enable Bluetooth");
                }
            }

            enableBluetoothCallback = null;
        }
    }

    /* @Override */
    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) {
        //Android 12 (API 31) and higher
        // Users MUST accept BLUETOOTH_SCAN and BLUETOOTH_CONNECT
        // Android 10 (API 29) up to Android 11 (API 30)
        // Users MUST accept ACCESS_FINE_LOCATION
        // Users may accept or reject ACCESS_BACKGROUND_LOCATION
        // Android 9 (API 28) and lower
        // Users MUST accept ACCESS_COARSE_LOCATION
        for (int i = 0; i < permissions.length; i++) {

            if (permissions[i].equals(Manifest.permission.ACCESS_FINE_LOCATION) && grantResults[i] == PackageManager.PERMISSION_DENIED) {
                LOG.d(TAG, "User *rejected* Fine Location Access");
                this.permissionCallback.error("Location permission not granted.");
                return;
            } else if (permissions[i].equals(Manifest.permission.ACCESS_COARSE_LOCATION) && grantResults[i] == PackageManager.PERMISSION_DENIED) {
                LOG.d(TAG, "User *rejected* Coarse Location Access");
                this.permissionCallback.error("Location permission not granted.");
                return;
            } else if (permissions[i].equals(BLUETOOTH_SCAN) && grantResults[i] == PackageManager.PERMISSION_DENIED) {
                LOG.d(TAG, "User *rejected* Bluetooth_Scan Access");
                this.permissionCallback.error("Bluetooth scan permission not granted.");
                return;
            } else if (permissions[i].equals(BLUETOOTH_CONNECT) && grantResults[i] == PackageManager.PERMISSION_DENIED) {
                LOG.d(TAG, "User *rejected* Bluetooth_Connect Access");
                this.permissionCallback.error("Bluetooth Connect permission not granted.");
                return;
            }
        }

        switch(requestCode) {
            case REQUEST_BLUETOOTH_SCAN:
                LOG.d(TAG, "User granted Bluetooth Scan Access");
                findLowEnergyDevices(permissionCallback, serviceUUIDs, scanSeconds, scanSettings);
                this.permissionCallback = null;
                this.serviceUUIDs = null;
                this.scanSeconds = -1;
                this.scanSettings = null;
                break;

            case REQUEST_BLUETOOTH_CONNECT:
                LOG.d(TAG, "User granted Bluetooth Connect Access");
                connect(permissionCallback, deviceMacAddress);
                this.permissionCallback = null;
                this.deviceMacAddress = null;
                break;

            case REQUEST_BLUETOOTH_CONNECT_AUTO:
                LOG.d(TAG, "User granted Bluetooth Auto Connect Access");
                autoConnect(permissionCallback, deviceMacAddress);
                this.permissionCallback = null;
                this.deviceMacAddress = null;
                break;

            case REQUEST_GET_BONDED_DEVICES:
                LOG.d(TAG, "User granted permissions for bonded devices");
                getBondedDevices(permissionCallback);
                this.permissionCallback = null;
                break;

            case REQUEST_LIST_KNOWN_DEVICES:
                LOG.d(TAG, "User granted permissions for list known devices");
                listKnownDevices(permissionCallback);
                this.permissionCallback = null;
                break;
        }
    }

    private UUID uuidFromString(String uuid) {
        return UUIDHelper.uuidFromString(uuid);
    }

    /**
     * Reset the BLE scanning options
     */
    private void resetScanOptions() {
        this.reportDuplicates = false;
    }

}
