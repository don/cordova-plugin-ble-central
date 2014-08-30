package com.megster.cordova.ble.central;

import org.apache.cordova.CallbackContext;
import java.util.UUID;

public class BLERegisterNotifyCallbackCommand implements BLECommand {
    CallbackContext callbackContext;
    UUID serviceUUID;
    UUID characteristicUUID;

    public BLERegisterNotifyCallbackCommand(CallbackContext callbackContext, UUID serviceUUID, UUID characteristicUUID) {
        this.callbackContext = callbackContext;
        this.serviceUUID = serviceUUID;
        this.characteristicUUID = characteristicUUID;
    }

    public int getType() {
        return BLECommand.REGISTER_NOTIFY;
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
        return null;
    }

}
