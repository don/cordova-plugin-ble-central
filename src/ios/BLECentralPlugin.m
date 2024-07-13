//
//  BLECentralPlugin.m
//  BLE Central Cordova Plugin
//
//  (c) 2104-2018 Don Coleman
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

#import "BLECentralPlugin.h"
#import <Cordova/CDV.h>

@interface BLECentralPlugin() {
    NSDictionary *bluetoothStates;
}
- (CBPeripheral *)findPeripheralByUUID:(NSUUID *)uuid;
- (CBPeripheral *)retrievePeripheralWithUUID:(NSUUID *)uuid;
- (void)stopScanTimer:(NSTimer *)timer;
@end

@implementation BLECentralPlugin

@synthesize manager;
@synthesize peripherals;

- (void)pluginInitialize {
    NSLog(@"Cordova BLE Central Plugin");
    NSLog(@"(c)2014-2016 Don Coleman");

    [super pluginInitialize];

    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    options[CBCentralManagerOptionShowPowerAlertKey] = @NO;

    NSDictionary *pluginSettings = [[self commandDelegate] settings];
    NSString *enableState = pluginSettings[@"bluetooth_restore_state"];
    if (![self isFalsey:enableState]) {
        NSString *restoreIdentifier = [@"true" isEqualToString:[enableState lowercaseString]]
            ? [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
            : enableState;
        options[CBCentralManagerOptionRestoreIdentifierKey] = restoreIdentifier;
    }

    peripherals = [NSMutableSet new];
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];

    restoredState = nil;
    connectCallbacks = [NSMutableDictionary new];
    connectCallbackLatches = [NSMutableDictionary new];
    readCallbacks = [NSMutableDictionary new];
    writeCallbacks = [NSMutableDictionary new];
    notificationCallbacks = [NSMutableDictionary new];
    startNotificationCallbacks = [NSMutableDictionary new];
    stopNotificationCallbacks = [NSMutableDictionary new];
    l2CapContexts = [NSMutableDictionary new];
    bluetoothStates = [NSDictionary dictionaryWithObjectsAndKeys:
                       @"unknown", @(CBCentralManagerStateUnknown),
                       @"resetting", @(CBCentralManagerStateResetting),
                       @"unsupported", @(CBCentralManagerStateUnsupported),
                       @"unauthorized", @(CBCentralManagerStateUnauthorized),
                       @"off", @(CBCentralManagerStatePoweredOff),
                       @"on", @(CBCentralManagerStatePoweredOn),
                       nil];
    readRSSICallbacks = [NSMutableDictionary new];
}

#pragma mark - Cordova Plugin Methods

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)state {
    restoredState = state;
}

