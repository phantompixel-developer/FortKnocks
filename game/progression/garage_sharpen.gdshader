shader_type canvas_item;

uniform float strength : hint_range(0.0, 0.35, 0.01) = 0.10;

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE;
	vec4 center = texture(TEXTURE, UV);
	vec4 north = texture(TEXTURE, UV + vec2(0.0, -px.y));
	vec4 south = texture(TEXTURE, UV + vec2(0.0, px.y));
	vec4 east = texture(TEXTURE, UV + vec2(px.x, 0.0));
	vec4 west = texture(TEXTURE, UV + vec2(-px.x, 0.0));
	vec4 sharpened = center * (1.0 + 4.0 * strength) - (north + south + east + west) * strength;
	COLOR = vec4(clamp(sharpened.rgb, 0.0, 1.0), center.a);
}
