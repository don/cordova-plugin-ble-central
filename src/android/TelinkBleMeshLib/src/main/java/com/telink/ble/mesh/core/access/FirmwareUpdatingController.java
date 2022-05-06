/********************************************************************************************************
 * @file FirmwareUpdatingController.java
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
package com.telink.ble.mesh.core.access;

import android.os.Handler;
import android.os.HandlerThread;

import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.MeshMessage;
import com.telink.ble.mesh.core.message.MeshSigModel;
import com.telink.ble.mesh.core.message.NotificationMessage;
import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.config.ConfigStatus;
import com.telink.ble.mesh.core.message.config.ModelSubscriptionSetMessage;
import com.telink.ble.mesh.core.message.config.ModelSubscriptionStatusMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.FirmwareMetadataCheckMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.FirmwareMetadataStatusMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.FirmwareUpdateApplyMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.FirmwareUpdateCancelMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.FirmwareUpdateGetMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.FirmwareUpdateInfoGetMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.FirmwareUpdateInfoStatusMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.FirmwareUpdateStartMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.FirmwareUpdateStatusMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatePhase;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdateStatus;
import com.telink.ble.mesh.core.message.firmwareupdate.blobtransfer.BlobBlockGetMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.blobtransfer.BlobBlockStartMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.blobtransfer.BlobBlockStatusMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.blobtransfer.BlobChunkTransferMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.blobtransfer.BlobInfoGetMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.blobtransfer.BlobInfoStatusMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.blobtransfer.BlobTransferGetMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.blobtransfer.BlobTransferStartMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.blobtransfer.BlobTransferStatusMessage;
import com.telink.ble.mesh.core.message.firmwareupdate.blobtransfer.TransferStatus;
import com.telink.ble.mesh.core.networking.NetworkingController;
import com.telink.ble.mesh.entity.FirmwareUpdateConfiguration;
import com.telink.ble.mesh.entity.MeshUpdatingDevice;
import com.telink.ble.mesh.util.MeshLogger;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;


/**
 * Mesh firmware updating
 * Created by kee on 2020/04/13.
 */
public class FirmwareUpdatingController {

    private final String LOG_TAG = "FwUpdate";

    /**
     * all complete, fail or success
     */
    public static final int STATE_SUCCESS = 0x00;

    /**
     * chunks sending progress
     */
    public static final int STATE_PROGRESS = 0x01;

    /**
     * device succeed when apply status success
     */
    public static final int STATE_DEVICE_SUCCESS = 0x02;

    /**
     * device failed at every step status err
     */
    public static final int STATE_DEVICE_FAIL = 0x03;

    /**
     * mesh updating flow failed
     */
    public static final int STATE_FAIL = 0x04;


    /**
     * params check err
     */
    public static final int STATE_STOPPED = 0x05;


    /**
     * prepare complete when  STEP_BLOB_TRANSFER_START sent success
     */
    public static final int STATE_PREPARED = 0x06;

    /**
     * get firmware info err
     */
//    public static final int STATE_ACTION_EXECUTE_FAIL = 0x05;

    /**
     * initial
     */
    private static final int STEP_INITIAL = 0;

    /**
     * set subscription at firmware-updating-model
     */
    private static final int STEP_SET_SUBSCRIPTION = 1;

    /**
     * get firmware information
     */
    private static final int STEP_GET_FIRMWARE_INFO = 2;

    /**
     * check firmware metadata
     */
    private static final int STEP_METADATA_CHECK = 3;

    /**
     * firmware update start
     */
    private static final int STEP_UPDATE_START = 4;

    /**
     * blob transfer get
     */
    private static final int STEP_BLOB_TRANSFER_GET = 5;

    /**
     * get blob info
     */
    private static final int STEP_GET_BLOB_INFO = 6;

    /**
     * blob transfer start
     */
    private static final int STEP_BLOB_TRANSFER_START = 7;

    /**
     * blob block transfer start
     */
    private static final int STEP_BLOB_BLOCK_TRANSFER_START = 8;

    /**
     * sending chunk data
     */
    private static final int STEP_BLOB_CHUNK_SENDING = 9;

