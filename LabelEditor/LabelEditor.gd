@tool
extends Control


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var waveform_view: Control = %WaveformView
@onready var spectrogram_view: Control = %SpectrogramView


func _ready() -> void:
	set_process(false)
	if not Engine.is_editor_hint():
		get_viewport().files_dropped.connect(on_files_dropped)
	
	%PlayButton.pressed.connect(begin_playback)
	%PauseButton.pressed.connect(pause_playback)
	%StopButton.pressed.connect(stop_playback)
	
	#%MenuBar/Min.pressed.connect(get_tree().quit)
	#%MenuBar/Max.pressed.connect(get_tree().quit)
	#%MenuBar/Close.pressed.connect(get_tree().quit)
	
	%VisualizerScrollBar.value_changed.connect(on_scroll)
	%VisualizerScrollBar.changed.connect(on_scroll_change)
	
	if audio_stream_player.stream != null:
		reload_shaders()

func reload_shaders() -> void:
	%VisualizerScrollBar.max_value = audio_stream_player.stream.get_length()
	
	var byte_data: PackedByteArray = audio_stream_player.stream.data
	var max_value: int = (2 ** 15) - 1 
	var sample_count: float = byte_data.size() / 2
	
	var power: int = ceili(log(sample_count) / log(2))
	if not power % 2 == 0:
		power += 1
	var axis_size: int = 2 ** (power / 2)
	
	var img: Image = Image.create(axis_size, axis_size, false, Image.FORMAT_RF)
	for i in range(0, byte_data.size(), 2):
		var value: float = byte_data.decode_s16(i) / float(max_value)
		img.set_pixel((i / 2) % axis_size, (i / 2) / axis_size, Color(value, 0.0, 0.0))
	
	var audio_texture: ImageTexture = ImageTexture.new()
	audio_texture.set_image(img)
	
	var sample_rate: float = float(audio_stream_player.stream.mix_rate)
	
	waveform_view.material.set_shader_parameter("offset", 0.0)
	waveform_view.material.set_shader_parameter("width", 10.0)
	waveform_view.material.set_shader_parameter("sample_rate", sample_rate)
	waveform_view.material.set_shader_parameter("sample_count", sample_count)
	waveform_view.material.set_shader_parameter("audio_texture", audio_texture)
	
	spectrogram_view.material.set_shader_parameter("offset", 0.0)
	spectrogram_view.material.set_shader_parameter("width", 10.0)
	spectrogram_view.material.set_shader_parameter("sample_rate", sample_rate)
	spectrogram_view.material.set_shader_parameter("sample_count", sample_count)
	spectrogram_view.material.set_shader_parameter("audio_texture", audio_texture)
	

var playhead_position: float = 0.0
func begin_playback() -> void:
	set_process(true)
	%VisualizerScrollBar.value = playhead_position
	audio_stream_player.play(playhead_position)

func pause_playback() -> void:
	set_process(false)
	playhead_position = audio_stream_player.get_playback_position()
	audio_stream_player.stop()

func stop_playback() -> void:
	set_process(false)
	playhead_position = 0.0
	%VisualizerScrollBar.value = playhead_position
	audio_stream_player.stop()

func on_scroll(value: float) -> void:
	playhead_position = value
	waveform_view.material.set_shader_parameter("offset", value)
	spectrogram_view.material.set_shader_parameter("offset", value)

func on_scroll_change():
	var page: float = %VisualizerScrollBar.page
	waveform_view.material.set_shader_parameter("width", page)
	spectrogram_view.material.set_shader_parameter("width", page)

func on_files_dropped(files) -> void:
	if files.size() == 0:
		return
	var audio_stream_wav: AudioStreamWAV = AudioStreamWAVLoader.load_from_path(files[0])
	audio_stream_player.stream = audio_stream_wav
	reload_shaders()
	print(files)

func _process(delta) -> void:
	%VisualizerScrollBar.value += delta

var panning: bool = false
func _input(event):
	if event is InputEventMouseMotion and panning:
		%VisualizerScrollBar.value += event.relative.x * 0.5
	
	if event.is_action_pressed("middle_click"):
		panning = true
	if event.is_action_released("middle_click"):
		panning = false
	
	if event.is_action_pressed("zoom_in"):
		%VisualizerScrollBar.page -= 2.0
	elif event.is_action_pressed("zoom_out"):
		%VisualizerScrollBar.page += 2.0
	elif event.is_action_pressed("scroll_up"):
		%VisualizerScrollBar.value -= 1.0
	elif event.is_action_pressed("scroll_down"):
		%VisualizerScrollBar.value += 1.0
	
