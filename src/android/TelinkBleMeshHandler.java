package com.megster.cordova.ble.central;


import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

import com.megster.cordova.ble.central.model.AppSettings;
import com.megster.cordova.ble.central.model.CertCacheService;
import com.megster.cordova.ble.central.model.MeshInfo;
import com.megster.cordova.ble.central.model.NodeInfo;
import com.megster.cordova.ble.central.model.NodeStatusChangedEvent;
import com.megster.cordova.ble.central.model.UnitConvert;
import com.telink.ble.mesh.core.message.MeshSigModel;
import com.telink.ble.mesh.core.message.NotificationMessage;
import com.telink.ble.mesh.core.message.StatusMessage;
import com.telink.ble.mesh.core.message.generic.LevelStatusMessage;
import com.telink.ble.mesh.core.message.generic.OnOffStatusMessage;
import com.telink.ble.mesh.core.message.lighting.CtlStatusMessage;
import com.telink.ble.mesh.core.message.lighting.CtlTemperatureStatusMessage;
import com.telink.ble.mesh.core.message.lighting.LightnessStatusMessage;
import com.telink.ble.mesh.core.networking.ExtendBearerMode;
import com.telink.ble.mesh.entity.OnlineStatusInfo;
import com.telink.ble.mesh.foundation.Event;
import com.telink.ble.mesh.foundation.EventBus;
import com.telink.ble.mesh.foundation.EventHandler;
import com.telink.ble.mesh.foundation.EventListener;
import com.telink.ble.mesh.foundation.MeshApplication;
import com.telink.ble.mesh.foundation.MeshConfiguration;
import com.telink.ble.mesh.foundation.MeshService;
import com.telink.ble.mesh.foundation.event.AutoConnectEvent;
import com.telink.ble.mesh.foundation.event.MeshEvent;
import com.telink.ble.mesh.foundation.event.NetworkInfoUpdateEvent;
import com.telink.ble.mesh.foundation.event.OnlineStatusEvent;
import com.telink.ble.mesh.foundation.event.StatusNotificationEvent;
import com.telink.ble.mesh.util.FileSystem;
import com.telink.ble.mesh.util.MeshLogger;

import java.util.List;


public class TelinkBleMeshHandler extends MeshApplication implements EventHandler {
  private String TAG = "TelinkBleMeshHandler";
  private static TelinkBleMeshHandler mThis;
  private Handler mOfflineCheckHandler;
  private MeshInfo meshInfo;
  private EventBus<String> mEventBus;

  // Very Important to call this before anything.
  // Because we are setting mThis to this.
  public void initialize(Context ctx) {
    mThis = this;
    mEventBus = new EventBus<>();
    initMesh(ctx);
    startMeshService(ctx);
    HandlerThread offlineCheckThread = new HandlerThread("offline check thread");
    offlineCheckThread.start();
    mOfflineCheckHandler = new Handler(offlineCheckThread.getLooper());
    CertCacheService.getInstance().load(ctx);
    MeshLogger.enableRecord(true);
  }

  private void startMeshService(Context ctx) {
    try {
      MeshService.getInstance().init(ctx, getInstance(), this);
      MeshConfiguration meshConfiguration = getMeshInfo().convertToConfiguration();
      MeshService.getInstance().setupMeshNetwork(meshConfiguration);
      MeshService.getInstance().checkBluetoothState();
    } catch (Exception e) {
      Log.e("deed", e.toString());
    }

    // set DLE enable
//    MeshService.getInstance().resetDELState(SharedPreferenceHelper.isDleEnable(ctx));
    MeshService.getInstance().resetExtendBearerMode(SharedPreferenceHelper.getExtendBearerMode(ctx));
  }

  private void initMesh(Context ctx) {
    Object configObj = FileSystem.readAsObject(ctx, MeshInfo.FILE_NAME);
    Log.d(TAG, "MeshInfoFileName" + MeshInfo.FILE_NAME);
    if (configObj == null) {
      meshInfo = MeshInfo.createNewMesh(ctx);
      meshInfo.saveOrUpdate(ctx);
    } else {
      meshInfo = (MeshInfo) configObj;
    }
  }

  public void setupMesh(MeshInfo mesh) {
    MeshLogger.d("setup mesh info: " + meshInfo.toString());
    this.meshInfo = mesh;
    dispatchEvent(new MeshEvent(this, MeshEvent.EVENT_TYPE_MESH_RESET, "mesh reset"));
  }

  public MeshInfo getMeshInfo() {
    return meshInfo;
  }

  public void setMeshInfo(MeshInfo newMeshInfo) {
    meshInfo = newMeshInfo;
  }

  public static TelinkBleMeshHandler getInstance() {
    return mThis;
  }

