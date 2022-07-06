#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const ACCESS_BACKGROUND_LOCATION = /\n.*?android\.permission\.ACCESS_BACKGROUND_LOCATION.*?\n/;
const USES_PERMISSION_FLAGS = /\s*android:usesPermissionFlags="neverForLocation"\s*/;

module.exports = function (context) {
    const { projectRoot, plugin } = context.opts;
    const { ConfigParser } = context.requireCordovaModule('cordova-common');

    const platformPath = path.resolve(projectRoot, 'platforms/android');
    const config = new ConfigParser(path.resolve(platformPath, 'app/src/main/res/xml/config.xml'));
    const accessBackgroundLocation = config.getPreference('accessBackgroundLocation', 'android');

    const targetSdkVersion = getTargetSdkVersion(platformPath);
    if (!targetSdkVersion) {
        console.log(plugin.id + ': WARNING - unable to find Android SDK version');
    }

    const manifestPath = path.resolve(platformPath, 'app/src/main/AndroidManifest.xml');
    if (!fs.existsSync(manifestPath)) {
        throw "Can't find AndroidManifest.xml in platforms/Android";
    }

    let manifestChanged = false;
    let androidManifest = fs.readFileSync(manifestPath).toString();
    if (accessBackgroundLocation != 'true' && androidManifest.search(ACCESS_BACKGROUND_LOCATION) != -1) {
        console.log(plugin.id + ': ACCESS_BACKGROUND_LOCATION permission removed from ' + manifestPath);
        androidManifest = androidManifest.replace(ACCESS_BACKGROUND_LOCATION, '\n');
        manifestChanged = true;
    }

    if (targetSdkVersion < 31 && androidManifest.search(USES_PERMISSION_FLAGS) != -1) {
        // (API 31) Build.VERSION_CODE.S Android 12
        console.log(plugin.id + ': Stripping Android 12-only attributes from ' + manifestPath);
        androidManifest = androidManifest.replace(USES_PERMISSION_FLAGS, ' ');
        manifestChanged = true;
    }

    if (manifestChanged) {
        fs.writeFileSync(manifestPath, androidManifest);
    }
};

function getTargetSdkVersion(platformPath) {
    let sdkVersion;
    const gradleConfigJson = path.resolve(platformPath, 'cdv-gradle-config.json');
    const gradleConfigProperties = path.resolve(platformPath, 'gradle.properties');

    if (fs.existsSync(gradleConfigJson)) {
        const gradleConfig = JSON.parse(fs.readFileSync(gradleConfigJson).toString());
        sdkVersion = gradleConfig.SDK_VERSION;
    } else if (fs.existsSync(gradleConfigProperties)) {
        const gradleConfig = fs.readFileSync(gradleConfigProperties).toString();
        sdkVersion = gradleConfig
            .split('\n')
            .map((l) => l.split('='))
            .filter(([key]) => key == 'cdvTargetSdkVersion')
            .map(([_, value]) => value);
    }

    return Number(sdkVersion || 0);
}
