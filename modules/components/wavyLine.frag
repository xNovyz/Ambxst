#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float phase;
    float amplitude;
    float frequency;
    vec4 shaderColor;
    float lineWidth;
    float canvasWidth;
    float canvasHeight;
    float fullLength;
} ubuf;

#define PI 3.14159265359

// Calcula la cobertura de un punto para la onda con extremos redondeados
float coverage(vec2 pos, float centerY) {
    float x = pos.x;
    float k = ubuf.frequency * 2.0 * PI / ubuf.fullLength;
    float radius = ubuf.lineWidth * 1.5; // Radio de los extremos redondeados

    // Limita la coordenada X para que la onda termine en los puntos de inicio de los arcos
    float clippedX = clamp(x, radius, ubuf.canvasWidth - radius);

    // Valor de la onda en el punto X limitado
    float waveValue = sin(k * clippedX + ubuf.phase);
    float waveY = centerY + ubuf.amplitude * waveValue;

    // Derivada para calcular el ancho efectivo de la línea
    float derivative = abs(cos(k * clippedX + ubuf.phase) * k * ubuf.amplitude);
    float effectiveWidth = ubuf.lineWidth * 1.0 * sqrt(1.0 + derivative * derivative);
    float halfWidth = effectiveWidth * 0.5;

    // Calcula la distancia del píxel a la forma de la onda con extremos redondeados
    float dist;
    if (x < radius) {
        // Extremo izquierdo: distancia al centro del círculo
        dist = distance(pos, vec2(radius, waveY));
    } else if (x > ubuf.canvasWidth - radius) {
        // Extremo derecho: distancia al centro del círculo
        dist = distance(pos, vec2(ubuf.canvasWidth - radius, waveY));
    } else {
        // Parte central: distancia vertical a la onda
        dist = abs(pos.y - waveY);
    }

    // Devuelve 1 si el píxel está dentro de la línea, 0 si no
    return step(dist, halfWidth);
}

void main() {
    vec2 pixelPos = qt_TexCoord0 * vec2(ubuf.canvasWidth, ubuf.canvasHeight);
    float centerY = ubuf.canvasHeight * 0.5;
    
    // Supersampling 3x3: muestrea 9 puntos alrededor del píxel
    float alpha = 0.0;
    float samples = 0.0;
    
    for (float dy = -0.66; dy <= 0.66; dy += 0.66) {
        for (float dx = -0.66; dx <= 0.66; dx += 0.66) {
            vec2 samplePos = pixelPos + vec2(dx, dy);
            alpha += coverage(samplePos, centerY);
            samples += 1.0;
        }
    }
    
    alpha /= samples;
    
    if (alpha < 0.5) {
        discard;
    }
    
    fragColor = vec4(ubuf.shaderColor.rgb, ubuf.shaderColor.a * alpha * ubuf.qt_Opacity);
}
