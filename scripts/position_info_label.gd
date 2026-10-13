extends Label

@onready var assembly_manager = get_tree().get_root().find_child("AssemblyManager", true, false)

# Called when the node enters the scene tree for the first time.
func _process(_delta: float) -> void:
	if not assembly_manager or not assembly_manager.controller:
		return
	
	var engines = assembly_manager.controller.engines
	if engines.is_empty():
		return
	
	var elevation: float = engines[0].global_position.y
	var x_position: float = engines[0].global_position.x
	var z_position: float = engines[0].global_position.z
	text = "Altitude: " + str(snappedf(elevation, 0.1)) + "m\n" + "Rocket position: (" + str(snappedf(x_position, 0.1)) + "," + str(snappedf(z_position, 0.1)) + ")"
