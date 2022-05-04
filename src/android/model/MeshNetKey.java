package com.megster.cordova.ble.central.model;

import java.io.Serializable;

/**
 * network key used for network layer encryption
 */
public class MeshNetKey implements MeshKey, Serializable {
    public String name;
    public int index;
    public byte[] key;

    public MeshNetKey(String name, int index, byte[] key) {
        this.name = name;
        this.index = index;
        this.key = key;
    }

    @Override
    public String getName() {
        return this.name;
    }

    @Override
    public int getIndex() {
        return this.index;
    }

    @Override
    public byte[] getKey() {
        return this.key;
    }
}
