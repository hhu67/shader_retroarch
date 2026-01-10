#version 450

layout(push_constant) uniform Push {
    vec4 SourceSize;
    vec4 OriginalSize;
    vec4 OutputSize;
    uint FrameCount;
    float curvature;
    float mask_dark;
    float bloom_intensity;
    float scanline_weight;
} params;

#pragma parameter curvature "CRT Curvature" 0.03 0.0 0.1 0.01
#pragma parameter mask_dark "Mask Strength" 0.5 0.0 1.0 0.05
#pragma parameter bloom_intensity "Bloom Intensity" 0.3 0.0 1.0 0.05
#pragma parameter scanline_weight "Scanline Weight" 0.3 0.0 1.0 0.05

layout(std140, set = 0, binding = 0) uniform UBO {
    mat4 MVP;
} global;

#pragma stage vertex
layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

void main() {
    gl_Position = global.MVP * Position;
    vTexCoord = TexCoord;
}

#pragma stage fragment
layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec4 FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;

// Функция искривления экрана
vec2 curve(vec2 uv) {
    uv = (uv - 0.5) * 2.0;
    uv *= 1.1; // Небольшой зум, чтобы скрыть края
    uv.x *= 1.0 + pow((abs(uv.y) * params.curvature), 2.0);
    uv.y *= 1.0 + pow((abs(uv.x) * params.curvature), 2.0);
    uv = (uv / 2.0) + 0.5;
    return uv;
}

void main() {
    vec2 uv = curve(vTexCoord);
    
    // Проверка границ (черные полосы по краям кривизны)
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // 1. Сэмплирование с легким размытием (Bloom/Glow)
    vec4 col = texture(Source, uv);
    vec4 glow = texture(Source, uv + vec2(0.001, 0.001)) * 0.5;
    glow += texture(Source, uv - vec2(0.001, 0.001)) * 0.5;
    col += glow * params.bloom_intensity;

    // 2. Сканирующие линии (Scanlines)
    float scanline = sin(uv.y * params.SourceSize.y * 3.1415) * params.scanline_weight;
    col.rgb -= scanline * col.rgb;

    // 3. Теневая маска (Aperture Grille / Shadow Mask)
    // Имитирует структуру пикселей люминофора
    float mask = 1.0 - params.mask_dark;
    if (mod(gl_FragCoord.x, 3.0) < 1.0) {
        col.r *= 1.1; col.g *= mask; col.b *= mask;
    } else if (mod(gl_FragCoord.x, 3.0) < 2.0) {
        col.r *= mask; col.g *= 1.1; col.b *= mask;
    } else {
        col.r *= mask; col.g *= mask; col.b *= 1.1;
    }

    // 4. Виньетка (затемнение по углам)
    float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
    vignette = pow(16.0 * vignette, 0.1);
    col.rgb *= vignette;

    FragColor = vec4(col.rgb, 1.0);
}
