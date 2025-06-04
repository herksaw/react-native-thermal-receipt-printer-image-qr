import { NativeEventEmitter } from "react-native";
import { COMMANDS } from './utils/printer-commands';
export interface PrinterOptions {
    beep?: boolean;
    cut?: boolean;
    tailingLine?: boolean;
    encoding?: string;
}
export declare enum PrinterWidth {
    "58mm" = 58,
    "80mm" = 80
}
export interface PrinterImageOptions {
    beep?: boolean;
    cut?: boolean;
    tailingLine?: boolean;
    encoding?: string;
    imageWidth?: number;
    imageHeight?: number;
    printerWidthType?: PrinterWidth;
    paddingX?: number;
}
export interface IUSBPrinter {
    device_name: string;
    vendor_id: string;
    product_id: string;
}
export interface IBLEPrinter {
    device_name: string;
    inner_mac_address: string;
}
export interface INetPrinter {
    host: string;
    port: number;
}
export interface INetLabelPrinter {
    host: string;
    port: number;
}
export declare enum ColumnAlignment {
    LEFT = 0,
    CENTER = 1,
    RIGHT = 2
}
export interface LabelPrinterOptions {
    width?: number;
    height?: number;
    speed?: number;
    density?: number;
    sensor?: number;
    sensorDistance?: number;
    sensorOffset?: number;
}
export interface LabelBarcodeOptions {
    x: number;
    y: number;
    type: string;
    height: number;
    humanReadable: number;
    rotation: number;
    narrow: number;
    wide: number;
    content: string;
}
export interface LabelFontOptions {
    x: number;
    y: number;
    fontName: string;
    rotation: number;
    xScale: number;
    yScale: number;
    content: string;
}
export interface LabelFontBlockOptions {
    x: number;
    y: number;
    width: number;
    height: number;
    fontName: string;
    rotation: number;
    xScale: number;
    yScale: number;
    space: number;
    align: number;
    content: string;
}
export interface LabelQRCodeOptions {
    x: number;
    y: number;
    eccLevel: string;
    cellWidth: number;
    rotation: number;
    content: string;
}
declare const USBPrinter: {
    init: () => Promise<void>;
    getDeviceList: () => Promise<IUSBPrinter[]>;
    connectPrinter: (vendorId: string, productId: string) => Promise<IUSBPrinter>;
    closeConn: () => Promise<void>;
    printText: (text: string, opts?: PrinterOptions) => void;
    printBill: (text: string, opts?: PrinterOptions) => void;
    /**
     * image url
     * @param imgUrl
     * @param opts
     */
    printImage: (imgUrl: string, opts?: PrinterImageOptions) => void;
    /**
     * base 64 string
     * @param Base64
     * @param opts
     */
    printImageBase64: (Base64: string, opts?: PrinterImageOptions) => void;
    /**
     * android print with encoder
     * @param text
     */
    printRaw: (text: string) => void;
    /**
     * `columnWidth`
     * 80mm => 46 character
     * 58mm => 30 character
     */
    printColumnsText: (texts: string[], columnWidth: number[], columnAlignment: (ColumnAlignment)[], columnStyle: string[], opts?: PrinterOptions) => void;
};
declare const BLEPrinter: {
    init: () => Promise<void>;
    getDeviceList: () => Promise<IBLEPrinter[]>;
    connectPrinter: (inner_mac_address: string) => Promise<IBLEPrinter>;
    closeConn: () => Promise<void>;
    printText: (text: string, opts?: PrinterOptions) => void;
    printBill: (text: string, opts?: PrinterOptions) => void;
    /**
     * image url
     * @param imgUrl
     * @param opts
     */
    printImage: (imgUrl: string, opts?: PrinterImageOptions) => void;
    /**
     * base 64 string
     * @param Base64
     * @param opts
     */
    printImageBase64: (Base64: string, opts?: PrinterImageOptions) => void;
    /**
     * android print with encoder
     * @param text
     */
    printRaw: (text: string) => void;
    /**
     * `columnWidth`
     * 80mm => 46 character
     * 58mm => 30 character
     */
    printColumnsText: (texts: string[], columnWidth: number[], columnAlignment: (ColumnAlignment)[], columnStyle: string[], opts?: PrinterOptions) => void;
};
declare const NetPrinter: {
    init: () => Promise<void>;
    getDeviceList: () => Promise<INetPrinter[]>;
    connectPrinter: (host: string, port: number, timeout?: number | undefined, skipPreConnect?: false | undefined) => Promise<INetPrinter>;
    connectPrinterAsync: (host: string, port: number, timeout?: number | undefined, skipPreConnect?: false | undefined) => Promise<INetPrinter>;
    closeConn: () => Promise<void>;
    printText: (text: string, opts?: {
        encoding: string;
        noHex: boolean;
    }) => void;
    printTextAsync: (text: string, opts?: {
        encoding: string;
        noHex: boolean;
    }) => void;
    printBill: (text: string, opts?: PrinterOptions) => void;
    /**
     * image url
     * @param imgUrl
     * @param opts
     */
    printImage: (imgUrl: string, opts?: PrinterImageOptions) => void;
    /**
     * base 64 string
     * @param Base64
     * @param opts
     */
    printImageBase64: (Base64: string, opts?: PrinterImageOptions) => void;
    /**
     * Android print with encoder
     * @param text
     */
    printRaw: (text: string) => void;
    /**
     * `columnWidth`
     * 80mm => 46 character
     * 58mm => 30 character
     */
    printColumnsText: (texts: string[], columnWidth: number[], columnAlignment: (ColumnAlignment)[], columnStyle?: string[], opts?: PrinterOptions) => void;
};
declare const NetLabelPrinter: {
    init: () => Promise<void>;
    connectPrinter: (host: string, port: number) => Promise<INetLabelPrinter>;
    closeConn: () => Promise<void>;
    setup: (options?: LabelPrinterOptions) => Promise<void>;
    clearBuffer: () => Promise<void>;
    printBarcode: (options: LabelBarcodeOptions) => Promise<void>;
    printFont: (options: LabelFontOptions) => Promise<void>;
    printFontBlock: (options: LabelFontBlockOptions) => Promise<void>;
    printQRCode: (options: LabelQRCodeOptions) => Promise<void>;
    printLabel: (set?: number, copy?: number) => Promise<void>;
    getPrinterStatus: () => Promise<string>;
};
declare const NetPrinterEventEmitter: NativeEventEmitter;
declare const NetLabelPrinterEventEmitter: NativeEventEmitter;
export { COMMANDS, NetPrinter, BLEPrinter, USBPrinter, NetLabelPrinter, NetPrinterEventEmitter, NetLabelPrinterEventEmitter };
export declare enum RN_THERMAL_RECEIPT_PRINTER_EVENTS {
    EVENT_NET_PRINTER_SCANNED_SUCCESS = "scannerResolved",
    EVENT_NET_PRINTER_SCANNING = "scannerRunning",
    EVENT_NET_PRINTER_SCANNED_ERROR = "registerError"
}
