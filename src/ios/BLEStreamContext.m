//
//  BLEStreamContext.m
//  Peripheral & PSM specific stream delegate
//

#import "BLEStreamContext.h"

@implementation BLEStreamContext

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"L2CAP stream is opened");
            if (self.connectionStateCallbackId) {
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [result setKeepCallbackAsBool:true];
                [self.commandDelegate sendPluginResult:result callbackId:self.connectionStateCallbackId];
                // keep connection state callback as this will be triggered when the stream disconnects
            }
            break;
            
        case NSStreamEventEndEncountered:
            NSLog(@"L2CAP stream end encountered");
            [self closeWithReason:@"L2CAP Stream end encountered"];
            break;
            
        case NSStreamEventHasBytesAvailable: {
            // NSLog(@"L2CAP stream bytes available");
            uint8_t buf[512];
            NSInteger len = [(NSInputStream *)stream read:buf maxLength:512];
            if (len > 0 && self.readCallbackId) {
                NSData *data = [NSData dataWithBytes:buf length:len];
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArrayBuffer:data];
                [result setKeepCallbackAsBool:true];
                [self.commandDelegate sendPluginResult:result callbackId:self.readCallbackId];
            }
            NSLog(@"Read %ld bytes from L2CAP stream", len);
            break;
        }
            
        case NSStreamEventHasSpaceAvailable:
            // NSLog(@"L2CAP stream space is available");
            [self doSend];
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"L2CAP stream error");
            [self closeWithReason:@"L2CAP stream error"];
            break;
            
        default:
            NSLog(@"Unknown stream event: %lu", (unsigned long)eventCode);
            break;
    }
}

-(void)closeWithReason:(NSString*)reason {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:reason];
    [self closeWithResult:result];
}

-(void)closeWithResult:(CDVPluginResult*)result {
    if (self.connectionStateCallbackId) {
        [self.commandDelegate sendPluginResult:result callbackId:self.connectionStateCallbackId];
        self.connectionStateCallbackId = nil;
    }
    
    if (self.readCallbackId) {
        [self.commandDelegate sendPluginResult:result callbackId:self.readCallbackId];
        self.readCallbackId = nil;
    }
    
    if (writeCallbackId) {
        [self.commandDelegate sendPluginResult:result callbackId:writeCallbackId];
        writeCallbackId = nil;
    }
    
    sendQueue = nil;
    
    [self.channel.inputStream close];
    [self.channel.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.channel.outputStream close];
    [self.channel.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.channel = nil;
}

-(void)write:(NSData*)message callbackId:(NSString*)callbackId {
    CDVPluginResult *errorResult = nil;
    if (sendQueue != nil) {
        NSLog(@"Unable to write as L2CAP write already in progress");
        errorResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                        messageAsString:@"L2CAP write already in progress"];
    }
    if (self.channel == nil) {
        NSLog(@"Unable to write as L2CAP channel is closed");
        errorResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                        messageAsString:@"L2CAP channel not connected"];
    }
    if (errorResult) {
        [_commandDelegate sendPluginResult:errorResult callbackId:callbackId];
        return;
    }
    sendQueue = message;
    writeCallbackId = callbackId;
    sentBytes = 0;
    [self doSend];
}

-(void)doSend {
    if (sendQueue && sentBytes < [sendQueue length]) {
        sendQueue = [sendQueue subdataWithRange:NSMakeRange(sentBytes, [sendQueue length] - sentBytes)];
        sentBytes = [self.channel.outputStream write:[sendQueue bytes] maxLength:[sendQueue length]];
        NSLog(@"Sending %ld bytes to L2CAP stream", sentBytes);
    } else {
        sendQueue = nil;
        if (writeCallbackId) {
            NSLog(@"Sending bytes to L2CAP stream complete");
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [_commandDelegate sendPluginResult:result callbackId:writeCallbackId];
            writeCallbackId = nil;
        }
    }
}

@end
