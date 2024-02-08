extends Node

var root_ui: Control

var playhead_position: float = 0.0:
	get:
		return playhead_position
	set(value):
		playhead_position_changed.emit()
		playhead_position = value

signal play(from: float)
signal pause
signal stop
signal record
signal playhead_position_changed()

var project: Dictionary = {}


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass


### Transport Here Controls ###
func on_play_pressed():
	play.emit(playhead_position)

func on_pause_pressed():
	pause.emit()

func on_stop_pressed():
	stop.emit()

func on_record_pressed():
	record.emit()