    /**
     * get block
     *
     * @see Opcode#BLOB_BLOCK_STATUS
     */
    private static final int STEP_GET_BLOB_BLOCK = 10;


    /**
     * get firmware update after block sent complete
     */
    private static final int STEP_UPDATE_GET = 11;

    /**
     * firmware update apply
     */
    private static final int STEP_UPDATE_APPLY = 12;

    /**
     * all complete
     */
    private static final int STEP_UPDATE_COMPLETE = 13;

    /**
     * manual stopping mesh updating flow
     */
    private static final int STEP_UPDATE_ABORTING = -1;

    /**
     * step
     */
    private int step = STEP_INITIAL;

    /**
     * node address | ignore
     */
    private List<MeshUpdatingDevice> nodes;

//    private int[] nodeAddresses;

    /**
     * group address for subscription
     */
    private int groupAddress;

    /**
     * app key index that updating model bound with
     */
    private int appKeyIndex;

    /**
     * operation index
     */
    private int nodeIndex;

//    private int companyId;

//    private int firmwareId;

    private long blobId;


    // firmware[2-5] + [0, 0, 0, 0]
    private byte[] metadata = new byte[8];

    private int metadataIndex = 0;

    private MeshFirmwareParser firmwareParser = new MeshFirmwareParser();

    private byte[] firmwareData;

    /**
     * received missing chunk number
     */
    private ArrayList<Integer> missingChunks = new ArrayList<>();

    private int missingChunkIndex = 0;

    /**
     * mix format : mix all format received after checkMissingChunks {@link #checkMissingChunks()}
     */
    private int mixFormat = -1;

    private Handler delayHandler;

    private AccessBridge accessBridge;

    /**
     * update only direct connected device
     */
    private boolean isGattMode = false;

    private int gattAddress = -1;

    // check if last chunk in block needs segmentation
    private int dleLength = 11;
    // for missing test
    boolean test = true;

    public FirmwareUpdatingController(HandlerThread handlerThread) {
        delayHandler = new Handler(handlerThread.getLooper());
    }

    public void register(AccessBridge accessBridge) {
        this.accessBridge = accessBridge;
    }

    /**
     * ignore distribution start action
     * <p>
     * 1. get all nodes's firmware information ->
     * 2. subscribe target group address
     * 3. distribution start (ignore)
     * 4. send block
     */
    public void begin(FirmwareUpdateConfiguration configuration) {
        if (configuration == null) {
            onUpdatingFail(STATE_FAIL, "updating params null");
            return;
        }
        test = true;
        this.isGattMode = configuration.isSingleAndDirect();
        this.dleLength = configuration.getDleLength();
        this.firmwareData = configuration.getFirmwareData();
        if (firmwareData.length < 6) {
            return;
        }
        this.metadata = configuration.getMetadata();

        // reset when device chunk size received
//        this.firmwareParser.reset(configuration.getFirmwareData());
        log(" config -- " + configuration.toString());
        log("isGattMode? " + isGattMode);
        this.appKeyIndex = configuration.getAppKeyIndex();
        this.groupAddress = configuration.getGroupAddress();
        this.nodes = configuration.getUpdatingDevices();
        this.blobId = configuration.getBlobId();
        this.nodeIndex = 0;
        if (nodes != null && nodes.size() != 0) {

            /*if (this.isGattMode){
                this.step = STEP_GET_FIRMWARE_INFO;
            }else {
                this.step = STEP_SET_SUBSCRIPTION;
            }*/
            if (this.isGattMode) {
                this.gattAddress = this.nodes.get(0).getMeshAddress();
            }
            this.step = STEP_SET_SUBSCRIPTION;
            executeUpdatingAction();
        } else {
            onUpdatingFail(STATE_FAIL, "params err when action begin");
        }
    }

    public void clear() {
        if (delayHandler != null) {
            delayHandler.removeCallbacksAndMessages(null);
        }
        step = STEP_INITIAL;
    }

    public void stop() {
        if (step == STEP_INITIAL) {
            log("mesh updating not running");
        } else {
            delayHandler.removeCallbacksAndMessages(null);
            delayHandler.postDelayed(stoppingCheckTask, 5 * 1000);
            step = STEP_UPDATE_ABORTING;
            FirmwareUpdateCancelMessage firmwareUpdateCancelMessage = FirmwareUpdateCancelMessage.getSimple(0xFFFF, appKeyIndex);
            onMeshMessagePrepared(firmwareUpdateCancelMessage);
        }
    }

