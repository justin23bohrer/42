extends Node

const FIRST_PLAYER = Vector2(536, 360)
const SECOND_PLAYER = Vector2(604, 360)
const THIRD_PLAYER = Vector2(672, 360)
const FOURTH_PLAYER = Vector2(740, 360)

var myScore = 0
var opponentScore = 0
var dominosInMiddle = []
var turns = [1,2,3,4]
var turn_counter = 0

# Called when the node is added to the scene
func _ready():
	run_game()
	$"../coin".play("default")

func run_game():
	myScore = 0
	opponentScore = 0
	hand_players_dominos()
	opponent1_put_domino_in_middle(FIRST_PLAYER)
	opponent2_put_domino_in_middle(SECOND_PLAYER)
	teammate_put_domino_in_middle(THIRD_PLAYER)
	$"../dominoSlot".position = FOURTH_PLAYER
	turn_counter = 0

# Handles dealing dominos to the player's hand
func hand_players_dominos():
	var all_dominos = generate_all_dominos()
	all_dominos.shuffle()

	var player_hand_values = all_dominos.slice(0, 7)
	var teammate_hand_values = all_dominos.slice(7, 14) 
	var opponent_hand1_values = all_dominos.slice(14, 21)
	var opponent_hand2_values = all_dominos.slice(21, 28)
	 
	#hand me dominos
	var player_hand = get_node("../playerHand")
	player_hand.receive_domino_values(player_hand_values)
	#hand teammate dominos
	var teammate_hand = get_node("../teammateHand")
	teammate_hand.receive_domino_values(teammate_hand_values)
	#hand opponent1 dominos
	var opponent_hand1 = get_node("../opponentHand1")
	opponent_hand1.receive_domino_values(opponent_hand1_values)
	#hand opponent2 dominos
	var opponent_hand2 = get_node("../opponentHand2")
	opponent_hand2.receive_domino_values(opponent_hand2_values)

# Generates a standard set of 28 dominos
func generate_all_dominos():
	var all_dominos = []
	for i in range(7):
		for j in range(i, 7):
			all_dominos.append([i, j])
	return all_dominos

# Called when the submit button is pressed
func _on_sub_dom_pressed() -> void:
	var slot = get_node("../dominoSlot")
	if slot.domino_in_slot:
		teammate_turn()

func teammate_turn():
	#$"../subDom".visible = false
	#$"../subDom".disabled = true
	var slot = get_node("../dominoSlot")
	
	if slot.domino_in_slot:
		var domino = slot.domino
		if domino:
			_on_domino_submitted(domino)
	for i in dominosInMiddle:
		i.queue_free()
		dominosInMiddle = []
	
	opponent1_put_domino_in_middle(FIRST_PLAYER)
	opponent2_put_domino_in_middle(SECOND_PLAYER)
	teammate_put_domino_in_middle(THIRD_PLAYER)
	
func opponent1_put_domino_in_middle(location):
	var hand_node = get_node("../opponentHand1") 
	if hand_node.player_hand.size() > 0:
		var first_domino = hand_node.player_hand[0]
		hand_node.present_domino(first_domino, location)
		first_domino.update_domino_display()
		dominosInMiddle.append(first_domino)
	else:
		present_final_score()

func opponent2_put_domino_in_middle(location):
	var hand_node = get_node("../opponentHand2") 
	if hand_node.player_hand.size() > 0:
		var first_domino = hand_node.player_hand[0]
		hand_node.present_domino(first_domino, location)
		first_domino.update_domino_display()
		dominosInMiddle.append(first_domino)
	else:
		present_final_score()

func teammate_put_domino_in_middle(location):
	var hand_node = get_node("../teammateHand") 
	if hand_node.player_hand.size() > 0:
		var first_domino = hand_node.player_hand[0]
		hand_node.present_domino(first_domino, location)
		first_domino.update_domino_display()
		dominosInMiddle.append(first_domino)
	else:
		present_final_score()


func present_final_score():
	if myScore > opponentScore:
		print("I win")
	else:
		print("you lost")

# Handles a submitted domino
func _on_domino_submitted(domino):
	var slot = get_node("../dominoSlot")
	slot.domino_in_slot = false
	slot.get_node("Area2D/CollisionShape2D").disabled = false
	domino.queue_free()

func update_score():
	$"../myScore".text = "Our Score: " + str(myScore)
	$"../opponentScore".text = "Opponent Score: " + str(opponentScore)
