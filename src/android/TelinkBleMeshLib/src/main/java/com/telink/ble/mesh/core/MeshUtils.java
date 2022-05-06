/********************************************************************************************************
 * @file MeshUtils.java
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date Sep. 30, 2010
 *
 * @par Copyright (c) 2010, Telink Semiconductor (Shanghai) Co., Ltd.
 *           All rights reserved.
 *
 *			 The information contained herein is confidential and proprietary property of Telink 
 * 		     Semiconductor (Shanghai) Co., Ltd. and is available under the terms 
 *			 of Commercial License Agreement between Telink Semiconductor (Shanghai) 
 *			 Co., Ltd. and the licensee in separate contract or the terms described here-in. 
 *           This heading MUST NOT be removed from this file.
 *
 * 			 Licensees are granted free, non-transferable use of the information in this 
 *			 file under Mutual Non-Disclosure Agreement. NO WARRENTY of ANY KIND is provided. 
 *
 *******************************************************************************************************/
package com.telink.ble.mesh.core;

import android.os.ParcelUuid;

import com.telink.ble.mesh.core.ble.MeshScanRecord;
import com.telink.ble.mesh.core.ble.UUIDInfo;
import com.telink.ble.mesh.util.Arrays;

import java.io.ByteArrayInputStream;
import java.nio.ByteOrder;
import java.security.SecureRandom;
import java.security.Signature;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.security.interfaces.ECPublicKey;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import androidx.annotation.NonNull;

public final class MeshUtils {

    //    public static final int DEVICE_ADDRESS_MAX = 0xFFFE; // 0x00FF

    public static final int UNICAST_ADDRESS_MAX = 0x7FFF; // 0x7F00
    public static final int UNICAST_ADDRESS_MIN = 0x0001; // 0x0001

    public static final String CHARS = "123456789aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ+-*/<>/?!@#$%^&;'[]{}|,.";

    public static final int ADDRESS_BROADCAST = 0xFFFF;

    // 1970 -- 2000 offset second
    public static final long TAI_OFFSET_SECOND = 946684800;

    public static final long UNSIGNED_INTEGER_MAX = 0xFFFFFFFFL;

    private static SecureRandom rng;

    private MeshUtils() {
    }

    public static byte[] generateRandom(int length) {

        byte[] data = new byte[length];

        synchronized (MeshUtils.class) {
            if (rng == null) {
                rng = new SecureRandom();
            }
        }

        rng.nextBytes(data);

        return data;
    }

    public static long getTaiTime() {
        return Calendar.getInstance().getTimeInMillis() / 1000 - TAI_OFFSET_SECOND;
    }

    /**
     * Mesh V1.0 3.7.3.1 Operation codes
     * Opcode Format
     * Notes
     * 0xxxxxxx (excluding 01111111)
     * 1-octet Opcodes
     * 01111111
     * Reserved for Future Use
     * 10xxxxxx xxxxxxxx
     * 2-octet Opcodes
     * 11xxxxxx zzzzzzzz
     * 3-octet Opcodes
     */

    /*public static OpcodeType getOpType(byte opFst) {
//        final int opVal = getValue();
        return (opFst & bit(7)) != 0
                ?
                ((opFst & bit(6)) != 0 ? OpcodeType.VENDOR : OpcodeType.SIG_2)
                :
                OpcodeType.SIG_1;
    }*/
    public static int bit(int n) {
        return 1 << n;
    }

    public static byte[] generateChars(int length) {

        int charLen = CHARS.length() - 1;
        int charAt;

        byte[] data = new byte[length];

        for (int i = 0; i < length; i++) {
            charAt = (int) Math.round(Math.random() * charLen);
            data[i] = (byte) CHARS.charAt(charAt);
        }

        return data;
    }


    /**
     * convert byte buffer to integer
     *
     * @param buffer target buffer
     * @param order  {@link ByteOrder#BIG_ENDIAN} and {@link ByteOrder#LITTLE_ENDIAN}
     * @return int value, max 32-bit length
     */
    public static int bytes2Integer(byte[] buffer, ByteOrder order) {
        int re = 0;
        int valLen = (buffer.length > 4 ? 4 : buffer.length);
        for (int i = 0; i < valLen; i++) {
            if (order == ByteOrder.LITTLE_ENDIAN) {
                re |= (buffer[i] & 0xFF) << (8 * i);
            } else if (order == ByteOrder.BIG_ENDIAN) {
                re |= (buffer[i] & 0xFF) << (8 * (valLen - i - 1));
            }
        }
        return re;
    }

