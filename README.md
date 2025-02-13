# Bluetooth Low Energy (BLE) Central Plugin for Apache Cordova

[![npm version](https://img.shields.io/npm/v/cordova-plugin-ble-central.svg?style=flat)](https://www.npmjs.com/package/cordova-plugin-ble-central) ![maintained](https://img.shields.io/maintenance/yes/2025?style=flat-square) [![cordova builds](https://img.shields.io/github/actions/workflow/status/don/cordova-plugin-ble-central/.github/workflows/cordova.yaml?branch=master&style=flat-square&label=cordova%20builds)](https://github.com/don/cordova-plugin-ble-central/actions/workflows/cordova.yaml?query=branch%3Amaster) [![capacitor builds](https://img.shields.io/github/actions/workflow/status/don/cordova-plugin-ble-central/.github/workflows/capacitor.yaml?branch=master&style=flat-square&label=capacitor%20builds)](https://github.com/don/cordova-plugin-ble-central/actions/workflows/capacitor.yaml?query=branch%3Amaster) [![license](https://img.shields.io/npm/l/cordova-plugin-ble-central.svg?style=flat)](https://www.npmjs.com/package/cordova-plugin-ble-central)

This plugin enables communication between a phone and Bluetooth Low Energy (BLE) peripherals.

The plugin provides a simple [JavaScript API](#api) for iOS and Android.

-   Scan for peripherals
-   Connect to a peripheral
-   Read the value of a characteristic
-   Write new value to a characteristic
-   Get notified when characteristic's value changes
-   Transfer data via L2CAP channels

Advertising information is returned when scanning for peripherals.
Service, characteristic, and property info is returned when connecting to a peripheral.
All access is via service and characteristic UUIDs. The plugin manages handles internally.

Simultaneous connections to multiple peripherals are supported.

_This plugin isn't intended for scanning beacons._ Try [cordova-plugin-ibeacon](https://github.com/petermetz/cordova-plugin-ibeacon) for iBeacons.<br/>
If you want to create Bluetooth devices, try [cordova-plugin-ble-peripheral](https://github.com/don/cordova-plugin-ble-peripheral).

See the [examples](https://github.com/don/cordova-plugin-ble-central/tree/master/examples) for ideas on how this plugin can be used.

## Supported Platforms

-   iOS
-   Android 6+ (8.1 or greater recommended)
-   Browser (where navigator.bluetooth is supported)

# Installing

## Capacitor

    $ npm install cordova-plugin-ble-central
    $ npx cap sync

The plugin can be further configured via the cordova preferences section of the [capacitor config file](https://capacitorjs.com/docs/cordova/migrating-from-cordova-to-capacitor#cordova-plugin-preferences):

```typescript
const config = {
  ...
  cordova: {
    preferences: {
      ...
      bluetooth_restore_state: "true",
      accessBackgroundLocation: "false",
    },
  }
}
```

-   `bluetooth_restore_state`: [**iOS**] Enable Bluetooth state restoration, allowing an app to be woken up to receive scan results and peripheral notifications. This is needed for background scanning support. See [iOS restore state](https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/CoreBluetoothBackgroundProcessingForIOSApps/PerformingTasksWhileYourAppIsInTheBackground.html#//apple_ref/doc/uid/TP40013257-CH7-SW13). For more information about background operation with this plugin, see [Background Scanning and Notifications on iOS](#background-scanning-and-notifications-on-ios).

-   `accessBackgroundLocation`: [**Android**] Tells the plugin to request the `ACCESS_BACKGROUND_LOCATION` permission on Android 10 & Android 11 in order for scanning to function when the app is not visible.

### iOS

After installation, the following additions should be made to the app's `Info.plist`

-   Set [NSBluetoothAlwaysUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsbluetoothalwaysusagedescription?language=objc) to a descriptive text, to be shown to the user on first access to the Bluetooth adapter. **If this is not defined the app will crash**.
-   _(Optional)_ Add `bluetooth-central` to [UIBackgroundModes](https://developer.apple.com/documentation/bundleresources/information_property_list/uibackgroundmodes?language=objc) to enable background receipt of scan information and BLE notifications

## Cordova

`$ cordova plugin add cordova-plugin-ble-central --variable BLUETOOTH_USAGE_DESCRIPTION="Your description here" --variable IOS_INIT_ON_LOAD=true|false --variable BLUETOOTH_RESTORE_STATE=true|false --variable ACCESS_BACKGROUND_LOCATION=true|false`

It's recommended to always use the latest cordova and cordova platform packages in order to ensure correct function. This plugin generally best supports the following platforms and version ranges:

| cordova | cordova-ios | cordova-android | cordova-browser |
| ------- | ----------- | --------------- | --------------- |
| 10+     | 6.2.0+      | 12.0+           | not tested      |

All variables can be modified after installation by updating the values in `package.json`.

-   `BLUETOOTH_USAGE_DESCRIPTION`: [**iOS**] defines the values for [NSBluetoothAlwaysUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsbluetoothalwaysusagedescription?language=objc).

-   `IOS_INIT_ON_LOAD`: [**iOS**] Prevents the Bluetooth plugin from being initialised until first access to the `ble` window object. This allows an application to warn the user before the Bluetooth access permission is requested.

-   `BLUETOOTH_RESTORE_STATE`: [**iOS**] Enable Bluetooth state restoration, allowing an app to be woken up to receive scan results and peripheral notifications. This is needed for background scanning support. See [iOS restore state](https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/CoreBluetoothBackgroundProcessingForIOSApps/PerformingTasksWhileYourAppIsInTheBackground.html#//apple_ref/doc/uid/TP40013257-CH7-SW13). For more information about background operation with this plugin, see [Background Scanning and Notifications on iOS](#background-scanning-and-notifications-on-ios).

-   `ACCESS_BACKGROUND_LOCATION`: [**Android**] Tells the plugin to request the ACCESS_BACKGROUND_LOCATION permission on Android 10 & Android 11 in order for scanning to function when the app is not visible.

## TypeScript

TypeScript definitions are provided by this plugin. These can be added to a file by adding a [triple-slash reference](https://www.typescriptlang.org/docs/handbook/triple-slash-directives.html#-reference-types-) at the top of any file using this plugin:

```typescript
/// <reference types="cordova-plugin-ble-central" />
```

## Android permission conflicts

If you are having Android permissions conflicts with other plugins, try using the `slim` variant of the plugin instead with `cordova plugin add cordova-plugin-ble-central@slim`. This variant excludes all Android permissions, leaving it to the developer to ensure the right entries are added manually to the `AndroidManifest.xml` (see below for an example).

To include the default set of permissions the plugin installs on Android SDK v31+, add the following snippet in your `config.xml` file, in the `<platform name="android">` section:

```xml
    <config-file target="AndroidManifest.xml" parent="/manifest">
        <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" android:maxSdkVersion="28" />
        <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30" />
        <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
        <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
        <uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
        <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    </config-file>
```

For the best understanding about which permissions are needed for which combinations of target SDK version & OS version, see [Android Bluetooth permissions](https://developer.android.com/guide/topics/connectivity/bluetooth/permissions)

# API

-   [ble.scan](#scan)
-   [ble.startScan](#startscan)
-   [ble.startScanWithOptions](#startscanwithoptions)
-   [ble.stopScan](#stopscan)
-   [ble.setPin](#setpin)
-   [ble.bond](#bond)
-   [ble.unbond](#unbond)
-   [ble.readBondState](#readbondstate)
-   [ble.connect](#connect)
-   [ble.autoConnect](#autoconnect)
-   [ble.disconnect](#disconnect)
-   [ble.requestMtu](#requestmtu)
-   [ble.requestConnectionPriority](#requestconnectionpriority)
-   [ble.refreshDeviceCache](#refreshdevicecache)
-   [ble.read](#read)
-   [ble.write](#write)
-   [ble.writeWithoutResponse](#writewithoutresponse)
-   [ble.startNotification](#startnotification)
-   [ble.stopNotification](#stopnotification)
-   [ble.isConnected](#isconnected)
-   [ble.isEnabled](#isenabled)
-   [ble.isLocationEnabled](#islocationenabled)
-   [ble.startLocationStateNotifications](#startlocationstatenotifications)
-   [ble.stopLocationStateNotifications](#stoplocationstatenotifications)
-   [ble.startStateNotifications](#startstatenotifications)
-   [ble.stopStateNotifications](#stopstatenotifications)
-   [ble.showBluetoothSettings](#showbluetoothsettings)
-   [ble.enable](#enable)
-   [ble.readRSSI](#readrssi)
-   [ble.connectedPeripheralsWithServices](#connectedperipheralswithservices)
-   [ble.peripheralsWithIdentifiers](#peripheralswithidentifiers)
-   [ble.restoredBluetoothState](#restoredbluetoothstate)
-   [ble.list](#list)
-   [ble.bondedDevices](#bondeddevices)
-   [ble.l2cap.open](#l2capopen)
-   [ble.l2cap.close](#l2capclose)
-   [ble.l2cap.receiveData](#l2capreceivedata)
-   [ble.l2cap.write](#l2capwrite)

## scan

Scan and discover BLE peripherals.

```javascript
ble.scan(services, seconds, success, failure);
```

### Description

Function `scan` scans for BLE devices. The success callback is called each time a peripheral is discovered. Scanning automatically stops after the specified number of seconds.

```json
{
    "name": "TI SensorTag",
    "id": "BD922605-1B07-4D55-8D09-B66653E51BBA",
    "rssi": -79,
    "advertising": /* ArrayBuffer or map */
}
```

Advertising information format varies depending on your platform. See [Advertising Data](#advertising-data) for more information.

### Location Permission Notes

With Android SDK >= 23 (6.0), additional permissions are required for Bluetooth low energy scanning. The location permission [ACCESS_COARSE_LOCATION](https://developer.android.com/reference/android/Manifest.permission.html#ACCESS_COARSE_LOCATION) is required because Bluetooth beacons can be used to determine a user's location. If necessary, the plugin will prompt the user to allow the app to access to device's location. If the user denies permission, the scan failure callback will receive the error "Location permission not granted".

Location Services must be enabled for Bluetooth scanning. If location services are disabled, the failure callback will receive the error "Location services are disabled". If you want to manage location permission and screens, try the [cordova-diagonostic-plugin](https://github.com/dpa99c/cordova-diagnostic-plugin) or the Ionic Native [Diagnostic plugin](https://ionicframework.com/docs/native/diagnostic/).

### Parameters

-   **services**: List of services to discover, or [] to find all devices
-   **seconds**: Number of seconds to run discovery
-   **success**: Success callback function that is invoked which each discovered device.
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Quick Example

```javascript
ble.scan(
    [],
    5,
    function (device) {
        console.log(JSON.stringify(device));
    },
    failure
);
```

## startScan

Scan and discover BLE peripherals.

```javascript
ble.startScan(services, success, failure);
```

### Description

Function `startScan` scans for BLE devices. The success callback is called each time a peripheral is discovered. Scanning will continue until `stopScan` is called.

```json
{
    "name": "TI SensorTag",
    "id": "BD922605-1B07-4D55-8D09-B66653E51BBA",
    "rssi": -79,
    "advertising": /* ArrayBuffer or map */
}
```

Advertising information format varies depending on your platform. See [Advertising Data](#advertising-data) for more information.

See the [location permission notes](#location-permission-notes) above for information about Location Services in Android SDK >= 23.

### Parameters

-   **services**: List of services to discover, or [] to find all devices
-   **success**: Success callback function that is invoked which each discovered device.
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Quick Example

```javascript
ble.startScan(
    [],
    function (device) {
        console.log(JSON.stringify(device));
    },
    failure
);

setTimeout(
    ble.stopScan,
    5000,
    function () {
        console.log('Scan complete');
    },
    function () {
        console.log('stopScan failed');
    }
);
```

## startScanWithOptions

Scan and discover BLE peripherals, specifying scan options.

```javascript
ble.startScanWithOptions(services, options, success, failure);
```

### Description

Function `startScanWithOptions` scans for BLE devices. It operates similarly to the `startScan` function, but allows you to specify extra options (like allowing duplicate device reports). The success callback is called each time a peripheral is discovered. Scanning will continue until `stopScan` is called.

```json
{
    "name": "TI SensorTag",
    "id": "BD922605-1B07-4D55-8D09-B66653E51BBA",
    "rssi": -79,
    "advertising": /* ArrayBuffer or map */
}
```

Advertising information format varies depending on your platform. See [Advertising Data](#advertising-data) for more information.

See the [location permission notes](#location-permission-notes) above for information about Location Services in Android SDK >= 23.

### Parameters

-   **services**: List of services to discover, or [] to find all devices
-   **options**: an object specifying a set of name-value pairs. The currently acceptable options are:
    -   _reportDuplicates_: _true_ if duplicate devices should be reported, _false_ (default) if devices should only be reported once.
    -   _duration_: time in seconds to scan for. (default) Scans forever when not specified.
    -   _scanMode_: String defines [setScanMode()](https://developer.android.com/reference/kotlin/android/bluetooth/le/ScanSettings.Builder#setscanmode) argument on Android. Default on Android is _lowPower_. When interactive scanning from an app, _lowLatency_ can boost how quickly the device is found, at the expense of using more battery power.
        Can be one of: _lowPower_ | _balanced_ | _lowLatency_ | _opportunistic_
    -   _callbackType_: String defines [setCallbackType()](https://developer.android.com/reference/kotlin/android/bluetooth/le/ScanSettings.Builder#setcallbacktype) argument on Android.  
        Can be one of: _all_ | _first_ | _lost_
    -   _matchMode_: String defines [setMatchMode()](https://developer.android.com/reference/kotlin/android/bluetooth/le/ScanSettings.Builder#setmatchmode) argument on Android.  
        Can be one of: _aggressive_ | _sticky_
    -   _numOfMatches_: String defines [setNumOfMatches()](https://developer.android.com/reference/kotlin/android/bluetooth/le/ScanSettings.Builder#setnumofmatches) argument on Android.  
        Can be one of: _one_ | _few_ | _max_
    -   _phy_: String for [setPhy()](https://developer.android.com/reference/kotlin/android/bluetooth/le/ScanSettings.Builder#setphy) on Android.
        Can be one of: _1m_ | _coded_ | _all_
    -   _legacy_: _true_ or _false_ to [control filtering](https://developer.android.com/reference/kotlin/android/bluetooth/le/ScanSettings.Builder#setlegacy) bluetooth spec.pre-4.2 advertisements on Android.
    -   _forceScanFilter_: _true_ or _false_ to [to force an empty scan filter](https://github.com/don/cordova-plugin-ble-central/issues/987) if no other filters are provided on Android.
    -   _reportDelay_: Milliseconds for [setReportDelay()](https://developer.android.com/reference/kotlin/android/bluetooth/le/ScanSettings.Builder#setreportdelay) on Android. _0_ to be notified of results immediately. Values > _0_ causes the scan results to be queued up and delivered after the requested delay or when the internal buffers fill up.
-   **success**: Success callback function that is invoked which each discovered device.
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Quick Example

```javascript
ble.startScanWithOptions([],
    { reportDuplicates: true }
    function(device) {
        console.log(JSON.stringify(device));
    },
    failure);

setTimeout(ble.stopScan,
    5000,
    function() { console.log("Scan complete"); },
    function() { console.log("stopScan failed"); }
);
```

## stopScan

Stop scanning for BLE peripherals.

```javascript
ble.stopScan(success, failure);
// Or using await with promises
await ble.withPromises.stopScan();
```

### Description

Function `stopScan` stops scanning for BLE devices.

### Parameters

-   **success**: Success callback function, invoked when scanning is stopped. [optional]
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Quick Example

```javascript
ble.startScan(
    [],
    function (device) {
        console.log(JSON.stringify(device));
    },
    failure
);

setTimeout(
    ble.stopScan,
    5000,
    function () {
        console.log('Scan complete');
    },
    function () {
        console.log('stopScan failed');
    }
);

/* Alternate syntax
setTimeout(function() {
    ble.stopScan(
        function() { console.log("Scan complete"); },
        function() { console.log("stopScan failed"); }
    );
}, 5000);
*/
```

## setPin

Set device pin

```javascript
ble.setPin(pin, [success], [failure]);
// Or using await with promises
await ble.withPromises.setPin(pin);
```

### Description

Function `setPin` sets the pin when device requires it.

### Parameters

-   **pin**: Pin of the device as a string
-   **success**: Success callback function that is invoked when the function is invoked. [optional]
-   **failure**: Error callback function, invoked when error occurs. [optional]

## bond

Initiate a bond with a remote device

```javascript
ble.bond(device_id, [success], [failure], [options]);
// Or using await with promises
await ble.withPromises.bond(device_id);
await ble.withPromises.bond(device_id, { usePairingDialog: true });
```

### Description

Function `bond` initialises a bond with a peripheral. The success callback will be called when the
bonding is complete. The bonding process may prompt the user to confirm the pairing process.

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **success**: Success callback function that is invoked when the bonding succeeds. [optional]
-   **failure**: Error callback function, invoked when the bonding fails. [optional]
-   **options**: an object specifying a set of name-value pairs. The currently acceptable options are:
    -   _usePairingDialog_: _true_ (default) Show pairing request as a dialog rather than a notification [optional]

### Supported Platforms

-   Android

## unbond

Remove a bond for a remote device

```javascript
ble.unbond(device_id, [success], [failure]);
// Or using await with promises
await ble.withPromises.unbond(device_id);
```

### Description

Function `unbond` removes an existing bond for a remote device. The success callback will be called when the
bond has been removed.

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **success**: Success callback function that is invoked when the bond is removed. [optional]
-   **failure**: Error callback function, invoked when the bond removal fails. [optional]

### Supported Platforms

-   Android

## readBondState

Get the bond state of a device as a string

```javascript
ble.readBondState(device_id, [success], [failure]);
// Or using await with promises
const bondState = await ble.withPromises.readBondState(device_id);
```

### Description

Function `readBondState` retrieves the current bond state of the device.

**States**

-   "none"
-   "bonding"
-   "bonded"

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **success**: Success callback function that is invoked with the current bond state. [optional]
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Supported Platforms

-   Android

## connect

Connect to a peripheral.

```javascript
ble.connect(device_id, connectCallback, disconnectCallback);
```

### Description

Function `connect` connects to a BLE peripheral. The callback is long running. The connect callback will be called when the connection is successful. Service and characteristic info will be passed to the connect callback in the [peripheral object](#peripheral-data).

The disconnect callback is called if the connection fails, or later if the peripheral disconnects. When possible, a peripheral object is passed to the failure callback. The disconnect callback is only called when the peripheral initates the disconnection. The disconnect callback is not called when the application calls [ble.disconnect](#disconnect). The disconnect callback is how your app knows the peripheral inintiated a disconnect.

### Scanning before connecting

Android can connect to peripherals using MAC address without scanning. If the MAC address is not found the connection will time out.

For iOS, the plugin needs to know about any device UUID before calling connect. You can do this by calling [ble.scan](#scan), [ble.startScan](#startscan), [ble.connectedPeripheralsWithServices](#connectedperipheralswithservices), or [ble.peripheralsWithIdentifiers](#peripheralswithidentifiers) so the plugin has a list of available peripherals.

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **connectCallback**: Connect callback function that is invoked when the connection is successful.
-   **disconnectCallback**: Disconnect callback function, invoked when the peripheral disconnects or an error occurs.

## autoConnect

Establish an automatic connection to a peripheral.

```javascript
ble.autoConnect(device_id, connectCallback, disconnectCallback);
```

### Description

Automatically connect to a device when it is in range of the phone. When the device connects, the connect callback is called with a [peripheral object](#peripheral-data). The call to autoConnect will not time out. It will wait forever until the device is in range. When the peripheral disconnects, the disconnect callback is called with a peripheral object.

Calling [ble.disconnect](#disconnect) will stop the automatic reconnection.

Both the connect and disconnect callbacks can be called many times as the device connects and disconnects. Do not wrap this function in a Promise or Observable.

On iOS, [background notifications on ios](#background-notifications-on-ios) must be enabled if you want to run in the background. On Android, this relies on the autoConnect argument of `BluetoothDevice.connectGatt()`. Not all Android devices implement this feature correctly.

See notes about [scanning before connecting](#scanning-before-connecting)

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **connectCallback**: Connect callback function that is invoked when the connection is successful.
-   **disconnectCallback**: Disconnect callback function, invoked when the peripheral disconnects or an error occurs.

## disconnect

Disconnect.

```javascript
ble.disconnect(device_id, [success], [failure]);
// Or using await with promises
await ble.withPromises.disconnect(device_id);
```

### Description

Function `disconnect` disconnects the selected device.

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **success**: Success callback function that is invoked when the connection is successful. [optional]
-   **failure**: Error callback function, invoked when error occurs. [optional]

## requestMtu

requestMtu

```javascript
ble.requestMtu(device_id, new_mtu, [success], [failure]);
// Or using await with promises
const actual_mtu = await ble.withPromises.requestMtu(device_id, new_mtu);
```

### Description

This function may be used to request (on Android) a larger MTU size to be able to send more data at once.
This can be useful when performing a write request operation (write without response), the data sent is truncated to the MTU size.
The resulting MTU size is sent to the success callback. The requested and resulting MTU sizes are not necessarily equal.

### Supported Platforms

-   Android

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **mtu**: MTU size
-   **success**: Success callback function that is invoked when the MTU size request is successful. The resulting MTU size is passed as an integer.
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Quick Example

```javascript
ble.requestMtu(
    device_id,
    new_mtu,
    function (mtu) {
        alert('MTU set to: ' + mtu);
    },
    function (failure) {
        alert('Failed to request MTU.');
    }
);
```

## requestConnectionPriority

requestConnectionPriority

```javascript
ble.requestConnectionPriority(device_id, priority, [success], [failure]);
// Or using await with promises
await ble.withPromises.requestConnectionPriority(device_id, priority);
```

### Description

When Connecting to a peripheral android can request for the connection priority for better communication. See [BluetoothGatt#requestConnectionPriority](<https://developer.android.com/reference/android/bluetooth/BluetoothGatt#requestConnectionPriority(int)>) for technical details

Connection priority can be one of:

-   `"balanced"` - [CONNECTION_PRIORITY_BALANCED](https://developer.android.com/reference/android/bluetooth/BluetoothGatt#CONNECTION_PRIORITY_BALANCED)
-   `"high"` - [CONNECTION_PRIORITY_HIGH](https://developer.android.com/reference/android/bluetooth/BluetoothGatt#CONNECTION_PRIORITY_HIGH)
-   `"low"` - [CONNECTION_PRIORITY_LOW_POWER](https://developer.android.com/reference/android/bluetooth/BluetoothGatt#CONNECTION_PRIORITY_LOW_POWER)

### Supported Platforms

-   Android

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **priority**: `"high"`, `"balanced"` or `"low"`
-   **success**: Success callback function that is invoked when the connection is successful. [optional]
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Quick Example

```javascript
ble.requestConnectionPriority(
    device_id,
    'high',
    function () {
        alert('success');
    },
    function (failure) {
        alert('Failed to request connection priority: ' + failure);
    }
);
```

## refreshDeviceCache

refreshDeviceCache

```javascript
ble.refreshDeviceCache(deviceId, timeoutMillis, [success], [failure]);
```

### Description

Some poorly behaved devices show old cached services and characteristics info. (Usually because they
don't implement Service Changed 0x2a05 on Generic Attribute Service 0x1801 and the central doesn't know
the data needs to be refreshed.) This method might help.

_NOTE_ Since this uses an undocumented API it's not guaranteed to work.

### Supported Platforms

-   Android

### Parameters

-   **deviceId**: UUID or MAC address of the peripheral
-   **timeoutMillis**: timeout in milliseconds after refresh before discovering services
-   **success**: Success callback function invoked with the refreshed peripheral. [optional]
-   **failure**: Error callback function, invoked when an error occurs. [optional]

## read

Reads the value of a characteristic.

```javascript
ble.read(device_id, service_uuid, characteristic_uuid, success, failure);
// Or using await with promises
const data = await ble.withPromises.read(device_id, service_uuid, characteristic_uuid);
```

### Description

Function `read` reads the value of the characteristic.

Raw data is passed from native code to the callback as an [ArrayBuffer](#typed-arrays).

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **service_uuid**: UUID of the BLE service
-   **characteristic_uuid**: UUID of the BLE characteristic
-   **success**: Success callback function that is invoked when the connection is successful. [optional]
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Quick Example

Retrieves an [ArrayBuffer](#typed-arrays) when reading data.

```javascript
// read data from a characteristic, do something with output data
ble.read(
    device_id,
    service_uuid,
    characteristic_uuid,
    function (data) {
        console.log('Hooray we have data' + JSON.stringify(data));
        alert('Successfully read data from device.' + JSON.stringify(data));
    },
    function (failure) {
        alert('Failed to read characteristic from device.');
    }
);
```

## write

Writes data to a characteristic.

```javascript
ble.write(device_id, service_uuid, characteristic_uuid, data, success, failure);
// Or using await with promises
await ble.withPromises.write(device_id, service_uuid, characteristic_uuid, data);
```

### Description

Function `write` writes data to a characteristic.

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **service_uuid**: UUID of the BLE service
-   **characteristic_uuid**: UUID of the BLE characteristic
-   **data**: binary data, use an [ArrayBuffer](#typed-arrays)
-   **success**: Success callback function that is invoked when the connection is successful. [optional]
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Quick Example

Use an [ArrayBuffer](#typed-arrays) when writing data.

```javascript
// send 1 byte to switch a light on
var data = new Uint8Array(1);
data[0] = 1;
ble.write(device_id, 'FF10', 'FF11', data.buffer, success, failure);

// send a 3 byte value with RGB color
var data = new Uint8Array(3);
data[0] = 0xff; // red
data[1] = 0x00; // green
data[2] = 0xff; // blue
ble.write(device_id, 'ccc0', 'ccc1', data.buffer, success, failure);

// send a 32 bit integer
var data = new Uint32Array(1);
data[0] = counterInput.value;
ble.write(device_id, SERVICE, CHARACTERISTIC, data.buffer, success, failure);
```

## writeWithoutResponse

Writes data to a characteristic without confirmation from the peripheral.

```javascript
ble.writeWithoutResponse(device_id, service_uuid, characteristic_uuid, data, success, failure);
// Or using await with promises
await ble.withPromises.writeWithoutResponse(device_id, service_uuid, characteristic_uuid, data);
```

### Description

Function `writeWithoutResponse` writes data to a characteristic without a response from the peripheral. You are not notified if the write fails in the BLE stack. The success callback is be called when the characteristic is written.

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **service_uuid**: UUID of the BLE service
-   **characteristic_uuid**: UUID of the BLE characteristic
-   **data**: binary data, use an [ArrayBuffer](#typed-arrays)
-   **success**: Success callback function that is invoked when the connection is successful. [optional]
-   **failure**: Error callback function, invoked when error occurs. [optional]

## startNotification

Register to be notified when the value of a characteristic changes.

```javascript
ble.startNotification(device_id, service_uuid, characteristic_uuid, success, failure);
// Or using await with promises
// Note, initial promise resolves or rejects depending on whether the subscribe was successful
await ble.withPromises.startNotification(device_id, success, failure);
```

### Description

Function `startNotification` registers a callback that is called _every time_ the value of a characteristic changes. This method handles both `notifications` and `indications`. The success callback is called multiple times.

Raw data is passed from native code to the success callback as an [ArrayBuffer](#typed-arrays).

See [Background Notifications on iOS](#background-notifications-on-ios)

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **service_uuid**: UUID of the BLE service
-   **characteristic_uuid**: UUID of the BLE characteristic
-   **success**: Success callback function invoked every time a notification occurs
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Quick Example

```javascript
var onData = function (buffer) {
    // Decode the ArrayBuffer into a typed Array based on the data you expect
    var data = new Uint8Array(buffer);
    alert('Button state changed to ' + data[0]);
};

ble.startNotification(device_id, 'FFE0', 'FFE1', onData, failure);
```

## stopNotification

Stop being notified when the value of a characteristic changes.

```javascript
ble.stopNotification(device_id, service_uuid, characteristic_uuid, success, failure);
// Or using await with promises
await ble.withPromises.stopNotification(device_id);
```

### Description

Function `stopNotification` stops a previously registered notification callback.

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **service_uuid**: UUID of the BLE service
-   **characteristic_uuid**: UUID of the BLE characteristic
-   **success**: Success callback function that is invoked when the notification is removed. [optional]
-   **failure**: Error callback function, invoked when error occurs. [optional]

## isConnected

Reports the connection status.

```javascript
// Callbacks
ble.isConnected(device_id, success, failure);

// Promises with boolean return
const isConnected = await ble.withPromises.isConnected(device_id, false);

// Promises with rejection
await ble.withPromises.isConnected(device_id); // throws if not connected
```

### Description

Function `isConnected` calls the success callback when the peripheral is connected and the failure callback when _not_ connected.

NOTE that for many apps isConnected is unncessary. The app can track the connected state. Ater calling [connect](#connect) the app is connected when the success callback function is called. If the device disconnects at any point in the future, the failure callback of connect will be called.

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **success**: Success callback function that is invoked with a boolean for connected status.
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Quick Example

```javascript
// Callbacks
ble.isConnected(
    'FFCA0B09-CB1D-4DC0-A1EF-31AFD3EDFB53',
    function () {
        console.log('Peripheral is connected');
    },
    function () {
        console.log('Peripheral is *not* connected');
    }
);

// Promises with boolean return
const isConnected = await ble.withPromises.isConnected(device_id, false);
if (isConnected) {
    console.log('Peripheral is connected');
} else {
    console.log('Peripheral is *not* connected');
}

// Promises with rejection
try {
    await ble.withPromises.isConnected(device_id);
    console.log('Peripheral is connected');
} catch (e) {
    console.log('Peripheral is *not* connected');
}
```

## isEnabled

Reports if bluetooth is enabled.

```javascript
ble.isEnabled(success, failure);
```

### Description

Function `isEnabled` calls the success callback when Bluetooth is enabled and the failure callback when Bluetooth is _not_ enabled.

### Parameters

-   **success**: Success callback function, invoked when Bluetooth is enabled.
-   **failure**: Error callback function, invoked when Bluetooth is disabled.

### Quick Example

```javascript
ble.isEnabled(
    function () {
        console.log('Bluetooth is enabled');
    },
    function () {
        console.log('Bluetooth is *not* enabled');
    }
);
```

## isLocationEnabled

Reports if location services are enabled.

```javascript
ble.isLocationEnabled(success, failure);
```

### Description

Function `isLocationEnabled` calls the success callback when location services are enabled and the failure callback when location services are _not_ enabled. On some devices, location services must be enabled in order to scan for peripherals.

### Supported Platforms

-   Android

### Parameters

-   **success**: Success callback function, invoked when location services are enabled.
-   **failure**: Error callback function, invoked when location services are disabled.

### Quick Example

```javascript
ble.isLocationEnabled(
    function () {
        console.log('location services are enabled');
    },
    function () {
        console.log('location services are *not* enabled');
    }
);
```

## startLocationStateNotifications

Registers to be notified when Location service state changes on the device.

```javascript
ble.startLocationStateNotifications(success, failure);
// Or using await with promises
// Note, initial promise resolves or rejects depending on whether the subscribe was successful
await ble.withPromises.startLocationStateNotifications(success, failure);
```

### Description

Function `startLocationStateNotifications` calls the success callback when the Location service is enabled or disabled on the device.

### Supported Platforms

-   Android

### Parameters

-   **success**: Success callback function that is invoked with a boolean for the Location state.
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Quick Example

```javascript
ble.startLocationStateNotifications(function (enabled) {
    console.log('Location is ' + enabled);
});
```

## stopLocationStateNotifications

Stops state notifications.

```javascript
ble.stopLocationStateNotifications(success, failure);
// Or using await with promises
await ble.withPromises.stopLocationStateNotifications();
```

### Description

Function `stopLocationStateNotifications` calls the success callback when Location state notifications have been stopped.

### Supported Platforms

-   Android

## startStateNotifications

Registers to be notified when Bluetooth state changes on the device.

```javascript
ble.startStateNotifications(success, failure);
// Or using await with promises
// Note, initial promise resolves or rejects depending on whether the subscribe was successful
await ble.withPromises.startStateNotifications(success, failure);
```

### Description

Function `startStateNotifications` calls the success callback when the Bluetooth is enabled or disabled on the device.

**States**

-   "on"
-   "off"
-   "turningOn" (Android Only)
-   "turningOff" (Android Only)
-   "unknown" (iOS Only)
-   "resetting" (iOS Only)
-   "unsupported" (iOS Only)
-   "unauthorized" (iOS Only)

### Supported Platforms

-   Android
-   iOS

### Parameters

-   **success**: Success callback function that is invoked with a string for the Bluetooth state.
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Quick Example

```javascript
ble.startStateNotifications(function (state) {
    console.log('Bluetooth is ' + state);
});
```

## stopStateNotifications

Stops state notifications.

```javascript
ble.stopStateNotifications(success, failure);
// Or using await with promises
await ble.withPromises.stopStateNotifications();
```

### Description

Function `stopStateNotifications` calls the success callback when Bluetooth state notifications have been stopped.

### Supported Platforms

-   Android
-   iOS

## showBluetoothSettings

Show the Bluetooth settings on the device.

```javascript
ble.showBluetoothSettings(success, failure);
// Or using await with promises
await ble.withPromises.showBluetoothSettings();
```

### Description

Function `showBluetoothSettings` opens the Bluetooth settings for the operating systems.

`showBluetoothSettings` is not available on iOS. Plugins like [cordova-diagonostic-plugin](https://github.com/dpa99c/cordova-diagnostic-plugin) and the Ionic Native [Diagnostic plugin](https://ionicframework.com/docs/native/diagnostic/) have APIs to open Bluetooth and other settings, but will often get apps rejected by Apple.

### Supported Platforms

-   Android

### Parameters

-   **success**: Success callback function [optional]
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Quick Example

```javascript
ble.showBluetoothSettings();
```

## enable

Enable Bluetooth on the device.

```javascript
ble.enable(success, failure);
// Or using await with promises
ble.withPromises.enable();
```

### Description

Function `enable` prompts the user to enable Bluetooth.

`enable` is only supported on Android and does not work on iOS.

If `enable` is called when Bluetooth is already enabled, the user will not prompted and the success callback will be invoked.

### Supported Platforms

-   Android

### Parameters

-   **success**: Success callback function, invoked if the user enabled Bluetooth.
-   **failure**: Error callback function, invoked if the user does not enabled Bluetooth.

### Quick Example

```javascript
ble.enable(
    function () {
        console.log('Bluetooth is enabled');
    },
    function () {
        console.log('The user did *not* enable Bluetooth');
    }
);
```

## readRSSI

Read the RSSI value on the device connection.

```javascript
ble.readRSSI(device_id, success, failure);
```

### Description

Samples the RSSI value (a measure of signal strength) on the connection to a bluetooth device. Requires that you have established a connection before invoking (otherwise an error will be raised).

### Parameters

-   **device_id**: device identifier
-   **success**: Success callback function, invoked with the RSSI value (as an integer)
-   **failure**: Error callback function, invoked if there is no current connection or if there is an error reading the RSSI.

### Quick Example

```javascript
var rssiSample;
ble.connect(
    device_id,
    function (device) {
        rssiSample = setInterval(function () {
            ble.readRSSI(
                device_id,
                function (rssi) {
                    console.log('read RSSI', rssi, 'with device', device_id);
                },
                function (err) {
                    console.error('unable to read RSSI', err);
                    clearInterval(rssiSample);
                }
            );
        }, 5000);
    },
    function (err) {
        console.error('error connecting to device');
    }
);
```

## connectedPeripheralsWithServices

Find the connected peripherals offering the listed service UUIDs.

```javascript
ble.connectedPeripheralsWithServices([service], success, failure);
```

### Description

Retreives a list of the peripherals (containing any of the specified services) currently connected to the system. The peripheral list is sent to the success callback. This function wraps [CBCentralManager.retrieveConnectedPeripheralsWithServices:](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1518924-retrieveconnectedperipheralswith?language=objc)

### Supported Platforms

-   iOS

### Parameters

-   **services**: List of services to discover
-   **success**: Success callback function, invoked with a list of peripheral objects
-   **failure**: Error callback function

## peripheralsWithIdentifiers

Find the connected peripherals offering the listed peripheral UUIDs.

```javascript
ble.peripheralsWithIdentifiers([uuids], success, failure);
```

### Description

Sends a list of known peripherals by their identifiers to the success callback. This function wraps [CBCentralManager.retrievePeripheralsWithIdentifiers:](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1519127-retrieveperipheralswithidentifie?language=objc)

### Supported Platforms

-   iOS

### Parameters

-   **identifiers**: List of peripheral UUIDs
-   **success**: Success callback function, invoked with a list of peripheral objects
-   **failure**: Error callback function

## restoredBluetoothState

Retrieve the CBManager restoration state (if applicable)

```javascript
ble.restoredBluetoothState(success, failure);
// Or using await with promises
await ble.withPromises.restoredBluetoothState();
```

### Description

**Use of this feature requires the [BLUETOOTH_RESTORE_STATE variable to be set](#background-scanning-and-notifications-on-ios) to true.** For more information about background operation, see [Background Scanning and Notifications on iOS](#background-scanning-and-notifications-on-ios).

Retrives the state dictionary that [iOS State Preservation and Restoration](https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/CoreBluetoothBackgroundProcessingForIOSApps/PerformingTasksWhileYourAppIsInTheBackground.html#//apple_ref/doc/uid/TP40013257-CH7-SW10) will supply when the application was launched by iOS.

If the application has no state restored, this will return an empty object.

### Supported Platforms

-   iOS

### Parameters

-   **success**: Success callback function, invoked with the restored Bluetooth state (if any)
-   **failure**: Error callback function

## list

Lists all peripherals discovered by the plugin due to scanning or connecting since app launch.

```javascript
ble.list(success, failure);
// Or using await with promises
await ble.withPromises.list();
```

### Description

Sends a list of bonded low energy peripherals to the success callback.

### Supported Platforms

-   Android

### Parameters

-   **success**: Success callback function, invoked with a list of peripheral objects
-   **failure**: Error callback function

## bondedDevices

Find the bonded devices.

```javascript
ble.bondedDevices(success, failure);
// Or using await with promises
await ble.withPromises.bondedDevices();
```

### Description

Sends a list of bonded low energy peripherals to the success callback.

### Supported Platforms

-   Android

### Parameters

-   **success**: Success callback function, invoked with a list of peripheral objects
-   **failure**: Error callback function

## l2cap.open

Open an L2CAP channel with a connected peripheral. The PSM is assigned by the peripheral, or possibly defined by the Bluetooth standard.

```javascript
ble.l2cap.open(device_id, psm, connectCallback, disconnectCallback);
// Or using await with promises
await ble.withPromises.l2cap.open(device_id, psm, disconnectCallback);
```

Android supports additional arguments in the psm flag to select whether the L2CAP channel is insecure or secure (iOS does this automatically):

```javascript
ble.l2cap.open(device_id, { psm: psm, secureChannel: true }, connectCallback, disconnectCallback);
// Or using await with promises
await ble.withPromises.l2cap.open(device_id, { psm: psm, secureChannel: true }, disconnectCallback);
```

### Description

An L2CAP channel is a duplex byte stream interface (similar to a network socket) that can be used for much more efficient binary data transfer. This is used in some streaming applications, such as the Bluetooth Object Transfer Service.

The PSM (protocol/service multiplexer) is specified by the peripheral when it opens the channel. Some channels have predefined identifiers controlled by [Bluetooth organisation](https://www.bluetooth.com/specifications/assigned-numbers/logical-link-control/). Apple has also outlined a [generic design](https://developer.apple.com/documentation/corebluetooth/cbuuidl2cappsmcharacteristicstring) for PSM exchange. To advertise an L2CAP channel on a specific service, a characteristic with the UUID "ABDD3056-28FA-441D-A470-55A75A52553A" is added to that service, and updated by the peripheral when the L2CAP channel is opened.

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **psm** or **options**: Protocol/service multiplexer, specified by the peripheral when the channel was opened. Can be an object which includes a `psm` key, with an optional `secureChannel` boolean setting to control whether the channel is encrypted or not (Android-only)
-   **connectCallback**: Connect callback function, invoked when an L2CAP connection is successfully opened
-   **disconnectCallback**: Disconnect callback function, invoked when the L2CAP stream closes or an error occurs.

### Supported Platforms

-   iOS
-   Android (>= 10)

## l2cap.close

Close an L2CAP channel.

```javascript
ble.l2cap.close(device_id, psm, success, failure);
// Or using await with promises
await ble.withPromises.l2cap.close(device_id, psm);
```

### Description

Closes an open L2CAP channel with the selected device. All pending reads and writes are aborted.

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **psm**: Protocol/service multiplexer, specified by the peripheral when the channel was opened
-   **success**: Success callback function that is invoked when the stream is closed successfully. [optional]
-   **failure**: Error callback function, invoked when error occurs. [optional]

### Supported Platforms

-   iOS
-   Android (>= 10)

## l2cap.receiveData

Receive data from an L2CAP channel.

```javascript
ble.l2cap.receiveData(device_id, psm, dataCallback);
```

### Description

Sets the function to be called whenever bytes are received on the L2CAP channel. This function will be used as long as the L2CAP connection remains open.

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **psm**: Protocol/service multiplexer, specified by the peripheral when the channel was opened
-   **dataCallback**: Data processing function that is invoked when bytes are received from the peripheral

### Supported Platforms

-   iOS
-   Android (>= 10)

## l2cap.write

Write data to an L2CAP channel.

```javascript
ble.l2cap.write(device_id, psm, data, success, failure);
// Or using await with promises
await ble.withPromises.l2cap.write(device_id, psm, data);
```

### Description

Writes all data to an open L2CAP channel. If the data exceeds the available space in the transmit buffer, the data will be automatically sent in chunks as space becomes available. The success callback is called only once after all the supplied bytes have been written to the transmit stream.

### Parameters

-   **device_id**: UUID or MAC address of the peripheral
-   **psm**: Protocol/service multiplexer, specified by the peripheral when the channel was opened
-   **data**: Data to write to the stream
-   **success**: Success callback function that is invoked after all bytes have been written to the stream [optional]
-   **failure**: Error callback function, invoked when error occurs [optional]

### Supported Platforms

-   iOS
-   Android (>= 10)

# Peripheral Data

Peripheral Data is passed to the success callback when scanning and connecting. Limited data is passed when scanning.

```json
{
    "name": "Battery Demo",
    "id": "20:FF:D0:FF:D1:C0",
    "advertising": [2, 1, 6, 3, 3, 15, 24, 8, 9, 66, 97, 116, 116, 101, 114, 121],
    "rssi": -55
}
```

After connecting, the peripheral object also includes service, characteristic and descriptor information.

```json
{
    "name": "Battery Demo",
    "id": "20:FF:D0:FF:D1:C0",
    "advertising": [2, 1, 6, 3, 3, 15, 24, 8, 9, 66, 97, 116, 116, 101, 114, 121],
    "rssi": -55,
    "services": ["1800", "1801", "180f"],
    "characteristics": [
        {
            "service": "1800",
            "characteristic": "2a00",
            "properties": ["Read"]
        },
        {
            "service": "1800",
            "characteristic": "2a01",
            "properties": ["Read"]
        },
        {
            "service": "1801",
            "characteristic": "2a05",
            "properties": ["Read"]
        },
        {
            "service": "180f",
            "characteristic": "2a19",
            "properties": ["Read"],
            "descriptors": [
                {
                    "uuid": "2901"
                },
                {
                    "uuid": "2904"
                }
            ]
        }
    ]
}
```

# Advertising Data

Bluetooth advertising data is returned in when scanning for devices. The format varies depending on your platform. On Android advertising data will be the raw advertising bytes. iOS does not allow access to raw advertising data, so a dictionary of data is returned.

The advertising information for both Android and iOS appears to be a combination of advertising data and scan response data.

To get consistent advertising data payloads across platforms, you can use
the [ble-central-advertisements](https://github.com/jospete/ble-central-advertisements) module.

## Android

```json
{
    "name": "demo",
    "id": "00:1A:7D:DA:71:13",
    "advertising": ArrayBuffer,
    "rssi": -37
    "connectable":"true" /*Only on Android >= API Level 26*/
}
```

Convert the advertising info to a Uint8Array for processing. `var adData = new Uint8Array(peripheral.advertising)`. You application is responsible for parsing all the information out of the advertising ArrayBuffer using the [GAP type constants](https://www.bluetooth.com/specifications/assigned-numbers/generic-access-profile). For example to get the service data from the advertising info, I [parse the advertising info into a map](https://github.com/don/ITP-BluetoothLE/blob/887511c375b1ab2fbef3afe210d6a6b7db44cee9/phonegap/thermometer_v2/www/js/index.js#L18-L39) and then get the service data to retrieve a [characteristic value that is being broadcast](https://github.com/don/ITP-BluetoothLE/blob/887511c375b1ab2fbef3afe210d6a6b7db44cee9/phonegap/thermometer_v2/www/js/index.js#L93-L103).

## iOS

Note that iOS uses the string value of the constants for the [Advertisement Data Retrieval Keys](https://developer.apple.com/library/ios/documentation/CoreBluetooth/Reference/CBCentralManagerDelegate_Protocol/index.html#//apple_ref/doc/constant_group/Advertisement_Data_Retrieval_Keys). This will likely change in the future.

```json
{
    "name": "demo"
    "id": "15B4F1C5-C9C0-4441-BD9F-1A7ED8F7A365",
    "advertising": {
        "kCBAdvDataLocalName": "demo",
        "kCBAdvDataManufacturerData": {}, // arraybuffer data not shown
        "kCBAdvDataServiceUUIDs": [
            "721b"
        ],
        "kCBAdvDataIsConnectable": true,
        "kCBAdvDataServiceData": {
            "BBB0": {}   // arraybuffer data not shown
        },
    },
    "rssi": -61
}
```

Some of the values such as `kCBAdvDataManufacturerData` are `ArrayBuffers`. The data won't print out, but you can convert it to bytes using `new Uint8Array(peripheral.advertisting.kCBAdvDataManufacturerData)`. Your application is responsible for parsing and decoding any binary data such as `kCBAdvDataManufacturerData` or `kCBAdvDataServiceData`.

```javascript
function onDiscoverDevice(device) {
    // log the device as JSON
    console.log('Found Device', JSON.stringify(device, null, 2));

    // on iOS, print the manufacturer data if it exists
    if (device.advertising && device.advertising.kCBAdvDataManufacturerData) {
        const mfgData = new Uint8Array(device.advertising.kCBAdvDataManufacturerData);
        console.log('Manufacturer Data is', mfgData);
    }
}

ble.scan([], 5, onDiscoverDevice, onError);
```

## Browser

### Chrome

Enable: chrome://flags/#enable-experimental-web-platform-features and
chrome://flags/#enable-web-bluetooth-new-permissions-backend

Scan must be initiated from a user action (click, touch, etc).

# Typed Arrays

This plugin uses typed Arrays or ArrayBuffers for sending and receiving data.

This means that you need convert your data to ArrayBuffers before sending and from ArrayBuffers when receiving.

```javascript
// ASCII only
function stringToBytes(string) {
    var array = new Uint8Array(string.length);
    for (var i = 0, l = string.length; i < l; i++) {
        array[i] = string.charCodeAt(i);
    }
    return array.buffer;
}

// ASCII only
function bytesToString(buffer) {
    return String.fromCharCode.apply(null, new Uint8Array(buffer));
}
```

You can read more about typed arrays in these articles on [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Typed_arrays) and [HTML5 Rocks](http://www.html5rocks.com/en/tutorials/webgl/typed_arrays/).

# UUIDs

UUIDs are always strings and not numbers. Some 16-bit UUIDs, such as '2220' look like integers, but they're not. (The integer 2220 is 0x8AC in hex.) This isn't a problem with 128 bit UUIDs since they look like strings 82b9e6e1-593a-456f-be9b-9215160ebcac. All 16-bit UUIDs should also be passed to methods as strings.

<a name="background-notifications-on-ios">

# Background Scanning and Notifications on iOS

Android applications will continue to receive notification while the application is in the background.

iOS applications need additional configuration to allow Bluetooth to run in the background.

Add a new section to config.xml

```xml
<platform name="ios">
    <config-file parent="UIBackgroundModes" target="*-Info.plist">
        <array>
            <string>bluetooth-central</string>
        </array>
    </config-file>
</platform>
```

See [ble-background](https://github.com/don/ble-background) example project for more details.

Additionally, iOS state restoration should be enabled if long-running scans or connects should be restarted after the phone is rebooted or the app is suspended by iOS. See [iOS restore state](https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/CoreBluetoothBackgroundProcessingForIOSApps/PerformingTasksWhileYourAppIsInTheBackground.html#//apple_ref/doc/uid/TP40013257-CH7-SW13) for the details and limitations of this feature.

To activate iOS state restoration, set the BLUETOOTH_RESTORE_STATE to true when adding the plugin to the project:

    --variable BLUETOOTH_RESTORE_STATE=true

By default, the app id (otherwise known as the bundle identifier) will be used as the iOS restore identifier key. This can be overridden by setting the variable to the desired key directly. For example:

    --variable BLUETOOTH_RESTORE_STATE=my.custom.restoration.identifier.key

It's important to note that iOS will **not** automatically relaunch an application under some conditions. For a detailed list of these conditions, see the [iOS Technical QA on the subject](https://developer.apple.com/library/archive/qa/qa1962/_index.html).

# Testing the Plugin

Tests require the [Cordova Plugin Test Framework](https://github.com/apache/cordova-plugin-test-framework)

Create a new project

    git clone https://github.com/don/cordova-plugin-ble-central
    cordova create ble-test com.example.ble.test BLETest
    cd ble-test
    cordova platform add android
    cordova plugin add ../cordova-plugin-ble-central
    cordova plugin add ../cordova-plugin-ble-central/tests
    cordova plugin add cordova-plugin-test-framework

Change the start page in `config.xml`

    <content src="cdvtests/index.html" />

Run the app on your phone

    cordova run android --device

# Release process

## Pre-release

1.  `npm version prepatch --preid=alpha`
2.  Align `plugin.xml` version with npm version
3.  `npm publish --tag alpha`

## Release

1.  `npm version patch`
2.  `npm publish`

## Release (slim)

1.  `git merge master`
2.  Align `package.json` and `plugin.xml` versions
3.  `npm publish --tag slim`

# Nordic DFU

If you need Nordic DFU capability, Tomáš Bedřich has a [fork](https://github.com/fxe-gear/cordova-plugin-ble-central) of this plugin that adds an `updateFirmware()` method that allows users to upgrade nRF5x based chips over the air. https://github.com/fxe-gear/cordova-plugin-ble-central

# License

Apache 2.0

# Feedback

Try the code. If you find an problem or missing feature, file an issue or create a pull request.

# Other Bluetooth Plugins

-   [cordova-plugin-ble-peripheral](https://github.com/don/cordova-plugin-ble-peripheral) - Create and publish Bluetooth LE services on iOS and Android using Javascript.
-   [BluetoothSerial](https://github.com/don/BluetoothSerial) - Connect to Arduino and other devices. Bluetooth Classic on Android, BLE on iOS.
-   [RFduino](https://github.com/don/cordova-plugin-rfduino) - RFduino specific plugin for iOS and Android.
-   [BluetoothLE](https://github.com/randdusing/BluetoothLE) - Rand Dusing's BLE plugin for Cordova
-   [PhoneGap Bluetooth Plugin](https://github.com/tanelih/phonegap-bluetooth-plugin) - Bluetooth classic pairing and connecting for Android
