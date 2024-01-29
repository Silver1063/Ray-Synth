extends OptionButton


func _ready():
	item_selected.connect(Ray.change_editor)
	



