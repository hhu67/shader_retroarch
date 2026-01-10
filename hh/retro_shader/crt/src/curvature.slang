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

// Коэффициент кривизны: чем выше, тем сильнее эффект ( )
#pragma parameter warp "Screen Curvature" 0.03 0.0 0.1 0.01

void main() {
        // Преобразуем координаты в диапазон -1.0 до 1.0
            vec2 uv = vTexCoord * 2.0 - 1.0;
                
                    // Применяем искажение (формула линзы)
                        vec2 offset = abs(uv.yx) * vec2(0.03); // Здесь задается сила изгиба
                            uv = uv + uv * offset * offset;
                                
                                    // Возвращаем координаты в диапазон 0.0 - 1.0
                                        vec2 final_uv = (uv + 1.0) * 0.5;

                                            // Проверяем, не вышли ли мы за границы экрана (рисуем черные поля)
                                                if (final_uv.y < 0.0 || final_uv.y > 1.0 || final_uv.x < 0.0 || final_uv.x > 1.0) {
                                                            FragColor = vec4(0.0, 0.0, 0.0, 1.0);
                                                } else {
                                                            FragColor = texture(Source, final_uv);
                                                }
}

                                                }
                                                }
}
}
}