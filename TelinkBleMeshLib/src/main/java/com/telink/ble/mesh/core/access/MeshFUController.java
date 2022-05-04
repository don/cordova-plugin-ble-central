package com.telink.ble.mesh.core.access;

import com.telink.ble.mesh.core.message.MeshMessage;
import com.telink.ble.mesh.core.message.NotificationMessage;
import com.telink.ble.mesh.core.message.Opcode;

/**
 * Mesh firmware update controller
 */
public class MeshFUController {

    AccessBridge accessBridge;
    int localAddress = 0x0001;
    int distributorAddress = 0;

    void start(int distributorAddress) {
        this.distributorAddress = distributorAddress;
    }

    void onMeshMessageResponse(NotificationMessage notificationMessage) {

    }

    void onMeshMessagePrepared(MeshMessage meshMessage) {

        if (meshMessage.getDestinationAddress() == localAddress) {
            responseLocalMessage(meshMessage);
        } else {
            accessBridge.onAccessMessagePrepared(meshMessage, AccessBridge.MODE_FIRMWARE_UPDATING);
        }
    }

    /**
     * @param meshMessage
     */
    private void responseLocalMessage(MeshMessage meshMessage) {
        final int op = meshMessage.getOpcode();
        final int rspOp = meshMessage.getResponseOpcode();
        if (rspOp == Opcode.FD_STATUS.value) {

        } else if (rspOp == Opcode.FD_CAPABILITIES_STATUS.value) {

        } else if (rspOp == Opcode.FD_FIRMWARE_STATUS.value) {

        } else if (rspOp == Opcode.FD_RECEIVERS_STATUS.value) {

        } else if (rspOp == Opcode.FD_UPLOAD_STATUS.value) {

        }

    }
}
