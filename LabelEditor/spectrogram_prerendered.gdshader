shader_type canvas_item;

uniform sampler2D test: source_color;
uniform sampler2DArray spectrogram_textures;

uniform float offset;
uniform float page = 10.0;

void fragment() {
	float pixel_offset = offset + (UV.x * page);
	float U = UV.x;
	float V = UV.y;
	float L = floor(pixel_offset / page);
	vec3 UVL = vec3(U, V, L);
	COLOR.rgb = texture(spectrogram_textures, UVL).rgb;
}

