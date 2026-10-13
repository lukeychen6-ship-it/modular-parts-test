extends Node
class_name RocketController

@export var parts: Array[RigidBody3D] = []
@export var engines: Array[RigidBody3D] = []
@onready var spring_arm: SpringArm3D = get_parent().get_node("SpringArm3D")
@onready var fuel_info_label = get_tree().get_root().find_child("FuelInfoLabel", true, false)
@onready var sound_manager = get_tree().get_root().find_child("SoundManager", true, false)

var was_thrusting := false
var is_launched: bool = false

# Find if there's another part whose top port is very close to this bottom port
func find_connected_part_at_port(bottom_port: Marker3D) -> RigidBody3D:
	var best_part: RigidBody3D = null
	var best_dist := 9999.0
	
	for other in parts:
		if other == bottom_port.get_parent():
			continue
		if not other.has_method("get_attachment_points"):
			continue
			
		for other_port in other.get_attachment_points():
			if other_port and "top" in other_port.name.to_lower():
				var dist = bottom_port.global_position.distance_to(other_port.global_position)
				if dist < best_dist and dist < 0.5:  # very close = connected
					best_dist = dist
					best_part = other
	
	return best_part

func find_connected_part_at_side_port(side_port: Marker3D) -> RigidBody3D:
	var best_part: RigidBody3D = null
	var best_dist := 9999.0
	
	for other in parts:
		if other == side_port.get_parent():
			continue
		if not other.has_method("get_side_attachment_points"):
			continue
		
		for other_port in other.get_side_attachment_points():
			if not other_port:
				continue
			# Only connect opposite sides: left↔right
			var is_opposite = ("left" in side_port.name.to_lower() and "right" in other_port.name.to_lower()) or \
							  ("right" in side_port.name.to_lower() and "left" in other_port.name.to_lower())
			if not is_opposite:
				continue
			var dist = side_port.global_position.distance_to(other_port.global_position)
			if dist < best_dist and dist < 0.5:
				best_dist = dist
				best_part = other
	
	return best_part
# Create a strong rigid joint between two parts
func create_joint_between(part_a: RigidBody3D, part_b: RigidBody3D, bottom_port: Marker3D) -> void:
	var joint = Generic6DOFJoint3D.new()
	joint.name = "Joint_" + part_a.name + "_" + part_b.name
	
	# Add to part_a so it exists in 3D space
	part_a.add_child(joint)
	
	joint.node_a = part_a.get_path()
	joint.node_b = part_b.get_path()
	
	for i in range(3):
		joint.set("linear_limit_" + ["x","y","z"][i] + "/enabled", true)
		joint.set("linear_limit_" + ["x","y","z"][i] + "/upper", 0.0)
		joint.set("linear_limit_" + ["x","y","z"][i] + "/lower", 0.0)
		
		joint.set("angular_limit_" + ["x","y","z"][i] + "/enabled", true)
		joint.set("angular_limit_" + ["x","y","z"][i] + "/upper", 0.0)
		joint.set("angular_limit_" + ["x","y","z"][i] + "/lower", 0.0)
	
	joint.global_transform = bottom_port.global_transform

func create_launch_stats() -> void:
	# used to create menu for stats (ie altitude, weight, etc)
	print("placeholder")

func _ready() -> void:
	set_physics_process(true)

func _physics_process(_delta: float) -> void:
	if not is_launched:
		return

	# Follow rocket with camera
	if not parts.is_empty():
		var engine_center = Vector3.ZERO
		for engine in engines:
			engine_center = engine.global_position
		spring_arm.global_position = engine_center + Vector3(0, 2.5, 0)

	var main_throttle = 0

	if Input.is_action_pressed("thrust") and fuel_info_label.current_fuel > 0:
		main_throttle = 1.0
	if main_throttle > 0.0 and not was_thrusting:
		sound_manager.play_thrust_start()
		was_thrusting = true
	elif main_throttle == 0.0 and was_thrusting:
		sound_manager.play_thrust_stop()
		was_thrusting = false

	# Read steering input
	var steer = Vector2.ZERO
	if Input.is_action_pressed("steer_right"):
		steer.x = -1.0 
	if Input.is_action_pressed("steer_left"):
		steer.x = 1.0
	if Input.is_action_pressed("steer_back"):
		steer.y = -1.0
	if Input.is_action_pressed("steer_forward"):
		steer.y = 1.0

	var engine_count = engines.size()

	for engine_body in engines:
		for child in engine_body.get_children():
			if child.has_method("apply_thrust"):
				child.throttle = main_throttle
				child.steer_direction = steer
				child.engine_count = engine_count  # pass count directly
				child.apply_thrust()
				

var has_launched := false  # separate from is_launched to track post-launch state

func launch_rocket() -> void:
	is_launched = true
	has_launched = true
	print("Parts count: ", parts.size())
	print("Engines count: ", engines.size())
	print("=== ROCKET LAUNCHED - Creating joints ===")
	
	for part in parts:
		if part is RigidBody3D:
			part.collision_layer = 1  # restore to default layer
			part.collision_mask = 1   # restore to default mask
			part.set_deferred("freeze", false)
			part.set_deferred("sleeping", false)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	create_rigid_joints()
	print("Joints created - rocket should now be connected!")
	await get_tree().physics_frame
	for part in parts:
		if not part.body_entered.is_connected(_on_part_hit_ground):
			part.contact_monitor = true
			part.max_contacts_reported = 4
			part.body_entered.connect(_on_part_hit_ground.bind(part))

func _on_part_hit_ground(body: Node, hitting_part: RigidBody3D) -> void:
	# Only break apart if we've actually launched and are coming back down
	if not has_launched or not is_launched:
		return
	
	# Check it's the ground we hit, not another rocket part
	if body.is_in_group("rocket_parts"):
		return
	
	# Only trigger if moving downward fast enough (ignore gentle landings)
	if hitting_part.linear_velocity.y > -5.0:
		return
	
	break_apart()

func break_apart() -> void:
	if not is_launched:
		return
	
	is_launched = false
	sound_manager.play_crash()
	print("💥 Rocket broke apart!")
	
	# Remove all joints
	for part in parts:
		for child in part.get_children():
			if child is Joint3D:
				child.queue_free()
	
	# Unfreeze all parts so they fly apart
	for part in parts:
		part.collision_layer = 1
		part.collision_mask = 1
		part.set_deferred("freeze", false)

# New function: Connect parts via ports
func create_rigid_joints() -> void:
	var connected_pairs = {}
	
	for part in parts:
		if not part.has_method("get_attachment_points"):
			continue
		
		# --- Top/bottom joints (existing logic) ---
		for port in part.get_attachment_points():
			if not port:
				continue
			if "bottom" in port.name.to_lower():
				var connected_part = find_connected_part_at_port(port)
				if connected_part and connected_part != part:
					create_joint_between(part, connected_part, port)
		
		# --- Side joints (new logic) ---
		if not part.has_method("get_side_attachment_points"):
			continue
		
		for side_port in part.get_side_attachment_points():
			if not side_port:
				continue
			
			# Only process left ports to avoid creating duplicate joints
			if not "left" in side_port.name.to_lower():
				continue
			
			var connected_part = find_connected_part_at_side_port(side_port)
			if connected_part and connected_part != part:
				var pair_key = str(min(part.get_instance_id(), connected_part.get_instance_id())) + \
							   "_" + str(max(part.get_instance_id(), connected_part.get_instance_id()))
				if pair_key not in connected_pairs:
					connected_pairs[pair_key] = true
					create_joint_between(part, connected_part, side_port)