    /**
     * @param buffer target buffer
     * @param offset buffer start position
     * @param size   selected bytes length
     * @param order  ByteOrder
     * @return int value
     */
    public static int bytes2Integer(byte[] buffer, int offset, int size, ByteOrder order) {
        int re = 0;
        int valLen = Math.min(4, size);
        for (int i = 0; i < valLen; i++) {
            if (order == ByteOrder.LITTLE_ENDIAN) {
                re |= (buffer[i + offset] & 0xFF) << (8 * i);
            } else if (order == ByteOrder.BIG_ENDIAN) {
                re |= (buffer[i + offset] & 0xFF) << (8 * (valLen - i - 1));
            }
        }
        return re;
    }

    public static long bytes2Long(byte[] buffer, int offset, int size, ByteOrder order) {
        long re = 0;
        int valLen = Math.min(8, size);
        for (int i = 0; i < valLen; i++) {
            if (order == ByteOrder.LITTLE_ENDIAN) {
                re |= (buffer[i + offset] & 0xFF) << (8 * i);
            } else if (order == ByteOrder.BIG_ENDIAN) {
                re |= (buffer[i + offset] & 0xFF) << (8 * (valLen - i - 1));
            }
        }
        return re;
    }

    public static byte[] integer2Bytes(int i, int size, ByteOrder order) {
        if (size > 4) size = 4;
        byte[] re = new byte[size];
        for (int j = 0; j < size; j++) {
            if (order == ByteOrder.LITTLE_ENDIAN) {
                re[j] = (byte) (i >> (8 * j));
            } else {
                re[size - j - 1] = (byte) (i >> (8 * j));
            }
        }
        return re;
    }

    /**
     * @param hex input
     * @return int value
     */
    public static int hexString2Int(String hex, ByteOrder order) {
        byte[] buf = Arrays.hexToBytes(hex);
        return bytes2Integer(buf, order);
    }

    public static byte[] sequenceNumber2Buffer(int sequenceNumber) {
        return integer2Bytes(sequenceNumber, 3, ByteOrder.BIG_ENDIAN);
    }

    public static byte generateAid(byte[] key) {
        return Encipher.k4(key);
    }

    public static int getMicSize(byte szmic) {
        return szmic == 0 ? 4 : 8;
    }

    public static boolean validUnicastAddress(int address) {
        return (address & 0xFFFF) <= UNICAST_ADDRESS_MAX && (address & 0xFFFF) >= UNICAST_ADDRESS_MIN;
    }

    public static boolean validGroupAddress(int address) {
        return (address & 0xFFFF) < 0xFF00 && (address & 0xFFFF) >= 0xC000;
    }

    public static double mathLog2(int i) {
        return Math.log(i) / Math.log(2);
    }

    public static long unsignedIntegerCompare(int a, int b) {
        return (a & UNSIGNED_INTEGER_MAX) - (b & UNSIGNED_INTEGER_MAX);
    }

    static final String FORMAT_1_BYTES = "%02X";
    static final String FORMAT_2_BYTES = "%04X";
    static final String FORMAT_3_BYTES = "%06X";
    static final String FORMAT_4_BYTES = "%08X";

    public static String formatIntegerByHex(int value) {
        if (value <= -1) {
            return String.format(FORMAT_4_BYTES, value);
        } else if (value <= 0xFF) {
            return String.format(FORMAT_1_BYTES, value);
        } else if (value <= 0xFFFF) {
            return String.format(FORMAT_2_BYTES, value);
        } else {
            return String.format(FORMAT_3_BYTES, value);
        }
    }

    /**
     * @param unprovisioned true: get provision service data, false: get proxy service data
     */
    public static byte[] getMeshServiceData(byte[] scanRecord, boolean unprovisioned) {
        MeshScanRecord meshScanRecord = MeshScanRecord.parseFromBytes(scanRecord);
        return meshScanRecord.getServiceData(ParcelUuid.fromString((unprovisioned ? UUIDInfo.SERVICE_PROVISION : UUIDInfo.SERVICE_PROXY).toString()));
    }

    /**
     * get missing bit position
     */
    public static List<Integer> parseMissingBitField(@NonNull byte[] params, int offset) {
        List<Integer> missingChunks = new ArrayList<>();
        final int BYTE_LEN = 8;
        byte val;
        for (int basePosition = 0; offset < params.length; offset++, basePosition += BYTE_LEN) {
            val = params[offset];
            for (int i = 0; i < BYTE_LEN; i++) {
                boolean missing = ((val >> i) & 0b01) == 1;
                if (missing) {
                    missingChunks.add(basePosition + i);
                }
            }
        }
        return missingChunks;
    }


    /**
     * @return is certificate based supported
     */
    public static boolean isCertSupported(int oobInfo) {
        return (oobInfo & MeshUtils.bit(7)) != 0;
    }

    /**
     * @return is provisioning record supported
     */
    public static boolean isPvRecordSupported(int oobInfo) {
        return (oobInfo & MeshUtils.bit(8)) != 0;
    }

}
