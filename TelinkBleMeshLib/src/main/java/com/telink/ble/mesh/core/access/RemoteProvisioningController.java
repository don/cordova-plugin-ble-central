/********************************************************************************************************
 * @file     RemoteProvisioningController.java 
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
package com.telink.ble.mesh.core.access;

import android.os.Handler;
import android.os.HandlerThread;

import com.telink.ble.mesh.core.message.MeshMessage;
import com.telink.ble.mesh.core.message.NotificationMessage;
import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.rp.LinkCloseMessage;
import com.telink.ble.mesh.core.message.rp.LinkOpenMessage;
import com.telink.ble.mesh.core.message.rp.LinkStatusMessage;
import com.telink.ble.mesh.core.message.rp.ProvisioningPDUOutboundReportMessage;
import com.telink.ble.mesh.core.message.rp.ProvisioningPDUReportMessage;
import com.telink.ble.mesh.core.message.rp.ProvisioningPduSendMessage;
import com.telink.ble.mesh.core.provisioning.ProvisioningBridge;
import com.telink.ble.mesh.core.provisioning.ProvisioningController;
import com.telink.ble.mesh.core.proxy.ProxyPDU;
import com.telink.ble.mesh.entity.RemoteProvisioningDevice;
import com.telink.ble.mesh.util.Arrays;
import com.telink.ble.mesh.util.MeshLogger;

/**
 * Mesh remote provision
 * Created by kee on 2019/9/26.
 * retransmit provisioning pdu when timeout
 * cache provisioning pdu when last pdu transmitting
 */

public class RemoteProvisioningController implements ProvisioningBridge {
    private final String LOG_TAG = "RemotePv";

    public static final int STATE_INIT = 0x00;

    public static final int STATE_LINK_OPENING = 0x01;

    public static final int STATE_PROVISIONING = 0x02;

    public static final int STATE_PROVISION_SUCCESS = 0x03;

    public static final int STATE_PROVISION_FAIL = 0x04;

    public static final int STATE_LINK_CLOSING = 0x05;

    private int state;

    private ProvisioningController provisioningController;
    private RemoteProvisioningDevice provisioningDevice;

    private AccessBridge accessBridge;

//    private int appKeyIndex;

    private static final int OUTBOUND_INIT_VALUE = 1;

    private int outboundNumber = OUTBOUND_INIT_VALUE;

    private int inboundPDUNumber = 0;

    /**
     * waiting for outbound report when provisioning pdu sent
     */
    private boolean outboundReportWaiting = false;

    private final Object WAITING_LOCK = new Object();

    // transmitting provisioning pdu, this may be retransmit if outbound report not received when timeout
    private byte[] cachePdu = null;

    private byte[] transmittingPdu = null;

    private boolean provisionSuccess = false;

    private Handler delayHandler;

    private static final long OUTBOUND_WAITING_TIMEOUT = 500;

    public RemoteProvisioningController(HandlerThread handlerThread) {
        delayHandler = new Handler(handlerThread.getLooper());
    }

    /**
     * after provisioningDataPdu sent， waiting for ProvisioningPDUOutboundReport status
     */
    public void register(AccessBridge accessBridge) {
        this.accessBridge = accessBridge;
    }

    public void begin(ProvisioningController provisioningController, RemoteProvisioningDevice remoteProvisioningDevice) {
        log(String.format("remote provisioning begin: server -- %04X  uuid -- %s",
                remoteProvisioningDevice.getServerAddress(),
                Arrays.bytesToHexString(remoteProvisioningDevice.getUuid())));
        this.outboundNumber = OUTBOUND_INIT_VALUE;
        this.inboundPDUNumber = -1;
        this.cachePdu = null;
        this.outboundReportWaiting = false;
        this.provisionSuccess = false;
        state = STATE_INIT;
        this.provisioningController = provisioningController;
        this.provisioningDevice = remoteProvisioningDevice;
        linkOpen();
    }

    public void clear() {
        this.state = STATE_INIT;
        this.cachePdu = null;
        this.transmittingPdu = null;
        this.provisioningController = null;
        if (delayHandler != null) {
            delayHandler.removeCallbacksAndMessages(null);
        }
    }

    public RemoteProvisioningDevice getProvisioningDevice() {
        return provisioningDevice;
    }