  protected void onNetworkInfoUpdate(NetworkInfoUpdateEvent networkInfoUpdateEvent) {

  }

  private boolean onLumStatus(NodeInfo nodeInfo, int lum) {
    boolean statusChanged = false;
    int tarOnOff = lum > 0 ? 1 : 0;
    if (nodeInfo.getOnlineState() != tarOnOff) {
      statusChanged = true;
    }
    nodeInfo.setOnOff(tarOnOff);
    if (nodeInfo.lum != lum) {
      statusChanged = true;
      nodeInfo.lum = lum;
    }
    return statusChanged;
  }

  public Handler getOfflineCheckHandler() {
    return mOfflineCheckHandler;
  }

  private boolean onTempStatus(NodeInfo nodeInfo, int temp) {
    boolean statusChanged = false;
    if (nodeInfo.temp != temp) {
      statusChanged = true;
      nodeInfo.temp = temp;
    }
    return statusChanged;
  }

  @Override
  protected void onStatusNotificationEvent(StatusNotificationEvent statusNotificationEvent) {
    NotificationMessage message = statusNotificationEvent.getNotificationMessage();

    StatusMessage statusMessage = message.getStatusMessage();
    if (statusMessage != null) {
      NodeInfo statusChangedNode = null;
      if (message.getStatusMessage() instanceof OnOffStatusMessage) {
        OnOffStatusMessage onOffStatusMessage = (OnOffStatusMessage) statusMessage;
        int onOff = onOffStatusMessage.isComplete() ? onOffStatusMessage.getTargetOnOff() : onOffStatusMessage.getPresentOnOff();
        for (NodeInfo nodeInfo : meshInfo.nodes) {
          if (nodeInfo.meshAddress == message.getSrc()) {
            if (nodeInfo.getOnlineState() != onOff) {
              statusChangedNode = nodeInfo;
            }
            nodeInfo.setOnOff(onOff);
            break;
          }
        }
      } else if (message.getStatusMessage() instanceof LevelStatusMessage) {
        LevelStatusMessage levelStatusMessage = (LevelStatusMessage) statusMessage;
        int srcAdr = message.getSrc();
        int level = levelStatusMessage.isComplete() ? levelStatusMessage.getTargetLevel() : levelStatusMessage.getPresentLevel();
        int tarVal = UnitConvert.level2lum((short) level);
        for (NodeInfo onlineDevice : meshInfo.nodes) {
          if (onlineDevice.compositionData == null) {
            continue;
          }
          int lightnessEleAdr = onlineDevice.getTargetEleAdr(MeshSigModel.SIG_MD_LIGHTNESS_S.modelId);
          if (lightnessEleAdr == srcAdr) {
            if (onLumStatus(onlineDevice, tarVal)) {
              statusChangedNode = onlineDevice;
            }

          } else {
            int tempEleAdr = onlineDevice.getTargetEleAdr(MeshSigModel.SIG_MD_LIGHT_CTL_TEMP_S.modelId);
            if (tempEleAdr == srcAdr) {
              if (onlineDevice.temp != tarVal) {
                statusChangedNode = onlineDevice;
                onlineDevice.temp = tarVal;
              }
            }
          }
        }
      } else if (message.getStatusMessage() instanceof CtlStatusMessage) {
        CtlStatusMessage ctlStatusMessage = (CtlStatusMessage) statusMessage;
        MeshLogger.d("ctl : " + ctlStatusMessage.toString());
        int srcAdr = message.getSrc();
        for (NodeInfo onlineDevice : meshInfo.nodes) {
          if (onlineDevice.meshAddress == srcAdr) {
            int lum = ctlStatusMessage.isComplete() ? ctlStatusMessage.getTargetLightness() : ctlStatusMessage.getPresentLightness();
            if (onLumStatus(onlineDevice, UnitConvert.lightness2lum(lum))) {
              statusChangedNode = onlineDevice;
            }

            int temp = ctlStatusMessage.isComplete() ? ctlStatusMessage.getTargetTemperature() : ctlStatusMessage.getPresentTemperature();
            if (onTempStatus(onlineDevice, UnitConvert.tempToTemp100(temp))) {
              statusChangedNode = onlineDevice;
            }
            break;
          }
        }
      } else if (message.getStatusMessage() instanceof LightnessStatusMessage) {
        LightnessStatusMessage lightnessStatusMessage = (LightnessStatusMessage) statusMessage;
        int srcAdr = message.getSrc();
        for (NodeInfo onlineDevice : meshInfo.nodes) {
          if (onlineDevice.meshAddress == srcAdr) {
            int lum = lightnessStatusMessage.isComplete() ? lightnessStatusMessage.getTargetLightness() : lightnessStatusMessage.getPresentLightness();
            if (onLumStatus(onlineDevice, UnitConvert.lightness2lum(lum))) {
              statusChangedNode = onlineDevice;
            }
            break;
          }
        }
      } else if (message.getStatusMessage() instanceof CtlTemperatureStatusMessage) {
        CtlTemperatureStatusMessage ctlTemp = (CtlTemperatureStatusMessage) statusMessage;
        int srcAdr = message.getSrc();
        for (NodeInfo onlineDevice : meshInfo.nodes) {
          if (onlineDevice.meshAddress == srcAdr) {
            int temp = ctlTemp.isComplete() ? ctlTemp.getTargetTemperature() : ctlTemp.getPresentTemperature();
            if (onTempStatus(onlineDevice, UnitConvert.lightness2lum(temp))) {
              statusChangedNode = onlineDevice;
            }
            break;
          }
        }
      }

      //if (statusChangedNode != null) {
        onNodeInfoStatusChanged(statusChangedNode);
      //}
    }
  }

