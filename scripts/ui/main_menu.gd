
extends Control

# Main Menu - UI/UX & Mobile Developer

func _ready() -> void:
    print("Main menu loaded successfully!")


func _on_new_game_pressed() -> void:
    var error := get_tree().change_scene_to_file(
        "res://scenes/dungeon/run_manager.tscn"
    )

    if error != OK:
        push_error(
            "Failed to open dungeon scene: %d" % error
        )


func _on_settings_pressed() -> void:
    print("Opening Settings Menu...")
    get_tree().change_scene_to_file(
        "res://scenes/ui/settings_menu.tscn"
    )


func _on_quit_pressed() -> void:
    get_tree().quit()