    private void startProvisioningFlow() {
        this.state = STATE_PROVISIONING;
        if (provisioningController != null) {
            provisioningController.setProvisioningBridge(this);
            provisioningController.begin(this.provisioningDevice);
        }
    }


    /**
     * rsp link status
     */
    private void linkOpen() {
        int serverAddress = provisioningDevice.getServerAddress();
        byte[] uuid = provisioningDevice.getUuid();
        MeshMessage linkOpenMessage = LinkOpenMessage.getSimple(serverAddress, 1, uuid);
        linkOpenMessage.setRetryCnt(8);
        this.state = STATE_LINK_OPENING;
        this.onMeshMessagePrepared(linkOpenMessage);
    }

    private void linkClose(boolean success) {
        this.state = STATE_LINK_CLOSING;
        int serverAddress = provisioningDevice.getServerAddress();
        byte reason = success ? LinkCloseMessage.REASON_SUCCESS : LinkCloseMessage.REASON_FAIL;
        LinkCloseMessage linkCloseMessage = LinkCloseMessage.getSimple(serverAddress, 1, reason);
        this.onMeshMessagePrepared(linkCloseMessage);
    }

    private void onLinkStatus(LinkStatusMessage linkStatusMessage) {
        log("link status : " + linkStatusMessage.toString());
        if (state == STATE_LINK_OPENING) {
            startProvisioningFlow();
        } else if (state == STATE_PROVISIONING) {
            log("link status when provisioning");
        } else if (state == STATE_LINK_CLOSING) {
            this.state = provisionSuccess ? STATE_PROVISION_SUCCESS : STATE_PROVISION_FAIL;
            onRemoteProvisioningComplete();
        }

    }

    private void onProvisioningPduNotify(ProvisioningPDUReportMessage provisioningPDUReportMessage) {
        log("provisioning pdu report : " + provisioningPDUReportMessage.toString()
                + " -- " + this.inboundPDUNumber);
        byte[] pduData = provisioningPDUReportMessage.getProvisioningPDU();
        int inboundPDUNumber = provisioningPDUReportMessage.getInboundPDUNumber() & 0xFF;
        if (inboundPDUNumber <= this.inboundPDUNumber) {
            log("repeated provisioning pdu received");
            return;
        }
        if (provisioningController != null) {
            provisioningController.pushNotification(pduData);
        }
    }

    private void resendProvisionPdu() {
        delayHandler.removeCallbacks(resendProvisionPduTask);
        delayHandler.postDelayed(resendProvisionPduTask, 2 * 1000);
    }

    private void onOutboundReport(ProvisioningPDUOutboundReportMessage outboundReportMessage) {
        int outboundPDUNumber = outboundReportMessage.getOutboundPDUNumber() & 0xFF;
        log("outbound report message received: " + outboundPDUNumber + " waiting? " + this.outboundReportWaiting);
        if (this.outboundNumber == outboundPDUNumber) {
            synchronized (WAITING_LOCK) {
                delayHandler.removeCallbacks(resendProvisionPduTask);
                transmittingPdu = null;
                outboundReportWaiting = false;
                log("stop outbound waiting: " + this.outboundNumber);
                this.outboundNumber++;
                if (this.cachePdu != null) {
                    this.onCommandPrepared(ProxyPDU.TYPE_PROVISIONING_PDU, this.cachePdu);
                    this.cachePdu = null;
                } else {
                    log("no cached provisioning pdu: waiting for provisioning response");
                }
            }

        } else if (outboundReportWaiting) {
            log("outbound number not pair");
            /*outboundReportWaiting = false;
            if (this.transmittingPdu != null) {
                this.onCommandPrepared(ProxyPDU.TYPE_PROVISIONING_PDU, this.transmittingPdu);
            }*/
        }
    }

    public void onMessageNotification(NotificationMessage message) {
        Opcode opcode = Opcode.valueOf(message.getOpcode());
        if (opcode == null) return;
        switch (opcode) {
            case REMOTE_PROV_LINK_STS:
                onLinkStatus((LinkStatusMessage) message.getStatusMessage());
                break;

            case REMOTE_PROV_PDU_REPORT:
                onProvisioningPduNotify((ProvisioningPDUReportMessage) message.getStatusMessage());
                break;
            case REMOTE_PROV_PDU_OUTBOUND_REPORT:
                onOutboundReport((ProvisioningPDUOutboundReportMessage) message.getStatusMessage());
                break;
        }
    }