  private void onNodeInfoStatusChanged(NodeInfo nodeInfo) {
    dispatchEvent(new NodeStatusChangedEvent(this, NodeStatusChangedEvent.EVENT_TYPE_NODE_STATUS_CHANGED, nodeInfo));
  }

  protected void onOnlineStatusEvent(OnlineStatusEvent onlineStatusEvent) {
    List<OnlineStatusInfo> infoList = onlineStatusEvent.getOnlineStatusInfoList();
    if (infoList != null && meshInfo != null) {
      NodeInfo statusChangedNode = null;
      for (OnlineStatusInfo onlineStatusInfo : infoList) {
        if (onlineStatusInfo.status == null || onlineStatusInfo.status.length < 3) break;
        NodeInfo deviceInfo = meshInfo.getDeviceByMeshAddress(onlineStatusInfo.address);
        if (deviceInfo == null) continue;
        int onOff;
        if (onlineStatusInfo.sn == 0) {
          onOff = -1;
        } else {
          if (onlineStatusInfo.status[0] == 0) {
            onOff = 0;
          } else {
            onOff = 1;
          }


        }
                /*if (deviceInfo.getOnOff() != onOff){

                }*/
        if (deviceInfo.getOnlineState() != onOff) {
          statusChangedNode = deviceInfo;
        }
        deviceInfo.setOnOff(onOff);
        if (deviceInfo.lum != onlineStatusInfo.status[0]) {
          statusChangedNode = deviceInfo;
          deviceInfo.lum = onlineStatusInfo.status[0];
        }

        if (deviceInfo.temp != onlineStatusInfo.status[1]) {
          statusChangedNode = deviceInfo;
          deviceInfo.temp = onlineStatusInfo.status[1];
        }
      }
      //if (statusChangedNode != null) {
        onNodeInfoStatusChanged(statusChangedNode);
     // }
    }
  }

  @Override
  protected void onMeshEvent(MeshEvent meshEvent) {
    String eventType = meshEvent.getType();
    if (MeshEvent.EVENT_TYPE_DISCONNECTED.equals(eventType)) {
      AppSettings.ONLINE_STATUS_ENABLE = false;
      for (NodeInfo nodeInfo : meshInfo.nodes) {
        nodeInfo.setOnOff(-1);
      }
    }
  }

  @Override
  public void onEventHandle(Event<String> event) {
    if (event instanceof NetworkInfoUpdateEvent) {
      // update network info: ivIndex , sequence number
      this.onNetworkInfoUpdate((NetworkInfoUpdateEvent) event);
    } else if (event instanceof StatusNotificationEvent) {
      onStatusNotificationEvent((StatusNotificationEvent) event);
    } else if (event instanceof OnlineStatusEvent) {
      onOnlineStatusEvent((OnlineStatusEvent) event);
    } else if (event instanceof MeshEvent) {
      onMeshEvent((MeshEvent) event);
    }
    dispatchEvent(event);
  }
  /********************************************************************************
   * Event API
   *******************************************************************************/

  /**
   * add event listener
   *
   * @param eventType event type
   * @param listener  listener
   */
  public void addEventListener(String eventType, EventListener<String> listener) {
    this.mEventBus.addEventListener(eventType, listener);
  }

  /**
   * remove listener
   */
  public void removeEventListener(EventListener<String> listener) {
    this.mEventBus.removeEventListener(listener);
  }

  /**
   * remove target event from listener
   *
   * @param eventType type
   * @param listener  ls
   */
  public void removeEventListener(String eventType, EventListener<String> listener) {
    this.mEventBus.removeEventListener(eventType, listener);
  }

  /**
   * remove all
   */
  public void removeEventListeners() {
    this.mEventBus.removeEventListeners();
  }

  /**
   * dispatch event from application
   */
  public void dispatchEvent(Event<String> event) {
    this.mEventBus.dispatchEvent(event);
  }
}
