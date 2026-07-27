extends BoxContainer
@export var engines: Array[RigidBody3D]

var elevation_label = Label.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for engine_body in engines:           
		for child in engine_body.get_children():
			if child.has_method("apply_thrust"):
				var elevation: float = child.global_position.y
				elevation_label.text = elevation
				