    public void onRemoteProvisioningCommandComplete(boolean success, int opcode, int rspMax, int rspCount) {
        if (!success) {
            onCommandError(opcode);
        }
    }

    private void onCommandError(int opcode) {
        if (opcode == Opcode.REMOTE_PROV_LINK_OPEN.value) {
            onProvisioningComplete(false, "link open err");
        } else if (opcode == Opcode.REMOTE_PROV_LINK_CLOSE.value) {
            this.state = provisionSuccess ? STATE_PROVISION_SUCCESS : STATE_PROVISION_FAIL;
            onRemoteProvisioningComplete();
        } else if (opcode == Opcode.REMOTE_PROV_PDU_SEND.value) {
            log("provisioning pdu send error");
            onProvisioningComplete(false, "provision pdu send error");
        }
    }

    private void onProvisioningComplete(boolean success, String desc) {
        delayHandler.removeCallbacksAndMessages(null);
        provisionSuccess = success;
        if (!success && provisioningController != null) {
            provisioningController.clear();
        }
        linkClose(success);
    }

    private void onRemoteProvisioningComplete() {
        if (accessBridge != null) {
            accessBridge.onAccessStateChanged(this.state, "remote provisioning complete", AccessBridge.MODE_REMOTE_PROVISIONING, this.provisioningDevice);
        }
    }

    private Runnable resendProvisionPduTask = new Runnable() {
        @Override
        public void run() {
            log("resend provision pdu: waitingOutbound?" + outboundReportWaiting);
            if (transmittingPdu != null) {
                synchronized (WAITING_LOCK) {
                    if (outboundReportWaiting) {
                        outboundReportWaiting = false;
                        onCommandPrepared(ProxyPDU.TYPE_PROVISIONING_PDU, transmittingPdu);
                    }
                }
            } else {
                log("transmitting pdu error");
            }
        }
    };

    // draft feature
    private void onMeshMessagePrepared(MeshMessage meshMessage) {}


    @Override
    public void onProvisionStateChanged(int state, String desc) {
        log("provisioning state changed: " + state + " -- " + desc);
        if (state == ProvisioningController.STATE_COMPLETE) {
            onProvisioningComplete(true, desc);
        } else if (state == ProvisioningController.STATE_FAILED) {
            onProvisioningComplete(false, desc);
        }
    }


    /*private Runnable provisioningPduTimeoutTask = new Runnable() {
        @Override
        public void run() {
            if (outboundReportWaiting && transmittingPdu != null) {
                outboundReportWaiting = false;
                logMessage("provisioning pdu timeout: " + Arrays.bytesToHexString(transmittingPdu));
                onCommandPrepared(ProxyPDU.TYPE_PROVISIONING_PDU, transmittingPdu);
            }
        }
    };*/

    /**
     * send provisioning pdu by ProvisioningController
     */
    @Override
    public void onCommandPrepared(byte type, byte[] data) {
        if (type != ProxyPDU.TYPE_PROVISIONING_PDU) return;

        synchronized (WAITING_LOCK) {
            if (outboundReportWaiting) {
                if (cachePdu == null) {
                    cachePdu = data;
                } else {
                    log("cache pdu already exists");
                }
                return;
            }
        }

        transmittingPdu = data.clone();

        ProvisioningPduSendMessage provisioningPduSendMessage = ProvisioningPduSendMessage.getSimple(
                provisioningDevice.getServerAddress(),
                0,
                (byte) this.outboundNumber,
                transmittingPdu
        );
        provisioningPduSendMessage.setRetryCnt(8);
//        delayHandler.removeCallbacks(provisioningPduTimeoutTask);
//        delayHandler.postDelayed(provisioningPduTimeoutTask, OUTBOUND_WAITING_TIMEOUT);
        log("send provisioning pdu: " + this.outboundNumber);
        onMeshMessagePrepared(provisioningPduSendMessage);
    }


    private void log(String logMessage) {
        log(logMessage, MeshLogger.LEVEL_DEBUG);
    }

    private void log(String logMessage, int level) {
        MeshLogger.log(logMessage, LOG_TAG, level);
    }
}
