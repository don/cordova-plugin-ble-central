package com.telink.ble.mesh.core.message.firmwaredistribution;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatingMessage;

public class FDCapabilitiesGetMessage extends UpdatingMessage {


    public FDCapabilitiesGetMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    public static FDCapabilitiesGetMessage getSimple(int destinationAddress, int appKeyIndex) {
        FDCapabilitiesGetMessage message = new FDCapabilitiesGetMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        return message;
    }

    @Override
    public int getOpcode() {
        return Opcode.FD_CAPABILITIES_GET.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.FD_CAPABILITIES_STATUS.value;
    }

}
