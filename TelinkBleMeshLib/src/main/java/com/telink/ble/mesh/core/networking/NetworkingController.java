/********************************************************************************************************
 * @file NetworkingController.java
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
package com.telink.ble.mesh.core.networking;

import android.os.Handler;
import android.os.HandlerThread;
import android.util.SparseArray;
import android.util.SparseIntArray;
import android.util.SparseLongArray;

import com.telink.ble.mesh.core.Encipher;
import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.MeshMessage;
import com.telink.ble.mesh.core.networking.beacon.MeshBeaconPDU;
import com.telink.ble.mesh.core.networking.beacon.SecureNetworkBeacon;
import com.telink.ble.mesh.core.networking.transport.lower.LowerTransportPDU;
import com.telink.ble.mesh.core.networking.transport.lower.SegmentAcknowledgmentMessage;
import com.telink.ble.mesh.core.networking.transport.lower.SegmentedAccessMessagePDU;
import com.telink.ble.mesh.core.networking.transport.lower.TransportControlMessagePDU;
import com.telink.ble.mesh.core.networking.transport.lower.UnsegmentedAccessMessagePDU;
import com.telink.ble.mesh.core.networking.transport.lower.UnsegmentedControlMessagePDU;
import com.telink.ble.mesh.core.networking.transport.upper.UpperTransportAccessPDU;
import com.telink.ble.mesh.core.proxy.ProxyAddAddressMessage;
import com.telink.ble.mesh.core.proxy.ProxyConfigurationMessage;
import com.telink.ble.mesh.core.proxy.ProxyConfigurationPDU;
import com.telink.ble.mesh.core.proxy.ProxyFilterStatusMessage;
import com.telink.ble.mesh.core.proxy.ProxyFilterType;
import com.telink.ble.mesh.core.proxy.ProxyPDU;
import com.telink.ble.mesh.core.proxy.ProxySetFilterTypeMessage;
import com.telink.ble.mesh.foundation.MeshConfiguration;
import com.telink.ble.mesh.util.Arrays;
import com.telink.ble.mesh.util.MeshLogger;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Queue;
import java.util.Set;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * networking packet
 * partition and composition
 */

/**
 * Created by kee on 2019/7/31.
 */
public class NetworkingController {

    private final String LOG_TAG = "Networking";
    // include mic(4)
    public static final int UNSEGMENTED_TRANSPORT_PAYLOAD_MAX_LENGTH = 15;

    public static final int UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DEFAULT = 11;

//    private static final int SEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH = 12;

    public static final int UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DLE = 225;

//    private static final int SEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH = UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH + 1;

    private boolean dleEnabled = false;

    // segmentedAccessLength = unsegmentedAccessLength + 1
    public static int unsegmentedAccessLength = UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DLE;


    private static final int DEFAULT_SEQUENCE_NUMBER_UPDATE_STEP = 0x100;

    /**
     * executing iv update procedure when connect proxy node success
     * based on sequence number value >= THRESHOLD_SEQUENCE_NUMBER
     *
     * @see #checkSequenceNumber(byte[], byte[])
     */
    private final static int THRESHOLD_SEQUENCE_NUMBER = 0xC00000;


    // for test
//    private final static int THRESHOLD_SEQUENCE_NUMBER = 0x0100;

    /**
     * receive
     */
    private final static int TRANSPORT_IN = 0x00;

    /**
     * transmit
     */
    private final static int TRANSPORT_OUT = 0x01;

    private AtomicInteger mSequenceNumber = new AtomicInteger(0x0001);

    private boolean isIvUpdating = false;

    private byte nid;

    private byte[] encryptionKey;

    private byte[] privacyKey;

    private int netKeyIndex;

    /**
     * deviceKey and unicastAddress map
     */
    private SparseArray<byte[]> deviceKeyMap;

    /**
     * save device sequence number and compare with sequence number in received network pdu
     * if sequence number in network pud is not larger than saved sequence number, drop this pdu
     */
    private SparseIntArray deviceSequenceNumberMap = new SparseIntArray();

    /**
     * appKey and appKeyIndex map
     */
    private SparseArray<byte[]> appKeyMap;

    /**
     * from mesh configuration
     */
    private int initIvIndex = 0;

    /**
     * unsigned 32-bit integer
     */
    private long ivIndex = 0;

    private int localAddress = 0x7FFF;

    /**
     * direct connected node mesh address
     */
    private int directAddress = 0;

    /**
     * model message transition id
     * All tid in message(if contains) will be valued by this variable
     */
    private AtomicInteger tid = new AtomicInteger(0);

    /**
     * 13 bits
     */
    private static final int SEQ_ZERO_LIMIT = 0x1FFF;

    /**
     * received segmented message buffer by notification
     */
    private SparseArray<SegmentedAccessMessagePDU> receivedSegmentedMessageBuffer = new SparseArray<>();


    private static final int SEQ_AUTH_BUF_CAPACITY = 10;

    /**
     * segment completed auth buffer
     */
    private SparseLongArray completedSeqAuthBuffer = new SparseLongArray();

    /**
     * segment busy auth buffer
     */
    private SparseLongArray busySeqAuthBuffer = new SparseLongArray();

    /**
     * sent segmented message buffer
     */
    private SparseArray<SegmentedAccessMessagePDU> sentSegmentedMessageBuffer = new SparseArray<>();

//    private SparseArray<byte[]> receivedSegmentedMessageBuffer;

    /**
     * last seqAuth in segmented pdu
     * 0: segment idle
     * others: segment busy
     */
    private long lastSeqAuth = 0;

    private int lastSegSrc = 0;

    // if last RX segment packets complete
    private boolean lastSegComplete = true;


    private NetworkingBridge mNetworkingBridge;

    private int mSnoUpdateStep = DEFAULT_SEQUENCE_NUMBER_UPDATE_STEP;

    private Handler mDelayHandler;

    private SegmentAckMessageSentTask mAccessSegCheckTask = new SegmentAckMessageSentTask();

    // waiting for segment ack message
    private SegmentBlockWaitingTask mSegmentBlockWaitingTask = new SegmentBlockWaitingTask();

    private static final int BLOCK_ACK_WAITING_TIMEOUT = 15 * 1000;

    private boolean segmentedBusy = false;

    private Runnable segmentedMessageTimeoutTask = new SegmentedMessageTimeoutTask();

    /**
     * sending message with ack
     * only one reliable message can be sent at one time
     * <p>
     * for reliable message,
     */
    private MeshMessage mSendingReliableMessage;

    private boolean reliableBusy = false;

    // reliable
    private final Object RELIABLE_SEGMENTED_LOCK = new Object();

    private static final int RELIABLE_MESSAGE_TIMEOUT = 960; // 2 * 1000

    private Set<Integer> mResponseMessageBuffer = new LinkedHashSet<>();

    private int proxyFilterInitStep = 0;

    private static final int PROXY_FILTER_INIT_STEP_SET_TYPE = 1;

    private static final int PROXY_FILTER_SET_STEP_ADD_ADR = 2;

    private static final int PROXY_FILTER_INIT_TIMEOUT = 5 * 1000;

    /**
     * networking pud sending prepared queue
     */
    private final Queue<byte[]> mNetworkingQueue = new ConcurrentLinkedQueue<>();

    public static final long NETWORKING_INTERVAL = 320; // 240 ms

    private final Object mNetworkBusyLock = new Object();

    private boolean networkingBusy = false;


    public NetworkingController(HandlerThread handlerThread) {
        this.mDelayHandler = new Handler(handlerThread.getLooper());
        this.appKeyMap = new SparseArray<>();
        this.deviceKeyMap = new SparseArray<>();
    }

    public void setNetworkingBridge(NetworkingBridge networkingBridge) {
        this.mNetworkingBridge = networkingBridge;
    }

