extends Node

var active_spawn #This variable holds the node that is the current checkpoint
var save_files_slots = []# This variable holds all three save files, null if empty
var active_save_file_index# This variable holds the index of the save file selected in main menu to start game
var save_files_address = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/My Games/LevelBreaker/Saves"# Address for save files, first part gets documents folder

var is_game_complete = false# This variable is set to true by finishing the last level, and set back to false by the level_transition scene

func _init():
	DirAccess.make_dir_recursive_absolute(save_files_address)# Checks folder exists, creates missing folders if necessary
	load_files()
	#save_file(0)
	#save_file(1)
	#save_file(2)

func load_files():# Loads save files from memory into array
	save_files_slots = []
	for i in range(3):
		var file_data = ConfigFile.new()
		var file_status = file_data.load(save_files_address + "/save_data_" + str(i) + ".cfg")# 0 = File found; 7 = File not found
		if file_status == 0:# Save file found
			save_files_slots.push_back(file_data)
		else:# Save file not found
			save_files_slots.push_back(null)

#func save_file(i, file_level = 1, file_lives = 3, file_coins = 0):# i = save file index (0,1,2)
func save_file(file_level = 1, file_lives = 3, file_coins = 0, i = active_save_file_index):# i = save file index (0,1,2)
	var file_data = ConfigFile.new()
	
	file_data.set_value("Player", "level", file_level)
	file_data.set_value("Player", "lives", file_lives)
	file_data.set_value("Player", "coins", file_coins)
	
	file_data.save(save_files_address + "/save_data_" + str(i) + ".cfg")
	load_files()

func delete_file(i):
	print("Save ", i, " deleted")
	save_files_slots[int(i)] = null
	DirAccess.remove_absolute(save_files_address + "/save_data_" + str(i) + ".cfg")

func copy_file(orig, dest):
	var file_data = save_files_slots[orig]
	var copy_level = file_data.get_value("Player", "level")
	var copy_lives = file_data.get_value("Player", "lives")
	var copy_coins = file_data.get_value("Player", "coins")
	
	save_file(copy_level, copy_lives, copy_coins, dest)
	load_files()
