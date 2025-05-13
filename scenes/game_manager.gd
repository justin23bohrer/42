extends Node

func _ready():
	hand_players_dominos()
	var main_node = get_node("..")
	main_node.connect("domino_submitted", Callable(self, "_on_domino_submitted"))
	
func _on_domino_submitted(domino):
	var slot = get_node("../dominoSlot")
	slot.domino_in_slot = false
	print("Domino submitted with values: ", domino.left_value, "-", domino.right_value)
	domino.queue_free()  # Remove the domino from the game
	
func hand_players_dominos():
	var all_dominos = generate_all_dominos()
	all_dominos.shuffle()

	var player_hand_values = all_dominos.slice(0, 7)  # Give first 7
	var player_hand = get_node("../playerHand")
	player_hand.receive_domino_values(player_hand_values)
	

func generate_all_dominos():
	var all_dominos = []
	for i in range(7):
		for j in range(i, 7):
			all_dominos.append([i, j])
	return all_dominos
