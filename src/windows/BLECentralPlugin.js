//Includes
var Enum = Windows.Devices.Enumeration; //Namespace of devices
var WinBT = Windows.Devices.Bluetooth; //Namespace of BT

//Locals Vars
var deviceWatcher; //BLE device scanner and watcher
var scanFunc = null; //Callback function
var scanning = false; //void to start the watcher again
var deviceArray = new Array(); //List of found devices
var addressHeader = ""; //left-part of the Win-BT addess
                        //Win-BT Adress: BluetoothLE#BluetoothLE[Local Device Address]-[Remote Device Address]
                        //Note: just-in-case variable

//Publics functions
module.exports = {
    //cordova.exec(successWrapper, failure, 'BLE', 'scan', [services, seconds, successWrapper]);
    scan: function (success, failure, args) {
        if (!scanning) {
            //Assign callback function
            scanFunc = args[2];
            //Request properties to get later in devinfo.properties[KEY]
            //If property is not declared here, it will return NULL
            var requestedProperties = ["System.Devices.Aep.DeviceAddress", "System.Devices.Aep.IsConnected", "System.Devices.Aep.SignalStrength", "System.ItemNameDisplay"];
            //Creating and saving watcher
            deviceWatcher = Enum.DeviceInformation.createWatcher(
                WinBT.BluetoothLEDevice.getDeviceSelectorFromPairingState(false),
                requestedProperties,
                Enum.DeviceInformationKind.associationEndpoint
            )

            //Required events
            deviceWatcher.addEventListener("added", DeviceWatcher_Added);
            deviceWatcher.addEventListener("updated", DeviceWatcher_Updated);
            deviceWatcher.addEventListener("removed", DeviceWatcher_Removed);

            //Optionals events
            deviceWatcher.addEventListener("stopped", DeviceWatcher_Stopped);
            deviceWatcher.addEventListener("enumerationcompleted", DeviceWatcher_EnumerationCompleted)

            //Start the scan
            deviceWatcher.start();
            scanning = true;
            
            //Auto-Stop
            setTimeout(function(){
                deviceWatcher.stop();
            }, args[1] * 1000); //setTimeout is Ms-based and Args[1] (seconds) is Second-Based
        } else {
            //NOTE: if the plugin only get one device, comment the line below
            failure("Already scanning");
        }
    }
};

function DeviceWatcher_Added(devinfo) {
    //Important: Check that the scanFunc local variable isn't NULL
    if (scanFunc != null) {
        //Add new device to the list
        deviceArray.push(devinfo);

        var rssi = 0; //Temporal RSSI variable
        //Check that the device has the RSSI property
        if (devinfo.properties["System.Devices.Aep.SignalStrength"] != null)
            rssi = devinfo.properties["System.Devices.Aep.SignalStrength"];
        else
            console.log("'System.Devices.Aep.SignalStrength' not found in BLE device.")

        var name = devinfo.name; //Temporal device-name variable
        //Check that the device has a public name property
        if(devinfo.properties["System.ItemNameDisplay"] != null)
            name = devinfo.properties["System.ItemNameDisplay"];
        
        var address = devinfo.id; //Temporal device-id (device-address) variable
        //Split original device-id to get the Header and the remote device id
        var splitAddress = devinfo.id.split('-');
        //Check if split was successfuly
        if(splitAddress.length >= 2) {
            addressHeader = splitAddress[0];
            address = splitAddress[1];
        }
        
        //Console.log text
        var json = '{ "name": "' + name + '", "id": "' + address + '", "rssi": ' + rssi + ', "advertising": [] }';
        console.log("New device: " + json);
        
        //Send a callback with the device
        scanFunc(
            {
                "name": name,
                "id": address,
                "rssi": rssi,
                "advertising": []
            }
        );
    }
}

function DeviceWatcher_Updated(devUpdate) {
    //Search the device in deviceArray using its ID
    for (var i = 0; i < deviceArray.length; i++) {
        if (deviceArray[i].id == devUpdate.id) {
            //Update properties
            deviceArray[i].update(devUpdate); //device.properties is read-only
            
            //Important: Check that the scanFunc local variable isn't NULL
            if(scanFunc != null) {
                var rssi = 0; //Temporal RSSI variable
                //Check that the device has the RSSI property
                if (deviceArray[i].properties["System.Devices.Aep.SignalStrength"] != null)
                    rssi = deviceArray[i].properties["System.Devices.Aep.SignalStrength"];
                else
                    console.log("'System.Devices.Aep.SignalStrength' not found in BLE device.")
                
                var name = deviceArray[i].name; //Temporal device-name variable
                //Check that the device has a public name property
                if(deviceArray[i].properties["System.ItemNameDisplay"] != null)
                    name = deviceArray[i].properties["System.ItemNameDisplay"];
                
                var address = deviceArray[i].id; //Temporal device-id (device-address) variable
                //Split original device-id to get the Header and the remote device id
                var splitAddress = deviceArray[i].id.split('-');
                //Check if split was successfuly
                if(splitAddress.length >= 2) {
                    addressHeader = splitAddress[0];
                    address = splitAddress[1];
                }
                
                //Console.log text
                var json = '{ "name": "' + name + '", "id": "' + address + '", "rssi": ' + rssi + ', "advertising": [] }';
                console.log("Device Updated: " + json);
                
                //Send a callback with the device with its new properties
                scanFunc(
                    {
                        "name": name,
                        "id": address,
                        "rssi": rssi,
                        "advertising": []
                    }
                ); //Dev-side-TODO: Check the device.id from scan-callback to avoid clone the same devices
            }
            break;
        }
    }
}

function DeviceWatcher_Removed(devupdate) {
    /*for (var i = 0; i < deviceArray.length; i++) {
        if (deviceArray[i].id == devupdate.id) {
            deviceArray[i].slice(devupdate);
        }
    }*/ //Commented because generate an unknown exception
}

function DeviceWatcher_EnumerationCompleted(obj) {
    //Stop the device Watcher
    deviceWatcher.stop();
}

function DeviceWatcher_Stopped(obj) {
    //Clear up everything
    deviceArray = new Array();
    scanning = false;
    scanFunc = null;
}

require("cordova/exec/proxy").add("BLE", module.exports);