- (void)restoredBluetoothState:(CDVInvokedUrlCommand *)command {
    NSMutableDictionary *state = [[NSMutableDictionary alloc] init];

    if (restoredState) {
        NSArray *restoredPeripherals = restoredState[CBCentralManagerRestoredStatePeripheralsKey];
        if (restoredPeripherals != nil) {
            NSMutableArray *peripherals = [NSMutableArray arrayWithCapacity:[restoredPeripherals count]];
            for (id peripheral in restoredPeripherals) {
                [peripherals addObject:[peripheral asDictionary]];
            }

            state[@"peripherals"] = peripherals;
        }

        NSArray *restoredScanServices = restoredState[CBCentralManagerRestoredStateScanServicesKey];
        if (restoredScanServices != nil) {
            NSMutableArray *uuids = [NSMutableArray arrayWithCapacity:[restoredScanServices count]];
            for (id uuid in restoredScanServices) {
                [uuids addObject:[uuid UUIDString]];
            }
            
            state[@"scanServiceUUIDs"] = uuids;
        }

        if (restoredState[CBCentralManagerRestoredStateScanOptionsKey]) {
            state[@"scanOptions"] = restoredState[CBCentralManagerRestoredStateScanOptionsKey];
        }
    }

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                  messageAsDictionary:state];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)connect:(CDVInvokedUrlCommand *)command {
    NSLog(@"connect");
    if ([manager state] != CBManagerStatePoweredOn) {
        NSString *error = @"Bluetooth is disabled";
        NSLog(@"%@", error);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    NSUUID *uuid = [self getUUID:command argumentAtIndex:0];
    if (uuid == nil) {
        return;
    }
    
    CBPeripheral *peripheral = [self findPeripheralByUUID:uuid];
    if (!peripheral) {
        peripheral = [self retrievePeripheralWithUUID:uuid];
    }

    if (peripheral) {
        NSLog(@"Connecting to peripheral with UUID : %@", uuid);

        [connectCallbacks setObject:[command.callbackId copy] forKey:[peripheral uuidAsString]];
        [manager connectPeripheral:peripheral options:nil];
    } else {
        NSString *error = [NSString stringWithFormat:@"Could not find peripheral %@.", uuid];
        NSLog(@"%@", error);
        CDVPluginResult *pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }

}

// This works different than Android. iOS needs to know about the peripheral UUID
// If not scanning, try connectedPeripheralsWIthServices or peripheralsWithIdentifiers
- (void)autoConnect:(CDVInvokedUrlCommand *)command {
    NSLog(@"autoConnect");
    if ([manager state] != CBManagerStatePoweredOn) {
        NSString *error = @"Bluetooth is disabled";
        NSLog(@"%@", error);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    NSUUID *uuid = [self getUUID:command argumentAtIndex:0];
    if (uuid == nil) {
        return;
    }
    
    CBPeripheral *peripheral = [self findPeripheralByUUID:uuid];
    if (!peripheral) {
        peripheral = [self retrievePeripheralWithUUID:uuid];
    }
    
    if (peripheral) {
        NSLog(@"Autoconnecting to peripheral with UUID : %@", uuid);
        
        [connectCallbacks setObject:[command.callbackId copy] forKey:[peripheral uuidAsString]];
        [manager connectPeripheral:peripheral options:nil];
    } else {
        NSString *error = [NSString stringWithFormat:@"Could not find peripheral %@.", uuid];
        NSLog(@"%@", error);
        CDVPluginResult *pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
}

// disconnect: function (device_id, success, failure) {
- (void)disconnect:(CDVInvokedUrlCommand*)command {
    NSLog(@"disconnect");

    NSUUID *uuid = [self getUUID:command argumentAtIndex:0];
    if (uuid == nil) {
        return;
    }

    CBPeripheral *peripheral = [self findPeripheralByUUID:uuid];

    if (!peripheral) {
        NSString *message = [NSString stringWithFormat:@"Peripheral %@ not found", uuid];
        NSLog(@"%@", message);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    } else {

        [connectCallbacks removeObjectForKey:uuid];
        [self cleanupOperationCallbacks:peripheral withResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Peripheral disconnected"]];

        if (peripheral && peripheral.state != CBPeripheralStateDisconnected) {
            [manager cancelPeripheralConnection:peripheral];
        }

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

// read: function (device_id, service_uuid, characteristic_uuid, success, failure) {
- (void)read:(CDVInvokedUrlCommand*)command {
    NSLog(@"read");

    BLECommandContext *context = [self getData:command prop:CBCharacteristicPropertyRead];
    if (context) {
        CBPeripheral *peripheral = [context peripheral];
        if ([peripheral state] != CBPeripheralStateConnected) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Peripheral is not connected"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        CBCharacteristic *characteristic = [context characteristic];

        NSString *key = [self keyForPeripheral: peripheral andCharacteristic:characteristic];
        [readCallbacks setObject:[command.callbackId copy] forKey:key];

        [peripheral readValueForCharacteristic:characteristic];  // callback sends value
    }
}

// write: function (device_id, service_uuid, characteristic_uuid, value, success, failure) {
- (void)write:(CDVInvokedUrlCommand*)command {
    BLECommandContext *context = [self getData:command prop:CBCharacteristicPropertyWrite];
    id message = [self tryDecodeBinaryData:[command argumentAtIndex:3]]; // This should be binary
    if (context) {
        if (message != nil && [message isKindOfClass:[NSData class]]) {
            CBPeripheral *peripheral = [context peripheral];
            if ([peripheral state] != CBPeripheralStateConnected) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Peripheral is not connected"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                return;
            }
            CBCharacteristic *characteristic = [context characteristic];

            NSString *key = [self keyForPeripheral: peripheral andCharacteristic:characteristic];
            [writeCallbacks setObject:[command.callbackId copy] forKey:key];

            // TODO need to check the max length
            [peripheral writeValue:message forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];

            // response is sent from didWriteValueForCharacteristic
        } else if (message != nil) {
            // #897: some alternative BLE plugins expect a string rather than array buffer, so this is a common misuse
            CDVPluginResult *pluginResult = nil;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"message was not ArrayBuffer"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            CDVPluginResult *pluginResult = nil;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"message was null"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
}

// writeWithoutResponse: function (device_id, service_uuid, characteristic_uuid, value, success, failure) {
- (void)writeWithoutResponse:(CDVInvokedUrlCommand*)command {
    NSLog(@"writeWithoutResponse");

    BLECommandContext *context = [self getData:command prop:CBCharacteristicPropertyWriteWithoutResponse];
    id message = [self tryDecodeBinaryData:[command argumentAtIndex:3]]; // This should be binary
    if (context) {
        CDVPluginResult *pluginResult = nil;
        if (message != nil && [message isKindOfClass:[NSData class]]) {
            CBPeripheral *peripheral = [context peripheral];
            if ([peripheral state] != CBPeripheralStateConnected) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Peripheral is not connected"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                return;
            }
            CBCharacteristic *characteristic = [context characteristic];

            // TODO need to check the max length
            [peripheral writeValue:message forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else if (message != nil) {
            // #897: some alternative BLE plugins expect a string rather than array buffer, so this is a common misuse
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"message was not ArrayBuffer"];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"message was null"];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

// success callback is called on notification
// notify: function (device_id, service_uuid, characteristic_uuid, success, failure) {
- (void)startNotification:(CDVInvokedUrlCommand*)command {
    NSLog(@"registering for notification");

    BLECommandContext *context = [self getData:command prop:CBCharacteristicPropertyNotify]; // TODO name this better

    if (context) {
        CBPeripheral *peripheral = [context peripheral];
        if ([peripheral state] != CBPeripheralStateConnected) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Peripheral is not connected"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        CBCharacteristic *characteristic = [context characteristic];

        NSString *key = [self keyForPeripheral: peripheral andCharacteristic:characteristic];
        NSString *callback = [command.callbackId copy];
        [startNotificationCallbacks setObject: callback forKey: key];
        [stopNotificationCallbacks removeObjectForKey:key];

        [peripheral setNotifyValue:YES forCharacteristic:characteristic];

    }

}

// stopNotification: function (device_id, service_uuid, characteristic_uuid, success, failure) {
- (void)stopNotification:(CDVInvokedUrlCommand*)command {
    NSLog(@"stop notification");

    BLECommandContext *context = [self getData:command prop:CBCharacteristicPropertyNotify];

    if (context) {
        CBPeripheral *peripheral = [context peripheral];    // FIXME is setNotifyValue:NO legal to call on a peripheral not connected?
        CBCharacteristic *characteristic = [context characteristic];

        NSString *key = [self keyForPeripheral: peripheral andCharacteristic:characteristic];
        NSString *callback = [command.callbackId copy];
        [stopNotificationCallbacks setObject: callback forKey: key];

        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        // callback sent from peripheral:didUpdateNotificationStateForCharacteristic:error:

    }
}

- (void)isEnabled:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult = nil;
    int bluetoothState = [manager state];

    BOOL enabled = bluetoothState == CBCentralManagerStatePoweredOn;

    if (enabled) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:bluetoothState];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)startScanWithOptions:(CDVInvokedUrlCommand*)command {
    NSLog(@"startScanWithOptions");
    if ([manager state] != CBManagerStatePoweredOn) {
        NSString *error = @"Bluetooth is disabled";
        NSLog(@"%@", error);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    discoverPeripheralCallbackId = [command.callbackId copy];
    NSArray<NSString *> *serviceUUIDStrings = [command argumentAtIndex:0];
    if (serviceUUIDStrings != nil && ![serviceUUIDStrings isKindOfClass:[NSArray class]]) {
        NSLog(@"Malformed UUID");
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Malformed UUID"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSArray<CBUUID *> *serviceUUIDs = [self uuidStringsToCBUUIDs:serviceUUIDStrings];
    if (serviceUUIDs == nil) {
        NSLog(@"Malformed UUID");
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Malformed UUID"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSDictionary *options = command.arguments[1];

    NSMutableDictionary *scanOptions = [NSMutableDictionary new];
    NSNumber *reportDuplicates = [options valueForKey: @"reportDuplicates"];
    if (reportDuplicates) {
        [scanOptions setValue:reportDuplicates
                       forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    }
    NSNumber *timeoutSeconds = [options valueForKey: @"duration"];

    [manager scanForPeripheralsWithServices:serviceUUIDs options:scanOptions];

    [scanTimer invalidate];
    scanTimer = nil;
    if (timeoutSeconds) {
        scanTimer = [NSTimer scheduledTimerWithTimeInterval:[timeoutSeconds floatValue]
                                         target:self
                                       selector:@selector(stopScanTimer:)
                                       userInfo:[command.callbackId copy]
                                        repeats:NO];
    }
}

- (void)stopScan:(CDVInvokedUrlCommand*)command {
    NSLog(@"stopScan");
    [self internalStopScan];

    if (discoverPeripheralCallbackId) {
        discoverPeripheralCallbackId = nil;
    }

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)isConnected:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult = nil;
    CBPeripheral *peripheral = [self findPeripheralByUUID:[command argumentAtIndex:0]];

    if (peripheral && peripheral.state == CBPeripheralStateConnected) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not connected"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)startStateNotifications:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = nil;

    if (stateCallbackId == nil) {
        stateCallbackId = [command.callbackId copy];
        int bluetoothState = [manager state];
        NSString *state = [bluetoothStates objectForKey:[NSNumber numberWithInt:bluetoothState]];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:state];
        [pluginResult setKeepCallbackAsBool:TRUE];
        NSLog(@"Start state notifications on callback %@", stateCallbackId);
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"State callback already registered"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)stopStateNotifications:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = nil;

    if (stateCallbackId != nil) {
        // Call with NO_RESULT so Cordova.js will delete the callback without actually calling it
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:stateCallbackId];
        stateCallbackId = nil;
    }

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)onReset {
    stateCallbackId = nil;
}

- (void)readRSSI:(CDVInvokedUrlCommand*)command {
    NSLog(@"readRSSI");
    NSUUID *uuid = [self getUUID:command argumentAtIndex:0];
    if (uuid == nil) {
        return;
    }
    
    CBPeripheral *peripheral = [self findPeripheralByUUID:uuid];

    if (peripheral && peripheral.state == CBPeripheralStateConnected) {
        [readRSSICallbacks setObject:[command.callbackId copy] forKey:[peripheral uuidAsString]];
        [peripheral readRSSI];
    } else {
        NSString *error = [NSString stringWithFormat:@"Need to be connected to peripheral %@ to read RSSI.", uuid];
        NSLog(@"%@", error);
        CDVPluginResult *pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

// Returns a list of the peripherals (containing any of the specified services) currently connected to the system.
// https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1518924-retrieveconnectedperipheralswith?language=objc
- (void)connectedPeripheralsWithServices:(CDVInvokedUrlCommand*)command {
    NSLog(@"connectedPeripheralsWithServices");
    if ([manager state] != CBManagerStatePoweredOn) {
        NSString *error = @"Bluetooth is disabled";
        NSLog(@"%@", error);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    NSArray<NSString *> *serviceUUIDStrings = [command argumentAtIndex:0];
    if (serviceUUIDStrings != nil && ![serviceUUIDStrings isKindOfClass:[NSArray class]]) {
        NSLog(@"Malformed UUID");
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Malformed UUID"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    NSArray<CBUUID *> *serviceUUIDs = [self uuidStringsToCBUUIDs:serviceUUIDStrings];
    if (serviceUUIDs == nil) {
        NSLog(@"Malformed UUID");
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Malformed UUID"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    NSArray<CBPeripheral *> *connectedPeripherals = [manager retrieveConnectedPeripheralsWithServices:serviceUUIDs];
    NSMutableArray<NSDictionary *> *connected = [NSMutableArray new];

    for (CBPeripheral *peripheral in connectedPeripherals) {
        [peripherals addObject:peripheral];
        [connected addObject:[peripheral asDictionary]];
    }

    CDVPluginResult *pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:connected];
    NSLog(@"Connected peripherals with services %@ %@", serviceUUIDStrings, connected);
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Returns a list of known peripherals by their identifiers.
// https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1519127-retrieveperipheralswithidentifie?language=objc
- (void)peripheralsWithIdentifiers:(CDVInvokedUrlCommand*)command {
    NSLog(@"peripheralsWithIdentifiers");
    NSArray *identifierUUIDStrings = [command argumentAtIndex:0];
    NSArray<NSUUID *> *identifiers = [self uuidStringsToNSUUIDs:identifierUUIDStrings];
    if (identifiers == nil) {
        NSLog(@"Malformed UUID");
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Malformed UUID"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSArray<CBPeripheral *> *foundPeripherals = [manager retrievePeripheralsWithIdentifiers:identifiers];
    // TODO are any of these connected?
    NSMutableArray<NSDictionary *> *found = [NSMutableArray new];
    
    for (CBPeripheral *peripheral in foundPeripherals) {
        [peripherals addObject:peripheral];   // TODO do we save these?
        [found addObject:[peripheral asDictionary]];
    }
    
    CDVPluginResult *pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:found];
    NSLog(@"Peripherals with identifiers %@ %@", identifierUUIDStrings, found);
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)closeL2Cap:(CDVInvokedUrlCommand*)command {
    NSLog(@"closeL2Cap");

    NSUUID *uuid = [self getUUID:command argumentAtIndex:0];
    if (uuid == nil) {
        return;
    }

    NSNumber *psm = [command argumentAtIndex:1];
    CBPeripheral *peripheral = [self findPeripheralByUUID:uuid];

    if (peripheral) {
        NSString *key = [self keyForPeripheral:peripheral andPSM:psm.unsignedShortValue];
        BLEStreamContext *context = [l2CapContexts objectForKey:key];
        if (context) {
            [context closeWithReason:@"L2CAP channel closed"];
            [l2CapContexts removeObjectForKey:key];
        }
        NSLog(@"Cleared callbacks for L2CAP channel key %@", key);
    }
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)openL2Cap:(CDVInvokedUrlCommand*)command {
    NSLog(@"openL2Cap");

    NSUUID *uuid = [self getUUID:command argumentAtIndex:0];
    if (uuid == nil) {
        return;
    }

    NSNumber *psm = [command argumentAtIndex:1];
    CBPeripheral *peripheral = [self findPeripheralByUUID:uuid];

    if (!peripheral) {
        NSString *message = [NSString stringWithFormat:@"Peripheral %@ not found", uuid];
        NSLog(@"%@", message);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    } else {
        BLEStreamContext *context = [self findStreamContextFromPeripheral:peripheral andPSM:[psm unsignedShortValue]];
        [context setConnectionStateCallbackId:[command.callbackId copy]];
        [peripheral openL2CAPChannel:psm.unsignedShortValue];
    }
}

- (void)receiveDataL2Cap:(CDVInvokedUrlCommand*)command {
    NSLog(@"receiveDataL2Cap");

    NSUUID *uuid = [self getUUID:command argumentAtIndex:0];
    if (uuid == nil) {
        return;
    }

    NSNumber *psm = [command argumentAtIndex:1];
    CBPeripheral *peripheral = [self findPeripheralByUUID:uuid];

    if (!peripheral) {
        NSString *message = [NSString stringWithFormat:@"Peripheral %@ not found", uuid];
        NSLog(@"%@", message);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        BLEStreamContext *context = [self findStreamContextFromPeripheral:peripheral andPSM:[psm unsignedShortValue]];
        [context setReadCallbackId:[command.callbackId copy]];
    }
}

- (void)writeL2Cap:(CDVInvokedUrlCommand *)command {
    NSLog(@"writeL2Cap");

    NSUUID *uuid = [self getUUID:command argumentAtIndex:0];
    if (uuid == nil) {
        return;
    }

    NSNumber *psm = [command argumentAtIndex:1];
    NSData *message = [command argumentAtIndex:2]; // This is binary
    CBPeripheral *peripheral = [self findPeripheralByUUID:uuid];

    if (!peripheral) {
        NSString *message = [NSString stringWithFormat:@"Peripheral %@ not found", uuid];
        NSLog(@"%@", message);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        BLEStreamContext *context = [self findStreamContextFromPeripheral:peripheral andPSM:[psm unsignedShortValue]];
        [context write:message callbackId:[command.callbackId copy]];
    }
}

#pragma mark - timers

-(void)stopScanTimer:(NSTimer *)timer {
    NSLog(@"stopScanTimer");
    [self internalStopScan];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

    [peripherals addObject:peripheral];
    [peripheral setAdvertisementData:advertisementData RSSI:RSSI];

    if (discoverPeripheralCallbackId) {
        CDVPluginResult *pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[peripheral asDictionary]];
        NSLog(@"Discovered %@", [peripheral asDictionary]);
        [pluginResult setKeepCallbackAsBool:TRUE];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:discoverPeripheralCallbackId];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"Status of CoreBluetooth central manager changed %ld %@", (long)central.state, [self centralManagerStateToString: central.state]);

    if (central.state == CBCentralManagerStateUnsupported)
    {
        NSLog(@"=============================================================");
        NSLog(@"WARNING: This hardware does not support Bluetooth Low Energy.");
        NSLog(@"=============================================================");
    }

    if (stateCallbackId != nil) {
        CDVPluginResult *pluginResult = nil;
        NSString *state = [bluetoothStates objectForKey:@(central.state)];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:state];
        [pluginResult setKeepCallbackAsBool:TRUE];
        NSLog(@"Report Bluetooth state \"%@\" on callback %@", state, stateCallbackId);
        [self.commandDelegate sendPluginResult:pluginResult callbackId:stateCallbackId];
    }

    // check and handle disconnected peripherals
    for (CBPeripheral *peripheral in peripherals) {
        if (peripheral.state == CBPeripheralStateDisconnected) {
            [self centralManager:central didDisconnectPeripheral:peripheral error:nil];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnectPeripheral");

    peripheral.delegate = self;

    // NOTE: it's inefficient to discover all services
    [peripheral discoverServices:nil];

    // NOTE: not calling connect success until characteristics are discovered
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral");

    NSString *connectCallbackId = [connectCallbacks valueForKey:[peripheral uuidAsString]];
    [connectCallbacks removeObjectForKey:[peripheral uuidAsString]];
    [self cleanupOperationCallbacks:peripheral withResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Peripheral disconnected"]];

    if (connectCallbackId) {

        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[peripheral asDictionary]];

        // add error info
        [dict setObject:@"Peripheral Disconnected" forKey:@"errorMessage"];
        if (error) {
            [dict setObject:[error localizedDescription] forKey:@"errorDescription"];
        }
        // remove extra junk
        [dict removeObjectForKey:@"rssi"];
        [dict removeObjectForKey:@"advertising"];
        [dict removeObjectForKey:@"services"];

        CDVPluginResult *pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:connectCallbackId];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didFailToConnectPeripheral");

    NSString *connectCallbackId = [connectCallbacks valueForKey:[peripheral uuidAsString]];
    [connectCallbacks removeObjectForKey:[peripheral uuidAsString]];
    [self cleanupOperationCallbacks:peripheral withResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Peripheral disconnected"]];

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[peripheral asDictionary]];

    // add error info
    [dict setObject:@"Connection Failed" forKey:@"errorMessage"];
    if (error) {
        [dict setObject:[error localizedDescription] forKey:@"errorDescription"];
    }
    // remove extra junk
    [dict removeObjectForKey:@"rssi"];
    [dict removeObjectForKey:@"advertising"];
    [dict removeObjectForKey:@"services"];

    CDVPluginResult *pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:connectCallbackId];
}

#pragma mark CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices");

    // save the services to tell when all characteristics have been discovered
    NSMutableSet *servicesForPeriperal = [NSMutableSet new];
    [servicesForPeriperal addObjectsFromArray:peripheral.services];
    [connectCallbackLatches setObject:servicesForPeriperal forKey:[peripheral uuidAsString]];

    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service]; // discover all is slow
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"didDiscoverCharacteristicsForService");

    NSString *peripheralUUIDString = [peripheral uuidAsString];
    NSString *connectCallbackId = [connectCallbacks valueForKey:peripheralUUIDString];
    NSMutableSet *latch = [connectCallbackLatches valueForKey:peripheralUUIDString];

    [latch removeObject:service];

    if ([latch count] == 0) {
        // Call success callback for connect
        if (connectCallbackId) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[peripheral asDictionary]];
            [pluginResult setKeepCallbackAsBool:TRUE];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:connectCallbackId];
        }
        [connectCallbackLatches removeObjectForKey:peripheralUUIDString];
    }

    NSLog(@"Found characteristics for service %@", service);
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Characteristic %@", characteristic);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateValueForCharacteristic");

    NSString *key = [self keyForPeripheral: peripheral andCharacteristic:characteristic];
    NSString *notifyCallbackId = [notificationCallbacks objectForKey:key];

    if (notifyCallbackId) {
        NSData *data = characteristic.value; // send RAW data to Javascript

        CDVPluginResult *pluginResult = nil;
        if (error) {
            NSLog(@"%@", error);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArrayBuffer:data];
        }

        [pluginResult setKeepCallbackAsBool:TRUE]; // keep for notification
        [self.commandDelegate sendPluginResult:pluginResult callbackId:notifyCallbackId];
    }

    NSString *readCallbackId = [readCallbacks objectForKey:key];

    if(readCallbackId) {
        NSData *data = characteristic.value; // send RAW data to Javascript
        CDVPluginResult *pluginResult = nil;
        
        if (error) {
            NSLog(@"%@", error);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArrayBuffer:data];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:readCallbackId];

        [readCallbacks removeObjectForKey:key];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSString *key = [self keyForPeripheral: peripheral andCharacteristic:characteristic];
    NSString *startNotificationCallbackId = [startNotificationCallbacks objectForKey:key];
    NSString *stopNotificationCallbackId = [stopNotificationCallbacks objectForKey:key];

    CDVPluginResult *pluginResult = nil;
    
    if (stopNotificationCallbackId) {
        if (!characteristic.isNotifying) {
            // successfully stopped notifications
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [notificationCallbacks removeObjectForKey:key];
        } else {
            if (error) {
                // error: something went wrong
                NSLog(@"%@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            } else {
                // error: still notifying
                NSLog(@"Notifications failed to stop");
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Notifications failed to stop"];
            }
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:stopNotificationCallbackId];
        [stopNotificationCallbacks removeObjectForKey:key];
    }

    if (startNotificationCallbackId) {
        if (characteristic.isNotifying) {
            // successfully started notifications
            // notification start succeeded, move the callback to the value notifications dict
            [notificationCallbacks setObject:startNotificationCallbackId forKey:key];
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"registered"];
            [pluginResult setKeepCallbackAsBool:TRUE]; // keep for notification
        } else {
            if (error) {
                // error: something went wrong
                NSLog(@"%@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            } else {
                // error: not notifying
                NSLog(@"Notifications failed to start");
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Notifications failed to start"];
            }
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:startNotificationCallbackId];
        [startNotificationCallbacks removeObjectForKey:key];
    }

    if (!characteristic.isNotifying) {
        // characteristic is not notifying
        NSString *notificationCallbackId = [notificationCallbacks objectForKey:key];
        if (notificationCallbackId) {
            // error: characteristic no longer notifying
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Characteristic not notifying"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:startNotificationCallbackId];
            [notificationCallbacks removeObjectForKey:key];
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // This is the callback for write

    NSString *key = [self keyForPeripheral: peripheral andCharacteristic:characteristic];
    NSString *writeCallbackId = [writeCallbacks objectForKey:key];

    if (writeCallbackId) {
        CDVPluginResult *pluginResult = nil;
        if (error) {
            NSLog(@"%@", error);
            pluginResult = [CDVPluginResult
                resultWithStatus:CDVCommandStatus_ERROR
                messageAsString:[error localizedDescription]
            ];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:writeCallbackId];
        [writeCallbacks removeObjectForKey:key];
    }

}

- (void)peripheral:(CBPeripheral*)peripheral didReadRSSI:(NSNumber*)rssi error:(NSError*)error {
    NSLog(@"didReadRSSI %@", rssi);
    NSString *key = [peripheral uuidAsString];
    NSString *readRSSICallbackId = [readRSSICallbacks objectForKey: key];
    [peripheral setSavedRSSI:rssi];
    if (readRSSICallbackId) {
        CDVPluginResult* pluginResult = nil;
        if (error) {
            NSLog(@"%@", error);
            pluginResult = [CDVPluginResult
                resultWithStatus:CDVCommandStatus_ERROR
                messageAsString:[error localizedDescription]];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                messageAsInt: (int) [rssi integerValue]];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId: readRSSICallbackId];
        [readRSSICallbacks removeObjectForKey:readRSSICallbackId];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didOpenL2CAPChannel:(CBL2CAPChannel*)channel error:(NSError*)error {
    NSLog(@"didOpenL2CAPChannel %@", channel);
    BLEStreamContext *context = [self findStreamContextFromPeripheral:peripheral andPSM:[channel PSM]];
    if (error) {
        [context closeWithReason:[error localizedDescription]];
    } else if (channel) {
        [channel.inputStream setDelegate:context];
        [channel.outputStream setDelegate:context];
        [channel.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [channel.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [channel.inputStream open];
        [channel.outputStream open];
        [context setChannel:channel];
    } else {
        [context closeWithReason:@"No L2CAP channel provided"];
    }
}

#pragma mark - internal implemetation

- (CBPeripheral*)findPeripheralByUUID:(NSUUID*)uuid {
    CBPeripheral *peripheral = nil;

    for (CBPeripheral *p in peripherals) {

        NSUUID* other = p.identifier;

        if ([uuid isEqual:other]) {
            peripheral = p;
            break;
        }
    }
    return peripheral;
}

- (CBPeripheral*)retrievePeripheralWithUUID:(NSUUID*)typedUUID {
    NSArray *existingPeripherals = [manager retrievePeripheralsWithIdentifiers:@[typedUUID]];
    CBPeripheral *peripheral = nil;
    if ([existingPeripherals count] > 0) {
        peripheral = [existingPeripherals firstObject];
        [peripherals addObject:peripheral];
    }
    return peripheral;
}

// RedBearLab
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID])
            return s;
    }

    return nil; //Service not found on this peripheral
}

// Find a characteristic in service with a specific property
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service prop:(CBCharacteristicProperties)prop {
    NSLog(@"Looking for %@ with properties %lu", UUID, (unsigned long)prop);
    for(int i=0; i < service.characteristics.count; i++)
    {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ((c.properties & prop) != 0x0 && [c.UUID.UUIDString isEqualToString: UUID.UUIDString]) {
            return c;
        }
    }
   return nil; //Characteristic with prop not found on this service
}

// Find a characteristic in service by UUID
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    NSLog(@"Looking for %@", UUID);
    for(int i=0; i < service.characteristics.count; i++)
    {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([c.UUID.UUIDString isEqualToString: UUID.UUIDString]) {
            return c;
        }
    }
   return nil; //Characteristic not found on this service
}

-(BLEStreamContext*) findStreamContextFromPeripheral:(CBPeripheral*)peripheral andPSM:(UInt16)psm {
    NSString *key = [self keyForPeripheral:peripheral andPSM:psm];
    BLEStreamContext *context = [l2CapContexts objectForKey:key];
    if (!context) {
        context = [BLEStreamContext alloc];
        [context setCommandDelegate:self.commandDelegate];
        [l2CapContexts setObject:context forKey:key];
    }
    return context;
}

// RedBearLab
-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1 length:16];
    [UUID2.data getBytes:b2 length:16];

    if (memcmp(b1, b2, UUID1.data.length) == 0)
        return 1;
    else
        return 0;
}

-(NSUUID*) getUUID:(CDVInvokedUrlCommand*)command argumentAtIndex:(NSUInteger)index {
    NSLog(@"getUUID");
    
    NSString *uuidString = [command argumentAtIndex:index withDefault:@"" andClass:[NSString class]];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    if (uuid == nil) {
        NSString *errorMessage = [NSString stringWithFormat:@"Malformed UUID: %@", [command argumentAtIndex:index]];
        NSLog(@"%@", errorMessage);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return nil;
    }
    return uuid;
}

// expecting deviceUUID, serviceUUID, characteristicUUID in command.arguments
-(BLECommandContext*) getData:(CDVInvokedUrlCommand*)command prop:(CBCharacteristicProperties)prop {
    NSLog(@"getData");

    CDVPluginResult *pluginResult = nil;

    NSUUID *deviceUUID = [self getUUID:command argumentAtIndex:0];
    if (deviceUUID == nil) {
        return nil;
    }

    NSUUID *serviceNSUUID = [self getUUID:command argumentAtIndex:1];
    if (serviceNSUUID == nil) {
        return nil;
    }
    
    NSUUID *characteristicNSUUID = [self getUUID:command argumentAtIndex:2];
    if (characteristicNSUUID == nil) {
        return nil;
    }
    
    CBUUID *serviceUUID = [CBUUID UUIDWithNSUUID:serviceNSUUID];
    CBUUID *characteristicUUID = [CBUUID UUIDWithNSUUID:characteristicNSUUID];

    CBPeripheral *peripheral = [self findPeripheralByUUID:deviceUUID];

    if (!peripheral) {

        NSLog(@"Could not find peripheral with UUID %@", deviceUUID);

        NSString *errorMessage = [NSString stringWithFormat:@"Could not find peripheral with UUID %@", deviceUUID];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return nil;
    }

    CBService *service = [self findServiceFromUUID:serviceUUID p:peripheral];

    if (!service) {
        NSString *errorMessage = [NSString stringWithFormat:@"Could not find service with UUID %@ on peripheral with UUID %@",
                                  serviceNSUUID.UUIDString,
                                  peripheral.identifier.UUIDString];
        NSLog(@"%@", errorMessage);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return nil;
    }

    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service prop:prop];

    // Special handling for INDICATE. If charateristic with notify is not found, check for indicate.
    if (prop == CBCharacteristicPropertyNotify && !characteristic) {
        characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service prop:CBCharacteristicPropertyIndicate];
    }

    // As a last resort, try and find ANY characteristic with this UUID, even if it doesn't have the correct properties
    if (!characteristic) {
        characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    }

    if (!characteristic) {
        NSString *errorMessage = [NSString stringWithFormat:
                                  @"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
                                  characteristicNSUUID.UUIDString,
                                  serviceNSUUID.UUIDString,
                                  peripheral.identifier.UUIDString];
        NSLog(@"%@", errorMessage);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return nil;
    }

    BLECommandContext *context = [[BLECommandContext alloc] init];
    [context setPeripheral:peripheral];
    [context setService:service];
    [context setCharacteristic:characteristic];
    return context;
}

