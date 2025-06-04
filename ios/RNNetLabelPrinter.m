// #import <React/RCTBridgeModule.h>

// @interface RCT_EXTERN_MODULE(RNNetLabelPrinter, NSObject)

// RCT_EXTERN_METHOD(init:(RCTPromiseResolveBlock)resolve
//                   reject:(RCTPromiseRejectBlock)reject)

// RCT_EXTERN_METHOD(openPort:(NSString *)ip
//                   port:(nonnull NSNumber *)port
//                   resolve:(RCTPromiseResolveBlock)resolve
//                   reject:(RCTPromiseRejectBlock)reject)

// RCT_EXTERN_METHOD(closePort:(RCTPromiseResolveBlock)resolve
//                   reject:(RCTPromiseRejectBlock)reject)

// RCT_EXTERN_METHOD(setup:(nonnull NSNumber *)width
//                   height:(nonnull NSNumber *)height
//                   speed:(nonnull NSNumber *)speed
//                   density:(nonnull NSNumber *)density
//                   sensor:(nonnull NSNumber *)sensor
//                   sensorDistance:(nonnull NSNumber *)sensorDistance
//                   sensorOffset:(nonnull NSNumber *)sensorOffset
//                   resolve:(RCTPromiseResolveBlock)resolve
//                   reject:(RCTPromiseRejectBlock)reject)

// RCT_EXTERN_METHOD(clearBuffer:(RCTPromiseResolveBlock)resolve
//                   reject:(RCTPromiseRejectBlock)reject)

// RCT_EXTERN_METHOD(printBarcode:(nonnull NSNumber *)x
//                   y:(nonnull NSNumber *)y
//                   type:(NSString *)type
//                   height:(nonnull NSNumber *)height
//                   humanReadable:(nonnull NSNumber *)humanReadable
//                   rotation:(nonnull NSNumber *)rotation
//                   narrow:(nonnull NSNumber *)narrow
//                   wide:(nonnull NSNumber *)wide
//                   content:(NSString *)content
//                   resolve:(RCTPromiseResolveBlock)resolve
//                   reject:(RCTPromiseRejectBlock)reject)

// RCT_EXTERN_METHOD(printFont:(nonnull NSNumber *)x
//                   y:(nonnull NSNumber *)y
//                   fontName:(NSString *)fontName
//                   rotation:(nonnull NSNumber *)rotation
//                   xScale:(nonnull NSNumber *)xScale
//                   yScale:(nonnull NSNumber *)yScale
//                   content:(NSString *)content
//                   resolve:(RCTPromiseResolveBlock)resolve
//                   reject:(RCTPromiseRejectBlock)reject)

// RCT_EXTERN_METHOD(printFontBlock:(nonnull NSNumber *)x
//                   y:(nonnull NSNumber *)y
//                   width:(nonnull NSNumber *)width
//                   height:(nonnull NSNumber *)height
//                   fontName:(NSString *)fontName
//                   rotation:(nonnull NSNumber *)rotation
//                   xScale:(nonnull NSNumber *)xScale
//                   yScale:(nonnull NSNumber *)yScale
//                   space:(nonnull NSNumber *)space
//                   align:(nonnull NSNumber *)align
//                   content:(NSString *)content
//                   resolve:(RCTPromiseResolveBlock)resolve
//                   reject:(RCTPromiseRejectBlock)reject)

// RCT_EXTERN_METHOD(printQRCode:(nonnull NSNumber *)x
//                   y:(nonnull NSNumber *)y
//                   eccLevel:(NSString *)eccLevel
//                   cellWidth:(nonnull NSNumber *)cellWidth
//                   rotation:(nonnull NSNumber *)rotation
//                   content:(NSString *)content
//                   resolve:(RCTPromiseResolveBlock)resolve
//                   reject:(RCTPromiseRejectBlock)reject)

// RCT_EXTERN_METHOD(printLabel:(nonnull NSNumber *)set
//                   copy:(nonnull NSNumber *)copy
//                   resolve:(RCTPromiseResolveBlock)resolve
//                   reject:(RCTPromiseRejectBlock)reject)

// RCT_EXTERN_METHOD(getPrinterStatus:(RCTPromiseResolveBlock)resolve
//                   reject:(RCTPromiseRejectBlock)reject)

// RCT_EXTERN_METHOD(sendCommand:(NSString *)command
//                   resolve:(RCTPromiseResolveBlock)resolve
//                   reject:(RCTPromiseRejectBlock)reject)

// RCT_EXTERN_METHOD(sendByteCmd:(NSArray<NSNumber *> *)byteArray
//                   resolve:(RCTPromiseResolveBlock)resolve
//                   reject:(RCTPromiseRejectBlock)reject)

// @end 