import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Controls

Item {
    id: root

    property bool opened: false

    FileView {
        id: contributorsFile

        path: Qt.resolvedUrl("data/contributors.json")
        preload: true

        onLoadFailed: function(error) {
            console.log(
                "surve.omarchy-contributors: failed to load contributors.json:",
                error
            )
        }

        onLoaded: {
            console.log(
                "surve.omarchy-contributors: contributors.json loaded"
            )
        }
    }

    PanelWindow {
        id: panel

        visible: root.opened

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "black"

        WlrLayershell.namespace: "surve-omarchy-contributors"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.opened
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None

        exclusionMode: ExclusionMode.Ignore

        Item {
            id: keyCatcher

            anchors.fill: parent
            focus: true

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    root.close()
                    event.accepted = true
                }
            }
        }

        ScrollView {
            anchors.fill: parent
            anchors.margins: 40

            TextArea {
                readOnly: true
                text: contributorsFile.text()
                wrapMode: TextArea.NoWrap

                color: "white"
                font.family: "monospace"
                font.pixelSize: 16

                background: null
            }
        }
    }

    function open(payloadJson) {
        console.log("surve.omarchy-contributors: open()")

        root.opened = true

        Qt.callLater(function() {
            keyCatcher.forceActiveFocus()
        })
    }

    function close() {
        root.opened = false
    }
}
