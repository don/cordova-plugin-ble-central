package com.megster.cordova.ble.central;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONObject;

public class Util {
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
