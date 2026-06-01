extends Node3D

@onready var controller: RocketController = $RocketController

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
	# After adding new_part
	controller.parts.append(new_part)
	if new_part.has_method("get_attachment_points"):  # optional
		print("Added new part to controller")
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("launch"):
		print("Launch key pressed!")
		controller.launch_rocket()
	
