extends Button
@onready var inspiration_menu = get_tree().get_root().find_child("InspirationMenu", true, false)

# Called when the node enters the scene tree for the first time.
func _pressed() -> void:
	inspiration_menu.show_menu()
