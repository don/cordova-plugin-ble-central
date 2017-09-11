#import <Cordova/CDV.h>

typedef CDVPluginResult* (^HookBlock)(CDVPluginResult*);

@interface BLECentralPluginHook: NSObject{
    
    NSString * uuid;
    HookBlock didWriteValueForCharacteristic;
    HookBlock didUpdateValueForCharacteristic;
}

@property (readwrite, strong) NSString *uuid; // FIXME remove and manage hooks at peripheral level

@property (readwrite, nonatomic, copy) HookBlock didWriteValueForCharacteristic;

@property (readwrite, nonatomic, copy) HookBlock didUpdateValueForCharacteristic;

@end
