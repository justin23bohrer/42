extends Node2D

signal hovered
signal hovered_off

var is_locked = false
var starting_position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Must have parent 
	get_parent().connect_domino_signals(self)

func _process(delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
