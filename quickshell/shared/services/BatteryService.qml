pragma Singleton

import QtQml
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    // UPower.displayDevice rappresenta il dispositivo aggregato
    // pensato per mostrare lo stato energetico del sistema.
    //
    // Nel nostro notebook corrisponde esattamente al DisplayDevice
    // che abbiamo appena interrogato con:
    //
    // upower -i /org/freedesktop/UPower/devices/DisplayDevice
    readonly property var device: UPower.displayDevice

    // Il device può esistere prima che UPower abbia terminato
    // di popolarne tutte le proprietà.
    readonly property bool ready: device.ready

    // UPower espone percentage come valore 0-100.
    // Al resto della nostra shell vogliamo esporre un intero.
    readonly property int percentage:
        ready ? Math.round(device.percentage) : 0

    // "charging" descrive esattamente ciò che ci interessa
    // visualizzare nel widget.
    readonly property bool charging:
        ready && device.state === UPowerDeviceState.Charging
}