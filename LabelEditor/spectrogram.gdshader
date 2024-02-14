shader_type canvas_item;

const int LINEAR = 0;
const int MEL_SCALE = 1;
const int LOGARITHMIC = 2;
uniform int mode = 0;

// color of waveform duh
uniform vec4 spectrogram_color: source_color = vec4(1.0);

// in seconds moves and zooms the waveform
uniform float offset = 0.0;
uniform float width = 10.0;

// properties of audio
uniform float sample_rate;
uniform float sample_count;

// length of average window
uniform float max_window = 50;

uniform sampler2D audio_texture: hint_default_black, filter_nearest;

float get_sample(int n) {
	int root_size = textureSize(audio_texture, 0).x;
	float x = float(n % root_size) / float(root_size);
	float y = float(n) / float(root_size * root_size);
	return texture(audio_texture, vec2(x, y)).r;
}

float mel_to_freq(float m) {
	return 700.0 * (exp(m / 1127.0) - 1.0);
}

float freq_to_mel(float f) {
	return 1127.0 * log(1.0 + f / 700.0);
}


void fragment() {
	float y = 1.0 - UV.y;
	
	float max_frequency = (sample_rate / 2.0);
	float max_mel = freq_to_mel(max_frequency);
	
	float frequency;
	switch (mode) {
		case LINEAR:
			frequency = y * max_frequency;
			break;
		case MEL_SCALE:
			frequency = mel_to_freq(y * max_mel);
			break;
		case LOGARITHMIC:
			frequency = exp2(y * (log2(max_frequency)));
			break;
		default:
			discard;
			break;
	}
	
	float window = max_window;
	
	int sample = int(UV.x * width * sample_rate + offset * sample_rate);
	int samples = int((window * sample_rate) / 1000.0);
	
	float coefficient = 2.0 * PI * frequency;
	vec2 value = vec2(0.0);
	for (int i = 0; i < samples; i++) {
		// 2*PI*f sets the frequency, i / sample_rate, gets the time
		float t = float(i) / sample_rate;
		float hann = pow(sin(PI * float(i) / float(samples)), 2.0);
		value += get_sample(sample + i) * hann * vec2(cos(coefficient * t), -sin(coefficient * t));
	}
	
	//= sqrt(v / (1.0 + v));
	//v = clamp(v, 0.0, 1.0);
	COLOR.rgb = vec3(pow(length(value), 2));
	
}
