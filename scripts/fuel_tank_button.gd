extends Button
@onready var build_manager = get_tree().get_root().find_child("BuildManager", true, false)

# Called when the node enters the scene tree for the first time.
func _pressed() -> void:
	if build_manager and build_manager.parts_palette.size() > 0:
		build_manager.selected_part_type = build_manager.parts_palette[0]
		build_manager.create_ghost()
