package com.megster.cordova.ble.central;


import android.content.Context;
import android.util.Log;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.megster.cordova.ble.central.model.AppSettings;
import com.megster.cordova.ble.central.model.MeshInfo;
import com.megster.cordova.ble.central.model.NetworkingDevice;
import com.megster.cordova.ble.central.model.NetworkingState;
import com.megster.cordova.ble.central.model.NodeInfo;

import com.megster.cordova.ble.central.model.PrivateDevice;
import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.access.BindingBearer;
import com.telink.ble.mesh.core.message.MeshSigModel;
import com.telink.ble.mesh.core.message.config.ConfigStatus;
import com.telink.ble.mesh.core.message.config.ModelPublicationSetMessage;
import com.telink.ble.mesh.core.message.config.ModelPublicationStatusMessage;
import com.telink.ble.mesh.entity.AdvertisingDevice;
import com.telink.ble.mesh.entity.BindingDevice;
import com.telink.ble.mesh.entity.CompositionData;
import com.telink.ble.mesh.entity.ModelPublication;
import com.telink.ble.mesh.entity.ProvisioningDevice;
import com.telink.ble.mesh.foundation.Event;
import com.telink.ble.mesh.foundation.EventListener;
import com.telink.ble.mesh.foundation.MeshController;
import com.telink.ble.mesh.foundation.MeshService;
import com.telink.ble.mesh.foundation.event.BindingEvent;
import com.telink.ble.mesh.foundation.event.BluetoothEvent;
import com.telink.ble.mesh.foundation.event.ProvisioningEvent;
import com.telink.ble.mesh.foundation.event.ScanEvent;
import com.telink.ble.mesh.foundation.event.StatusNotificationEvent;
import com.telink.ble.mesh.foundation.parameter.BindingParameters;
import com.telink.ble.mesh.foundation.parameter.ProvisioningParameters;
import com.telink.ble.mesh.foundation.parameter.ScanParameters;
import com.telink.ble.mesh.util.Arrays;
import com.telink.ble.mesh.util.MeshLogger;

import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.List;
import android.os.Handler;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * TODO: Implement these functions
 * mListAdapter update where ever we are doing - notify to cordova there.
 *
 @Override
 public void finish() {
 super.finish();
 MeshService.getInstance().idle(false);
 }

 @Override
 protected void onDestroy() {
 super.onDestroy();
 TelinkMeshApplication.getInstance().removeEventListener(this);
 }

 */


public class DeviceProvisioning implements EventListener<String> {
  String TAG = "BleMeshPlugin.DeviceProvisioning";
  private List<NetworkingDevice> devices = new ArrayList<>();
  private Context ctx;
  private Context appCtx;
  private CallbackContext callbackContext;

  /**
   * local mesh info
   */
  private MeshInfo mesh;
  private Handler mHandler;
  private boolean isPubSetting = false;
  private boolean isScanning = false;

  /**
   * data adapter
   */
//  private DeviceProvisionListAdapter mListAdapter;

  public void initialize(Context ctx, Context actCtx, CallbackContext callbackContext) {
    this.ctx = ctx;
    this.appCtx = actCtx;
    this.callbackContext = callbackContext;

    TelinkBleMeshHandler.getInstance().addEventListener(ProvisioningEvent.EVENT_TYPE_PROVISION_BEGIN, this);
    TelinkBleMeshHandler.getInstance().addEventListener(ProvisioningEvent.EVENT_TYPE_PROVISION_SUCCESS, this);
    TelinkBleMeshHandler.getInstance().addEventListener(ProvisioningEvent.EVENT_TYPE_PROVISION_FAIL, this);
    TelinkBleMeshHandler.getInstance().addEventListener(BindingEvent.EVENT_TYPE_BIND_SUCCESS, this);
    TelinkBleMeshHandler.getInstance().addEventListener(BindingEvent.EVENT_TYPE_BIND_FAIL, this);
    TelinkBleMeshHandler.getInstance().addEventListener(ScanEvent.EVENT_TYPE_SCAN_TIMEOUT, this);
    TelinkBleMeshHandler.getInstance().addEventListener(ScanEvent.EVENT_TYPE_DEVICE_FOUND, this);
    TelinkBleMeshHandler.getInstance().addEventListener(ModelPublicationStatusMessage.class.getName(), this);
    mesh = TelinkBleMeshHandler.getInstance().getMeshInfo();
    startScan();
  }

  public void stop() {
    TelinkBleMeshHandler.getInstance().removeEventListener(this);
  }

