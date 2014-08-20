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

@implementation CBPeripheral(com_megster_rfduino_extension)

-(NSDictionary *)asDictionary {
    
    NSString *uuidString = NULL;
    if ([self UUID]) {
        uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, self.UUID);
    } else {
        uuidString = @"";
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject: uuidString forKey: @"id"];
    
    // TODO what should when this is null?
    if ([self name]) {
        [dictionary setObject: [self name] forKey: @"name"];
    }
    
    if ([self RSSI]) {
        [dictionary setObject: [self RSSI] forKey: @"rssi"];
    } else if ([self advertisementRSSI]) {
        [dictionary setObject: [self advertisementRSSI] forKey: @"rssi"];
    }
    
    // TODO remove this RFduino specific code
    if ([self advertising]) {
        [dictionary setObject: [self advertising] forKey: @"advertising"];
    }
    
    return dictionary;

}

// AdvertisementData is from didDiscoverPeripheral. RFduino advertises a service name in the Mfg Data Field.
-(void)setAdvertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)rssi{
    
    // TODO send raw advertisement data, write a parser in JavaScript

//    if (advertisementData) {
//        id manufacturerData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
//        if (manufacturerData) {
//            const uint8_t *bytes = [manufacturerData bytes];
//            int len = [manufacturerData length];
//            // skip manufacturer uuid
//            NSData *data = [NSData dataWithBytes:bytes+2 length:len-2];
//            [self setAdvertising: [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
//        }
//    }
    
    // TODO Android sends back the raw bytes, iOS puts this in a dictionary
    // See Advertisement Data Retrieval Keys https://developer.apple.com/library/mac/documentation/CoreBluetooth/Reference/CBCentralManagerDelegate_Protocol/translated_content/CBCentralManagerDelegate.html#//apple_ref/doc/constant_group/Advertisement_Data_Retrieval_Keys
    [self setAdvertising:@"[]"];
    [self setAdvertisementRSSI: rssi];
}

-(void)setAdvertising:(NSString *)newAdvertisingValue{
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

