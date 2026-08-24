import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

Item {
    id: root

    property bool opened: false
    property var contributors: []

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
            root.loadContributors()
        }
    }

    function loadContributors() {
        try {
            var data = JSON.parse(contributorsFile.text())
            root.contributors = data.contributors || []

            console.log(
                "surve.omarchy-contributors: loaded",
                root.contributors.length,
                "contributors"
            )

            root.scheduleCreditsStart()
        } catch (error) {
            console.log(
                "surve.omarchy-contributors: JSON parse failed:",
                error
            )
        }
    }

    function scheduleCreditsStart() {
        if (!root.opened)
            return

        animationStartTimer.restart()
    }

    function startCredits() {
        if (!root.opened)
            return

        if (root.contributors.length === 0)
            return

        if (credits.height <= 0)
            return

        creditsAnimation.stop()

        credits.y = creditsViewport.height

        creditsAnimation.from = creditsViewport.height
        creditsAnimation.to = -credits.height

        creditsAnimation.start()
    }

    function open(payloadJson) {
        root.opened = true

        Qt.callLater(function() {
            keyCatcher.forceActiveFocus()
            root.scheduleCreditsStart()
        })
    }

    function close() {
        root.opened = false

        animationStartTimer.stop()
        creditsAnimation.stop()
    }

    Timer {
        id: animationStartTimer

        interval: 100
        repeat: false

        onTriggered: {
            root.startCredits()
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

        Item {
            id: creditsViewport

            anchors.fill: parent
            clip: true

            // ============================================================
            // TOP FADE
            // ============================================================

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                height: 180
                z: 10

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "black"
                    }

                    GradientStop {
                        position: 1.0
                        color: "#00000000"
                    }
                }
            }

            // ============================================================
            // BOTTOM FADE
            // ============================================================

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                height: 180
                z: 10

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "#00000000"
                    }

                    GradientStop {
                        position: 1.0
                        color: "black"
                    }
                }
            }

            // ============================================================
            // CREDIT ROLL
            // ============================================================

            Item {
                id: credits

                width: creditsViewport.width
                height: creditsColumn.height

                y: creditsViewport.height

                Column {
                    id: creditsColumn

                    width: creditsViewport.width

                    spacing: 18

                    // ====================================================
                    // OPENING
                    // ====================================================

                    Column {
                        width: parent.width

                        spacing: 18

                        Text {
                            width: parent.width

                            text: "OMARCHY CONTRIBUTORS"

                            horizontalAlignment: Text.AlignHCenter

                            color: "white"

                            font.family: "monospace"
                            font.pixelSize: 56
                            font.bold: true
                        }

                        Text {
                            width: parent.width

                            text: "A THANK YOU TO THE PEOPLE WHO BUILT IT"

                            horizontalAlignment: Text.AlignHCenter

                            color: "#666666"

                            font.family: "monospace"
                            font.pixelSize: 16
                        }

                        Item {
                            width: parent.width
                            height: 45
                        }
                    }

                    // ====================================================
                    // CONTRIBUTORS
                    // ====================================================

                    Repeater {
                        model: root.contributors

                        delegate: Item {
                            width: creditsColumn.width
                            height: 42

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter

                                width: 900
                                height: parent.height

                                // ------------------------------------------------
                                // LEFT COLUMN
                                //
                                // 405px + 45px gap = 450px.
                                //
                                // Since the row is centered, x=450 is the
                                // exact center of the screen.
                                // ------------------------------------------------

                                Text {
                                    width: 405
                                    height: parent.height

                                    text:
                                        "@"
                                        + modelData.login

                                    color: "white"

                                    font.family: "monospace"
                                    font.pixelSize: 22
                                    font.bold: true

                                    horizontalAlignment: Text.AlignRight
                                    verticalAlignment: Text.AlignVCenter
                                }

                                // ------------------------------------------------
                                // CENTER GAP
                                // ------------------------------------------------

                                Item {
                                    width: 45
                                    height: 1
                                }

                                // ------------------------------------------------
                                // RIGHT COLUMN
                                // ------------------------------------------------

                                Text {
                                    width: 450
                                    height: parent.height

                                    text:
                                        modelData.commits
                                        + " "
                                        + (
                                            modelData.commits === 1
                                            ? "contribution"
                                            : "contributions"
                                        )

                                    color: "#aaaaaa"

                                    font.family: "monospace"
                                    font.pixelSize: 17

                                    horizontalAlignment: Text.AlignLeft
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }

                    // ====================================================
                    // ENDING
                    // ====================================================

                    Column {
                        width: parent.width

                        spacing: 24

                        Item {
                            width: parent.width
                            height: 100
                        }

                        Text {
                            width: parent.width

                            text: "THANK YOU"

                            horizontalAlignment: Text.AlignHCenter

                            color: "white"

                            font.family: "monospace"
                            font.pixelSize: 42
                            font.bold: true
                        }

                        Text {
                            width: parent.width

                            text: "OMARCHY"

                            horizontalAlignment: Text.AlignHCenter

                            color: "#777777"

                            font.family: "monospace"
                            font.pixelSize: 22
                        }

                        Item {
                            width: parent.width
                            height: 500
                        }
                    }
                }

                // ============================================================
                // SCROLL ANIMATION
                // ============================================================

                NumberAnimation {
                    id: creditsAnimation

                    target: credits
                    property: "y"

                    duration: Math.max(
                        60000,
                        root.contributors.length * 1000
                    )

                    easing.type: Easing.Linear

                    onFinished: {
                        root.close()
                    }
                }
            }
        }
    }
}