  private void startScan() {
    ScanParameters parameters = ScanParameters.getDefault(false, false);
    parameters.setScanTimeout(10 * 1000);
    MeshService.getInstance().startScan(parameters);
  }

  @Override
  public void performed(Event<String> event) {
    // TODO: Add super.performed - actions from baseactivity. and hadle - EVENT_TYPE_SCAN_LOCATION_WARNING, EVENT_TYPE_BLUETOOTH_STATE_CHANGE
    // TODO: figure out if this must be running in a separate thread or same thread ?

    if (event.getType().equals(ScanEvent.EVENT_TYPE_SCAN_LOCATION_WARNING)) {
      Log.w(TAG, "EVENT_TYPE_SCAN_LOCATON_WARNING");
      // TODO: ARIHANT - Send a message to cordova to show a dialog box. in case of error events.
//      if (!SharedPreferenceHelper.isLocationIgnore(this)) {
//        boolean showDialog;
//
//        if (this instanceof MainActivity) {
//          showDialog = MeshService.getInstance().getCurrentMode() == MeshController.Mode.MODE_AUTO_CONNECT;
//        } else {
//          showDialog = true;
//        }
//        if (showDialog) {
//
//          runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//              showLocationDialog();
//            }
//          });
//        }
//      }
    }
    else if (event.getType().equals(BluetoothEvent.EVENT_TYPE_BLUETOOTH_STATE_CHANGE)) {
      Log.w(TAG, "EVENT_TYPE_BLUETOOTH_STATE_CHANGE");
      // TODO: ARIHANT - Send a message to cordova to show a dialog box. in case of error events.
//      int state = ((BluetoothEvent) event).getState();
//      if (state == BluetoothAdapter.STATE_OFF) {
//        showBleStateDialog();
//      } else if (state == BluetoothAdapter.STATE_ON) {
//        dismissBleStateDialog();
//      }
    }
    else if (event.getType().equals(ScanEvent.EVENT_TYPE_SCAN_TIMEOUT)) {
        Log.w(TAG, "EVENT_TYPE_SCAN_TIMEOUT");
//      enableUI(true);

    } else if (event.getType().equals(ProvisioningEvent.EVENT_TYPE_PROVISION_BEGIN)) {
      onProvisionStart((ProvisioningEvent) event);
    } else if (event.getType().equals(ProvisioningEvent.EVENT_TYPE_PROVISION_SUCCESS)) {
      onProvisionSuccess((ProvisioningEvent) event);
    } else if (event.getType().equals(ProvisioningEvent.EVENT_TYPE_PROVISION_FAIL)) {
      onProvisionFail((ProvisioningEvent) event);

      // provision next when provision failed
      provisionNext();
    } else if (event.getType().equals(BindingEvent.EVENT_TYPE_BIND_SUCCESS)) {
      onKeyBindSuccess((BindingEvent) event);
    } else if (event.getType().equals(BindingEvent.EVENT_TYPE_BIND_FAIL)) {
      onKeyBindFail((BindingEvent) event);

      // provision next when binding fail
      provisionNext();
    } else if (event.getType().equals(ScanEvent.EVENT_TYPE_DEVICE_FOUND)) {
      AdvertisingDevice device = ((ScanEvent) event).getAdvertisingDevice();
      onDeviceFound(device);
    } else if (event.getType().equals(ModelPublicationStatusMessage.class.getName())) {
      MeshLogger.d("pub setting status: " + isPubSetting);
      if (!isPubSetting) {
        return;
      }
      mHandler.removeCallbacks(timePubSetTimeoutTask);
      final ModelPublicationStatusMessage statusMessage = (ModelPublicationStatusMessage) ((StatusNotificationEvent) event).getNotificationMessage().getStatusMessage();

      if (statusMessage.getStatus() == ConfigStatus.SUCCESS.code) {
        onTimePublishComplete(true, "time pub set success");
      } else {
        onTimePublishComplete(false, "time pub set status err: " + statusMessage.getStatus());
        MeshLogger.log("publication err: " + statusMessage.getStatus());
      }
    }
  }

  private void onProvisionStart(ProvisioningEvent event) {
    NetworkingDevice pvDevice = getCurrentDevice(NetworkingState.PROVISIONING);
    if (pvDevice == null) return;
    pvDevice.addLog(NetworkingDevice.TAG_PROVISION, "begin");
//    mListAdapter.notifyDataSetChanged();
  }

