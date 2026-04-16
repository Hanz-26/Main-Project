extends Node

var score = 0
var checkpoint_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("game_manager")
	# Set spawn point as default checkpoint so scene never needs to reload
	var player := get_tree().get_first_node_in_group("player")
	if player:
		checkpoint_pos = player.global_position

func add_point() -> void:
	score += 1
	print(score)

func set_checkpoint(pos: Vector2) -> void:
	checkpoint_pos = pos
