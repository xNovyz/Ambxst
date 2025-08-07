import QtQuick

Item {
    implicitWidth: 400
    implicitHeight: 300

    property alias sourceComponent: loader.sourceComponent
    property alias item: loader.item

    Loader {
        id: loader
        anchors.fill: parent
        active: true
    }
}