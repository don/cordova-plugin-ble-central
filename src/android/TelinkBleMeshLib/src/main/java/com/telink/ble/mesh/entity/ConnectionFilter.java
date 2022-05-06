package com.telink.ble.mesh.entity;

public class ConnectionFilter {
    public static final int TYPE_MESH_ADDRESS = 0;
    public static final int TYPE_MAC_ADDRESS = 1;
    public static final int TYPE_DEVICE_NAME = 2;


    public int type;

    //
    public Object target;

    public ConnectionFilter(int type, Object target) {
        this.type = type;
        this.target = target;
    }
}
