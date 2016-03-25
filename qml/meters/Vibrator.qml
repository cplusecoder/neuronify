import QtQuick 2.0
import Neuronify 1.0

import ".."

Node {
    id: vibratorRoot
    objectName: "Vibrator"
    fileName: "meters/Vibrator.qml"

    width: 62
    height: 62

    engine: VibratorEngine {

    }

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        antialiasing: true
        smooth: true
        source: "qrc:/images/meters/speaker.png"
    }
}
