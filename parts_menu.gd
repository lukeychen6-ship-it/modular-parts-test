extends BoxContainer

@onready var build_manager = get_tree().get_root().find_child("BuildManager", true, false)
@onready var save_load_manager = get_tree().get_root().find_child("SaveLoadManager", true, false)
@onready var inspiration_menu = get_tree().get_root().find_child("InspirationMenu", true, false)


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

	var save_button = Button.new()
	var load_button = Button.new()

	save_button.text = "Save Rocket"
	load_button.text = "Load Rocket"

	save_button.pressed.connect(func(): save_load_manager.show_menu(true))
	load_button.pressed.connect(func(): save_load_manager.show_menu(false))

	add_child(save_button)
	add_child(load_button)
	
	var inspiration_button = Button.new()
	
	inspiration_button.text = "Ideas"
	
	inspiration_button.pressed.connect(func(): inspiration_menu.show_menu())

	add_child(inspiration_button)

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
		build_manager.selected_part_type = build_manager.parts_palette[2]
		build_manager.create_ghost()
