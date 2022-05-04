/********************************************************************************************************
 * @file     MeshFirmwareParser.java 
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
package com.telink.ble.mesh.core.access;

import java.util.zip.CRC32;

/**
 * Created by kee on 2019/10/12.
 */

public class MeshFirmwareParser {

//    private static final int DEFAULT_OBJECT_ID = 0x8877665544332211L;

    private static final int DEFAULT_BLOCK_SIZE = 4 * 1024;

    private static final int DEFAULT_CHUNK_SIZE = 256;

    private byte[] firmwareData;

//    private long objectId = DEFAULT_OBJECT_ID;

    private int objectSize;

    private int mBlockSize = DEFAULT_BLOCK_SIZE;

    private int mChunkSize = DEFAULT_CHUNK_SIZE;

    private int curBlockIndex;

    private int curChunkIndex;

    private int totalBlockNumber;

    private int totalChunkNumber;

    private int progress = -1;

    public void reset(byte[] data) {
        this.firmwareData = data;
        this.objectSize = data.length;

        this.curBlockIndex = -1;
        this.curChunkIndex = -1;
        progress = -1;
        totalBlockNumber = (int) Math.ceil(((double) objectSize) / mBlockSize);
        totalChunkNumber = (int) Math.ceil(((double) objectSize) / mChunkSize);
    }

    public void reset(byte[] data, int blockSize, int chunkSize) {
        this.mBlockSize = blockSize;
        this.mChunkSize = chunkSize;
        this.reset(data);
    }


    /**
     * prepare for next block
     *
     * @return if has next
     */
    public int nextBlock() {
        curChunkIndex = -1;
        return ++curBlockIndex;
    }

    public void resetBlock() {
        curBlockIndex = -1;
    }

    public boolean hasNextBlock() {
        return curBlockIndex + 1 < totalBlockNumber;
    }

    public int getCurBlockSize() {
        int blockSize;

        if (hasNextBlock() || (objectSize % mBlockSize) == 0) {
            // not the last block or last block size is mBlockSize
            blockSize = mBlockSize;
        } else {
            blockSize = objectSize % mBlockSize;
        }
        return blockSize;
    }


    /**
     * refresh progress by chunk/total
     *
     * @return progress
     */
    public boolean validateProgress() {
        // Math.ceil(mBlockSize/mChunkSize)
        float chunkNumberOffset = curBlockIndex * (mBlockSize / mChunkSize) + (curChunkIndex + 1);
        // max 99
        int progress = (int) (chunkNumberOffset * 99 / totalChunkNumber);
        if (progress <= this.progress) {
            return false;
        }
        this.progress = progress;
        return true;
    }

    public int getProgress() {
        return progress;
    }

    /**
     * generate next chunk at current block
     *
     * @return chunk-message or null when all chunk sent
     */
    public byte[] nextChunk() {
        int chunkNumber;
        double blockSize = getCurBlockSize();

        chunkNumber = (int) Math.ceil(blockSize / mChunkSize);

        if (curChunkIndex + 1 < chunkNumber) {
            // has next
            curChunkIndex++;
            int chunkSize;
            if (curChunkIndex + 1 < chunkNumber || blockSize % mChunkSize == 0) {
                chunkSize = mChunkSize;
            } else {
                chunkSize = (int) (blockSize % mChunkSize);
            }

            byte[] chunkData = new byte[chunkSize];
            int offset = curBlockIndex * mBlockSize + curChunkIndex * mChunkSize;
            System.arraycopy(firmwareData, offset, chunkData, 0, chunkSize);


            return chunkData;
        } else {
            return null;
        }
    }


    public byte[] chunkAt(int chunkIndex) {
        int chunkNumber;

        double blockSize = getCurBlockSize();

        chunkNumber = (int) Math.ceil(blockSize / mChunkSize);
        if (chunkIndex >= chunkNumber) return null;

        int chunkSize;
        if (chunkIndex + 1 < chunkNumber || blockSize % mChunkSize == 0) {

            chunkSize = mChunkSize;
        } else {
            chunkSize = (int) (blockSize % mChunkSize);
        }

        byte[] chunkData = new byte[chunkSize];
        int offset = curBlockIndex * mBlockSize + chunkIndex * mChunkSize;
        System.arraycopy(firmwareData, offset, chunkData, 0, chunkSize);

        return chunkData;

    }

    public int currentBlockIndex() {
        return curBlockIndex;
    }

    public int currentChunkIndex() {
        return curChunkIndex;
    }

    public int getObjectSize() {
        return objectSize;
    }

    public int getBlockSize() {
        return mBlockSize;
    }

    public int getChunkSize() {
        return mChunkSize;
    }

    /**
     * get current block checksum
     */
    public int getBlockChecksum() {
        int blockSize = getCurBlockSize();
        byte[] blockData = new byte[blockSize];
        System.arraycopy(firmwareData, curBlockIndex * mBlockSize, blockData, 0, blockSize);
        CRC32 crc32 = new CRC32();
        crc32.update(blockData);
        return (int) crc32.getValue();
    }
}
