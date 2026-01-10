#version 450

layout(set = 0, binding = 2) uniform sampler2D Source;
layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec4 FragColor;

void main() {
    vec4 col = texture(Source, vTexCoord);
    // Преобразование гаммы 2.2 -> 1.0
    FragColor = vec4(pow(col.rgb, vec3(2.2)), col.a);
}
