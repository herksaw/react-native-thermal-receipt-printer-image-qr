package com.pinmi.react.printer;

import android.bluetooth.BluetoothAdapter;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.pinmi.react.printer.adapter.BLEPrinterAdapter;
import com.pinmi.react.printer.adapter.BLEPrinterDeviceId;
import com.pinmi.react.printer.adapter.PrinterAdapter;
import com.pinmi.react.printer.adapter.PrinterDevice;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by xiesubin on 2017/9/22.
 */

public class RNBLEPrinterModule extends ReactContextBaseJavaModule implements RNPrinterModule {

    protected ReactApplicationContext reactContext;

    protected PrinterAdapter adapter;

    public RNBLEPrinterModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @ReactMethod
    @Override
    public void init(Callback successCallback, Callback errorCallback) {
        this.adapter = BLEPrinterAdapter.getInstance();
        this.adapter.init(reactContext,  successCallback, errorCallback);
    }

    @ReactMethod
    @Override
    public void closeConn()  {
        adapter.closeConnectionIfExists();
    }

    @ReactMethod
    @Override
    public void getDeviceList(Callback successCallback, Callback errorCallback)  {
        List<PrinterDevice> printerDevices = adapter.getDeviceList(errorCallback);
        WritableArray pairedDeviceList = Arguments.createArray();

        // Check bluetooth state first
        BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if(bluetoothAdapter == null) {
            errorCallback.invoke("No bluetooth adapter available");
            return;
        }
        if (!bluetoothAdapter.isEnabled()) {
            errorCallback.invoke("Bluetooth is not enabled");
            return;
        }

        // Check permission
        // 2025-01-02 - hide first
        // if (reactContext.checkSelfPermission(android.Manifest.permission.BLUETOOTH) != PackageManager.PERMISSION_GRANTED) {
        //     errorCallback.invoke("Bluetooth permission is not granted");
        //     return;
        // }

        if(printerDevices.size() > 0) {
            for (PrinterDevice printerDevice : printerDevices) {
                pairedDeviceList.pushMap(printerDevice.toRNWritableMap());
            }
            successCallback.invoke(pairedDeviceList);
        } else {
            errorCallback.invoke("No Device Found");
        }
    }

    @ReactMethod
    @Override
    public void printRawData(String base64Data, Callback errorCallback){
        adapter.printRawData(base64Data, errorCallback);
    }

    @ReactMethod
    @Override
    public void printRawDataAsync(String base64Data, Callback errorCallback){
        adapter.printRawDataAsync(base64Data, errorCallback);
    }

    @ReactMethod
    @Override
    public void printImageData(String imageUrl, int imageWidth, int imageHeight, Callback errorCallback) {
        Log.v("imageUrl", imageUrl);
        adapter.printImageData(imageUrl, imageWidth, imageHeight,errorCallback);
    }

    @ReactMethod
    @Override
    public void printImageBase64(String base64, int imageWidth, int imageHeight, Callback errorCallback) {
        byte[] decodedString = Base64.decode(base64, Base64.DEFAULT);
        Bitmap decodedByte = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
        adapter.printImageBase64(decodedByte, imageWidth, imageHeight,errorCallback);
    }

    @ReactMethod
    public void connectPrinter(String innerAddress, Callback successCallback, Callback errorCallback) {
        adapter.selectDevice(BLEPrinterDeviceId.valueOf(innerAddress), successCallback, errorCallback);
    }

    @Override
    public String getName() {
        return "RNBLEPrinter";
    }
}
