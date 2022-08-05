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

/* global cordova, module */
'use strict';

var stringToArrayBuffer = function (str) {
    var ret = new Uint8Array(str.length);
    for (var i = 0; i < str.length; i++) {
        ret[i] = str.charCodeAt(i);
    }
    return ret.buffer;
};

var base64ToArrayBuffer = function (b64) {
    return stringToArrayBuffer(atob(b64));
};

function massageMessageNativeToJs(message) {
    if (message.CDVType == 'ArrayBuffer') {
        message = base64ToArrayBuffer(message.data);
    }
    return message;
}

// Cordova 3.6 doesn't unwrap ArrayBuffers in nested data structures
// https://github.com/apache/cordova-js/blob/94291706945c42fd47fa632ed30f5eb811080e95/src/ios/exec.js#L107-L122
function convertToNativeJS(object) {
    Object.keys(object).forEach(function (key) {
        var value = object[key];
        object[key] = massageMessageNativeToJs(value);
        if (typeof value === 'object') {
            convertToNativeJS(value);
        }
    });
}

// set of auto-connected device ids
var autoconnected = {};

module.exports = {
    scan: function (services, seconds, success, failure) {
        var successWrapper = function (peripheral) {
            convertToNativeJS(peripheral);
            success(peripheral);
        };
        cordova.exec(successWrapper, failure, 'BLE', 'scan', [services, seconds]);
    },

    startScan: function (services, success, failure) {
        var successWrapper = function (peripheral) {
            convertToNativeJS(peripheral);
            success(peripheral);
        };
        cordova.exec(successWrapper, failure, 'BLE', 'startScan', [services]);
    },

    stopScan: function (success, failure) {
        cordova.exec(success, failure, 'BLE', 'stopScan', []);
    },

    startScanWithOptions: function (services, options, success, failure) {
        var successWrapper = function (peripheral) {
            convertToNativeJS(peripheral);
            success(peripheral);
        };
        options = options || {};
        cordova.exec(successWrapper, failure, 'BLE', 'startScanWithOptions', [services, options]);
    },

    // iOS only
    connectedPeripheralsWithServices: function (services, success, failure) {
        cordova.exec(success, failure, 'BLE', 'connectedPeripheralsWithServices', [services]);
    },

    // iOS only
    peripheralsWithIdentifiers: function (identifiers, success, failure) {
        cordova.exec(success, failure, 'BLE', 'peripheralsWithIdentifiers', [identifiers]);
    },

    // Android only
    bondedDevices: function (success, failure) {
        cordova.exec(success, failure, 'BLE', 'bondedDevices', []);
    },

    list: function (success, failure) {
        cordova.exec(success, failure, 'BLE', 'list', []);
    },

    connect: function (device_id, success, failure) {
        // wrap success so nested array buffers in advertising info are handled correctly
        var successWrapper = function (peripheral) {
            convertToNativeJS(peripheral);
            success(peripheral);
        };
        cordova.exec(successWrapper, failure, 'BLE', 'connect', [device_id]);
    },

    autoConnect: function (deviceId, connectCallback, disconnectCallback) {
        var disconnectCallbackWrapper;
        autoconnected[deviceId] = true;

        // wrap connectCallback so nested array buffers in advertising info are handled correctly
        var connectCallbackWrapper = function (peripheral) {
            convertToNativeJS(peripheral);
            connectCallback(peripheral);
        };

        // iOS needs to reconnect on disconnect, unless ble.disconnect was called.
        if (cordova.platformId === 'ios') {
            disconnectCallbackWrapper = function (peripheral) {
                // let the app know the peripheral disconnected
                disconnectCallback(peripheral);

                // reconnect if we have a peripheral.id and the user didn't call disconnect
                if (peripheral.id && autoconnected[peripheral.id]) {
                    cordova.exec(connectCallbackWrapper, disconnectCallbackWrapper, 'BLE', 'autoConnect', [deviceId]);
                }
            };
        } else {
            // no wrapper for Android
            disconnectCallbackWrapper = disconnectCallback;
        }

        cordova.exec(connectCallbackWrapper, disconnectCallbackWrapper, 'BLE', 'autoConnect', [deviceId]);
    },

    disconnect: function (device_id, success, failure) {
        try {
            delete autoconnected[device_id];
        } catch (e) {
            // ignore error
        }
        cordova.exec(success, failure, 'BLE', 'disconnect', [device_id]);
    },

    queueCleanup: function (device_id, success, failure) {
        cordova.exec(success, failure, 'BLE', 'queueCleanup', [device_id]);
    },

    setPin: function (pin, success, failure) {
        cordova.exec(success, failure, 'BLE', 'setPin', [pin]);
    },

    requestMtu: function (device_id, mtu, success, failure) {
        cordova.exec(success, failure, 'BLE', 'requestMtu', [device_id, mtu]);
    },

    requestConnectionPriority: function (device_id, connectionPriority, success, failure) {
        cordova.exec(success, failure, 'BLE', 'requestConnectionPriority', [device_id, connectionPriority]);
    },

    refreshDeviceCache: function (deviceId, timeoutMillis, success, failure) {
        var successWrapper = function (peripheral) {
            convertToNativeJS(peripheral);
            success(peripheral);
        };
        cordova.exec(successWrapper, failure, 'BLE', 'refreshDeviceCache', [deviceId, timeoutMillis]);
    },

    // characteristic value comes back as ArrayBuffer in the success callback
    read: function (device_id, service_uuid, characteristic_uuid, success, failure) {
        cordova.exec(success, failure, 'BLE', 'read', [device_id, service_uuid, characteristic_uuid]);
    },

    // RSSI value comes back as an integer
    readRSSI: function (device_id, success, failure) {
        cordova.exec(success, failure, 'BLE', 'readRSSI', [device_id]);
    },

    // value must be an ArrayBuffer
    write: function (device_id, service_uuid, characteristic_uuid, value, success, failure) {
        cordova.exec(success, failure, 'BLE', 'write', [device_id, service_uuid, characteristic_uuid, value]);
    },

    // value must be an ArrayBuffer
    writeWithoutResponse: function (device_id, service_uuid, characteristic_uuid, value, success, failure) {
        cordova.exec(success, failure, 'BLE', 'writeWithoutResponse', [
            device_id,
            service_uuid,
            characteristic_uuid,
            value,
        ]);
    },

    // value must be an ArrayBuffer
    writeCommand: function (device_id, service_uuid, characteristic_uuid, value, success, failure) {
        console.log('WARNING: writeCommand is deprecated, use writeWithoutResponse');
        cordova.exec(success, failure, 'BLE', 'writeWithoutResponse', [
            device_id,
            service_uuid,
            characteristic_uuid,
            value,
        ]);
    },

    // success callback is called on notification
    notify: function (device_id, service_uuid, characteristic_uuid, success, failure) {
        console.log('WARNING: notify is deprecated, use startNotification');
        cordova.exec(success, failure, 'BLE', 'startNotification', [device_id, service_uuid, characteristic_uuid]);
    },

    // success callback is called on notification
    startNotification: function (device_id, service_uuid, characteristic_uuid, success, failure, options) {
        const emitOnRegistered = options && options.emitOnRegistered == true;
        function onEvent(data) {
            if (data === 'registered') {
                // For backwards compatibility, don't emit the registered event unless explicitly instructed
                if (emitOnRegistered) success(data);
            } else {
                success(data);
            }
        }
        cordova.exec(onEvent, failure, 'BLE', 'startNotification', [device_id, service_uuid, characteristic_uuid]);
    },

    // success callback is called when the descriptor 0x2902 is written
    stopNotification: function (device_id, service_uuid, characteristic_uuid, success, failure) {
        cordova.exec(success, failure, 'BLE', 'stopNotification', [device_id, service_uuid, characteristic_uuid]);
    },

    isConnected: function (device_id, success, failure) {
        cordova.exec(success, failure, 'BLE', 'isConnected', [device_id]);
    },

    isEnabled: function (success, failure) {
        cordova.exec(success, failure, 'BLE', 'isEnabled', []);
    },

    // Android only
    isLocationEnabled: function (success, failure) {
        cordova.exec(success, failure, 'BLE', 'isLocationEnabled', []);
    },

    enable: function (success, failure) {
        cordova.exec(success, failure, 'BLE', 'enable', []);
    },

    showBluetoothSettings: function (success, failure) {
        cordova.exec(success, failure, 'BLE', 'showBluetoothSettings', []);
    },

    startLocationStateNotifications: function (success, failure) {
        cordova.exec(success, failure, 'BLE', 'startLocationStateNotifications', []);
    },

    stopLocationStateNotifications: function (success, failure) {
        cordova.exec(success, failure, 'BLE', 'stopLocationStateNotifications', []);
    },

    startStateNotifications: function (success, failure) {
        cordova.exec(success, failure, 'BLE', 'startStateNotifications', []);
    },

    stopStateNotifications: function (success, failure) {
        cordova.exec(success, failure, 'BLE', 'stopStateNotifications', []);
    },

    restoredBluetoothState: function (success, failure) {
        cordova.exec(success, failure, 'BLE', 'restoredBluetoothState', []);
    },
};

