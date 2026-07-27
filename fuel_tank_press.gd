extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	var button = Button.new()
	button.text = "Test"
	button.pressed.connect(_button_pressed)
	add_child(button)

func _button_pressed():
	print("Hello world!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
