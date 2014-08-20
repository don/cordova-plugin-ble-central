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
/* global detailPage, buttonState, ledButton, disconnectButton */
/* global ble  */
/* jshint browser: true , devel: true*/
'use strict';

var arrayBufferToInt = function (ab) {
    var a = new Uint8Array(ab);
    return a[0];
};

var rfduino = {
    serviceUUID: "2220",
    receiveCharacteristic: "2221",
    sendCharacteristic: "2222",
    disconnectCharacteristic: "2223"
};


// TODO get the terminology correct
// TODO make this a generic function
// TODO convert known types - Name, Advertised Services, iBeacon, etc
// 
// returns advertising data as hashmap of byte arrays keyed by type
// advertising data is length, type, data
// https://www.bluetooth.org/en-us/specification/assigned-numbers/generic-access-profile
function parseAdvertisingData(bytes) {
    var length, type, data, i = 0, advertisementData = {};

    while (length !== 0) {
    
       length = bytes[i] & 0xFF;         
        i++;
        
        type = bytes[i] & 0xFF;
        i++;    
        
        data = bytes.slice(i, i + length - 2); // length includes type and length
        i += length - 2;  // move to end of data
        i++;

        advertisementData[type] = data;
    }
    
    return advertisementData;
}

// RFduino advertises the sketch its running in the Manufacturer field 0xFF
// RFduino provides a UART-like service so all sketchs look the same
var getRFduinoService = function(scanRecord) {
    var ad = parseAdvertisingData(scanRecord),
        mfgData = ad[0xFF],
        service;
    
    if (mfgData) {
      // ignore 1st 2 bytes of mfg data
      service = bytesToString(mfgData.slice(2));
      return service;      
    } else {
      return "";
    }
};

var bytesToString = function (bytes) {
    var bytesAsString = "";
    for (var i = 0; i < bytes.length; i++) {
        bytesAsString += String.fromCharCode(bytes[i]);
    }
    return bytesAsString;
};

var app = {
    initialize: function() {
        this.bindEvents();
        detailPage.hidden = true;
    },
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
        refreshButton.addEventListener('touchstart', this.refreshDeviceList, false);
        ledButton.addEventListener('touchstart', this.sendData, false);
        ledButton.addEventListener('touchend', this.sendData, false);                
        disconnectButton.addEventListener('touchstart', this.disconnect, false);
        deviceList.addEventListener('touchstart', this.connect, false); // assume not scrolling
    },
    onDeviceReady: function() {
        app.refreshDeviceList();
    },
    refreshDeviceList: function() {
        deviceList.innerHTML = ''; // empties the list
        ble.scan([rfduino.serviceUUID], 5, app.onDiscoverDevice, app.onError);
    },
    onDiscoverDevice: function(device) {
        var listItem = document.createElement('li'),
            html = '<b>' + device.name + '</b><br/>' +
                'RSSI: ' + device.rssi + '&nbsp;|&nbsp;' +
                'Advertising: ' + getRFduinoService(device.advertising) + '<br/>' +
                device.id;

        listItem.dataset.deviceId = device.id;
        listItem.innerHTML = html;
        deviceList.appendChild(listItem);
    },
    connect: function(e) {
        var deviceId = e.target.dataset.deviceId,
            onConnect = function() {
                // subscribe for incoming data
                ble.notify(deviceId, rfduino.serviceUUID, rfduino.receiveCharacteristic, app.onData, app.onError);
                disconnectButton.dataset.deviceId = deviceId;
                ledButton.dataset.deviceId = deviceId;             
                app.showDetailPage();
            };

        ble.connect(deviceId, onConnect, app.onError);
    },
    onData: function(data) { // data received from rfduino
        console.log(data);        
        var buttonValue = arrayBufferToInt(data);
        if (buttonValue === 1) {
            buttonState.innerHTML = "Button Pressed";
        } else {
            buttonState.innerHTML = "Button Released";            
        }
    },
    sendData: function(event) { // send data to rfduino 

        var success = function() {
            console.log("success");
        };

        var failure = function() {
            alert("Failed writing data to the rfduino");
        };
        
        var data = new Uint8Array(1);        
        data[0] = event.type === 'touchstart' ? 0x1 : 0x0;
        var deviceId = event.target.dataset.deviceId;

        ble.writeCommand(deviceId, rfduino.serviceUUID, rfduino.sendCharacteristic, data.buffer, success, failure);
        
    },    
    disconnect: function(event) {
        var deviceId = event.target.dataset.deviceId;
        ble.disconnect(deviceId, app.showMainPage, app.onError);
    },
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
