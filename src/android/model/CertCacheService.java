/********************************************************************************************************
 * @file CertCacheService.java
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date Sep. 30, 2017
 *
 * @par Copyright (c) 2017, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
 *
 *          Licensed under the Apache License, Version 2.0 (the "License");
 *          you may not use this file except in compliance with the License.
 *          You may obtain a copy of the License at
 *
 *              http://www.apache.org/licenses/LICENSE-2.0
 *
 *          Unless required by applicable law or agreed to in writing, software
 *          distributed under the License is distributed on an "AS IS" BASIS,
 *          WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *          See the License for the specific language governing permissions and
 *          limitations under the License.
 *******************************************************************************************************/
package com.megster.cordova.ble.central.model;

        import android.content.Context;

        import com.telink.ble.mesh.core.MeshUtils;
        import com.telink.ble.mesh.util.FileSystem;
        import com.telink.ble.mesh.util.MeshLogger;

        import java.io.File;
        import java.io.FilenameFilter;
        import java.nio.ByteOrder;
        import java.util.ArrayList;
        import java.util.List;

/**
 * cert cache
 */
public class CertCacheService {

    private static final String CERT_CACHE_PREFIX = "tlk_cert";

    private static final String CERT_DIR = "certs";


    private static final String CERT_CACHE_ROOT_INDEX = "root_index";

    private static final CertCacheService service = new CertCacheService();

    List<byte[]> certs = new ArrayList<>();

    // selected root cert index
    int rootIndex = -1;

    private CertCacheService() {
    }

    public static CertCacheService getInstance() {
        return service;
    }

    /**
     * load cert storage
     */
    public void load(Context context) {
        File dir = getCertDir(context);
        if (!dir.exists()) return;
        String[] targets = dir.list(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                MeshLogger.d("file in cert cache dir: " + name);
                return name.startsWith(CERT_CACHE_PREFIX);
            }
        });
        if (targets == null || targets.length == 0) {
            return;
        }
        File file;
        certs.clear();
        for (String certFile : targets) {
            file = new File(dir, certFile);
            byte[] data = FileSystem.readByteArray(file);
            if (data != null) {
                certs.add(data);
            }
        }

        loadRootIndex(context);
    }

    public byte[] getRootCert() {
        if (rootIndex != -1 && certs.size() > rootIndex) {
            return certs.get(rootIndex);
        }
        return null;
    }


    private void loadRootIndex(Context context) {
        File dir = getCertDir(context);
        File rootIdxFile = new File(dir, CERT_CACHE_ROOT_INDEX);
        if (!rootIdxFile.exists()) {
            rootIndex = -1;
            return;
        }

        byte[] data = FileSystem.readByteArray(rootIdxFile);
        if (data == null) {
            rootIndex = -1;
        } else {
            this.rootIndex = MeshUtils.bytes2Integer(data, ByteOrder.LITTLE_ENDIAN);
        }
    }

    private File getCertDir(Context context) {
        File root = context.getFilesDir();
        return new File(root, CERT_DIR);
    }


    /**
     * get firmware update cache in memory
     */
    public List<byte[]> get() {
        return this.certs;
    }

    /**
     * save cache in disk
     */
    public void addCert(Context context, byte[] certData) {
        MeshLogger.d("save cert");
        this.certs.add(certData);
        String fileName = CERT_CACHE_PREFIX + "_" + System.currentTimeMillis();
        FileSystem.writeByteArray(getCertDir(context), fileName, certData);
    }

    public void delete(Context context, int index) {
        File dir = getCertDir(context);
        if (!dir.exists()) return;
        String[] targets = dir.list(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return name.startsWith(CERT_CACHE_PREFIX);
            }
        });
        if (targets == null || targets.length < index) {
            return;
        }
        File file = new File(dir, targets[index]);
        boolean deleted = file.delete();
        MeshLogger.d("delete file at " + index + " -- " + targets[index] + " -- " + deleted);
        this.certs.remove(index);
        if (index == rootIndex) {
            rootIndex = -1;
        } else if (index < rootIndex) {
            rootIndex -= 1;
        }
        saveRootIndex(context);

    }

    /**
     * clear memory and remove file in disk
     */
    public void clear(Context context) {
        MeshLogger.d("FUCache clear");
        this.certs.clear();

        File dir = getCertDir(context);
        if (!dir.exists()) return;
        String[] targets = dir.list(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return name.startsWith(CERT_CACHE_PREFIX);
            }
        });
        if (targets == null || targets.length == 0) {
            return;
        }
        for (String fileName : targets) {
            File file = new File(dir, fileName);
            if (file.exists()) {
                file.delete();
            }
        }
        this.rootIndex = -1;
        saveRootIndex(context);
    }

    public int getRootIndex() {
        return rootIndex;
    }

    public void setRootIndex(Context context, int i) {
        if (this.rootIndex == i) {
            this.rootIndex = -1;
        } else {
            this.rootIndex = i;
        }
        saveRootIndex(context);
    }

    private void saveRootIndex(Context context) {
        byte[] indexData = MeshUtils.integer2Bytes(this.rootIndex, 4, ByteOrder.LITTLE_ENDIAN);
        FileSystem.writeByteArray(getCertDir(context), CERT_CACHE_ROOT_INDEX, indexData);
    }


}
