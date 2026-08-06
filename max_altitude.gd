extends BoxContainer

var max_altitude_label: Label

@onready var altitude_info = get_tree().get_root().find_child("AltitudeInfo", true, false)
@onready var assembly_manager = get_tree().get_root().find_child("AssemblyManager", true, false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_altitude_label = Label.new()
	max_altitude_label.text = "Highest Altitude: 0m"
	add_child(max_altitude_label)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var max_altitude: float = 0
	if not assembly_manager or not assembly_manager.controller:
		return
	
	var engines = assembly_manager.controller.engines
	if engines.is_empty():
		return
	
	var elevation: float = engines[0].global_position.y
	if elevation > max_altitude:
		max_altitude = elevation
	max_altitude_label.text = "Highest Altitude: " + str(snappedf(max_altitude, 0.1)) + "m"
