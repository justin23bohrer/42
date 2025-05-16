extends Node2D

signal hovered
signal hovered_off

var is_locked = false
var starting_position
var in_slot = false

var left_value: int = 0
var right_value: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Must have parent 
	get_parent().connect_domino_signals(self)

func update_domino_display():
	match left_value:
		0:
			$left.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/0.png")
		1:
			$left.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/1.png")
		2:
			$left.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/2.png")
		3:
			$left.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/3.png")
		4:
			$left.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/4.png")
		5:
			$left.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/5.png")
		6:
			$left.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/6.png")
	match right_value:
		0:
			$right.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/0.png")
		1:
			$right.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/1.png")
		2:
			$right.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/2.png")
		3:
			$right.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/3.png")
		4:
			$right.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/4.png")
		5:
			$right.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/5.png")
		6:
			$right.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/6.png")

func update_domino_display_non_player():
	$left.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/0.png")
	$right.texture = ResourceLoader.load("res://assets/dominos/dominoNumbers/0.png")
	$Area2D.set_deferred("monitoring", false)
	$Area2D.get_node("CollisionShape2D").set_deferred("disabled", true)


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
	
func multiple_of_five_animation(num):
	$normalDom.visible = false
	$redDom.visible = true
	if num == 5:
		$five.visible = true
	if num == 10:
		$ten.visible = true
	$Timer.start()
	await $Timer.timeout
	$normalDom.visible = true
	$redDom.visible = false
	$five.visible = false
	$ten.visible = false

func done_dom_animation():
	$normalDom.visible = false
	$doneDom.visible = true
	$Timer.start()
	await $Timer.timeout
	$normalDom.visible = true
	$doneDom.visible = false

func winning_dom_animation():
	$normalDom.visible = false
	$winningDom.visible = true
	$Timer.start()
	await $Timer.timeout
	$normalDom.visible = true
	$winningDom.visible = false
