#version 450

layout(push_constant) uniform Push {
    vec4 SourceSize;
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
   // Читаем цвет из предыдущего "тяжелого" прохода
   vec3 color = texture(Source, vTexCoord).rgb;
   
   // 1. Улучшенные сканирующие линии (ориентированы на разрешение вывода)
   // Используем OutputSize, чтобы линии были четкими на твоем мониторе
   float scanline = sin(vTexCoord.y * params.OutputSize.y * 1.0); 
   scanline = mix(1.0, 0.8, pow(abs(scanline), 2.0)); 
   
   // 2. Теневая маска (RGB сетка)
   // Создает эффект мелких точек (фосфора)
   float mask = 1.0;
   float x_pos = gl_FragCoord.x;
   if (mod(x_pos, 3.0) < 1.0) color.r *= 1.1; 
   else if (mod(x_pos, 3.0) < 2.0) color.g *= 1.1;
   else color.b *= 1.1;
   
   // 3. Компенсация яркости
   color *= 1.2; 
   
   FragColor = vec4(color * scanline, 1.0);
}
