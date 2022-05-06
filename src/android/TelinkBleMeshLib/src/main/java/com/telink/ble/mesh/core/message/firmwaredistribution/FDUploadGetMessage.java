package com.telink.ble.mesh.core.message.firmwaredistribution;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatingMessage;

/**
 * The Firmware Distribution Upload Get message is an acknowledged message sent by a Firmware Distribution Client to check the status of a firmware image upload to a Firmware Distribution Server.
 * The response to a Firmware Distribution Upload Get message is a Firmware Distribution Upload Status message.
 */
public class FDUploadGetMessage extends UpdatingMessage {


    public FDUploadGetMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    public static FDUploadGetMessage getSimple(int destinationAddress, int appKeyIndex) {
        FDUploadGetMessage message = new FDUploadGetMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        return message;
    }

    @Override
    public int getOpcode() {
        return Opcode.FD_UPLOAD_GET.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.FD_UPLOAD_STATUS.value;
    }


}
