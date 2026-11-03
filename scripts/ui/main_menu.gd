
extends Control

# Main Menu for Dungeon Deck.

const RUN_MANAGER_SCRIPT: Script = preload(
    "res://scripts/dungeon/run_manager.gd"
)

const SETTINGS_SCENE: String = (
    "res://scenes/ui/settings_menu.tscn"
)


func _ready() -> void:
	print("Main menu loaded successfully!")


func _on_new_game_pressed() -> void:
	print("Starting new dungeon run...")

	# Create the Run Manager.
	var run_manager := Control.new()
	run_manager.set_script(RUN_MANAGER_SCRIPT)

	# Add it to the scene tree.
	# Its _ready() function starts the dungeon run.
	get_tree().root.add_child(run_manager)

	run_manager.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# Remove the old Main Menu.
	queue_free()


func _on_settings_pressed() -> void:
	print("Opening Settings Menu...")

	var error: Error = get_tree().change_scene_to_file(
		SETTINGS_SCENE
	)

	if error != OK:
		push_error(
			"Failed to load settings scene: %s" % error
		)


func _on_quit_pressed() -> void:
	get_tree().quit()
