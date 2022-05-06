package com.telink.ble.mesh.core.message.firmwaredistribution;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatingMessage;


/**
 * The Firmware Distribution Apply message is an acknowledged message
 * sent from a Firmware Distribution Client to a Firmware Distribution Server to apply the firmware image on the Updating nodes.
 * The response to a Firmware Distribution Apply message is a Firmware Distribution Status message.
 */
public class FDApplyMessage extends UpdatingMessage {


    public FDApplyMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    public static FDApplyMessage getSimple(int destinationAddress, int appKeyIndex) {
        FDApplyMessage message = new FDApplyMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        return message;
    }

    @Override
    public int getOpcode() {
        return Opcode.FD_APPLY.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.FD_STATUS.value;
    }

}
