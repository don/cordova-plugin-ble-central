package com.megster.cordova.ble.central;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

public class NotificationActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (isTaskRoot()) {
            // if the app is not running, launch it
            launchApp();
        }

        // close this activity
        finish();
    }

    private void launchApp() {
        Context context = getApplicationContext();
        String pkgName  = context.getPackageName();

        Intent intent = context
                .getPackageManager()
                .getLaunchIntentForPackage(pkgName);

        intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT | Intent.FLAG_ACTIVITY_SINGLE_TOP);

        context.startActivity(intent);
    }
}
