@tool
extends Control


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var waveform_view: Control = %WaveformView
@onready var spectrogram_view: Control = %SpectrogramView



var audio_list: Dictionary = {}

func _ready() -> void:
	#Ray.editors.append(self)
	if not Engine.is_editor_hint():
		get_viewport().files_dropped.connect(on_files_dropped)

func on_files_dropped(files) -> void:
	if files.size() == 0:
		return
	var audio_stream_wav: AudioStreamWAV = AudioStreamWAVLoader.load_from_path(files[0])
	audio_stream_player.stream = audio_stream_wav
	%VisualizerView.reload_shaders()
