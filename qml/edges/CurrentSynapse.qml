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

    objectName: "CurrentSynapse"
    filename: "edges/CurrentSynapse.qml"

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

        property real timeSinceLastWeightChange: 0.0

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
            if(alphaFunction) {
                linear = 0.0;
                exponential = Math.exp(1.0);
            } else {
                exponential = 1.0;
            }
        }

        onResettedDynamics: {
            linear = 0.0;
            exponential = 0.0;
            triggers.length = 0;
            if(learningEnabled) {
                maximumCurrent = 3.0e-9
            }
        }

        onResettedProperties: {
            tau = 2.0e-3
            delay = 5.0e-3
            alphaFunction = false;
            if(!learningEnabled) {
                maximumCurrent = 3.0e-9
            }
        }

        onStepped:{
            root.timeStep = dt;
            if(alphaFunction) {
                currentOutput = maximumCurrent * linear * exponential;
            } else {
                currentOutput = maximumCurrent * exponential;
            }
            if(alphaFunction) {
                linear = linear + dt / tau;
            }
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
                            delta = - 1e-9 * Math.exp(-timeSinceLastWeightChange / 0.002)
                        } else {
                            delta = 1e-9 * Math.exp(-timeSinceLastWeightChange / 0.001)
                        }
                        maximumCurrent += delta

                        console.log(delta)

                        timeSinceLastWeightChange = 0.0
                    }

                    weightChange = false
                    firstWeightChange = false
                }
            }
            timeSinceLastWeightChange += dt
            time += dt;
        }

        onReceivedFire: {
//            emitter.burst(1);
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

//    Emitter {
//        id: emitter
//        property real duration: {
//            var result = 0.0;
//            if(engine.delay > 0 && root.timeStep > 0) {
//                return Math.max(1, engine.delay / (root.timeStep * Style.playbackSpeed) * 16);
//            } else {
//                result = 1;
//            }
//            return result;
//        }
//        system: particleSystem
//        x: root.startPoint.x
//        y: root.startPoint.y
//        emitRate: 0.0
//        lifeSpan: duration
//        velocity: PointDirection {
//            x: (root.endPoint.x - root.startPoint.x) / emitter.duration * 1000;
//            y: (root.endPoint.y - root.startPoint.y) / emitter.duration * 1000;
//        }
//        size: 24 * Style.workspaceScale
//    }

//    Age {
//        id: ageAffector
//        x: root.endPoint.x - width * 0.5
//        y: root.endPoint.y - width * 0.5
//        system: root.particleSystem
//        width: 8
//        height: 8
//        shape: EllipseShape {}
//        lifeLeft: 0.0
//    }
}
