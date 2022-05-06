/********************************************************************************************************
 * @file     BleScanner.java 
 *
 * @brief    for TLSR chips
 *
 * @author	 telink
 * @date     Sep. 30, 2010
 *
 * @par      Copyright (c) 2010, Telink Semiconductor (Shanghai) Co., Ltd.
 *           All rights reserved.
 *           
 *			 The information contained herein is confidential and proprietary property of Telink 
 * 		     Semiconductor (Shanghai) Co., Ltd. and is available under the terms 
 *			 of Commercial License Agreement between Telink Semiconductor (Shanghai) 
 *			 Co., Ltd. and the licensee in separate contract or the terms described here-in. 
 *           This heading MUST NOT be removed from this file.
 *
 * 			 Licensees are granted free, non-transferable use of the information in this 
 *			 file under Mutual Non-Disclosure Agreement. NO WARRENTY of ANY KIND is provided. 
 *           
 *******************************************************************************************************/
package com.telink.ble.mesh.core.ble;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.ParcelUuid;
import android.text.TextUtils;

import com.telink.ble.mesh.util.ContextUtil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import androidx.annotation.Nullable;

public class BleScanner {

    public static final int CODE_START_FAIL = 0x06;

    private ScannerType mScannerType;

    private BluetoothAdapter.LeScanCallback mLeScanCallback;

    private BluetoothLeScanner mLeScanner;

    private ScanCallback mScanCallback;

    private final Object SCANNING_STATE_LOCK = new Object();

    private boolean isScanning = false;

    private ScannerCallback mScannerCallback;

    private LeScanFilter mLeScanFilter;

    private LeScanSetting mLeScanSetting;

    private Handler mDelayHandler;

    private long mLastScanStartTime = 0;

    /**
     * check is any device found by scanning
     * if false && location not enable, show
     */
    private boolean anyDeviceFound = false;

    private BleScanner() {
    }

    public void setScannerCallback(ScannerCallback scannerCallback) {
        this.mScannerCallback = scannerCallback;
    }

    public BleScanner(ScannerType scannerType, HandlerThread handlerThread) {
        this.mDelayHandler = new Handler(handlerThread.getLooper());
        if (scannerType == null || !ContextUtil.versionAboveL()) {
            this.mScannerType = ScannerType.DEFAULT;
        } else {
            this.mScannerType = scannerType;
        }
        switch (mScannerType) {
            case DEFAULT:
                initDefaultScanner();
                break;

            case Lollipop:
                initLollipopScanner();
                break;
        }
    }

    public boolean isEnabled() {
        return BluetoothAdapter.getDefaultAdapter().isEnabled();
    }

    public void enableBluetooth() {
        BluetoothAdapter.getDefaultAdapter().enable();
    }

    private void initDefaultScanner() {
        mLeScanCallback = new BluetoothAdapter.LeScanCallback() {

            @Override
            public void onLeScan(BluetoothDevice device, int rssi, byte[] scanRecord) {
                anyDeviceFound = true;
                if (mLeScanFilter != null) {
                    final LeScanFilter filter = mLeScanFilter;
                    if (filter.macExclude != null && filter.macExclude.length != 0) {
                        for (String mac : filter.macExclude) {
                            if (mac.equalsIgnoreCase(device.getAddress())) {
                                return;
                            }
                        }
                    }

                    boolean isTarget = true;
                    if (filter.macInclude != null && filter.macInclude.length != 0) {
                        isTarget = false;
                        for (String mac : filter.macInclude) {
                            if (mac.equalsIgnoreCase(device.getAddress())) {
                                isTarget = true;
                                break;
                            }
                        }
                    }


                    if (isTarget && filter.nameInclude != null && filter.nameInclude.length != 0) {
                        isTarget = false;
                        final String deviceName = device.getName();
                        if (!TextUtils.isEmpty(device.getName())) {
                            for (String name : filter.nameInclude) {
                                if (deviceName.equals(name)) {
                                    isTarget = true;
                                    break;
                                }
                            }
                        }
                    }

                    if (isTarget) {
                        onDeviceScanned(device, rssi, scanRecord);
                    }
                } else {
                    onDeviceScanned(device, rssi, scanRecord);
                }
            }
        };
    }

