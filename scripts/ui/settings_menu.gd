
extends Control

# Settings Menu - UI/UX & Mobile Developer

const SETTINGS_PATH: String = "user://settings.cfg"

@onready var master_slider: HSlider = $CenterContainer/VBoxContainer/MasterVolume
@onready var music_slider: HSlider = $CenterContainer/VBoxContainer/MusicVolume
@onready var sfx_slider: HSlider = $CenterContainer/VBoxContainer/SFXVolume


func _ready() -> void:
	print("Settings menu loaded successfully!")

	# Restore saved audio settings when the menu opens.
	_load_settings()

	# Display the current volume of each audio bus.
	_load_slider_volume(master_slider, "Master")
	_load_slider_volume(music_slider, "Music")
	_load_slider_volume(sfx_slider, "SFX")


# Load previously saved audio preferences.
func _load_settings() -> void:
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)

	# No settings file exists on the first launch.
	if error == ERR_FILE_NOT_FOUND:
		print("No saved settings found. Using default volumes.")
		return

	if error != OK:
		push_warning("Could not load settings.")
		return

	for bus_name in ["Master", "Music", "SFX"]:
		var volume: float = float(
			config.get_value("audio", bus_name, 100.0)
		)

		_apply_volume(bus_name, volume)

	print("Saved audio settings loaded successfully!")


# Save all three volume preferences.
func _save_settings() -> void:
	var config := ConfigFile.new()

	config.set_value("audio", "Master", master_slider.value)
	config.set_value("audio", "Music", music_slider.value)
	config.set_value("audio", "SFX", sfx_slider.value)

	var error := config.save(SETTINGS_PATH)

	if error != OK:
		push_warning("Failed to save audio settings.")
	else:
		print("Audio settings saved successfully!")


# Display the current volume on its corresponding slider.
func _load_slider_volume(slider: HSlider, bus_name: String) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)

	if bus_index == -1:
		push_warning("Audio bus not found: " + bus_name)
		return

	if AudioServer.is_bus_mute(bus_index):
		slider.set_value_no_signal(0.0)
		return

	var current_volume: float = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)

	slider.set_value_no_signal(
		clampf(current_volume * 100.0, 0.0, 100.0)
	)


# Apply a volume percentage to an audio bus.
func _apply_volume(bus_name: String, value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)

	if bus_index == -1:
		push_warning("Audio bus not found: " + bus_name)
		return

	var linear_volume: float = clampf(value / 100.0, 0.0, 1.0)

	if linear_volume <= 0.0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(
			bus_index,
			linear_to_db(linear_volume)
		)


# Update volume and automatically save preferences.
func _set_volume(bus_name: String, value: float) -> void:
	_apply_volume(bus_name, value)
	_save_settings()

	print("Updated ", bus_name, " volume to ", value, "%")


# Master Volume slider.
func _on_master_volume_changed(value: float) -> void:
	_set_volume("Master", value)


# Music Volume slider.
func _on_music_volume_changed(value: float) -> void:
	_set_volume("Music", value)


# Sound Effects slider.
func _on_sfx_volume_changed(value: float) -> void:
	_set_volume("SFX", value)


# Return to the main menu.
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://scenes/ui/main_menu.tscn"
	)
