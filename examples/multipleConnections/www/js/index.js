// (c) 2014 Don Coleman
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

/* global mainPage, deviceList, refreshButton */
/* global detailPage, batteryState, batteryStateButton, disconnectButton */
/* global ble  */
/* jshint browser: true , devel: true*/
'use strict';

var battery = {
    service: "180F",
    level: "2A19"
};

var Peripheral = function (deviceId) {
  this.deviceId = deviceId;
};

Peripheral.prototype.connect = function () {
  ble.connect(this.deviceId, this.onConnect.bind(this), app.onError);
};

Peripheral.prototype.onConnect = function (event) {
  this.readBatteryLevel();
  // keep calling the battery level so we know multiple connections work
  setInterval(this.readBatteryLevel.bind(this), 10000);
};

Peripheral.prototype.readBatteryLevel = function() {
  ble.read(this.deviceId, battery.service, battery.level, this.onReadBatteryLevel.bind(this), app.onError);
};

Peripheral.prototype.onReadBatteryLevel = function(data) {
    console.log(data);
    var message;
    var a = new Uint8Array(data);
    if (cordova.platformId == 'android') {
        toast.showShort(this.deviceId + ' ' + a[0] + '%');
    } else {
        alert(this.deviceId + ' ' + a[0] + '%');
    }
};

Peripheral.prototype.disconnect = function () {
  ble.disconnect(this.deviceId, app.showMainPage, app.onError);
};

var app = {
    peripherals: [],
    initialize: function() {
        this.bindEvents();
        detailPage.hidden = true;
    },
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
        refreshButton.addEventListener('touchstart', this.refreshDeviceList, false);
        batteryStateButton.addEventListener('touchstart', this.readBatteryState, false);
        disconnectButton.addEventListener('touchstart', this.disconnect, false);
        deviceList.addEventListener('touchstart', this.connect, false); // assume not scrolling
    },
    onDeviceReady: function() {
        app.refreshDeviceList();
    },
    refreshDeviceList: function() {
        deviceList.innerHTML = ''; // empties the list
        // scan for all devices
        ble.scan([], 5, app.onDiscoverDevice, app.onError);
    },
    onDiscoverDevice: function(device) {

        console.log(JSON.stringify(device));
        var listItem = document.createElement('li'),
            html = '<b>' + device.name + '</b><br/>' +
                'RSSI: ' + device.rssi + '&nbsp;|&nbsp;' +
                device.id;

        listItem.dataset.deviceId = device.id;  // TODO
        listItem.innerHTML = html;
        deviceList.appendChild(listItem);

    },
    connect: function(e) {
      // TODO need to keep a list of connected peripherals
        var deviceId = e.target.dataset.deviceId,
          peripheral = new Peripheral(deviceId);  // TODO store name too

        app.peripherals.push(peripheral);
        peripheral.connect();
    },
    // onBatteryLevelChange: function(data) {
    //     console.log(data);
    //     var message;
    //     var a = new Uint8Array(data);
    //     batteryState.innerHTML = a[0];
    // },
    // readBatteryState: function(event) {
    //     console.log("readBatteryState");
    //     var deviceId = event.target.dataset.deviceId;
    //     ble.read(deviceId, battery.service, battery.level, app.onReadBatteryLevel, app.onError);
    // },
    // onReadBatteryLevel: function(data) {
    //     console.log(data);
    //     var message;
    //     var a = new Uint8Array(data);
    //     batteryState.innerHTML = a[0];
    // },
    // disconnect: function(event) {
    //     var deviceId = event.target.dataset.deviceId;
    //     ble.disconnect(deviceId, app.showMainPage, app.onError);
    // },
    showMainPage: function() {
        mainPage.hidden = false;
        detailPage.hidden = true;
    },
    showDetailPage: function() {
        mainPage.hidden = true;
        detailPage.hidden = false;
    },
    onError: function(reason) {
        alert("ERROR: " + reason); // real apps should use notification.alert
    }
};
