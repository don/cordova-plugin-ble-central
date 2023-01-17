/********************************************************************************************************
 * @file     CBUUID+Hex.m
 *
 * @brief    for TLSR chips
 *
 * @author   Telink, 梁家誌
 * @date     2019/10/16
 *
 * @par     Copyright (c) [2021], Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
 *
 *          Licensed under the Apache License, Version 2.0 (the "License");
 *          you may not use this file except in compliance with the License.
 *          You may obtain a copy of the License at
 *
 *              http://www.apache.org/licenses/LICENSE-2.0
 *
 *          Unless required by applicable law or agreed to in writing, software
 *          distributed under the License is distributed on an "AS IS" BASIS,
 *          WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *          See the License for the specific language governing permissions and
 *          limitations under the License.
 *******************************************************************************************************/

#import "CBUUID+Hex.h"

@implementation CBUUID (Hex)

/// Creates the UUID from a 32-character hexadecimal string.
- (instancetype)initWithHex:(NSString *)hex {
    if(self = [super init]){
        if (hex.length != 32) {
            return nil;
        }
        NSString *uuidString = [NSString stringWithFormat:@"%@_%@_%@_%@_%@",[hex substringWithRange:NSMakeRange(0, 8)],[hex substringWithRange:NSMakeRange(8, 4)],[hex substringWithRange:NSMakeRange(12, 4)],[hex substringWithRange:NSMakeRange(16, 4)],[hex substringWithRange:NSMakeRange(20, 12)]];
        CBUUID *uuid = [CBUUID UUIDWithString:uuidString];
        if(uuid == nil){
            return nil;
        }
        return uuid;
    }
    return nil;
}

/// Returns the uuidString without dashes.
- (NSString *)getHex {
    return [self.UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

/// The UUID as Data.
- (NSData *)getData {
    return [LibTools nsstringToHex:self.getHex];
}

@end
