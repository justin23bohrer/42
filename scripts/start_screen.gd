extends Control

signal start_pressed
@onready var my_sprite = $"../background"  # or get_node("MySprite")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	self.hide()
	emit_signal("start_pressed")
	
func _on_button_2_pressed() -> void:
	pass # options
	
func _on_button_3_pressed() -> void:
	get_tree().quit()
