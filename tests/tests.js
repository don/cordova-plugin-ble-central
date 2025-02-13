exports.defineAutoTests = function () {
    describe('BLE object', function () {
        it('ble should exist', function () {
            expect(ble).toBeDefined();
        });

        it('should contain a startScan function', function () {
            expect(typeof ble.startScan).toBeDefined();
            expect(typeof ble.startScan).toBe('function');
        });
    });
};

exports.defineManualTests = function (contentEl, createActionButton) {
    let scanned = [];
    let connectedDevice;

    createActionButton('Is Bluetooth Enabled?', function () {
        ble.isEnabled(
            function () {
                console.log('Bluetooth is enabled');
            },
            function () {
                console.log('Bluetooth is *not* enabled');
            }
        );
    });

    if (cordova.platformId !== 'ios') {
        // not supported on iOS
        createActionButton('Show Bluetooth Settings', function () {
            ble.showBluetoothSettings();
        });

        // not supported on iOS
        createActionButton('Enable Bluetooth', function () {
            ble.enable(
                function () {
                    console.log('Bluetooth is enabled');
                },
                function () {
                    console.log('The user did *not* enable Bluetooth');
                }
            );
        });
    }

    createActionButton('Scan', function () {
        scanned = [];
        var scanSeconds = 5;
        console.log('Scanning for BLE peripherals for ' + scanSeconds + ' seconds.');
        ble.startScan(
            [],
            function (device) {
                scanned.push(device);
                console.log(JSON.stringify(device));
            },
            function (reason) {
                console.log('BLE Scan failed ' + reason);
            }
        );

        setTimeout(
            ble.stopScan,
            scanSeconds * 1000,
            function () {
                console.log('Scan complete');
            },
            function () {
                console.log('stopScan failed');
            }
        );
    });

    createActionButton('Connect', function () {
        connectedDevice = undefined;
        contentEl.innerHTML = '';
        buttonList(
            scanned,
            (d) => [d.name, d.id],
            (d) => ble.connect(d.id, onConnect, onError)
        );

        function onConnect(d) {
            connectedDevice = d;
            console.log('BLE connected:', JSON.stringify(d));
            contentEl.innerHTML = '';
        }

        function onError(e) {
            console.log('Error', e);
            contentEl.innerHTML = '';
        }
    });

    createActionButton('Read', function () {
        contentEl.innerHTML = '';
        const readable = connectedDevice.characteristics.filter((c) => c.properties.indexOf('Read') != -1);
        buttonList(
            readable,
            (c) => [c.service, c.characteristic],
            (c) => ble.read(connectedDevice.id, c.service, c.characteristic, onRead, onError)
        );

        function onRead(d) {
            console.log('Payload read:', JSON.stringify(Array.from(new Uint8Array(d))));
            contentEl.innerHTML = '';
        }

        function onError(e) {
            console.log('Error', e);
            contentEl.innerHTML = '';
        }
    });

    createActionButton('Write', function () {
        contentEl.innerHTML = '';
        const writable = connectedDevice.characteristics.filter((c) => c.properties.indexOf('Write') != -1);
        const payload = new Uint8Array(1);
        payload[0] = 65; // Capital A
        buttonList(
            writable,
            (c) => [c.service, c.characteristic],
            (c) => ble.write(connectedDevice.id, c.service, c.characteristic, payload.buffer, onWrite, onError)
        );

        function onWrite(d) {
            console.log('Payload written');
            contentEl.innerHTML = '';
        }

        function onError(e) {
            console.log('Error', e);
            contentEl.innerHTML = '';
        }
    });

    createActionButton('Notify', function () {
        contentEl.innerHTML = '';
        const notifiable = connectedDevice.characteristics.filter(
            (c) => c.properties.indexOf('Notify') != -1 || c.properties.indexOf('Indicate') != -1
        );
        buttonList(
            notifiable,
            (c) => [c.service, c.characteristic],
            (c) => ble.startNotifications(connectedDevice.id, c.service, c.characteristic, onRead, onError)
        );

        function onRead(d) {
            console.log('Payload received:', JSON.stringify(Array.from(new Uint8Array(d))));
            contentEl.innerHTML = '';
        }

        function onError(e) {
            console.log('Error', e);
            contentEl.innerHTML = '';
        }
    });

    function buttonList(items, labelFn, actionFn) {
        for (const item of items) {
            const button = document.createElement('button');
            for (const label of labelFn(item)) {
                button.append(label);
                button.append(document.createElement('br'));
            }
            button.removeChild(button.lastElementChild);
            button.onclick = () => actionFn(item);
            contentEl.append(button);
            contentEl.append(document.createElement('br'));
        }
    }
};
