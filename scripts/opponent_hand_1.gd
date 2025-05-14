extends Node2D

const DOMINO_SCENE_PATH = "res://scenes/domino.tscn"
const CARD_WIDTH = 120
const HAND_Y_POSITION = 50

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
		new_domino.update_domino_display_non_player()

func add_domino_to_hand(domino):
	if domino not in player_hand:
		player_hand.insert(0, domino)
		update_hand_position()
	else:
		animate_domino_to_position(domino, domino.starting_position)
	
func update_hand_position():
	var total = player_hand.size()
	var column_x = 80  # Starting X position on the left side
	var column_spacing = 75  # Horizontal spacing between columns
	var domino_height = 120

	var screen_center_y = get_viewport().size.y / 2

	for i in range(total):
		var column = 0 if i < 3 else 1  # First 3 go in column 0, rest in column 1
		var index_in_column = i if column == 0 else i - 3
		var dominos_in_column = 3 if column == 0 else 4

		var total_height = (dominos_in_column - 1) * domino_height
		var y_offset = screen_center_y + index_in_column * domino_height - total_height / 2
		var x_pos = column_x + column * column_spacing

		var new_position = Vector2(x_pos, y_offset)
		var domino = player_hand[i]
		domino.starting_position = new_position
		animate_domino_to_position(domino, new_position)
		domino.rotation_degrees = 90  # Optional: rotate dominos vertically



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

func present_domino(domino):
	if domino in player_hand:
		# Remove it from the hand and update remaining hand layout
		remove_domino_from_hand(domino)

		# Animate to center of the screen
		var center_position = Vector2(center_screen_x, get_viewport().size.y / 2)
		animate_domino_to_position(domino, center_position)
	
