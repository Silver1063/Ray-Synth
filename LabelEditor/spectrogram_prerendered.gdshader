shader_type canvas_item;

uniform bool textures_loaded = false;

uniform sampler2DArray spectrogram_textures : repeat_enable;
uniform sampler2D gradient: source_color;

uniform float offset;
uniform float page = 10.0;

const float rendered_page = 10.0;

void fragment() {
	if(!textures_loaded) {
		discard;
	}
	
	float frag_offset = offset + (UV.x * page);
	float U = (UV.x + offset / page) * (page / rendered_page);
	float V = UV.y;
	float L = floor(frag_offset / rendered_page);
	vec3 UVL = vec3(U, V, L);
	
	ivec3 s = textureSize(spectrogram_textures, 0);
	float v = texture(spectrogram_textures, UVL).r;
	COLOR.rgb = texture(gradient, vec2(v,0)).rgb;
}

