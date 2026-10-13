# sound_manager.gd
extends Node

# One player per sound so they can overlap freely
var place_player: AudioStreamPlayer
var thrust_player: AudioStreamPlayer
var crash_player: AudioStreamPlayer

func _ready() -> void:
	place_player = _make_player("place")
	thrust_player = _make_player("thrust")
	crash_player = _make_player("crash")

func _make_player(sound_name: String) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.name = sound_name + "_player"
	add_child(player)
	
	# Try to load the real audio file if it exists
	var path = "res://sounds/" + sound_name + ".wav"
	if ResourceLoader.exists(path):
		player.stream = load(path)
		print("✅ Loaded sound: ", path)
	else:
		print("⚠️ No sound file found for: ", sound_name, " (add one at ", path, ")")
	
	return player

func play_place() -> void:
	if place_player.stream:
		place_player.play()

func play_thrust_start() -> void:
	if thrust_player.stream:
		thrust_player.play()

func play_thrust_stop() -> void:
	thrust_player.stop()

func play_crash() -> void:
	# Stop thrust sound if rocket crashes mid-flight
	thrust_player.stop()
	if crash_player.stream:
		crash_player.play()
