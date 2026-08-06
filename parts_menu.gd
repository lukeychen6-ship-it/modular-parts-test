extends BoxContainer

@onready var build_manager = get_tree().get_root().find_child("BuildManager", true, false)

func _ready() -> void:
	var fuel_tank_button = Button.new()
	var nose_cone_button = Button.new()
	var engine_button = Button.new()
	
	fuel_tank_button.text = "Fuel Tank (1)"
	nose_cone_button.text = "Nose Cone (2)"
	engine_button.text = "Engine (3)"
	
	fuel_tank_button.pressed.connect(_on_fuel_tank_pressed)
	nose_cone_button.pressed.connect(_on_nose_cone_pressed)
	engine_button.pressed.connect(_on_engine_pressed)
	
	add_child(fuel_tank_button)
	add_child(nose_cone_button)
	add_child(engine_button)

func _on_fuel_tank_pressed() -> void:
	if build_manager and build_manager.parts_palette.size() > 0:
		build_manager.selected_part_type = build_manager.parts_palette[0]
		build_manager.create_ghost()

func _on_nose_cone_pressed() -> void:
	if build_manager and build_manager.parts_palette.size() > 1:
		build_manager.selected_part_type = build_manager.parts_palette[1]
		build_manager.create_ghost()

func _on_engine_pressed() -> void:
	if build_manager and build_manager.parts_palette.size() > 2:
		if build_manager.engine_count < 1:
			build_manager.selected_part_type = build_manager.parts_palette[2]
			build_manager.create_ghost()
		else:
			print("You can only have one engine")
