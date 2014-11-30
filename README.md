# Bluetooth Low Energy Central Plugin for Apache Cordova

This plugin enables communication between a phone and Bluetooth Low Energy (BLE) peripherals. Simultaneous connections to multiple peripherals are supported

## Philosophy

The goal of this plugin is to provide a simple [JavaScript API](#api) for Bluetooth Central devices. The API should be common across all platforms.

 * Scan for peripherals
 * Connect to a peripheral
 * Read the value of a characteristic
 * Write new value to a characteristic
 * Get notified when characteristic's value changes

All access is via service and characteristic UUIDs. The plugin manages handles internally.

See the [examples](https://github.com/don/cordova-plugin-ble-central/tree/master/examples) for ideas on how this plugin can be used.

## Supported Platforms

* iOS
* Android (4.3 or greater)

## Limitations

This is an early version of plugin, the API is likely to change.

 * All services are discovered, this can be slow, especially on iOS
 * Implementation doesn't stop you from scanning during a scan
 * Indicate is not implemented

# Installing

Install with Cordova CLI

    $ cd /path/to/your/project
    $ cordova plugin add com.megster.cordova.ble

# API

## Methods

- [ble.scan](#scan)

- [ble.connect](#connect)
- [ble.disconnect](#disconnect)

- [ble.read](#read)
- [ble.write](#write)
- [ble.writeWithoutResponse](#writewithoutresponse)

- [ble.notify](#notify)
- [ble.indicate](#indicate)

- [ble.isEnabled](#isenabled)
- [ble.isConnected](#isconnected)


## scan

Scan and discover BLE peripherals.

    ble.scan(services, seconds, success, failure);

### Description

Function `scan` scans for BLE devices.  The success callback is called each time a peripheral is discovered.

    {
        "name": "TI SensorTag",
        "id": "BD922605-1B07-4D55-8D09-B66653E51BBA",
        "rssi": -79,
        "advertising": /* ArrayBuffer or map */
    }

Advertising information format varies depending on your platform. See [Advertising Data](#advertising-data) for more information.

### Parameters

- __services__: List of services to discover, or [] to find all devices
- __seconds__: Number of seconds to run discovery
- __success__: Success callback function that is invoked with a list of bonded devices.
- __failure__: Error callback function, invoked when error occurs. [optional]

### Quick Example

    ble.scan([], 5, function(device) {
        console.log(JSON.stringify(device));
    }, failure);


## connect

Connect to a peripheral.

    ble.connect(device_id, connectSuccess, connectFailure);

### Description

Function `connect` connects to a BLE peripheral. The callback is long running. Success will be called when the connection is successful. Service and characteristic info will be passed to the success callback in the [peripheral object](#peripheral-data). Failure is called if the connection fails, or later if the connection disconnects. An error message is passed to the failure callback.

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

    ble.read(device_id, service_uuid, characteristic_uuid, success, failure) {;

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

    ble.write(device_id, service_uuid, characteristic_uuid, value, success, failure);

### Description

Function `write` writes data to a characteristic.

### Parameters
- __device_id__: UUID or MAC address of the peripheral
- __service_uuid__: UUID of the BLE service
- __characteristic_uuid__: UUID of the BLE characteristic
- __data__: binary data, use an [ArrayBuffer](#typed-arrays)
- __success__: Success callback function that is invoked when the connection is successful. [optional]
- __failure__: Error callback function, invoked when error occurs. [optional]

## writeWithoutResponse

Writes data to a characteristic without confirmation from the peripheral.

    ble.writeCommand(device_id, service_uuid, characteristic_uuid, value, success, failure);

### Description

Function `writeWithoutResponse` writes data to a characteristic without a response from the peripheral. You are not notified if the write fails in the BLE stack. The success callback is be called when the characteristic is written.

### Parameters
- __device_id__: UUID or MAC address of the peripheral
- __service_uuid__: UUID of the BLE service
- __characteristic_uuid__: UUID of the BLE characteristic
- __data__: binary data, use an [ArrayBuffer](#typed-arrays)
- __success__: Success callback function that is invoked when the connection is successful. [optional]
- __failure__: Error callback function, invoked when error occurs. [optional]

## notify

Register to be notified when the value of a characteristic changes.

    ble.notify(device_id, service_uuid, characteristic_uuid, success, failure) {;

### Description

Function `notify` registers a callback that is called when the value of the characteristic changes.

Raw data is passed from native code to the success callback as an [ArrayBuffer](#typed-arrays).

### Parameters

- __device_id__: UUID or MAC address of the peripheral
- __service_uuid__: UUID of the BLE service
- __characteristic_uuid__: UUID of the BLE characteristic
- __success__: Success callback function that is invoked when the connection is successful. [optional]
- __failure__: Error callback function, invoked when error occurs. [optional]

## indicate

Register for an indication when the value of a characteristic changes.

    ble.indicate(device_id, service_uuid, characteristic_uuid, success, failure) {;

### Description

Function `indicate` registers a callback that is called when the value of the characteristic changes. Indicate is similar to notify, except indicate sends a confirmation back to the peripheral when the value is read.

Raw data is passed from native code to the success callback as an [ArrayBuffer](#typed-arrays).

### Parameters

- __device_id__: UUID or MAC address of the peripheral
- __service_uuid__: UUID of the BLE service
- __characteristic_uuid__: UUID of the BLE characteristic
- __success__: Success callback function that is invoked when the connection is successful. [optional]
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

- __success__: Success callback function that is invoked with a boolean for connected status.
- __failure__: Error callback function, invoked when error occurs. [optional]

### Quick Example

    ble.isEnabled(
        function() {
            console.log("Bluetooth is enabled");
        },
        function() {
            console.log("Bluetooth is *not* enabled");
        }
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
                    "byteLength": 7 /* data not shown */
                }
            },
            "kCBAdvDataLocalName": "demo",
            "kCBAdvDataServiceUUIDs": ["FED8"],
            "kCBAdvDataManufacturerData": {
                "byteLength": 7  /* data not shown */
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

# License

Apache 2.0

# Feedback

Try the code. If you find an problem or missing feature, file an issue or create a pull request.

# Other Bluetooth Plugins

 * [BluetoothSerial](https://github.com/don/BluetoothSerial) - Connect to Arduino and other devices. Bluetooth Classic on Android, BLE on iOS.
 * [RFduino](https://github.com/don/cordova-plugin-rfduino) - RFduino specific plugin for iOS and Android.
 * [BluetoothLE](https://github.com/randdusing/BluetoothLE) - Rand Dusing's BLE plugin for Cordova
 * [PhoneGap Bluetooth Plugin](https://github.com/tanelih/phonegap-bluetooth-plugin) - Bluetooth classic pairing and connecting for Android
