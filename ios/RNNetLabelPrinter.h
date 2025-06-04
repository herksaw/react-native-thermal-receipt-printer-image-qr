#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RNNetLabelPrinter : RCTEventEmitter <RCTBridgeModule>

- (void)init:(RCTPromiseResolveBlock)resolve
      reject:(RCTPromiseRejectBlock)reject;

- (void)openPort:(NSString *)ip
            port:(NSInteger)port
         resolve:(RCTPromiseResolveBlock)resolve
          reject:(RCTPromiseRejectBlock)reject;

- (void)closePort:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject;

- (void)setup:(NSInteger)width
        height:(NSInteger)height
        speed:(NSInteger)speed
      density:(NSInteger)density
       sensor:(NSInteger)sensor
sensorDistance:(NSInteger)sensorDistance
 sensorOffset:(NSInteger)sensorOffset
      resolve:(RCTPromiseResolveBlock)resolve
       reject:(RCTPromiseRejectBlock)reject;

- (void)clearBuffer:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject;

- (void)printBarcode:(NSInteger)x
                   y:(NSInteger)y
                type:(NSString *)type
              height:(NSInteger)height
        humanReadable:(NSInteger)humanReadable
            rotation:(NSInteger)rotation
              narrow:(NSInteger)narrow
                wide:(NSInteger)wide
             content:(NSString *)content
             resolve:(RCTPromiseResolveBlock)resolve
              reject:(RCTPromiseRejectBlock)reject;

- (void)printFont:(NSInteger)x
                y:(NSInteger)y
         fontName:(NSString *)fontName
         rotation:(NSInteger)rotation
          xScale:(NSInteger)xScale
          yScale:(NSInteger)yScale
          content:(NSString *)content
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject;

- (void)printFontBlock:(NSInteger)x
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
              reject:(RCTPromiseRejectBlock)reject;

- (void)printQRCode:(NSInteger)x
                  y:(NSInteger)y
            eccLevel:(NSString *)eccLevel
          cellWidth:(NSInteger)cellWidth
           rotation:(NSInteger)rotation
            content:(NSString *)content
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject;

- (void)printLabel:(NSInteger)set
              copy:(NSInteger)copy
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject;

- (void)getPrinterStatus:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject;

- (void)sendCommand:(NSString *)command
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject;

- (void)sendByteCmd:(NSArray<NSNumber *> *)byteArray
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject;                  

@end 