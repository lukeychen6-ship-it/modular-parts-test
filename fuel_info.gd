extends BoxContainer

var fuel_label: Label
var current_fuel: float = 0.0
var fuel_initialized: bool = false
var fuel_consumption_rate: float = 10.0  # kg per second

@onready var build_manager = get_tree().get_root().find_child("BuildManager", true, false)
@onready var rocket_controller = get_tree().get_root().find_child("RocketController", true, false)

func _ready() -> void:
	fuel_label = Label.new()
	fuel_label.text = "Fuel: 0kg"
	add_child(fuel_label)

func _process(delta: float) -> void:
	if not build_manager or not rocket_controller:
		return

	# Set starting fuel once when launched
	if rocket_controller.is_launched and not fuel_initialized:
		current_fuel = build_manager.fuel_tank_count * 100.0
		fuel_initialized = true

	# Consume fuel while thrusting
	if rocket_controller.is_launched and Input.is_action_pressed("thrust"):
		current_fuel = max(0.0, current_fuel - fuel_consumption_rate * delta)

	# Before launch, show full fuel amount
	if not rocket_controller.is_launched:
		current_fuel = build_manager.fuel_tank_count * 100.0

	fuel_label.text = "Fuel: " + str(snappedf(current_fuel, 0.1)) + "kg"
