extends Node2D

## QUIZ BOSS - Displays a math quiz when player approaches
## Correct answer = boss dies. Wrong answer = lose a heart.

const SPEED = 40
var direction = -1
var move_range = 80.0
var start_x = 0.0
var boss_lives = 1  # Dies in one correct answer
var quiz_active = false
var player_in_zone = false

@onready var animated_sprite = $AnimatedSprite2D

# Quiz data: [question, [answers], correct_index]
var quiz_questions = [
	# Order of operations
	["What is 8 + 3 x 4?", ["44", "20", "32", "24"], 1],
	["What is (12 - 5) x 6?", ["42", "36", "48", "30"], 0],
	["What is 50 - 4 x 9?", ["14", "414", "18", "9"], 0],
	# Exponents
	["What is 2^5?", ["16", "64", "32", "25"], 2],
	["What is 3^3 - 10?", ["17", "19", "21", "27"], 0],
	["What is 5^2 + 4^2?", ["41", "45", "36", "81"], 0],
	# Fractions & decimals
	["What is 3/4 + 1/2?", ["1", "5/4", "4/6", "1/1"], 1],
	["What is 0.75 x 8?", ["5", "6.5", "7", "6"], 3],
	["What is 7/8 - 3/8?", ["4/8", "1/2", "4/16", "Both A and B"], 3],
	# Harder multiplication
	["What is 13 x 12?", ["144", "156", "168", "132"], 1],
	["What is 17 x 6?", ["96", "112", "102", "108"], 2],
	["What is 25 x 25?", ["525", "650", "625", "600"], 2],
	# Multi-step
	["What is (15 + 9) / (12 - 4)?", ["4", "2", "6", "3"], 3],
	["What is 100 / 4 - 3 x 5?", ["10", "15", "5", "20"], 0],
	["What is 2^4 + 3^2?", ["25", "21", "23", "19"], 0],
	# Algebra concepts
	["If x + 7 = 15, what is x?", ["7", "9", "8", "22"], 2],
	["If 3x = 27, what is x?", ["3", "81", "9", "24"], 2],
	["If x^2 = 49, what is x?", ["6", "8", "7", "24.5"], 2],
]

var current_question = null
var quiz_ui = null
var game_manager = null
var player_node = null

func _ready():
	start_x = position.x
	if animated_sprite:
		animated_sprite.play("idle")
		# Reset sprite position - let the Node2D position handle placement
		animated_sprite.position = Vector2(0, 0)

	game_manager = get_tree().current_scene.get_node_or_null("GameManager")
	if not game_manager:
		game_manager = get_tree().current_scene.get_node_or_null("Game Manager")
	player_node = get_tree().current_scene.get_node_or_null("Player")

	# Create trigger zone around the boss
	var trigger = Area2D.new()
	trigger.name = "QuizTrigger"
	trigger.collision_layer = 0
	trigger.collision_mask = 2  # Detect player
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(160, 100)  # Large detection zone
	shape.shape = rect
	shape.position = Vector2(0, -15)
	trigger.add_child(shape)
	add_child(trigger)
	trigger.body_entered.connect(_on_player_entered)
	trigger.body_exited.connect(_on_player_exited)

func _process(delta):
	if quiz_active:
		return  # Don't move during quiz

	position.x += direction * SPEED * delta

	if position.x > start_x + move_range:
		direction = -1
	elif position.x < start_x - move_range:
		direction = 1

	if animated_sprite:
		if direction == -1:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true

func _on_player_entered(body: Node2D) -> void:
	if body.name == "Player" and not quiz_active:
		player_in_zone = true
		show_quiz()

func _on_player_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_zone = false

