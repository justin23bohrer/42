extends Node

signal domino_submitted

const FIRST_PLAYER = Vector2(536, 360)
const SECOND_PLAYER = Vector2(604, 360)
const THIRD_PLAYER = Vector2(672, 360)
const FOURTH_PLAYER = Vector2(740, 360)

var leadingSuit = -1
var myScore = 0
var opponentScore = 0
var dominosInMiddle = []
var player_rotation = ["me","op1","tm8","op2"]
var domsThatTurn = {}
var winning_player = "me"

# Called when the node is added to the scene
func _ready():
	$"../coin".play("default")

func turn(turn, player):
	print(player)
	var placement
	match turn:
		0:
			placement = FIRST_PLAYER
		1:
			placement = SECOND_PLAYER
		2:
			placement = THIRD_PLAYER
		3:
			placement = FOURTH_PLAYER
	if player in ["op1", "op2", "tm8"]:
		$"../Timer".start()
		await $"../Timer".timeout
		ai_plays_dom(player, placement)
	else:
		$"../Timer".start()
		await $"../Timer".timeout
		$"../dominoSlot".visible = true
		$"../dominoSlot".position = placement
		$"../subDom".visible = true

func play_round():
	for i in range(7):
		domsThatTurn = {
			"op1": [],
			"tm8": [],
			"op2": [],
			"me": []
		}
		leadingSuit = -1
		rotate_players()
		for y in player_rotation.size():
			var player = player_rotation[y]
			await turn(y, player)
			if player == "me":
				await self.domino_submitted
			if y == 0 and domsThatTurn[player].size() > 0:
				var played_dom = domsThatTurn[player][0]
				leadingSuit = max(played_dom[0], played_dom[1])
		domino_accountant()
		$"../Timer".start()
		await $"../Timer".timeout
	#clear doms
		await animate_dominos_to_winner()
		print(winning_player)

func rotate_players():
	var index = player_rotation.find(winning_player)
	if index == -1:
		print("Winning player not in rotation")
		return
	
	var new_rotation = []
	for i in range(player_rotation.size()):
		var rotated_index = (index + i) % player_rotation.size()
		new_rotation.append(player_rotation[rotated_index])
	
	player_rotation = new_rotation
	print(player_rotation)

func run_game():
	$"../startGame".visible = false
	hand_players_dominos()
	await play_round()
	present_final_score()

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

	# If no domino is placed, just return 
	if not slot.domino_in_slot or not slot.domino:
		return

	$"../subDom".visible = false
	$"../dominoSlot".visible = false

	#submitting dom in slot
	var domino = slot.domino
	domsThatTurn["me"].append([domino.left_value, domino.right_value])
	emit_signal("domino_submitted")
	dominosInMiddle.append(domino)
	slot.domino_in_slot = false
	slot.get_node("Area2D/CollisionShape2D").disabled = false
	

func ai_plays_dom(player, location):
	var hand_node
	match player:
		"op1": hand_node = get_node("../opponentHand1")
		"op2": hand_node = get_node("../opponentHand2")
		"tm8": hand_node = get_node("../teammateHand")
		_: print("Invalid AI player"); return

	var legal_dominos = []
	var off_suit_dominos = []

	for domino in hand_node.player_hand:
		if domino.left_value == leadingSuit or domino.right_value == leadingSuit:
			legal_dominos.append(domino)
		else:
			off_suit_dominos.append(domino)

	var chosen_domino
	if legal_dominos.size() > 0:
		# Prioritize doubles first, then highest sum
		chosen_domino = legal_dominos[0]
		for dom in legal_dominos:
			if dom.left_value == dom.right_value and chosen_domino.left_value != chosen_domino.right_value:
				chosen_domino = dom
			elif (dom.left_value + dom.right_value) > (chosen_domino.left_value + chosen_domino.right_value):
				chosen_domino = dom
	else:
		# No legal move, play lowest off-suit domino
		chosen_domino = off_suit_dominos[0]
		for dom in off_suit_dominos:
			if (dom.left_value + dom.right_value) < (chosen_domino.left_value + chosen_domino.right_value) and dom.left_value == dom.right_value and dom.left_value + dom.right_value != 5 and dom.left_value + dom.right_value != 10:
				chosen_domino = dom

	hand_node.present_domino(chosen_domino, location)
	chosen_domino.update_domino_display()
	dominosInMiddle.append(chosen_domino)
	domsThatTurn[player].append([chosen_domino.left_value, chosen_domino.right_value])