  private void onProvisionFail(ProvisioningEvent event) {
//        ProvisioningDevice deviceInfo = event.getProvisioningDevice();

    NetworkingDevice pvDevice = getCurrentDevice(NetworkingState.PROVISIONING);
    if (pvDevice == null) {
      MeshLogger.d("pv device not found when failed");
      return;
    }
    pvDevice.state = NetworkingState.PROVISION_FAIL;
    pvDevice.addLog(NetworkingDevice.TAG_PROVISION, event.getDesc());
//    mListAdapter.notifyDataSetChanged();
  }

  private void onProvisionSuccess(ProvisioningEvent event) {

    ProvisioningDevice remote = event.getProvisioningDevice();


    NetworkingDevice pvDevice = getCurrentDevice(NetworkingState.PROVISIONING);
    if (pvDevice == null) {
      MeshLogger.d("pv device not found when provision success");
      return;
    }

    pvDevice.state = NetworkingState.BINDING;
    pvDevice.addLog(NetworkingDevice.TAG_PROVISION, "success");
    NodeInfo nodeInfo = pvDevice.nodeInfo;
    int elementCnt = remote.getDeviceCapability().eleNum;
    nodeInfo.elementCnt = elementCnt;
    nodeInfo.deviceKey = remote.getDeviceKey();
    nodeInfo.netKeyIndexes.add(mesh.getDefaultNetKey().index);
    mesh.insertDevice(nodeInfo);
    mesh.increaseProvisionIndex(elementCnt);
    mesh.saveOrUpdate(this.ctx);


    // check if private mode opened
    final boolean privateMode = SharedPreferenceHelper.isPrivateMode(this.ctx);

    // check if device support fast bind
    boolean defaultBound = false;
    if (privateMode && remote.getDeviceUUID() != null) {
      PrivateDevice device = PrivateDevice.filter(remote.getDeviceUUID());
      if (device != null) {
        MeshLogger.d("private device");
        final byte[] cpsData = device.getCpsData();
        nodeInfo.compositionData = CompositionData.from(cpsData);
        defaultBound = true;
      } else {
        MeshLogger.d("private device null");
      }
    }

    nodeInfo.setDefaultBind(defaultBound);
    pvDevice.addLog(NetworkingDevice.TAG_BIND, "action start");
//    mListAdapter.notifyDataSetChanged();
    int appKeyIndex = mesh.getDefaultAppKeyIndex();
    BindingDevice bindingDevice = new BindingDevice(nodeInfo.meshAddress, nodeInfo.deviceUUID, appKeyIndex);
    bindingDevice.setDefaultBound(defaultBound);
    bindingDevice.setBearer(BindingBearer.GattOnly);
//        bindingDevice.setDefaultBound(false);
    MeshService.getInstance().startBinding(new BindingParameters(bindingDevice));
  }

  private void onKeyBindFail(BindingEvent event) {
    NetworkingDevice deviceInList = getCurrentDevice(NetworkingState.BINDING);
    if (deviceInList == null) return;

    deviceInList.state = NetworkingState.BIND_FAIL;
    deviceInList.addLog(NetworkingDevice.TAG_BIND, "failed - " + event.getDesc());
//    mListAdapter.notifyDataSetChanged();
    mesh.saveOrUpdate(this.ctx);
  }

  private void onKeyBindSuccess(BindingEvent event) {
    BindingDevice remote = event.getBindingDevice();

    NetworkingDevice pvDevice = getCurrentDevice(NetworkingState.BINDING);
    if (pvDevice == null) {
      MeshLogger.d("pv device not found when bind success");
      return;
    }
    pvDevice.addLog(NetworkingDevice.TAG_BIND, "success");
    pvDevice.nodeInfo.bound = true;
    // if is default bound, composition data has been valued ahead of binding action
    if (!remote.isDefaultBound()) {
      pvDevice.nodeInfo.compositionData = remote.getCompositionData();
    }

    if (setTimePublish(pvDevice)) {
      pvDevice.state = NetworkingState.TIME_PUB_SETTING;
      pvDevice.addLog(NetworkingDevice.TAG_PUB_SET, "action start");
      isPubSetting = true;
      MeshLogger.d("waiting for time publication status");
    } else {
      // no need to set time publish
      pvDevice.state = NetworkingState.BIND_SUCCESS;
      provisionNext();
    }
//    mListAdapter.notifyDataSetChanged();
    mesh.saveOrUpdate(this.ctx);
  }

