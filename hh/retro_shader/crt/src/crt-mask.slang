#version 450

layout(push_constant) uniform Push {
    vec4 OutputSize;
} params;

layout(std140, set = 0, binding = 0) uniform UBO { mat4 MVP; } global;

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

void main() {
   vec3 color = texture(Source, vTexCoord).rgb;

   // Создаем вертикальную маску (полоски RGB)
   // Цикл повторяется каждые 3 пикселя монитора
   float mask = 1.0;
   float x = mod(gl_FragCoord.x, 3.0);
   
   if (x < 1.0) mask = 0.9;      // Чуть темнее слева
   else if (x < 2.0) mask = 1.0; // Ярко в центре
   else mask = 0.8;             // Темнее справа (разделитель)

   FragColor = vec4(color * mask, 1.0);
}