    private void initLollipopScanner() {
        mLeScanner = BluetoothAdapter.getDefaultAdapter().getBluetoothLeScanner();
        mScanCallback = new ScanCallback() {
            @Override
            public void onScanResult(int callbackType, ScanResult result) {
                super.onScanResult(callbackType, result);
                anyDeviceFound = true;
                BluetoothDevice device = result.getDevice();
                byte[] scanRecord = result.getScanRecord().getBytes();
                int rssi = result.getRssi();
                if (mLeScanFilter != null) {
                    final LeScanFilter filter = mLeScanFilter;
                    if (filter.macExclude != null && filter.macExclude.length != 0) {
                        for (String mac : filter.macExclude) {
                            if (mac.equalsIgnoreCase(device.getAddress())) {
                                return;
                            }
                        }
                    }
                }
                onDeviceScanned(device, rssi, scanRecord);

            }

            @Override
            public void onBatchScanResults(List<ScanResult> results) {
                super.onBatchScanResults(results);
            }

            @Override
            public void onScanFailed(int errorCode) {
                super.onScanFailed(errorCode);
                BleScanner.this.onScanFailed(errorCode, "scanner failed by : " + errorCode);
            }
        };
    }

    private void onDeviceScanned(BluetoothDevice bluetoothDevice, int rssi, byte[] scanRecord) {
        if (scanRecord == null) return;
        if (mScannerCallback != null) {
            mScannerCallback.onLeScan(bluetoothDevice, rssi, scanRecord);
        }
    }

    public synchronized void stopScan() {

        if (!isScanning) {
            return;
        }
        stopScanningTimeoutTask();
        stopScanningTask();
        if (mScannerType == ScannerType.DEFAULT) {
            stopLeScan();
        } else if (mScannerType == ScannerType.Lollipop) {
            stopLollipopScan();
        }
        isScanning = false;
        if (mScannerCallback != null) {
            mScannerCallback.onStoppedScan();
        }
    }

    /**
     * start bluetooth low energy scanning
     *
     * @param leScanFilter  scanning filter
     * @param leScanSetting scanning setting
     */
    public synchronized void startScan(@Nullable LeScanFilter leScanFilter, @Nullable LeScanSetting leScanSetting) {

        mDelayHandler.removeCallbacksAndMessages(null);
        /*if (!isEnabled()) {
            return;
        }*/

        if (isScanning) {
            stopScan();
        }
        anyDeviceFound = false;
        isScanning = true;
        this.mLeScanFilter = leScanFilter;
        if (leScanSetting == null) {
            mLeScanSetting = LeScanSetting.getDefault();
        } else {
            mLeScanSetting = leScanSetting;
        }

        long scanDelay = 0;

        long scanSpacing = mLeScanSetting.spacing;

        long currentTime = System.currentTimeMillis();
        if (scanSpacing > 0 && currentTime - mLastScanStartTime < scanSpacing) {
            scanDelay = scanSpacing - (currentTime - mLastScanStartTime);
            if (scanDelay > scanSpacing) scanDelay = scanSpacing;
        }
        mLastScanStartTime = currentTime;
        startScanningTask(scanDelay);
    }

    private void startScanningTimeoutTask(long timeout) {
        mDelayHandler.removeCallbacks(scanningTimeoutTask);
        mDelayHandler.postDelayed(scanningTimeoutTask, timeout);
    }

    private void stopScanningTimeoutTask() {
        mDelayHandler.removeCallbacks(scanningTimeoutTask);
    }

    private Runnable scanningTimeoutTask = new Runnable() {
        @Override
        public void run() {
            stopScan();
            if (mScannerCallback != null) {
                mScannerCallback.onScanTimeout(anyDeviceFound);
            }
        }
    };

    private void startScanningTask(long delay) {
        mDelayHandler.removeCallbacks(scanningStartTask);
        mDelayHandler.postDelayed(scanningStartTask, delay);
    }

    private void stopScanningTask() {
        mDelayHandler.removeCallbacks(scanningStartTask);
    }


    private Runnable scanningStartTask = new Runnable() {
        @Override
        public void run() {
            boolean scanStarted = false;
            if (mScannerType == ScannerType.DEFAULT) {
                scanStarted = startLeScan(mLeScanFilter);
            } else if (mScannerType == ScannerType.Lollipop) {
                scanStarted = startLollipopScan(mLeScanFilter, null);
            }
            startScanningTimeoutTask(mLeScanSetting.timeout);
            if (scanStarted) {
                if (mScannerCallback != null) {
                    mScannerCallback.onStartedScan();
                }
            } else {
                onScanFailed(CODE_START_FAIL, "scan action start failed");
            }

        }
    };

