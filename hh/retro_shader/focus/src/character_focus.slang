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

// Пользовательские параметры (появятся в меню RetroArch)
// Эти параметры контролируют силу эффекта
#pragma parameter focus_strength "Focus Strength" 0.6 0.0 1.0 0.05
#pragma parameter blur_radius "Blur Radius" 0.005 0.0 0.02 0.001
#pragma parameter vignette_strength "Vignette Strength" 0.3 0.0 1.0 0.05

void main() {
   vec3 color = texture(Source, vTexCoord).rgb;
   
   // 1. Расчет центра экрана
   vec2 center = vec2(0.5, 0.5);
   float dist = distance(vTexCoord, center); // Расстояние от текущего пикселя до центра
   
   // 2. Затемнение и размытие периферии
   // Чем дальше от центра, тем сильнее эффект
   float focus_factor = 1.0 - smoothstep(0.3, 0.7, dist); // От 0.3 до 0.7 радиуса

   // Затемнение (20%)
   float dim_factor = mix(0.8, 1.0, focus_factor); // 0.8 = 20% затемнения
   color *= dim_factor;

   // Имитация размытия (очень простое, для демонстрации)
   // Берем несколько соседних пикселей
   vec3 blurred_color = texture(Source, vTexCoord + vec2(blur_radius, 0.0)).rgb;
   blurred_color += texture(Source, vTexCoord - vec2(blur_radius, 0.0)).rgb;
   blurred_color += texture(Source, vTexCoord + vec2(0.0, blur_radius)).rgb;
   blurred_color += texture(Source, vTexCoord - vec2(0.0, blur_radius)).rgb;
   blurred_color += color; // Включаем центральный пиксель
   blurred_color /= 5.0; // Усредняем

   // Смешиваем оригинальный цвет с размытым в зависимости от фокуса
   color = mix(blurred_color, color, focus_factor);

   // 3. Виньетка (дополнительное затемнение краев)
   float vignette = 1.0 - (dist * dist * vignette_strength);
   color *= vignette;
   
   // 4. Подсветка центра (делаем его чуть ярче)
   color *= mix(1.0, 1.1, focus_factor); // Усиливаем яркость в центре
   
   FragColor = vec4(color, 1.0);
}
