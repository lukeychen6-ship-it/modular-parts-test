extends BoxContainer

var fuel_label: Label

@onready var build_manager = get_tree().get_root().find_child("BuildManager", true, false)
@onready var rocket_controller = get_tree().get_root().find_child("RocketController", true, false)

func _ready() -> void:
	fuel_label = Label.new()
	fuel_label.text = "Fuel: 0kg"
	add_child(fuel_label)

func _process(delta: float) -> void:
	if not build_manager:
		return
	var fuel_mass: float = build_manager.fuel_tank_count * 100.0
	if rocket_controller.is_launched:
		var simulation_fuel: float = fuel_mass
		if Input.is_action_pressed("thrust"):
			simulation_fuel -= 1
		fuel_label.text = "Fuel: " + str(snappedf(simulation_fuel, 0.1)) + "kg"
