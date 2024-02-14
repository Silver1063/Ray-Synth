extends Control

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var waveform_view: Control = %WaveformView
@onready var spectrogram_view: Control = %SpectrogramView
@onready var default_page: float = %VisualizerScrollBar.page
var zoom_index: int = 9
var zoom_levels: Array[float] = [0.05, 0.1, 0.25, 0.33, 0.50, 0.66, 0.75, 0.80, 0.90, 1.0, 1.10, 1.25, 1.50, 1.75, 2.0, 2.50, 3.0, 4.0, 5.0, 8.0, 10.0]

func _ready() -> void:
	set_process(false)
	Ray.play.connect(play)
	Ray.pause.connect(pause)
	Ray.stop.connect(stop)
	Ray.playhead_position_changed.connect(move_playhead)
	#Ray.record.connect(record)


func _process(delta) -> void:
	Ray.playhead_position += delta
	if Ray.playhead_position >= %VisualizerScrollBar.value + %VisualizerScrollBar.page:
		%VisualizerScrollBar.value += %VisualizerScrollBar.page

func play(from: float):
	set_process(true)
	audio_stream_player.play(from)
	move_playhead()

func pause() -> void:
	set_process(false)
	Ray.playhead_position = audio_stream_player.get_playback_position()
	audio_stream_player.stop()

func stop() -> void:
	set_process(false)
	audio_stream_player.stop()
	Ray.playhead_position = audio_stream_player.get_playback_position()
	%VisualizerScrollBar.value = Ray.playhead_position


func move_playhead() -> void:
	var value: float = %VisualizerScrollBar.value
	var page: float = %VisualizerScrollBar.page
	

	%Playhead.position.x = size.x * fmod(Ray.playhead_position, page) / page

	if %Playhead.position.x > size.x:
		%VisualizerScrollBar.value += page


var panning: bool = false
func _gui_input(event):
	if event is InputEventMouseMotion and panning:
		%VisualizerScrollBar.value -= event.relative.x * 0.05

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
