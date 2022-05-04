package com.megster.cordova.ble.central.model;

import java.io.Serializable;

/**
 * bridging table format
 */
public class BridgingTable implements Serializable {
    /**
     * Allowed directions for the bridged traffic
     * 8 bits
     */
    public byte directions;

    /**
     * NetKey Index of the first subnet
     * 12 bits
     */
    public int netKeyIndex1;

    /**
     * NetKey Index of the second subnet
     * 12 bits
     */
    public int netKeyIndex2;

    /**
     * Address of the node in the first subnet
     * 16 bits
     */
    public int address1;

    /**
     * Address of the node in the second subnet
     * 16 bits
     */
    public int address2;

    public enum Direction {

        // unidirectional
        UNIDIRECTIONAL(1, "UNIDIRECTIONAL"),
        // bidirectional
        BIDIRECTIONAL(2, "BIDIRECTIONAL");

        public final int value;
        public final String desc;

        Direction(int value, String desc) {
            this.value = value;
            this.desc = desc;
        }

        public static Direction getByValue(int value) {
            for (Direction direction :
                    values()) {
                if (direction.value == value) {
                    return direction;
                }
            }
            return UNIDIRECTIONAL;
        }
    }
}
