extends Node

@onready var HUD = preload("res://scenes/gameHUD.tscn").instantiate()
var original_positions := {}

func _ready() -> void:
	var start_screen = $startScreen
	start_screen.start_pressed.connect(_on_start_game)

func _on_start_game() -> void:
	print("Start button was pressed!")
	$startScreen.hide()
	$dominoManager.visible = true
	$dominoSlot.visible = true
	$background.visible = false
	$playerHand.visible = true
