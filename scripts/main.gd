extends Node

signal domino_submitted(domino)

func _ready() -> void:
	var start_screen = $startScreen
	start_screen.start_pressed.connect(_on_start_game)
	$background.z_index = -2
	$screenEffect.layer = 999
func _on_start_game() -> void:
	$startScreen.hide()
	$"42game".visible = true
	$gameMusic.play()
	$AudioStreamPlayer.stop()
