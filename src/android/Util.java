package com.megster.cordova.ble.central;

import com.google.gson.Gson;
import com.megster.cordova.ble.central.model.GroupInfo;
import com.megster.cordova.ble.central.model.MeshAppKey;
import com.megster.cordova.ble.central.model.MeshInfo;
import com.megster.cordova.ble.central.model.MeshNetKey;
import com.megster.cordova.ble.central.model.NodeInfo;
import com.megster.cordova.ble.central.model.PublishModel;
import com.megster.cordova.ble.central.model.Scene;
import com.megster.cordova.ble.central.model.json.AddressRange;
import com.megster.cordova.ble.central.model.json.MeshSecurity;
import com.megster.cordova.ble.central.model.json.MeshStorage;
import com.telink.ble.mesh.core.MeshUtils;
import com.telink.ble.mesh.core.message.MeshSigModel;
import com.telink.ble.mesh.entity.CompositionData;
import com.telink.ble.mesh.entity.Scheduler;
import com.telink.ble.mesh.entity.TransitionTime;
import com.telink.ble.mesh.util.Arrays;
import com.telink.ble.mesh.util.MeshLogger;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class Util {

  private static final byte[] VC_TOOL_CPS = new byte[]{
          (byte) 0x00, (byte) 0x00, (byte) 0x01, (byte) 0x01, (byte) 0x33, (byte) 0x31, (byte) 0xE8, (byte) 0x03,
          (byte) 0x04, (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x17, (byte) 0x01, (byte) 0x00, (byte) 0x00,
          (byte) 0x01, (byte) 0x00, (byte) 0x02, (byte) 0x00, (byte) 0x03, (byte) 0x00, (byte) 0x05, (byte) 0x00,
          (byte) 0x00, (byte) 0xFE, (byte) 0x01, (byte) 0xFE, (byte) 0x02, (byte) 0xFE, (byte) 0x03, (byte) 0xFE,
          (byte) 0x00, (byte) 0xFF, (byte) 0x01, (byte) 0xFF, (byte) 0x02, (byte) 0x12, (byte) 0x01, (byte) 0x10,
          (byte) 0x03, (byte) 0x10, (byte) 0x05, (byte) 0x10, (byte) 0x08, (byte) 0x10, (byte) 0x05, (byte) 0x12,
          (byte) 0x08, (byte) 0x12, (byte) 0x02, (byte) 0x13, (byte) 0x05, (byte) 0x13, (byte) 0x09, (byte) 0x13,
          (byte) 0x11, (byte) 0x13, (byte) 0x15, (byte) 0x10, (byte) 0x11, (byte) 0x02, (byte) 0x01, (byte) 0x00
  };

  // Send plugin functions
  public static void sendPluginResult(CallbackContext callbackContext, boolean success){
    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, success);
    callbackContext.sendPluginResult(pluginResult);
  }
  public static  void sendPluginResult(CallbackContext callbackContext, String message){
    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, message);
    callbackContext.sendPluginResult(pluginResult);
  }
  public static  void sendPluginResult(CallbackContext callbackContext, JSONObject obj){
    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, obj);
    callbackContext.sendPluginResult(pluginResult);
  }
  public static  void sendPluginResult(CallbackContext callbackContext, JSONArray arr){
    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, arr);
    callbackContext.sendPluginResult(pluginResult);
  }

  public static  void eventSendPluginResult(CallbackContext callbackContext,String event, String data){
    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, event);
    pluginResult.setKeepCallback(true);
    callbackContext.sendPluginResult(pluginResult);
  }
  public static JSONObject makeError(Exception error){
    JSONObject resultObj = new JSONObject();
    try {
      resultObj.put("error", "JsonException");
      resultObj.put("message", error.getMessage());
    } catch (Exception e) {}

    return resultObj;
  }
  public static JSONObject makeError(String code, String message){
    JSONObject resultObj = new JSONObject();
    try {
      resultObj.put("error", code);
      resultObj.put("message", message);
    } catch (Exception e) {}

    return resultObj;
  }

  public static String convertByteToHexadecimal(byte[] byteArray)
  {
    String hex = "";

    // Iterating through each byte in the array
    for (byte i : byteArray) {
      hex += String.format("%02X", i);
    }

    return hex;
  }
  public static byte[] convertHexStringtoBytesArray(String s){
    byte[] ans = new byte[s.length() / 2];

    System.out.println("Hex String : "+s);

    for (int i = 0; i < ans.length; i++) {
      int index = i * 2;

      // Using parseInt() method of Integer class
      int val = Integer.parseInt(s.substring(index, index + 2), 16);
      ans[i] = (byte)val;
    }
    return ans;
  }

}
