# Bluetooth Low Energy (BLE) Central Plugin for Apache Cordova

This plugin enables communication between a phone and Bluetooth Low Energy (BLE) peripherals.

The plugin provides a simple [JavaScript API](#api) for iOS and Android.

 * Scan for peripherals
 * Connect to a peripheral
 * Read the value of a characteristic
 * Write new value to a characteristic
 * Get notified when characteristic's value changes

Advertising information is returned when scanning for peripherals.
Service, characteristic, and property info is returned when connecting to a peripheral.
All access is via service and characteristic UUIDs. The plugin manages handles internally.

Simultaneous connections to multiple peripherals are supported.

See the [examples](https://github.com/don/cordova-plugin-ble-central/tree/master/examples) for ideas on how this plugin can be used.

## Supported Platforms

* iOS
* Android (4.3 or greater)

# Installing

### Cordova

    $ cordova plugin add cordova-plugin-ble-central

### PhoneGap

    $ phonegap plugin add cordova-plugin-ble-central

### PhoneGap Build

Edit config.xml to install the plugin for [PhoneGap Build](http://build.phonegap.com).

    <gap:plugin name="cordova-plugin-ble-central" source="npm" />
    <preference name="phonegap-version" value="cli-6.1.0" />

### PhoneGap Developer App

This plugin is included in iOS and Android versions of the [PhoneGap Developer App](http://app.phonegap.com/).

Note that this plugin's id changed from `com.megster.cordova.ble` to `cordova-plugin-ble-central` as part of the migration from the [Cordova plugin repo](http://plugins.cordova.io/) to [npm](https://www.npmjs.com/).

### iOS 10

For iOS 10, apps will crash unless they include usage description keys for the types of data they access. For Bluetooth, [NSBluetoothPeripheralUsageDescription](https://developer.apple.com/library/prerelease/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW20) must be defined.

This can be done when the plugin is installed using the BLUETOOTH_USAGE_DESCRIPTION variable.

    $ cordova plugin add cordova-plugin-ble-central --variable BLUETOOTH_USAGE_DESCRIPTION="Your description here"

# API

## Methods

- [ble.scan](#scan)
- [ble.startScan](#startscan)
- [ble.startScanWithOptions](#startscanwithoptions)
- [ble.stopScan](#stopscan)
- [ble.connect](#connect)
- [ble.disconnect](#disconnect)
- [ble.read](#read)
- [ble.write](#write)
- [ble.writeWithoutResponse](#writewithoutresponse)
- [ble.startNotification](#startnotification)
- [ble.stopNotification](#stopnotification)
- [ble.isEnabled](#isenabled)
- [ble.isConnected](#isconnected)
- [ble.startStateNotifications](#startstatenotifications)
- [ble.stopStateNotifications](#stopstatenotifications)
- [ble.showBluetoothSettings](#showbluetoothsettings)
- [ble.enable](#enable)
- [ble.readRSSI](#readrssi)

## scan

Scan and discover BLE peripherals.

    ble.scan(services, seconds, success, failure);

### Description

Function `scan` scans for BLE devices.  The success callback is called each time a peripheral is discovered. Scanning automatically stops after the specified number of seconds.

    {
        "name": "TI SensorTag",
        "id": "BD922605-1B07-4D55-8D09-B66653E51BBA",
        "rssi": -79,
        "advertising": /* ArrayBuffer or map */
    }

Advertising information format varies depending on your platform. See [Advertising Data](#advertising-data) for more information.

*Note* in Android SDK >= 23, Location Services must be enabled. If it has not been enabled, the scan method will return no results even when BLE devices are in proximity.

### Parameters

- __services__: List of services to discover, or [] to find all devices
- __seconds__: Number of seconds to run discovery
- __success__: Success callback function that is invoked which each discovered device.
- __failure__: Error callback function, invoked when error occurs. [optional]

### Quick Example

    ble.scan([], 5, function(device) {
        console.log(JSON.stringify(device));
    }, failure);

## startScan

Scan and discover BLE peripherals.

    ble.startScan(services, success, failure);

### Description

Function `startScan` scans for BLE devices.  The success callback is called each time a peripheral is discovered. Scanning will continue until `stopScan` is called.

    {
        "name": "TI SensorTag",
        "id": "BD922605-1B07-4D55-8D09-B66653E51BBA",
        "rssi": -79,
        "advertising": /* ArrayBuffer or map */
    }

Advertising information format varies depending on your platform. See [Advertising Data](#advertising-data) for more information.

*Note* cf. note above about Location Services in Android SDK >= 23.

### Parameters

- __services__: List of services to discover, or [] to find all devices
- __success__: Success callback function that is invoked which each discovered device.
- __failure__: Error callback function, invoked when error occurs. [optional]

### Quick Example

    ble.startScan([], function(device) {
        console.log(JSON.stringify(device));
    }, failure);

    setTimeout(ble.stopScan,
        5000,
        function() { console.log("Scan complete"); },
        function() { console.log("stopScan failed"); }
    );

## startScanWithOptions

Scan and discover BLE peripherals, specifying scan options.

    ble.startScanWithOptions(services, options, success, failure);

### Description

Function `startScanWithOptions` scans for BLE devices. It operates similarly to the `startScan` function, but allows you to specify extra options (like allowing duplicate device reports).  The success callback is called each time a peripheral is discovered. Scanning will continue until `stopScan` is called.

    {
        "name": "TI SensorTag",
        "id": "BD922605-1B07-4D55-8D09-B66653E51BBA",
        "rssi": -79,
        "advertising": /* ArrayBuffer or map */
    }

Advertising information format varies depending on your platform. See [Advertising Data](#advertising-data) for more information.

### Parameters

- __services__: List of services to discover, or [] to find all devices
- __options__: an object specifying a set of name-value pairs. The currently acceptable options are:
- _reportDuplicates_: true if duplicate devices should be reported, false (default) if devices should only be reported once. [optional]
- __success__: Success callback function that is invoked which each discovered device.
- __failure__: Error callback function, invoked when error occurs. [optional]

### Quick Example

    ble.startScan([],
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


## stopScan

Stop scanning for BLE peripherals.

    ble.stopScan(success, failure);

### Description

Function `stopScan` stops scanning for BLE devices.

### Parameters

- __success__: Success callback function, invoked when scanning is stopped. [optional]
- __failure__: Error callback function, invoked when error occurs. [optional]

### Quick Example

    ble.startScan([], function(device) {
        console.log(JSON.stringify(device));
    }, failure);

    setTimeout(ble.stopScan,
        5000,
        function() { console.log("Scan complete"); },
        function() { console.log("stopScan failed"); }
    );

    /* Alternate syntax
    setTimeout(function() {
        ble.stopScan(
            function() { console.log("Scan complete"); },
            function() { console.log("stopScan failed"); }
        );
    }, 5000);
    */

## connect

Connect to a peripheral.

    ble.connect(device_id, connectSuccess, connectFailure);

### Description

Function `connect` connects to a BLE peripheral. The callback is long running. Success will be called when the connection is successful. Service and characteristic info will be passed to the success callback in the [peripheral object](#peripheral-data). Failure is called if the connection fails, or later if the peripheral disconnects. An peripheral object is passed to the failure callback.

[ble.scan](#scan) must be called before calling connect, so the plugin has a list of avaiable peripherals.

__NOTE__: the connect failure callback will be called if the peripheral disconnects.

### Parameters

- __device_id__: UUID or MAC address of the peripheral
- __connectSuccess__: Success callback function that is invoked when the connection is successful.
- __connectFailure__: Error callback function, invoked when error occurs or the connection disconnects.

## disconnect

Disconnect.

    ble.disconnect(device_id, [success], [failure]);

### Description

Function `disconnect` disconnects the selected device.

### Parameters

- __device_id__: UUID or MAC address of the peripheral
- __success__: Success callback function that is invoked when the connection is successful. [optional]
- __failure__: Error callback function, invoked when error occurs. [optional]

## read

Reads the value of a characteristic.

    ble.read(device_id, service_uuid, characteristic_uuid, success, failure);

### Description

Function `read` reads the value of the characteristic.

Raw data is passed from native code to the callback as an [ArrayBuffer](#typed-arrays).

### Parameters

- __device_id__: UUID or MAC address of the peripheral
- __service_uuid__: UUID of the BLE service
- __characteristic_uuid__: UUID of the BLE characteristic
- __success__: Success callback function that is invoked when the connection is successful. [optional]
- __failure__: Error callback function, invoked when error occurs. [optional]

## write

Writes data to a characteristic.

    ble.write(device_id, service_uuid, characteristic_uuid, data, success, failure);

### Description

Function `write` writes data to a characteristic.

### Parameters
- __device_id__: UUID or MAC address of the peripheral
- __service_uuid__: UUID of the BLE service
- __characteristic_uuid__: UUID of the BLE characteristic
- __data__: binary data, use an [ArrayBuffer](#typed-arrays)
- __success__: Success callback function that is invoked when the connection is successful. [optional]
- __failure__: Error callback function, invoked when error occurs. [optional]

### Quick Example

Use an [ArrayBuffer](#typed-arrays) when writing data.

    // send 1 byte to switch a light on
    var data = new Uint8Array(1);
    data[0] = 1;
    ble.write(device_id, "FF10", "FF11", data.buffer, success, failure);

    // send a 3 byte value with RGB color
    var data = new Uint8Array(3);
    data[0] = 0xFF; // red
    data[1] = 0x00; // green
    data[2] = 0xFF; // blue
    ble.write(device_id, "ccc0", "ccc1", data.buffer, success, failure);

    // send a 32 bit integer
    var data = new Uint32Array(1);
    data[0] = counterInput.value;
    ble.write(device_id, SERVICE, CHARACTERISTIC, data.buffer, success, failure);

## writeWithoutResponse

Writes data to a characteristic without confirmation from the peripheral.

    ble.writeWithoutResponse(device_id, service_uuid, characteristic_uuid, data, success, failure);

### Description

Function `writeWithoutResponse` writes data to a characteristic without a response from the peripheral. You are not notified if the write fails in the BLE stack. The success callback is be called when the characteristic is written.

### Parameters
- __device_id__: UUID or MAC address of the peripheral
- __service_uuid__: UUID of the BLE service
- __characteristic_uuid__: UUID of the BLE characteristic
- __data__: binary data, use an [ArrayBuffer](#typed-arrays)
- __success__: Success callback function that is invoked when the connection is successful. [optional]
- __failure__: Error callback function, invoked when error occurs. [optional]

## startNotification

Register to be notified when the value of a characteristic changes.

    ble.startNotification(device_id, service_uuid, characteristic_uuid, success, failure);

### Description

Function `startNotification` registers a callback that is called *every time* the value of a characteristic changes. This method handles both `notifications` and `indications`. The success callback is called multiple times.

Raw data is passed from native code to the success callback as an [ArrayBuffer](#typed-arrays).

See [Background Notifications on iOS](#background-notifications-on-ios)

### Parameters

- __device_id__: UUID or MAC address of the peripheral
- __service_uuid__: UUID of the BLE service
- __characteristic_uuid__: UUID of the BLE characteristic
- __success__: Success callback function invoked every time a notification occurs
- __failure__: Error callback function, invoked when error occurs. [optional]

### Quick Example

    var onData = function(buffer) {
        // Decode the ArrayBuffer into a typed Array based on the data you expect
        var data = new Uint8Array(buffer);
        alert("Button state changed to " + data[0]);
    }

    ble.startNotification(device_id, "FFE0", "FFE1", onData, failure);

## stopNotification

Stop being notified when the value of a characteristic changes.

    ble.stopNotification(device_id, service_uuid, characteristic_uuid, success, failure);

### Description

Function `stopNotification` stops a previously registered notification callback.

### Parameters

- __device_id__: UUID or MAC address of the peripheral
- __service_uuid__: UUID of the BLE service
- __characteristic_uuid__: UUID of the BLE characteristic
- __success__: Success callback function that is invoked when the notification is removed. [optional]
- __failure__: Error callback function, invoked when error occurs. [optional]

## isConnected

Reports the connection status.

    ble.isConnected(device_id, success, failure);

### Description

Function `isConnected` calls the success callback when the peripheral is connected and the failure callback when *not* connected.

### Parameters

- __device_id__: UUID or MAC address of the peripheral
- __success__: Success callback function that is invoked with a boolean for connected status.
- __failure__: Error callback function, invoked when error occurs. [optional]

### Quick Example

    ble.isConnected(
        'FFCA0B09-CB1D-4DC0-A1EF-31AFD3EDFB53',
        function() {
            console.log("Peripheral is connected");
        },
        function() {
            console.log("Peripheral is *not* connected");
        }
    );

## isEnabled

Reports if bluetooth is enabled.

    ble.isEnabled(success, failure);

### Description

Function `isEnabled` calls the success callback when Bluetooth is enabled and the failure callback when Bluetooth is *not* enabled.

### Parameters

- __success__: Success callback function, invoked when Bluetooth is enabled.
- __failure__: Error callback function, invoked when Bluetooth is disabled.

### Quick Example

    ble.isEnabled(
        function() {
            console.log("Bluetooth is enabled");
        },
        function() {
            console.log("Bluetooth is *not* enabled");
        }
    );

## startStateNotifications

Registers to be notified when Bluetooth state changes on the device.

    ble.startStateNotifications(success, failure);

### Description

Function `startStateNotifications` calls the success callback when the Bluetooth is enabled or disabled on the device.

__States__

- "on"
- "off"
- "turningOn" (Android Only)
- "turningOff" (Android Only)
- "unknown" (iOS Only)
- "resetting" (iOS Only)
- "unsupported" (iOS Only)
- "unauthorized" (iOS Only)

### Parameters

- __success__: Success callback function that is invoked with a string for the Bluetooth state.
- __failure__: Error callback function, invoked when error occurs. [optional]

### Quick Example

    ble.startStateNotifications(
        function(state) {
            console.log("Bluetooth is " + state);
        }
    );

## stopStateNotifications

Stops state notifications.

    ble.stopStateNotifications(success, failure);

### Description

Function `stopStateNotifications` calls the success callback when Bluetooth state notifications have been stopped.

## showBluetoothSettings

Show the Bluetooth settings on the device.

    ble.showBluetoothSettings(success, failure);

### Description

Function `showBluetoothSettings` opens the Bluetooth settings for the operating systems.

#### iOS

`showBluetoothSettings` is not supported on iOS.

### Parameters

- __success__: Success callback function [optional]
- __failure__: Error callback function, invoked when error occurs. [optional]

### Quick Example

    ble.showBluetoothSettings();

## enable

Enable Bluetooth on the device.

    ble.enable(success, failure);

### Description

Function `enable` prompts the user to enable Bluetooth.

#### Android

`enable` is only supported on Android and does not work on iOS.

If `enable` is called when Bluetooth is already enabled, the user will not prompted and the success callback will be invoked.

### Parameters

- __success__: Success callback function, invoked if the user enabled Bluetooth.
- __failure__: Error callback function, invoked if the user does not enabled Bluetooth.

### Quick Example

    ble.enable(
        function() {
            console.log("Bluetooth is enabled");
        },
        function() {
            console.log("The user did *not* enable Bluetooth");
        }
    );

## readRSSI

Read the RSSI value on the device connection.

    ble.readRSSI(device_id, success, failure);

### Description

Samples the RSSI value (a measure of signal strength) on the connection to a bluetooth device. Requires that you have established a connection before invoking (otherwise an error will be raised).

### Parameters

- __device_id__: device identifier
- __success__: Success callback function, invoked with the RSSI value (as an integer)
- __failure__: Error callback function, invoked if there is no current connection or if there is an error reading the RSSI.

### Quick Example
    var rssiSample;
    ble.connect(device_id,
        function(device) {
            rssiSample = setInterval(function() {
                    ble.readRSSI(device_id, function(rssi) {
                            console.log('read RSSI',rssi,'with device', device_id);
                        }, function(err) {
                            console.error('unable to read RSSI',err);
                            clearInterval(rssiSample);
                            })
                }, 5000);
        },
        function(err) { console.error('error connecting to device')}
        );

# Peripheral Data

Peripheral Data is passed to the success callback when scanning and connecting. Limited data is passed when scanning.

    {
        "name": "Battery Demo",
        "id": "20:FF:D0:FF:D1:C0",
        "advertising": [2,1,6,3,3,15,24,8,9,66,97,116,116,101,114,121],
        "rssi": -55
    }

After connecting, the peripheral object also includes service, characteristic and descriptor information.

    {
        "name": "Battery Demo",
        "id": "20:FF:D0:FF:D1:C0",
        "advertising": [2,1,6,3,3,15,24,8,9,66,97,116,116,101,114,121],
        "rssi": -55,
        "services": [
            "1800",
            "1801",
            "180f"
        ],
        "characteristics": [
            {
                "service": "1800",
                "characteristic": "2a00",
                "properties": [
                    "Read"
                ]
            },
            {
                "service": "1800",
                "characteristic": "2a01",
                "properties": [
                    "Read"
                ]
            },
            {
                "service": "1801",
                "characteristic": "2a05",
                "properties": [
                    "Read"
                ]
            },
            {
                "service": "180f",
                "characteristic": "2a19",
                "properties": [
                    "Read"
                ],
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


# Advertising Data

Bluetooth advertising data is returned in when scanning for devices. The format format varies depending on your platform. On Android advertising data will be the raw advertising bytes. iOS does not allow access to raw advertising data, so a dictionary of data is returned.

The advertising information for both Android and iOS appears to be a combination of advertising data and scan response data.

Ideally a common format (map or array) would be returned for both platforms in future versions. If you have ideas, please contact me.

## Android

    {
        "name": "demo",
        "id": "00:1A:7D:DA:71:13",
        "advertising": ArrayBuffer,
        "rssi": -37
    }

Convert the advertising info to a Uint8Array for processing. `var adData = new Uint8Array(peripheral.advertising)`

## iOS

Note that iOS uses the string value of the constants for the [Advertisement Data Retrieval Keys](https://developer.apple.com/library/ios/documentation/CoreBluetooth/Reference/CBCentralManagerDelegate_Protocol/index.html#//apple_ref/doc/constant_group/Advertisement_Data_Retrieval_Keys). This will likely change in the future.

    {
        "name": "demo",
        "id": "D8479A4F-7517-BCD3-91B5-3302B2F81802",
        "advertising": {
            "kCBAdvDataChannel": 37,
            "kCBAdvDataServiceData": {
                "FED8": {
                    "byteLength": 7 // data not shown
                }
            },
            "kCBAdvDataLocalName": "demo",
            "kCBAdvDataServiceUUIDs": ["FED8"],
            "kCBAdvDataManufacturerData": {
                "byteLength": 7  // data not shown
            },
            "kCBAdvDataTxPowerLevel": 32,
            "kCBAdvDataIsConnectable": true
        },
        "rssi": -53
    }

# Typed Arrays

This plugin uses typed Arrays or ArrayBuffers for sending and receiving data.

This means that you need convert your data to ArrayBuffers before sending and from ArrayBuffers when receiving.

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

You can read more about typed arrays in these articles on [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Typed_arrays) and [HTML5 Rocks](http://www.html5rocks.com/en/tutorials/webgl/typed_arrays/).

# UUIDs

UUIDs are always strings and not numbers. Some 16-bit UUIDs, such as '2220' look like integers, but they're not. (The integer 2220 is 0x8AC in hex.) This isn't a problem with 128 bit UUIDs since they look like strings 82b9e6e1-593a-456f-be9b-9215160ebcac. All 16-bit UUIDs should also be passed to methods as strings.

<a name="background-notifications-on-ios">
# Background Scanning and Notifications on iOS

Android applications will continue to receive notification while the application is in the background.

iOS applications need additional configuration to allow Bluetooth to run in the background.

Install the [cordova-custom-config](https://www.npmjs.com/package/cordova-custom-config) plugin.

    cordova plugin add cordova-custom-config

Add a new section to config.xml

    <platform name="ios">
        <config-file parent="UIBackgroundModes" target="*-Info.plist">
            <array>
                <string>bluetooth-central</string>
            </array>
        </config-file>
    </platform>
    
See [ble-background](https://github.com/don/ble-background) example project for more details.
    
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

# License

Apache 2.0

# Feedback

Try the code. If you find an problem or missing feature, file an issue or create a pull request.

# Other Bluetooth Plugins

 * [BluetoothSerial](https://github.com/don/BluetoothSerial) - Connect to Arduino and other devices. Bluetooth Classic on Android, BLE on iOS.
 * [RFduino](https://github.com/don/cordova-plugin-rfduino) - RFduino specific plugin for iOS and Android.
 * [BluetoothLE](https://github.com/randdusing/BluetoothLE) - Rand Dusing's BLE plugin for Cordova
 * [PhoneGap Bluetooth Plugin](https://github.com/tanelih/phonegap-bluetooth-plugin) - Bluetooth classic pairing and connecting for Android
