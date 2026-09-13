extends RigidBody3D
class_name RocketPart

@export var is_frozen: bool = true

@onready var top_attach: Marker3D = $TopAttachment
@onready var bottom_attach: Marker3D = $BottomAttachment

# Side attachments are optional — only engines have these
var left_attach: Marker3D = null
var right_attach: Marker3D = null

func _ready() -> void:
	freeze = is_frozen
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC if is_frozen else RigidBody3D.FREEZE_MODE_KINEMATIC
	
	# Grab side ports if they exist on this part
	if has_node("LeftAttachment"):
		left_attach = $LeftAttachment
	if has_node("RightAttachment"):
		right_attach = $RightAttachment

func get_attachment_points() -> Array[Marker3D]:
	return [top_attach, bottom_attach]

func get_side_attachment_points() -> Array[Marker3D]:
	var sides: Array[Marker3D] = []
	if left_attach:
		sides.append(left_attach)
	if right_attach:
		sides.append(right_attach)
	return sides

func get_port_global_transform(port_name: String) -> Transform3D:
	if port_name == "top" and top_attach:
		return top_attach.global_transform
	if port_name == "bottom" and bottom_attach:
		return bottom_attach.global_transform
	if port_name == "left" and left_attach:
		return left_attach.global_transform
	if port_name == "right" and right_attach:
		return right_attach.global_transform
	return global_transform
