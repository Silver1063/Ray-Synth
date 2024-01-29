class_name TransportControls
extends PanelContainer


func _ready():
	$MarginContainer/HBoxContainer/PlayButton.pressed.connect(Ray.on_play_pressed)
	$MarginContainer/HBoxContainer/PauseButton.pressed.connect(Ray.on_pause_pressed)
	$MarginContainer/HBoxContainer/StopButton.pressed.connect(Ray.on_stop_pressed)
	$MarginContainer/HBoxContainer/RecordButton.pressed.connect(Ray.on_record_pressed)
