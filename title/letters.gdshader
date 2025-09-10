shader_type canvas_item;

void fragment() {
	float t = TIME * 0.4;
	COLOR = texture(TEXTURE,UV + vec2(0.0,
		  0.005 * sin(20.0 * UV.y + 2.0 * t - 0.11) 
		+ 0.004 * cos(15.0 * UV.y + 3.0 * t + 0.05)
		+ 0.003 * cos(9.0 * UV.y + 4.0 * t + 1.52)
		+ 0.002 * sin(5.0 * UV.y + 5.0 * t + 1.53) 
	));
}
