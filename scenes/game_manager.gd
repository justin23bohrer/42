extends Node

# Called when the node is added to the scene
func _ready():
	hand_players_dominos()

# Handles dealing dominos to the player's hand
func hand_players_dominos():
	var all_dominos = generate_all_dominos()
	all_dominos.shuffle()

	var player_hand_values = all_dominos.slice(0, 7)
	var teammate_hand_values = all_dominos.slice(7, 14) 
	var player_hand = get_node("../playerHand")
	player_hand.receive_domino_values(player_hand_values)
	var teammate_hand = get_node("../teammateHand")
	teammate_hand.receive_domino_values(teammate_hand_values)

# Generates a standard set of 28 dominos
func generate_all_dominos():
	var all_dominos = []
	for i in range(7):
		for j in range(i, 7):
			all_dominos.append([i, j])
	return all_dominos

# Called when the submit button is pressed
func _on_sub_dom_pressed() -> void:
	$"../subDom".visible = false
	$"../subDom".disabled = true
	var slot = get_node("../dominoSlot")
	
	if slot.domino_in_slot:
		var domino = slot.domino
		
		if domino == null:
			for child in $dominoManager.get_children():
				if child.is_locked:
					domino = child
					break

		if domino:
			_on_domino_submitted(domino)

# Handles a submitted domino
func _on_domino_submitted(domino):
	var slot = get_node("../dominoSlot")
	slot.domino_in_slot = false
	slot.get_node("Area2D/CollisionShape2D").disabled = false
	
	print("Domino submitted with values: ", domino.left_value, "-", domino.right_value)
	domino.queue_free()
