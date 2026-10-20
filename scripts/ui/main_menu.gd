extends Control

# Main Menu - UI/UX & Mobile Developer

func _ready() -> void:
	print("Main menu loaded successfully!")


func _on_new_game_pressed() -> void:
	print("New Game selected")
	# Gameplay scene will be connected later.


func _on_settings_pressed() -> void:
	print("Opening Settings Menu...")
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
