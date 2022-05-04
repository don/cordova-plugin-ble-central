package com.telink.ble.mesh.core.message.firmwaredistribution;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatingMessage;

/**
 * The Firmware Distribution Firmware Delete message is an acknowledged message sent by a Firmware Distribution Client to delete a stored firmware image on a Firmware Distribution Server.
 * The response to a Firmware Distribution Firmware Delete message is a Firmware Distribution Firmware Status message.
 */
public class FDFirmwareDeleteMessage extends UpdatingMessage {

    /**
     * Firmware ID
     * The Firmware ID identifying the firmware image to check
     * Variable length
     */
    public int firmwareID;


    public FDFirmwareDeleteMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    public static FDFirmwareDeleteMessage getSimple(int destinationAddress, int appKeyIndex) {
        FDFirmwareDeleteMessage message = new FDFirmwareDeleteMessage(destinationAddress, appKeyIndex);
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
