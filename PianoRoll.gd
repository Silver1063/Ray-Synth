@tool
class_name PianoRoll
extends Control

@export var playhead_position: float = 0.0
var key_pattern: Array[String] = ["C", "x", "D", "x", "E", "F", "x", "G", "x", "A", "x", "B"]

var octave_count: int = 10

var lower_limit: int = 0
var upper_limit: int = 24

var NUMBER_OF_KEYS: int = upper_limit - lower_limit + 1

var time_signature_numerator: int = 4
var time_signature_denominator: int = 4

var measures = 16

@export var view_position: Vector2 = Vector2(0, 0)
@export var view_scale: Vector2 = Vector2(1.0, 1.0)

@export var BLACK: Color = Color(0.15, 0.15, 0.15, 1)
@export var WHITE: Color = Color(0.25, 0.25, 0.25, 1)

@onready var vscrollbar = $VScrollBar
@onready var hscrollbar = $HScrollBar

#@onready var font = load("res://fonts/Poppins-Black.ttf")


func _ready() -> void:
	vscrollbar.min_value = lower_limit
	vscrollbar.max_value = upper_limit
	vscrollbar.page = 16
	vscrollbar.step = 0
	vscrollbar.value = 0
	vscrollbar.value_changed.connect(vscrollbar_scrolled)

	hscrollbar.min_value = 0
	hscrollbar.max_value = 16
	hscrollbar.page = 4
	hscrollbar.step = 0
	hscrollbar.value = view_position.x
	hscrollbar.value_changed.connect(hscrollbar_scrolled)


func vscrollbar_scrolled(value: float) -> void:
	view_position.y = vscrollbar.value / vscrollbar.max_value


func hscrollbar_scrolled(value: float) -> void:
	view_position.x = hscrollbar.value


func _process(delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var visible_row_count: int = int(16 * view_scale.y)
	var row_height: float = 900 / visible_row_count
	
	#draw the piano roll
	for i in range(lower_limit, upper_limit + 1):
		var row_position = Vector2(
			0, (NUMBER_OF_KEYS - (i + 1)) * row_height - row_height * NUMBER_OF_KEYS * view_position.y
			#* ((NUMBER_OF_KEYS - i - 1) - (NUMBER_OF_KEYS * view_position.y))
		)
		var row_size = Vector2(size.x, row_height)
		
		# if row_position.y > size.y or row_position.y < -row_height:
		# 	continue

		var row: Rect2 = Rect2(row_position, row_size)
		var note_index: int = i % 12
		var key: String = key_pattern[note_index]
		var color: Color = BLACK if key_pattern[note_index] == "x" else WHITE

		draw_rect(row, color, true, -1)
		var c = 0.12
		#print(key)
		var octave: String = str(i / 12)

		if key == "C":
			draw_string(
				get_theme_default_font(),
				row_position + Vector2(10, 40) * view_scale.y,
				key + octave,
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				int(24 * view_scale.y),
				Color(c, c, c, 1.0)
			)
		if key == "B" or key == "E":
			draw_line(
				row_position, row_position + Vector2(row_size.x, 0), Color(c, c, c, 1.0), 2.0, false
			)
	
	#draw the measures
	var measure_width = 400
	for i in range(measures):
		var bar_position: Vector2 = Vector2(i * measure_width - view_position.x * 100, 0)

		if bar_position.x < 0 or bar_position.x > size.x:
			continue

		var c = 0.5

		draw_line(bar_position, bar_position + Vector2(0, size.y), Color(c, c, c, 1.0), 2.0, false)
		
		draw_string(
			get_theme_default_font(),
			bar_position + Vector2(10, 40) * view_scale.y,
			str(i),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			int(24 * view_scale.y),
			Color(c, c, c, 1.0)
		)

	# draw play head
	var playhead_color: Color = Color.DARK_RED
	var points = PackedVector2Array(
		[
			Vector2(playhead_position - 10, 0),
			Vector2(playhead_position + 10, 0),
			Vector2(playhead_position, 20),
		]
	)
	var colors = PackedColorArray([playhead_color])

	draw_line(
		Vector2(playhead_position, 0),
		Vector2(playhead_position, size.y),
		playhead_color,
		2.0,
		false,
	)
	draw_polygon(points, colors)


var shift: bool = false
var ctrl: bool = false

var panning: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT and not event.is_echo():
			shift = not shift
		if event.keycode == KEY_CTRL and not event.is_echo():
			ctrl = not ctrl
	if event is InputEventMouseMotion and panning:
			#lerp(vscrollbar.value, vscrollbar.value - event.relative.y / 150, 0.5)
			vscrollbar.value += -1 * event.relative.y / 150
			hscrollbar.value += -1 * event.relative.x / 150
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE and not event.is_echo():
			panning = not panning
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if not shift and not ctrl:
				vscrollbar.value -= 0.5
			if shift and not ctrl:
				hscrollbar.value -= 1
			if not shift and ctrl:
				view_scale.y -= 0.1
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if not shift and not ctrl:
				vscrollbar.value += 0.5
			if shift and not ctrl:
				hscrollbar.value += 1
			if not shift and ctrl:
				view_scale.y += 0.1

	view_position.x = clamp(view_position.x, 0, measures)
	view_position.y = clamp(view_position.y, 0, 1)

	view_scale.x = clamp(view_scale.x, 0.1, 4.0)
	view_scale.y = clamp(view_scale.y, 0.1, 4.0)

	#vscrollbar.value = view_position.y * vscrollbar.max_value
	#hscrollbar.value = view_position.x * hscrollbar.max_value