    private Runnable stoppingCheckTask = new Runnable() {
        @Override
        public void run() {
            onUpdatingStopped();
        }
    };

    private void sendChunks() {
        byte[] chunkData = firmwareParser.nextChunk();
        final int chunkIndex = firmwareParser.currentChunkIndex();
        /*if (test) {
            if (firmwareParser.currentChunkIndex() == 2) {
                byte[] missingChunkData = firmwareParser.nextChunk();
                test = false;
            }
        }*/
        if (chunkData != null) {
            validateUpdatingProgress();
//            int chunkNumber = firmwareParser.currentChunkIndex();

            BlobChunkTransferMessage blobChunkTransferMessage = generateChunkTransferMessage(chunkIndex, chunkData);

            log("next chunk transfer msg: " + blobChunkTransferMessage.toString());

            onMeshMessagePrepared(blobChunkTransferMessage);
            if (!isGattMode) {
                delayHandler.postDelayed(chunkSendingTask, getChunkSendingInterval());
            } else {
                int len = chunkData.length + 3;
                boolean segment = len > dleLength;
                if (!segment) {
                    sendChunks();
                }
            }
        } else {
            log("chunks sent complete at: block -- " + firmwareParser.currentBlockIndex()
                    + " chunk -- " + firmwareParser.currentChunkIndex());
            checkMissingChunks();
        }
    }


    private void checkMissingChunks() {
        log("check missing chunks");
        missingChunks.clear();
        mixFormat = -1;
        step = STEP_GET_BLOB_BLOCK;
        nodeIndex = 0;
        executeUpdatingAction();
    }


    private void resendMissingChunks() {
        if (missingChunkIndex >= missingChunks.size()) {
            // all missing chunk sent
            log("all missing chunks sent complete: " + missingChunkIndex);
            checkMissingChunks();
        } else {
            int chunkNumber = missingChunks.get(missingChunkIndex);
            log("missing chunks: " + chunkNumber);
            byte[] chunkData = firmwareParser.chunkAt(chunkNumber);
            if (chunkData == null) {
                log("chunk index overflow when resending chunk: " + chunkNumber);
                return;
            }
            BlobChunkTransferMessage blobChunkTransferMessage = generateChunkTransferMessage(chunkNumber, chunkData);
            onMeshMessagePrepared(blobChunkTransferMessage);
            delayHandler.postDelayed(missingChunkSendingTask, getChunkSendingInterval());
        }
    }

    /*private long getChunkSendingInterval() {
        // relay 320 ms

        long interval = firmwareParser.getChunkSize() / 12 * NetworkingController.NETWORKING_INTERVAL + NetworkingController.NETWORKING_INTERVAL;
        final long min = 5 * 1000;
        interval = Math.max(min, interval);
        log("chunk sending interval: " + interval);
        return interval;
    }*/

    private long getChunkSendingInterval() {
        // relay 320 ms

        if (isGattMode) {
            return 100;
        }

        // 12
        // 208
        // chunk size + opcode(1 byte)
        final int chunkMsgLen = firmwareParser.getChunkSize() + 1;
        final int unsegLen = NetworkingController.unsegmentedAccessLength;
        final int segLen = unsegLen + 1;
        int segmentCnt = chunkMsgLen == unsegLen ? 1 : (chunkMsgLen % segLen == 0 ? chunkMsgLen / segLen : (chunkMsgLen / segLen + 1));
        long interval = segmentCnt * NetworkingController.NETWORKING_INTERVAL;
//        final long min = 5 * 1000;
        // use 5000 when DLE disabled, use 300 when DLE enabled
        final long min = unsegLen == NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DEFAULT ? 5 * 1000 : 300;
        interval = Math.max(min, interval);
        log("chunk sending interval: " + interval);
        return interval;
    }

    private Runnable missingChunkSendingTask = new Runnable() {
        @Override
        public void run() {
            missingChunkIndex++;
            resendMissingChunks();
        }
    };

