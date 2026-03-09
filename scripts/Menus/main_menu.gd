extends Control

@onready var menu_selections: VBoxContainer = $main_menu_text/menu_selections
@onready var submenus: Control = $submenus
@onready var submenu_start_options = get_tree().get_nodes_in_group("submenu_start_options")# This is the group with the selectable options from the start submenu
var selected_menu_index = 0# start_game node
var selected_menu# menu selection node
var current_menu# menu node currently being displayed
var movement_is_blocked = false# this variable is to limit selection cursor speed

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
			if selected_menu_index < 3:
				selected_menu_index = 3
			else:
				selected_menu_index += 1
				selected_menu_index = 5 if selected_menu_index > 5 else selected_menu_index
		if direction < 0: #pressing up
			if selected_menu_index == 3:
				selected_menu_index = 0
			elif selected_menu_index > 3:
				selected_menu_index -= 1
		if h_direction != 0 and selected_menu_index < 3: #moving sideways between save files
			selected_menu_index += h_direction
			selected_menu_index = 0 if selected_menu_index < 0 else selected_menu_index
			selected_menu_index = 2 if selected_menu_index > 2 else selected_menu_index
		#code below updates select icon and selected_menu
		selected_menu = submenu_start_options[selected_menu_index]
		if selected_menu_index < 3:
			self.get_node("select_icon").global_position = selected_menu.global_position + Vector2(150,350)
		else:
			self.get_node("select_icon").global_position = selected_menu.global_position + Vector2(-25,0)
		movement_is_blocked = true
		await get_tree().create_timer(0.35).timeout	
		movement_is_blocked = false

	if Input.is_action_just_pressed("confirm"):
		await get_tree().create_timer(0.3).timeout	# I added this delay because for some reason the direction stays stuck for a split second when moving menus
		if current_menu.name == "submenu_start":#start menu
			if selected_menu.name == "submenu_start_back":
				self._ready()
		elif current_menu.name == "submenu_credits":#credits menu
			self._ready()
		elif current_menu.name == "submenu_options":#options menu
			if selected_menu.name == "options_back":
				self._ready()
		elif current_menu.name == "main_menu_text":#main menu
			match selected_menu.name:
				"start_game": select_submenu_start()# get_tree().change_scene_to_file("res://scenes/castle_level.tscn")
				"options": select_submenu_options()
				"exit_game": get_tree().quit()
				"credits": select_submenu_credits()

func select_submenu_credits():
	current_menu = submenus.get_node("submenu_credits")
	current_menu.visible = true
	self.get_node("main_menu_text").visible = false
	self.get_node("select_icon").visible = false

func select_submenu_options():
	current_menu.visible = false
	current_menu = submenus.get_node("submenu_options")
	current_menu.visible = true
	selected_menu = current_menu.get_node("options_selections/options_volume")
	selected_menu_index = 0
	self.get_node("select_icon").global_position = selected_menu.global_position + Vector2(-25,0)

func select_submenu_start():
	current_menu.visible = false
	current_menu = submenus.get_node("submenu_start")
	current_menu.visible = true
	selected_menu = submenu_start_options[0]# save file 1
	selected_menu_index = 0
	self.get_node("select_icon").global_position = selected_menu.global_position + Vector2(150,350)
	
