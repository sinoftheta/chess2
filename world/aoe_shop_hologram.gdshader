shader_type canvas_item;

uniform float time_scale = 0.4;
void fragment() {
	
	//COLOR = texture(TEXTURE,UV + vec2(0.0,
		  //0.005 * sin(20.0 * UV.y + 2.0 * t - 0.11)
		//+ 0.004 * cos(15.0 * UV.y + 3.0 * t + 0.05)
		//+ 0.003 * cos(9.0 * UV.y + 4.0 * t + 1.52)
		//+ 0.002 * sin(5.0 * UV.y + 5.0 * t + 1.53)
	//));
	float t = TIME * time_scale;
	float f = 0.5 + 0.5 * sin(cos(UV.x / TEXTURE_PIXEL_SIZE.x / (3.0 + 2.0 * sin(TIME * 0.1))) * 0.5 + ( UV.y + TEXTURE_PIXEL_SIZE.y * 5.0 * TIME) * 0.33 * PI / TEXTURE_PIXEL_SIZE.y);
	float c = max(max(COLOR.r, COLOR.g), COLOR.b);
	
	COLOR = vec4(c,c,c,
		COLOR.a * (f + 0.3)
	);

}
