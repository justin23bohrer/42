extends Control

var bidNum
var curBid
signal bid_made(result)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curBid = 30
	bidNum = curBid
func wait_for_bid():
	var result = await self.bid_made
	return result


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$ColorRect/bidNum.text = str(bidNum)
	if bidNum == curBid:
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
	emit_signal("bid_made", bidNum)


func _on_pass_pressed() -> void:
	emit_signal("bid_made", -1)
