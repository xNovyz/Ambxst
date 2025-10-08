import QtQuick
import qs.config
import qs.modules.theme

Canvas {
    id: root
    property real amplitudeMultiplier: 0.5
    property real frequency: 6
    property color color: Colors.primaryFixed
    property real lineWidth: 4
    property real fullLength: width
    
    renderStrategy: Canvas.Cooperative
    renderTarget: Canvas.FramebufferObject
    antialiasing: true
    
    property real phase: 0
    
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onColorChanged: requestPaint()
    onLineWidthChanged: requestPaint()
    
    Component.onCompleted: requestPaint()

    onPaint: {
        if (width <= 0 || height <= 0) return;
        
        var ctx = getContext("2d");
        
        ctx.save();
        ctx.clearRect(0, 0, width, height);

        var amplitude = root.lineWidth * root.amplitudeMultiplier;
        var frequency = root.frequency;
        var centerY = height / 2;

        ctx.strokeStyle = root.color;
        ctx.lineWidth = root.lineWidth;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";
        ctx.beginPath();
        
        for (var x = ctx.lineWidth / 2; x <= root.width - ctx.lineWidth / 2; x += 2) {
            var waveY = centerY + amplitude * Math.sin(frequency * 2 * Math.PI * x / root.fullLength + root.phase);
            if (x === ctx.lineWidth / 2)
                ctx.moveTo(x, waveY);
            else
                ctx.lineTo(x, waveY);
        }
        ctx.stroke();
        ctx.restore();
        
        root.phase += 0.04;
    }
}
