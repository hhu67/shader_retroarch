#version 450
layout(push_constant) uniform Push { vec4 SourceSize; } params;
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
    // Рисуем линии по высоте исходного разрешения игры
    float line = sin(vTexCoord.y * params.SourceSize.y * 3.14159);
    color *= mix(1.0, 0.7, abs(line)); 
    FragColor = vec4(color, 1.0);
}