    private Runnable chunkSendingTask = new Runnable() {
        @Override
        public void run() {
            sendChunks();
        }
    };

    private BlobChunkTransferMessage generateChunkTransferMessage(int chunkNumber, byte[] chunkData) {
        int address = isGattMode ? gattAddress : groupAddress;
        return BlobChunkTransferMessage.getSimple(address, appKeyIndex, chunkNumber, chunkData);
    }


    /**
     * execute updating actions(one by one && step by step)
     * one device by one device
     * if all devices executed, then next step
     */
    // draft feature
    private void executeUpdatingAction() {}


    private void removeFailedDevices() {
        Iterator<MeshUpdatingDevice> iterator = nodes.iterator();
        MeshUpdatingDevice updatingNode;
        while (iterator.hasNext()) {
            updatingNode = iterator.next();
            if (updatingNode.getState() == MeshUpdatingDevice.STATE_FAIL) {
                iterator.remove();
            }
        }
    }

    private void onMeshMessagePrepared(MeshMessage meshMessage) {
        meshMessage.setRetryCnt(10);
        log("mesh message prepared: " + meshMessage.getClass().getSimpleName()
                + String.format(" opcode: 0x%04X -- dst: 0x%04X", meshMessage.getOpcode(), meshMessage.getDestinationAddress()));
        if (accessBridge != null) {
            boolean isMessageSent = accessBridge.onAccessMessagePrepared(meshMessage, AccessBridge.MODE_FIRMWARE_UPDATING);
            if (!isMessageSent) {

                if (meshMessage instanceof BlobChunkTransferMessage) {
                    onUpdatingFail(-1, "chunk transfer message sent error");
                } else {
                    if (nodes.size() > nodeIndex) {
                        onDeviceFail(nodes.get(nodeIndex), String.format("mesh message sent error -- opcode: 0x%04X", meshMessage.getOpcode()));
                    }
                }

            }
        }
    }

    public void onSegmentComplete(boolean success) {
        if (isGattMode && step == STEP_BLOB_CHUNK_SENDING) {
            if (success) {
                sendChunks();
            } else {
                onUpdatingFail(STATE_FAIL, "chunk send fail -- segment message send fail");
            }
        }
    }

    //  在 发包过程中 retry导致的收多次
    public void onMessageNotification(NotificationMessage message) {
        Opcode opcode = Opcode.valueOf(message.getOpcode());
        log("message notification: " + opcode);
        if (step == STEP_INITIAL) {
            log("notification when idle");
            return;
        }
        if (opcode == null) return;
        final int src = message.getSrc();

        if (nodes.size() <= nodeIndex) {
            log("node index overflow", MeshLogger.LEVEL_WARN);
            return;
        }

        if (nodes.get(nodeIndex).getMeshAddress() != src) {
            log("unexpected notification src", MeshLogger.LEVEL_WARN);
            return;
        }

        switch (opcode) {

            case FIRMWARE_UPDATE_INFORMATION_STATUS:
                onFirmwareInfoStatus((FirmwareUpdateInfoStatusMessage) message.getStatusMessage());
                break;

            case CFG_MODEL_SUB_STATUS:
                onSubscriptionStatus((ModelSubscriptionStatusMessage) message.getStatusMessage());
                break;

            case BLOB_INFORMATION_STATUS:
                onBlobInfoStatus((BlobInfoStatusMessage) message.getStatusMessage());
                break;

            case FIRMWARE_UPDATE_FIRMWARE_METADATA_STATUS:
                onMetadataStatus((FirmwareMetadataStatusMessage) message.getStatusMessage());
                break;

            case FIRMWARE_UPDATE_STATUS:
                onFirmwareUpdateStatus((FirmwareUpdateStatusMessage) message.getStatusMessage());
                break;

            case BLOB_TRANSFER_STATUS:
                onBlobTransferStatus((BlobTransferStatusMessage) message.getStatusMessage());
                break;


            /*case BLOB_BLOCK_STATUS: OBJ_BLOCK_TRANSFER_STATUS:
                onBlockTransferStatus((BlobBlockStatusMessage) message.getStatusMessage());
                break;*/

            case BLOB_BLOCK_STATUS:
                onBlobBlockStatus(message);
                break;
        }
    }