    public void setup(MeshConfiguration configuration) {
        this.clear();
        this.initIvIndex = configuration.ivIndex;
        this.ivIndex = initIvIndex & MeshUtils.UNSIGNED_INTEGER_MAX;
        int seqNo = configuration.sequenceNumber;
        this.mSequenceNumber.set(initSequenceNumber(seqNo));
        this.netKeyIndex = configuration.netKeyIndex;
        byte[][] k2Output = Encipher.calculateNetKeyK2(configuration.networkKey);
        this.nid = (byte) (k2Output[0][15] & 0x7F);
        this.encryptionKey = k2Output[1];
        this.privacyKey = k2Output[2];

        this.appKeyMap = configuration.appKeyMap;
        this.deviceKeyMap = configuration.deviceKeyMap;

        this.localAddress = configuration.localAddress;
    }


    public void clear() {
        if (mDelayHandler != null) {
            mDelayHandler.removeCallbacksAndMessages(null);
        }

        this.networkingBusy = false;
        this.segmentedBusy = false;
        this.reliableBusy = false;
        this.mNetworkingQueue.clear();
        this.lastSeqAuth = 0;
        this.lastSegSrc = 0;
        this.directAddress = 0;
        this.lastSegComplete = true;
        this.deviceSequenceNumberMap.clear();
        this.receivedSegmentedMessageBuffer.clear();
        this.sentSegmentedMessageBuffer.clear();
        this.mResponseMessageBuffer.clear();
        this.isIvUpdating = false;
        this.lastSegComplete = true;
    }

    public void addDeviceKey(int unicastAddress, byte[] deviceKey) {
        this.deviceKeyMap.put(unicastAddress, deviceKey);
    }

    public void enableDLE(boolean enable) {
        this.dleEnabled = enable;
        unsegmentedAccessLength = enable ? UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DLE : UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DEFAULT;
        log("enableDLE: " + enable + " -- value : " + unsegmentedAccessLength);
    }

    public int getSegmentAccessLength() {
        return unsegmentedAccessLength;
    }

    public void removeDeviceKey(int unicastAddress) {
        this.deviceKeyMap.remove(unicastAddress);
    }


    private synchronized void saveCompletedSeqAuth(int src, long seqAuth) {
        log(String.format(Locale.getDefault(), "save complete seqAuth src: 0x%04X -- seqAuth: 0x%014X", src, seqAuth));
        this.completedSeqAuthBuffer.put(src, seqAuth);
        /*if (this.completedSeqAuthBuffer.size() > SEQ_AUTH_BUF_CAPACITY) {
            log("remove buffer");
            this.completedSeqAuthBuffer.removeAt(SEQ_AUTH_BUF_CAPACITY);
        }*/
    }

    private boolean isCompleteAuthExists(int src, long seqAuth) {
        return this.completedSeqAuthBuffer.get(src, 0) == seqAuth;
    }

    private synchronized void saveBusySeqAuth(int src, long seqAuth) {
        log(String.format(Locale.getDefault(), "save busy seqAuth src: 0x%04X -- seqAuth: 0x%014X", src, seqAuth));
        this.busySeqAuthBuffer.put(src, seqAuth);
    }

    private boolean isBusyAuthExists(int src, long seqAuth) {
        return this.busySeqAuthBuffer.get(src, 0) == seqAuth;
    }

    /**
     * check SequenceNumber when proxy connected
     * sendIvUpdatingBeacon
     */
    public void checkSequenceNumber(byte[] networkId, byte[] beaconKey) {
        final boolean updatingNeeded = this.mSequenceNumber.get() >= THRESHOLD_SEQUENCE_NUMBER;
        SecureNetworkBeacon networkBeacon = SecureNetworkBeacon.createIvUpdatingBeacon((int) this.ivIndex, networkId, beaconKey, updatingNeeded);
        this.isIvUpdating = updatingNeeded;
        if (isIvUpdating) {
            this.ivIndex += 1;
        }
        log(networkBeacon.toString());
        sendMeshBeaconPdu(networkBeacon);
    }

    private void onIvUpdated(long newIvIndex) {
        if (newIvIndex > initIvIndex) {
            log(String.format(" iv updated to %08X", newIvIndex));
            this.deviceSequenceNumberMap.clear();
            this.mSequenceNumber.set(0);
            if (mNetworkingBridge != null) {
                mNetworkingBridge.onNetworkInfoUpdate(mSequenceNumber.get(), (int) newIvIndex);
            }
        } else {
            log(" iv not updated");
        }
    }

    private void onIvIndexReceived(long remoteIvIndex, boolean updating) {
        log(String.format("iv index received iv: %08X -- updating: %b -- localIv: %08X -- updating: %b ",
                remoteIvIndex,
                updating,
                this.ivIndex,
                this.isIvUpdating));
        // d-value
        long dVal = remoteIvIndex - this.ivIndex;

        if (dVal == 0) {
            // remote node iv update complete
            if (!updating && this.isIvUpdating) {
                this.isIvUpdating = false;
                this.onIvUpdated(remoteIvIndex);
            }
        } else if (dVal > 0) {
            log("larger iv index received");
            if (dVal <= 42) {
                this.isIvUpdating = updating;
                this.ivIndex = remoteIvIndex;

                this.onIvUpdated(updating ? remoteIvIndex - 1 : remoteIvIndex);
            } else {
                log("iv index dVal greater than 42");
            }

        } else {
            log(" smaller iv index received", MeshLogger.LEVEL_WARN);
        }
    }

    private int initSequenceNumber(int sequenceNumber) {
        if (mSnoUpdateStep == 0 || mSnoUpdateStep == 1) return sequenceNumber;
        int initSno = (sequenceNumber / mSnoUpdateStep + 1) * mSnoUpdateStep;
        onSequenceNumberUpdate(initSno);
        log("init sno: " + initSno);
        return initSno;
    }

    private void sendProxyConfigurationMessage(ProxyConfigurationMessage message) {
        byte[] transportPdu = message.toByteArray();
        ProxyConfigurationPDU networkLayerPDU = createProxyConfigurationPdu(transportPdu,
                localAddress, getTransmitIvIndex(), this.mSequenceNumber.get());
        sendProxyNetworkPdu(networkLayerPDU);
    }

    public boolean sendMeshMessage(MeshMessage meshMessage) {

        int dst = meshMessage.getDestinationAddress();
        if (!validateDestinationAddress(dst)) {
            log("invalid dst address: " + String.format("%04X", dst), MeshLogger.LEVEL_WARN);
            return false;
        }

        AccessType accessType = meshMessage.getAccessType();
        byte[] encryptionKey;
        if (accessType == AccessType.APPLICATION) {
            encryptionKey = getAppKey(meshMessage.getAppKeyIndex());
        } else {
            encryptionKey = getDeviceKey(meshMessage.getDestinationAddress());
        }

        if (encryptionKey == null) {
            log("access key not found : " + accessType, MeshLogger.LEVEL_WARN);
            return false;
        }
        meshMessage.setAccessKey(encryptionKey);


        return postMeshMessage(meshMessage, false);
    }


