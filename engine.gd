extends Node3D
class_name EngineComponent

@export var max_thrust: float = 4000.0
@export var throttle: float = 0.0

@onready var body: RigidBody3D = get_parent()  # The actual RigidBody part

func apply_thrust() -> void:
	if throttle <= 0.0:
		return
	
	var thrust_force = max_thrust * throttle
	var force_vector = global_transform.basis.y * thrust_force
	var nozzle_offset = global_transform.basis.y * -0.5   # tweak as needed
	
	body.apply_central_force(force_vector)
	# or body.apply_central_force(force_vector) for simpler testing
	if Engine.get_frames_drawn() % 60 == 0:
		print("Thrust applied: ", thrust_force)