    private void onFirmwareInfoStatus(FirmwareUpdateInfoStatusMessage firmwareInfoStatusMessage) {
        log("firmware info status: " + firmwareInfoStatusMessage.toString());
        if (step != STEP_GET_FIRMWARE_INFO) {
            log("not at STEP_GET_FIRMWARE_INFO");
            return;
        }

        int firstIndex = firmwareInfoStatusMessage.getFirstIndex();
        int companyId = firmwareInfoStatusMessage.getListCount();
        List<FirmwareUpdateInfoStatusMessage.FirmwareInformationEntry> firmwareInformationList
                = firmwareInfoStatusMessage.getFirmwareInformationList();
        nodeIndex++;
        executeUpdatingAction();
    }

    private void onSubscriptionStatus(ModelSubscriptionStatusMessage subscriptionStatusMessage) {
        log("subscription status: " + subscriptionStatusMessage.toString());
        if (step != STEP_SET_SUBSCRIPTION) {
            log("not at STEP_SET_SUBSCRIPTION");
            return;
        }
        if (subscriptionStatusMessage.getStatus() != ConfigStatus.SUCCESS.code) {
            onDeviceFail(nodes.get(nodeIndex), "grouping status err " + subscriptionStatusMessage.getStatus());
        }
        nodeIndex++;
        executeUpdatingAction();
    }


    /**
     * response of {@link BlobInfoStatusMessage}
     */
    private void onBlobInfoStatus(BlobInfoStatusMessage objectInfoStatusMessage) {


        log("object info status: " + objectInfoStatusMessage.toString());
        if (step != STEP_GET_BLOB_INFO) {
            log("not at STEP_GET_BLOB_INFO");
            return;
        }
        int blockSize = (int) Math.pow(2, objectInfoStatusMessage.getMaxBlockSizeLog());
        int chunkSize = objectInfoStatusMessage.getMaxChunkSize();
        log("chunk size : " + chunkSize + " block size: " + blockSize);
        this.firmwareParser.reset(firmwareData, blockSize, chunkSize);
        nodeIndex++;
        executeUpdatingAction();
    }

    private void onMetadataStatus(FirmwareMetadataStatusMessage metadataStatusMessage) {
        UpdateStatus status = UpdateStatus.valueOf(metadataStatusMessage.getStatus());
        if (step == STEP_METADATA_CHECK) {
            if (status != UpdateStatus.SUCCESS) {
                onDeviceFail(nodes.get(nodeIndex), "metadata check error: " + status.desc);
            }
            nodeIndex++;
            executeUpdatingAction();
        } else {
            log("metadata received when not checking", MeshLogger.LEVEL_WARN);
        }
    }

    /**
     * response of {@link FirmwareUpdateStartMessage} , {@link FirmwareUpdateGetMessage}
     * and {@link FirmwareUpdateApplyMessage}
     */
    private void onFirmwareUpdateStatus(FirmwareUpdateStatusMessage firmwareUpdateStatusMessage) {

        log("firmware update status: " + " at: " + getStepDesc(step)
                + " -- " + firmwareUpdateStatusMessage.toString());
        final UpdateStatus status = UpdateStatus.valueOf(firmwareUpdateStatusMessage.getStatus() & 0xFF);

        if (status != UpdateStatus.SUCCESS) {
            onDeviceFail(nodes.get(nodeIndex), "firmware update status err");
        } else {
            final int step = this.step;
            /*boolean pass = (step == STEP_UPDATE_START && phase == FirmwareUpdateStatusMessage.PHASE_IN_PROGRESS)
                    || (step == STEP_UPDATE_GET && phase == FirmwareUpdateStatusMessage.PHASE_READY)
                    || (step == STEP_UPDATE_APPLY && phase == FirmwareUpdateStatusMessage.PHASE_IDLE);*/
            boolean pass = true;
            if (!pass) {
                onDeviceFail(nodes.get(nodeIndex), "firmware update phase err");
            } else {
                final UpdatePhase phase = UpdatePhase.valueOf(firmwareUpdateStatusMessage.getPhase() & 0xFF);
                if (step == STEP_UPDATE_APPLY) {
                    if (phase == UpdatePhase.VERIFICATION_SUCCESS
                            || phase == UpdatePhase.APPLYING_UPDATE) {
                        onDeviceSuccess(nodes.get(nodeIndex));
                    } else {
                        onDeviceFail(nodes.get(nodeIndex), "phase error when update apply");
                    }
                }
            }
        }
        nodeIndex++;
        executeUpdatingAction();

    }

