extends ColorRect


@onready var shader: Shader = load("res://LabelEditor/spectrogram.gdshader")
@onready var audio_stream: AudioStreamWAV = %AudioStreamPlayer.stream
@onready var subviewport: SubViewport = SubViewport.new()
@onready var surface: ColorRect = ColorRect.new()


var offset: float
var duration: float
const width: float = 10.0
var chunks: int

var images: Array[Image] = []
var chunk: int = 0
var rendered: bool = false


func _ready() -> void:
	%VisualizerScrollBar.value_changed.connect(on_scrollbar_value_change)
	%VisualizerScrollBar.changed.connect(on_scrollbar_change)
	setup_shader()


func setup_shader() -> void:
	if audio_stream == null:
		return

	var audio_texture: ImageTexture = AudioStreamWAVLoader.audio_to_texture(audio_stream)
	var view_size: Vector2i = Vector2i(512, 512)

	var sample_count: float = audio_stream.data.size() / 2
	var sample_rate: float = audio_stream.mix_rate

	offset = 0.0
	duration = audio_stream.get_length()
	chunks = int(duration / width) + 1

	subviewport.size = view_size
	surface.size = view_size

	var shader_material: ShaderMaterial = ShaderMaterial.new()
	shader_material.shader = shader
	surface.material = shader_material

	surface.material.set_shader_parameter("offset", offset)
	surface.material.set_shader_parameter("width", 10.0)
	surface.material.set_shader_parameter("sample_rate", sample_rate)
	surface.material.set_shader_parameter("sample_count", sample_count)
	surface.material.set_shader_parameter("audio_texture", audio_texture)
	surface.material.set_shader_parameter("mode", 1)

	subviewport.add_child(surface)
	add_child(subviewport)

	subviewport.render_target_update_mode = SubViewport.UPDATE_ONCE

	RenderingServer.frame_pre_draw.connect(render_shader)


func render_shader() -> void:
	if rendered:
		return

	if chunk >= chunks:
		var textures: Texture2DArray = Texture2DArray.new()
		rendered = textures.create_from_images(images)
		material.set_shader_parameter("spectrogram_textures", textures)
		material.set_shader_parameter("textures_loaded", true)
		return

	surface.material.set_shader_parameter("offset", chunk * width)
	await RenderingServer.frame_post_draw
	var img: Image = subviewport.get_texture().get_image()
	images.append(img)
	chunk += 1
	subviewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func on_scrollbar_value_change(value: float) -> void:
	material.set_shader_parameter("offset", value)


func on_scrollbar_change() -> void:
	material.set_shader_parameter("page", %VisualizerScrollBar.page)
