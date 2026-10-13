# inspiration_menu.gd
extends CanvasLayer

const INSPIRATIONS_PATH = "res://inspirations/"

var panel: PanelContainer
var content_vbox: VBoxContainer

@onready var build_manager = get_tree().get_root().find_child("BuildManager", true, false)
@onready var assembly_manager = get_tree().get_root().find_child("AssemblyManager", true, false)

func _ready() -> void:
	panel = PanelContainer.new()
	panel.visible = false

	var vbox = VBoxContainer.new()

	var title = Label.new()
	title.text = "Inspiration Rockets"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var description = Label.new()
	description.text = "Load a pre-built rocket as a starting point"
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(description)

	# Scrollable area for rocket list
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(300, 200)
	content_vbox = VBoxContainer.new()
	scroll.add_child(content_vbox)
	vbox.add_child(scroll)

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
	panel.offset_left = -175
	panel.offset_right = 175
	panel.offset_top = -200
	panel.offset_bottom = 200

func show_menu() -> void:
	panel.visible = true
	refresh_list()

func hide_menu() -> void:
	panel.visible = false

func refresh_list() -> void:
	# Clear existing buttons
	for child in content_vbox.get_children():
		child.queue_free()

	# Scan inspirations folder
	var dir = DirAccess.open(INSPIRATIONS_PATH)
	if not dir:
		var empty_label = Label.new()
		empty_label.text = "No inspiration rockets found"
		content_vbox.add_child(empty_label)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".cfg"):
			var config = ConfigFile.new()
			config.load(INSPIRATIONS_PATH + file_name)

			var name = config.get_value("meta", "name", file_name)
			var description = config.get_value("meta", "description", "")
			var part_count = config.get_value("meta", "part_count", 0)

			# Create a card for each rocket
			var card = PanelContainer.new()
			var card_vbox = VBoxContainer.new()

			var name_label = Label.new()
			name_label.text = name
			card_vbox.add_child(name_label)

			var desc_label = Label.new()
			desc_label.text = description
			desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			card_vbox.add_child(desc_label)

			var parts_label = Label.new()
			parts_label.text = str(part_count) + " parts"
			card_vbox.add_child(parts_label)

			var load_button = Button.new()
			load_button.text = "Load " + name
			load_button.pressed.connect(_on_load_pressed.bind(INSPIRATIONS_PATH + file_name))
			card_vbox.add_child(load_button)

			card.add_child(card_vbox)
			content_vbox.add_child(card)

		file_name = dir.get_next()

func _on_load_pressed(path: String) -> void:
	load_inspiration(path)
	hide_menu()

func load_inspiration(path: String) -> void:
	if not FileAccess.file_exists(path):
		print("Inspiration file not found: ", path)
		return

	# Clear existing build
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

		for child in new_part.get_children():
			if child.has_method("apply_thrust"):
				assembly_manager.controller.engines.append(new_part)
				build_manager.engine_count += 1
				break

		if type_index == 0:
			build_manager.fuel_tank_count += 1

	print("✅ Inspiration loaded: ", config.get_value("meta", "name", path))
	
