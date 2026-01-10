#version 450
layout(push_constant) uniform Push { vec4 SourceSize; vec4 OutputSize; } params;
layout(std140, set = 0, binding = 0) uniform UBO { mat4 MVP; } global;

#pragma stage vertex
layout(location = 0) in vec4 Position; layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;
void main() { gl_Position = global.MVP * Position; vTexCoord = TexCoord; }

#pragma stage fragment
layout(location = 0) in vec2 vTexCoord; layout(location = 0) out vec4 FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;

void main() {
    vec3 color = texture(Source, vTexCoord).rgb;
    float dist = distance(vTexCoord, vec2(0.5));
    
    // Создаем маску фокуса (центр яркий, края размыты)
    float focus = 1.0 - smoothstep(0.2, 0.6, dist);
    
    // Затемняем края на 20% (умножаем на 0.8)
    color *= mix(0.8, 1.0, focus);
    
    // Простое размытие краев
    vec3 blur = texture(Source, vTexCoord + 0.002).rgb + texture(Source, vTexCoord - 0.002).rgb;
    blur /= 2.0;
    
    color = mix(blur, color, focus);
    FragColor = vec4(color, 1.0);
}
