// (c) 2018 Tim Burke
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package com.megster.cordova.ble.central;

import android.bluetooth.BluetoothGatt;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import java.util.ArrayList;
import java.util.List;

public class SequentialCallbackContext {
    private boolean subscribed;
    private int sequence;
    private final CallbackContext context;

    public SequentialCallbackContext(CallbackContext context) {
        this.context = context;
        this.sequence = 0;
    }

    private int getNextSequenceNumber() {
        synchronized(this) {
            return this.sequence++; 
        }
    }

    private PluginResult createSequentialResult(byte[] data) {
        List<PluginResult> resultList = new ArrayList<PluginResult>(2);

        PluginResult dataResult = new PluginResult(PluginResult.Status.OK, data);
        PluginResult sequenceResult = new PluginResult(PluginResult.Status.OK, this.getNextSequenceNumber()); 

        resultList.add(dataResult);
        resultList.add(sequenceResult);
        
        return new PluginResult(PluginResult.Status.OK, resultList);
    }

    public void sendSequentialResult(byte[] data) {
        PluginResult result = this.createSequentialResult(data);
        result.setKeepCallback(true);

        this.context.sendPluginResult(result);
    }

    public boolean completeSubscription(int status) {
        if (subscribed) {
            return true;
        }

        subscribed = true;
        boolean success = status == BluetoothGatt.GATT_SUCCESS;
        PluginResult result;
        if (success) {
            result = new PluginResult(PluginResult.Status.OK, "registered");
            result.setKeepCallback(true);
        } else {
            result = new PluginResult(PluginResult.Status.ERROR, "Write descriptor failed: " + status);
        }
        this.context.sendPluginResult(result);
        return success;
    }
}