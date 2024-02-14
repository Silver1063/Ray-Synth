extends ColorRect


@onready var audio_stream: AudioStreamWAV = %AudioStreamPlayer.stream


func _ready():
	%VisualizerScrollBar.value_changed.connect(on_scrollbar_value_change)
	%VisualizerScrollBar.changed.connect(on_scrollbar_change)
	setup_shader()


func setup_shader() -> void:
	if audio_stream == null:
		return

	var audio_texture: ImageTexture = AudioStreamWAVLoader.audio_to_texture(audio_stream)

	var sample_count: float = audio_stream.data.size() / 2
	var sample_rate: float = audio_stream.mix_rate

	material.set_shader_parameter("offset", 0.0)
	material.set_shader_parameter("page", 10.0)
	material.set_shader_parameter("sample_rate", sample_rate)
	material.set_shader_parameter("sample_count", sample_count)
	material.set_shader_parameter("audio_texture", audio_texture)


func on_scrollbar_value_change(value: float) -> void:
	material.set_shader_parameter("offset", value)

func on_scrollbar_change() -> void:
	material.set_shader_parameter("page", %VisualizerScrollBar.page)
