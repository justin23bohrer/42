extends Node

signal domino_submitted(domino)

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
	$subDom.visible = true


func _on_sub_dom_pressed() -> void:
	var slot = $dominoSlot
	if slot.domino_in_slot:
		var domino = get_node_or_null("dominoManager").domino_being_dragged
		if domino == null:
			for child in $dominoManager.get_children():
				if child.is_locked:
					domino = child
					break
		if domino:
			emit_signal("domino_submitted", domino)
