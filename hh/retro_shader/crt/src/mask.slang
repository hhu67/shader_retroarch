#version 450
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
    // Маска: каждый 3-й пиксель монитора чуть темнее
    float m = mod(gl_FragCoord.x, 3.0);
    float mask = (m > 1.5) ? 0.9 : 1.0;
    FragColor = vec4(color * mask, 1.0);
}
