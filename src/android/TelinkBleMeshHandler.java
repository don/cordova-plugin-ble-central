package com.megster.cordova.ble.central;


import android.content.Context;
import android.util.Log;

import com.megster.cordova.ble.central.model.MeshInfo;
import com.telink.ble.mesh.foundation.Event;
import com.telink.ble.mesh.foundation.EventBus;
import com.telink.ble.mesh.foundation.EventHandler;
import com.telink.ble.mesh.foundation.EventListener;
import com.telink.ble.mesh.foundation.MeshConfiguration;
import com.telink.ble.mesh.foundation.MeshService;
import com.telink.ble.mesh.foundation.event.MeshEvent;
import com.telink.ble.mesh.foundation.event.NetworkInfoUpdateEvent;
import com.telink.ble.mesh.foundation.event.OnlineStatusEvent;
import com.telink.ble.mesh.foundation.event.StatusNotificationEvent;
import com.telink.ble.mesh.util.FileSystem;
import com.telink.ble.mesh.util.MeshLogger;


public class TelinkBleMeshHandler implements EventHandler {
  private String TAG = "TelinkBleMeshHandler";
  private EventBus<String> mEventBus;
  private MeshInfo meshInfo;
  private static TelinkBleMeshHandler mThis;

  // Very Important to call this before anything.
  // Because we are setting mThis to this.
  public void initialize(Context ctx) {
    mThis = this;
    mEventBus = new EventBus<>();
    initMesh(ctx);
    startMeshService(ctx);
  }

  private void startMeshService(Context ctx) {
    MeshService.getInstance().init(ctx, this);
    MeshConfiguration meshConfiguration = getMeshInfo().convertToConfiguration();
    MeshService.getInstance().setupMeshNetwork(meshConfiguration);
    MeshService.getInstance().checkBluetoothState();
    // set DLE enable
    MeshService.getInstance().resetDELState(SharedPreferenceHelper.isDleEnable(ctx));
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
  public static TelinkBleMeshHandler getInstance() {
    return mThis;
  }

  protected void onNetworkInfoUpdate(NetworkInfoUpdateEvent networkInfoUpdateEvent) {

  }

  protected void onStatusNotificationEvent(StatusNotificationEvent statusNotificationEvent) {

  }

  protected void onOnlineStatusEvent(OnlineStatusEvent onlineStatusEvent) {

  }

  protected void onMeshEvent(MeshEvent meshEvent) {

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
