import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.0
import CuteVersioning 1.0

import "store"
import "style"

ApplicationWindow {
    id: applicationWindow1

    property real startupTime: 0

//    visibility: ApplicationWindow.FullScreen
    visible: true
    width: 1136
    height: 640
    title: qsTr("Neuronify " + Version.latestTag)

    Component.onCompleted: {
        console.log("ApplicationWindow load completed " + Date.now());
        startupTime = Date.now();
    }

    Settings {
        id: settings
        property alias width: applicationWindow1.width
        property alias height: applicationWindow1.height
        property alias x: applicationWindow1.x
        property alias y: applicationWindow1.y
        property alias firstRun: neuronify.firstRun
    }

    FontLoader {
        source: "qrc:/fonts/roboto/Roboto-Regular.ttf"
    }

    FontLoader {
        source: "qrc:/fonts/roboto/Roboto-Light.ttf"
    }

    FontLoader {
        source: "qrc:/fonts/roboto/Roboto-Bold.ttf"
    }

    Rectangle {
        id: overlay

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width * 0.25
        color: "#f7fbff"
        border.color: Style.meter.border.color
        border.width: Style.meter.border.width

        Image {
            id: titleText
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 32
            }
            height: 180
            source: "qrc:/images/logo/logo-with-text.png"
            antialiasing: true
            smooth: true
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: authorsText
            anchors {
                top: titleText.bottom
                left: parent.left
                right: parent.right
                margins: 32
            }
            font.pixelSize: parent.width * 0.036
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            textFormat: Text.RichText
            text: "<p>S.-A. Dragly<sup>1</sup>, M. Hobbi Mobarhan<sup>2</sup>, A. V. Solbrå<sup>1</sup>, S. Tennøe<sup>3</sup>, H. P. Langtangen<sup>*,3,5</sup>, A. Malthe-Sørenssen<sup>1</sup>, M. Fyhn, T. Hafting<sup>4</sup>, G. T. Einevoll<sup>6,1</sup></p>"
        }

        Text {
            id: affiliationsText
            anchors {
                top: authorsText.bottom
                left: parent.left
                right: parent.right
                margins: 32
                topMargin: 16
            }
            font.pixelSize: parent.width * 0.03
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            textFormat: Text.RichText
            text: "<p><sup>1</sup>Dept. of Physics, <sup>2</sup>Dept. of Biosci., <sup>3</sup>Dept. of Informatics, <sup>4</sup>Inst. of Basic Med. Sci., Univ. of Oslo, Oslo, Norway; <sup>5</sup>Simula Res. Lab., Oslo, Norway; <sup>6</sup>Dept. of Mathematical Sci. and Technol., Norwegian Univ. of Life Sci., Ås, Norway;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<sup>*</sup>Deceased</p>"
        }

        Text {
            id: descriptionText
            anchors {
                top: affiliationsText.bottom
                left: parent.left
                right: parent.right
                bottom: logoRow.top
                margins: 32
                topMargin: 48
            }
            font.pixelSize: parent.width * 0.05
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: "Neuronify is an educational tool meant to create intuition for how neurons and neural networks behave. We aim to provide a low entry point to simulation-based neuroscience. You can explore how changes on single cells lead to behavioral changes in important networks.

To build and explore neural networks, you drag neurons and measurement devices onto the screen. In addition, the app comes with several ready-made simulations for inspiration."
        }

        Row {
            id: logoRow
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 32
            }

            Image {
                width: parent.width * 0.4
                height: 64
                smooth: true
                antialiasing: true
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/logo/cinpla-logo.png"
            }

            Image {
                width: parent.width * 0.6
                height: 64
                smooth: true
                antialiasing: true
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/logo/uio-logo.png"
            }
        }
    }

    Neuronify {
        id: neuronify
        anchors {
            left: overlay.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        clip: true
    }

    Shortcut {
        sequence: "Ctrl+Shift+F"
        onActivated: {
            if(applicationWindow1.visibility !== ApplicationWindow.FullScreen) {
                applicationWindow1.visibility = ApplicationWindow.FullScreen
            } else {
                applicationWindow1.visibility = ApplicationWindow.Maximized
            }
        }
    }

    onClosing: {
        if (Qt.platform.os === "android"){
            close.accepted = false
        }
    }
}
