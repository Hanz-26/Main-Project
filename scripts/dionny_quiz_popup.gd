extends CanvasLayer

signal quiz_completed

const CONFETTI_SCRIPT = preload("res://scripts/dionny_confetti.gd")

var _difficulty: String = "easy"
var _questions: Array = []
var _current_q: int = 0
var _answering: bool = false

@onready var progress_label: Label = $Panel/Margin/VBox/Progress
@onready var question_label: Label = $Panel/Margin/VBox/Question
@onready var feedback_label: Label = $Panel/Margin/VBox/Feedback
@onready var btn_a: Button = $Panel/Margin/VBox/Buttons/BtnA
@onready var btn_b: Button = $Panel/Margin/VBox/Buttons/BtnB
@onready var btn_c: Button = $Panel/Margin/VBox/Buttons/BtnC
@onready var celebrate_sound: AudioStreamPlayer = $CelebrateSound
@onready var player: CharacterBody2D = get_tree().current_scene.get_node("Player")

func start(diff: String) -> void:
	_difficulty = diff
	_questions = _generate_questions()
	_current_q = 0
	_show_question()

func _generate_questions() -> Array:
	var result: Array = []
	var used: Dictionary = {}
	while result.size() < 3:
		var q = _make_question()
		if not used.has(q.text):
			used[q.text] = true
			result.append(q)
	return result

func _make_question() -> Dictionary:
	var a: int
	var b: int
	var op: String
	var answer: int

	if _difficulty == "easy":
		a = randi_range(1, 5)
		b = randi_range(1, 5)
		op = "+"
		answer = a + b
	else:
		if randf() < 0.5:
			a = randi_range(4, 12)
			b = randi_range(3, 9)
			op = "+"
			answer = a + b
		else:
			a = randi_range(6, 15)
			b = randi_range(1, a - 1)
			op = "-"
			answer = a - b

	var wrongs: Array = []
	while wrongs.size() < 2:
		var offset = randi_range(1, 4) * (1 if randf() < 0.5 else -1)
		var w = answer + offset
		if w >= 0 and w != answer and w not in wrongs:
			wrongs.append(w)

	var choices = [answer] + wrongs
	choices.shuffle()

	return {"text": "%d %s %d = ?" % [a, op, b], "answer": answer, "choices": choices}

func _show_question() -> void:
	_answering = false
	var q = _questions[_current_q]
	progress_label.text = "Question %d of 3" % (_current_q + 1)
	question_label.text = q.text
	feedback_label.text = ""
	btn_a.text = str(q.choices[0])
	btn_b.text = str(q.choices[1])
	btn_c.text = str(q.choices[2])
	btn_a.disabled = false
	btn_b.disabled = false
	btn_c.disabled = false
	_answering = true

func _on_answer(idx: int) -> void:
	if not _answering:
		return
	_answering = false
	btn_a.disabled = true
	btn_b.disabled = true
	btn_c.disabled = true

	var q = _questions[_current_q]
	if q.choices[idx] == q.answer:
		_current_q += 1
		if _current_q >= 3:
			_celebrate()
			await get_tree().create_timer(2.2).timeout
			quiz_completed.emit()
			queue_free()
		else:
			feedback_label.modulate = Color(0.2, 0.9, 0.2, 1)
			feedback_label.text = "Correct! Keep going!"
			await get_tree().create_timer(0.6).timeout
			_show_question()
	else:
		var gm = get_tree().get_first_node_in_group("game_manager")
		if gm:
			gm.lose_life()
		#
		player.take_damage()#
		#get_tree().paused = false
		#self.get_node("../")._quiz_triggered = false
		#self.queue_free()
		#
		feedback_label.modulate = Color(1.0, 0.3, 0.3, 1)
		feedback_label.text = "Not quite! Try again."
		await get_tree().create_timer(1.0).timeout
		_questions = _generate_questions()
		_current_q = 0
		_show_question()

func _celebrate() -> void:
	feedback_label.modulate = Color(1.0, 0.85, 0.0, 1)
	feedback_label.text = "Amazing! You did it!"
	celebrate_sound.play()

	var confetti = Node2D.new()
	confetti.set_script(CONFETTI_SCRIPT)
	confetti.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(confetti)

	var panel = $Panel
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(panel, "scale", Vector2(1.18, 1.18), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)

func _on_btn_a_pressed() -> void:
	_on_answer(0)

func _on_btn_b_pressed() -> void:
	_on_answer(1)

func _on_btn_c_pressed() -> void:
	_on_answer(2)
