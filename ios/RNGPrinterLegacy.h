#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <GSDK/EthernetConnecter.h>
#import <GSDK/TscCommand.h>

@interface RNGPrinterLegacy : RCTEventEmitter <RCTBridgeModule> {
    NSString *connected_ip;
    NSString *current_scan_ip;
    NSMutableArray* _printerArray;
    bool is_scanning;
    EthernetConnecter *connecter;
}

@end 