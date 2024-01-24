shader_type canvas_item;

// color of waveform duh
uniform vec4 waveform_color: source_color = vec4(1.0);

// in seconds moves and zooms the waveform
uniform float offset = 0.0;
uniform float width = 10.0;

// properties of audio
uniform float sample_rate;

// length of average window
uniform float window = 6;

uniform sampler2D audio_texture: hint_default_black, filter_nearest;

float get_sample(int n) {
	int root_size = textureSize(audio_texture, 0).x;
	float x = float(n % root_size) / float(root_size);
	float y = float(n) / float(root_size * root_size);
	return texture(audio_texture, vec2(x, y)).r;
}

void fragment() {
	int sample = int(UV.x * width * sample_rate + offset * sample_rate);
	int samples = int((window * sample_rate) / (1000.0 * 2.0));
	
	float value = 0.0;
	for (int i = -samples; i <= samples; i++) {
		value += abs(get_sample(sample + i));
	}
	value = value / float(samples);
	
	if (abs(UV.y - 0.5) <= value) {
		COLOR = waveform_color;
	}
	else {
		discard;
	}
}