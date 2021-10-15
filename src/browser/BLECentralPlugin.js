   
function notSupported() {
    console.log('BLE is not supported on the browser');
}


function getDeviceId(device_id) {
    return device_id.startsWith('0x') ? parseInt(device_id) : device_id;
}


module.exports = {

    devices: new Map(),
    scanning: null,

    scan: function(services, success, failure) {

        if (!navigator.bluetooth) {
            failure('Bluetooth is not supported on this browser.');
            return;
        }

        this.scanning = true;

        let options = {};

        if (services && services.length) {
            options.filters = [{
                services: services.map(getDeviceId)
            }];
        } else {
            options.acceptAllDevices = true;
        }

        console.log('requestDevice', options);
        navigator.bluetooth.requestDevice(options).then(device => {
            if (this.scanning) {  
                return device.gatt.connect().then(server => {
                    this.devices.set(device.id, {
                        device: device,
                        server: server
                    })
                    success(device);
                });              
            }
        }).catch(failure);
    },
    stopScan: function(success, failure) {
        this.scanning = false;
        if (success) success();
    },
    startScanWithOptions: function(services, options, success, failure) {
        this.scanning = true;
        navigator.bluetooth.requestDevice(options).then(device => {
            if (this.scanning) {                
                success(device);
            }
        }).catch(failure);
    },
    connect: function(device_id, connectSuccess, connectFailure) {
        console.log('connect', device_id);
        if (this.devices.has(device_id)) {
            connectSuccess(this.devices.get(device_id).device);
        } else {
            navigator.bluetooth.requestDevice({filters: [{
                services: [getDeviceId(device_id)]
            }]}).then(device => {
                return device.gatt.connect().then(server => {
                    this.devices.set(device_id, {
                        device: device,
                        server: server
                    })
                    connectSuccess(device);
                });
            }).catch(connectFailure);
        }
    },
    disconnect: function(device_id, disconnectSuccess, disconnectFailure) {
        if (this.devices.has(device_id)) {
            var device = this.devices.get(device_id).device;
            this.devices.delete(device_id);
            if (device.gatt.connected) {
                device.gatt.disconnect();
                disconnectSuccess(device);
            } else {
                disconnectFailure("Device not connected");
            }
        } else if (disconnectFailure) {
            disconnectFailure();
        }
    },
    read: function(device_id, service_uuid, characteristic_uuid, success, failure) {
       if (this.devices.has(device_id)) {
            this.devices.get(device_id).server.getPrimaryService(service_uuid).then(service => {
                return service.getCharacteristic(characteristic_uuid);
            }).then(characteristic => {
                return characteristic.readValue();
            }).then(result => {
                success(result);
            }).catch(error => {
                if (failure) failure(error);
            });
        } else if (failure) { 
          failure();
        }
    },
    readRSSI: function(device_id, success, failure) {
        notSupported();
        if (failure) failure();
    },
    write: function(device_id, service_uuid, characteristic_uuid, data, success, failure) {
        if (this.devices.has(device_id)) {
            this.devices.get(device_id).server.getPrimaryService(service_uuid).then(service => {
                return service.getCharacteristic(characteristic_uuid);
            }).then(characteristic => {
                return characteristic.writeValue(data);
            }).then(result => {
                success(result);
            }).catch(error => {
                if (failure) failure(error);
            });
        } else if (failure) { 
          failure();
        }
    },
    writeWithoutResponse: function(device_id, service_uuid, characteristic_uuid, data, success, failure) {
        if (this.devices.has(device_id)) {
            this.devices.get(device_id).server.getPrimaryService(service_uuid).then(service => {
                return service.getCharacteristic(characteristic_uuid);
            }).then(characteristic => {
                return characteristic.writeValue(data);
            }).then(result => {
                success(result);
            }).catch(error => {
                // Ignore Error 
                // failure();
            });
        } else if (failure) { 
            // Ignore Error 
            // failure();
        }
    },
    startNotification: function(device_id, service_uuid, characteristic_uuid, success, failure) {
         if (this.devices.has(device_id)) {
            this.devices.get(device_id).server.getPrimaryService(service_uuid).then(service => {
                return service.getCharacteristic(characteristic_uuid);
            }).then(characteristic => {
                return characteristic.startNotifications().then(result => {
                    characteristic.addEventListener('characteristicvaluechanged', function (event) {
                        success(event.target.value.buffer);
                    });
                });
            }).catch(error => {
                if (failure) failure(error);
            })
        } else if (failure) { 
          failure();
        }
    },
    stopNotifcation: function(device_id, service_uuid, characteristic_uuid, success, failure) {
       if (this.devices.has(device_id)) {
            this.devices.get(device_id).server.getPrimaryService(service_uuid).then(service => {
                return service.getCharacteristic(characteristic_uuid);
            }).then(characteristic => {
                return characteristic.stopNotifications();
            }).then(result => {
                success(result);
            }).catch(error => {
                if (failure) failure(error);
            });
        } else if (failure) { 
          failure();
        }
    },
    isEnabled: function(success, failure) {
        notSupported();
        if (failure) failure();
    },
    isConnected: function(device_id, success, failure) {
        if (this.devices.has(device_id)) {
            var device = this.devices.get(device_id).device;
            if (device.gatt.connected) {
                device.gatt.disconnect();
                success();
            } else {
                failure();
            }
        } else if (failure) {
            failure();
        }
    },
    showBluetoothSettings: function(success, failure) {
        notSupported();
        if (failure) failure();
    },
    enable: function(success, failure) {
        notSupported();
        if (failure) failure();
    },
    startStateNotifications: function(success, failure) {
      notSupported();
      if (failure) failure();
    },
    stopStateNotifications: function(success, failure) {
      notSupported();
      if (failure) failure();
    }
};
