//
//  CBPeripheral+Extensions.m
//  BLE Central Cordova Plugin
//
//  (c) 2104 Don Coleman
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

#import "CBPeripheral+Extensions.h"

static char ADVERTISING_IDENTIFER;
static char ADVERTISEMENT_RSSI_IDENTIFER;

@implementation CBPeripheral(com_megster_ble_extension)

-(NSDictionary *)asDictionary {

    NSString *uuidString = NULL;
    if ([self UUID]) {
        uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, self.UUID);
    } else {
        uuidString = @"";
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject: uuidString forKey: @"id"];

    if ([self name]) {
        [dictionary setObject: [self name] forKey: @"name"];
    }

    if ([self RSSI]) {
        [dictionary setObject: [self RSSI] forKey: @"rssi"];
    } else if ([self advertisementRSSI]) {
        [dictionary setObject: [self advertisementRSSI] forKey: @"rssi"];
    }

    if ([self advertising]) {
        [dictionary setObject: [self advertising] forKey: @"advertising"];
    }

    return dictionary;

}

// AdvertisementData is from didDiscoverPeripheral. RFduino advertises a service name in the Mfg Data Field.
-(void)setAdvertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)rssi{

    [self setAdvertising:[self serializableAdvertisementData: advertisementData]];
    [self setAdvertisementRSSI: rssi];

}

// Translates the Advertisement Data from didDiscoverPeripheral into a structure that can be serialized as JSON
//
// This version keeps the iOS constants for keys, future versions could create more friendly keys
//
// Advertisement Data from a Peripheral could look something like
//
// advertising = {
//     kCBAdvDataChannel = 39;
//     kCBAdvDataIsConnectable = 1;
//     kCBAdvDataLocalName = foo;
//     kCBAdvDataManufacturerData = {
//         CDVType = ArrayBuffer;
//         data = "AABoZWxsbw==";
//     };
//     kCBAdvDataServiceData = {
//         FED8 = {
//             CDVType = ArrayBuffer;
//             data = "ACAAYWJjBw==";
//         };
//     };
//     kCBAdvDataServiceUUIDs = (
//         FED8
//     );
//     kCBAdvDataTxPowerLevel = 32;
//};
- (NSDictionary *) serializableAdvertisementData: (NSDictionary *) advertisementData {

    NSMutableDictionary *dict = [advertisementData mutableCopy];

    // Service Data is a dictionary of CBUUID and NSData
    // Convert to String keys with Array Buffer values
    NSMutableDictionary *serviceData = [dict objectForKey:CBAdvertisementDataServiceDataKey];
    if (serviceData) {
        NSLog(@"%@", serviceData);

        for(CBUUID *key in serviceData) {
            [serviceData setObject:dataToArrayBuffer([serviceData objectForKey:key]) forKey:[key UUIDString]];
            [serviceData removeObjectForKey:key];
        }
    }

    // Create a new list of Service UUIDs as Strings instead of CBUUIDs
    NSMutableArray *serviceUUIDs = [dict objectForKey:CBAdvertisementDataServiceUUIDsKey];
    NSMutableArray *serviceUUIDStrings;
    if (serviceUUIDs) {
        serviceUUIDStrings = [[NSMutableArray alloc] initWithCapacity:serviceUUIDs.count];

        for (CBUUID *uuid in serviceUUIDs) {
            [serviceUUIDStrings addObject:[uuid UUIDString]];
        }

        // replace the UUID list with list of strings
        [dict removeObjectForKey:CBAdvertisementDataServiceUUIDsKey];
        [dict setObject:serviceUUIDStrings forKey:CBAdvertisementDataServiceUUIDsKey];

    }

    // Convert the manufacturer data
    NSData *mfgData = [dict objectForKey:CBAdvertisementDataManufacturerDataKey];
    if (mfgData) {
        [dict setObject:dataToArrayBuffer([dict objectForKey:CBAdvertisementDataManufacturerDataKey]) forKey:CBAdvertisementDataManufacturerDataKey];
    }

    return dict;
}

// Borrowed from Cordova messageFromArrayBuffer since Cordova doesn't handle NSData in NSDictionary
id dataToArrayBuffer(NSData* data)
{
    return @{
             @"CDVType" : @"ArrayBuffer",
             @"data" :[data base64EncodedString]
             };
}


-(void)setAdvertising:(NSDictionary *)newAdvertisingValue{
    objc_setAssociatedObject(self, &ADVERTISING_IDENTIFER, newAdvertisingValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)advertising{
    return objc_getAssociatedObject(self, &ADVERTISING_IDENTIFER);
}


-(void)setAdvertisementRSSI:(NSNumber *)newAdvertisementRSSIValue {
    objc_setAssociatedObject(self, &ADVERTISEMENT_RSSI_IDENTIFER, newAdvertisementRSSIValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)advertisementRSSI{
    return objc_getAssociatedObject(self, &ADVERTISEMENT_RSSI_IDENTIFER);
}

@end

