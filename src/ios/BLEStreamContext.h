//
//  BLEStreamContext
//  Peripheral & PSM specific stream delegate
//

#import <Cordova/CDV.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class BLEStreamContext;

@interface BLEStreamContext : NSObject <NSStreamDelegate> {
    NSString *writeCallbackId;
    NSData *sendQueue;
    NSInteger sentBytes;
};

@property (nonatomic) NSString *connectionStateCallbackId;
@property (nonatomic) NSString *readCallbackId;
@property (nonatomic, weak) id <CDVCommandDelegate> commandDelegate;
@property (nonatomic) CBL2CAPChannel *channel;

-(void)closeWithReason:(NSString*)reason;
-(void)closeWithResult:(CDVPluginResult*)result;

-(void)write:(NSData*)message callbackId:(NSString*)callbackId;

@end