func domino_accountant():
	print(domsThatTurn)
	winning_player = get_player_with_biggest_domino()
	
	var points_this_round = 0
	for domino in dominosInMiddle:
		var sum = domino.left_value + domino.right_value
		if sum % 5 == 0:
			points_this_round += sum
	
	if winning_player == "me" or winning_player == "tm8":
		myScore += points_this_round+1
	if winning_player == "op1" or winning_player == "op2":
		opponentScore += points_this_round+1
	
func get_player_with_biggest_domino() -> String:
	var best_player = ""
	var best_score = -1
	var best_priority = -1

	for player in domsThatTurn.keys():
		var dom = domsThatTurn[player][0]
		var is_double = dom[0] == dom[1]
		var follows_suit = dom[0] == leadingSuit or dom[1] == leadingSuit
		var dom_score = dom[0] + dom[1]

		# Priority: double-in-suit > in-suit > double > off-suit
		var priority = 0
		if is_double and follows_suit:
			priority = 3
		elif follows_suit:
			priority = 2
		elif is_double:
			priority = 1

		# Pick higher priority, or higher sum within tie
		if priority > best_priority or (priority == best_priority and dom_score > best_score):
			best_priority = priority
			best_score = dom_score
			best_player = player

	return best_player

func present_final_score():
	if myScore > opponentScore:
		print("I win")
	else:
		print("you lost")
	$"../startGame".visible = true
func update_score():
	$"../myScore".text = "Our Score: " + str(myScore)
	$"../opponentScore".text = "Opponent Score: " + str(opponentScore)


func _on_start_game_pressed() -> void:
	myScore = 0
	opponentScore = 0
	update_score()
	run_game()

func get_player_position(player: String) -> Vector2:
	match player:
		"me": return Vector2(45,-70)
		"op1": return Vector2(1200, -70)
		"tm8": return Vector2(45,-70)
		"op2": return Vector2(1200, -70)
		_: return Vector2(0, 0)  # fallback

func animate_dominos_to_winner() -> void:
	var tot_round_points = 1
	for dom in dominosInMiddle:
		if dom == get_winning_domino():
			dom.winning_dom_animation()
	$"../runThroughDoms".start()
	await $"../runThroughDoms".timeout
	for dom in dominosInMiddle:
		dom.done_dom_animation()
		$"../plusOne".visible = true
	$"../runThroughDoms".start()
	await $"../runThroughDoms".timeout
	$"../plusOne".visible = false
	for dom in dominosInMiddle:
		var sum = dom.left_value + dom.right_value
		# Only the winning domino gets the multiple_of_five_animation if divisible by 5
		if sum % 5 == 0 and sum != 0:
			tot_round_points += sum
			dom.multiple_of_five_animation(sum)
			$"../runThroughDoms".start()
			await $"../runThroughDoms".timeout
	if winning_player == "me" or winning_player == "tm8":
		$"../myTeamPoints".text = "+"+str(tot_round_points)
		$"../myTeamPoints".visible = true
	else:
		$"../opTeamPoints".text = "+"+str(tot_round_points)
		$"../opTeamPoints".visible = true
	
	$"../Timer".start()
	await $"../Timer".timeout
	
	var target_pos = get_player_position(winning_player)

	for dom in dominosInMiddle:
		dom.z_index = -1
		var tween = dom.create_tween()
		tween.tween_property(dom, "position", target_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(dom, "modulate:a", 0.0, 0.3).set_delay(0.5)

	await get_tree().create_timer(1.0).timeout
	$"../myTeamPoints".visible = false
	$"../opTeamPoints".visible = false
	update_score()
	for dom in dominosInMiddle:
		dom.queue_free()
	dominosInMiddle = []

func get_winning_domino() -> Node:
	var winning_dom_values = domsThatTurn[winning_player][0]
	for dom in dominosInMiddle:
		if (dom.left_value == winning_dom_values[0] and dom.right_value == winning_dom_values[1]) or (dom.left_value == winning_dom_values[1] and dom.right_value == winning_dom_values[0]):
			return dom
	return null
