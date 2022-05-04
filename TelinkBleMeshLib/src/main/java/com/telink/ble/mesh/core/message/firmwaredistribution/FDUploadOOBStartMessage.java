package com.telink.ble.mesh.core.message.firmwaredistribution;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatingMessage;

/**
 * The Firmware Distribution Upload OOB Start message is an acknowledged message
 * sent by a Firmware Distribution Client to start a firmware image upload to a Firmware Distribution Server using an out-of-band mechanism.
 */
public class FDUploadOOBStartMessage extends UpdatingMessage {

    /**
     * Upload URI Length
     * Length of the Upload URI field
     * 1 byte
     */
    public int uploadURILength;

    /**
     * Upload URI
     * URI for the firmware image source
     * 1 to 255 bytes
     */
    public int uploadURI;

    /**
     * Upload Firmware ID
     * The Firmware ID value used to generate the URI query string
     * Variable length
     */
    public int uploadFirmwareID;

    public FDUploadOOBStartMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    public static FDUploadOOBStartMessage getSimple(int destinationAddress, int appKeyIndex) {
        FDUploadOOBStartMessage message = new FDUploadOOBStartMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        return message;
    }

    @Override
    public int getOpcode() {
        return Opcode.FD_UPLOAD_START.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.FD_UPLOAD_STATUS.value;
    }


}
