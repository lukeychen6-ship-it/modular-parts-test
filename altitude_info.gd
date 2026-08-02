extends BoxContainer

var elevation_label: Label
var position_label: Label

@onready var assembly_manager = get_tree().get_root().find_child("AssemblyManager", true, false)

func _ready() -> void:
	elevation_label = Label.new()
	position_label = Label.new()
	elevation_label.text = "Altitude: 0m, "
	position_label.text = "Rocket position: (0,0)"
	add_child(elevation_label)
	add_child(position_label)

func _process(_delta: float) -> void:
	if not assembly_manager or not assembly_manager.controller:
		return
	
	var engines = assembly_manager.controller.engines
	if engines.is_empty():
		return
	
	var elevation: float = engines[0].global_position.y
	var x_position: float = engines[0].global_position.x
	var z_position: float = engines[0].global_position.z
	elevation_label.text = "Altitude: " + str(snappedf(elevation, 0.1)) + "m, "
	position_label.text = "Rocket position: (" + str(snappedf(x_position, 0.1)) + "," + str(snappedf(z_position, 0.1)) + ")"
