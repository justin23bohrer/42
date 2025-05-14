extends Node2D

signal hovered
signal hovered_off

var is_locked = false
var starting_position

var left_value: int = 0
var right_value: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Must have parent 
	get_parent().connect_domino_signals(self)

func update_domino_display():
	$Label.text = str(left_value)
	$Label2.text = str(right_value)
func update_domino_display_non_player():
	$Label.text = ""
	$Label2.text = ""
	$Area2D.set_deferred("monitoring", false)
	$Area2D.get_node("CollisionShape2D").set_deferred("disabled", true)


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
