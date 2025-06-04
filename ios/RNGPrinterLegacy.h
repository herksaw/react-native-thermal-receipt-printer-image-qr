#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import "GPrinterLegacy/GSDK/GSDK.framework/Headers/EthernetConnecter.h"
#import "GPrinterLegacy/GSDK/GSDK.framework/Headers/TscCommand.h"

@interface RNGPrinterLegacy : RCTEventEmitter <RCTBridgeModule> {
    NSString *connected_ip;
    NSString *current_scan_ip;
    NSMutableArray* _printerArray;
    bool is_scanning;
    EthernetConnecter *connecter;
}

@end 