    /**
     * @return if message will be sent
     */
    private boolean postMeshMessage(MeshMessage meshMessage, boolean retry) {
        int dst = meshMessage.getDestinationAddress();
        int src = localAddress;
        int aszmic = meshMessage.getSzmic();
        byte akf = meshMessage.getAccessType().akf;
        byte aid;
        if (meshMessage.getAccessType() == AccessType.APPLICATION) {
            aid = Encipher.k4(meshMessage.getAccessKey());
        } else {
            aid = 0x00;
        }

        int sequenceNumber = mSequenceNumber.get();

        final byte[] params = meshMessage.getParams();
        final int tidPos = meshMessage.getTidPosition();
        if (params != null && tidPos >= 0 && params.length > tidPos) {
            params[tidPos] = retry ? (byte) this.tid.get() : (byte) this.tid.incrementAndGet();
        }

        AccessLayerPDU accessPDU = new AccessLayerPDU(meshMessage.getOpcode(), params);

        byte[] accessPduData = accessPDU.toByteArray();

//        boolean segmented = accessPduData.length > UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH;
        boolean segmented = accessPduData.length > unsegmentedAccessLength;
        meshMessage.setSegmented(segmented);
        if (segmented) {
            synchronized (RELIABLE_SEGMENTED_LOCK) {
                if (segmentedBusy) {
                    log("segment message send err: segmented busy");
                    return false;
                }
            }
        }

        log("post access pdu: " + Arrays.bytesToHexString(accessPDU.toByteArray(), ""));

        int ivIndex = getTransmitIvIndex();

        UpperTransportAccessPDU upperPDU = createUpperTransportAccessPDU(accessPduData,
                meshMessage.getAccessKey(),
                (byte) meshMessage.getSzmic(),
                meshMessage.getAccessType(),
                ivIndex,
                sequenceNumber, src, dst);

        if (upperPDU == null) {
            log("create upper transport pdu err: encrypt err", MeshLogger.LEVEL_WARN);
            return false;
        }
        log("upper transport pdu: " + Arrays.bytesToHexString(upperPDU.getEncryptedPayload(), ""));

        // check message reliable
        final boolean reliable = meshMessage.isReliable();

        // upperPDU.getEncryptedPayload().length <= UNSEGMENTED_TRANSPORT_PAYLOAD_MAX_LENGTH
        //
        /*
            for unsegmented & reliable message, start reliable timeout check immediately,
            for segmented & reliable message, start reliable timeout check when received block ack
         */
        if (!segmented) {
            log("send unsegmented access message");

            if (reliable) {
                if (reliableBusy) {
                    log("unsegmented reliable message send err: busy", MeshLogger.LEVEL_WARN);
                    return false;
                }
                reliableBusy = true;
                mSendingReliableMessage = meshMessage;
                restartReliableMessageTimeoutTask();
            }

            UnsegmentedAccessMessagePDU unsegmentedMessagePDU = createUnsegmentedAccessMessage(upperPDU.getEncryptedPayload(), akf, aid);
            NetworkLayerPDU networkPDU = createNetworkPDU(unsegmentedMessagePDU.toByteArray(),
                    meshMessage.getCtl(), meshMessage.getTtl(), src, dst, ivIndex, sequenceNumber);
            sendNetworkPdu(networkPDU);
        } else {
            synchronized (RELIABLE_SEGMENTED_LOCK) {
                if (reliable) {
                    if (reliableBusy) {
                        log("segmented reliable message send err: busy", MeshLogger.LEVEL_WARN);
                        return false;
                    }
                    reliableBusy = true;
                    mSendingReliableMessage = meshMessage;
//                    restartReliableMessageTimeoutTask(); //
                }
                SparseArray<SegmentedAccessMessagePDU> segmentedAccessMessages = createSegmentedAccessMessage(upperPDU.getEncryptedPayload(), akf, aid, aszmic, sequenceNumber);
                if (segmentedAccessMessages.size() == 0) return false;

                log("send segmented access message");
                List<NetworkLayerPDU> networkLayerPduList = new ArrayList<>();
                for (int i = 0; i < segmentedAccessMessages.size(); i++) {
                    byte[] lowerTransportPdu = segmentedAccessMessages.get(i).toByteArray();
                    NetworkLayerPDU networkPDU = createNetworkPDU(lowerTransportPdu,
                            meshMessage.getCtl(), meshMessage.getTtl(), src, dst, ivIndex, sequenceNumber + i);
                    networkLayerPduList.add(networkPDU);
                }
                if (MeshUtils.validUnicastAddress(dst)) {
                    this.sentSegmentedMessageBuffer = segmentedAccessMessages.clone();
                    startSegmentedMessageTimeoutCheck();
                    startSegmentedBlockAckWaiting(meshMessage.getCtl(), meshMessage.getTtl(), src, dst);
                } else if (reliable) {
                    restartReliableMessageTimeoutTask();
                }
                sendNetworkPduList(networkLayerPduList);
            }
        }
        return true;
    }

    /**
     * proxy filter init steps:
     * 1. set white list
     * 2. add localAddress and 0xFFFF into address array
     */
    public void proxyFilterInit() {
        proxyFilterInitStep = 0;
        mDelayHandler.removeCallbacks(proxyFilterInitTimeoutTask);
        mDelayHandler.postDelayed(proxyFilterInitTimeoutTask, PROXY_FILTER_INIT_TIMEOUT);
        setFilterType(ProxyFilterType.WhiteList);
    }

    private void setFilterType(ProxyFilterType filterType) {
        ProxySetFilterTypeMessage message = new ProxySetFilterTypeMessage(filterType.value);
        sendProxyConfigurationMessage(message);
    }

    private void addFilterAddress(int[] addressArray) {
        ProxyAddAddressMessage addAddressMessage = new ProxyAddAddressMessage(addressArray);
        sendProxyConfigurationMessage(addAddressMessage);
    }

    private boolean validateDestinationAddress(int address) {
        return address != 0;
    }

    /**
     * get app key in map
     *
     * @return app key at index
     */
    private byte[] getAppKey(int appKeyIndex) {
        if (this.appKeyMap == null) return null;
        return this.appKeyMap.get(appKeyIndex);
    }


    /**
     * get device key for config model message when akf==0
     * {@link AccessType#DEVICE}
     *
     * @param unicastAddress node address
     * @return device key
     */
    private byte[] getDeviceKey(int unicastAddress) {
        if (this.deviceKeyMap == null) return null;
        return this.deviceKeyMap.get(unicastAddress);
    }


    private void startSegmentedMessageTimeoutCheck() {
        segmentedBusy = true;
        mDelayHandler.removeCallbacks(segmentedMessageTimeoutTask);
        mDelayHandler.postDelayed(segmentedMessageTimeoutTask, BLOCK_ACK_WAITING_TIMEOUT);
    }

    private void startSegmentedBlockAckWaiting(int ctl, int ttl, int src, int dst) {
        mDelayHandler.removeCallbacks(mSegmentBlockWaitingTask);
        mSegmentBlockWaitingTask.resetParams(ctl, ttl, src, dst);
        mDelayHandler.postDelayed(mSegmentBlockWaitingTask, getSegmentedTimeout(ttl, true));
    }

    /**
     * stop segmented message block acknowledgment waiting
     *
     * @param complete true: when timeout {@link #BLOCK_ACK_WAITING_TIMEOUT}
     *                 or block ack shows all segmented message received
     *                 false: when checking block ack
     */
    private void stopSegmentedBlockAckWaiting(boolean complete, boolean success) {
        log(String.format("stop segmented block waiting, complete - %B success - %B", complete, success));
        mDelayHandler.removeCallbacks(mSegmentBlockWaitingTask);
        if (complete) {
            onSegmentedMessageComplete(success);
        }
    }

    /**
     * segment message sent complete
     *
     * @param success true: received completed block
     *                false: timeout
     */
    private void onSegmentedMessageComplete(boolean success) {
        log("segmented message complete, success? : " + success);
        // clear segment state
        clearSegmentSendingState(success);

        // check reliable state
        if (reliableBusy) {
            /*
            if segmented message sent success, check response after #@link{RELIABLE_MESSAGE_TIMEOUT}
            else if segmented message timeout, retry immediately
             */
            if (success) {
                restartReliableMessageTimeoutTask();
            } else {
                // if segment timeout , no need to resend reliable message
                onReliableMessageComplete(false);
            }
        }
    }

    private void clearSegmentSendingState(boolean success) {
        segmentedBusy = false;
        mDelayHandler.removeCallbacks(segmentedMessageTimeoutTask);
        sentSegmentedMessageBuffer.clear();
        if (mNetworkingBridge != null) {
            mNetworkingBridge.onSegmentMessageComplete(success);
        }
        /*final  MeshMessage meshMessage = mSendingReliableMessage;
        if (meshMessage != null){
            int opcode = meshMessage.getOpcode();

        }*/

    }

