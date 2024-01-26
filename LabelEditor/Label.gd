extends Control


@onready var start_bar: Control = $StartBar
@onready var end_bar: Control = $EndBar

var dragging: bool = false
var start_bar_selected: bool = false
var end_bar_selected: bool = false

func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_click"):
			dragging = true
			start_bar_selected = start_bar.get_global_rect().has_point(event.position)
			end_bar_selected = end_bar.get_global_rect().has_point(event.position)
		if event.is_action_released("left_click"):
			dragging = false
			start_bar_selected = false
			end_bar_selected = false
		if event.is_action_released("right_click"):
			queue_free()
	if event is InputEventMouseMotion:
		if dragging and start_bar_selected:
			position.x += event.relative.x
			size.x -= event.relative.x
		if dragging and end_bar_selected:
			size.x += event.relative.x
		


