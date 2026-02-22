extends Control

@onready var menu_selections: VBoxContainer = $main_menu_text/menu_selections
@onready var submenus: Control = $submenus
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
	#print(direction)
	
	#block below updates selection cursor and selected menu
	if direction != 0 and current_menu.name == "main_menu_text":
		if not movement_is_blocked:
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

	if Input.is_action_just_pressed("confirm"):
		if current_menu.name == "submenu_credits":
			self._ready()
		else:
			match selected_menu.name:
				"start_game": get_tree().change_scene_to_file("res://scenes/castle_level.tscn")
				"options": print("Selected menu: options")# TO BE FINISHED
				"exit_game": get_tree().quit()
				"credits": select_submenu_credits()

func select_submenu_credits():
	current_menu = submenus.get_node("submenu_credits")
	current_menu.visible = true
	self.get_node("main_menu_text").visible = false
	self.get_node("select_icon").visible = false
