extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	var audio = AudioStreamWAVLoader.load_from_path("res://data/Silver/01.wav")
	var audio_texture = AudioStreamWAVLoader.audio_to_texture(audio)
	
	var sample_count = audio.data.size() / 2
	
	material.set_shader_parameter("offset", 0.0)
	material.set_shader_parameter("width", 10.0)
	material.set_shader_parameter("sample_rate", 48000.0)
	material.set_shader_parameter("sample_count", sample_count)
	material.set_shader_parameter("audio_texture", audio_texture)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
