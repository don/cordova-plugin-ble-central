package com.telink.ble.mesh.core.access;

public class BlobTransfer {
    Direction direction = Direction.INITIATOR_TO_DISTRIBUTOR;

    byte[] firmware;



    enum Direction {
        /**
         * initiator to distributor
         */
        INITIATOR_TO_DISTRIBUTOR,

        /**
         * distributor to updating nodes
         */
        DISTRIBUTOR_TO_NODE
    }
}
