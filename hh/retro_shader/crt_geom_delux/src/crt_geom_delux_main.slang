#version 450

layout(push_constant) uniform Push {
    vec4 SourceSize;
    vec4 OutputSize;
    uint FrameCount;
    float CURVATURE;
    float MASK_STRENGTH;
    float SCANLINE_STRENGTH;
} params;

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

// Функция искривления экрана (Curvature)
vec2 curve(vec2 uv) {
    uv = (uv - 0.5) * 2.0;
    uv *= 1.1; // Небольшой зум, чтобы не было черных краев
    uv.x *= 1.0 + pow((abs(uv.y) / 4.0), 2.0);
    uv.y *= 1.0 + pow((abs(uv.x) / 3.0), 2.0);
    uv  = (uv / 2.0) + 0.5;
    return uv;
}

void main() {
    vec2 uv = curve(vTexCoord);
    
    // Проверка границ (черные полосы за пределами экрана)
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec3 col = texture(Source, uv).rgb;

    // Эмуляция сканлайнов
    float scanline = sin(uv.y * params.SourceSize.y * 3.1415) * params.SCANLINE_STRENGTH;
    col -= col * scanline * 0.3;

    // Простая маска тринитрон (RGB полосы)
    float mask = 1.0 - params.MASK_STRENGTH;
    if (mod(gl_FragCoord.x, 3.0) < 1.0) col.r *= 1.0;
    else if (mod(gl_FragCoord.x, 3.0) < 2.0) col.g *= 1.0;
    else col.b *= 1.0;
    
    col += mask * 0.2; // Немного яркости для компенсации маски

    FragColor = vec4(col, 1.0);
}
