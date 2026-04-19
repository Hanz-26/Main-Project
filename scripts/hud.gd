extends CanvasLayer

@onready var heart1: Label = $HBox/Heart1
@onready var heart2: Label = $HBox/Heart2
@onready var heart3: Label = $HBox/Heart3
@onready var heart4: Label = $HBox/Heart4
@onready var heart5: Label = $HBox/Heart5
@onready var coin_label: Label = $HBox/CoinLabel

const COLOR_FULL = Color(0.95, 0.15, 0.15, 1)
const COLOR_LOST = Color(0.15, 0.15, 0.15, 1)

var _hearts: Array

func _ready() -> void:
	_hearts = [heart1, heart2, heart3, heart4, heart5]
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		gm.lives_changed.connect(_on_lives_changed)
		gm.coins_changed.connect(_on_coins_changed)
		_on_lives_changed(gm.lives)
		_on_coins_changed(gm.coin_count, 5 - gm.coin_count)

func _on_lives_changed(new_lives: int) -> void:
	for i in _hearts.size():
		_hearts[i].modulate = COLOR_FULL if i < new_lives else COLOR_LOST

func _on_coins_changed(current: int, needed: int) -> void:
	coin_label.text = "  %d / %d coins" % [current, current + needed]
