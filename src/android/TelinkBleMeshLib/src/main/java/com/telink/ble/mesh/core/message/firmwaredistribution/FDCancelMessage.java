package com.telink.ble.mesh.core.message.firmwaredistribution;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatingMessage;

/**
 * The Firmware Distribution Cancel message is an acknowledged message
 * sent by a Firmware Distribution Client to stop the firmware image distribution from a Firmware Distribution Server.
 * The response to a Firmware Distribution Cancel message is a Firmware Distribution Status message.
 */
public class FDCancelMessage extends UpdatingMessage {


    public FDCancelMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    public static FDCancelMessage getSimple(int destinationAddress, int appKeyIndex) {
        FDCancelMessage message = new FDCancelMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        return message;
    }

    @Override
    public int getOpcode() {
        return Opcode.FD_CANCEL.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.FD_STATUS.value;
    }

}