    private long getSegmentedTimeout(int ttl, boolean outer) {

        final int relayTimeout = 300;
        final int segmentAckTimeout = 200 + 50 * ttl;
        long timeout;
        if (outer) {
            // send
            int queueSize;
            synchronized (mNetworkingQueue) {
                queueSize = mNetworkingQueue.size();
            }
            timeout = relayTimeout + segmentAckTimeout + queueSize * NETWORKING_INTERVAL;
        } else {
            // receive
            timeout = relayTimeout + segmentAckTimeout;
        }
        log("get segment ack timeout: " + timeout);
        return timeout;
    }

    private long getReliableMessageTimeout() {
        int queueSize;
        synchronized (mNetworkingQueue) {
            queueSize = mNetworkingQueue.size();
        }

        // 960
//        long timeout = 1280 + queueSize * NETWORKING_INTERVAL;
        long timeout = (dleEnabled ? 2560 : 1280) + queueSize * NETWORKING_INTERVAL;
        log("reliable message timeout:" + timeout);
        return timeout;
    }

    private void increaseSequenceNumber() {
        int latestValue = mSequenceNumber.incrementAndGet();
        onSequenceNumberUpdate(latestValue);
    }

    private void sendNetworkPduList(List<NetworkLayerPDU> networkPduList) {
        if (mNetworkingBridge != null) {
            for (NetworkLayerPDU networkLayerPDU : networkPduList) {
                byte[] networkPduPayload = networkLayerPDU.generateEncryptedPayload();
                log("multi network pdu: " + Arrays.bytesToHexString(networkPduPayload, ":"));
                onNetworkingPduPrepared(networkPduPayload, networkLayerPDU.getDst());
            }
        }
    }

    private void sendNetworkPdu(NetworkLayerPDU networkPdu) {
        if (mNetworkingBridge != null) {
            byte[] networkPduPayload = networkPdu.generateEncryptedPayload();
            log("single network pdu: " + Arrays.bytesToHexString(networkPduPayload, ":"));
            onNetworkingPduPrepared(networkPduPayload, networkPdu.getDst());
        }
    }

    private void sendProxyNetworkPdu(ProxyConfigurationPDU networkPdu) {
        if (mNetworkingBridge != null) {
            byte[] networkPduPayload = networkPdu.generateEncryptedPayload();
            log("proxy network pdu: " + Arrays.bytesToHexString(networkPduPayload, ":"));
            mNetworkingBridge.onCommandPrepared(ProxyPDU.TYPE_PROXY_CONFIGURATION, networkPduPayload);
        }
    }

    private void onNetworkingPduPrepared(byte[] payload, int dstAddress) {
        log("networking pud prepared: " + Arrays.bytesToHexString(payload, ":") + " busy?-" + networkingBusy);

        synchronized (mNetworkBusyLock) {
            if (!networkingBusy) {
                boolean directPdu = dstAddress == this.directAddress;
                if (directPdu) {
                    log("networking pdu sending direct ");
                    if (mNetworkingBridge != null) {
                        mNetworkingBridge.onCommandPrepared(ProxyPDU.TYPE_NETWORK_PDU, payload);
                    }
                    return;
                }
            }
        }

        synchronized (mNetworkingQueue) {
            mNetworkingQueue.add(payload);
        }
        synchronized (mNetworkBusyLock) {
            if (!networkingBusy) {
                networkingBusy = true;
                pollNetworkingQueue();
            }
        }
    }


    private void pollNetworkingQueue() {
        byte[] payload;
        synchronized (mNetworkingQueue) {
            payload = mNetworkingQueue.poll();
        }
        if (payload == null) {
            log("networking pud poll: null");
            synchronized (mNetworkBusyLock) {
                networkingBusy = false;
            }
        } else {
            log("networking pud poll: " + Arrays.bytesToHexString(payload, ":"));
            if (mNetworkingBridge != null) {
                mNetworkingBridge.onCommandPrepared(ProxyPDU.TYPE_NETWORK_PDU, payload);
            }
            mDelayHandler.removeCallbacks(networkingSendingTask);
            mDelayHandler.postDelayed(networkingSendingTask, NETWORKING_INTERVAL);
        }
    }

    private Runnable networkingSendingTask = new Runnable() {
        @Override
        public void run() {
            pollNetworkingQueue();
        }
    };

    /**
     * seqNo update by step
     * {@link #mSnoUpdateStep}
     *
     * @param latestSequenceNumber latest sequenceNumber
     */
    private void onSequenceNumberUpdate(int latestSequenceNumber) {
        if (mNetworkingBridge != null) {
            if (mSnoUpdateStep == 0 || latestSequenceNumber % mSnoUpdateStep == 0) {
                mNetworkingBridge.onNetworkInfoUpdate(latestSequenceNumber, (int) this.ivIndex);
            }
        }
    }


    public void parseMeshBeacon(byte[] payload, byte[] networkId, byte[] networkBeaconKey) {
        SecureNetworkBeacon networkBeacon = SecureNetworkBeacon.from(payload);
        // validate beacon data
        if (networkBeacon != null) {
            log("SecureNetworkBeacon received: " + networkBeacon.toString());
            if (networkBeacon.validateAuthValue(networkId, networkBeaconKey)) {
                int ivIndex = networkBeacon.getIvIndex();
                boolean isIvUpdating = networkBeacon.isIvUpdating();
                onIvIndexReceived(ivIndex & MeshUtils.UNSIGNED_INTEGER_MAX, isIvUpdating);
            } else {
                log("network beacon check err");
            }

        } else {
            log("network beacon parse err");
        }
    }

    /**
     * accepted when received networking pdu
     *
     * @param ivi 1-bit
     * @return ivIndex
     */
    private int getAcceptedIvIndex(int ivi) {
        log(String.format("getAcceptedIvIndex : %08X", ivIndex) + " ivi: " + ivi);
        boolean ivChecked = (ivIndex & 0b01) == ivi;
        return ivChecked ? (int) ivIndex : (int) (ivIndex - 1);
    }

    private int getTransmitIvIndex() {
        int re = (int) (!isIvUpdating ? ivIndex : ivIndex - 1);
        log(String.format("getTransmitIvIndex : %08X", re));
        return re;
    }

    private void sendMeshBeaconPdu(MeshBeaconPDU meshBeaconPDU) {
        if (mNetworkingBridge != null) {
            mNetworkingBridge.onCommandPrepared(ProxyPDU.TYPE_MESH_BEACON, meshBeaconPDU.toBytes());
        }
    }

    /**
     * @param payload data payload
     */
    public void parseNetworkPdu(byte[] payload) {

        int ivi = (payload[0] & 0xFF) >> 7;
        int ivIndex = getAcceptedIvIndex(ivi);
        NetworkLayerPDU networkLayerPDU = new NetworkLayerPDU(
                new NetworkLayerPDU.NetworkEncryptionSuite(ivIndex, this.encryptionKey, this.privacyKey, this.nid)
        );
        if (networkLayerPDU.parse(payload)) {
            if (!validateSequenceNumber(networkLayerPDU)) {
                log("network pdu sequence number check err", MeshLogger.LEVEL_WARN);
                return;
            }
            if (networkLayerPDU.getCtl() == MeshMessage.CTL_ACCESS) {
                parseAccessMessage(networkLayerPDU);
            } else {
                parseControlMessage(networkLayerPDU);
            }

        } else {
            log("network layer parse err", MeshLogger.LEVEL_WARN);
        }
    }

