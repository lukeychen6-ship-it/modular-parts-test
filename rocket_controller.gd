extends Node
class_name RocketController

@export var parts: Array[RigidBody3D] = []
@export var engines: Array[RigidBody3D] = []

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

# Create a strong rigid joint between two parts
func create_joint_between(part_a: RigidBody3D, part_b: RigidBody3D, bottom_port: Marker3D) -> void:
	var joint = Generic6DOFJoint3D.new()
	joint.name = "Joint_" + part_a.name + "_" + part_b.name
	add_child(joint)
	
	# Connect the two rigid bodies
	joint.node_a = part_a.get_path()
	joint.node_b = part_b.get_path()
	
	# Make the joint very stiff (like welded)
	for i in range(6):  # 0-2 = linear, 3-5 = angular
		joint.set("linear_limit_" + ["x","y","z"][i % 3] + "/enabled", true)
		joint.set("linear_limit_" + ["x","y","z"][i % 3] + "/upper", 0.0)
		joint.set("linear_limit_" + ["x","y","z"][i % 3] + "/lower", 0.0)
		
		joint.set("angular_limit_" + ["x","y","z"][i % 3] + "/enabled", true)
		joint.set("angular_limit_" + ["x","y","z"][i % 3] + "/upper", 0.0)
		joint.set("angular_limit_" + ["x","y","z"][i % 3] + "/lower", 0.0)
	
	# Position the joint at the connection point
	joint.global_transform = bottom_port.global_transform

func _ready() -> void:
	set_physics_process(true)

func _physics_process(_delta: float) -> void:
	if not is_launched:
		return
	
	var main_throttle = 0.0
	if Input.is_action_pressed("thrust"):
		main_throttle = 1.0
	
	for engine_body in engines:                    # renamed for clarity
		# Find the EngineComponent child and set throttle on it
		for child in engine_body.get_children():
			if child.has_method("apply_thrust"):
				child.throttle = main_throttle     # ← Set on the component
				child.apply_thrust()               # ← Call apply_thrust
				break

func launch_rocket() -> void:
	is_launched = true
	print("=== ROCKET LAUNCHED - Creating joints ===")
	
	for part in parts:
		if part is RigidBody3D:
			part.set_deferred("freeze", false)
			part.set_deferred("sleeping", false)
	
	await get_tree().physics_frame
	await get_tree().physics_frame  # Give physics two frames to wake up
	
	create_rigid_joints()
	print("Joints created - rocket should now be connected!")

# New function: Connect parts via ports
func create_rigid_joints() -> void:
	var connected_pairs = {}  # To avoid duplicate joints
	
	for part in parts:
		if not part.has_method("get_attachment_points"):
			continue
			
		for port in part.get_attachment_points():
			if not port:
				continue
				
			# Only connect BOTTOM ports to TOP ports of the part below
			if "bottom" in port.name.to_lower():
				var connected_part = find_connected_part_at_port(port)
				if connected_part and connected_part != part:
					create_joint_between(part, connected_part, port)
