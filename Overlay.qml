import Quickshell
import Quickshell.Wayland
import QtQuick

Item {
  id: root

  property bool opened: false

  function open(payloadJson){
    root.opened = true
    Qt.callLater(function(){
      keyCatcher.forceActiveFocus()
    })
  }

  function close(){
    root.opened = false
  }

  PanelWindow{
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
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    exclusionMode: ExclusionMode.Ignore

    Item {
      id: keyCatcher

      anchors.fill: parent
      focus: true

      Keys.onPressed: function(event){
        if(event.key === Qt.Key_Escape){
          root.close()
          event.accepted = true
        }
      }
    }

    Text {
      anchors.centerIn: parent

      text: "OMARCHY CONTRIBUTORS"
      color: "white"
      font.pixelSize: 48
    }
  }
}
