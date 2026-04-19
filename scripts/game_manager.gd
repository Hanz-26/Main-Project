extends Node

var score = 0
var checkpoint_pos: Vector2 = Vector2.ZERO
var lives: int = 5
var coin_count: int = 0

signal lives_changed(new_lives: int)
signal coins_changed(current: int, needed: int)

func _ready() -> void:
	add_to_group("game_manager")
	var player := get_tree().get_first_node_in_group("player")
	if player:
		checkpoint_pos = player.global_position

func add_point() -> void:
	score += 1
	coin_count += 1
	if coin_count >= 5 and lives < 5:
		coin_count -= 5
		lives += 1
		lives_changed.emit(lives)
	coins_changed.emit(coin_count, 5 - coin_count)

func set_checkpoint(pos: Vector2) -> void:
	checkpoint_pos = pos

func lose_life() -> void:
	lives = max(0, lives - 1)
	lives_changed.emit(lives)
