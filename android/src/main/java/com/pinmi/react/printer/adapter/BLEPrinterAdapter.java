package com.pinmi.react.printer.adapter;

import static com.pinmi.react.printer.adapter.UtilsImage.getPixelsSlow;
import static com.pinmi.react.printer.adapter.UtilsImage.recollectSlice;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.util.Base64;
import android.util.Log;
import android.widget.Toast;
import android.content.pm.PackageManager;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.Socket;
import java.util.ArrayList;
import java.net.URL;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import android.graphics.BitmapFactory;

import android.os.Build;
import android.Manifest;

/**
 * Created by xiesubin on 2017/9/21.
 */

public class BLEPrinterAdapter implements PrinterAdapter{


    private static BLEPrinterAdapter mInstance;


    private final String LOG_TAG = "RNBLEPrinter";

    private BluetoothDevice mBluetoothDevice;
    private BluetoothSocket mBluetoothSocket;


    private ReactApplicationContext mContext;

    private final static char ESC_CHAR = 0x1B;
    private static final byte[] SELECT_BIT_IMAGE_MODE = { 0x1B, 0x2A, 33 };
    private final static byte[] SET_LINE_SPACE_24 = new byte[] { ESC_CHAR, 0x33, 24 };
    private final static byte[] SET_LINE_SPACE_32 = new byte[] { ESC_CHAR, 0x33, 32 };
    private final static byte[] LINE_FEED = new byte[] { 0x0A };
    private static final byte[] CENTER_ALIGN = { 0x1B, 0X61, 0X31 };



    private BLEPrinterAdapter(){}

    public static BLEPrinterAdapter getInstance() {
        if(mInstance == null) {
            mInstance = new BLEPrinterAdapter();
        }
        return mInstance;
    }

    @Override
    public void init(ReactApplicationContext reactContext, Callback successCallback, Callback errorCallback) {
        this.mContext = reactContext;
        BluetoothAdapter bluetoothAdapter = getBTAdapter();
        if(bluetoothAdapter == null) {
            errorCallback.invoke("No bluetooth adapter available");
            return;
        }
        if(!bluetoothAdapter.isEnabled()) {
            errorCallback.invoke("bluetooth adapter is not enabled");
            return;
        }else{
            successCallback.invoke();
        }

    }

    private static BluetoothAdapter getBTAdapter() {
        return BluetoothAdapter.getDefaultAdapter();
    }

    @Override
    public void getDeviceListCallback(Callback successCallback, Callback errorCallback) {
    }

    @Override
    public List<PrinterDevice> getDeviceList(Callback errorCallback) {
        BluetoothAdapter bluetoothAdapter = getBTAdapter();
        List<PrinterDevice> printerDevices = new ArrayList<>();
        if(bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
            errorCallback.invoke("adapater issue");
            return printerDevices;
        }
        
        // Check for Bluetooth permission
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            int connectPermission = mContext.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT);
            int scanPermission = mContext.checkSelfPermission(Manifest.permission.BLUETOOTH_SCAN);

            Log.d("PrinterDebug", "Android 12+:");
            Log.d("PrinterDebug", "BLUETOOTH_CONNECT permission: " + connectPermission);
            Log.d("PrinterDebug", "BLUETOOTH_SCAN permission: " + scanPermission);

