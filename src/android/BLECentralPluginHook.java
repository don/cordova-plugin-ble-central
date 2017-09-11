package com.megster.cordova.ble.central;

import org.apache.cordova.PluginResult;

public interface BLECentralPluginHook {

    public PluginResult onCharacteristicChanged(PluginResult pr);

    public PluginResult onCharacteristicRead(PluginResult pr);

	public PluginResult onCharacteristicWrite(PluginResult pr);
}
