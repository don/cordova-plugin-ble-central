// (c) 2104 Don Coleman
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

import android.app.Activity;

import android.bluetooth.*;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.*;
import java.util.concurrent.ConcurrentLinkedQueue;

/**
 * Peripheral wraps the BluetoothDevice and provides methods to convert to JSON.
 */
public class Peripheral extends BluetoothGattCallback {

    // 0x2902 org.bluetooth.descriptor.gatt.client_characteristic_configuration.xml
    public final static UUID CLIENT_CHARACTERISTIC_CONFIGURATION_UUID = UUID.fromString("00002902-0000-1000-8000-00805F9B34FB");

    private BluetoothDevice device;
    private byte[] advertisingData;
    private int advertisingRSSI;
    private boolean connected = false;
    private ConcurrentLinkedQueue<BLECommand> commandQueue = new ConcurrentLinkedQueue<BLECommand>();
    private boolean bleProcessing;

    BluetoothGatt gatt;

    private CallbackContext connectCallback;

    // Note these callback maps are probably useless since we are queuing commands instead of Android
    // ServiceUUID | CharacteristicUUID | InstanceId is the key
    private Map<String, CallbackContext> readCallbacks = new HashMap<String, CallbackContext>();
    private Map<String, CallbackContext> notificationCallbacks = new HashMap<String, CallbackContext>();

    // don't need HashMaps since Android can only read or write one at a time :(
    private CallbackContext writeCallback;

    public Peripheral(BluetoothDevice device, int advertisingRSSI, byte[] scanRecord) {

        this.device = device;
        this.advertisingRSSI = advertisingRSSI;
        this.advertisingData = scanRecord;

    }

    public void connect(CallbackContext callbackContext, Activity activity) {
        BluetoothDevice device = getDevice();
        connectCallback = callbackContext;
        gatt = device.connectGatt(activity, false, this);

        PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
    }

    public void disconnect() {
        connectCallback = null;
        connected = false;
        if (gatt != null) {
            gatt.close();
            gatt = null;
        }
    }

    public JSONObject asJSONObject()  {

        JSONObject json = new JSONObject();

        try {
            json.put("name", device.getName());
            json.put("id", device.getAddress()); // mac address
            json.put("advertising", byteArrayToJSON(advertisingData));
            // TODO real RSSI if we have it, else
            json.put("rssi", advertisingRSSI);
        } catch (JSONException e) { // this shouldn't happen
            e.printStackTrace();
        }

        return json;
    }

    static JSONArray byteArrayToJSON(byte[] bytes) {
        JSONArray json = new JSONArray();
        for (byte aByte : bytes) {
            json.put(aByte);
        }
        return json;
    }

    public boolean isConnected() {
        return connected;
    }

    public BluetoothDevice getDevice() {
        return device;
    }

    @Override
    public void onServicesDiscovered(BluetoothGatt gatt, int status) {
        super.onServicesDiscovered(gatt, status);

        if (status == BluetoothGatt.GATT_SUCCESS) {
            PluginResult result = new PluginResult(PluginResult.Status.OK);
            result.setKeepCallback(true);
            connectCallback.sendPluginResult(result);
        } else {
            connectCallback.error("Service discovery failed. status = " + status);
            disconnect();
        }
    }

    @Override
    public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {

        this.gatt = gatt;

        if (newState == BluetoothGatt.STATE_CONNECTED) {

            connected = true;
            gatt.discoverServices();

        } else {

            connected = false;
            if (connectCallback != null) {
                connectCallback.error("Disconnected");
                connectCallback = null;
            }
        }

    }

