extends Control

@onready var menu_selections: VBoxContainer = $main_menu_text/menu_selections
@onready var submenus: Control = $submenus
@onready var submenu_start_options = get_tree().get_nodes_in_group("submenu_start_options")# This is the group with the selectable options from the start submenu
var selected_menu_index = 0# start_game node
var selected_menu# menu selection node
var current_menu# menu node currently being displayed
var movement_is_blocked = false# this variable is to limit selection cursor speed
var selected_save_file# this variable hold the integer (0, 1, 2) save file that was selected in submenu_start

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_menu = self.get_node("main_menu_text")
	current_menu.visible = true
	selected_menu_index = 0# hide to keep cursor memory
	selected_menu = menu_selections.get_child(selected_menu_index)# start_game node at startup
	self.get_node("select_icon").visible = true
	self.get_node("select_icon").global_position = selected_menu.global_position + Vector2(-25,0)
	for n in submenus.get_children():
		n.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
# All movement within menus and user input is handled within this function
func _process(delta: float) -> void:
	var direction := Input.get_axis("move_up", "move_down")
	var h_direction := Input.get_axis("move_left", "move_right")
	#print(direction)
	
	#Main Menu - block below updates selection cursor and selected menu
	if direction != 0 and current_menu.name == "main_menu_text" and not movement_is_blocked:
		selected_menu_index += direction
		if selected_menu_index > 4:
			selected_menu_index = 0
		elif selected_menu_index < 0:
			selected_menu_index = 4
		if selected_menu_index == 3:# empty_space node
			selected_menu_index += direction
		selected_menu = menu_selections.get_child(selected_menu_index)
		#print("Selected menu is: ", selected_menu.text)
		self.get_node("select_icon").global_position = selected_menu.global_position + Vector2(-25,0)
		#Lines below prevent constant cursor movement
		movement_is_blocked = true
		await get_tree().create_timer(0.35).timeout	
		movement_is_blocked = false
	
	#Options Menu
	if direction != 0 and current_menu.name == "submenu_options" and not movement_is_blocked:
		selected_menu_index += direction
		if selected_menu_index > 2:
			selected_menu_index = 0
		elif selected_menu_index < 0:
			selected_menu_index = 2
		# the last menu is options_back which is not a child of options_selections
		if selected_menu_index == 2:
			selected_menu = current_menu.get_node("options_back")
		else:
			selected_menu = current_menu.get_node("options_selections").get_child(selected_menu_index)
		self.get_node("select_icon").global_position = selected_menu.global_position + Vector2(-25,0)
		movement_is_blocked = true
		await get_tree().create_timer(0.35).timeout	
		movement_is_blocked = false
	#Options Menu adjusting volume or brightness
	if h_direction != 0 and current_menu.name == "submenu_options" and not movement_is_blocked:
		if (selected_menu.name) == "options_volume" or (selected_menu.name) == "options_brightness":
			var settings_val = 0
			# if else below is for adjusting volume or brightness bar
			if h_direction > 0:
				for n in selected_menu.get_child(0).get_children():
					if n.visible == false:
						n.visible = true
						break
			else:
				for n in selected_menu.get_child(0).get_children():
					if n.visible == true:
						n.visible = false
						break
			# Code below counts how many squares in selected setting are visible and adds it to settings_val
			for n in selected_menu.get_child(0).get_children():
					if n.visible == true:
						settings_val += 0.1
			# code below sets global brightness to settings_val
			if selected_menu.name == "options_brightness":
				if settings_val == 0:
					settings_val = 0.05
				Global_World_Environment.environment.adjustment_brightness = settings_val
			else:# code below adjusts master volume
				var bus_index = AudioServer.get_bus_index("Master")# Master audio bus
				AudioServer.set_bus_volume_db(bus_index, linear_to_db(settings_val**2))# settings_val is squared for steeper curve

		movement_is_blocked = true
		await get_tree().create_timer(0.25).timeout	
		movement_is_blocked = false
	#code below handles submenu_start
	if (direction != 0 or h_direction != 0) and current_menu.name == "submenu_start" and not movement_is_blocked:
		if direction > 0: #pressing down
			selected_menu_index = 3
		if direction < 0: #pressing up
			if selected_menu_index == 3:
				selected_menu_index = 0
		if h_direction != 0 and selected_menu_index < 3: #moving sideways between save files
			selected_menu_index += h_direction
			selected_menu_index = 0 if selected_menu_index < 0 else selected_menu_index
			selected_menu_index = 2 if selected_menu_index > 2 else selected_menu_index
		#code below updates select icon and selected_menu
		selected_menu = submenu_start_options[selected_menu_index]
		if selected_menu_index < 3:
			self.get_node("select_icon").global_position = selected_menu.get_node("Panel").global_position + Vector2(130,335)
		else:
			self.get_node("select_icon").global_position = selected_menu.global_position + Vector2(-25,0)
		movement_is_blocked = true
		await get_tree().create_timer(0.35).timeout	
		movement_is_blocked = false
	#code below handles selecting a file within submenu start
	if (direction != 0 or h_direction != 0) and current_menu.name == "file_selection_options" and not movement_is_blocked:
		if direction != 0:
			selected_menu_index += direction
		selected_menu_index = 3 if selected_menu_index < 0 else selected_menu_index
		selected_menu_index = 0 if selected_menu_index > 3 else selected_menu_index
		selected_menu = current_menu.get_child(selected_menu_index)
		self.get_node("select_icon").global_position = selected_menu.global_position + Vector2(375, 0)
		movement_is_blocked = true
		await get_tree().create_timer(0.35).timeout	
		movement_is_blocked = false
	#code below handles deleting a file within submenu_start
	if (direction != 0 or h_direction != 0) and current_menu.name == "save_file_delete_box" and not movement_is_blocked:
		if h_direction != 0:
			selected_menu_index += h_direction
			selected_menu_index = 0 if selected_menu_index < 0 else selected_menu_index
			selected_menu_index = 1 if selected_menu_index > 1 else selected_menu_index
			selected_menu = current_menu.get_node("delete_options").get_child(selected_menu_index)
			self.get_node("select_icon").global_position = selected_menu.global_position + Vector2(-28, 0)	
			movement_is_blocked = true
			await get_tree().create_timer(0.35).timeout	
			movement_is_blocked = false
	#code below handles copying a file within submenu_start
	if (direction != 0 or h_direction != 0) and current_menu.name == "save_file_copy_box" and not movement_is_blocked:
		if current_menu.get_node("copy_confirmation").visible == false:
			if direction > 0: #pressing down
				selected_menu_index = 3
			if direction < 0: #pressing up
				if selected_menu_index == 3:
					selected_menu_index = 0
			if h_direction != 0 and selected_menu_index < 3: #moving sideways between save files
				selected_menu_index += h_direction
				selected_menu_index = 0 if selected_menu_index < 0 else selected_menu_index
				selected_menu_index = 2 if selected_menu_index > 2 else selected_menu_index
			#code below updates select icon and selected_menu
			selected_menu = submenu_start_options[selected_menu_index]
			if selected_menu_index < 3:
				self.get_node("select_icon").global_position = selected_menu.get_node("Panel").global_position + Vector2(130,335)
			else:
				self.get_node("select_icon").global_position = selected_menu.global_position + Vector2(-25,0)
		else:# Copy confirmation section
			if h_direction != 0:
				selected_menu_index += h_direction
				selected_menu_index = 0 if selected_menu_index < 0 else selected_menu_index
				selected_menu_index = 1 if selected_menu_index > 1 else selected_menu_index
				selected_menu = current_menu.get_node("copy_confirmation").get_child(selected_menu_index)
				self.get_node("select_icon").global_position = selected_menu.global_position + Vector2(-25, 0)	
		movement_is_blocked = true
		await get_tree().create_timer(0.35).timeout	
		movement_is_blocked = false

	if Input.is_action_just_pressed("confirm"):
		if current_menu.name == "submenu_start":#start menu
			if selected_menu.name == "submenu_start_back":# Back to main menu
				self._ready()
			elif selected_menu in submenu_start_options:# Selecting a save file
				selected_save_file = str(selected_menu.name)[-1]
				select_file(selected_menu)
		elif current_menu.name == "file_selection_options":# selecting an option after selecting a save file
			match selected_menu.name:
				"save_file_start": save_file_start(selected_save_file)# start game
				"save_file_copy": save_file_copy()# copy save to another slot
				"save_file_delete": save_file_delete()# delete file
				"save_file_cancel": select_submenu_start()# cancel selection
		elif current_menu.name == "save_file_delete_box":# selecting to delete a save file
			if selected_menu.name == "delete_yes":
				Global.delete_file(selected_save_file)
			select_submenu_start()
		elif current_menu.name == "save_file_copy_box":# selecting to copy a save file
			if selected_menu.name == "copy_yes":
				Global.copy_file(int(selected_save_file), int(str(current_menu.get_node("copy_prompt").text)[-2]) - 1)
				select_submenu_start()
			elif selected_menu.name == "copy_no":
				select_submenu_start()
			elif selected_menu.name == "submenu_start_back":# reset start menu
				select_submenu_start()
			elif str(selected_menu.name)[-1] == selected_save_file:# attempt to overwrite same file
				print("ERROR: Can't overwrite same save file")# FIXME Add error sound effect
			elif str(selected_menu.name)[-1] != selected_save_file:# file copy confirmation
				current_menu.get_node("copy_prompt").text = "Copy save " + str(int(selected_save_file) + 1) + " to " + str(int(selected_menu_index) + 1) + "?"
				current_menu.get_node("copy_confirmation").visible = true
				selected_menu_index = 0
				selected_menu = current_menu.get_node("copy_confirmation").get_child(selected_menu_index)
				self.get_node("select_icon").global_position = Vector2(413.0, 477.2728)	
		elif current_menu.name == "submenu_credits":#credits menu
			self._ready()
		elif current_menu.name == "submenu_options":#options menu
			if selected_menu.name == "options_back":
				self._ready()
		elif current_menu.name == "main_menu_text":#main menu
			match selected_menu.name:
				"start_game": select_submenu_start()
				"options": select_submenu_options()
				"exit_game": get_tree().quit()
				"credits": select_submenu_credits()