-(NSString *) keyForPeripheral: (CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic {
    return [NSString stringWithFormat:@"%@|%@|%@", [peripheral uuidAsString], [characteristic.service UUID], [characteristic UUID]];
}

-(NSString *) keyForPeripheral: (CBPeripheral *)peripheral andPSM:(UInt16)psm {
    return [NSString stringWithFormat:@"%@|%hu", [peripheral uuidAsString], psm];
}


+(BOOL) isKey: (NSString *)key forPeripheral:(CBPeripheral *)peripheral {
    NSArray *keyArray = [key componentsSeparatedByString: @"|"];
    return [[peripheral uuidAsString] compare:keyArray[0]] == NSOrderedSame;
}

-(void) cleanupOperationCallbacks: (CBPeripheral *)peripheral withResult:(CDVPluginResult *) result {
    for(id key in readCallbacks.allKeys) {
        if([BLECentralPlugin isKey:key forPeripheral:peripheral]) {
            NSString *callbackId = [readCallbacks valueForKey:key];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
            [readCallbacks removeObjectForKey:key];
            NSLog(@"Cleared read callback %@ for key %@", callbackId, key);
        }
    }
    for(id key in writeCallbacks.allKeys) {
        if([BLECentralPlugin isKey:key forPeripheral:peripheral]) {
            NSString *callbackId = [writeCallbacks valueForKey:key];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
            [writeCallbacks removeObjectForKey:key];
            NSLog(@"Cleared write callback %@ for key %@", callbackId, key);
        }
    }
    for(id key in startNotificationCallbacks.allKeys) {
        if([BLECentralPlugin isKey:key forPeripheral:peripheral]) {
            NSString *callbackId = [startNotificationCallbacks valueForKey:key];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
            [startNotificationCallbacks removeObjectForKey:key];
            NSLog(@"Cleared start notification callback %@ for key %@", callbackId, key);
        }
    }
    for(id key in stopNotificationCallbacks.allKeys) {
        if([BLECentralPlugin isKey:key forPeripheral:peripheral]) {
            NSString *callbackId = [stopNotificationCallbacks valueForKey:key];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
            [stopNotificationCallbacks removeObjectForKey:key];
            NSLog(@"Cleared stop notification callback %@ for key %@", callbackId, key);
        }
    }
    for(id key in notificationCallbacks.allKeys) {
        if([BLECentralPlugin isKey:key forPeripheral:peripheral]) {
            NSString *callbackId = [notificationCallbacks valueForKey:key];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
            [notificationCallbacks removeObjectForKey:key];
            NSLog(@"Cleared notification callback %@ for key %@", callbackId, key);
        }
    }
    for(id key in l2CapContexts.allKeys) {
        if([BLECentralPlugin isKey:key forPeripheral:peripheral]) {
            BLEStreamContext *context = [l2CapContexts valueForKey:key];
            [context closeWithResult:result];
            [l2CapContexts removeObjectForKey:key];
            NSLog(@"Cleared L2CAP context for key %@", key);
        }
    }
}

#pragma mark - util

- (NSString*) centralManagerStateToString: (int)state {
    switch(state)
    {
        case CBCentralManagerStateUnknown:
            return @"State unknown (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateResetting:
            return @"State resetting (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateUnsupported:
            return @"State BLE unsupported (CBCentralManagerStateResetting)";
        case CBCentralManagerStateUnauthorized:
            return @"State unauthorized (CBCentralManagerStateUnauthorized)";
        case CBCentralManagerStatePoweredOff:
            return @"State BLE powered off (CBCentralManagerStatePoweredOff)";
        case CBCentralManagerStatePoweredOn:
            return @"State powered up and ready (CBCentralManagerStatePoweredOn)";
        default:
            return @"State unknown";
    }

    return @"Unknown state";
}

- (NSArray<CBUUID *> *) uuidStringsToCBUUIDs: (NSArray<NSString *> *)uuidStrings {
    NSMutableArray *uuids = [NSMutableArray new];
    for (int i = 0; i < [uuidStrings count]; i++) {
        NSString *uuidString = [uuidStrings objectAtIndex: i];
        if (![uuidString isKindOfClass:[NSString class]]) {
            NSLog(@"Malformed UUID found: %@", uuidString);
            return nil;
        }
        
        NSUUID *nsuuid = [[NSUUID alloc]initWithUUIDString:uuidString];
        if (nsuuid == nil) {
            NSLog(@"Malformed UUID found: %@", uuidString);
            return nil;
        }
        
        CBUUID *uuid = [CBUUID UUIDWithNSUUID:nsuuid];
        [uuids addObject:uuid];
    }
    return uuids;
}

- (NSArray<NSUUID *> *) uuidStringsToNSUUIDs: (NSArray<NSString *> *)uuidStrings {
    NSMutableArray *uuids = [NSMutableArray new];
    for (int i = 0; i < [uuidStrings count]; i++) {
        NSString *uuidString = [uuidStrings objectAtIndex: i];
        if (![uuidString isKindOfClass:[NSString class]]) {
            NSLog(@"Malformed UUID found: %@", uuidString);
            return nil;
        }
        
        NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:uuidString];
        if (uuid == nil) {
            NSLog(@"Malformed UUID found: %@", uuidString);
            return nil;
        }
        
        [uuids addObject:uuid];
    }
    return uuids;
}

- (BOOL) isFalsey:(NSString *)value {
    return value == nil || [value length] == 0 || [@"false" isEqualToString:[value lowercaseString]];
}

- (id) tryDecodeBinaryData:(id)value {
    if (value != nil && [value isKindOfClass:[NSString class]]) {
        NSData *decoded = [[NSData alloc] initWithBase64EncodedString:value options:0];
        if (decoded != nil) {
            return decoded;
        }
    }
    return value;
}

- (void) internalStopScan {
    [scanTimer invalidate];
    scanTimer = nil;
    
    if ([manager state] == CBManagerStatePoweredOn) {
        [manager stopScan];
    }

    if (discoverPeripheralCallbackId) {
        discoverPeripheralCallbackId = nil;
    }
}

@end
