@tool
extends Control


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var waveform_view: Control = %WaveformView
@onready var spectrogram_view: Control = %SpectrogramView

@onready var default_page: float = %VisualizerScrollBar.page
var zoom_index: int = 7
var zoom_levels: Array[float] = [0.25, 0.33, 0.50, 0.66, 0.75, 0.80, 0.90, 1.0, 1.10, 1.25, 1.50, 1.75, 2.0, 2.50, 3.0, 4.0, 5.0]

var audio_list: Dictionary = {}

func _ready() -> void:
	
	set_process(false)
	if not Engine.is_editor_hint():
		get_viewport().files_dropped.connect(on_files_dropped)
	
	%PlayButton.pressed.connect(start_playback)
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
func start_playback():
	set_process(true)
	audio_stream_player.play(playhead_position)
	move_playhead()

func pause_playback() -> void:
	set_process(false)
	playhead_position = audio_stream_player.get_playback_position()
	audio_stream_player.stop()

func stop_playback() -> void:
	set_process(false)
	playhead_position = 0.0
	move_playhead()
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
	audio_list[files[0]] = audio_stream_wav
	reload_shaders()
	var audio_label: Label = Label.new()
	audio_label.text = files[0]
	%Audio.add_child(audio_label)
	print(files)

func _process(delta) -> void:
	move_playhead()
	#if playhead_position >= %VisualizerScrollBar.value + %VisualizerScrollBar.page:
		#%VisualizerScrollBar.value += %VisualizerScrollBar.page

func move_playhead() -> void:
	if %Playhead.position.x > %Playhead.get_parent_area_size().x:
		%VisualizerScrollBar.value += %VisualizerScrollBar.page
	playhead_position = audio_stream_player.get_playback_position()
	%Playhead.position.x = %Playhead.get_parent_area_size().x * (playhead_position - %VisualizerScrollBar.value) / %VisualizerScrollBar.page

var panning: bool = false
func _input(event):
	if event is InputEventMouseMotion and panning:
		%VisualizerScrollBar.value += event.relative.x * 0.5
	
	if event.is_action_pressed("middle_click"):
		panning = true
	if event.is_action_released("middle_click"):
		panning = false
	
	if event.is_action_pressed("zoom_in"):
		zoom_index -= 1
		zoom_index = clamp(zoom_index, 0, zoom_levels.size()-1)
		%VisualizerScrollBar.page = default_page * zoom_levels[zoom_index]
	
	elif event.is_action_pressed("zoom_out"):
		zoom_index += 1
		zoom_index = clamp(zoom_index, 0, zoom_levels.size()-1)
		%VisualizerScrollBar.page = default_page * zoom_levels[zoom_index]
		
	elif event.is_action_pressed("scroll_up"):
		%VisualizerScrollBar.value -= zoom_levels[zoom_index]
	elif event.is_action_pressed("scroll_down"):
		%VisualizerScrollBar.value += zoom_levels[zoom_index]
	
