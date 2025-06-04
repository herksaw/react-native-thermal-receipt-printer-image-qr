import Foundation
import React
import IOS_SWIFT_WIFI_SDK

@objc(RNNetLabelPrinter)
class RNNetLabelPrinter: NSObject {
    private var gswifi: GTSPL_WIFI
    private var hasListeners: Bool = false
    
    override init() {
        gswifi = GTSPL_WIFI()
        super.init()
    }
    
    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc
    func supportedEvents() -> [String] {
        return ["printerStatus"]
    }
    
    @objc
    func startObserving() {
        hasListeners = true
    }
    
    @objc
    func stopObserving() {
        hasListeners = false
    }
    
    @objc
    func init(_ resolve: @escaping RCTPromiseResolveBlock,
              reject: @escaping RCTPromiseRejectBlock) {
        resolve(nil)
    }
    
    @objc
    func openPort(_ ip: String,
                  port: NSNumber,
                  resolve: @escaping RCTPromiseResolveBlock,
                  reject: @escaping RCTPromiseRejectBlock) {
        gswifi.openPort(IP: ip, port: port.intValue) { msg in
            if msg == "connected" {
                resolve(nil)
            } else {
                reject("error", msg, nil)
            }
        }
    }
    
    @objc
    func closePort(_ resolve: @escaping RCTPromiseResolveBlock,
                   reject: @escaping RCTPromiseRejectBlock) {
        gswifi.closePort { msg in
            resolve(nil)
        }
    }
    
    @objc
    func setup(_ width: NSNumber,
               height: NSNumber,
               speed: NSNumber,
               density: NSNumber,
               sensor: NSNumber,
               sensorDistance: NSNumber,
               sensorOffset: NSNumber,
               resolve: @escaping RCTPromiseResolveBlock,
               reject: @escaping RCTPromiseRejectBlock) {
        gswifi.setup(width: width.intValue,
                    height: height.intValue,
                    speed: speed.intValue,
                    density: density.intValue,
                    sensor: sensor.intValue,
                    sensorDistance: sensorDistance.intValue,
                    sensorOffset: sensorOffset.intValue) { msg in
            if msg == "Connection doesn't exist." {
                reject("connection_error", msg, nil)
            } else {
                resolve(nil)
            }
        }
    }
    
    @objc
    func clearBuffer(_ resolve: @escaping RCTPromiseResolveBlock,
                     reject: @escaping RCTPromiseRejectBlock) {
        gswifi.clearBuffer()
        resolve(nil)
    }
    
    @objc
    func printBarcode(_ x: NSNumber,
                      y: NSNumber,
                      type: String,
                      height: NSNumber,
                      humanReadable: NSNumber,
                      rotation: NSNumber,
                      narrow: NSNumber,
                      wide: NSNumber,
                      content: String,
                      resolve: @escaping RCTPromiseResolveBlock,
                      reject: @escaping RCTPromiseRejectBlock) {
        gswifi.printBarcode(x: x.intValue,
                          y: y.intValue,
                          type: type,
                          height: height.intValue,
                          readable: humanReadable.intValue,
                          rotation: rotation.intValue,
                          narrow: narrow.intValue,
                          wide: wide.intValue,
                          content: content) { msg in
            resolve(nil)
        }
    }
    
    @objc
    func printFont(_ x: NSNumber,
                   y: NSNumber,
                   fontName: String,
                   rotation: NSNumber,
                   xScale: NSNumber,
                   yScale: NSNumber,
                   content: String,
                   resolve: @escaping RCTPromiseResolveBlock,
                   reject: @escaping RCTPromiseRejectBlock) {
        gswifi.printFont(x: x.intValue,
                        y: y.intValue,
                        fontName: fontName,
                        rotation: rotation.intValue,
                        x_scale: xScale.intValue,
                        y_scale: yScale.intValue,
                        content: content) { msg in
            resolve(nil)
        }
    }
    
    @objc
    func printFontBlock(_ x: NSNumber,
                        y: NSNumber,
                        width: NSNumber,
                        height: NSNumber,
                        fontName: String,
                        rotation: NSNumber,
                        xScale: NSNumber,
                        yScale: NSNumber,
                        space: NSNumber,
                        align: NSNumber,
                        content: String,
                        resolve: @escaping RCTPromiseResolveBlock,
                        reject: @escaping RCTPromiseRejectBlock) {
        gswifi.printFontBlock(x: x.intValue,
                            y: y.intValue,
                            width: width.intValue,
                            height: height.intValue,
                            fontName: fontName,
                            rotation: rotation.intValue,
                            x_scale: xScale.intValue,
                            y_scale: yScale.intValue,
                            space: space.intValue,
                            align: align.intValue,
                            content: content) { msg in
            resolve(nil)
        }
    }
    
    @objc
    func printQRCode(_ x: NSNumber,
                     y: NSNumber,
                     eccLevel: String,
                     cellWidth: NSNumber,
                     rotation: NSNumber,
                     content: String,
                     resolve: @escaping RCTPromiseResolveBlock,
                     reject: @escaping RCTPromiseRejectBlock) {
        gswifi.printQRCode(x: x.intValue,
                          y: y.intValue,
                          eccLevel: eccLevel,
                          cellWidth: cellWidth.intValue,
                          rotation: rotation.intValue,
                          content: content) { msg in
            resolve(nil)
        }
    }
    
    @objc
    func printLabel(_ set: NSNumber,
                    copy: NSNumber,
                    resolve: @escaping RCTPromiseResolveBlock,
                    reject: @escaping RCTPromiseRejectBlock) {
        gswifi.printLabel(set: set.intValue, copy: copy.intValue)
        resolve(nil)
    }
    
    @objc
    func getPrinterStatus(_ resolve: @escaping RCTPromiseResolveBlock,
                         reject: @escaping RCTPromiseRejectBlock) {
        gswifi.printerStatus { status in
            resolve(status)
        }
    }
    
    @objc
    func sendCommand(_ command: String,
                     resolve: @escaping RCTPromiseResolveBlock,
                     reject: @escaping RCTPromiseRejectBlock) {
        if command.isEmpty {
            reject("invalid_command", "Command string cannot be empty", nil)
            return
        }
        
        gswifi.sendCommand(command)
        resolve(nil)
    }
    
    @objc
    func sendByteCmd(_ byteArray: [NSNumber],
                     resolve: @escaping RCTPromiseResolveBlock,
                     reject: @escaping RCTPromiseRejectBlock) {
        if byteArray.isEmpty {
            reject("invalid_data", "Byte array cannot be empty", nil)
            return
        }
        
        let data = byteArray.map { $0.uint8Value }
        gswifi.sendByteCmd(cmdData: Data(data))
        resolve(nil)
    }
} 