extends Node2D

const COLLISION_MASK_DOMINO = 1
const COLLISION_MASK_DOMINO_SLOT = 2
const Z_INDEX_NORMAL = 1
const Z_INDEX_HOVERED = 10
const Z_INDEX_DRAGGED = 100

var domino_being_dragged
var screen_size
var is_hovering_on_domino
var player_hand_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_hand_reference = $"../playerHand"
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if domino_being_dragged:
		var mouse_pos = get_global_mouse_position()
		domino_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x),
			clamp(mouse_pos.y, 0, screen_size.y))
	

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var domino = raycast_check_for_domino()
			if domino:
				start_drag(domino)
		else:
			if domino_being_dragged:
				finish_drag()

func start_drag(domino):
	if domino.is_locked:
		return
	domino_being_dragged = domino
	domino.scale = Vector2(1, 1)
	domino.z_index = Z_INDEX_DRAGGED


func finish_drag():
	if domino_being_dragged:
		domino_being_dragged.scale = Vector2(1.05, 1.05)
		var domino_slot_found = raycast_check_for_domino_slot()
		if domino_slot_found and not domino_slot_found.domino_in_slot:
			player_hand_reference.remove_domino_from_hand(domino_being_dragged)
			domino_being_dragged.position = domino_slot_found.position
			domino_slot_found.get_node("Area2D/CollisionShape2D").disabled = true
			domino_slot_found.domino_in_slot = true
			domino_being_dragged.is_locked = true  
		else:
			player_hand_reference.add_domino_to_hand(domino_being_dragged)
		domino_being_dragged = null

func connect_domino_signals(domino):
	domino.connect("hovered", on_hovered_over_domino)
	domino.connect("hovered_off", on_hovered_off_domino)
	
func on_hovered_over_domino(domino):
	if !is_hovering_on_domino:
		is_hovering_on_domino = true
		highlight_domino(domino, true)

func on_hovered_off_domino(domino):
	if !domino_being_dragged:
		highlight_domino(domino, false)
		var new_domino_hovered = raycast_check_for_domino()
		if new_domino_hovered:
			highlight_domino(new_domino_hovered, true)
		else:
			is_hovering_on_domino = false

func highlight_domino(domino, hovered):
	if hovered:
		domino.scale = Vector2(1.05, 1.05)
		domino.z_index = Z_INDEX_HOVERED
	else:
		domino.scale = Vector2(1,1)
		domino.z_index = Z_INDEX_NORMAL

func raycast_check_for_domino():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_DOMINO
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var top_domino = get_domino_with_highest_z_index(result)
		if top_domino and not top_domino.is_locked:
			return top_domino
	return null
	
func raycast_check_for_domino_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_DOMINO_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func get_domino_with_highest_z_index(dominos):
	var highest_z_domino = dominos[0].collider.get_parent()
	var highest_z_index = highest_z_domino.z_index
	for i in range(1, dominos.size()):
		var courrent_domino = dominos[i].collider.get_parent()
		if courrent_domino.z_index > highest_z_index:
			highest_z_domino = courrent_domino
	return highest_z_domino
