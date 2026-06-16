extends Node3D
class_name BuildManager

@export var parts_palette: Array[PackedScene] = []

var selected_part_type: PackedScene = null
var ghost_part: RigidBody3D = null
var is_snapped:= false
var snapped_to_port: Marker3D = null
var occupied_ports: Array[Marker3D] = []
var snap_threshold := 4.0
var unsnap_threshold := 6.0

@onready var camera := get_viewport().get_camera_3d()
@onready var assembly_manager = get_tree().get_root().find_child("AssemblyManager", true, false)

func _ready() -> void:
	print("✅ BuildManager ready. Camera:", camera != null)

func _input(event: InputEvent) -> void:
	# Select parts with 1, 2, 3
	if event.is_action_pressed("select_1") and parts_palette.size() > 0:
		selected_part_type = parts_palette[0]
		print("✅ SELECTED: FuelTank")
		create_ghost()

	if event.is_action_pressed("select_2") and parts_palette.size() > 1:
		selected_part_type = parts_palette[1]
		print("✅ SELECTED: NoseCone")
		create_ghost()

	if event.is_action_pressed("select_3") and parts_palette.size() > 2:
		selected_part_type = parts_palette[2]
		print("✅ SELECTED: Engine")
		create_ghost()

	# Left-click to place the current ghost
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if ghost_part:
			place_part()

func create_ghost() -> void:
	is_snapped = false
	snapped_to_port = null
	if ghost_part:
		ghost_part.queue_free()
	
	if not selected_part_type or not camera:
		return

	ghost_part = selected_part_type.instantiate()
	if not ghost_part is RigidBody3D:
		print("❌ Error: Root of scene is not RigidBody3D")
		return

	# Set BEFORE add_child so part.gd's _ready() sees is_frozen = true
	ghost_part.is_frozen = true
	ghost_part.freeze = true
	ghost_part.collision_layer = 0  # Ghost won't be detected by anything
	ghost_part.collision_mask = 0   # Ghost won't detect anything either
	add_child(ghost_part)
	# No need to force-reset scales in a loop anymore

	make_ghost_transparent(ghost_part)
	ghost_part.global_position = Vector3(0, 8, 0)
	print("👻 Ghost created with size ", ghost_part.scale)

func make_ghost_transparent(part: Node) -> void:
	for mesh in part.find_children("*", "MeshInstance3D", true):
		if mesh is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color = Color(0.6, 0.9, 1.0, 0.4)
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mesh.material_override = mat

func _process(_delta: float) -> void:
	if not ghost_part or not camera:
		return

	ghost_part.scale = Vector3.ONE

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var to = from + dir * 1000.0

	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space.intersect_ray(query)

	if not result:
		return

	# Handle unsnap first, before any snap search
	if is_snapped:
		var mouse_dist = snapped_to_port.global_position.distance_to(result.position)
		if mouse_dist > unsnap_threshold:
			is_snapped = false
			snapped_to_port = null
			ghost_part.global_position = result.position + Vector3(0, 2.0, 0)
		# Whether we just unsnapped or are still snapped, return here.
		# The ghost stays locked until the mouse moves far enough.
		return

	# Get ghost's bottom port
	var ghost_bottom_port: Marker3D = null
	if ghost_part.has_method("get_attachment_points"):
		for port in ghost_part.get_attachment_points():
			if port and "bottom" in port.name.to_lower():
				ghost_bottom_port = port
				break
	if not ghost_bottom_port:
		ghost_part.global_position = result.position + Vector3(0, 2.0, 0)
		return
	# Search for closest available (unoccupied) top port
	var best_snap_distance := 9999.0
	var best_target_port: Marker3D = null

	for part in get_tree().get_nodes_in_group("rocket_parts"):
		if part == ghost_part or not part.has_method("get_attachment_points"):
			continue
		for port in part.get_attachment_points():
			if port and "top" in port.name.to_lower() and port not in occupied_ports:
				var distance = ghost_bottom_port.global_position.distance_to(port.global_position)
				if distance < best_snap_distance:
					best_snap_distance = distance
					best_target_port = port

	if best_target_port and best_snap_distance < snap_threshold:
		is_snapped = true
		snapped_to_port = best_target_port
		var origin_to_bottom = ghost_part.global_position - ghost_bottom_port.global_position
		ghost_part.global_position = best_target_port.global_position + origin_to_bottom
		ghost_part.global_rotation = best_target_port.global_transform.basis.get_euler()
	else:
		ghost_part.global_position = result.position + Vector3(0, 2.0, 0)
		
func place_part() -> void:
	if not ghost_part:
		return

	var new_part = selected_part_type.instantiate()
	new_part.freeze = true
	new_part.collision_layer = 0
	new_part.collision_mask = 0
	new_part.add_to_group("rocket_parts")

	# Add to AssemblyManager so RocketController can find it
	assembly_manager.add_child(new_part)
	new_part.global_transform = ghost_part.global_transform

	# Register with RocketController
	if assembly_manager.controller:
		assembly_manager.controller.parts.append(new_part)
		for child in new_part.get_children():
			if child.has_method("apply_thrust"):
				assembly_manager.controller.engines.append(new_part)
				print("Engine registered: ", new_part.name)
				break

	if snapped_to_port:
		occupied_ports.append(snapped_to_port)

	is_snapped = false
	snapped_to_port = null
	ghost_part.queue_free()
	ghost_part = null
	print("✅ Part placed!")
	assembly_manager.controller.parts.append(new_part)
	if new_part.has_method("get_attachment_points"):  # optional
		print("Added new part to controller")