func select_submenu_credits():
	current_menu = submenus.get_node("submenu_credits")
	current_menu.visible = true
	self.get_node("main_menu_text").visible = false
	self.get_node("select_icon").visible = false

func select_submenu_options():
	movement_is_blocked = true
	await get_tree().create_timer(0.35).timeout	
	movement_is_blocked = false
	current_menu.visible = false
	current_menu = submenus.get_node("submenu_options")
	current_menu.visible = true
	selected_menu = current_menu.get_node("options_selections/options_volume")
	selected_menu_index = 0
	self.get_node("select_icon").global_position = selected_menu.global_position + Vector2(-25,0)

func select_submenu_start():
	movement_is_blocked = true
	await get_tree().create_timer(0.35).timeout	
	movement_is_blocked = false
	current_menu.visible = false
	current_menu = submenus.get_node("submenu_start")
	current_menu.visible = true
	selected_menu = submenu_start_options[0]# save file 1
	selected_menu_index = 0
	self.get_node("select_icon").global_position = selected_menu.get_node("Panel").global_position + Vector2(130,335)
	
	#Loads save file info and displays it
	for i in range(3):
		if Global.save_files_slots[i] == null:# Empty slot
			submenu_start_options[i].get_node("Panel/new_game").visible = true
			submenu_start_options[i].get_node("Panel/save_file_info").visible = false
		else:# Displays save file data
			submenu_start_options[i].get_node("Panel/new_game").visible = false
			submenu_start_options[i].get_node("Panel/save_file_info").visible = true
			var disk_save_data = Global.save_files_slots[i]
			var save_file_info = submenu_start_options[i].get_node("Panel/save_file_info")
			save_file_info.get_node("lives_count/lives_label").text = "x" + str(disk_save_data.get_value("Player", "lives"))
			save_file_info.get_node("coins_count/coins_counter").text = "x" + str(disk_save_data.get_value("Player", "coins"))
			save_file_info.get_node("level_info/level_name").text = "Level " + str(disk_save_data.get_value("Player", "level"))

