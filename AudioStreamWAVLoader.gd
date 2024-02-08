class_name AudioStreamWAVLoader
extends Node


static func load_from_path(path: String) -> AudioStreamWAV:
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	var content: Dictionary = {}
	
	var offset: int = 0
	while offset >= 0:
		var chunk: String = bytes.slice(offset, offset + 4).get_string_from_ascii()
		var chunk_size: int = bytes.decode_u16(offset + 4)
		if offset == 0 and not chunk == "RIFF":
			break
		if chunk == "RIFF":
			offset = 12
			continue
		if chunk == "fmt ":
			content["num_channels"] = bytes.decode_u16(offset + 10)
			content["sample_rate"] = bytes.decode_u16(offset + 12)
			content["bits_per_sample"] = bytes.decode_u16(offset + 22)
		if chunk == "data":
			content["data"] = bytes.slice(offset + 8)
			break
		offset += 8 + chunk_size
	
	print(content["bits_per_sample"], "\n", content["sample_rate"], "\n", content["num_channels"])
	
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.data = content["data"]
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = content["sample_rate"]
	wav.stereo = bool(content["num_channels"] - 1)
	
	return wav

static func audio_to_texture(audio: AudioStreamWAV) -> ImageTexture:
	var byte_data: PackedByteArray = audio.data
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
	
	var audio_texture: ImageTexture = ImageTexture.create_from_image(img)
	return audio_texture

