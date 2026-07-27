extends BoxContainer


 #Called when the node enters the scene tree for the first time.
func _ready():
	var fuel_tank_button = Button.new()
	var nose_cone_button = Button.new()
	var engine_button = Button.new()
	fuel_tank_button.text = "Fuel Tank"
	nose_cone_button.text = "Nose Cone"
	engine_button.text = "Engine"
	fuel_tank_button.pressed.connect(_button_pressed)
	add_child(fuel_tank_button)
	add_child(nose_cone_button)
	add_child(engine_button)

func _button_pressed():
	print("Hello world!")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
