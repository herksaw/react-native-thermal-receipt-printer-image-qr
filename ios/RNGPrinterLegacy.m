#import "RNGPrinterLegacy.h"
// #import "PrinterSDK.h"
// #import "TscCommand.h"
// #import "ConnecterManager.h"
#import <React/RCTLog.h>
#import "GPrinterLegacy/GSDK/GSDK.framework/Headers/EthernetConnecter.h"
#import "GPrinterLegacy/GSDK/GSDK.framework/Headers/TscCommand.h"

@implementation RNGPrinterLegacy

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(init:(RCTResponseSenderBlock)successCallback
                  fail:(RCTResponseSenderBlock)errorCallback) {
    connected_ip = nil;
    is_scanning = NO;
    _printerArray = [NSMutableArray new];
    connecter = [[EthernetConnecter alloc] init];
    successCallback(@[@"Init successful"]);
}

RCT_EXPORT_METHOD(connectIP:(NSString *)ip
                  withPort:(nonnull NSNumber *)port
                  success:(RCTResponseSenderBlock)successCallback
                  fail:(RCTResponseSenderBlock)errorCallback) {
    @try {
        [connecter connectIP:ip port:[port intValue] connectState:^(ConnectState state) {
            if (state == CONNECT_STATE_CONNECTED) {
                connected_ip = ip;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GPrinterConnected" object:nil];
                successCallback(@[[NSString stringWithFormat:@"Connecting to printer %@", ip]]);
            } else {
                errorCallback(@[[NSString stringWithFormat:@"Failed to connect to printer %@", ip]]);
            }
        }];
    } @catch (NSException *exception) {
        errorCallback(@[exception.reason]);
    }
}

RCT_EXPORT_METHOD(addStrToCommand:(NSString *)str
                  success:(RCTResponseSenderBlock)successCallback
                  fail:(RCTResponseSenderBlock)errorCallback) {
    @try {
        !connected_ip ? [NSException raise:@"Invalid connection" format:@"Can't connect to printer"] : nil;
        
        TscCommand *command = [[TscCommand alloc] init];
        [command addStrToCommand:str];
        NSData *data = [command getCommand];
        
        [connecter write:data];
        successCallback(@[@"Command sent successfully"]);
    } @catch (NSException *exception) {
        errorCallback(@[exception.reason]);
    }
}

RCT_EXPORT_METHOD(addNSDataToCommand:(NSString *)base64Data
                  success:(RCTResponseSenderBlock)successCallback
                  fail:(RCTResponseSenderBlock)errorCallback) {
    @try {
        !connected_ip ? [NSException raise:@"Invalid connection" format:@"Can't connect to printer"] : nil;
        
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64Data options:0];
        if (!data) {
            [NSException raise:@"Invalid data" format:@"Invalid base64 data"];
        }
        
        TscCommand *command = [[TscCommand alloc] init];
        [command addNSDataToCommand:data];
        NSData *commandData = [command getCommand];
        
        [connecter write:commandData];
        successCallback(@[@"Data sent successfully"]);
    } @catch (NSException *exception) {
        errorCallback(@[exception.reason]);
    }
}

RCT_EXPORT_METHOD(addPrint:(nonnull NSNumber *)m
                  withN:(nonnull NSNumber *)n
                  success:(RCTResponseSenderBlock)successCallback
                  fail:(RCTResponseSenderBlock)errorCallback) {
    @try {
        !connected_ip ? [NSException raise:@"Invalid connection" format:@"Can't connect to printer"] : nil;
        
        TscCommand *command = [[TscCommand alloc] init];
        [command addPrint:[m intValue] :[n intValue]];
        NSData *data = [command getCommand];
        
        [connecter write:data];
        successCallback(@[@"Print command sent successfully"]);
    } @catch (NSException *exception) {
        errorCallback(@[exception.reason]);
    }
}

RCT_EXPORT_METHOD(addCls:(RCTResponseSenderBlock)successCallback
                  fail:(RCTResponseSenderBlock)errorCallback) {
    @try {
        !connected_ip ? [NSException raise:@"Invalid connection" format:@"Can't connect to printer"] : nil;
        
        TscCommand *command = [[TscCommand alloc] init];
        [command addCls];
        NSData *data = [command getCommand];
        
        [connecter write:data];
        successCallback(@[@"Clear command sent successfully"]);
    } @catch (NSException *exception) {
        errorCallback(@[exception.reason]);
    }
}

RCT_EXPORT_METHOD(closeConn) {
    @try {
        [connecter close];
        connected_ip = nil;
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

RCT_EXPORT_METHOD(close:(RCTResponseSenderBlock)successCallback
                  fail:(RCTResponseSenderBlock)errorCallback) {
    @try {
        [connecter close];
        connected_ip = nil;
        successCallback(@[@"Connection closed successfully"]);
    } @catch (NSException *exception) {
        errorCallback(@[exception.reason]);
    }
}

@end 