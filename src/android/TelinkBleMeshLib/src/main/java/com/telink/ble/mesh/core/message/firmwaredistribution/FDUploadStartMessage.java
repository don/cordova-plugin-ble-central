package com.telink.ble.mesh.core.message.firmwaredistribution;

import com.telink.ble.mesh.core.message.Opcode;
import com.telink.ble.mesh.core.message.firmwareupdate.UpdatingMessage;

/**
 * The Firmware Distribution Upload Start message is an acknowledged message sent by a Firmware Distribution Client to start a firmware image upload to a Firmware Distribution Server.
 * The response to a Firmware Distribution Upload Start message is a Firmware Distribution Upload Status message.
 */
public class FDUploadStartMessage extends UpdatingMessage {

    /**
     * Upload TTL
     * Time To Live value used in a firmware image upload
     * 1 byte
     */
    public int uploadTTL;

    /**
     * Upload Timeout Base
     * Used to compute the timeout of the firmware image upload
     * 2 bytes
     */
    public int uploadTimeoutBase;

    /**
     * Upload BLOB ID
     * BLOB identifier for the firmware image
     * 8 bytes
     */
    public int uploadBLOBID;

    /**
     * Upload Firmware Size
     * Firmware image size (in octets)
     * 4 bytes
     */
    public int uploadFirmwareSize;

    /**
     * Upload Firmware Metadata Length
     * Size of the Upload Firmware Metadata field
     * 1 byte
     */
    public int uploadFirmwareMetadataLength;

    /**
     * Upload Firmware Metadata
     * Vendor-specific firmware metadata
     * 1 to 255 bytes
     */
    public int uploadFirmwareMetadata;

    /**
     * Upload Firmware ID
     * The Firmware ID identifying the firmware image being uploaded
     * Variable
     */
    public int uploadFirmwareID;


    public FDUploadStartMessage(int destinationAddress, int appKeyIndex) {
        super(destinationAddress, appKeyIndex);
    }

    public static FDUploadStartMessage getSimple(int destinationAddress, int appKeyIndex) {
        FDUploadStartMessage message = new FDUploadStartMessage(destinationAddress, appKeyIndex);
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
