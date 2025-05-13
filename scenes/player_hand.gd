extends Node2D

const HAND_COUNT = 4
const DOMINO_SCENE_PATH = "res://scenes/domino.tscn"
const CARD_WIDTH = 120
const HAND_Y_POSITION = 600

var player_hand = []
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	center_screen_x = get_viewport().size.x / 2
	
	var domino_scene = preload(DOMINO_SCENE_PATH)
	for i in range(HAND_COUNT):
		var new_domino = domino_scene.instantiate()
		$"../dominoManager".add_child(new_domino)
		new_domino.name = "Domino"
		add_domino_to_hand(new_domino)

func add_domino_to_hand(domino):
	player_hand.insert(0, domino)
	update_hand_position()
	
func update_hand_position():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_domino_position(i), HAND_Y_POSITION)
		var domino = player_hand[i]
		animate_domino_to_position(domino, new_position)

func calculate_domino_position(i):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + i * CARD_WIDTH - total_width / 2
	return x_offset

func animate_domino_to_position(domino, position):
	var tween = get_tree().create_tween()
	tween.tween_property(domino, "position", position, 0.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