            if (connectPermission != PackageManager.PERMISSION_GRANTED || scanPermission != PackageManager.PERMISSION_GRANTED) {
                errorCallback.invoke("Permission issue (Android 12+): CONNECT=" + connectPermission + ", SCAN=" + scanPermission);
                return printerDevices;
            }
        } else {
            int btPermission = mContext.checkSelfPermission(Manifest.permission.BLUETOOTH);
            int btAdminPermission = mContext.checkSelfPermission(Manifest.permission.BLUETOOTH_ADMIN);

            Log.d("PrinterDebug", "Pre-Android 12:");
            Log.d("PrinterDebug", "BLUETOOTH permission: " + btPermission);
            Log.d("PrinterDebug", "BLUETOOTH_ADMIN permission: " + btAdminPermission);

            if (btPermission != PackageManager.PERMISSION_GRANTED || btAdminPermission != PackageManager.PERMISSION_GRANTED) {
                errorCallback.invoke("Permission issue (Pre-Android 12): BLUETOOTH=" + btPermission + ", ADMIN=" + btAdminPermission);
                return printerDevices;
            }
        }

        Set<BluetoothDevice> pairedDevices = getBTAdapter().getBondedDevices();
        for (BluetoothDevice device : pairedDevices) {
            printerDevices.add(new BLEPrinterDevice(device));
        }
        return printerDevices;
    }

        @Override
    public void selectDevice(PrinterDeviceId printerDeviceId, Callback successCallback, Callback errorCallback) {
        BluetoothAdapter bluetoothAdapter = getBTAdapter();
        if(bluetoothAdapter == null) {
            errorCallback.invoke("No bluetooth adapter available");
            return;
        }
        if (!bluetoothAdapter.isEnabled()) {
            errorCallback.invoke("bluetooth is not enabled");
            return;
        }

        // Check for Bluetooth permission
        // 2025-01-02 - hide first
        // if (mContext.checkSelfPermission(android.Manifest.permission.BLUETOOTH) != PackageManager.PERMISSION_GRANTED) {
        //     errorCallback.invoke("Bluetooth permission is not granted");
        //     return;
        // }

        BLEPrinterDeviceId blePrinterDeviceId = (BLEPrinterDeviceId)printerDeviceId;
        if(this.mBluetoothDevice != null){
            if(this.mBluetoothDevice.getAddress().equals(blePrinterDeviceId.getInnerMacAddress()) && this.mBluetoothSocket != null){
                Log.v(LOG_TAG, "do not need to reconnect");
                successCallback.invoke(new BLEPrinterDevice(this.mBluetoothDevice).toRNWritableMap());
                return;
            }else{
                closeConnectionIfExists();
            }
        }
        Set<BluetoothDevice> pairedDevices = getBTAdapter().getBondedDevices();

        for (BluetoothDevice device : pairedDevices) {
            if(device.getAddress().equals(blePrinterDeviceId.getInnerMacAddress())){

                try{
                    connectBluetoothDevice(device, false);
                    successCallback.invoke(new BLEPrinterDevice(this.mBluetoothDevice).toRNWritableMap());
                    return;
                }catch (IOException e){
                    try {
                        connectBluetoothDevice(device, true);
                        successCallback.invoke(new BLEPrinterDevice(this.mBluetoothDevice).toRNWritableMap());
                        return;
                    } catch (IOException er) {
                        er.printStackTrace();
                        errorCallback.invoke(er.getMessage());
                        return;
                    }
                }
            }
        }
        String errorText = "Can not find the specified printing device, please perform Bluetooth pairing in the system settings first.";
        Toast.makeText(this.mContext, errorText, Toast.LENGTH_LONG).show();
        errorCallback.invoke(errorText);
        return;
    }

    private void connectBluetoothDevice(BluetoothDevice device, Boolean retry) throws IOException{
        // // Check for Bluetooth permission
        // if (mContext.checkSelfPermission(android.Manifest.permission.BLUETOOTH) != PackageManager.PERMISSION_GRANTED) {
        //     throw new IOException("Bluetooth permission is not granted");
        // }

        // UUID uuid = UUID.fromString("00001101-0000-1000-8000-00805f9b34fb");
        // this.mBluetoothSocket = device.createRfcommSocketToServiceRecord(uuid);
        // this.mBluetoothSocket.connect();
        // this.mBluetoothDevice = device;

        UUID uuid = UUID.fromString("00001101-0000-1000-8000-00805f9b34fb");

        if (retry) {
            try {
                this.mBluetoothSocket = (BluetoothSocket) device.getClass()
                        .getMethod("createRfcommSocket", new Class[] { int.class }).invoke(device, 1);
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            this.mBluetoothSocket = device.createInsecureRfcommSocketToServiceRecord(uuid);
            this.mBluetoothSocket.connect();
        }

        this.mBluetoothDevice = device;// 最后一步执行
    }

    @Override
    public void closeConnectionIfExists() {
        try{
            if(this.mBluetoothSocket != null){
                this.mBluetoothSocket.close();
                this.mBluetoothSocket = null;
            }
        }catch(IOException e){
            e.printStackTrace();
        }

        if(this.mBluetoothDevice != null) {
            this.mBluetoothDevice = null;
        }
    }

    @Override
    public void printRawData(String rawBase64Data, Callback errorCallback) {
        if(this.mBluetoothSocket == null){
            errorCallback.invoke("bluetooth connection is not built, may be you forgot to connectPrinter");
            return;
        }
        final String rawData = rawBase64Data;
        final BluetoothSocket socket = this.mBluetoothSocket;
        Log.v(LOG_TAG, "start to print raw data " + rawBase64Data);
        byte [] bytes = Base64.decode(rawData, Base64.DEFAULT);
        try{
            OutputStream printerOutputStream = socket.getOutputStream();
            printerOutputStream.write(bytes, 0, bytes.length);
            printerOutputStream.flush();
        }catch (IOException e){
            Log.e(LOG_TAG, "failed to print data" + rawData);
            e.printStackTrace();
        }
    }

    @Override
    public void printRawDataAsync(String rawBase64Data, Callback errorCallback) {
        if(this.mBluetoothSocket == null){
            errorCallback.invoke("bluetooth connection is not built, may be you forgot to connectPrinter");
            return;
        }
        final String rawData = rawBase64Data;
        final BluetoothSocket socket = this.mBluetoothSocket;
        Log.v(LOG_TAG, "start to print raw data " + rawBase64Data);
        new Thread(new Runnable() {
            @Override
            public void run() {
                byte [] bytes = Base64.decode(rawData, Base64.DEFAULT);
                try{
                    OutputStream printerOutputStream = socket.getOutputStream();
                    printerOutputStream.write(bytes, 0, bytes.length);
                    printerOutputStream.flush();
                }catch (IOException e){
                    Log.e(LOG_TAG, "failed to print data" + rawData);
                    e.printStackTrace();
                }

            }
        }).start();
    }

    public static Bitmap getBitmapFromURL(String src) {
        try {
            URL url = new URL(src);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setDoInput(true);
            connection.connect();
            InputStream input = connection.getInputStream();
            Bitmap myBitmap = BitmapFactory.decodeStream(input);

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            myBitmap.compress(Bitmap.CompressFormat.PNG, 100, baos);

            return myBitmap;
        } catch (IOException e) {
            // Log exception
            return null;
        }
    }

    @Override
    public void printImageData(String imageUrl, int  imageWidth, int imageHeight, Callback errorCallback) {
        final Bitmap bitmapImage = getBitmapFromURL(imageUrl);

        if(bitmapImage == null) {
            errorCallback.invoke("image not found");
            return;
        }

        if (this.mBluetoothSocket == null) {
            errorCallback.invoke("bluetooth connection is not built, may be you forgot to connectPrinter");
            return;
        }

        final BluetoothSocket socket = this.mBluetoothSocket;

        try {
            int[][] pixels = getPixelsSlow(bitmapImage, imageWidth, imageHeight);

            OutputStream printerOutputStream = socket.getOutputStream();

            printerOutputStream.write(SET_LINE_SPACE_24);
            printerOutputStream.write(CENTER_ALIGN);

            for (int y = 0; y < pixels.length; y += 24) {
                // Like I said before, when done sending data,
                // the printer will resume to normal text printing
                printerOutputStream.write(SELECT_BIT_IMAGE_MODE);
                // Set nL and nH based on the width of the image
                printerOutputStream.write(new byte[]{(byte)(0x00ff & pixels[y].length)
                        , (byte)((0xff00 & pixels[y].length) >> 8)});
                for (int x = 0; x < pixels[y].length; x++) {
                    // for each stripe, recollect 3 bytes (3 bytes = 24 bits)
                    printerOutputStream.write(recollectSlice(y, x, pixels));
                }

                // Do a line feed, if not the printing will resume on the same line
                printerOutputStream.write(LINE_FEED);
            }
            printerOutputStream.write(SET_LINE_SPACE_32);
            printerOutputStream.write(LINE_FEED);

            printerOutputStream.flush();
        } catch (IOException e) {
            Log.e(LOG_TAG, "failed to print data");
            e.printStackTrace();
        }
    }

    @Override
    public void printImageBase64(final Bitmap bitmapImage, int imageWidth, int imageHeight,Callback errorCallback) {
        if(bitmapImage == null) {
            errorCallback.invoke("image not found");
            return;
        }

        if (this.mBluetoothSocket == null) {
            errorCallback.invoke("bluetooth connection is not built, may be you forgot to connectPrinter");
            return;
        }

        final BluetoothSocket socket = this.mBluetoothSocket;

        try {
            int[][] pixels = getPixelsSlow(bitmapImage, imageWidth, imageHeight);

            OutputStream printerOutputStream = socket.getOutputStream();

            printerOutputStream.write(SET_LINE_SPACE_24);
            printerOutputStream.write(CENTER_ALIGN);

            for (int y = 0; y < pixels.length; y += 24) {
                // Like I said before, when done sending data,
                // the printer will resume to normal text printing
                printerOutputStream.write(SELECT_BIT_IMAGE_MODE);
                // Set nL and nH based on the width of the image
                printerOutputStream.write(new byte[]{(byte)(0x00ff & pixels[y].length)
                        , (byte)((0xff00 & pixels[y].length) >> 8)});
                for (int x = 0; x < pixels[y].length; x++) {
                    // for each stripe, recollect 3 bytes (3 bytes = 24 bits)
                    printerOutputStream.write(recollectSlice(y, x, pixels));
                }

                // Do a line feed, if not the printing will resume on the same line
                printerOutputStream.write(LINE_FEED);
            }
            printerOutputStream.write(SET_LINE_SPACE_32);
            printerOutputStream.write(LINE_FEED);

            printerOutputStream.flush();
        } catch (IOException e) {
            Log.e(LOG_TAG, "failed to print data");
            e.printStackTrace();
        }
    }

    // private byte[] recollectSlice(int y, int x, int[][] img) {
    //     byte[] slices = new byte[] { 0, 0, 0 };
    //     for (int yy = y, i = 0; yy < y + 24 && i < 3; yy += 8, i++) {
    //         byte slice = 0;
    //         for (int b = 0; b < 8; b++) {
    //             int yyy = yy + b;
    //             if (yyy >= img.length) {
    //                 continue;
    //             }
    //             int col = img[yyy][x];
    //             boolean v = shouldPrintColor(col);
    //             slice |= (byte) ((v ? 1 : 0) << (7 - b));
    //         }
    //         slices[i] = slice;
    //     }
    //     return slices;
    // }

    // private boolean shouldPrintColor(int col) {
    //     final int threshold = 127;
    //     int a, r, g, b, luminance;
    //     a = (col >> 24) & 0xff;
    //     if (a != 0xff) {// Ignore transparencies
    //         return false;
    //     }
    //     r = (col >> 16) & 0xff;
    //     g = (col >> 8) & 0xff;
    //     b = col & 0xff;

    //     luminance = (int) (0.299 * r + 0.587 * g + 0.114 * b);

    //     return luminance < threshold;
    // }

    // public static Bitmap resizeTheImageForPrinting(Bitmap image) {
    //     // making logo size 150 or less pixels
    //     int width = image.getWidth();
    //     int height = image.getHeight();
    //     if (width > 200 || height > 200) {
    //         if (width > height) {
    //             float decreaseSizeBy = (200.0f / width);
    //             return getBitmapResized(image, decreaseSizeBy);
    //         } else {
    //             float decreaseSizeBy = (200.0f / height);
    //             return getBitmapResized(image, decreaseSizeBy);
    //         }
    //     }
    //     return image;
    // }

    // public static int getRGB(Bitmap bmpOriginal, int col, int row) {
    //     // get one pixel color
    //     int pixel = bmpOriginal.getPixel(col, row);
    //     // retrieve color of all channels
    //     int R = Color.red(pixel);
    //     int G = Color.green(pixel);
    //     int B = Color.blue(pixel);
    //     return Color.rgb(R, G, B);
    // }

    // public static Bitmap getBitmapResized(Bitmap image, float decreaseSizeBy) {
    //     Bitmap resized = Bitmap.createScaledBitmap(image, (int) (image.getWidth() * decreaseSizeBy),
    //             (int) (image.getHeight() * decreaseSizeBy), true);
    //     return resized;
    // }

    // public static int[][] getPixelsSlow(Bitmap image2) {

    //     Bitmap image = resizeTheImageForPrinting(image2);

    //     int width = image.getWidth();
    //     int height = image.getHeight();
    //     int[][] result = new int[height][width];
    //     for (int row = 0; row < height; row++) {
    //         for (int col = 0; col < width; col++) {
    //             result[row][col] = getRGB(image, col, row);
    //         }
    //     }
    //     return result;
    // }

    // @Override
    // public void printQrCode(String qrCode, Callback errorCallback) {

    // }
}
