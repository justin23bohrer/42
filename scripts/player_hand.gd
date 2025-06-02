extends Node2D

const DOMINO_SCENE_PATH = "res://scenes/domino.tscn"
const CARD_WIDTH = 120
const HAND_Y_POSITION = 550

var player_hand = []
var center_screen_x = 0.0

func _ready():
	center_screen_x = get_viewport().size.x / 2

func receive_domino_values(domino_values: Array):
	var domino_scene = preload(DOMINO_SCENE_PATH)

	for pair in domino_values:
		var new_domino = domino_scene.instantiate()
		new_domino.left_value = pair[0]
		new_domino.right_value = pair[1]
		
		new_domino.z_index = 999
		new_domino.z_as_relative = false

		get_node("../dominoManager").add_child(new_domino)
		add_domino_to_hand(new_domino)
		new_domino.update_domino_display()

func add_domino_to_hand(domino):
	if domino in player_hand:
		player_hand.erase(domino)
	
	# Use domino position x and y to get insert index correctly for row
	var insert_index = get_insert_index(domino.position.x, domino.position.y)
	player_hand.insert(insert_index, domino)
	update_hand_position()
	
func update_hand_position():
	center_screen_x = get_viewport().size.x / 2

	var total = player_hand.size()
	for i in range(total):
		var row = 0 if i < 4 else 1
		var index_in_row = i if row == 0 else i - 4

		var row_y = HAND_Y_POSITION if row == 0 else HAND_Y_POSITION + 75
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

func get_insert_index(drop_x: float, drop_y: float) -> int:
	if player_hand.size() == 0:
		return 0
	
	var row = 0 if drop_y < HAND_Y_POSITION + 40 else 1
	var start_index = 0 if row == 0 else 4
	var end_index = 4 if row == 0 else player_hand.size()
	
	# Clamp start_index and end_index to valid range
	start_index = clamp(start_index, 0, player_hand.size())
	end_index = clamp(end_index, 0, player_hand.size())
	
	for i in range(start_index, end_index):
		if drop_x < player_hand[i].position.x:
			return i
	
	return end_index
