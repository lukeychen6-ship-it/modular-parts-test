# achievement_manager.gd
extends CanvasLayer

var popup_label: Label
var popup_panel: PanelContainer
var popup_timer: float = 0.0
var popup_duration: float = 3.0
var achieved: Array[String] = []


var achievements = [
	[100,   "Airborne", "🥉", "1000m"],
	[1000,   "Getting Somewhere", "🥈", "5000m"],
	[5000,  "Getting Higher", "🥇", "13000m"],
	[13000,  "Reached the Stratosphere",     "💎", "80000m"],
	[80000,  "Reached Space", "🏆", "None"],
]

@onready var assembly_manager = get_tree().get_root().find_child("AssemblyManager", true, false)

func _ready() -> void:
	# Build the popup UI
	popup_panel = PanelContainer.new()
	popup_panel.visible = false
	
	var vbox = VBoxContainer.new()
	popup_label = Label.new()
	popup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	vbox.add_child(popup_label)
	popup_panel.add_child(vbox)
	add_child(popup_panel)

	# Set exact pixel coordinates (e.g., near the bottom left)
	popup_panel.position = Vector2(0, 500)

func _process(delta: float) -> void:
	# Count down and hide popup when done
	if popup_panel.visible:
		popup_timer -= delta
		if popup_timer <= 0.0:
			popup_panel.visible = false

	if not assembly_manager or not assembly_manager.controller:
		return
	
	var engines = assembly_manager.controller.engines
	if engines.is_empty():
		return
	
	var elevation: float = engines[0].global_position.y
	check_achievements(elevation)

func check_achievements(elevation: float) -> void:
	for achievement in achievements:
		var altitude = achievement[0]
		var title = achievement[1]
		var medal = achievement[2]
		var next_medal = achievement[3]
		
		# Only trigger if not already achieved and altitude is reached
		if title not in achieved and elevation >= altitude:
			achieved.append(title)
			show_popup(title, medal, altitude, next_medal)

func show_popup(title: String, medal: String, altitude: float, next_medal: String) -> void:
	popup_label.text = medal + "\n" + title + "\n" + str(altitude) + "m reached!" + "\n" + "Next medal at " + str(next_medal)
	popup_panel.visible = true
	popup_timer = popup_duration
	print("Achievement unlocked: ", title)
