#import "RNNetLabelPrinter.h"
#import <IOS_SWIFT_WIFI_SDK/IOS_SWIFT_WIFI_SDK-Swift.h>

@implementation RNNetLabelPrinter {
    GTSPL_WIFI *gswifi;
    bool hasListeners;
}

RCT_EXPORT_MODULE()

- (instancetype)init {
    self = [super init];
    if (self) {
        gswifi = [[GTSPL_WIFI alloc] init];
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"printerStatus"];
}

- (void)startObserving {
    hasListeners = YES;
}

- (void)stopObserving {
    hasListeners = NO;
}

RCT_EXPORT_METHOD(init:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    resolve(nil);
}

RCT_EXPORT_METHOD(openPort:(NSString *)ip
                  port:(NSInteger)port
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    [gswifi openportWithIP:ip Port:port completion:^(NSString *msg) {
        if ([msg isEqualToString:@"Success"]) {
            resolve(nil);
        } else {
            reject(@"error", msg, nil);
        }
    }];
}

RCT_EXPORT_METHOD(closePort:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    [gswifi closePort];
    resolve(nil);
}

RCT_EXPORT_METHOD(setup:(NSInteger)width
                  height:(NSInteger)height
                  speed:(NSInteger)speed
                  density:(NSInteger)density
                  sensor:(NSInteger)sensor
                  sensorDistance:(NSInteger)sensorDistance
                  sensorOffset:(NSInteger)sensorOffset
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    [gswifi setupWithWidth:width height:height speed:speed density:density sensor:sensor sensorDistance:sensorDistance sensorOffset:sensorOffset];
    resolve(nil);
}

RCT_EXPORT_METHOD(clearBuffer:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    [gswifi clearBuffer];
    resolve(nil);
}

RCT_EXPORT_METHOD(printBarcode:(NSInteger)x
                  y:(NSInteger)y
                  type:(NSString *)type
                  height:(NSInteger)height
                  humanReadable:(NSInteger)humanReadable
                  rotation:(NSInteger)rotation
                  narrow:(NSInteger)narrow
                  wide:(NSInteger)wide
                  content:(NSString *)content
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    [gswifi printBarcodeWithX:x y:y type:type height:height human_readable:humanReadable rotation:rotation narrow:narrow wide:wide content:content];
    resolve(nil);
}

RCT_EXPORT_METHOD(printFont:(NSInteger)x
                  y:(NSInteger)y
                  fontName:(NSString *)fontName
                  rotation:(NSInteger)rotation
                  xScale:(NSInteger)xScale
                  yScale:(NSInteger)yScale
                  content:(NSString *)content
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    [gswifi printFontWithX:x y:y fontname:fontName rotation:rotation xScale:xScale yScale:yScale content:content];
    resolve(nil);
}

RCT_EXPORT_METHOD(printFontBlock:(NSInteger)x
                  y:(NSInteger)y
                  width:(NSInteger)width
                  height:(NSInteger)height
                  fontName:(NSString *)fontName
                  rotation:(NSInteger)rotation
                  xScale:(NSInteger)xScale
                  yScale:(NSInteger)yScale
                  space:(NSInteger)space
                  align:(NSInteger)align
                  content:(NSString *)content
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    [gswifi printFontBlockWithX:x y:y width:width height:height fontname:fontName rotation:rotation xScale:xScale yScale:yScale space:space align:align content:content];
    resolve(nil);
}

RCT_EXPORT_METHOD(printQRCode:(NSInteger)x
                  y:(NSInteger)y
                  eccLevel:(NSString *)eccLevel
                  cellWidth:(NSInteger)cellWidth
                  rotation:(NSInteger)rotation
                  content:(NSString *)content
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    [gswifi printQRCodeWithX:x y:y eccLevel:eccLevel cellWidth:cellWidth rotation:rotation content:content];
    resolve(nil);
}

RCT_EXPORT_METHOD(printLabel:(NSInteger)set
                  copy:(NSInteger)copy
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    [gswifi printLabelWithSet:set copy:copy];
    resolve(nil);
}

RCT_EXPORT_METHOD(getPrinterStatus:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    NSString *status = [gswifi printerStatus];
    resolve(status);
}

@end 