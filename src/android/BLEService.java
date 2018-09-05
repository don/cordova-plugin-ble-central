package com.megster.cordova.ble.central;

import android.app.job.JobParameters;
import android.app.job.JobService;
import android.content.Intent;
import android.os.Handler;
import android.util.Log;

public class BLEService extends JobService {

    public BLEService() {}

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d("NATURAL", "on start command");
        return START_STICKY;
    }

    @Override
    public boolean onStartJob(final JobParameters params) {
        // The work that this service "does" is simply wait for a certain duration and finish
        // the job (on another thread).

        Log.d("NATURAL", "start job");
        // Uses a handler to delay the execution of jobFinished().
        final Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                Log.d("NATURAL", "job running");
//                jobFinished(params, false);
                handler.postDelayed(this, 5 * 60 * 1000);
            }
        }, 5000);

        // Return true as there's more work to be done with this job.
        return true;
    }

    @Override
    public boolean onStopJob(JobParameters params) {
        // Return false to drop the job.
        return true;
    }

    @Override
    public void onDestroy() {
        Log.d("NATURAL EXIT", "service on destroy");
        Intent broadcastIntent = new Intent("com.megster.cordova.ble.central.BLERestart");
        sendBroadcast(broadcastIntent);
        super.onDestroy();
    }
}