    public void parseProxyConfigurationPdu(byte[] payload) {
        int ivi = (payload[0] & 0xFF) >> 7;
        int ivIndex = getAcceptedIvIndex(ivi);
        ProxyConfigurationPDU proxyNetworkPdu = new ProxyConfigurationPDU(
                new NetworkLayerPDU.NetworkEncryptionSuite(ivIndex, this.encryptionKey, this.privacyKey, this.nid)
        );
        if (proxyNetworkPdu.parse(payload)) {
            if (!validateSequenceNumber(proxyNetworkPdu)) {
                log("proxy config pdu sequence number check err", MeshLogger.LEVEL_WARN);
                return;
            }
            log(String.format("proxy network pdu src: %04X dst: %04X", proxyNetworkPdu.getSrc(), proxyNetworkPdu.getDst()));
            onProxyConfigurationNotify(proxyNetworkPdu.getTransportPDU(), proxyNetworkPdu.getSrc());
        }

    }

    private void onProxyConfigurationNotify(byte[] proxyConfigMessage, int src) {
        log("onProxyConfigurationNotify: "
                + Arrays.bytesToHexString(proxyConfigMessage, ":"));
        ProxyFilterStatusMessage proxyFilterStatusMessage = ProxyFilterStatusMessage.fromBytes(proxyConfigMessage);
        if (proxyFilterStatusMessage != null) {

            // target Filter type is whitelist
            if (proxyFilterStatusMessage.getFilterType() == ProxyFilterType.WhiteList.value) {
                if (proxyFilterInitStep < 0) {
                    log("filter init action not started!", MeshLogger.LEVEL_WARN);
                    return;
                }
                this.directAddress = src;
                proxyFilterInitStep++;
                if (proxyFilterInitStep == PROXY_FILTER_INIT_STEP_SET_TYPE) {
                    addFilterAddress(new int[]{localAddress, 0xFFFF});
                } else if (proxyFilterInitStep == PROXY_FILTER_SET_STEP_ADD_ADR) {
                    onProxyInitComplete(true);
                }
            }

        }
    }

    private Runnable proxyFilterInitTimeoutTask = new Runnable() {
        @Override
        public void run() {
            log("filter init timeout");
            onProxyInitComplete(false);
        }
    };

    private void onProxyInitComplete(boolean success) {
        proxyFilterInitStep = -1;
        if (success) {
            mDelayHandler.removeCallbacks(proxyFilterInitTimeoutTask);
        }
        if (mNetworkingBridge != null) {
            mNetworkingBridge.onProxyInitComplete(success, this.directAddress);
        }
    }

    private boolean validateSequenceNumber(NetworkLayerPDU networkLayerPDU) {
        int src = networkLayerPDU.getSrc();
        int pduSequenceNumber = networkLayerPDU.getSeq();
        int deviceSequenceNumber = this.deviceSequenceNumberMap.get(src, -1);
        boolean pass = true;
        if (deviceSequenceNumber == -1) {
            this.deviceSequenceNumberMap.put(src, pduSequenceNumber);
        } else {
            if (pduSequenceNumber > deviceSequenceNumber) {
                this.deviceSequenceNumberMap.put(src, pduSequenceNumber);
            } else {
                log(String.format("validate sequence number error  src: %04X -- pdu-sno: %06X -- dev-sno: %06X", src, pduSequenceNumber, deviceSequenceNumber));
                pass = false;
            }
        }
        return pass;
    }

    private void parseControlMessage(NetworkLayerPDU networkLayerPDU) {
        byte[] lowerTransportPduData = networkLayerPDU.getTransportPDU();
        int segOpcode = lowerTransportPduData[0] & 0xFF;
        int seg = segOpcode >> 7;
        int opcode = segOpcode & 0x7F;
        log("parse control message  seg:" + seg + " -- opcode:" + opcode);
        if (seg == LowerTransportPDU.SEG_TYPE_UNSEGMENTED) {
            if (opcode == TransportControlMessagePDU.CONTROL_MESSAGE_OPCODE_SEG_ACK) {
                SegmentAcknowledgmentMessage segmentAckMessage = new SegmentAcknowledgmentMessage();
                if (segmentAckMessage.parse(lowerTransportPduData)) {
                    onSegmentAckMessageReceived(segmentAckMessage);
                }
            } else if (opcode == TransportControlMessagePDU.CONTROL_MESSAGE_OPCODE_HEARTBEAT) {
                onHeartbeatNotify(networkLayerPDU.getSrc(), networkLayerPDU.getDst(), lowerTransportPduData);
            }
        }
    }


    private void onHeartbeatNotify(int src, int dst, byte[] transportPdu) {
        log("on heart beat notify: " + Arrays.bytesToHexString(transportPdu, ":"));
        if (mNetworkingBridge != null) {
            mNetworkingBridge.onHeartbeatMessageReceived(src, dst, transportPdu);
        }
    }

    /**
     * when receive Segment Acknowledgment Message
     * check if is segmented message sending,
     * and check blockAck value , if segmented message missing, resend
     */
    private void onSegmentAckMessageReceived(SegmentAcknowledgmentMessage segmentAckMessage) {
        log("onSegmentAckMessageReceived: " + segmentAckMessage.toString());
        if (segmentedBusy) {
            resendSegmentedMessages(segmentAckMessage.getSeqZero(), segmentAckMessage.getBlockAck());
        } else {
            log("Segment Acknowledgment Message err: segmented messages not sending", MeshLogger.LEVEL_WARN);
        }
    }

    /**
     * @param seqZero  valued by block ack message or -1 when not received any block ack message;
     *                 so if seqZero is -1, resend all segmented messages
     * @param blockAck valued by block ack message showing missing segmented messages or 0 when not received any block ack message
     */
    private void resendSegmentedMessages(int seqZero, int blockAck) {
        final SparseArray<SegmentedAccessMessagePDU> messageBuffer = sentSegmentedMessageBuffer.clone();
        log("resendSegmentedMessages: seqZero: " + seqZero
                + " block ack: " + blockAck
                + " buffer size: " + messageBuffer.size());
        if (messageBuffer.size() != 0) {
            SegmentedAccessMessagePDU message0 = messageBuffer.get(messageBuffer.keyAt(0));
            int messageSeqZero = message0.getSeqZero();

            if (seqZero != -1) {
                if (seqZero == messageSeqZero) {
                    stopSegmentedBlockAckWaiting(false, false);
                } else {
                    return;
                }
            }


            int ctl = mSegmentBlockWaitingTask.ctl;
            int ttl = mSegmentBlockWaitingTask.ttl;
            int src = mSegmentBlockWaitingTask.src;
            int dst = mSegmentBlockWaitingTask.dst;

//            int blockAck = segmentAckMessage.getBlockAck();
            int messageSegN = message0.getSegN();
            boolean messageReceived;
            SegmentedAccessMessagePDU messagePDU;
            int ivIndex = getTransmitIvIndex();
            int sequenceNumber = mSequenceNumber.get();
            int addedValue = 0;
            List<NetworkLayerPDU> networkLayerPduList = new ArrayList<>();
            for (int i = 0; i <= messageSegN; i++) {
                messageReceived = (blockAck & MeshUtils.bit(i)) != 0;
                if (!messageReceived) {
                    // message miss
                    messagePDU = messageBuffer.get(i);
                    byte[] lowerTransportPdu = messagePDU.toByteArray();
                    log("resend segmented message: seqZero:" + messagePDU.getSeqZero() + " -- segO:" + messagePDU.getSegO());
                    NetworkLayerPDU networkPDU = createNetworkPDU(lowerTransportPdu,
                            ctl, ttl, src, dst, ivIndex, sequenceNumber + addedValue);
                    addedValue++;
                    networkLayerPduList.add(networkPDU);
                }
            }

            if (networkLayerPduList.size() == 0) {
                // all received
                stopSegmentedBlockAckWaiting(true, true);
            } else {
                startSegmentedBlockAckWaiting(ctl, ttl, src, dst);
                sendNetworkPduList(networkLayerPduList);
            }

        }


    }


