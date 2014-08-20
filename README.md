# Bluetooth Low Energy Central Plugin for Apache Cordova

This plugin enables communication between a phone and Bluetooth Low Energy (BLE) peripherials.

## Philosophy

The goal of this plugin is to provide a simple JavaScript API for Bluetooth Central devices. The API should be common across all platforms.

 * Scan for peripherals
 * Connect to a peripheral
 * Read the value of a characteristic
 * Write new value to a characteristic
 * Get notified when characteristic's value changes

I assume you know details about the services and characteristics that you want to use. All access is via service and characteristic UUIDs. The plugin will manage handles internally. This plugin probably won't be suitable for writing generic BLE clients.

See the examples for ideas on how this plugin can be used.

## Supported Platforms

* iOS
* Android

Android 4.3 or greater is required. Update the generated cordova project from target 17 to 18 or 19

    $ android update project -p platforms/android -t android-19

## Limitations

This is an early version of plugin, the API is likely to change.

 * Android does not queue BLE commands yet
 * iOS does not return advertising data
 * All services are discovered, this can be slow, especially on iOS. Future versions may need to pass options object to connect with desired services.
 * Android might have a hard limit of 4 notifications per connection http://processors.wiki.ti.com/index.php/SensorTag_User_Guide#Notification_limit
 * Implementation doesn't stop you from scanning during a scan
 * Indicate is not implemented

# Installing

Install with Cordova CLI

    $ cd /path/to/your/project
    $ cordova plugin add /path/to/plugin

# API

## Methods

- [ble.scan](#scan)

- [ble.connect](#connect)
- [ble.disconnect](#disconnect)

- [ble.read](#read)
- [ble.write](#write)
- [ble.writeCommand](#writecommand)

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
        "rssi": -79
    }

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

Function `connect` connects to a BLE peripheral. The callback is long running. Success will be called when the connection is successful. Failure is called if the connection fails, or later if the connection disconnects. An error message is passed to the failure callback.

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

Raw data is passed from native code to the callback as an [ArrayBuffer](http://www.html5rocks.com/en/tutorials/webgl/typed_arrays/).

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
- __data__: binary data, use an ArrayBuffer
- __success__: Success callback function that is invoked when the connection is successful. [optional]
- __failure__: Error callback function, invoked when error occurs. [optional]

## writeCommand

Writes data to a characteristic without confirmation.

    ble.writeCommand(device_id, service_uuid, characteristic_uuid, value, success, failure);

### Description

Function `write` writes data to a characteristic without a response. You are not notified if the write fails in the BLE stack.

### Parameters
- __device_id__: UUID or MAC address of the peripheral
- __service_uuid__: UUID of the BLE service
- __characteristic_uuid__: UUID of the BLE characteristic
- __data__: binary data, use an ArrayBuffer
- __success__: Success callback function that is invoked when the connection is successful. [optional]
- __failure__: Error callback function, invoked when error occurs. [optional]

## notify

Register to be notified when the value of a characteristic changes.

    ble.notify(device_id, service_uuid, characteristic_uuid, success, failure) {;

### Description

Function `notify` registers a callback that is called when the value of the characteristic changes.

Raw data is passed from native code to the success callback as an [ArrayBuffer](http://www.html5rocks.com/en/tutorials/webgl/typed_arrays/).

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

Raw data is passed from native code to the success callback as an [ArrayBuffer](http://www.html5rocks.com/en/tutorials/webgl/typed_arrays/).

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

# License

Apache 2.0

# Feedback

Try the code. If you find an problem or missing feature, file an issue or create a pull request.

# Other Bluetooth Plugins

 * [BluetoothSerial](https://github.com/don/BluetoothSerial) - Connect to Arduino and other devices. Bluetooth Classic on Android, BLE on iOS.
 * [RFduino](https://github.com/don/cordova-plugin-rfduino) - RFduino specific pluginc for iOS and Android.
 * [BluetoothLE](https://github.com/randdusing/BluetoothLE) - Rand Dusing's BLE plugin for Cordova
 * [PhoneGap Bluetooth Plugin](https://github.com/tanelih/phonegap-bluetooth-plugin) - Bluetooth classic pairing and connecting for Android