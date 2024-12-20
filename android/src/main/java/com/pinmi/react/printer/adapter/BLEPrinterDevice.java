package com.pinmi.react.printer.adapter;

import android.bluetooth.BluetoothDevice;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;

/**
 * Created by xiesubin on 2017/9/21.
 */

public class BLEPrinterDevice implements PrinterDevice {
    private BluetoothDevice mBluetoothDevice;
    private BLEPrinterDeviceId mPrinterDeviceId;

    public BLEPrinterDevice(BluetoothDevice bluetoothDevice) {
        this.mBluetoothDevice = bluetoothDevice;
        this.mPrinterDeviceId = BLEPrinterDeviceId.valueOf(bluetoothDevice.getAddress());
    }

    @Override
    public PrinterDeviceId getPrinterDeviceId() {
        return this.mPrinterDeviceId;
    }

    @Override
    public WritableMap toRNWritableMap() {
        WritableMap deviceMap = Arguments.createMap();
        deviceMap.putString("inner_mac_address", this.mPrinterDeviceId.getInnerMacAddress());
        
        // Safely get device name with null check
        String deviceName = null;
        try {
            deviceName = this.mBluetoothDevice.getName();
        } catch (SecurityException e) {
            deviceName = "Unknown Device";
        }
        deviceMap.putString("device_name", deviceName != null ? deviceName : "Unknown Device");
        
        return deviceMap;
    }
}