    /**
     * parse lower transport pdu
     */
    private void parseAccessMessage(NetworkLayerPDU networkLayerPDU) {
        log("parse access message");
        int src = networkLayerPDU.getSrc();
        int dst = networkLayerPDU.getDst();

        if (MeshUtils.validUnicastAddress(dst)) {
            if (dst != localAddress) {
                return;
            }
        }

        byte[] lowerTransportData = networkLayerPDU.getTransportPDU();

        byte lowerTransportHeader = lowerTransportData[0];
        int seg = (lowerTransportHeader >> 7) & 0b01;
        AccessLayerPDU accessPDU;
        if (seg == 1) {
            log("parse segmented access message");

            /*
             * tick refresh if received segment busy
             */
            /*if (reliableBusy) {
                log("refresh reliable tick because of segment network pdu received");
                restartReliableMessageTimeoutTask();
            }*/
            accessPDU = parseSegmentedAccessMessage(networkLayerPDU);

        } else {
            log("parse unsegmented access message");
            accessPDU = parseUnsegmentedAccessMessage(networkLayerPDU);
        }

        if (accessPDU != null) {
            onAccessPduReceived(src, dst, accessPDU);
        }
    }


    /**
     * refresh reliable message status, then invoke message callback
     */
    private void onAccessPduReceived(int src, int dst, AccessLayerPDU accessPDU) {

        log(String.format("access pdu received at 0x%04X: opcode -- 0x%04X", src, accessPDU.opcode)
                + " params -- " + Arrays.bytesToHexString(accessPDU.params, ""));
        // check reliable message state
        updateReliableMessage(src, accessPDU);
        if (mNetworkingBridge != null) {
            mNetworkingBridge.onMeshMessageReceived(src, dst, accessPDU.opcode, accessPDU.params);
        }
    }

    private void updateReliableMessage(int src, AccessLayerPDU accessLayerPDU) {
        if (!reliableBusy) return;
        if (mSendingReliableMessage != null && mSendingReliableMessage.getResponseOpcode() == accessLayerPDU.opcode) {
            mResponseMessageBuffer.add(src);
            if (mResponseMessageBuffer.size() >= mSendingReliableMessage.getResponseMax()) {

                onReliableMessageComplete(true);
            }
        }
    }

    /**
     * reliable command complete
     *
     * @param success if command response received
     */
    private void onReliableMessageComplete(boolean success) {
        mDelayHandler.removeCallbacks(reliableMessageTimeoutTask);
        int opcode = mSendingReliableMessage.getOpcode();
        int rspMax = mSendingReliableMessage.getResponseMax();
        int rspCount = mResponseMessageBuffer.size();
        log(String.format("Reliable Message Complete: %06X success?: %b", opcode, success));
        mResponseMessageBuffer.clear();
        synchronized (RELIABLE_SEGMENTED_LOCK) {
            reliableBusy = false;
            if (success) {
                if (segmentedBusy && mSendingReliableMessage.isSegmented()) {
                    segmentedBusy = false;
                    stopSegmentedBlockAckWaiting(true, true);
//                    mDelayHandler.removeCallbacks(mSegmentBlockWaitingTask);
                }
            }
        }
        if (mNetworkingBridge != null) {
            mNetworkingBridge.onReliableMessageComplete(success, opcode, rspMax, rspCount);
        }
    }

    /**
     * start or refresh tick
     */
    private void restartReliableMessageTimeoutTask() {
        log("restart reliable message timeout task, immediate");
        mDelayHandler.removeCallbacks(reliableMessageTimeoutTask);
        mDelayHandler.postDelayed(reliableMessageTimeoutTask, getReliableMessageTimeout());
    }

    private Runnable reliableMessageTimeoutTask = new Runnable() {
        @Override
        public void run() {
            final MeshMessage meshMessage = mSendingReliableMessage;
            if (meshMessage != null) {
                log(String.format(Locale.getDefault(), "reliable message retry segmentRxComplete? %B retryCnt: %d %s opcode: %06X", lastSegComplete, meshMessage.getRetryCnt(), meshMessage.getClass().getSimpleName(), meshMessage.getOpcode()));
                if (lastSegComplete) {
                    if (meshMessage.getRetryCnt() <= 0) {
                        onReliableMessageComplete(false);
                    } else {
                        // resend mesh message
                        meshMessage.setRetryCnt(meshMessage.getRetryCnt() - 1);
                        synchronized (RELIABLE_SEGMENTED_LOCK) {
                            reliableBusy = false;
                            if (segmentedBusy && meshMessage.isSegmented()) {
                                stopSegmentedBlockAckWaiting(true, false);
                            }
                        }
                        postMeshMessage(meshMessage, true);
                    }
                } else {
                    // receiving rx segment packet
                    restartReliableMessageTimeoutTask();
                }


            }
        }
    };


    // parse unsegmented access message lower transport PDU
    private AccessLayerPDU parseUnsegmentedAccessMessage(NetworkLayerPDU networkLayerPDU) {
        byte[] lowerTransportData = networkLayerPDU.getTransportPDU();
        byte header = lowerTransportData[0]; //Lower transport pdu starts here
        int akf = (header >> 6) & 0x01;

        int ivIndex = networkLayerPDU.encryptionSuite.ivIndex;

        UnsegmentedAccessMessagePDU unsegmentedAccessMessagePDU = new UnsegmentedAccessMessagePDU();
        if (unsegmentedAccessMessagePDU.parse(networkLayerPDU)) {

            UpperTransportAccessPDU.UpperTransportEncryptionSuite upperTransportEncryptionSuite;
            if (AccessType.DEVICE.akf == akf) {
                upperTransportEncryptionSuite = new UpperTransportAccessPDU.UpperTransportEncryptionSuite(getDeviceKey(networkLayerPDU.getSrc()), ivIndex);
            } else {
                List<byte[]> appKeyList = getAppKeyList();
                upperTransportEncryptionSuite = new UpperTransportAccessPDU.UpperTransportEncryptionSuite(appKeyList, ivIndex);
            }

            UpperTransportAccessPDU upperTransportAccessPDU = new UpperTransportAccessPDU(upperTransportEncryptionSuite);
            boolean decRe = upperTransportAccessPDU.parseAndDecryptUnsegmentedMessage(unsegmentedAccessMessagePDU, networkLayerPDU.getSeq(), networkLayerPDU.getSrc(), networkLayerPDU.getDst());
            if (decRe) {
                return AccessLayerPDU.parse(upperTransportAccessPDU.getDecryptedPayload());
            } else {
                log("unsegmented access message parse err", MeshLogger.LEVEL_WARN);
            }
        }
        return null;
    }

    private List<byte[]> getAppKeyList() {
        if (this.appKeyMap != null && this.appKeyMap.size() != 0) {
            List<byte[]> appKeyList = new ArrayList<>();
            for (int i = 0; i < appKeyMap.size(); i++) {
                appKeyList.add(appKeyMap.get(appKeyMap.keyAt(i)));
            }
            return appKeyList;
        }
        return null;
    }

    private void checkSegmentBlock(boolean immediate, int ttl, int src) {
        if (immediate) {
            stopSegmentTimeoutTask();
        } else {
            restartSegmentTimeoutTask();
        }
        mDelayHandler.removeCallbacks(mAccessSegCheckTask);
        long timeout = immediate ? 0 : getSegmentedTimeout(ttl, false);
        mAccessSegCheckTask.src = src;
        mAccessSegCheckTask.ttl = ttl;
        log("check segment block: immediate-" + immediate + " ttl-" + ttl + " src-" + src + " timeout-" + timeout);
        mDelayHandler.postDelayed(mAccessSegCheckTask, timeout);
    }

    private void stopSegmentBlockAckTask() {
        mDelayHandler.removeCallbacks(mAccessSegCheckTask);
    }


