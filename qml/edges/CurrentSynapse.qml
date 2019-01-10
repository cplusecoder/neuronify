import QtQuick 2.0
import QtQuick.Particles 2.0

import Neuronify 1.0

import ".."
import "../controls"
import "../hud"
import "../style"

Edge {
    id: root

    property real timeStep
    property bool itemAFiredLast: false
    property bool weightChange: false
    property bool firstWeightChange: true
    property bool learningEnabled: false
    property bool resetFireTimer: false

    objectName: "CurrentSynapse"
    filename: "edges/CurrentSynapse.qml"
    name: "Current based synapse"

    lineWidth: 1.0 + engine.maximumCurrent * 1e9

    onItemAChanged: {
        if(itemA && itemA.isNeuron && itemB && itemB.isNeuron) {
            setup()
        }
    }

    onItemBChanged: {
        if(itemA && itemA.isNeuron && itemB && itemB.isNeuron) {
            setup()
        }
    }

    function setup() {
        console.log("Setting up with", itemA, itemB)

        if(itemA.engine) {
            itemA.engine.fired.connect(function() {
                if(learningEnabled) {
                    if(!itemAFiredLast) {
                        weightChange = true
                    }
                    resetFireTimer = true
                    itemAFiredLast = true
                }
            })
        }

        if(itemB.engine) {
            itemB.engine.fired.connect(function() {
                if(learningEnabled) {
                    if(itemAFiredLast) {
                        weightChange = true
                    }
                    resetFireTimer = true
                    itemAFiredLast = false
                }
            })
        }
    }

    engine: EdgeEngine {
        id: engine

        property bool alphaFunction
        property real tau
        property real maximumCurrent
        property real delay: 0.0

        property real time
        property real linear
        property real exponential

        property real timeSinceLastFire: 0.0

        property var triggers: []

        savedProperties: [
            PropertyGroup {
                // properties
                property alias learningEnabled: root.learningEnabled
                property alias tau: engine.tau
                property alias delay: engine.delay
                property alias alphaFunction: engine.alphaFunction

                // dynamics
                property alias linear: engine.linear
                property alias exponential: engine.exponential
                property alias triggers: engine.triggers

                // depends on learning enabled
                property alias maximumCurrent: engine.maximumCurrent
            }
        ]

        function trigger() {
            exponential = maximumCurrent
        }

        onResettedDynamics: {
            linear = 0.0
            exponential = 0.0
            triggers.length = 0
            if(learningEnabled) {
                maximumCurrent = 0.0
            }
        }

        onResettedProperties: {
            tau = 2.0e-3
            delay = 5.0e-3
            alphaFunction = false
            if(!learningEnabled) {
                maximumCurrent = 3.0e-9
            }
        }

        onStepped:{
            root.timeStep = dt;
            currentOutput = exponential
            exponential = exponential - exponential * dt / tau;
            if(triggers.length > 0) {
                if(triggers[0] < time) {
                    trigger();
                    triggers.shift();
                }
            }
            if(learningEnabled) {
                if(weightChange) {
                    if(!firstWeightChange) {
                        var delta = 0.0
                        if(itemAFiredLast) {
                            delta = -20e-9 * Math.exp(-timeSinceLastFire / 0.0024)
                        } else {
                            delta = 10e-9 * Math.exp(-timeSinceLastFire / 0.0016)
                        }
                        maximumCurrent += delta * dt * 10
                        maximumCurrent = Math.max(0.0, Math.min(10.0e-9, maximumCurrent))
                    }
                    weightChange = false
                    firstWeightChange = false
                }
                if(resetFireTimer) {
                    timeSinceLastFire = 0.0
                    resetFireTimer = false
                }
            }
            timeSinceLastFire += dt
            time += dt;
        }

        onReceivedFire: {
            if(root.playbackSpeed < 4) {
                signalComponent.createObject(root, {delay: delay})
            }

            if(delay > 0.0) {
                triggers.push(time + delay);
            } else {
                trigger();
            }
        }
    }

    savedProperties: [
        PropertyGroup {
            property alias engine: engine
        }
    ]

    controls: Component {
        PropertiesPage {
            property string title: "Current based synapse"
            SwitchControl {
                target: root
                property: "learningEnabled"
                checkedText: "Learning enabled"
                uncheckedText: "Learning disabled"
            }
            BoundSlider {
                target: engine
                property: "maximumCurrent"
                text: "Maximum current"
                unit: "nA"
                minimumValue: 0e-9
                maximumValue: 10e-9
                unitScale: 1e-9
                stepSize: 0.1e-9
                precision: 1
            }
            BoundSlider {
                target: engine
                property: "tau"
                text: "Time constant"
                unit: "ms"
                minimumValue: 0.1e-3
                maximumValue: 6.0e-3
                unitScale: 1e-3
                stepSize: 1e-4
                precision: 2
            }
            BoundSlider {
                target: engine
                property: "delay"
                text: "Delay"
                unit: "ms"
                minimumValue: 0.0e-3
                maximumValue: 30.0e-3
                unitScale: 1e-3
                stepSize: 1e-4
                precision: 1
            }
        }
    }

    Component {
        id: signalComponent
        Rectangle {
            id: signalRectangle
            property real delay: 0.0
            property real fraction: 0.0
            property real previousTime: Date.now()

            width: 24
            height: width
            radius: width * 0.5
//            source: "qrc:///images/particles/particle.png"
            color: root.itemA ? root.itemA.color : "black"

            x: root.startPoint.x + (root.endPoint.x - root.startPoint.x) * fraction - width / 2
            y: root.startPoint.y + (root.endPoint.y - root.startPoint.y) * fraction - height / 2

            opacity: Math.min(1.0, 3 * (1.0 - fraction))

            Connections {
                target: engine
                onStepped: {
                    var duration = Math.max(240, delay / (root.timeStep * root.playbackSpeed) * 16)
                    var currentTime = Date.now()
                    var delta = currentTime - previousTime
                    signalRectangle.fraction += delta / duration
                    previousTime = currentTime
                    if(fraction > 1.0) {
                        signalRectangle.destroy()
                    }
                }
            }
        }
    }
}