    /**
     * response of {@link BlobTransferStartMessage}
     */
    private void onBlobTransferStatus(BlobTransferStatusMessage transferStatusMessage) {
        log("object transfer status: " + transferStatusMessage.toString());
        if (step == STEP_BLOB_TRANSFER_START || step == STEP_BLOB_TRANSFER_GET) {
            UpdateStatus status = UpdateStatus.valueOf(transferStatusMessage.getStatus());

            if (status != UpdateStatus.SUCCESS) {
                onDeviceFail(nodes.get(nodeIndex), "object transfer status err");
            }
            nodeIndex++;
            executeUpdatingAction();
        }

        /*byte status = transferStatusMessage.getStatus();
        if (status != ObjectTransferStatusMessage.STATUS_READY
                && status != ObjectTransferStatusMessage.STATUS_BUSY_ACTIVE) {
            onDeviceFail(nodes.get(nodeIndex), "object transfer status err");
        }*/

    }

    /**
     * response of {@link BlobBlockStartMessage} before start chunks sending
     */
    private void onBlockTransferStatus(BlobBlockStatusMessage blockTransferStatusMessage) {
        log("block transfer status: " + blockTransferStatusMessage.toString());
        int status = blockTransferStatusMessage.getStatus();
        /*if (status != ObjectBlockTransferStatusMessage.STATUS_ACCEPTED) {
            onDeviceFail(nodes.get(nodeIndex), "object block transfer status err");
        }*/
        nodeIndex++;
        executeUpdatingAction();
    }

    /**
     * response of BLOCK_GET
     * {@link #checkMissingChunks()}
     * {@link BlobBlockStartMessage}
     */
    private void onBlobBlockStatus(NotificationMessage message) {
        if (step != STEP_GET_BLOB_BLOCK && step != STEP_BLOB_BLOCK_TRANSFER_START) {
            return;
        }
        BlobBlockStatusMessage blobBlockStatusMessage = (BlobBlockStatusMessage) message.getStatusMessage();
        log("block status: " + blobBlockStatusMessage.toString());
        int srcAddress = message.getSrc();
        TransferStatus transferStatus = TransferStatus.valueOf(blobBlockStatusMessage.getStatus() & 0xFF);
        if (transferStatus != TransferStatus.SUCCESS) {
            onDeviceFail(nodes.get(nodeIndex), "block status err");
        } else {
            // only check chunk missing when STEP_GET_BLOB_BLOCK
            if (step == STEP_GET_BLOB_BLOCK) {
                int format = blobBlockStatusMessage.getFormat();

                mixFormat(format);

                switch (format) {
                    case BlobBlockStatusMessage.FORMAT_ALL_CHUNKS_MISSING:
                        log(String.format("all chunks missing: %04X", srcAddress));
                        break;

                    case BlobBlockStatusMessage.FORMAT_NO_CHUNKS_MISSING:
                        log(String.format("no chunks missing: %04X", srcAddress));
                        break;

                    case BlobBlockStatusMessage.FORMAT_SOME_CHUNKS_MISSING:
                        mixMissingChunks(blobBlockStatusMessage.getMissingChunks());
                        break;

                    case BlobBlockStatusMessage.FORMAT_ENCODED_MISSING_CHUNKS:
                        mixMissingChunks(blobBlockStatusMessage.getEncodedMissingChunks());
                        break;
                }
            }
        }

        nodeIndex++;
        executeUpdatingAction();


        /*switch (objectBlockStatusMessage.getStatus()) {
            case ObjectBlockStatusMessage.STATUS_ALL_CHUNKS_RECEIVED:
                // all chunks data received
                log("no chunks missing");
                nodeIndex++;
                executeUpdatingAction();
                break;

            case ObjectBlockStatusMessage.STATUS_NOT_ALL_CHUNKS_RECEIVED:
                // chunk missing
                int[] missingChunksList = objectBlockStatusMessage.getMissingChunksList();
                if (missingChunksList != null) {
                    for (int chunkNum : missingChunksList) {
                        missingChunks.add(chunkNum);
                    }
                    nodeIndex++;
                    executeUpdatingAction();
                } else {
                    log("missing chunk data not found at status: " + objectBlockStatusMessage.getStatus());
                }
                break;

            case ObjectBlockStatusMessage.STATUS_WRONG_CHECKSUM:
            case ObjectBlockStatusMessage.STATUS_WRONG_OBJECT_ID:
            case ObjectBlockStatusMessage.STATUS_WRONG_BLOCK:
                // err
                MeshUpdatingDevice device = getDeviceByAddress(srcAddress);
                if (device != null) {
                    onDeviceFail(device, "block status err");
                } else {
                    log(String.format("device not found , mesh address: %04X", srcAddress));
                }
                break;

        }*/
    }

