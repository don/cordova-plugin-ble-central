## Methods

- [Methods](#methods)
- [initialize](#initialize)
- [provScanDevices](#provscandevices)
- [provAddDevice](#provadddevice)

## initialize
Initialize Ble Mesh & its handlers. Call this before any other functions. 
```JavaScript
        // Returns Promise<void>
        ble.mesh.initialize();
```

## provScanDevices
Scan nearby devices which can be provisioned. 
```JavaScript
        ble.mesh.provScanDevices({}, successCallback, failureCallback);
        // calls successcallback with found devices. It sends list of all mesh devices and times out after 15 seconds. 
        {
            "devices": [
                {
                    "isProcessing": false,
                    "logExpand": false,
                    "nodeInfo": {
                        "meshAddress": -1,
                        "macAddress": "A4:C1:38:BB:1E:6C",
                        "elementCnt": 0,
                        "bound": false,
                        "lum": 100,
                        "temp": 0,
                        "isLpn": false,
                        "isOffline": true,
                        "isDefaultBind": false,
                        "pidDesc": "(unbound)",
                        "deviceUUID": "7CDA06A96E226C3CBEA5C5CE442F64FC"
                    }
                }
            ]
        }
```
## provAddDevice
Provision a selected device. Send UUID of the device which needs to be provisioned. 
```JavaScript
        ble.mesh.provadddevice({
            uuid: UUID
        }, successCallback, failureCallback);
        // it calls successcallbacks with different events, even if mesh provisioning fails or binding fails. With event type. 
        Events: ['device_prov_begin', 'device_prov_suc', 'device_prov_fail', 'device_bind_suc', 'device_bind_fail']
        // We'll get events in order , first device_prov then device_bind. 
        Response: 
        {"ev":"device_prov_begin","device":{"isProcessing":true,"logExpand":false,"nodeInfo":{"meshAddress":6,"macAddress":"A4:C1:38:BB:1E:6C","elementCnt":0,"bound":false,"lum":100,"temp":0,"isLpn":false,"isOffline":true,"isDefaultBind":false,"pidDesc":"(unbound)","deviceUUID":"7CDA06A96E226C3CBEA5C5CE442F64FC"}}}
        {"ev":"device_bind_suc","device":{"isProcessing":false,"logExpand":false,"nodeInfo":{"meshAddress":6,"macAddress":"A4:C1:38:BB:1E:6C","elementCnt":2,"bound":true,"lum":100,"temp":0,"isLpn":false,"isOffline":true,"isDefaultBind":false,"pidDesc":"cid-1102 pid-0100","deviceUUID":"7CDA06A96E226C3CBEA5C5CE442F64FC","deviceKey":"AE023B27FF34E7321F6212187D942C35","netKeyIdxes":[0]}}}

```