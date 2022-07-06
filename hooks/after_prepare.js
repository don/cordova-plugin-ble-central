#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

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
    if (accessBackgroundLocation != 'true') {
        androidManifest = stripPermission(androidManifest, 'ACCESS_BACKGROUND_LOCATION');
        manifestChanged = true;
    }

    if (targetSdkVersion <= 30) {
        // Strip out Android 12+ changes
        androidManifest = stripPermission(androidManifest, 'BLUETOOTH_SCAN');
        androidManifest = stripPermission(androidManifest, 'BLUETOOTH_CONNECT');
        androidManifest = stripMaxSdkVersion(androidManifest, '30');
        manifestChanged = true;
    }

    if (targetSdkVersion <= 28) {
        // Strip out Android 10+ changes
        androidManifest = stripPermission(androidManifest, 'ACCESS_FINE_LOCATION');
        androidManifest = stripPermission(androidManifest, 'ACCESS_BACKGROUND_LOCATION');
        androidManifest = stripMaxSdkVersion(androidManifest, '28');
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

function stripPermission(androidManifest, permission) {
    const replacer = new RegExp(
        '\\n\\s*?<uses-permission.*? android:name="android\\.permission\\.' + permission + '".*?\\/>\\n',
        'g'
    );
    return androidManifest.replace(replacer, '\n');
}

function stripMaxSdkVersion(androidManifest, level) {
    const replacer = new RegExp('\\s*android:maxSdkVersion="' + level + '"\\s*', 'g');
    return androidManifest.replace(replacer, ' ');
}
