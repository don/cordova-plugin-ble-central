package com.telink.ble.mesh.core.message.firmwaredistribution;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatingMessage;

/**
 * The Firmware Distribution Upload Start message is an acknowledged message sent by a Firmware Distribution Client to start a firmware image upload to a Firmware Distribution Server.
 * The response to a Firmware Distribution Upload Start message is a Firmware Distribution Upload Status message.
 */
public class FDFirmwareGetByIndexMessage extends UpdatingMessage {

    /**
     * Distribution Firmware Image Index
     * Index of the entry in the Firmware Images List state
     * 2 bytes
     */
    public int distImageIndex;


    public FDFirmwareGetByIndexMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    public static FDFirmwareGetByIndexMessage getSimple(int destinationAddress, int appKeyIndex) {
        FDFirmwareGetByIndexMessage message = new FDFirmwareGetByIndexMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        return message;
    }

    @Override
    public int getOpcode() {
        return Opcode.FD_FIRMWARE_GET.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.FD_UPLOAD_STATUS.value;
    }


}
