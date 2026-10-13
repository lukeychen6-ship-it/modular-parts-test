extends Label
@export var max_altitude: float = 0.0
@export var all_time_max_altitude: float = 0.0

const SAVE_PATH = "user://save_data.cfg"
var config = ConfigFile.new()

@onready var assembly_manager = get_tree().get_root().find_child("AssemblyManager", true, false)

func _ready() -> void:
	load_max_altitude()

func _process(_delta: float) -> void:
	if not assembly_manager or not assembly_manager.controller:
		return
	
	var engines = assembly_manager.controller.engines
	if engines.is_empty():
		return
	
	var elevation: float = engines[0].global_position.y
	if elevation > max_altitude:
		max_altitude = elevation
	
	# Check if current run beat the all time record
	if max_altitude > all_time_max_altitude:
		all_time_max_altitude = max_altitude
		save_max_altitude()
	
	text = "Highest Altitude: " + str(snappedf(max_altitude, 0.1)) + "m\nRecord: " + str(snappedf(all_time_max_altitude, 0.1)) + "m"

func save_max_altitude() -> void:
	config.set_value("stats", "max_altitude", all_time_max_altitude)
	config.save(SAVE_PATH)
	print("Saved record altitude: ", all_time_max_altitude)

func load_max_altitude() -> void:
	var err = config.load(SAVE_PATH)
	if err == OK:
		all_time_max_altitude = config.get_value("stats", "max_altitude", 0.0)
		print("Loaded record altitude: ", all_time_max_altitude)
	else:
		print("No save file found, starting fresh")

func reset_record() -> void:
	all_time_max_altitude = 0.0
	save_max_altitude()
