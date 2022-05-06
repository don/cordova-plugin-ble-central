package com.telink.ble.mesh.core.message.firmwaredistribution;

public interface DistributorCapabilities {



    enum OOBRetrievalSupported {
        SUPPORTED(1),
        NotSupported(0);
        final int value;

        OOBRetrievalSupported(int value) {
            this.value = value;
        }
    }
}
