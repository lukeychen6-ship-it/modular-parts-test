extends Node3D
class_name EngineComponent

@export var max_thrust: float = 2500.0
@export var max_gimbal: float = 100.0  # how strongly it steers
@export var throttle: float = 0.0
@onready var rocket_controller = get_tree().get_root().find_child("RocketController", true, false)

var steer_direction: Vector2 = Vector2.ZERO  # x = left/right, y = forward/back

@onready var body: RigidBody3D = get_parent()
func _process(_delta) -> void:
	if not rocket_controller:
		return
		
	if rocket_controller.is_launched:
		var total_mass: float = 0.0
		for part in rocket_controller.parts:
			total_mass += part.mass
		max_thrust = total_mass * 75
		max_gimbal = total_mass * 3


func apply_thrust() -> void:
	if throttle <= 0.0:
		return

	var thrust_force = max_thrust * throttle
	var force_vector = global_transform.basis.y * thrust_force
	body.apply_central_force(force_vector)

	# Apply steering as a lateral force offset from center
	if steer_direction.length() > 0.0:
		var gimbal_force = (global_transform.basis.x * steer_direction.x +
							global_transform.basis.z * steer_direction.y) * max_gimbal
		# Apply at the bottom of the rocket to create rotation
		var nozzle_pos = global_transform.basis.y * -1.0
		body.apply_force(gimbal_force, nozzle_pos)
