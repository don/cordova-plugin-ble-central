declare namespace BLECentralPlugin {
    type PeripheralState = 'disconnected' | 'disconnecting' | 'connecting' | 'connected';

    interface PeripheralCharacteristic {
        service: string;
        characteristic: string;
        properties: string[];
        descriptors?: any[] | undefined;
    }

    interface PeripheralData {
        name: string;
        id: string;
        rssi: number;
        advertising: ArrayBuffer | any;
        state: PeripheralState;
    }

    interface PeripheralDataExtended extends PeripheralData {
        services: string[];
        characteristics: PeripheralCharacteristic[];
    }

    interface BLEError {
        name: string;
        id: string;
        errorMessage: string;
    }

    interface StartScanOptions {
        reportDuplicates?: boolean | undefined;
    }

    interface L2CAPOptions {
        psm: number;
        secureChannel?: boolean;
    }

    interface L2CAP {
        close(device_id: string, psm: number, success?: () => any, failure?: (error: string | BLEError) => any): void;

        open(
            device_id: string,
            psmOrOptions: number | L2CAPOptions,
            connectCallback?: () => any,
            disconnectCallback?: (error: string | BLEError) => any
        ): void;

        receiveData(device_id: string, psm: number, data: (data: ArrayBuffer) => any): void;

        write(
            device_id: string,
            psm: number,
            data: ArrayBuffer,
            success?: () => {},
            failure?: (error: string | BLEError) => any
        ): void;
    }

    interface L2CAPPromises {
        open(
            device_id: string,
            psmOrOptions: number | L2CAPOptions,
            disconnectCallback?: (error: string | BLEError) => any
        ): Promise<void>;
        close(device_id: string, psm: number): Promise<void>;
        write(device_id: string, psm: number, data: ArrayBuffer): Promise<void>;
    }

    interface RestoredState {
        peripherals?: PeripheralDataExtended[];
        scanServiceUUIDs?: string[];
        scanOptions?: Record<string, any>;
    }

    interface BLECentralPluginCommon {
        scan(
            services: string[],
            seconds: number,
            success: (data: PeripheralData) => any,
            failure?: (error: string) => any
        ): void;

        startScan(
            services: string[],
            success: (data: PeripheralData) => any,
            failure?: (error: string | BLEError) => any
        ): void;

        startScanWithOptions(
            services: string[],
            options: StartScanOptions,
            success: (data: PeripheralData) => any,
            failure?: (error: string) => any
        ): void;

        connect(
            device_id: string,
            connectCallback: (data: PeripheralDataExtended) => any,
            disconnectCallback: (error: string | BLEError) => any
        ): void;
    }

    export interface BLECentralPluginPromises extends BLECentralPluginCommon {
        l2cap: L2CAPPromises;

        /* Lists all peripherals discovered by the plugin due to scanning or connecting since app launch.
           [iOS] list is not supported on iOS. */
        list(): Promise<PeripheralData>;

        /* Find the bonded devices.
           [iOS] bondedDevices is not supported on iOS. */
        bondedDevices(): Promise<PeripheralData>;

        stopScan(): Promise<void>;
        disconnect(device_id: string): Promise<void>;
        read(device_id: string, service_uuid: string, characteristic_uuid: string): Promise<ArrayBuffer>;
        write(device_id: string, service_uuid: string, characteristic_uuid: string, value: ArrayBuffer): Promise<void>;
        writeWithoutResponse(
            device_id: string,
            service_uuid: string,
            characteristic_uuid: string,
            value: ArrayBuffer
        ): Promise<void>;

        /* Register to be notified when the value of a characteristic changes. */
        startNotification(
            device_id: string,
            service_uuid: string,
            characteristic_uuid: string,
            success: (rawData: ArrayBuffer) => any,
            failure?: (error: string | BLEError) => any
        ): Promise<void>;
        stopNotification(device_id: string, service_uuid: string, characteristic_uuid: string): Promise<void>;

        /* Returns a rejected promise if the device is not connected */
        isConnected(device_id: string): Promise<void>;

        /* Returns a rejected promise if bluetooth is not connected */
        isEnabled(): Promise<void>;

        enable(): Promise<void>;
        showBluetoothSettings(): Promise<void>;

        /** Registers a change listener for Bluetooth adapter state changes */
        startStateNotifications(success: (state: string) => any, failure?: (error: string) => any): Promise<void>;

        stopStateNotifications(): Promise<void>;

        /* Registers a change listener for location-related services.
           [iOS] startLocationStateNotifications is not supported on iOS. */
        startLocationStateNotifications(
            change: (isLocationEnabled: boolean) => any,
            failure?: (error: string) => any
        ): Promise<void>;
        stopLocationStateNotifications(): Promise<void>;

        readRSSI(device_id: string): Promise<number>;

        /* When Connecting to a peripheral android can request for the connection priority for faster communication.
           [iOS] requestConnectionPriority is not supported on iOS. */
        requestConnectionPriority(device_id: string, priority: 'high' | 'balanced' | 'low'): Promise<void>;

        restoredBluetoothState(): Promise<RestoredState | undefined>;
    }

    export interface BLECentralPluginStatic extends BLECentralPluginCommon {
        l2cap: L2CAP;

        /* sets the pin when device requires it.
           [iOS] setPin is not supported on iOS. */
        setPin(pin: string, success?: () => any, failure?: (error: string | BLEError) => any): void;

        stopScan(success?: () => any, failure?: () => any): void;

        /* Automatically connect to a device when it is in range of the phone
           [iOS] background notifications on ios must be enabled if you want to run in the background
           [Android] this relies on the autoConnect argument of BluetoothDevice.connectGatt(). Not all Android devices implement this feature correctly. */
        autoConnect(
            device_id: string,
            connectCallback: (data: PeripheralDataExtended) => any,
            disconnectCallback: (error: string | BLEError) => any
        ): void;

        disconnect(device_id: string, success?: () => any, failure?: (error: string | BLEError) => any): void;

        read(
            device_id: string,
            service_uuid: string,
            characteristic_uuid: string,
            success?: (rawData: ArrayBuffer) => any,
            failure?: (error: string | BLEError) => any
        ): void;

        write(
            device_id: string,
            service_uuid: string,
            characteristic_uuid: string,
            data: ArrayBuffer,
            success?: () => any,
            failure?: (error: string | BLEError) => any
        ): void;

        /* Writes data to a characteristic without a response from the peripheral. 
           You are not notified if the write fails in the BLE stack.
           The success callback is be called when the characteristic is written.*/
        writeWithoutResponse(
            device_id: string,
            service_uuid: string,
            characteristic_uuid: string,
            data: ArrayBuffer,
            success?: () => any,
            failure?: (error: string) => any
        ): void;

        /* Start notifications on the given characteristic
           - options
               emitOnRegistered     Default is false. Emit "registered" to success callback 
                                    when peripheral confirms notifications are active
          */
        startNotification(
            device_id: string,
            service_uuid: string,
            characteristic_uuid: string,
            success: (rawData: ArrayBuffer | 'registered') => any,
            failure?: (error: string | BLEError) => any,
            options: { emitOnRegistered: boolean }
        ): void;

        startNotification(
            device_id: string,
            service_uuid: string,
            characteristic_uuid: string,
            success: (rawData: ArrayBuffer) => any,
            failure?: (error: string | BLEError) => any
        ): void;

        stopNotification(
            device_id: string,
            service_uuid: string,
            characteristic_uuid: string,
            success?: () => any,
            failure?: (error: string | BLEError) => any
        ): void;

        /* Reports if bluetooth is enabled. */
        isEnabled(success: () => any, failure?: (error: string) => any): void;

        /* Reports if location services are enabled.
           [iOS] isLocationEnabled is not supported on iOS. */
        isLocationEnabled(success: () => any, failure?: (error: string) => any): void;

        /* Calls the success callback when the peripheral is connected and the failure callback when not connected. */
        isConnected(device_id: string, success: () => any, failure?: (error: string) => any): void;

        /* May be used to request (on Android) a larger MTU size to be able to send more data at once
           [iOS] requestMtu is not supported on iOS. */
        requestMtu(device_id: string, mtu: number, success?: () => any, failure?: () => any): void;

        /* When Connecting to a peripheral android can request for the connection priority for faster communication.
           [iOS] requestConnectionPriority is not supported on iOS. */
        requestConnectionPriority(
            device_id: string,
            priority: 'high' | 'balanced' | 'low',
            success?: () => any,
            failure?: () => any
        ): void;

        /* Clears cached services and characteristics info for some poorly behaved devices. Uses an undocumented API,
           so it is not guaranteed to work.
           [iOS] refreshDeviceCache is not supported on iOS. */
        refreshDeviceCache(
            device_id: string,
            timeout_millis: number,
            success?: (data: PeripheralDataExtended) => any,
            failure?: (error: string | BLEError) => any
        ): void;

        /** Registers a change listener for Bluetooth adapter state changes */
        startStateNotifications(success: (state: string) => any, failure?: (error: string) => any): void;

        stopStateNotifications(success?: () => any, failure?: () => any): void;

        /* Registers a change listener for location-related services.
           [iOS] startLocationStateNotifications is not supported on iOS. */
        startLocationStateNotifications(
            change: (isLocationEnabled: boolean) => any,
            failure?: (error: string) => any
        ): void;

        stopLocationStateNotifications(success?: () => any, failure?: (error: string) => any): void;

        /* Opens the Bluetooth settings for the operating systems.
           [iOS] showBluetoothSettings is not supported on iOS. */
        showBluetoothSettings(success: () => any, failure?: (error: string) => any): void;

        /* Enable Bluetooth on the device.
           [iOS] enable is not supported on iOS. */
        enable(success: () => any, failure?: (error: string) => any): void;

        readRSSI(device_id: string, success: (rssi: number) => any, failure?: (error: string) => any): void;

        /* Find connected peripherals offering the listed service UUIDs.
           This function wraps CBCentralManager.retrieveConnectedPeripheralsWithServices.
           [Android] peripheralsWithIdentifiers is not supported on Android. */
        connectedPeripheralsWithServices(
            services: string[],
            success: (data: PeripheralData[]) => any,
            failure?: (error: string) => any
        ): void;

        /* Find known (but not necessarily connected) peripherals offering the listed device UUIDs.
               This function wraps CBCentralManager.retrievePeripheralsWithIdentifiers
               [Android] peripheralsWithIdentifiers is not supported on Android. */
        peripheralsWithIdentifiers(
            device_ids: string[],
            success: (data: PeripheralData[]) => any,
            failure?: (error: string) => any
        ): void;

        /* Lists all peripherals discovered by the plugin due to scanning or connecting since app launch.
            [iOS] list is not supported on iOS. */
        list(success: (data: PeripheralData[]) => any, failure?: (error: string) => any): void;

        /* Find the bonded devices.
                   [iOS] bondedDevices is not supported on iOS. */
        bondedDevices(success: (data: PeripheralData[]) => any, failure?: (error: string) => any): void;

        /* Reports the BLE restoration status if the app was restarted by iOS
           as a result of a BLE event.
           See https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/CoreBluetoothBackgroundProcessingForIOSApps/PerformingTasksWhileYourAppIsInTheBackground.html#//apple_ref/doc/uid/TP40013257-CH7-SW10
            [Android] restoredBluetoothState is not supported on Android. */
        restoredBluetoothState(success: (data: RestoredState) => any, failure?: (error: string) => any): void;

        withPromises: BLECentralPluginPromises;
    }
}

declare var ble: BLECentralPlugin.BLECentralPluginStatic;
