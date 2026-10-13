# save_load_manager.gd
extends CanvasLayer

const SAVE_PATH = "user://rocket_saves/"
const MAX_SLOTS = 5

var panel: PanelContainer
var slot_buttons: Array[Button] = []
var is_saving: bool = false  # true = save mode, false = load mode

@onready var build_manager = get_tree().get_root().find_child("BuildManager", true, false)
@onready var assembly_manager = get_tree().get_root().find_child("AssemblyManager", true, false)

func _ready() -> void:
	# Make sure save directory exists
	DirAccess.make_dir_absolute(SAVE_PATH)
	
	# Build the UI
	panel = PanelContainer.new()
	panel.visible = false
	
	var vbox = VBoxContainer.new()
	
	var title = Label.new()
	title.text = "Save / Load Rocket"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Create a button for each save slot
	for i in range(MAX_SLOTS):
		var slot_button = Button.new()
		slot_button.pressed.connect(_on_slot_pressed.bind(i))
		slot_buttons.append(slot_button)
		vbox.add_child(slot_button)
	
	# Close button
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(hide_menu)
	vbox.add_child(close_button)
	
	panel.add_child(vbox)
	add_child(panel)
	
	call_deferred("position_panel")

func position_panel() -> void:
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -150
	panel.offset_right = 150
	panel.offset_top = -175
	panel.offset_bottom = 175

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_save_load"):
		if panel.visible:
			hide_menu()
		else:
			show_menu(false)  # default to load mode

func show_menu(saving: bool) -> void:
	is_saving = saving
	panel.visible = true
	refresh_slots()

func hide_menu() -> void:
	panel.visible = false

func refresh_slots() -> void:
	for i in range(MAX_SLOTS):
		var path = SAVE_PATH + "slot_" + str(i) + ".cfg"
		if FileAccess.file_exists(path):
			var config = ConfigFile.new()
			config.load(path)
			var part_count = config.get_value("meta", "part_count", 0)
			var save_name = config.get_value("meta", "name", "Slot " + str(i + 1))
			slot_buttons[i].text = save_name + " (" + str(part_count) + " parts)"
		else:
			slot_buttons[i].text = "Slot " + str(i + 1) + " - Empty"

func _on_slot_pressed(slot_index: int) -> void:
	if is_saving:
		save_rocket(slot_index)
	else:
		load_rocket(slot_index)
	hide_menu()

func save_rocket(slot_index: int) -> void:
	var config = ConfigFile.new()
	var parts = get_tree().get_nodes_in_group("rocket_parts")
	
	config.set_value("meta", "part_count", parts.size())
	config.set_value("meta", "name", "Slot " + str(slot_index + 1))
	
	for i in range(parts.size()):
		var part = parts[i]
		# Save part type by matching against parts_palette
		var type_index = -1
		for j in range(build_manager.parts_palette.size()):
			if part.get_scene_file_path() == build_manager.parts_palette[j].resource_path:
				type_index = j
				break
		
		config.set_value("part_" + str(i), "type_index", type_index)
		config.set_value("part_" + str(i), "position", part.global_position)
		config.set_value("part_" + str(i), "rotation", part.global_rotation)
	
	config.save(SAVE_PATH + "slot_" + str(slot_index) + ".cfg")
	print("✅ Rocket saved to slot ", slot_index)

func load_rocket(slot_index: int) -> void:
	var path = SAVE_PATH + "slot_" + str(slot_index) + ".cfg"
	if not FileAccess.file_exists(path):
		print("No save in slot ", slot_index)
		return
	
	# Clear existing placed parts
	for part in get_tree().get_nodes_in_group("rocket_parts"):
		part.queue_free()
	assembly_manager.controller.parts.clear()
	assembly_manager.controller.engines.clear()
	build_manager.occupied_ports.clear()
	build_manager.fuel_tank_count = 0
	build_manager.engine_count = 0
	
	var config = ConfigFile.new()
	config.load(path)
	var part_count = config.get_value("meta", "part_count", 0)
	
	for i in range(part_count):
		var type_index = config.get_value("part_" + str(i), "type_index", -1)
		var position = config.get_value("part_" + str(i), "position", Vector3.ZERO)
		var rotation = config.get_value("part_" + str(i), "rotation", Vector3.ZERO)
		
		if type_index < 0 or type_index >= build_manager.parts_palette.size():
			continue
		
		var new_part = build_manager.parts_palette[type_index].instantiate()
		new_part.freeze = true
		new_part.collision_layer = 0
		new_part.collision_mask = 0
		new_part.add_to_group("rocket_parts")
		
		assembly_manager.add_child(new_part)
		new_part.set_deferred("global_position", position)
		new_part.set_deferred("global_rotation", rotation)
		
		assembly_manager.controller.parts.append(new_part)
		
		# Re-register engines and count parts
		for child in new_part.get_children():
			if child.has_method("apply_thrust"):
				assembly_manager.controller.engines.append(new_part)
				build_manager.engine_count += 1
				break
		
		if type_index == 0:  # fuel tank
			build_manager.fuel_tank_count += 1
	
	print("✅ Rocket loaded from slot ", slot_index)
