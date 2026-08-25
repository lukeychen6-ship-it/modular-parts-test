extends BoxContainer
var rank_label = Label
var rank = "Grounded"
@onready var max_altitude = get_tree().get_root().find_child("MaxAltitude", true, false)

# Rank Explanations:
# 0m: Grounded
# 100m: Airbourne
# 1000m: Alright Rocket
# 5000m: Experienced Rocket Builder
# 11582m (38000 ft): Airplane Pilot
# 13000m: Troposphere Breaker
# 50000m: Stratosphere Breaker
# 80000m: Reached Space
# 100000m: Astronaut
# 330000m: ISS Member

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rank_label = Label.new()
	rank_label.text = "Status: None"
	add_child(rank_label)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_requirements()
	rank_label.text = "Status: " + rank

func check_requirements() -> void:
	if max_altitude.max_altitude > 330000:
		rank = "Reached the ISS"
	elif max_altitude.max_altitude > 100000:
		rank = "Reached 100000 meters"
	elif max_altitude.max_altitude > 80000:
		rank = "Reached Space"
	elif max_altitude.max_altitude > 50000:
		rank = "Broke the stratosphere"
	elif max_altitude.max_altitude > 13000:
		rank = "Reached the stratosphere"
	elif max_altitude.max_altitude > 11582:
		rank = "Reached cruising altitude"
	elif max_altitude.max_altitude > 5000:
		rank = "High-Flyer"
	elif max_altitude.max_altitude > 1000:
		rank = "Getting Somewhere"
	elif max_altitude.max_altitude > 100:
		rank = "Airborne"
		