    private void mixFormat(int format) {
        if (this.mixFormat == BlobBlockStatusMessage.FORMAT_ALL_CHUNKS_MISSING) {
            return;
        }
        if (this.mixFormat == -1) {
            this.mixFormat = format;
        } else if (this.mixFormat != format && format != BlobBlockStatusMessage.FORMAT_NO_CHUNKS_MISSING) {
            this.mixFormat = format;
        }
    }

    private void mixMissingChunks(List<Integer> chunks) {
        if (this.mixFormat == BlobBlockStatusMessage.FORMAT_ALL_CHUNKS_MISSING) return;
        if (chunks != null) {
            for (int chunkNumber : chunks) {
                if (!missingChunks.contains(chunkNumber)) {
                    missingChunks.add(chunkNumber);
                }
            }
        }
    }


    /**
     * reliable command complete
     */
    public void onUpdatingCommandComplete(boolean success, int opcode, int rspMax, int rspCount) {
        log(String.format("updating command complete: opcode-%04X success?-%b", opcode, success));
        if (!success) {

            /*
            STEP_SET_SUBSCRIPTION = 1;
            STEP_GET_FIRMWARE_INFO = 2;
            STEP_METADATA_CHECK = 3;
            STEP_UPDATE_START = 4;
            STEP_BLOB_TRANSFER_GET = 5;
            STEP_GET_BLOB_INFO = 6;
            STEP_BLOB_TRANSFER_START = 7;
            STEP_BLOB_BLOCK_TRANSFER_START = 8;
            STEP_BLOB_CHUNK_SENDING = 9;
            STEP_GET_BLOB_BLOCK = 10;
            STEP_UPDATE_GET = 11;
            STEP_UPDATE_APPLY = 12;
            STEP_UPDATE_COMPLETE = 13;
             */

            // command timeout
            final boolean deviceFailed =
                    (opcode ==
                            Opcode.CFG_MODEL_SUB_ADD.value && step == STEP_SET_SUBSCRIPTION) ||
                            (opcode == Opcode.FIRMWARE_UPDATE_INFORMATION_GET.value && step == STEP_GET_FIRMWARE_INFO) ||
                            (opcode == Opcode.FIRMWARE_UPDATE_FIRMWARE_METADATA_CHECK.value && step == STEP_METADATA_CHECK) ||
                            (opcode == Opcode.FIRMWARE_UPDATE_START.value && step == STEP_UPDATE_START) ||
                            (opcode == Opcode.BLOB_TRANSFER_GET.value && step == STEP_BLOB_TRANSFER_GET) ||

                            (opcode == Opcode.BLOB_INFORMATION_GET.value && step == STEP_GET_BLOB_INFO) ||

                            (opcode == Opcode.BLOB_TRANSFER_START.value && step == STEP_BLOB_TRANSFER_START) ||
                            (opcode == Opcode.BLOB_BLOCK_START.value && step == STEP_BLOB_BLOCK_TRANSFER_START)
                            || (opcode == Opcode.BLOB_BLOCK_GET.value && step == STEP_GET_BLOB_BLOCK)
                            || (opcode == Opcode.FIRMWARE_UPDATE_GET.value && step == STEP_UPDATE_GET)
                            || (opcode == Opcode.FIRMWARE_UPDATE_APPLY.value && step == STEP_UPDATE_APPLY);
            if (deviceFailed) {
                String desc = String.format(Locale.getDefault(), "device failed at step: %02d when sending: 0x%04X", step, opcode);
                onDeviceFail(nodes.get(nodeIndex), desc);
                nodeIndex++;
                executeUpdatingAction();
            }
        }
    }

