/********************************************************************************************************
 * @file     FileSystem.java 
 *
 * @brief    for TLSR chips
 *
 * @author	 telink
 * @date     Sep. 30, 2010
 *
 * @par      Copyright (c) 2010, Telink Semiconductor (Shanghai) Co., Ltd.
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

import android.content.Context;
import android.os.Environment;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

public abstract class FileSystem {

    public static boolean writeAsObject(Context context, String fileName, Object obj) {

        File dir = context.getFilesDir();
        File file = new File(dir, fileName);

        FileOutputStream fos = null;
        ObjectOutputStream ops = null;

        boolean success = false;
        try {

            if (!file.exists())
                file.createNewFile();

            fos = new FileOutputStream(file);
            ops = new ObjectOutputStream(fos);

            ops.writeObject(obj);
            ops.flush();

            success = true;

        } catch (IOException e) {

        } finally {
            try {
                if (ops != null)
                    ops.close();
                if (ops != null)
                    fos.close();
            } catch (Exception e) {
            }
        }

        return success;
    }

    public static Object readAsObject(Context context, String fileName) {

        File dir = context.getFilesDir();
        File file = new File(dir, fileName);

        if (!file.exists())
            return null;

        FileInputStream fis = null;
        ObjectInputStream ois = null;

        Object result = null;
        try {

            fis = new FileInputStream(file);
            ois = new ObjectInputStream(fis);

            result = ois.readObject();
        } catch (IOException | ClassNotFoundException e) {
            MeshLogger.w("read object error : " + e.toString());
        } finally {
            try {
                if (ois != null)
                    ois.close();
            } catch (Exception e) {
            }
        }

        return result;
    }

    public static File getSettingPath() {
        File root = Environment.getExternalStorageDirectory();
        return new File(root.getAbsolutePath() + File.separator + "TelinkBleMesh");
    }

    //
    public static File writeString(File dir, String filename, String content) {

        if (!dir.exists()) {
            dir.mkdirs();
        }
        File file = new File(dir, filename);

        FileOutputStream fos;
        try {
            if (!file.exists())
                file.createNewFile();
            fos = new FileOutputStream(file);
            fos.write(content.getBytes());
            fos.flush();
            fos.close();
            return file;
        } catch (IOException e) {
        }

        return null;
    }


    public static String readString(File file) {
        if (!file.exists())
            return "";
        try {
            FileReader fr = new FileReader(file);
            BufferedReader br = new BufferedReader(fr);
            String line = null;

            StringBuilder sb = new StringBuilder();

            while ((line = br.readLine()) != null) {
                sb.append(line);
            }

            br.close();
            fr.close();
            return sb.toString();

        } catch (IOException e) {

        }

        return "";
    }
}