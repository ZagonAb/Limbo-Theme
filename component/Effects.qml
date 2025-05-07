import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: effectsRoot

    property alias noiseOpacity: noiseEffect.opacity
    property alias flickerInterval: flickerTimer.interval
    property alias flickerIntensity: flickerEffect.opacity
    property alias topGradientOpacity: topGradient.opacity
    property alias bottomGradientOpacity: bottomGradient.opacity

    Rectangle {
        id: topGradient
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 100
        opacity: 0.5

        gradient: Gradient {
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Rectangle {
        id: bottomGradient
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: 100
        opacity: 0.5

        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "black" }
        }
    }

    ShaderEffect {
        id: noiseEffect
        anchors.fill: parent
        opacity: 0.08

        property real time: 0

        vertexShader: "
        uniform highp mat4 qt_Matrix;
        attribute highp vec4 qt_Vertex;
        attribute highp vec2 qt_MultiTexCoord0;
        varying highp vec2 coord;
        void main() {
        coord = qt_MultiTexCoord0;
        gl_Position = qt_Matrix * qt_Vertex;
    }"

    fragmentShader: "
    varying highp vec2 coord;
    uniform lowp float qt_Opacity;
    uniform lowp float time;

    float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
    }

    void main() {
    vec2 p = coord * time;
    float noise = rand(p);
    gl_FragColor = vec4(vec3(noise), 1.0) * qt_Opacity;
    }"

    NumberAnimation on time {
        from: 0
        to: Math.PI * 2
        duration: 1000
        loops: Animation.Infinite
    }
    }

    Rectangle {
        id: flickerEffect
        anchors.fill: parent
        color: "black"
        opacity: 0

        Timer {
            id: flickerTimer
            interval: 100
            running: true
            repeat: true
            onTriggered: {
                flickerEffect.opacity = Math.random() * 0.1;
            }
        }
    }
}
