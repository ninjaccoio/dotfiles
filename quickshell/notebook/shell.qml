// Importa i componenti base di Qt Quick.
//
// QtQuick ci mette a disposizione gli elementi fondamentali di QML:
// Rectangle, Text, Item, MouseArea, ecc.
import QtQuick

// Importa l'API di Quickshell.
//
// Qui troviamo gli oggetti specifici di Quickshell,
// come ShellRoot e PanelWindow.
import Quickshell


// ShellRoot è la radice della nostra shell.
//
// Puoi pensarlo come il "contenitore principale" dell'intera
// configurazione Quickshell.
//
// Tutto ciò che farà parte della nostra shell partirà da qui.
ShellRoot {

    // PanelWindow crea una superficie Wayland pensata
    // appositamente per elementi come:
    //
    // - status bar
    // - dock
    // - pannelli
    //
    // Per ora ne creiamo una sola.
    PanelWindow {

        // Ancoriamo la finestra alla parte superiore dello schermo.
        //
        // "true" significa:
        //
        //     questo bordo della finestra deve aderire
        //     al corrispondente bordo dello schermo.
        //
        anchors {
            top: true
            left: true
            right: true
        }

        // Altezza della nostra barra in pixel.
        implicitHeight: 40


        // Rectangle è un normale elemento Qt Quick.
        //
        // Lo usiamo temporaneamente per rendere visibile
        // l'area occupata dalla barra.
        Rectangle {

            // Fa occupare al Rectangle tutto lo spazio
            // disponibile nel suo parent, cioè PanelWindow.
            anchors.fill: parent

            // Colore volutamente evidente.
            //
            // Non stiamo scegliendo ancora il design finale:
            // serve soltanto a verificare che la barra esista.
            color: "#202020"
        }
    }
}