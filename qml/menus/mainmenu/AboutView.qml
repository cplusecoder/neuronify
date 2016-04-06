import QtQuick 2.0
import "../../style"
import "../"


MainMenuPage {
    id: aboutView

    title: "About"

    clip: true

    width: 200
    height: 100

    Flickable {
        id: aboutFlickable
        anchors {
            fill: parent
            margins: Style.margin
        }

        clip: true
        contentHeight: aboutText.height

        Text {
            id: aboutText

            width: aboutFlickable.width

            font: Style.text.font
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: Style.text.color
            textFormat: Text.RichText
            text: "<p>"+
                  "Neuronify is an educational tool meant to create intuition for how neurons and neural networks behave. You can use it to combine neurons with different connections, just like the ones we have in our brain, and explore how changes on single cells lead to behavioral changes in important networks."
                  +"<p>"+
                  "We aim to provide a low entry point to simulation-based neuroscience. Most undergraduate students don’t have the computational experience to create their own neural simulator. These students should also have the opportunity to build up their intuition by experimenting with neural phenomena."
                  +"<p>"+
                  "Neuronify is based on an integrate-and-fire model of neurons. This is one of the simplest models of neurons that exist. It focuses on the spike timing of a neuron and ignores the details of the action potential dynamics. These neurons are modelled as simple RC circuits. When the membrane potential is above a certain threshold, a spike is generated and the voltage is reset to its resting potential. This spike then signals other neurons through its synapses.  "
                  +"</p>"
        }

//        Image {
//            id: image
//            anchors {
//                top: aboutText.bottom
//                horizontalCenter: parent.horizontalCenter
//            }

//            asynchronous: true
//            width: Style.size * 48
//            height: Style.size * 24
//            fillMode: Image.PreserveAspectFit
//            smooth: true
//            source: "qrc:/images/logo.png"
//        }

    }
}



