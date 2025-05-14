extends Node2D

const DOMINO_SCENE_PATH = "res://scenes/domino.tscn"
const CARD_WIDTH = 120
const HAND_Y_POSITION = 550

var player_hand = []
var center_screen_x

func _ready():
	center_screen_x = get_viewport().size.x / 2

func receive_domino_values(domino_values: Array):
	var domino_scene = preload(DOMINO_SCENE_PATH)

	for pair in domino_values:
		var new_domino = domino_scene.instantiate()
		new_domino.left_value = pair[0]
		new_domino.right_value = pair[1]

		get_node("../dominoManager").add_child(new_domino)
		add_domino_to_hand(new_domino)
		new_domino.update_domino_display()

func add_domino_to_hand(domino):
	if domino not in player_hand:
		player_hand.insert(0, domino)
		update_hand_position()
	else:
		animate_domino_to_position(domino, domino.starting_position)
	
func update_hand_position():
	var total = player_hand.size()
	for i in range(total):
		var row = 0 if i < 4 else 1
		var index_in_row = i if row == 0 else i - 4
		
		var row_y = HAND_Y_POSITION if row == 0 else HAND_Y_POSITION + 75  # 150 px below the top row
		var dominos_in_this_row = 4 if row == 0 else 3
		
		var total_width = (dominos_in_this_row - 1) * CARD_WIDTH
		var x_offset = center_screen_x + index_in_row * CARD_WIDTH - total_width / 2
		
		var new_position = Vector2(x_offset, row_y)
		var domino = player_hand[i]
		domino.starting_position = new_position
		animate_domino_to_position(domino, new_position)

func calculate_domino_position(i):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + i * CARD_WIDTH - total_width / 2
	return x_offset

func animate_domino_to_position(domino, position):
	var tween = get_tree().create_tween()
	tween.tween_property(domino, "position", position, 0.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func remove_domino_from_hand(domino):
	if domino in player_hand:
		player_hand.erase(domino)
		update_hand_position()
