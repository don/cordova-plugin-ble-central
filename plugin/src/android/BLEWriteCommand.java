package com.megster.cordova.ble.central;

import org.apache.cordova.CallbackContext;
import java.util.UUID;

public class BLEWriteCommand implements BLECommand {
    CallbackContext callbackContext;
    UUID serviceUUID;
    UUID characteristicUUID;
    byte[] data;
    int writeType;

    public BLEWriteCommand( CallbackContext callbackContext, UUID serviceUUID, UUID characteristicUUID, byte[] data, int writeType) {
        this.callbackContext = callbackContext;
        this.serviceUUID = serviceUUID;
        this.characteristicUUID = characteristicUUID;
        this.data = data;
        this.writeType = writeType;
    }

    public int getType() {
        return writeType;
    }

    public CallbackContext getCallbackContext() {
        return callbackContext;
    }

    public UUID getServiceUUID() {
        return serviceUUID;
    }

    public UUID getCharacteristicUUID() {
        return characteristicUUID;
    }

    public byte[] getData() {
        return data;
    }

}
