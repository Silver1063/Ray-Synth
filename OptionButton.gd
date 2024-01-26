extends OptionButton


func _ready():
	item_selected.connect(change_editor)
	change_editor(selected)
	


func change_editor(index: int):
	var editor: Node
	match get_item_text(index):
		"Song Editor":
			editor = load("res://Song Editor/SongEditor.tscn").instantiate()
		"Talk Editor":
			editor = Node.new()
		"Label Editor":
			editor = load("res://LabelEditor/LabelEditor.tscn").instantiate()
		_:
			editor = Node.new()
	var children: Array[Node] = %MainArea.get_children()
	print(children)
	for child in children:
		%MainArea.remove_child(child)
	%MainArea.add_child(editor)
