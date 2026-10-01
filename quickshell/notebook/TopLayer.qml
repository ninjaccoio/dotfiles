import QtQuick
import Quickshell

import qs.shared.services
//import qs.shared.services

PanelWindow {
    id: root

    // Aggancia la surface ai tre lati superiori dello schermo.
    anchors {
        top: true
        left: true
        right: true
    }

    // Altezza della nostra area superiore.
    implicitHeight: 30

    // La window esiste, ma non vogliamo vedere uno sfondo.
    color: "transparent"

    /*
    Component.onCompleted: {
        console.log("Battery ready:", BatteryService.ready)
        console.log("Battery percentage:", BatteryService.percentage)
        console.log("Battery charging:", BatteryService.charging)
    }
    */
}