module.exports.withPromises = {
    scan: module.exports.scan,
    startScan: module.exports.startScan,
    startScanWithOptions: module.exports.startScanWithOptions,
    connect: module.exports.connect,

    stopScan: function () {
        return new Promise(function (resolve, reject) {
            module.exports.stopScan(resolve, reject);
        });
    },

    disconnect: function (device_id) {
        return new Promise(function (resolve, reject) {
            module.exports.disconnect(device_id, resolve, reject);
        });
    },

    bondedDevices: function () {
        return new Promise(function (resolve, reject) {
            module.exports.bondedDevices(resolve, reject);
        });
    },

    list: function () {
        return new Promise(function (resolve, reject) {
            module.exports.list(resolve, reject);
        });
    },

    queueCleanup: function (device_id) {
        return new Promise(function (resolve, reject) {
            module.exports.queueCleanup(device_id, resolve, reject);
        });
    },

    setPin: function (pin) {
        return new Promise(function (resolve, reject) {
            module.exports.setPin(pin, resolve, reject);
        });
    },

    read: function (device_id, service_uuid, characteristic_uuid) {
        return new Promise(function (resolve, reject) {
            module.exports.read(device_id, service_uuid, characteristic_uuid, resolve, reject);
        });
    },

    write: function (device_id, service_uuid, characteristic_uuid, value) {
        return new Promise(function (resolve, reject) {
            module.exports.write(device_id, service_uuid, characteristic_uuid, value, resolve, reject);
        });
    },

    writeWithoutResponse: function (device_id, service_uuid, characteristic_uuid, value) {
        return new Promise(function (resolve, reject) {
            module.exports.writeWithoutResponse(device_id, service_uuid, characteristic_uuid, value, resolve, reject);
        });
    },

    startNotification: function (device_id, service_uuid, characteristic_uuid, success, failure) {
        return new Promise(function (resolve, reject) {
            module.exports.startNotification(
                device_id,
                service_uuid,
                characteristic_uuid,
                (data) => {
                    resolve();
                    // Filter out registered callback
                    if (data !== 'registered') success(data);
                },
                (err) => {
                    reject(err);
                    failure(err);
                },
                { emitOnRegistered: true }
            );
        });
    },

    stopNotification: function (device_id, service_uuid, characteristic_uuid) {
        return new Promise(function (resolve, reject) {
            module.exports.stopNotification(device_id, service_uuid, characteristic_uuid, resolve, reject);
        });
    },

    isConnected: function (device_id) {
        return new Promise(function (resolve, reject) {
            module.exports.isConnected(device_id, resolve, reject);
        });
    },

    isEnabled: function () {
        return new Promise(function (resolve, reject) {
            module.exports.isEnabled(resolve, reject);
        });
    },

    enable: function () {
        return new Promise(function (resolve, reject) {
            module.exports.enable(resolve, reject);
        });
    },

    showBluetoothSettings: function () {
        return new Promise(function (resolve, reject) {
            module.exports.showBluetoothSettings(resolve, reject);
        });
    },

    startStateNotifications: function (success, failure) {
        return new Promise(function (resolve, reject) {
            module.exports.startStateNotifications(
                function (state) {
                    resolve();
                    success(state);
                },
                function (err) {
                    reject(err);
                    failure(err);
                }
            );
        });
    },

    stopStateNotifications: function () {
        return new Promise(function (resolve, reject) {
            module.exports.stopStateNotifications(resolve, reject);
        });
    },

    startLocationStateNotifications: function (change, failure) {
        return new Promise(function (resolve, reject) {
            module.exports.startLocationStateNotifications(
                function (state) {
                    resolve();
                    change(state);
                },
                function (err) {
                    reject(err);
                    failure(err);
                }
            );
        });
    },

    stopLocationStateNotifications: function () {
        return new Promise(function (resolve, reject) {
            module.exports.stopLocationStateNotifications(resolve, reject);
        });
    },

    readRSSI: function (device_id) {
        return new Promise(function (resolve, reject) {
            module.exports.readRSSI(device_id, resolve, reject);
        });
    },

    requestConnectionPriority: function (device_id, priority) {
        return new Promise(function (resolve, reject) {
            module.exports.requestConnectionPriority(device_id, priority, resolve, reject);
        });
    },

    restoredBluetoothState: function () {
        return new Promise(function (resolve, reject) {
            module.exports.restoredBluetoothState(resolve, reject);
        });
    },
};

