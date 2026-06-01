extends RigidBody3D
class_name RocketPart

@export var is_frozen: bool = true

@onready var top_attach: Marker3D = $TopAttachment if has_node("TopAttachment") else null
@onready var bottom_attach: Marker3D = $BottomAttachment if has_node("BottomAttachment") else null

func _ready() -> void:
	freeze = is_frozen
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC if is_frozen else RigidBody3D.FREEZE_MODE_KINEMATIC
	# above changes freeze state

# Returns the two main attachment points
func get_attachment_points() -> Array[Marker3D]:
	var ports: Array[Marker3D] = []
	if top_attach:
		ports.append(top_attach)
	if bottom_attach:
		ports.append(bottom_attach)
	return ports