    @Override
    public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {

        super.onCharacteristicChanged(gatt, characteristic);

        CallbackContext callback = notificationCallbacks.get(generateHashKey(characteristic));

        if (callback != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, characteristic.getValue());
            result.setKeepCallback(true);
            callback.sendPluginResult(result);
        }
    }

    @Override
    public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
        super.onCharacteristicRead(gatt, characteristic, status);

        CallbackContext callback = readCallbacks.remove(generateHashKey(characteristic));

        if (callback != null) {

            if (status == BluetoothGatt.GATT_SUCCESS) {
                callback.success(characteristic.getValue());
            } else {
                callback.error("Error reading " + characteristic.getUuid() + " status=" + status);
            }

        }

        commandCompleted();
    }

    @Override
    public void onCharacteristicWrite(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
        super.onCharacteristicWrite(gatt, characteristic, status);
        // we're supposed to compare the peripheral's value to our desired value and confirm it is correct
    }

    @Override
    public void onDescriptorRead(BluetoothGatt gatt, BluetoothGattDescriptor descriptor, int status) {
        super.onDescriptorRead(gatt, descriptor, status);
    }

    @Override
    public void onDescriptorWrite(BluetoothGatt gatt, BluetoothGattDescriptor descriptor, int status) {
        super.onDescriptorWrite(gatt, descriptor, status);

//        if (status == BluetoothGatt.GATT_SUCCESS) {
//            writeCallback.success();
//        } else {
//            writeCallback.error(status);
//        }

        commandCompleted();
    }

    @Override
    public void onReliableWriteCompleted(BluetoothGatt gatt, int status) {
        super.onReliableWriteCompleted(gatt, status);

        if (status == BluetoothGatt.GATT_SUCCESS) {
            writeCallback.success();
        } else {
            writeCallback.error(status);
        }

        writeCallback = null;
        commandCompleted();
    }

    public void updateRssi(int rssi) {
        advertisingRSSI = rssi;
    }

    // This seems way too complicated
    private void registerNotifyCallback(CallbackContext callbackContext, UUID serviceUUID, UUID characteristicUUID) {

        boolean success = false;

        try {
            if (gatt == null) {
                callbackContext.error("BluetoothGatt is null");
                return;
            }

            BluetoothGattService service = gatt.getService(serviceUUID);
            BluetoothGattCharacteristic characteristic = service.getCharacteristic(characteristicUUID);
            String key = generateHashKey(serviceUUID, characteristic);

            if (characteristic != null) {

                notificationCallbacks.put(key, callbackContext);

                if (gatt.setCharacteristicNotification(characteristic, true)) {

                    // TODO why doesn't setCharacteristicNotification write the descriptor?
                    BluetoothGattDescriptor descriptor = characteristic.getDescriptor(CLIENT_CHARACTERISTIC_CONFIGURATION_UUID);
                    if (descriptor != null) {
                        descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);

                        if (gatt.writeDescriptor(descriptor)) {
                            // unnecessary
                            PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
                            result.setKeepCallback(true);
                            callbackContext.sendPluginResult(result);

                            success = true;
                        } else {
                            callbackContext.error("Failed to set client characteristic notification for " + characteristicUUID);
                        }

                    } else {
                        callbackContext.error("Set notification failed for " + characteristicUUID);
                    }

                } else {
                    callbackContext.error("Failed to register notification for " + characteristicUUID);
                }

            } else {
                callbackContext.error("Characteristic " + characteristicUUID + " not found");
            }
        } finally {
            if (!success) {
                commandCompleted();
            }
        }
    }

    private void readCharacteristic(CallbackContext callbackContext, UUID serviceUUID, UUID characteristicUUID) {

        boolean success = false;

        try {
            if (gatt == null) {
                callbackContext.error("BluetoothGatt is null");
                return;
            }

            BluetoothGattService service = gatt.getService(serviceUUID);
            BluetoothGattCharacteristic characteristic = service.getCharacteristic(characteristicUUID);
            String key = generateHashKey(serviceUUID, characteristic);

            if (characteristic == null) {
                callbackContext.error("Characteristic " + characteristicUUID + " not found.");
            } else {

                readCallbacks.put(key, callbackContext);

                if (gatt.readCharacteristic(characteristic)) {

                    success = true;

                } else {

                    readCallbacks.remove(key);
                    callbackContext.error("Read failed");

                }
            }
        } finally {

            if (!success) {
                commandCompleted();
            }
        }

    }

    // BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE
    private void writeNoResponse(CallbackContext callbackContext, UUID serviceUUID, UUID characteristicUUID, byte[] data) {

        try {

            if (gatt == null) {
                callbackContext.error("BluetoothGatt is null");
                return;
            }

            BluetoothGattService service = gatt.getService(serviceUUID);
            BluetoothGattCharacteristic characteristic = service.getCharacteristic(characteristicUUID);

            if (characteristic == null) {
                callbackContext.error("Characteristic " + characteristicUUID + " not found.");
            } else {
                characteristic.setValue(data);
                characteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE);

                if (gatt.writeCharacteristic(characteristic)) {
                    callbackContext.success();
                } else {
                    callbackContext.error("Write failed");
                }
            }

        } finally {
            commandCompleted();
        }

    }

    // BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
    private void writeCharacteristic(CallbackContext callbackContext, UUID serviceUUID, UUID characteristicUUID, byte[] data) {

        if (gatt == null) {
            callbackContext.error("BluetoothGatt is null");
            return;
        }

        boolean success = false;

        BluetoothGattService service = gatt.getService(serviceUUID);
        BluetoothGattCharacteristic characteristic = service.getCharacteristic(characteristicUUID);

        if (characteristic == null) {
            callbackContext.error("Characteristic " + characteristicUUID + " not found.");
        } else {
            characteristic.setValue(data);
            characteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);

            if (gatt.writeCharacteristic(characteristic)) {
                // success is sent by onReliableWriteCompleted
                writeCallback = callbackContext;
                success = true;
            } else {
                callbackContext.error("Write failed");
            }
        }

        if (!success) {
            commandCompleted();
        }

    }

    public void queueRead(CallbackContext callbackContext, UUID serviceUUID, UUID characteristicUUID) {
        BLECommand command = new BLEReadCommand(callbackContext, serviceUUID, characteristicUUID);
        commandQueue.add(command);

        PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
        processCommands();
    }

    public void queueWrite(CallbackContext callbackContext, UUID serviceUUID, UUID characteristicUUID, byte[] data, int writeType) {
        BLECommand command = new BLEWriteCommand(callbackContext, serviceUUID, characteristicUUID, data, writeType);
        commandQueue.add(command);

        PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
        processCommands();
    }

    public void queueRegisterNotifyCallback(CallbackContext callbackContext, UUID serviceUUID, UUID characteristicUUID) {
        BLECommand command = new BLERegisterNotifyCallbackCommand(callbackContext, serviceUUID, characteristicUUID);
        queueCommand(command);
    }

    // add a new command to the queue
    private void queueCommand(BLECommand command) {
        commandQueue.add(command);

        PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
        result.setKeepCallback(true);
        command.getCallbackContext().sendPluginResult(result);

        if (!bleProcessing) {
            processCommands();
        }
    }

    // command finished, queue the next command
    private void commandCompleted() {
        bleProcessing = false;
        processCommands();
    }

    // process the queue
    private void processCommands() {

        if (bleProcessing) { return; }

        BLECommand command = commandQueue.poll();
        if (command != null) {
            if (command.getType() == BLECommand.READ) {
                bleProcessing = true;
                readCharacteristic(command.getCallbackContext(), command.getServiceUUID(), command.getCharacteristicUUID());
            } else if (command.getType() == BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT) {
                bleProcessing = true;
                writeCharacteristic(command.getCallbackContext(), command.getServiceUUID(), command.getCharacteristicUUID(), command.getData());
            } else if (command.getType() == BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE) {
                bleProcessing = true;
                writeNoResponse(command.getCallbackContext(), command.getServiceUUID(), command.getCharacteristicUUID(), command.getData());
            } else if (command.getType() == BLECommand.REGISTER_NOTIFY) {
                bleProcessing = true;
                registerNotifyCallback(command.getCallbackContext(), command.getServiceUUID(), command.getCharacteristicUUID());
            } else {
                // this shouldn't happen
                throw new RuntimeException("Unexpected BLE Command type " + command.getType());
            }
        }

    }

    private String generateHashKey(BluetoothGattCharacteristic characteristic) {
        return generateHashKey(characteristic.getService().getUuid(), characteristic);
    }

    private String generateHashKey(UUID serviceUUID, BluetoothGattCharacteristic characteristic) {

        StringBuffer b = new StringBuffer();
        b.append(serviceUUID);
        b.append("|");
        b.append(characteristic.getUuid());
        b.append("|");
        b.append(characteristic.getInstanceId());
        return b.toString();

    }

}
