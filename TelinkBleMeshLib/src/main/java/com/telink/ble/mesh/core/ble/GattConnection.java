/********************************************************************************************************
 * @file GattConnection.java
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date Sep. 30, 2010
 *
 * @par Copyright (c) 2010, Telink Semiconductor (Shanghai) Co., Ltd.
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

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;

import com.telink.ble.mesh.core.proxy.ProxyPDU;
import com.telink.ble.mesh.util.Arrays;
import com.telink.ble.mesh.util.MeshLogger;

import java.lang.reflect.Method;
import java.util.List;
import java.util.Queue;
import java.util.UUID;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.atomic.AtomicBoolean;

import androidx.annotation.NonNull;

public class GattConnection extends BluetoothGattCallback {

    private final String LOG_TAG = "GATT";

    private Context mContext;

    private Handler mHandler;

    private BluetoothGatt mGatt;

    private BluetoothDevice mBluetoothDevice;

    private final Object CONNECTION_STATE_LOCK = new Object();

    protected final Runnable mConnectionTimeoutRunnable = new ConnectionTimeoutRunnable();

    protected final Runnable mDisconnectionTimeoutRunnable = new DisconnectionTimeoutRunnable();

    protected final Runnable mServicesDiscoveringRunnable = new ServicesDiscoveringRunnable();

    protected final Runnable mCommandTimeoutRunnable = new CommandTimeoutRunnable();

    protected final Handler mRequestTimeoutHandler = new Handler(Looper.getMainLooper());

    private final Queue<GattRequest> mGattRequestQueue = new ConcurrentLinkedQueue<>();

    private final Object COMMAND_PROCESSING_LOCK = new Object();

    private boolean isRequestProcessing = false;

    private AtomicBoolean isConnectWaiting = new AtomicBoolean(false);

    private long commandTimeoutMill = 10 * 1000;
    /**
     * connection timeout used on {@link #connect()}
     */
    private static final int CONNECTION_TIMEOUT = 10 * 1000;

    private static final int DISCONNECTION_TIMEOUT = 2 * 1000;

    /**
     * {@link BluetoothGatt#STATE_CONNECTED}
     */
    private int mConnectionState;

    private static final int CONN_STATE_IDLE = 0;
    private static final int CONN_STATE_CONNECTING = 1;
    private static final int CONN_STATE_CONNECTED = 2;
    private static final int CONN_STATE_DISCONNECTING = 3;