  private void onDeviceFound(AdvertisingDevice advertisingDevice) {
    // provision service data: 15:16:28:18:[16-uuid]:[2-oobInfo]
    byte[] serviceData = MeshUtils.getMeshServiceData(advertisingDevice.scanRecord, true);
    if (serviceData == null || serviceData.length < 17) {
      MeshLogger.log("serviceData error", MeshLogger.LEVEL_ERROR);
      return;
    }

    final int uuidLen = 16;
    byte[] deviceUUID = new byte[uuidLen];


    System.arraycopy(serviceData, 0, deviceUUID, 0, uuidLen);

    final int oobInfo = MeshUtils.bytes2Integer(serviceData, 16, 2, ByteOrder.LITTLE_ENDIAN);

    if (deviceExists(deviceUUID)) {
      MeshLogger.d("device exists");
      return;
    }

    NodeInfo nodeInfo = new NodeInfo();
    nodeInfo.meshAddress = -1;
    nodeInfo.deviceUUID = deviceUUID;
    nodeInfo.macAddress = advertisingDevice.device.getAddress();

    NetworkingDevice processingDevice = new NetworkingDevice(nodeInfo);
    processingDevice.bluetoothDevice = advertisingDevice.device;
    if (AppSettings.DRAFT_FEATURES_ENABLE) {
      processingDevice.oobInfo = oobInfo;
    }
    processingDevice.state = NetworkingState.IDLE;
    processingDevice.addLog(NetworkingDevice.TAG_SCAN, "device found");
    devices.add(processingDevice);
    // TODO: ARihant
    // Notify this to cordova -
//    mListAdapter.notifyDataSetChanged();
    updateDevices(devices);
  }

  private void updateDevices(List<NetworkingDevice> devices) {
    try {
    JSONObject resultObj = new JSONObject();
    JSONArray devicesArray = new JSONArray();
    for(NetworkingDevice device: devices){
      JSONObject deviceObj = new JSONObject();
      try {
        deviceObj.put("isProcessing", device.isProcessing());
        deviceObj.put("logExpand", device.logExpand);
        JSONObject nodeInfo = new JSONObject();
        nodeInfo.put("meshAddress", device.nodeInfo.meshAddress);
        nodeInfo.put("macAddress", device.nodeInfo.macAddress);
        nodeInfo.put("elementCnt", device.nodeInfo.elementCnt);
        nodeInfo.put("bound", device.nodeInfo.bound);
        nodeInfo.put("lum", device.nodeInfo.lum);
        nodeInfo.put("temp", device.nodeInfo.temp);
        nodeInfo.put("isLpn", device.nodeInfo.isLpn());
        nodeInfo.put("isOffline", device.nodeInfo.isOffline());
        nodeInfo.put("isDefaultBind", device.nodeInfo.isDefaultBind());
        nodeInfo.put("pidDesc", device.nodeInfo.getPidDesc());
        nodeInfo.put("deviceUUID", Util.convertByteToHexadecimal(device.nodeInfo.deviceUUID));
        nodeInfo.put("deviceKey", Util.convertByteToHexadecimal(device.nodeInfo.deviceKey));
        JSONArray netKeyIndexes = new JSONArray();
        for(Integer ind: device.nodeInfo.netKeyIndexes){
          netKeyIndexes.put(ind);
        }
        nodeInfo.put("netKeyIdxes", netKeyIndexes);
        deviceObj.put("nodeInfo", nodeInfo);

        devicesArray.put(deviceObj);
      } catch (Exception e) {
        Log.d(TAG, "startScanLock error = " + e.toString());
      }
    }

      resultObj.put("devices", devicesArray);
      PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
      pluginResult.setKeepCallback(true);
      callbackContext.sendPluginResult(pluginResult);
    } catch (JSONException e) {
//      e.printStackTrace();
      callbackContext.error(Util.makeError("JSONError", e.getMessage()));
    }

  }