func show_quiz():
	quiz_active = true

	# Freeze the player
	if player_node:
		player_node.set_physics_process(false)

	# Freeze ALL enemies in the scene
	get_tree().paused = false  # Make sure tree isn't paused first
	for node in get_tree().get_nodes_in_group("enemies"):
		node.set_process(false)
	# Also freeze all slimes and other Node2D enemies by finding them
	for node in get_tree().current_scene.get_children():
		if "lime" in node.name or "Slime" in node.name:
			node.set_process(false)
	# Check inside containers too
	for container_name in ["CaveSection", "ThirdFloor", "BossArea", "MiniBosses"]:
		var container = get_tree().current_scene.get_node_or_null(container_name)
		if container:
			for child in container.get_children():
				if child.has_method("_process") and child != self:
					child.set_process(false)

	# Pick a random question
	current_question = quiz_questions[randi() % quiz_questions.size()]

	# Create quiz UI
	var canvas = player_node.get_node_or_null("UI")
	if not canvas:
		return

	# Remove old quiz UI
	var old_quiz = canvas.get_node_or_null("QuizUI")
	if old_quiz:
		old_quiz.queue_free()

	quiz_ui = ColorRect.new()
	quiz_ui.name = "QuizUI"
	quiz_ui.color = Color(0, 0, 0.1, 0.85)
	quiz_ui.anchor_right = 1.0
	quiz_ui.anchor_bottom = 1.0
	canvas.add_child(quiz_ui)

	var font = load("res://assets/fonts/PixelOperator8-Bold.ttf")
	if not font:
		font = load("res://assets/fonts/PixelOperator8.ttf")

	# Title
	var title = Label.new()
	title.text = "BOSS CHALLENGE!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.anchor_left = 0.2
	title.anchor_right = 0.8
	title.anchor_top = 0.08
	title.anchor_bottom = 0.15
	if font:
		title.add_theme_font_override("font", font)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0))
	quiz_ui.add_child(title)

	# Question
	var q_label = Label.new()
	q_label.text = current_question[0]
	q_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	q_label.anchor_left = 0.1
	q_label.anchor_right = 0.9
	q_label.anchor_top = 0.22
	q_label.anchor_bottom = 0.35
	if font:
		q_label.add_theme_font_override("font", font)
	q_label.add_theme_font_size_override("font_size", 16)
	q_label.add_theme_color_override("font_color", Color(1, 1, 1))
	quiz_ui.add_child(q_label)

	# Answer buttons (4 choices)
	var answers = current_question[1]
	var button_positions = [
		[0.15, 0.42, 0.48, 0.52],  # A - top left
		[0.52, 0.42, 0.85, 0.52],  # B - top right
		[0.15, 0.58, 0.48, 0.68],  # C - bottom left
		[0.52, 0.58, 0.85, 0.68],  # D - bottom right
	]
	var letters = ["A", "B", "C", "D"]

	for i in range(4):
		var btn = Button.new()
		btn.name = "Answer_%d" % i
		btn.text = "%s) %s" % [letters[i], answers[i]]
		btn.anchor_left = button_positions[i][0]
		btn.anchor_top = button_positions[i][1]
		btn.anchor_right = button_positions[i][2]
		btn.anchor_bottom = button_positions[i][3]
		if font:
			btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 12)
		btn.pressed.connect(_on_answer_pressed.bind(i))
		quiz_ui.add_child(btn)

	# Hint text
	var hint = Label.new()
	hint.text = "Click the correct answer!"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.anchor_left = 0.2
	hint.anchor_right = 0.8
	hint.anchor_top = 0.78
	hint.anchor_bottom = 0.85
	if font:
		hint.add_theme_font_override("font", font)
	hint.add_theme_font_size_override("font_size", 8)
	hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	quiz_ui.add_child(hint)

func _on_answer_pressed(answer_index: int):
	var correct_index = current_question[2]

	if answer_index == correct_index:
		# CORRECT! Boss dies
		print("Correct answer! Boss defeated!")
		show_result("CORRECT!", Color(0, 1, 0.3))
		await get_tree().create_timer(1.5).timeout
		close_quiz()

		# Kill the boss
		if animated_sprite:
			animated_sprite.modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.5).timeout
		queue_free()
	else:
		# WRONG! Lose a heart
		print("Wrong answer! Lost a heart!")
		show_result("WRONG! Try again!", Color(1, 0.2, 0.2))
		if game_manager:
			game_manager.take_damage()
		await get_tree().create_timer(1.5).timeout

		# Check if player is dead
		if game_manager and game_manager.hearts <= 0:
			close_quiz()
			return

		# Show a new question
		close_quiz()
		if player_in_zone:
			show_quiz()

func show_result(text: String, color: Color):
	if not quiz_ui:
		return
	# Remove old result
	var old = quiz_ui.get_node_or_null("Result")
	if old:
		old.queue_free()

	var result = Label.new()
	result.name = "Result"
	result.text = text
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.anchor_left = 0.2
	result.anchor_right = 0.8
	result.anchor_top = 0.85
	result.anchor_bottom = 0.95
	var font = load("res://assets/fonts/PixelOperator8-Bold.ttf")
	if font:
		result.add_theme_font_override("font", font)
	result.add_theme_font_size_override("font_size", 16)
	result.add_theme_color_override("font_color", color)
	quiz_ui.add_child(result)

func close_quiz():
	quiz_active = false
	if player_node:
		player_node.set_physics_process(true)
	if quiz_ui:
		quiz_ui.queue_free()
		quiz_ui = null

	# Unfreeze ALL enemies
	for node in get_tree().current_scene.get_children():
		if "lime" in node.name or "Slime" in node.name:
			node.set_process(true)
	for container_name in ["CaveSection", "ThirdFloor", "BossArea", "MiniBosses"]:
		var container = get_tree().current_scene.get_node_or_null(container_name)
		if container:
			for child in container.get_children():
				if child.has_method("_process"):
					child.set_process(true)

func enemy_take_damage():
	# Sword doesn't kill quiz bosses - quiz does
	print("This boss can only be defeated by answering the quiz!")
