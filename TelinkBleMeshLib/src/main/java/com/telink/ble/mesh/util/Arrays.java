/********************************************************************************************************
 * @file Arrays.java
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
package com.telink.ble.mesh.util;

import android.text.TextUtils;

import java.io.UnsupportedEncodingException;
import java.security.SecureRandom;

/**
 * array util
 */
public final class Arrays {
    public static final char[] HEX_BASIC = "0123456789ABCDEF".toCharArray();

    private Arrays() {
    }

    /**
     * reverse array
     *
     * @param a
     * @return
     */
    public static byte[] reverse(byte[] a) {

        if (a == null)
            return null;

        int p1 = 0, p2 = a.length;
        byte[] result = new byte[p2];

        while (--p2 >= 0) {
            result[p2] = a[p1++];
        }

        return result;
    }

    /**
     * reverse part of array
     *
     * @param arr
     * @param begin
     * @param end
     * @return
     */
    public static byte[] reverse(byte[] arr, int begin, int end) {

        while (begin < end) {
            byte temp = arr[end];
            arr[end] = arr[begin];
            arr[begin] = temp;
            begin++;
            end--;
        }

        return arr;
    }

    /**
     * compare two arrays
     *
     * @param array1
     * @param array2
     * @return
     */
    public static boolean equals(byte[] array1, byte[] array2) {

        if (array1 == array2) {
            return true;
        }

        if (array1 == null || array2 == null || array1.length != array2.length) {
            return false;
        }

        for (int i = 0; i < array1.length; i++) {
            if (array1[i] != array2[i]) {
                return false;
            }
        }

        return true;
    }

    public static String bytesToString(byte[] array) {

        if (array == null) {
            return "null";
        }

        if (array.length == 0) {
            return "[]";
        }

        StringBuilder sb = new StringBuilder(array.length * 6);
        sb.append('[');
        sb.append(array[0]);
        for (int i = 1; i < array.length; i++) {
            sb.append(", ");
            sb.append(array[i]);
        }
        sb.append(']');
        return sb.toString();
    }

    public static String bytesToString(byte[] data, String charsetName) throws UnsupportedEncodingException {
        return new String(data, charsetName);
    }


    public static String bytesToHexString(byte[] array) {
        return bytesToHexString(array, "");
    }

    /**
     * array to hex string
     */
    public static String bytesToHexString(byte[] array, String separator) {
        if (array == null || array.length == 0)
            return "";

//        final boolean sepNul = TextUtils.isEmpty(separator);
        final boolean sepNul = separator == null || separator.length() == 0;
        StringBuilder hexResult = new StringBuilder();
        int ai;
        for (int i = 0; i < array.length; i++) {
            ai = array[i] & 0xFF;
            if (i != 0 && !sepNul) {
                hexResult.append(separator);
            }
            hexResult.append(HEX_BASIC[ai >>> 4]).append(HEX_BASIC[ai & 0x0F]);
        }
        return hexResult.toString();
    }

    public static byte[] hexToBytes(String hexStr) {
        if (hexStr == null) return null;
        if (hexStr.length() == 1) {
            hexStr = "0" + hexStr;
        }
        int length = hexStr.length() / 2;
        byte[] result = new byte[length];

        for (int i = 0; i < length; i++) {
            result[i] = (byte) Integer.parseInt(hexStr.substring(i * 2, i * 2 + 2), 16);
        }

        return result;
    }

    public static byte[] generateRandom(int length) {
        byte[] data = new byte[length];
        SecureRandom secureRandom = new SecureRandom();
        secureRandom.nextBytes(data);
        return data;
    }
}
