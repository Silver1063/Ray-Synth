extends TextureRect



func _ready():
	var audio: AudioStream = load("res://debug/01.wav")
	var shader = load("res://LabelEditor/spectrogram.gdshader")
	
	var y: int = 1024
	var x: int = ceil(1024 / 4 * audio.get_length())
	$"../SubViewport".size = Vector2i(x, y)
	
	ViewportTexture.new()
	
