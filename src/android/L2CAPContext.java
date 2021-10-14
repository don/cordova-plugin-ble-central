package com.megster.cordova.ble.central;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.os.Build;
import androidx.annotation.RequiresApi;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.LOG;
import org.apache.cordova.PluginResult;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

class L2CAPContext {
    private static final String TAG = "L2CAPContext";

    private final Object updateLock = new Object();
    private final int psm;
    private final BluetoothDevice device;
    private final ExecutorService executor;

    private BluetoothSocket socket;
    private CallbackContext l2capReceiver;
    private CallbackContext l2capConnectContext;

    public L2CAPContext(BluetoothDevice device, int psm) {
        this.psm = psm;
        this.device = device;
        this.executor = Executors.newSingleThreadExecutor();
    }

    public void connectL2cap(CallbackContext callbackContext, boolean secureChannel) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                disconnectL2Cap();
                socket = secureChannel ? device.createL2capChannel(psm) : device.createInsecureL2capChannel(psm);
                socket.connect();
                executor.submit(this::readL2CapData);

                PluginResult result = new PluginResult(PluginResult.Status.OK);
                result.setKeepCallback(true);
                callbackContext.sendPluginResult(result);
                synchronized (updateLock) {
                    l2capConnectContext = callbackContext;
                }
            } else {
                callbackContext.error("L2CAP not supported by platform");
            }
        } catch (Exception e) {
            LOG.e(TAG, "connect L2Cap failed", e);
            callbackContext.error("Failed to open L2Cap connection");
        }
    }

    public void disconnectL2Cap() {
        disconnectL2Cap("L2CAP disconnected");
    }

    public boolean isConnected() {
        return socket != null && socket.isConnected();
    }

    private void disconnectL2Cap(String message) {
        try {
            if (socket != null) {
                socket.close();
                socket = null;
            }
        } catch (Exception e) {
            LOG.e(TAG, "disconnect L2Cap failed", e);
        }
        CallbackContext callback;
        synchronized (updateLock) {
            callback = l2capConnectContext;
            l2capConnectContext = null;
        }
        if (callback != null) {
            callback.error(message);
        }
    }

    public void registerL2CapReceiver(CallbackContext callbackContext) {
        synchronized (updateLock) {
            l2capReceiver = callbackContext;
        }
    }

    public void writeL2CapChannel(CallbackContext callbackContext, byte[] data) {
        if (socket == null || !socket.isConnected()) {
            callbackContext.error("L2CAP PSM " + psm + " not connected.");
            return;
        }

        try {
            OutputStream outputStream = socket.getOutputStream();
            outputStream.write(data);
            callbackContext.success();
        } catch (IOException e) {
            LOG.e(TAG, "L2Cap write failed", e);
            disconnectL2Cap("L2Cap write pipe broken");
            callbackContext.error("L2CAP write failed");
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    private void readL2CapData() {
        try {
            InputStream inputStream = socket.getInputStream();
            byte[] buffer = new byte[socket.getMaxReceivePacketSize()];
            while (socket.isConnected()) {
                int readCount = inputStream.read(buffer);
                CallbackContext receiver;
                synchronized (updateLock) {
                    receiver = l2capReceiver;
                }
                if (readCount >= 0 && receiver != null) {
                    PluginResult result = new PluginResult(PluginResult.Status.OK, Arrays.copyOf(buffer, readCount));
                    result.setKeepCallback(true);
                    receiver.sendPluginResult(result);
                }
            }
            disconnectL2Cap("L2Cap channel disconnected");

        } catch (Exception e) {
            LOG.e(TAG, "reading L2Cap data failed", e);
            disconnectL2Cap("L2Cap read pipe broken");
        }
    }
}
