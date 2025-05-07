import QtQuick 2.15

Item {
    id: root
    property alias source: sourceImage.source
    property alias fillMode: sourceImage.fillMode
    width: sourceImage.width
    height: sourceImage.height

    property real leftGradient: 0.3
    property real rightGradient: 0.3
    property real topGradient: 0.3
    property real bottomGradient: 0.3
    property real gradientSoftness: 0.2

    Image {
        id: sourceImage
        anchors.fill: parent
        visible: false
    }

    ShaderEffect {
        id: shaderEffect
        anchors.fill: sourceImage
        property variant source: sourceImage
        property real leftGrad: root.leftGradient
        property real rightGrad: root.rightGradient
        property real topGrad: root.topGradient
        property real bottomGrad: root.bottomGradient
        property real softness: root.gradientSoftness

        fragmentShader: "
        varying highp vec2 qt_TexCoord0;
        uniform sampler2D source;
        uniform lowp float qt_Opacity;
        uniform lowp float leftGrad;
        uniform lowp float rightGrad;
        uniform lowp float topGrad;
        uniform lowp float bottomGrad;
        uniform lowp float softness;

        void main() {
        highp vec4 originalColor = texture2D(source, qt_TexCoord0);
        highp float gray = dot(originalColor.rgb, vec3(0.299, 0.587, 0.114));
        highp vec4 grayColor = vec4(gray, gray, gray, originalColor.a);

        highp float leftEdge = smoothstep(0.0, leftGrad + softness, qt_TexCoord0.x);
        highp float rightEdge = smoothstep(1.0, 1.0 - rightGrad - softness, qt_TexCoord0.x);
        highp float topEdge = smoothstep(0.0, topGrad + softness, qt_TexCoord0.y);
        highp float bottomEdge = smoothstep(1.0, 1.0 - bottomGrad - softness, qt_TexCoord0.y);

        highp float totalGradient = leftEdge * rightEdge * topEdge * bottomEdge;

        gl_FragColor = mix(vec4(0.0, 0.0, 0.0, 1.0), grayColor, totalGradient) * qt_Opacity;
    }
    "
    }
}
