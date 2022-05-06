package com.telink.ble.mesh.core.message.firmwaredistribution;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatingMessage;

public class FDReceiversDeleteAllMessage extends UpdatingMessage {


    public FDReceiversDeleteAllMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    public static FDReceiversDeleteAllMessage getSimple(int destinationAddress, int appKeyIndex) {
        FDReceiversDeleteAllMessage message = new FDReceiversDeleteAllMessage(destinationAddress, appKeyIndex);
        message.setResponseMax(1);
        return message;
    }

    @Override
    public int getOpcode() {
        return Opcode.FD_RECEIVERS_DELETE_ALL.value;
    }

    @Override
    public int getResponseOpcode() {
        return Opcode.FD_RECEIVERS_STATUS.value;
    }

}
