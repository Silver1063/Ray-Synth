extends ColorRect

var dragging: bool = false
func _gui_input(event):
	print(event.position.x)
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_click"):
			dragging = true
		if event.is_action_released("left_click"):
			dragging = false
	if event is InputEventMouseMotion and dragging:
		Ray.playhead_position += (event.relative.x / get_parent_area_size().x) * %VisualizerScrollBar.page