  public void provisionNext() {
//    enableUI(false);
    NetworkingDevice waitingDevice = getNextWaitingDevice();
    if (waitingDevice == null) {
      MeshLogger.d("no waiting device found");
//      enableUI(true);
      return;
    }
    startProvision(waitingDevice);
  }
  private NetworkingDevice getNextWaitingDevice() {
    for (NetworkingDevice device : devices) {
      if (device.state == NetworkingState.WAITING) {
        return device;
      }
    }
    return null;
  }
  private void startProvision(NetworkingDevice processingDevice) {
    if (isScanning) {
      isScanning = false;
      MeshService.getInstance().stopScan();
    }

    int address = mesh.getProvisionIndex();
    MeshLogger.d("alloc address: " + address);
    if (!MeshUtils.validUnicastAddress(address)) {
//      enableUI(true);
      return;
    }

    byte[] deviceUUID = processingDevice.nodeInfo.deviceUUID;
    ProvisioningDevice provisioningDevice = new ProvisioningDevice(processingDevice.bluetoothDevice, processingDevice.nodeInfo.deviceUUID, address);
    provisioningDevice.setOobInfo(processingDevice.oobInfo);
    processingDevice.state = NetworkingState.PROVISIONING;
    processingDevice.addLog(NetworkingDevice.TAG_PROVISION, "action start -> 0x" + String.format("%04X", address));
    processingDevice.nodeInfo.meshAddress = address;
//    mListAdapter.notifyDataSetChanged();

    // check if oob exists
    byte[] oob = TelinkBleMeshHandler.getInstance().getMeshInfo().getOOBByDeviceUUID(deviceUUID);
    if (oob != null) {
      provisioningDevice.setAuthValue(oob);
    } else {
      final boolean autoUseNoOOB = SharedPreferenceHelper.isNoOOBEnable(this.ctx);
      provisioningDevice.setAutoUseNoOOB(autoUseNoOOB);
    }
    ProvisioningParameters provisioningParameters = new ProvisioningParameters(provisioningDevice);

    MeshLogger.d("provisioning device: " + provisioningDevice.toString());
    MeshService.getInstance().startProvisioning(provisioningParameters);
  }
  /**
   * set time publish after key bind success
   *
   * @param networkingDevice target
   * @return
   */
  private boolean setTimePublish(NetworkingDevice networkingDevice) {
    int modelId = MeshSigModel.SIG_MD_TIME_S.modelId;
    int pubEleAdr = networkingDevice.nodeInfo.getTargetEleAdr(modelId);
    if (pubEleAdr != -1) {
      final int period = 30 * 1000;
      final int pubAdr = 0xFFFF;
      int appKeyIndex = TelinkBleMeshHandler.getInstance().getMeshInfo().getDefaultAppKeyIndex();
      ModelPublication modelPublication = ModelPublication.createDefault(pubEleAdr, pubAdr, appKeyIndex, period, modelId, true);

      ModelPublicationSetMessage publicationSetMessage = new ModelPublicationSetMessage(networkingDevice.nodeInfo.meshAddress, modelPublication);
      boolean result = MeshService.getInstance().sendMeshMessage(publicationSetMessage);
      if (result) {
        mHandler.removeCallbacks(timePubSetTimeoutTask);
        mHandler.postDelayed(timePubSetTimeoutTask, 5 * 1000);
      }
      return result;
    } else {
      return false;
    }
  }

  private Runnable timePubSetTimeoutTask = new Runnable() {
    @Override
    public void run() {
      onTimePublishComplete(false, "time pub set timeout");
    }
  };

  private void onTimePublishComplete(boolean success, String desc) {
    if (!isPubSetting) return;
    MeshLogger.d("pub set complete: " + success + " -- " + desc);
    isPubSetting = false;

    NetworkingDevice pvDevice = getCurrentDevice(NetworkingState.TIME_PUB_SETTING);

    if (pvDevice == null) {
      MeshLogger.d("pv device not found pub set success");
      return;
    }
    pvDevice.addLog(NetworkingDevice.TAG_PUB_SET, success ? "success" : ("failed : " + desc));
    pvDevice.state = success ? NetworkingState.TIME_PUB_SET_SUCCESS : NetworkingState.TIME_PUB_SET_FAIL;
    pvDevice.addLog(NetworkingDevice.TAG_PUB_SET, desc);
//    mListAdapter.notifyDataSetChanged();
    mesh.saveOrUpdate(this.ctx);
    provisionNext();
  }

  /**
   * only find in unprovisioned list
   *
   * @param deviceUUID deviceUUID in unprovisioned scan record
   */
  private boolean deviceExists(byte[] deviceUUID) {
    for (NetworkingDevice device : this.devices) {
      if (device.state == NetworkingState.IDLE && Arrays.equals(deviceUUID, device.nodeInfo.deviceUUID)) {
        return true;
      }
    }
    return false;
  }
  /**
   * @param state target state,
   * @return processing device
   */
  private NetworkingDevice getCurrentDevice(NetworkingState state) {
    for (NetworkingDevice device : devices) {
      if (device.state == state) {
        return device;
      }
    }
    return null;
  }

  public void setCallbackContext(CallbackContext callbackContext) {
    this.callbackContext = callbackContext;
  }
}

