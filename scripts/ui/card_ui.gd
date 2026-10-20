
extends Button

signal card_selected(card: CardInstance)

var card_instance: CardInstance


func _ready() -> void:
    pressed.connect(_on_pressed)


func setup(card: CardInstance) -> void:
    card_instance = card
    _update_display()


func _update_display() -> void:
    if card_instance == null:
        return

    text = "%s\n\nENERGY: %d\n\n%s" % [
        card_instance.get_name(),
        card_instance.get_cost(),
        card_instance.get_text()
    ]


func _on_pressed() -> void:
    if card_instance != null:
        card_selected.emit(card_instance)
