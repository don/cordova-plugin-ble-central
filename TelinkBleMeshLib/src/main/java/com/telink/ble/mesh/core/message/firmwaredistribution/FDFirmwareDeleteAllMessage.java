package com.telink.ble.mesh.core.message.firmwaredistribution;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatingMessage;

/**
 * The Firmware Distribution Firmware Delete All message is an acknowledged message sent by a Firmware Distribution Client to delete all firmware images stored on a Firmware Distribution Server.
 * The response to a Firmware Distribution Firmware Delete All message is a Firmware Distribution Firmware Status message.
 */
public class FDFirmwareDeleteAllMessage extends UpdatingMessage {

    /**
     * Firmware ID
     * The Firmware ID identifying the firmware image to check
     * Variable length
     */
    public int firmwareID;


    public FDFirmwareDeleteAllMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    public static FDFirmwareDeleteAllMessage getSimple(int destinationAddress, int appKeyIndex) {
        FDFirmwareDeleteAllMessage message = new FDFirmwareDeleteAllMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        return message;
    }

    @Override
    public int getOpcode() {
        return Opcode.FD_FIRMWARE_DELETE.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.FD_UPLOAD_STATUS.value;
    }


}