    private void sendSegmentBlockAck(int src, int ttl) {
        log("send segment block ack:" + src);
        final SparseArray<SegmentedAccessMessagePDU> messages = receivedSegmentedMessageBuffer.clone();
        if (messages.size() > 0) {
//            int segN = -1;
            int seqZero = -1;
            int blockAck = 0;
            int segO;
            int segN = -1;
            SegmentedAccessMessagePDU message;
            for (int i = 0; i < messages.size(); i++) {
                segO = messages.keyAt(i);
                message = messages.get(segO);
                if (segN == -1) {
                    segN = message.getSegN();
                }
                if (seqZero == -1) {
                    seqZero = message.getSeqZero();
                }
                blockAck |= (1 << segO);
            }

            SegmentAcknowledgmentMessage segmentAckMessage = new SegmentAcknowledgmentMessage(seqZero, blockAck);
            sendSegmentAckMessage(segmentAckMessage, src);

            boolean complete = messages.size() == (segN + 1);
            if (!complete) {
                mDelayHandler.removeCallbacks(mAccessSegCheckTask);
                long timeout = getSegmentedTimeout(ttl, false);
                mDelayHandler.postDelayed(mAccessSegCheckTask, timeout);
            }
        }
    }

    /**
     * send segment busy
     */
    private void sendSegmentBlockBusyAck(int src, int seqZero, long seqAuth) {
        log("send segment block busy ack:" + src);
        saveBusySeqAuth(src, seqAuth);
        SegmentAcknowledgmentMessage segmentAckMessage = new SegmentAcknowledgmentMessage(seqZero, 0);
        sendSegmentAckMessage(segmentAckMessage, src);
    }

    private void sendSegmentAckMessage(SegmentAcknowledgmentMessage segmentAcknowledgmentMessage, int dst) {
        log("send segment ack: " + segmentAcknowledgmentMessage.toString());
        sendUnsegmentedControlMessage(segmentAcknowledgmentMessage, dst);
    }

    private void sendUnsegmentedControlMessage(UnsegmentedControlMessagePDU controlMessagePDU, int dst) {
        byte[] data = controlMessagePDU.toByteArray();
        log("send control message: " + Arrays.bytesToHexString(data, ""));
        int ctl = MeshMessage.CTL_CONTROL;
        int ttl = 5;
        int src = localAddress;
        int ivIndex = getTransmitIvIndex();
        NetworkLayerPDU networkPDU = createNetworkPDU(data, ctl, ttl, src, dst, ivIndex, mSequenceNumber.get());
        sendNetworkPdu(networkPDU);
    }

    /**
     * not receive any segment with current segAuth
     */
    private static final long SEG_TIMEOUT = 10 * 1000;
    private Runnable segmentTimeoutTask = new Runnable() {
        @Override
        public void run() {
            stopSegmentBlockAckTask();
            log(String.format(Locale.getDefault(), "segment timeout : lastSeqAuth: 0x%014X -- src: %02d",
                    lastSeqAuth,
                    lastSegSrc));
            lastSegComplete = true;
            lastSegSrc = 0;
            lastSeqAuth = 0;
        }
    };

    private void restartSegmentTimeoutTask() {
        mDelayHandler.removeCallbacks(segmentTimeoutTask);
        mDelayHandler.postDelayed(segmentTimeoutTask, SEG_TIMEOUT);
    }

    private void stopSegmentTimeoutTask() {
        mDelayHandler.removeCallbacks(segmentTimeoutTask);
    }

    private void sendSegmentCompleteBlockAck(int src, int segN, int seqZero) {
        int blockAck = 0;
        for (int i = 0; i < segN + 1; i++) {
            blockAck |= (1 << i);
        }
        SegmentAcknowledgmentMessage segmentAckMessage = new SegmentAcknowledgmentMessage(seqZero, blockAck);
        sendSegmentAckMessage(segmentAckMessage, src);
    }

    /**
     * parse segmented access message
     * check auth
     */
    private AccessLayerPDU parseSegmentedAccessMessage(NetworkLayerPDU networkLayerPDU) {
        SegmentedAccessMessagePDU message = new SegmentedAccessMessagePDU();
        message.parse(networkLayerPDU);
        final int src = networkLayerPDU.getSrc();
        int ttl = networkLayerPDU.getTtl() & 0xFF;
        int sequenceNumber = networkLayerPDU.getSeq();

        int seqLowerBitValue = sequenceNumber & SEQ_ZERO_LIMIT;

        int seqZero = message.getSeqZero();

        int seqHigherBitValue;
        if (seqLowerBitValue < seqZero) {
            seqHigherBitValue = (sequenceNumber - (SEQ_ZERO_LIMIT + 1)) & 0xFFE000;
        } else {
            seqHigherBitValue = sequenceNumber & 0xFFE000;
        }

        // sequence number of first segmented message
        int transportSeqNo = seqHigherBitValue | seqZero;
        int ivIndex = networkLayerPDU.encryptionSuite.ivIndex;
        // seq auth:   ivIndex(32bits) | seqNo(11bits) | seqZero(13bits)
        // 0x7FFFFFFFL remove highest bit
        long seqAuth = (transportSeqNo & 0xFFFFFFL) | ((ivIndex & 0x7FFFFFFFL) << 24);

        int segO = message.getSegO();
        int segN = message.getSegN();

        log(String.format(Locale.getDefault(), "lastComplete? :%B -- seqAuth: 0x%014X -- lastSeqAuth: 0x%014X -- src: 0x%04X -- lastSrc: 0x%04X -- seg0: %02d -- segN: %02d",
                lastSegComplete,
                seqAuth,
                lastSeqAuth,
                src,
                lastSegSrc,
                segO,
                segN));

        if (isBusyAuthExists(src, seqAuth)) {
            log("busy auth exists");
            sendSegmentBlockBusyAck(src, seqZero, seqAuth);
            return null;
        }

        if (isCompleteAuthExists(src, seqAuth)) {
            log("complete auth exists");
            sendSegmentCompleteBlockAck(src, segN, seqZero);
            return null;
        }

        AccessLayerPDU accessPDU = null;

        if (seqAuth != lastSeqAuth || lastSegSrc != src) {
            if (lastSegComplete) {
                log("last segment complete");
                // save last seqAuth
                saveCompletedSeqAuth(lastSegSrc, lastSeqAuth);
                lastSegComplete = false;
                // new segment message
                lastSeqAuth = seqAuth;
                lastSegSrc = src;
                receivedSegmentedMessageBuffer.clear();
            } else {
                sendSegmentBlockBusyAck(src, seqZero, seqAuth);
                return null;
            }
        }

       /* if (seqAuth != lastSeqAuth || lastSegSrc != src) {
            if (lastSegComplete) {
                log("last segment complete");
                // save last seqAuth
                saveCompletedSeqAuth(lastSegSrc, lastSeqAuth);
                lastSegComplete = false;
                // new segment message
                lastSeqAuth = seqAuth;
                lastSegSrc = src;
                receivedSegmentedMessageBuffer.clear();
                receivedSegmentedMessageBuffer.put(segO, message);
                checkSegmentBlock(false, ttl, src);
            } else {
                sendSegmentBlockBusyAck(src, seqZero, seqAuth);
            }
        } else*/
        {
            receivedSegmentedMessageBuffer.put(segO, message);

            int messageCnt = receivedSegmentedMessageBuffer.size();
            log("received segment message count: " + messageCnt);

            if (messageCnt != segN + 1) {
                lastSeqAuth = seqAuth;
                checkSegmentBlock(false, ttl, src);
            } else {
                lastSegComplete = true;
                checkSegmentBlock(true, ttl, src);
                if (isCompleteAuthExists(src, seqAuth)) {
                    log(" seqAuth already received: " + seqAuth);
                    lastSeqAuth = 0;
                    return null;
                }
                UpperTransportAccessPDU.UpperTransportEncryptionSuite encryptionSuite;
                int akf = message.getAkf();
                if (akf == AccessType.APPLICATION.akf) {
                    encryptionSuite = new UpperTransportAccessPDU.UpperTransportEncryptionSuite(getAppKeyList(), ivIndex);
                } else {
                    byte[] deviceKey = getDeviceKey(src);
                    if (deviceKey == null) {
                        log("Device key not found when decrypt segmented access message", MeshLogger.LEVEL_WARN);
                        return null;
                    }
                    encryptionSuite = new UpperTransportAccessPDU.UpperTransportEncryptionSuite(deviceKey, ivIndex);
                }

                UpperTransportAccessPDU upperTransportAccessPDU = new UpperTransportAccessPDU(encryptionSuite);
                upperTransportAccessPDU.parseAndDecryptSegmentedMessage(receivedSegmentedMessageBuffer.clone(), transportSeqNo, src, networkLayerPDU.getDst());

                byte[] completeTransportPdu = upperTransportAccessPDU.getDecryptedPayload();

                log("decrypted upper: " + Arrays.bytesToHexString(completeTransportPdu, ""));
                if (completeTransportPdu != null) {
                    accessPDU = AccessLayerPDU.parse(completeTransportPdu);
                } else {
                    log("upper pdu decryption error: ", MeshLogger.LEVEL_WARN);
                }
            }
        }
        return accessPDU;
    }


