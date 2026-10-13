extends Button
@onready var max_altitude_label = get_tree().get_root().find_child("MaxAltitudeLabel", true, false)

# Called when the node enters the scene tree for the first time.
func _pressed() -> void:
	max_altitude_label.reset_record()