    private void validateUpdatingProgress() {
        if (firmwareParser.validateProgress()) {
            final int progress = firmwareParser.getProgress();
            log("chunk sending progress: " + progress);
            onStateUpdate(STATE_PROGRESS, "progress update", progress);
        }
    }

    private MeshUpdatingDevice getDeviceByAddress(int meshAddress) {
        for (MeshUpdatingDevice device : nodes) {
            if (device.getMeshAddress() == meshAddress) return device;
        }
        return null;
    }


    private void onDeviceFail(MeshUpdatingDevice device, String desc) {
        log(String.format("node updating fail: %04X -- " + desc, device.getMeshAddress()));
        device.setState(MeshUpdatingDevice.STATE_FAIL);
        onStateUpdate(STATE_DEVICE_FAIL,
                String.format("node updating fail: %04X -- ", device.getMeshAddress()),
                device);
    }

    private void onDeviceSuccess(MeshUpdatingDevice device) {
        log(String.format("node updating success: %04X -- ", device.getMeshAddress()));
        device.setState(MeshUpdatingDevice.STATE_SUCCESS);
        onStateUpdate(STATE_DEVICE_SUCCESS,
                String.format("node updating success: %04X -- ", device.getMeshAddress()),
                device);
    }

    /**
     * at least one device success
     */
    private void onUpdatingSuccess() {
        onStateUpdate(STATE_PROGRESS, "update complete -> progress ", 100);
        log("updating complete");
        this.step = STEP_INITIAL;
        onStateUpdate(STATE_SUCCESS, "updating success", null);
    }

    /**
     * no device success
     */
    private void onUpdatingFail(int state, String desc) {
        log("updating failed: " + state + " -- " + desc);
        this.step = STEP_INITIAL;
        onStateUpdate(state, desc, null);
        onMeshMessagePrepared(FirmwareUpdateCancelMessage.getSimple(0xFFFF, appKeyIndex));
    }


    public void onUpdatingStopped() {
        log("updating stopped");
        this.step = STEP_INITIAL;
        onStateUpdate(STATE_STOPPED, "updating stopped", null);
    }

    private void onStateUpdate(int state, String desc, Object obj) {
        if (accessBridge != null) {
            accessBridge.onAccessStateChanged(state, desc, AccessBridge.MODE_FIRMWARE_UPDATING, obj);
        }
    }

    /**
     * get step description
     */
    private String getStepDesc(int step) {
        switch (step) {

            case STEP_INITIAL:
                return "initial";

            case STEP_GET_FIRMWARE_INFO:
                return "get-firmware-info";

            case STEP_SET_SUBSCRIPTION:
                return "set-subscription";

            case STEP_GET_BLOB_INFO:
                return "get-blob-info";

            case STEP_METADATA_CHECK:
                return "metadata-check";

            case STEP_UPDATE_START:
                return "update-start";

            case STEP_BLOB_TRANSFER_START:
                return "blob-transfer-start";

            case STEP_BLOB_TRANSFER_GET:
                return "blob transfer get";

            case STEP_BLOB_BLOCK_TRANSFER_START:
                return "block-transfer-start";

            case STEP_BLOB_CHUNK_SENDING:
                return "blob-chunk-sending";

            case STEP_GET_BLOB_BLOCK:
                return "get-blob-block";

            case STEP_UPDATE_GET:
                return "update-get";

            case STEP_UPDATE_APPLY:
                return "update-apply";

            case STEP_UPDATE_COMPLETE:
                return "update-complete";
        }
        return "unknown";
    }

    private void log(String logMessage) {
        log(logMessage, MeshLogger.LEVEL_DEBUG);
    }

    private void log(String logMessage, int level) {
        MeshLogger.log(logMessage, LOG_TAG, level);
    }


}