module.exports.l2cap = {
    close(device_id, psm, success, failure) {
        cordova.exec(success, failure, 'BLE', 'closeL2Cap', [device_id, psm]);
    },

    open(device_id, psmOrOptions, connectCallback, disconnectCallback) {
        var psm = psmOrOptions;
        var settings = {};
        if (psmOrOptions != undefined && 'psm' in psmOrOptions) {
            psm = psmOrOptions.psm;
            settings = psmOrOptions;
        }
        cordova.exec(connectCallback, disconnectCallback, 'BLE', 'openL2Cap', [device_id, psm, settings]);
    },

    receiveData(device_id, psm, receive) {
        cordova.exec(receive, function () {}, 'BLE', 'receiveDataL2Cap', [device_id, psm]);
    },

    write(device_id, psm, data, success, failure) {
        cordova.exec(success, failure, 'BLE', 'writeL2Cap', [device_id, psm, data]);
    },
};

module.exports.withPromises.l2cap = {
    close(device_id, psm) {
        return new Promise(function (resolve, reject) {
            module.exports.l2cap.close(device_id, psm, resolve, reject);
        });
    },

    open(device_id, psmOrOptions, disconnectCallback) {
        return new Promise(function (resolve, reject) {
            module.exports.l2cap.open(device_id, psmOrOptions, resolve, function (e) {
                disconnectCallback(e);
                reject(e);
            });
        });
    },

    write(device_id, psm, data) {
        return new Promise(function (resolve, reject) {
            module.exports.l2cap.write(device_id, psm, data, resolve, reject);
        });
    },
};
