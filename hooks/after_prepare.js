#!/usr/bin/env node
'use strict';

var fs = require('fs');

var ACCESS_BACKGROUND_LOCATION_PERMISSION = '<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />';

module.exports = function (context) {
    const accessBackgroundLocationVariable = getAccessBackgroundLocationVariable();
    const manifestPath = getAndroidManifestFilePath(context);
    const androidManifest = fs.readFileSync(manifestPath).toString();
    if (accessBackgroundLocationVariable === 'true') {
        if (!accessBackgroundLocationExists(androidManifest)) {
            addAccessBackgroundLocationToManifest(manifestPath, androidManifest);
            console.log(context.opts.plugin.id + ': ACCESS_BACKGROUND_LOCATION permission added to ' + manifestPath);
        } else {
            console.log(context.opts.plugin.id + ': ACCESS_BACKGROUND_LOCATION permission already exists in ' + manifestPath);
        }
    } else {
        if (accessBackgroundLocationExists(androidManifest)) {
            removeAccessBackgroundLocationToManifest(manifestPath, androidManifest);
            console.log(context.opts.plugin.id + ': ACCESS_BACKGROUND_LOCATION permission removed from ' + manifestPath);
        } else {
            console.log(context.opts.plugin.id + ': ACCESS_BACKGROUND_LOCATION permission does not exists in ' + manifestPath);
        }
    }
}

var getAccessBackgroundLocationVariable = function () {
    if (process.argv.join("|").indexOf("ACCESS_BACKGROUND_LOCATION=") > -1) {
        return process.argv.join("|").match(/ACCESS_BACKGROUND_LOCATION=(.*?)(\||$)/)[1];
    } else {
        return getPreferenceValue("ACCESS_BACKGROUND_LOCATION");
    }
}

var getPreferenceValue = function (name) {
    const config = fs.readFileSync('config.xml').toString();
    var preferenceValue = getPreferenceValueFromConfig(config, name);
    if (!preferenceValue) {
        const packageJson = fs.readFileSync('package.json').toString();
        preferenceValue = getPreferenceValueFromPackageJson(packageJson, name);
    }
    return preferenceValue;
}

var getPreferenceValueFromConfig = function (config, name) {
    const value = config.match(new RegExp('name="' + name + '" value="(.*?)"', "i"));
    if (value && value[1]) {
        return value[1];
    } else {
        return null;
    }
}

var getPreferenceValueFromPackageJson = function (packageJson, name) {
    const value = packageJson.match(new RegExp('"' + name + '":\\s"(.*?)"', "i"));
    if (value && value[1]) {
        return value[1];
    } else {
        return null;
    }
}

var getAndroidManifestFilePath = function (context) {
    const manifestPath = {
        cordovaAndroid6: context.opts.projectRoot + '/platforms/android/AndroidManifest.xml',
        cordovaAndroid7: context.opts.projectRoot + '/platforms/android/app/src/main/AndroidManifest.xml'
    };
    if (fs.existsSync(manifestPath.cordovaAndroid7)) {
        return manifestPath.cordovaAndroid7;
    } else if (fs.existsSync(manifestPath.cordovaAndroid6)) {
        return manifestPath.cordovaAndroid6;
    } else {
        throw "Can't find AndroidManifest.xml in platforms/Android";
    }
}

var accessBackgroundLocationExists = function (manifest) {
    const value = manifest.search(ACCESS_BACKGROUND_LOCATION_PERMISSION);
    if (value === -1) {
        return false;
    } else {
        return true;
    }
}

var addAccessBackgroundLocationToManifest = function (manifestPath, androidManifest) {
    const index = androidManifest.search('</manifest>');
    const accessBackgroundLocationPermissionLine = '    ' + ACCESS_BACKGROUND_LOCATION_PERMISSION + '\n';
    const updatedManifest = androidManifest.substring(0, index) + accessBackgroundLocationPermissionLine + androidManifest.substring(index);
    fs.writeFileSync(manifestPath, updatedManifest);
}

var removeAccessBackgroundLocationToManifest = function (manifestPath, androidManifest) {
    const accessBackgroundLocationPermissionLine = '    ' + ACCESS_BACKGROUND_LOCATION_PERMISSION + '\n';
    const updatedManifest = androidManifest.replace(accessBackgroundLocationPermissionLine, '');
    fs.writeFileSync(manifestPath, updatedManifest);
}