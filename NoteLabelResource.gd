extends Resource

@export var phoneme: String
@export var lyric: String
@export var note_break: Array[float]

func _init():
	phoneme = "sil"
	lyric = ""
	note_break = []