func select_file(save_file):# This is called when pressing Enter on a save file
	movement_is_blocked = true
	await get_tree().create_timer(0.35).timeout	
	movement_is_blocked = false
	if save_file.get_node("Panel/new_game").visible:# If save empty save file and launch first level
		Global.save_file(selected_save_file)
		save_file_start(selected_save_file)
		#get_tree().change_scene_to_file("res://scenes/castle_level.tscn")
	else:
		current_menu = current_menu.get_node("file_selection_options")
		current_menu.visible = true
		selected_menu_index = 0
		selected_menu = current_menu.get_child(0)
		self.get_node("select_icon").global_position = selected_menu.global_position + Vector2(375, 0)	

func save_file_delete():
	current_menu.visible = false
	current_menu = current_menu.get_node("../save_file_delete_box")
	current_menu.visible = true
	current_menu.get_node("delete_confirmation").text = "Are you sure want to delete file " + str(int(selected_save_file) + 1)
	selected_menu_index = 0
	selected_menu = current_menu.get_node("delete_options/delete_yes")
	self.get_node("select_icon").global_position = Vector2(410.0, 440.9091)	

func save_file_copy():
	movement_is_blocked = true
	await get_tree().create_timer(0.35).timeout	
	movement_is_blocked = false
	current_menu.visible = false
	current_menu = current_menu.get_node("../save_file_copy_box")
	current_menu.visible = true
	current_menu.get_node("copy_prompt").text = "Select file to overwrite"
	current_menu.get_node("copy_confirmation").visible = false
	selected_menu = submenu_start_options[0]# save file 1
	selected_menu_index = 0
	self.get_node("select_icon").global_position = selected_menu.get_node("Panel").global_position + Vector2(130,335)

func save_file_start(save_index):#starts the game from the selected save
	Global.active_save_file_index = int(save_index)# This keeps track in global of which save file is currently active
	var save_file_level = Global.save_files_slots[int(save_index)].get_value("Player", "level")
	match save_file_level:
		1: get_tree().change_scene_to_file("res://scenes/Cutscenes/initial_cutscene.tscn")
		2: print("launch level 2")