    private void onScanFailed(int errorCode, String desc) {
        isScanning = false;
        if (mScannerCallback != null) {
            mScannerCallback.onScanFail(errorCode);
        }
    }

    private boolean startLeScan(LeScanFilter leScanFilter) {
        if (mLeScanCallback != null) {
            BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
            return bluetoothAdapter.startLeScan(leScanFilter == null ? null : leScanFilter.uuidInclude, mLeScanCallback);
        } else {
            return false;
        }

    }

    private boolean startLollipopScan(LeScanFilter leScanFilter, ScanSettings scanSettings) {
        if (mLeScanner != null && mScanCallback != null) {
            List<ScanFilter> scanFilters = buildLeScanFilter(leScanFilter);
            if (scanSettings == null) {
                scanSettings = buildDefaultScanSettings();
            }

            mLeScanner.startScan(scanFilters, scanSettings, mScanCallback);
            return true;
        }

        return false;
    }

    private void stopLeScan() {
        if (mLeScanCallback != null) {
            BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
            bluetoothAdapter.stopLeScan(mLeScanCallback);
        }
    }

    private void stopLollipopScan() {
        if (mLeScanner != null && mScanCallback != null) {
            mLeScanner.stopScan(mScanCallback);
        }
    }

    public boolean isBluetoothSupported() {
        return BluetoothAdapter.getDefaultAdapter() != null;
    }

    public boolean isBluetoothEnabled() {
        return BluetoothAdapter.getDefaultAdapter() != null
                && BluetoothAdapter.getDefaultAdapter().isEnabled();
    }

    private List<ScanFilter> buildLeScanFilter(LeScanFilter filter) {

        if (filter == null) {
            return null;
        }

        int maxSize = Collections.max(Arrays.asList(
                filter.uuidInclude == null ? 0 : filter.uuidInclude.length,
                filter.macInclude == null ? 0 : filter.macInclude.length,
                filter.nameInclude == null ? 0 : filter.nameInclude.length
        ));
        if (maxSize == 0) {
            return null;
        }

        List<ScanFilter> results = new ArrayList<>();
        ScanFilter.Builder builder;
        for (int i = 0; i < maxSize; i++) {
            builder = new ScanFilter.Builder();
            if (filter.uuidInclude != null && filter.uuidInclude.length > i) {
                builder.setServiceUuid(ParcelUuid.fromString(filter.uuidInclude[i].toString()));
            }
            if (filter.macInclude != null && filter.macInclude.length > i) {
                builder.setDeviceAddress(filter.macInclude[i]);
            }

            if (filter.nameInclude != null && filter.nameInclude.length > i) {
                builder.setDeviceName(filter.nameInclude[i]);
            }
            results.add(builder.build());
        }

        return results;
    }

    private ScanSettings buildDefaultScanSettings() {
        ScanSettings.Builder builder = new ScanSettings.Builder()
                .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                .setReportDelay(0);
        if (ContextUtil.SDK_VERSION >= 23) {
            builder.setCallbackType(ScanSettings.CALLBACK_TYPE_ALL_MATCHES);
            builder.setMatchMode(ScanSettings.MATCH_MODE_AGGRESSIVE);
            builder.setNumOfMatches(ScanSettings.MATCH_NUM_MAX_ADVERTISEMENT);
        }
        if (ContextUtil.SDK_VERSION >= 26) {
            builder.setLegacy(true);
            builder.setPhy(ScanSettings.PHY_LE_ALL_SUPPORTED);
        }
        return builder.build();

    }

    /**
     * Scanner Types for different SDK-VERSION
     */
    public enum ScannerType {
        /**
         * for android-sdk 18 (4.3)
         */
        DEFAULT,

        /**
         * for android-sdk 21 (5.0)
         */
        Lollipop,

    }


    public interface ScannerCallback {
        void onLeScan(BluetoothDevice bluetoothDevice, int rssi, byte[] scanRecord);

        void onScanFail(int errorCode);

        void onStartedScan();

        void onStoppedScan();

        void onScanTimeout(boolean anyDeviceFound);
    }
}
