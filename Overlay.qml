import QtQuick
import Quickshell

FloatingWindow {
    id: window

    // MUST BE DECLARED FOR OMARCHY LOADER INJECTION
    property var shell: null
    property var manifest: null
    property var omarchyPath: null
    property var barWidgetRegistry: null
    property var pluginRegistry: null

    visible: false
    title: "Omarchy Contributors"
    color: "#0f0f11"

    implicitWidth: 1000
    implicitHeight: 700

    Component.onCompleted: {
        console.log("=== CONTRIBUTORS COMPONENT LOADED ===")
    }

    function open(payloadJson) {
        console.log("=== CONTRIBUTORS OPEN CALLED ===")
        window.visible = true
    }

    function close() {
        console.log("=== CONTRIBUTORS CLOSE CALLED ===")
        window.visible = false
    }

    onVisibleChanged: {
        console.log("=== WINDOW VISIBLE:", visible, "===")
        if (!visible && window.shell && typeof window.shell.hide === "function") {
            window.shell.hide("surve.omarchy-contributors")
        }
    }

    Text {
        anchors.centerIn: parent
        text: "Omarchy Contributors"
        color: "white"
        font.pixelSize: 32
    }
}
