extends Node3D

@onready var controller: RocketController = $RocketController
@export var engines: Array[RigidBody3D] = []

func _ready() -> void:
	# Clear safely
	if controller:
		controller.parts.clear()
		if "engines" in controller:   # safe property check
			controller.engines.clear()
	
	var all_rigidbodies = find_children("*", "RigidBody3D", true, false)
	
	for rb in all_rigidbodies:
		controller.parts.append(rb)
		
		for child in rb.get_children():
			if child.has_method("apply_thrust"):
				controller.engines.append(rb)
				print("Engine detected on part: ", rb.name)
				break
	for part in controller.parts:
		part.add_to_group("rocket_parts")
func _process(delta: float) -> void:
	for engine_body in engines:                    # renamed for clarity
		# Find the EngineComponent child and set throttle on it
		for child in engine_body.get_children():
			if child.has_method("apply_thrust"):
				var elevation: float = child.global_position.y
				print("Engine elevation: ", elevation)
				
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("launch"):
		print("Launch key pressed!")
		controller.launch_rocket()
	