    private UpperTransportAccessPDU createUpperTransportAccessPDU(byte[] accessPDU, byte[] key, byte szmic, AccessType accessType, int ivIndex, int seqNo, int src, int dst) {

        UpperTransportAccessPDU.UpperTransportEncryptionSuite encryptionSuite;


        if (accessType == AccessType.APPLICATION) {
            List<byte[]> appKeyList = new ArrayList<>();
            appKeyList.add(key);
            encryptionSuite = new UpperTransportAccessPDU.UpperTransportEncryptionSuite(appKeyList, ivIndex);
        } else {
            encryptionSuite = new UpperTransportAccessPDU.UpperTransportEncryptionSuite(key, ivIndex);
        }
        UpperTransportAccessPDU upperTransportAccessPDU =
                new UpperTransportAccessPDU(encryptionSuite);
        if (upperTransportAccessPDU.encrypt(accessPDU, szmic, accessType, seqNo, src, dst)) {
            return upperTransportAccessPDU;
        } else {
            return null;
        }


    }


    /*private SparseArray<LowerTransportPDU> createLowerTransportPDU(byte[] upperTransportPDU, byte akf, byte aid, int aszmic, int seqNo) {
        SparseArray<LowerTransportPDU> lowerTransportPduMap;
        if (upperTransportPDU.length <= UNSEGMENTED_TRANSPORT_PAYLOAD_MAX_LENGTH) {
            LowerTransportPDU lowerTransportPDU = createUnsegmentedAccessMessage(upperTransportPDU, akf, aid);
            lowerTransportPduMap = new SparseArray<>();
            lowerTransportPduMap.put(0, lowerTransportPDU);
        } else {
            lowerTransportPduMap = createSegmentedAccessMessage(upperTransportPDU, akf, aid, aszmic, seqNo);
        }
        return lowerTransportPduMap;
    }*/

    private SparseArray<SegmentedAccessMessagePDU> createSegmentedAccessMessage(byte[] encryptedUpperTransportPDU, byte akf, byte aid, int aszmic, int sequenceNumber) {

        final int segmentedAccessLen = unsegmentedAccessLength + 1;
        byte[] seqNoBuffer = MeshUtils.integer2Bytes(sequenceNumber, 3, ByteOrder.BIG_ENDIAN);
        // 13 lowest bits
        int seqZero = ((seqNoBuffer[1] & 0x1F) << 8) | (seqNoBuffer[2] & 0xFF);

        // segment pdu number
        int segNum = (int) Math.ceil(((double) encryptedUpperTransportPDU.length) / segmentedAccessLen); // SEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH
        int segN = segNum - 1; // index from 0
        log("create segmented access message: seqZero - " + seqZero + " segN - " + segN);

        SparseArray<SegmentedAccessMessagePDU> lowerTransportPDUArray = new SparseArray<>();
        int offset = 0;
        int segmentedLength;
        SegmentedAccessMessagePDU lowerTransportPDU;
        for (int segOffset = 0; segOffset < segNum; segOffset++) {
            segmentedLength = Math.min(encryptedUpperTransportPDU.length - offset, segmentedAccessLen);
            lowerTransportPDU = new SegmentedAccessMessagePDU();
            lowerTransportPDU.setAkf(akf);
            lowerTransportPDU.setAid(aid);
            lowerTransportPDU.setSzmic(aszmic);
            lowerTransportPDU.setSeqZero(seqZero);
            lowerTransportPDU.setSegO(segOffset);
            lowerTransportPDU.setSegN(segN);
            lowerTransportPDU.setSegmentM(ByteBuffer.allocate(segmentedLength).put(encryptedUpperTransportPDU, offset, segmentedLength).array());
            offset += segmentedLength;
            lowerTransportPDUArray.put(segOffset, lowerTransportPDU);

        }
        return lowerTransportPDUArray;
    }


    private UnsegmentedAccessMessagePDU createUnsegmentedAccessMessage(byte[] upperTransportPDU, byte akf, byte aid) {
        return new UnsegmentedAccessMessagePDU(akf, aid, upperTransportPDU);
    }

    private NetworkLayerPDU createNetworkPDU(byte[] transportPdu,
                                             int ctl, int ttl, int src, int dst, int ivIndex, int sequenceNumber) {
        NetworkLayerPDU networkLayerPDU = new NetworkLayerPDU(
                new NetworkLayerPDU.NetworkEncryptionSuite(ivIndex, this.encryptionKey, this.privacyKey, this.nid)
        );
        networkLayerPDU.setIvi((byte) (ivIndex & 0x01));
        networkLayerPDU.setNid(this.nid);
        networkLayerPDU.setCtl((byte) ctl);
        networkLayerPDU.setTtl((byte) ttl);
        networkLayerPDU.setSeq(sequenceNumber);
        networkLayerPDU.setSrc(src);
        networkLayerPDU.setDst(dst);
        networkLayerPDU.setTransportPDU(transportPdu);

        // for every network pdu , sequence number should increase
        increaseSequenceNumber();
        return networkLayerPDU;
    }

    private ProxyConfigurationPDU createProxyConfigurationPdu(byte[] transportPdu, int src, int ivIndex, int sequenceNumber) {
        ProxyConfigurationPDU networkLayerPDU = new ProxyConfigurationPDU(
                new NetworkLayerPDU.NetworkEncryptionSuite(ivIndex, this.encryptionKey, this.privacyKey, this.nid)
        );
        networkLayerPDU.setIvi((byte) (ivIndex & 0x01));
        networkLayerPDU.setNid(this.nid);
        networkLayerPDU.setCtl(ProxyConfigurationPDU.ctl);
        networkLayerPDU.setTtl(ProxyConfigurationPDU.ttl);
        networkLayerPDU.setSeq(sequenceNumber);
        networkLayerPDU.setSrc(src);
        networkLayerPDU.setDst(ProxyConfigurationPDU.dst);
        networkLayerPDU.setTransportPDU(transportPdu);

        // for every network pdu , sequence number should increase
        increaseSequenceNumber();
        return networkLayerPDU;
    }

    private class SegmentAckMessageSentTask implements Runnable {
        private int src;
        private int ttl;

        @Override
        public void run() {
            sendSegmentBlockAck(src, ttl);
        }
    }

    private class SegmentedMessageTimeoutTask implements Runnable {
        @Override
        public void run() {
            log("segmented message timeout");
            stopSegmentedBlockAckWaiting(true, false);
        }
    }

    private class SegmentBlockWaitingTask implements Runnable {
        private int ctl;
        private int ttl;
        private int src;
        private int dst;

        public void resetParams(int ctl, int ttl, int src, int dst) {
            this.ctl = ctl;
            this.ttl = ttl;
            this.src = src;
            this.dst = dst;
        }

        @Override
        public void run() {
            resendSegmentedMessages(-1, 0);
        }
    }


    private void log(String logMessage) {
        log(logMessage, MeshLogger.LEVEL_DEBUG);
    }

    private void log(String logMessage, int level) {
        MeshLogger.log(logMessage, LOG_TAG, level);
    }
}