//    private static final int CONN_STATE_CLOSED = 4;

    /**
     * services get by gatt#discoverServices
     */
    protected List<BluetoothGattService> mServices;

    private ConnectionCallback mConnectionCallback;

    private byte[] proxyNotificationSegBuffer;

    private int mtu = 23;

    private static final int MTU_SIZE_MAX = 517;

    public GattConnection(Context context, HandlerThread thread) {
        mContext = context.getApplicationContext();
        mHandler = new Handler(thread.getLooper());
    }

    public void setConnectionCallback(ConnectionCallback connectionCallback) {
        this.mConnectionCallback = connectionCallback;
    }

    /*public static GattConnection createNewInstance(Context context, BluetoothDevice device) {
        GattConnection gattDevice = new GattConnection(context);
        gattDevice.mBluetoothDevice = device;
        return gattDevice;
    }*/

    public boolean isConnected() {
        synchronized (CONNECTION_STATE_LOCK) {
            return mConnectionState == CONN_STATE_CONNECTED;
        }
    }

    public boolean isProxyNodeConnected() {
        return isProxyNodeConnected(false);
    }

    /**
     * @return proxy node connected
     */
    public boolean isProxyNodeConnected(boolean real) {
        if (isConnected()) {
            return getProxyService(real) != null;
        }
        return false;
    }

    /**
     * @return un-provisioned node connected
     */
    public boolean isUnPvNodeConnected() {
        if (isConnected()) {
            return getProvisionService() != null;
        }
        return false;
    }

    public void proxyInit() {
        enableNotifications();
        writeCCCForPx();
//        writeCCCForPv();
    }

    public void provisionInit() {
        enableNotifications();
        writeCCCForPv();
        writeCCCForPx();
    }

    /**
     * @param type proxy pdu type
     * @param data data excluding type
     */
    public void sendMeshData(byte type, byte[] data) {
        // opcode: 1 byte, handle: 2 bytes
        final int mtu = this.mtu - 3;
        final boolean isProvisioningPdu = type == ProxyPDU.TYPE_PROVISIONING_PDU;
        if (data.length > mtu - 1) {
            double ceil = Math.ceil(((double) data.length) / (mtu - 1));
            int pktNum = (int) ceil;
            byte oct0;
            byte[] pkt;
            for (int i = 0; i < pktNum; i++) {
                if (i != pktNum - 1) {
                    if (i == 0) {
                        oct0 = (byte) (ProxyPDU.SAR_SEG_FIRST | type);
                    } else {
                        oct0 = (byte) (ProxyPDU.SAR_SEG_CONTINUE | type);
                    }
                    pkt = new byte[mtu];
                    pkt[0] = oct0;
                    System.arraycopy(data, (mtu - 1) * i, pkt, 1, mtu - 1);
                } else {
                    oct0 = (byte) (ProxyPDU.SAR_SEG_LAST | type);
                    int restSize = data.length - (mtu - 1) * i;
                    pkt = new byte[restSize + 1];
                    pkt[0] = oct0;
                    System.arraycopy(data, (mtu - 1) * i, pkt, 1, restSize);
                }
                log("send segment pkt: " + Arrays.bytesToHexString(pkt, ":"));
                if (isProvisioningPdu) {
                    sendPvRequest(pkt);
                } else {
                    sendProxyRequest(pkt);
                }
            }
        } else {
            byte[] proxyData = new byte[data.length + 1];
            proxyData[0] = type;
            System.arraycopy(data, 0, proxyData, 1, data.length);
            log("send unsegment pkt: " + Arrays.bytesToHexString(proxyData, ":"));
            if (isProvisioningPdu) {
                sendPvRequest(proxyData);
            } else {
                sendProxyRequest(proxyData);
            }
        }
    }


    // 27 18
    public void writeCCCForPv() {
        log("write ccc in provision service");
        GattRequest cmd = GattRequest.newInstance();
        BluetoothGattService service = getProvisionService();
        if (service == null) return;
        cmd.serviceUUID = service.getUuid();
        cmd.characteristicUUID = UUIDInfo.CHARACTERISTIC_PB_OUT;
        cmd.descriptorUUID = UUIDInfo.DESCRIPTOR_CFG_UUID;
        cmd.data = new byte[]{0x01, 0x00};
        cmd.type = GattRequest.RequestType.WRITE_DESCRIPTOR;
        sendRequest(cmd);
    }


    // 28 18
    public void writeCCCForPx() {
        log("write ccc in proxy service");
        GattRequest cmd = GattRequest.newInstance();
        BluetoothGattService service = getProxyService(false);
        if (service == null) return;
        cmd.serviceUUID = service.getUuid();
        cmd.characteristicUUID = UUIDInfo.CHARACTERISTIC_PROXY_OUT;
        cmd.descriptorUUID = UUIDInfo.DESCRIPTOR_CFG_UUID;
        cmd.data = new byte[]{0x01, 0x00};
        cmd.type = GattRequest.RequestType.WRITE_DESCRIPTOR;
        sendRequest(cmd);
    }

    public boolean enableOnlineStatus() {
        GattRequest cmd = GattRequest.newInstance();
        if (!isConnected()) return false;
        if (!checkOnlineStatusService()) return false;
        cmd.serviceUUID = UUIDInfo.SERVICE_ONLINE_STATUS;
        cmd.characteristicUUID = UUIDInfo.CHARACTERISTIC_ONLINE_STATUS;
        cmd.data = new byte[]{0x01};
        cmd.type = GattRequest.RequestType.WRITE_NO_RESPONSE;
        sendRequest(cmd);
        return true;
    }


    private void sendPvRequest(byte[] data) {
        GattRequest cmd = GattRequest.newInstance();
        cmd.characteristicUUID = UUIDInfo.CHARACTERISTIC_PB_IN;
        BluetoothGattService service = getProvisionService();
        if (service == null) return;
        cmd.serviceUUID = service.getUuid();
        cmd.data = data.clone();
        cmd.type = GattRequest.RequestType.WRITE_NO_RESPONSE;
        sendRequest(cmd);
    }

    private void sendProxyRequest(byte[] data) {
        GattRequest cmd = GattRequest.newInstance();
        BluetoothGattService service = getProxyService(false);
        if (service == null) return;
        cmd.serviceUUID = service.getUuid();
        cmd.characteristicUUID = UUIDInfo.CHARACTERISTIC_PROXY_IN;
        cmd.data = data.clone();
        cmd.type = GattRequest.RequestType.WRITE_NO_RESPONSE;
        sendRequest(cmd);
    }


    private void enableNotifications() {
        GattRequest gattRequest;
        BluetoothGattService provisionService = getProvisionService();
        if (provisionService != null) {
            gattRequest = GattRequest.newInstance();
            gattRequest.type = GattRequest.RequestType.ENABLE_NOTIFY;
            gattRequest.serviceUUID = provisionService.getUuid();
            gattRequest.characteristicUUID = UUIDInfo.CHARACTERISTIC_PB_OUT;
            sendRequest(gattRequest);
        }

        BluetoothGattService proxyService = getProxyService(false);
        if (proxyService != null) {
            gattRequest = GattRequest.newInstance();
            gattRequest.type = GattRequest.RequestType.ENABLE_NOTIFY;
            gattRequest.serviceUUID = proxyService.getUuid();
            gattRequest.characteristicUUID = UUIDInfo.CHARACTERISTIC_PROXY_OUT;
            sendRequest(gattRequest);
        }

        {
            gattRequest = GattRequest.newInstance();
            gattRequest.type = GattRequest.RequestType.ENABLE_NOTIFY;
            gattRequest.serviceUUID = UUIDInfo.SERVICE_ONLINE_STATUS;
            gattRequest.characteristicUUID = UUIDInfo.CHARACTERISTIC_ONLINE_STATUS;
            sendRequest(gattRequest);
        }
    }

    private boolean checkOnlineStatusService() {
        if (this.mServices == null) return false;
        for (BluetoothGattService service : mServices) {
            if (service.getUuid().equals(UUIDInfo.SERVICE_ONLINE_STATUS)) {
                for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
                    if (characteristic.getUuid().equals(UUIDInfo.CHARACTERISTIC_ONLINE_STATUS)) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    private BluetoothGattService getProvisionService() {
        final List<BluetoothGattService> services = this.mServices;
        if (services == null) return null;
        for (BluetoothGattService service :
                services) {
            if (service.getUuid().equals(UUIDInfo.SERVICE_PROVISION) || service.getUuid().equals(UUIDInfo.SERVICE_MESH_FLEX)) {
                for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
                    if (characteristic.getUuid().equals(UUIDInfo.CHARACTERISTIC_PB_IN)) {
                        return service;
                    }
                }
            }
        }
        return null;
    }

    /**
     * @param real true: only check PROXY_SERVICE_UUID,
     *             false: check PROXY_SERVICE_UUID and MESH_FLEX_SERVICE_UUID
     */
    private BluetoothGattService getProxyService(boolean real) {
        final List<BluetoothGattService> services = this.mServices;
        if (services == null) return null;
        for (BluetoothGattService service : services) {
            if ((service.getUuid().equals(UUIDInfo.SERVICE_PROXY))
                    || (!real && service.getUuid().equals(UUIDInfo.SERVICE_MESH_FLEX))) {
                for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
                    if (characteristic.getUuid().equals(UUIDInfo.CHARACTERISTIC_PROXY_IN)) {
                        return service;
                    }
                }
            }
        }
        return null;
    }


    public void connect(BluetoothDevice bluetoothDevice) {
        if (bluetoothDevice.equals(mBluetoothDevice)) {
            connect();
        } else {
            this.mBluetoothDevice = bluetoothDevice;
            if (this.disconnect()) {
                // waiting for disconnected callback
                log(" waiting for disconnect -- ");
                isConnectWaiting.set(true);
            } else {
                log(" already disconnected -- ");
                // execute connecting action
                this.connect();
            }
        }
    }


    public void connect() {
        synchronized (CONNECTION_STATE_LOCK) {
            if (mConnectionState == CONN_STATE_CONNECTED) {
                this.onConnected();
                if (mServices != null) {
                    this.onServicesDiscoveredComplete(mServices);
                }
                /* auto discover services when connection established */
            } else if (mConnectionState == CONN_STATE_IDLE) {
                this.mConnectionState = CONN_STATE_CONNECTING;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    this.mGatt = this.mBluetoothDevice.connectGatt(mContext, false, this, BluetoothDevice.TRANSPORT_LE);
                } else {
                    this.mGatt = this.mBluetoothDevice.connectGatt(mContext, false, this);
                }
                if (this.mGatt == null) {
                    this.disconnect();
                    this.mConnectionState = CONN_STATE_IDLE;
                    this.onDisconnected();
                } else {
                    mHandler.postDelayed(mConnectionTimeoutRunnable, CONNECTION_TIMEOUT);
                }
            }
            /* ignore CONN_STATE_DISCONNECTING and CONN_STATE_CONNECTING */
        }
    }

    /**
     * @return true: onDisconnected will callback
     * false: no callback
     */
    public boolean disconnect() {
        this.clear();
        synchronized (this.CONNECTION_STATE_LOCK) {
            if (mConnectionState == CONN_STATE_IDLE) return false;
            if (this.mGatt != null) {
                if (mConnectionState == CONN_STATE_CONNECTED) {
                    this.mConnectionState = CONN_STATE_DISCONNECTING;
                    this.mGatt.disconnect();
                } else if (mConnectionState == CONN_STATE_CONNECTING) {
                    this.mGatt.disconnect();
                    this.mGatt.close();
                    this.mConnectionState = CONN_STATE_IDLE;
                    return false;
                }
            } else {
                this.mConnectionState = CONN_STATE_IDLE;
                return false;
            }
        }
        startDisconnectionCheck();
        return true;
    }


    private void startDisconnectionCheck() {
        mHandler.removeCallbacks(mDisconnectionTimeoutRunnable);
        mHandler.postDelayed(mDisconnectionTimeoutRunnable, DISCONNECTION_TIMEOUT);
    }

    private void startServicesDiscovering() {
        long delay;
        if (mBluetoothDevice.getBondState() == BluetoothDevice.BOND_BONDED) {
            // waiting for encryption procedure
            delay = 1600;
        } else {
            delay = 300;
        }
        mHandler.removeCallbacks(mServicesDiscoveringRunnable);
        mHandler.postDelayed(mServicesDiscoveringRunnable, delay);
    }

    private void clear() {
        this.refreshCache();
        this.cancelCommandTimeoutTask();
        this.mGattRequestQueue.clear();
        this.isRequestProcessing = false;
        this.mHandler.removeCallbacksAndMessages(null);
    }

    private void onConnected() {
        this.mHandler.removeCallbacks(mConnectionTimeoutRunnable);
        if (mConnectionCallback != null) {
            mConnectionCallback.onConnected();
        }
    }

    public void requestConnectionPriority(int connectionPriority) {
        if (mGatt != null) {
            mGatt.requestConnectionPriority(connectionPriority);
        }
    }

    public boolean refreshCache() {
        if (Build.VERSION.SDK_INT >= 27) return false;
        if (mGatt == null) {
            log("refresh error: gatt null");
            return false;
        } else {
            log("Device#refreshCache#prepare");
        }
        try {
            BluetoothGatt localBluetoothGatt = mGatt;
            Method localMethod = localBluetoothGatt.getClass().getMethod("refresh", new Class[0]);
            if (localMethod != null) {
                boolean bool = (Boolean) localMethod.invoke(localBluetoothGatt, new Object[0]);
                /*if (bool) {
                    mDelayHandler.postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            gatt.discoverServices();
                        }
                    }, 0);
                }*/
                return bool;
            }
        } catch (Exception localException) {
            log("An exception occurs while refreshing device");
        }
        return false;
    }


    private void onServicesDiscoveredComplete(List<BluetoothGattService> services) {
        /*StringBuffer serviceInfo = new StringBuffer("\n");

        for (BluetoothGattService service : services) {
            serviceInfo.append(service.getUuid().toString()).append("\n");
            for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
                serviceInfo.append("chara: \t");
                serviceInfo.append(characteristic.getUuid().toString()).append("\n");
            }
        }
        log("services: " + serviceInfo);*/
        log("service discover complete");
        if (mConnectionCallback != null) {
            mConnectionCallback.onServicesDiscovered(services);
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            this.mGatt.requestMtu(MTU_SIZE_MAX);
        }
    }

    private void onDisconnected() {
        this.mHandler.removeCallbacks(mDisconnectionTimeoutRunnable);
        this.mHandler.removeCallbacks(mServicesDiscoveringRunnable);
        this.mServices = null;
        if (isConnectWaiting.get()) {
            isConnectWaiting.set(false);
            this.connect();
        } else {
            if (mConnectionCallback != null) {
                mConnectionCallback.onDisconnected();
            }
        }


    }


    public String getMacAddress() {
        if (mBluetoothDevice == null) return null;
        return mBluetoothDevice.getAddress();
    }

    public String getDeviceName() {
        if (mBluetoothDevice == null) return null;
        return mBluetoothDevice.getName();
    }

    public int getMtu() {
        return this.mtu;
    }

    /************************************************************************
     * gatt operation
     ************************************************************************/

    public boolean sendRequest(@NonNull GattRequest gattRequest) {
        synchronized (this.CONNECTION_STATE_LOCK) {
            if (this.mConnectionState != CONN_STATE_CONNECTED)
                return false;
        }
        mGattRequestQueue.add(gattRequest);
        postRequest();
        return true;
    }

    private void postRequest() {
        synchronized (COMMAND_PROCESSING_LOCK) {
            if (isRequestProcessing) {
                return;
            }
        }

        synchronized (mGattRequestQueue) {
            if (!mGattRequestQueue.isEmpty()) {
                GattRequest gattRequest = mGattRequestQueue.peek();
                if (gattRequest != null) {
                    synchronized (COMMAND_PROCESSING_LOCK) {
                        isRequestProcessing = true;
                    }
                    processRequest(gattRequest);
                }
            }
        }
    }

    private void processRequest(GattRequest gattRequest) {
        GattRequest.RequestType requestType = gattRequest.type;
        log("process request : " + gattRequest.toString(), MeshLogger.LEVEL_VERBOSE);
        switch (requestType) {
            case READ:
                this.postCommandTimeoutTask();
                this.readCharacteristic(gattRequest);
                break;
            case WRITE:
                this.postCommandTimeoutTask();
                this.writeCharacteristic(gattRequest, BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);
                break;
            case WRITE_NO_RESPONSE:
                this.postCommandTimeoutTask();
                this.writeCharacteristic(gattRequest, BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE);
                break;
            case READ_DESCRIPTOR:
                this.postCommandTimeoutTask();
                this.readDescriptor(gattRequest);
                break;
            case WRITE_DESCRIPTOR:
                this.postCommandTimeoutTask();
                this.writeDescriptor(gattRequest);
                break;
            case ENABLE_NOTIFY:
                this.enableNotification(gattRequest);
                break;
            case DISABLE_NOTIFY:
                this.disableNotification(gattRequest);
                break;
        }
    }


    private void postCommandTimeoutTask() {

        if (this.commandTimeoutMill <= 0)
            return;

        this.mRequestTimeoutHandler.removeCallbacksAndMessages(null);
        this.mRequestTimeoutHandler.postDelayed(this.mCommandTimeoutRunnable, this.commandTimeoutMill);
    }

    private void cancelCommandTimeoutTask() {
        this.mRequestTimeoutHandler.removeCallbacksAndMessages(null);
    }


    private void onNotify(BluetoothGattCharacteristic characteristic, byte[] data) {
        final UUID charUUID = characteristic.getUuid();
        final UUID serviceUUID = characteristic.getService().getUuid();
        if (!charUUID.equals(UUIDInfo.CHARACTERISTIC_PB_OUT) && !charUUID.equals(UUIDInfo.CHARACTERISTIC_PROXY_OUT)) {
            if (mConnectionCallback != null) {
                mConnectionCallback.onNotify(serviceUUID, charUUID, data);
            }
            return;
        }
        log("on notify -- " + Arrays.bytesToHexString(data, ":"), MeshLogger.LEVEL_VERBOSE);

        if (data == null || data.length == 0) {
            log("empty packet received!", MeshLogger.LEVEL_WARN);
            return;
        }
        byte[] completePacket = getCompletePacket(data);
        if (completePacket == null) {
            log("waiting for segment pkt", MeshLogger.LEVEL_VERBOSE);
            return;
        }
        log("completed notification data: " + Arrays.bytesToHexString(completePacket, ":"));
        if (completePacket.length <= 1) {
            log("complete notification length err", MeshLogger.LEVEL_WARN);
            return;
        }
        if (mConnectionCallback != null) {
            mConnectionCallback.onNotify(serviceUUID, charUUID, completePacket);
        }
    }

    private byte[] getCompletePacket(byte[] data) {
        byte sar = (byte) (data[0] & ProxyPDU.BITS_SAR);
        switch (sar) {
            case ProxyPDU.SAR_COMPLETE:
                return data;

            case ProxyPDU.SAR_SEG_FIRST:
                data[0] = (byte) (data[0] & ProxyPDU.BITS_TYPE);
                proxyNotificationSegBuffer = data;
                return null;

            case ProxyPDU.SAR_SEG_CONTINUE:
            case ProxyPDU.SAR_SEG_LAST:
                if (proxyNotificationSegBuffer != null) {
                    int segType = proxyNotificationSegBuffer[0] & ProxyPDU.BITS_TYPE;
                    int dataType = data[0] & ProxyPDU.BITS_TYPE;

                    // check if pkt typeValue equals
                    if (segType == dataType && data.length > 1) {
                        byte[] tempBuffer = new byte[proxyNotificationSegBuffer.length + data.length - 1];
                        System.arraycopy(proxyNotificationSegBuffer, 0, tempBuffer, 0, proxyNotificationSegBuffer.length);
                        System.arraycopy(data, 1, tempBuffer, proxyNotificationSegBuffer.length, data.length - 1);
                        if (sar == ProxyPDU.SAR_SEG_CONTINUE) {
                            proxyNotificationSegBuffer = tempBuffer;
                            return null;
                        } else {
                            proxyNotificationSegBuffer = null;
                            return tempBuffer;
                        }
                    } else {
                        log("other segment ", MeshLogger.LEVEL_WARN);
                    }
                } else {
                    log("segment first pkt no found", MeshLogger.LEVEL_WARN);
                }

            default:
                return null;
        }
    }

    private void onRequestError(String errorMsg) {
        log("request error: " + errorMsg);
        GattRequest request;
        synchronized (mGattRequestQueue) {
            request = this.mGattRequestQueue.poll();
        }
        if (request != null) {
            GattRequest.Callback requestCallback = request.callback;
            if (requestCallback != null) {
                requestCallback.error(request, errorMsg);
            }
        }
    }


    private boolean onRequestTimeout(@NonNull GattRequest gattRequest) {
        log("gatt request timeout", MeshLogger.LEVEL_VERBOSE);
        GattRequest.Callback requestCallback = gattRequest.callback;
        if (requestCallback != null) {
            return requestCallback.timeout(gattRequest);
        }
        return false;
    }


    /**
     * @param data command response
     */
    private void onRequestSuccess(byte[] data) {
        GattRequest gattRequest = mGattRequestQueue.poll();
        if (gattRequest != null) {
            log("request success: tag - " + gattRequest.tag, MeshLogger.LEVEL_VERBOSE);
            GattRequest.Callback requestCallback = gattRequest.callback;
            if (requestCallback != null) {
                requestCallback.success(gattRequest, data);
            }
        } else {
            log("request not found");
        }
    }

    private void onRequestComplete() {

        log("gatt request completed", MeshLogger.LEVEL_VERBOSE);

        synchronized (this.COMMAND_PROCESSING_LOCK) {
            if (this.isRequestProcessing)
                this.isRequestProcessing = false;
        }

        this.postRequest();
    }

    public void enableNotification(GattRequest gattRequest) {

        boolean success = true;
        String errorMsg = "";
        final UUID serviceUUID = gattRequest.serviceUUID;
        final UUID characteristicUUID = gattRequest.characteristicUUID;
        BluetoothGattService service = this.mGatt.getService(serviceUUID);
        if (service != null) {
            BluetoothGattCharacteristic characteristic = this
                    .findNotifyCharacteristic(service, characteristicUUID);

            if (characteristic != null) {

                if (!this.mGatt.setCharacteristicNotification(characteristic,
                        true)) {
                    success = false;
                    errorMsg = "enable notification error";
                }

            } else {
                success = false;
                errorMsg = "no characteristic";
            }
        } else {
            success = false;
            errorMsg = "service is not offered by the remote device";
        }

        if (!success) {
            String errInfo = "enable notification error: " + errorMsg + " - " + characteristicUUID;
            this.onRequestError(errInfo);
        } else {
            this.onRequestSuccess(null);
        }
        this.onRequestComplete();
    }

    private void disableNotification(GattRequest gattRequest) {

        boolean success = true;
        String errorMsg = "";
        final UUID serviceUUID = gattRequest.serviceUUID;
        final UUID characteristicUUID = gattRequest.characteristicUUID;
        BluetoothGattService service = this.mGatt.getService(serviceUUID);

        if (service != null) {

            BluetoothGattCharacteristic characteristic = this
                    .findNotifyCharacteristic(service, characteristicUUID);

            if (characteristic != null) {
                if (!this.mGatt.setCharacteristicNotification(characteristic,
                        false)) {
                    success = false;
                    errorMsg = "disable notification error";
                }

            } else {
                success = false;
                errorMsg = "no characteristic";
            }

        } else {
            success = false;
            errorMsg = "service is not offered by the remote device";
        }

        if (!success) {
            String errInfo = "disable notification error: " + errorMsg + " - " + characteristicUUID;
            log(errInfo);
            this.onRequestError(errInfo);
        } else {
            this.onRequestSuccess(null);
        }
        this.onRequestComplete();
    }


    private void readDescriptor(GattRequest gattRequest) {

        boolean success = true;
        String errorMsg = "";
        final UUID serviceUUID = gattRequest.serviceUUID;
        final UUID characteristicUUID = gattRequest.characteristicUUID;
        final UUID descriptorUUID = gattRequest.descriptorUUID;
        BluetoothGattService service = this.mGatt.getService(serviceUUID);

        if (service != null) {

            BluetoothGattCharacteristic characteristic = service
                    .getCharacteristic(characteristicUUID);

            if (characteristic != null) {

                BluetoothGattDescriptor descriptor = characteristic.getDescriptor(descriptorUUID);
                if (descriptor != null) {
                    if (!this.mGatt.readDescriptor(descriptor)) {
                        success = false;
                        errorMsg = "read descriptor error";
                    }
                } else {
                    success = false;
                    errorMsg = "read descriptor error - descriptor not found";
                }

            } else {
                success = false;
                errorMsg = "read characteristic error - characteristic not found";
            }
        } else {
            success = false;
            errorMsg = "service is not offered by the remote device";
        }

        if (!success) {
            this.onRequestError(errorMsg);
            this.onRequestComplete();
        }
    }

    private void writeDescriptor(GattRequest gattRequest) {

        boolean success = true;
        String errorMsg = "";
        final UUID serviceUUID = gattRequest.serviceUUID;
        final UUID characteristicUUID = gattRequest.characteristicUUID;
        final UUID descriptorUUID = gattRequest.descriptorUUID;
        byte[] data = gattRequest.data;
        BluetoothGattService service = this.mGatt.getService(serviceUUID);

        if (service != null) {
            BluetoothGattCharacteristic characteristic = service.getCharacteristic(characteristicUUID);

            if (characteristic != null) {

                BluetoothGattDescriptor descriptor = characteristic.getDescriptor(descriptorUUID);
                if (descriptor != null) {
                    descriptor.setValue(data);
                    if (!this.mGatt.writeDescriptor(descriptor)) {
                        success = false;
                        errorMsg = "write characteristic error";
                    }
                } else {
                    success = false;
                    errorMsg = "no descriptor";
                }


            } else {
                success = false;
                errorMsg = "no characteristic";
            }
        } else {
            success = false;
            errorMsg = "service is not offered by the remote device";
        }

        if (!success) {
            this.onRequestError(errorMsg);
            this.onRequestComplete();
        }
    }


    private void readCharacteristic(GattRequest request) {

        boolean success = true;
        String errorMsg = "";
        final UUID serviceUUID = request.serviceUUID;
        final UUID characteristicUUID = request.characteristicUUID;
        BluetoothGattService service = this.mGatt.getService(serviceUUID);

        if (service != null) {
            BluetoothGattCharacteristic characteristic = service
                    .getCharacteristic(characteristicUUID);

            if (characteristic != null) {

                if (!this.mGatt.readCharacteristic(characteristic)) {
                    success = false;
                    errorMsg = "read characteristic error";
                }

            } else {
                success = false;
                errorMsg = "read characteristic error - characteristic not found";
            }
        } else {
            success = false;
            errorMsg = "service is not offered by the remote device";
        }

        if (!success) {
            this.onRequestError(errorMsg);
            this.onRequestComplete();
        }
    }

    private void writeCharacteristic(GattRequest gattRequest,
                                     int writeType) {

        boolean success = true;
        String errorMsg = "";
        final UUID serviceUUID = gattRequest.serviceUUID;
        final UUID characteristicUUID = gattRequest.characteristicUUID;
        final byte[] data = gattRequest.data;
        BluetoothGattService service = this.mGatt.getService(serviceUUID);

        if (service != null) {
            BluetoothGattCharacteristic characteristic = this
                    .findWritableCharacteristic(service, characteristicUUID,
                            writeType);
            if (characteristic != null) {

                characteristic.setValue(data);
                characteristic.setWriteType(writeType);

                if (!this.mGatt.writeCharacteristic(characteristic)) {
                    success = false;
                    errorMsg = "write characteristic error";
                }

            } else {
                success = false;
                errorMsg = "no characteristic";
            }
        } else {
            success = false;
            errorMsg = "service is not offered by the remote device";
        }

        if (!success) {
            this.onRequestError(errorMsg);
            this.onRequestComplete();
        }
    }


    private BluetoothGattCharacteristic findWritableCharacteristic(
            BluetoothGattService service, UUID characteristicUUID, int writeType) {

        BluetoothGattCharacteristic characteristic = null;

        int writeProperty = BluetoothGattCharacteristic.PROPERTY_WRITE;

        if (writeType == BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE) {
            writeProperty = BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE;
        }

        List<BluetoothGattCharacteristic> characteristics = service
                .getCharacteristics();

        for (BluetoothGattCharacteristic c : characteristics) {
            if ((c.getProperties() & writeProperty) != 0
                    && characteristicUUID.equals(c.getUuid())) {
                characteristic = c;
                break;
            }
        }

        return characteristic;
    }

    private BluetoothGattCharacteristic findNotifyCharacteristic(
            BluetoothGattService service, UUID characteristicUUID) {

        BluetoothGattCharacteristic characteristic = null;

        List<BluetoothGattCharacteristic> characteristics = service
                .getCharacteristics();

        for (BluetoothGattCharacteristic c : characteristics) {
            if ((c.getProperties() & BluetoothGattCharacteristic.PROPERTY_NOTIFY) != 0
                    && characteristicUUID.equals(c.getUuid())) {
                characteristic = c;
                break;
            }
        }

        if (characteristic != null)
            return characteristic;

        for (BluetoothGattCharacteristic c : characteristics) {
            if ((c.getProperties() & BluetoothGattCharacteristic.PROPERTY_INDICATE) != 0
                    && characteristicUUID.equals(c.getUuid())) {
                characteristic = c;
                break;
            }
        }

        return characteristic;
    }

    /************************************************************************
     * gatt [end]
     ************************************************************************/


    /************************************************************************
     * gatt callback [start]
     ************************************************************************/

    /**
     * gatt#setPreferredPhy callback
     */
    @Override
    public void onPhyUpdate(BluetoothGatt gatt, int txPhy, int rxPhy, int status) {
        super.onPhyUpdate(gatt, txPhy, rxPhy, status);

    }

    /**
     * gatt#readPhy callback
     */
    @Override
    public void onPhyRead(BluetoothGatt gatt, int txPhy, int rxPhy, int status) {
        super.onPhyRead(gatt, txPhy, rxPhy, status);
    }

    /**
     * connection/disconnection callback
     */
    @Override
    public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
        log("onConnectionStateChange  status :" + status + " state : " + newState);
        if (newState == BluetoothGatt.STATE_CONNECTED) {
            synchronized (CONNECTION_STATE_LOCK) {
                this.mConnectionState = CONN_STATE_CONNECTED;
            }
            this.onConnected();
            startServicesDiscovering();
        } else {
            synchronized (this.CONNECTION_STATE_LOCK) {
                log("Close");
                if (this.mGatt != null) {
                    this.mGatt.close();
                }
                this.clear();
                this.mConnectionState = CONN_STATE_IDLE;
                this.onDisconnected();
            }
        }

    }

    /**
     * gatt#discoverServices callback
     */
    @Override
    public void onServicesDiscovered(BluetoothGatt gatt, int status) {
        if (status == BluetoothGatt.GATT_SUCCESS) {
            List<BluetoothGattService> services = gatt.getServices();
            this.mServices = services;
            this.onServicesDiscoveredComplete(services);
        } else {
            log("Service discovery failed");
            this.disconnect();
        }
    }

    @Override
    public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
        super.onCharacteristicRead(gatt, characteristic, status);
        this.cancelCommandTimeoutTask();
        if (gattStatusSuccess(status)) {
            byte[] data = characteristic.getValue();
            this.onRequestSuccess(data);
        } else {
            this.onRequestError("read characteristic failed");
        }
        this.onRequestComplete();
    }

    @Override
    public void onCharacteristicWrite(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
        super.onCharacteristicWrite(gatt, characteristic, status);
        this.cancelCommandTimeoutTask();
        if (gattStatusSuccess(status)) {
            this.onRequestSuccess(null);
        } else {
            this.onRequestError("write characteristic fail");
        }
        this.onRequestComplete();
    }

    @Override
    public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
        super.onCharacteristicChanged(gatt, characteristic);
        this.onNotify(characteristic, characteristic.getValue());
    }

    @Override
    public void onDescriptorRead(BluetoothGatt gatt, BluetoothGattDescriptor descriptor, int status) {
        super.onDescriptorRead(gatt, descriptor, status);
        this.cancelCommandTimeoutTask();
        if (gattStatusSuccess(status)) {
            this.onRequestSuccess(descriptor.getValue());
        } else {
            this.onRequestError("read descriptor fail");
        }
        this.onRequestComplete();
    }

    @Override
    public void onDescriptorWrite(BluetoothGatt gatt, BluetoothGattDescriptor descriptor, int status) {
        super.onDescriptorWrite(gatt, descriptor, status);
        this.cancelCommandTimeoutTask();
        if (gattStatusSuccess(status)) {
            this.onRequestSuccess(null);
        } else {
            this.onRequestError("write descriptor fail");
        }
        this.onRequestComplete();
    }

    @Override
    public void onReliableWriteCompleted(BluetoothGatt gatt, int status) {
        super.onReliableWriteCompleted(gatt, status);
    }

    @Override
    public void onReadRemoteRssi(BluetoothGatt gatt, int rssi, int status) {
        super.onReadRemoteRssi(gatt, rssi, status);
    }

    @Override
    public void onMtuChanged(BluetoothGatt gatt, int mtu, int status) {
        log("onMtuChanged: " + mtu);
        super.onMtuChanged(gatt, mtu, status);
        if (gattStatusSuccess(status)) {
            this.mtu = mtu;
        }
    }

    /************************************************************************
     * gatt callback [end]
     ************************************************************************/

    private final class ConnectionTimeoutRunnable implements Runnable {

        @Override
        public void run() {
            if (!disconnect()) {
                onDisconnected();
            }
        }
    }

    private final class DisconnectionTimeoutRunnable implements Runnable {

        @Override
        public void run() {
            log("disconnection timeout");
            synchronized (CONNECTION_STATE_LOCK) {
                if (mGatt != null) {
                    mGatt.disconnect();
                    mGatt.close();
                }
                mConnectionState = CONN_STATE_IDLE;
                onDisconnected();
            }

        }
    }

    private final class ServicesDiscoveringRunnable implements Runnable {

        @Override
        public void run() {
            if (mGatt == null || !mGatt.discoverServices()) {
                disconnect();
            } else {
                log("start services discovering");
            }
        }
    }

    private final class CommandTimeoutRunnable implements Runnable {

        @Override
        public void run() {

            synchronized (mGattRequestQueue) {

                GattRequest gattRequest = mGattRequestQueue.peek();

                if (gattRequest != null) {

                    boolean retry = onRequestTimeout(gattRequest);

                    if (retry) {
                        processRequest(gattRequest);
                    } else {
                        gattRequest.clear();
                        mGattRequestQueue.poll();
                        onRequestComplete();
                    }
                }
            }
        }
    }


    private boolean gattStatusSuccess(int status) {
        return status == BluetoothGatt.GATT_SUCCESS;
    }

    /**
     * gatt status description
     *
     * @param status gatt status
     * @return desc
     */
    private String getGattStatusDesc(int status) {
        switch (status) {
            case BluetoothGatt.GATT_SUCCESS:
                return "success";
            case BluetoothGatt.GATT_READ_NOT_PERMITTED:
                return "read not permitted";

            case BluetoothGatt.GATT_WRITE_NOT_PERMITTED:
                return "write not permitted";

            case BluetoothGatt.GATT_INSUFFICIENT_AUTHENTICATION:
                return "insufficient authentication";

            case BluetoothGatt.GATT_REQUEST_NOT_SUPPORTED:
                return "request not supported";

            case BluetoothGatt.GATT_INSUFFICIENT_ENCRYPTION:
                return "insufficient encryption";

            case BluetoothGatt.GATT_INVALID_OFFSET:
                return "invalid offset";

            case BluetoothGatt.GATT_INVALID_ATTRIBUTE_LENGTH:
                return "invalid attribute length";

            case BluetoothGatt.GATT_CONNECTION_CONGESTED:
                return "connection congested";

            case BluetoothGatt.GATT_FAILURE:
                return "failure";
            default:
                return "unknown";
        }
    }

    public interface ConnectionCallback {
        void onConnected();

        void onDisconnected();

        void onServicesDiscovered(List<BluetoothGattService> services);

        void onNotify(UUID serviceUUID, UUID charUUID, byte[] data);
    }

    private void log(String logMessage) {
        log(logMessage, MeshLogger.LEVEL_DEBUG);
    }

    private void log(String logMessage, int level) {
        MeshLogger.log(logMessage, LOG_TAG, level);
    }
}
