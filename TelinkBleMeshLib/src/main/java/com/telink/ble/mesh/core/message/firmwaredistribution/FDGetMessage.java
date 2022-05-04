package com.telink.ble.mesh.core.message.firmwaredistribution;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatingMessage;

public class FDGetMessage extends UpdatingMessage {


    public FDGetMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    public static FDGetMessage getSimple(int destinationAddress, int appKeyIndex) {
        FDGetMessage message = new FDGetMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        return message;
    }

    @Override
    public int getOpcode() {
        return Opcode.FD_GET.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.FD_STATUS.value;
    }


}
