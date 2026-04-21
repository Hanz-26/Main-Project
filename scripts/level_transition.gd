extends Control

var next_level = int(Global.save_files_slots[Global.active_save_file_index].get_value("Player", "level"))# this variable is the level to be loaded
#var next_level = 2# quick variable just for debugging

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Global.is_game_complete:# Transitiong levels
		self.get_node("transition_text").text = "Level " + str(next_level - 1) + " Complete"
		await get_tree().create_timer(3).timeout	
		go_to_level(next_level)
	else:# Finishing the game
		Global.is_game_complete = false
		self.get_node("transition_text").text = "Congratulations!!!\n\nYou saved the princess"
		await get_tree().create_timer(10).timeout	
		get_tree().change_scene_to_file("res://scenes/Menus/main_menu.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func go_to_level(i):
	print("now going to level ", i)
	match i:
		2: get_tree().change_scene_to_file("res://scenes/Levels/carlos_level.tscn")
		3: get_tree().change_scene_to_file("res://scenes/Levels/manuel_level.tscn")
		4: get_tree().change_scene_to_file("res://scenes/castle_level.tscn")
