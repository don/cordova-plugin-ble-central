package com.telink.ble.mesh.core.message.firmwaredistribution;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatingMessage;

/**
 * The Firmware Distribution Upload Cancel message is an acknowledged message sent by a Firmware Distribution Client to stop a firmware image upload to a Firmware Distribution Server.
 * The response to a Firmware Distribution Upload Cancel message is a Firmware Distribution Upload Status message.
 */
public class FDUploadCancelMessage extends UpdatingMessage {


    public FDUploadCancelMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    public static FDUploadCancelMessage getSimple(int destinationAddress, int appKeyIndex) {
        FDUploadCancelMessage message = new FDUploadCancelMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        return message;
    }

    @Override
    public int getOpcode() {
        return Opcode.FD_UPLOAD_CANCEL.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.FD_UPLOAD_STATUS.value;
    }


}
