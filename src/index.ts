import { NativeModules, NativeEventEmitter, Platform } from "react-native";

import * as EPToolkit from "./utils/EPToolkit";
import { processColumnText } from './utils/print-column';
import { COMMANDS } from './utils/printer-commands';
import { connectToHost } from './utils/net-connect';

const RNUSBPrinter = NativeModules.RNUSBPrinter;
const RNBLEPrinter = NativeModules.RNBLEPrinter;
const RNNetPrinter = NativeModules.RNNetPrinter;
const RNNetLabelPrinter = NativeModules.RNNetLabelPrinter;

export interface PrinterOptions {
  beep?: boolean;
  cut?: boolean;
  tailingLine?: boolean;
  encoding?: string;
}

export enum PrinterWidth {
  "58mm" = 58,
  "80mm" = 80,
}

export interface PrinterImageOptions {
  beep?: boolean;
  cut?: boolean;
  tailingLine?: boolean;
  encoding?: string;
  imageWidth?: number;
  imageHeight?: number;
  printerWidthType?: PrinterWidth;
  // only ios
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

export enum ColumnAlignment {
  LEFT,
  CENTER,
  RIGHT,
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

const textTo64Buffer = (text: string, opts: PrinterOptions) => {
  const defaultOptions = {
    beep: false,
    cut: false,
    tailingLine: false,
    encoding: "UTF8",
  };

  const options = {
    ...defaultOptions,
    ...opts,
  };

  const fixAndroid = '\n'
  const buffer = EPToolkit.exchange_text(text + fixAndroid, options);
  return buffer.toString("base64");
};

const billTo64Buffer = (text: string, opts: PrinterOptions) => {
  const defaultOptions = {
    beep: true,
    cut: true,
    encoding: "UTF8",
    tailingLine: true,
  };
  const options = {
    ...defaultOptions,
    ...opts,
  };
  const buffer = EPToolkit.exchange_text(text, options);
  return buffer.toString("base64");
};

const textPreprocessingIOS = (text: string, canCut = true, beep = true, encoding = '', tailingLine = true) => {
  let options = {
    beep: beep,
    cut: canCut,
    encoding: encoding ? encoding : '',
    tailingLine: tailingLine ? tailingLine : true,
  };
  if (encoding) {
    return {
      text: EPToolkit.exchange_text_ios(
        text
          .replace(/<\/?CB>/g, "")
          .replace(/<\/?CM>/g, "")
          .replace(/<\/?CD>/g, "")
          .replace(/<\/?C>/g, "")
          .replace(/<\/?D>/g, "")
          .replace(/<\/?B>/g, "")
          .replace(/<\/?M>/g, ""),
        {
          ...options,
          encoding: encoding,
          tailingLine: tailingLine,
        }
      ),
      opts: options,
    };
  }
  else {
    return {
      text: text
        .replace(/<\/?CB>/g, "")
        .replace(/<\/?CM>/g, "")
        .replace(/<\/?CD>/g, "")
        .replace(/<\/?C>/g, "")
        .replace(/<\/?D>/g, "")
        .replace(/<\/?B>/g, "")
        .replace(/<\/?M>/g, ""),
      opts: options,
    };
  }
};

// const imageToBuffer = async (imagePath: string, threshold: number = 60) => {
//   const buffer = await EPToolkit.exchange_image(imagePath, threshold);
//   return buffer.toString("base64");
// };

const USBPrinter = {
  init: (): Promise<void> =>
    new Promise((resolve, reject) =>
      RNUSBPrinter.init(
        () => resolve(),
        (error: Error) => reject(error)
      )
    ),

  getDeviceList: (): Promise<IUSBPrinter[]> =>
    new Promise((resolve, reject) =>
      RNUSBPrinter.getDeviceList(
        (printers: IUSBPrinter[]) => resolve(printers),
        (error: Error) => reject(error)
      )
    ),

  connectPrinter: (vendorId: string, productId: string): Promise<IUSBPrinter> =>
    new Promise((resolve, reject) =>
      RNUSBPrinter.connectPrinter(
        vendorId,
        productId,
        (printer: IUSBPrinter) => resolve(printer),
        (error: Error) => reject(error)
      )
    ),

  closeConn: (): Promise<void> =>
    new Promise((resolve) => {
      RNUSBPrinter.closeConn();
      resolve();
    }),

  printText: (text: string, opts: PrinterOptions = {}): void =>
    RNUSBPrinter.printRawData(textTo64Buffer(text, opts), (error: Error) =>
      console.warn(error)
    ),

  printBill: (text: string, opts: PrinterOptions = {}): void =>
    RNUSBPrinter.printRawData(billTo64Buffer(text, opts), (error: Error) =>
      console.warn(error)
    ),
  /**
   * image url
   * @param imgUrl
   * @param opts
   */
  printImage: function (imgUrl: string, opts: PrinterImageOptions = {}) {
    if (Platform.OS === "ios") {
      RNUSBPrinter.printImageData(imgUrl, opts, (error: Error) =>
        console.warn(error)
      );
    } else {
      RNUSBPrinter.printImageData(
        imgUrl,
        opts?.imageWidth ?? 0,
        opts?.imageHeight ?? 0,
        (error: Error) => console.warn(error)
      );
    }
  },
  /**
   * base 64 string
   * @param Base64
   * @param opts
   */
  printImageBase64: function (Base64: string, opts: PrinterImageOptions = {}) {
    if (Platform.OS === "ios") {
      RNUSBPrinter.printImageBase64(Base64, opts, (error: Error) =>
        console.warn(error)
      );
    } else {
      RNUSBPrinter.printImageBase64(
        Base64,
        opts?.imageWidth ?? 0,
        opts?.imageHeight ?? 0,
        (error: Error) => console.warn(error)
      );
    }
  },
  /**
   * android print with encoder
   * @param text
   */
  printRaw: (text: string): void => {
    if (Platform.OS === "ios") {
    } else {
      RNUSBPrinter.printRawData(text, (error: Error) => console.warn(error));
    }
  },
  /**
   * `columnWidth`
   * 80mm => 46 character
   * 58mm => 30 character
   */
  printColumnsText: (texts: string[], columnWidth: number[], columnAlignment: (ColumnAlignment)[], columnStyle: string[], opts: PrinterOptions = {}): void => {
    const result = processColumnText(texts, columnWidth, columnAlignment, columnStyle)
    RNUSBPrinter.printRawData(textTo64Buffer(result, opts), (error: Error) =>
      console.warn(error)
    );
  },
};

const BLEPrinter = {
  init: (): Promise<void> =>
    new Promise((resolve, reject) =>
      RNBLEPrinter.init(
        () => resolve(),
        (error: Error) => reject(error)
      )
    ),

  getDeviceList: (): Promise<IBLEPrinter[]> =>
    new Promise((resolve, reject) =>
      RNBLEPrinter.getDeviceList(
        (printers: IBLEPrinter[]) => resolve(printers),
        (error: Error) => reject(error)
      )
    ),

  connectPrinter: (inner_mac_address: string): Promise<IBLEPrinter> =>
    new Promise((resolve, reject) =>
      RNBLEPrinter.connectPrinter(
        inner_mac_address,
        (printer: IBLEPrinter) => resolve(printer),
        (error: Error) => reject(error)
      )
    ),

  closeConn: (): Promise<void> =>
    new Promise((resolve) => {
      RNBLEPrinter.closeConn();
      resolve();
    }),

  printText: (text: string, opts: PrinterOptions = {}): void => {
    if (Platform.OS === "ios") {
      const processedText = textPreprocessingIOS(text, false, false);
      RNBLEPrinter.printRawData(
        processedText.text,
        processedText.opts,
        (error: Error) => console.warn(error)
      );
    } else {
      RNBLEPrinter.printRawData(textTo64Buffer(text, opts), (error: Error) =>
        console.warn(error)
      );
    }
  },

  printBill: (text: string, opts: PrinterOptions = {}): void => {
    if (Platform.OS === "ios") {
      const processedText = textPreprocessingIOS(text, opts?.cut ?? true, opts.beep ?? true);
      RNBLEPrinter.printRawData(
        processedText.text,
        processedText.opts,
        (error: Error) => console.warn(error)
      );
    } else {
      RNBLEPrinter.printRawData(billTo64Buffer(text, opts), (error: Error) =>
        console.warn(error)
      );
    }
  },
  /**
   * image url
   * @param imgUrl
   * @param opts
   */
  printImage: function (imgUrl: string, opts: PrinterImageOptions = {}) {
    if (Platform.OS === "ios") {
      /**
       * just development
       */
      RNBLEPrinter.printImageData(imgUrl, opts, (error: Error) => console.warn(error));
    } else {
      RNBLEPrinter.printImageData(
        imgUrl,
        opts?.imageWidth ?? 0,
        opts?.imageHeight ?? 0,
        (error: Error) => console.warn(error)
      );
    }
  },
  /**
   * base 64 string
   * @param Base64
   * @param opts
   */
  printImageBase64: function (Base64: string, opts: PrinterImageOptions = {}) {
    if (Platform.OS === "ios") {
      /**
       * just development
       */
      RNBLEPrinter.printImageBase64(Base64, opts, (error: Error) => console.warn(error));
    } else {
      /**
       * just development
       */
      RNBLEPrinter.printImageBase64(
        Base64,
        opts?.imageWidth ?? 0,
        opts?.imageHeight ?? 0,
        (error: Error) => console.warn(error)
      );
    }
  },
  /**
   * android print with encoder
   * @param text
   */
  printRaw: (text: string): void => {
    if (Platform.OS === "ios") {
      var processedText = textPreprocessingIOS(text, false, false);

      RNBLEPrinter.printRawData(
        processedText.text,
        processedText.opts,
        function (error: Error) {
          return console.warn(error);
        }
      );
    } else {
      RNBLEPrinter.printRawData(text, (error: Error) =>
        console.warn(error)
      );
    }
  },
  /**
   * `columnWidth`
   * 80mm => 46 character
   * 58mm => 30 character
   */
  printColumnsText: (texts: string[], columnWidth: number[], columnAlignment: (ColumnAlignment)[], columnStyle: string[], opts: PrinterOptions = {}): void => {
    const result = processColumnText(texts, columnWidth, columnAlignment, columnStyle)
    if (Platform.OS === "ios") {
      const processedText = textPreprocessingIOS(result, false, false);
      RNBLEPrinter.printRawData(
        processedText.text,
        processedText.opts,
        (error: Error) => console.warn(error)
      );
    } else {
      RNBLEPrinter.printRawData(textTo64Buffer(result, opts), (error: Error) =>
        console.warn(error)
      );
    }
  },
};

const NetPrinter = {
  init: (): Promise<void> =>
    new Promise((resolve, reject) =>
      RNNetPrinter.init(
        () => resolve(),
        (error: Error) => reject(error)
      )
    ),

  getDeviceList: (): Promise<INetPrinter[]> =>
    new Promise((resolve, reject) =>
      RNNetPrinter.getDeviceList(
        (printers: INetPrinter[]) => resolve(printers),
        (error: Error) => reject(error)
      )
    ),

  connectPrinter: (host: string, port: number, timeout?: number, skipPreConnect?: false): Promise<INetPrinter> =>
    new Promise(async (resolve, reject) => {
      try {
        if (skipPreConnect) {
          // do nothing here
        }
        else {
          await connectToHost(host, timeout);
        }

        RNNetPrinter.connectPrinter(
          host,
          port,
          (printer: INetPrinter) => resolve(printer),
          (error: Error) => reject(error)
        );
      } catch (error) {
        reject(error?.message || `Connect to ${host} fail`)
      }
    }
    ),

  connectPrinterAsync: (host: string, port: number, timeout?: number, skipPreConnect?: false): Promise<INetPrinter> =>
    new Promise(async (resolve, reject) => {
      try {
        if (skipPreConnect) {
          // do nothing here
        }
        else {
          await connectToHost(host, timeout);
        }

        RNNetPrinter.connectPrinterAsync(
          host,
          port,
          (printer: INetPrinter) => resolve(printer),
          (error: Error) => reject(error)
        );
      } catch (error) {
        reject(error?.message || `Connect to ${host} fail`)
      }
    }
    ),

  closeConn: (): Promise<void> =>
    new Promise((resolve) => {
      RNNetPrinter.closeConn();
      resolve();
    }),

  printText: (text: string, opts = { encoding: '', noHex: false }): void => {
    if (Platform.OS === "ios") {
      const processedText = textPreprocessingIOS(text, false, false, opts.encoding ? opts.encoding : '');

      if (processedText.opts.encoding) {
        // use custom code

        if (opts.noHex) {
          RNNetPrinter.printRawData(
            processedText.text,
            processedText.opts,
            (error: Error) => console.warn(error)
          );
        }
        else {
          RNNetPrinter.printHex(
            processedText.text,
            processedText.opts,
            (error: Error) => console.warn(error)
          );
        }
      }
      else {
        // use original code

        RNNetPrinter.printRawData(
          processedText.text,
          processedText.opts,
          (error: Error) => console.warn(error)
        );

        // if (opts.noHex) {
        //   RNNetPrinter.printRawData(
        //     processedText.text,
        //     processedText.opts,
        //     (error: Error) => console.warn(error)
        //   );
        // }
        // else {
        //   RNNetPrinter.printHex(
        //     processedText.text,
        //     processedText.opts,
        //     (error: Error) => console.warn(error)
        //   );
        // }
      }
    } else {
      RNNetPrinter.printRawData(textTo64Buffer(text, opts), (error: Error) =>
        console.warn(error)
      );
    }
  },

  printTextAsync: (text: string, opts = { encoding: '', noHex: false }): void => {
    if (Platform.OS === "ios") {
      const processedText = textPreprocessingIOS(text, false, false, opts.encoding ? opts.encoding : '');

      if (processedText.opts.encoding) {
        // use custom code

        if (opts.noHex) {
          RNNetPrinter.printRawDataAsync(
            processedText.text,
            processedText.opts,
            (error: Error) => console.warn(error)
          );
        }
        else {
          RNNetPrinter.printHexAsync(
            processedText.text,
            processedText.opts,
            (error: Error) => console.warn(error)
          );
        }
      }
      else {
        // use original code

        RNNetPrinter.printRawDataAsync(
          processedText.text,
          processedText.opts,
          (error: Error) => console.warn(error)
        );

        // if (opts.noHex) {
        //   RNNetPrinter.printRawData(
        //     processedText.text,
        //     processedText.opts,
        //     (error: Error) => console.warn(error)
        //   );
        // }
        // else {
        //   RNNetPrinter.printHex(
        //     processedText.text,
        //     processedText.opts,
        //     (error: Error) => console.warn(error)
        //   );
        // }
      }
    } else {
      RNNetPrinter.printRawDataAsync(textTo64Buffer(text, opts), (error: Error) =>
        console.warn(error)
      );
    }
  },

  printBill: (text: string, opts: PrinterOptions = {}): void => {
    if (Platform.OS === "ios") {
      const processedText = textPreprocessingIOS(text, opts?.cut ?? true, opts.beep ?? true);
      RNNetPrinter.printRawData(
        processedText.text,
        processedText.opts,
        (error: Error) => console.warn(error)
      );
    } else {
      RNNetPrinter.printRawData(billTo64Buffer(text, opts), (error: Error) =>
        console.warn(error)
      );
    }
  },
  /**
   * image url
   * @param imgUrl
   * @param opts
   */
  printImage: function (imgUrl: string, opts: PrinterImageOptions = {}) {
    if (Platform.OS === "ios") {
      RNNetPrinter.printImageData(imgUrl, opts, (error: Error) => console.warn(error));
    } else {
      RNNetPrinter.printImageData(
        imgUrl,
        opts?.imageWidth ?? 0,
        opts?.imageHeight ?? 0,
        (error: Error) => console.warn(error)
      );
    }
  },
  /**
   * base 64 string
   * @param Base64
   * @param opts
   */
  printImageBase64: function (Base64: string, opts: PrinterImageOptions = {}) {
    if (Platform.OS === "ios") {
      RNNetPrinter.printImageBase64(Base64, opts, (error: Error) => console.warn(error));
    } else {
      RNNetPrinter.printImageBase64(
        Base64,
        opts?.imageWidth ?? 0,
        opts?.imageHeight ?? 0,
        (error: Error) => console.warn(error)
      );
    }
  },

  /**
   * Android print with encoder
   * @param text
   */
  printRaw: (text: string): void => {
    if (Platform.OS === "ios") {
    } else {
      RNNetPrinter.printRawData(text, (error: Error) =>
        console.warn(error)
      );
    }
  },

  /**
   * `columnWidth`
   * 80mm => 46 character
   * 58mm => 30 character
   */
  printColumnsText: (texts: string[], columnWidth: number[], columnAlignment: (ColumnAlignment)[], columnStyle: string[] = [], opts: PrinterOptions = {}): void => {
    const result = processColumnText(texts, columnWidth, columnAlignment, columnStyle)
    if (Platform.OS === "ios") {
      const processedText = textPreprocessingIOS(result, false, false);
      RNNetPrinter.printRawData(
        processedText.text,
        processedText.opts,
        (error: Error) => console.warn(error)
      );
    } else {
      RNNetPrinter.printRawData(textTo64Buffer(result, opts), (error: Error) =>
        console.warn(error)
      );
    }
  },
};

const NetLabelPrinter = {
  init: (): Promise<void> =>
    new Promise((resolve, reject) =>
      RNNetLabelPrinter.initialize(
        () => resolve(),
        (error: Error) => reject(error)
      )
    ),

  connectPrinter: (host: string, port: number): Promise<INetLabelPrinter> =>
    new Promise((resolve, reject) =>
      RNNetLabelPrinter.openPort(
        host,
        port,
        (printer: INetLabelPrinter) => resolve(printer),
        (error: Error) => reject(error)
      )
    ),

  closeConn: (): Promise<void> =>
    new Promise((resolve) => {
      RNNetLabelPrinter.closePort();
      resolve();
    }),

  setup: (options: LabelPrinterOptions = {}): Promise<void> =>
    new Promise((resolve, reject) =>
      RNNetLabelPrinter.setup(
        options.width ?? 105,
        options.height ?? 80,
        options.speed ?? 4,
        options.density ?? 6,
        options.sensor ?? 0,
        options.sensorDistance ?? 3,
        options.sensorOffset ?? 3,
        () => resolve(),
        (error: Error) => reject(error)
      )
    ),

  clearBuffer: (): Promise<void> =>
    new Promise((resolve, reject) =>
      RNNetLabelPrinter.clearBuffer(
        () => resolve(),
        (error: Error) => reject(error)
      )
    ),

  printBarcode: (options: LabelBarcodeOptions): Promise<void> =>
    new Promise((resolve, reject) =>
      RNNetLabelPrinter.printBarcode(
        options.x,
        options.y,
        options.type,
        options.height,
        options.humanReadable,
        options.rotation,
        options.narrow,
        options.wide,
        options.content,
        () => resolve(),
        (error: Error) => reject(error)
      )
    ),

  printFont: (options: LabelFontOptions): Promise<void> =>
    new Promise((resolve, reject) =>
      RNNetLabelPrinter.printFont(
        options.x,
        options.y,
        options.fontName,
        options.rotation,
        options.xScale,
        options.yScale,
        options.content,
        () => resolve(),
        (error: Error) => reject(error)
      )
    ),

  printFontBlock: (options: LabelFontBlockOptions): Promise<void> =>
    new Promise((resolve, reject) =>
      RNNetLabelPrinter.printFontBlock(
        options.x,
        options.y,
        options.width,
        options.height,
        options.fontName,
        options.rotation,
        options.xScale,
        options.yScale,
        options.space,
        options.align,
        options.content,
        () => resolve(),
        (error: Error) => reject(error)
      )
    ),

  printQRCode: (options: LabelQRCodeOptions): Promise<void> =>
    new Promise((resolve, reject) =>
      RNNetLabelPrinter.printQRCode(
        options.x,
        options.y,
        options.eccLevel,
        options.cellWidth,
        options.rotation,
        options.content,
        () => resolve(),
        (error: Error) => reject(error)
      )
    ),

  printLabel: (set: number = 1, copy: number = 1): Promise<void> =>
    new Promise((resolve, reject) =>
      RNNetLabelPrinter.printLabel(
        set,
        copy,
        () => resolve(),
        (error: Error) => reject(error)
      )
    ),

  getPrinterStatus: (): Promise<string> =>
    new Promise((resolve, reject) =>
      RNNetLabelPrinter.getPrinterStatus(
        (status: string) => resolve(status),
        (error: Error) => reject(error)
      )
    ),

  // New methods
  sendCommand: (command: string): Promise<void> =>
    new Promise((resolve, reject) =>
      RNNetLabelPrinter.sendCommand(
        command,
        () => resolve(),
        (error: Error) => reject(error)
      )
    ),

  sendByteCmd: (byteArray: number[]): Promise<void> =>
    new Promise((resolve, reject) =>
      RNNetLabelPrinter.sendByteCmd(
        byteArray,
        () => resolve(),
        (error: Error) => reject(error)
      )
    ),
};

const NetPrinterEventEmitter = new NativeEventEmitter(RNNetPrinter);
const NetLabelPrinterEventEmitter = new NativeEventEmitter(RNNetLabelPrinter);

export {
  COMMANDS,
  NetPrinter,
  BLEPrinter,
  USBPrinter,
  NetLabelPrinter,
  NetPrinterEventEmitter,
  NetLabelPrinterEventEmitter
};

export enum RN_THERMAL_RECEIPT_PRINTER_EVENTS {
  EVENT_NET_PRINTER_SCANNED_SUCCESS = "scannerResolved",
  EVENT_NET_PRINTER_SCANNING = "scannerRunning",
  EVENT_NET_PRINTER_SCANNED_ERROR = "registerError",
}
