extends Control

var bidNum
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bidNum = 30


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$ColorRect/bidNum.text = str(bidNum)
	if bidNum == 30:
		$ColorRect/left.visible = false
	else:
		$ColorRect/left.visible = true
	if bidNum == 42:
		$ColorRect/right.visible = false
	else:
		$ColorRect/right.visible = true


func _on_button_pressed() -> void:
	bidNum += 1


func _on_button_2_pressed() -> void:
	bidNum -= 1


func _on_sub_bid_pressed() -> void:
	pass # Replace with function body.


func _on_pass_pressed() -> void:
	pass # Replace with function body.
