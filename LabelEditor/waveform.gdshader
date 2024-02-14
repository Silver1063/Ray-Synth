shader_type canvas_item;

// color of waveform duh
uniform vec4 waveform_color: source_color = vec4(1.0);

// in seconds moves and zooms the waveform
uniform float offset = 0.0;
uniform float page = 10.0;

// properties of audio
uniform float sample_rate;

uniform sampler2D audio_texture: hint_default_black, filter_nearest;

float get_sample(int n) {
	int root_size = textureSize(audio_texture, 0).x;
	float x = float(n % root_size) / float(root_size);
	float y = float(n) / float(root_size * root_size);
	return texture(audio_texture, vec2(x, y)).r;
}

void fragment() {
	float window = page;
	int sample = int(UV.x * page * sample_rate + offset * sample_rate);
	int samples = int((window * sample_rate) / (1000.0 * 2.0));
	
	vec2 value = vec2(0.0, 0.0);
	for (int i = -samples; i <= samples; i++) {
		float sample = get_sample(sample + i);
		value.x = min(value.x, sample);
		value.y = max(value.y, sample);
	}
	
	if (UV.y - 0.5 >= value.x && UV.y - 0.5 <= value.y ) {
		COLOR = waveform_color;
	}
	else {
		discard;
	}
}