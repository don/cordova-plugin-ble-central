package com.megster.cordova.ble.central;

import org.apache.cordova.CallbackContext;

import java.util.UUID;

/**
 * Android BLE stack is async but doesn't queue commands, so it ignore additional commands when processing. WTF?
 * This is an object to encapsulate the command data for queuing
 */
interface BLECommand {
    public static int READ = 10000;
    public static int REGISTER_NOTIFY = 10001;

    int getType();

    CallbackContext getCallbackContext();
    UUID getServiceUUID();
    UUID getCharacteristicUUID();
    byte[] getData();
}
