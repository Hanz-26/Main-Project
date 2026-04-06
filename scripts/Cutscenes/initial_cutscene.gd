extends Control

var text_index = 0# variable keeps track of narration text
var narration_text_list = [
	"Once upon a time,\n\nThere was a prince who fell in love with a princess\n
	Immediately they decided to get married and news of the wedding spread all throughout the land"
	,
	"But news of the union reached an evil wizard who had long wanted the princess all to himself\n
	Enraged, the wizard went to the castle to stop the prince"
	,
	"The wizard captured the princess and addressed the prince:\n
	\"The princess shall be mine and there is nothing you can do to stop me\"\n
	Then the wizard disappeared with the princess"
	,
	"Determined to save the princess at all costs, the prince set off for the wizard's castle",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_cutscene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("confirm"):
		update_cutscene()

func update_cutscene():
	match text_index - 1:# updates character to match scene
		1:# wizard appears
			self.get_node("characters/wizard").visible = true
		2:# wizard kidnaps princess
			self.get_node("characters/princess").global_position = self.get_node("characters/wizard").global_position + Vector2(-100, 10)
		3:# wizard and princess disappear
			self.get_node("characters/wizard").visible = false
			self.get_node("characters/princess").visible = false
	if text_index == 0:# startup screen
		self.get_node("CanvasLayer/background").visible = false
		self.get_node("CanvasLayer/black").visible = true
		self.get_node("characters").visible = false
		self.get_node("narration_text").visible = true
	else:# flips visibilities
		self.get_node("CanvasLayer/background").visible = !self.get_node("CanvasLayer/background").visible
		self.get_node("CanvasLayer/black").visible = !self.get_node("CanvasLayer/black").visible
		self.get_node("characters").visible = !self.get_node("characters").visible
		self.get_node("narration_text").visible = !self.get_node("narration_text").visible
	if text_index >= narration_text_list.size() and self.get_node("narration_text").visible == true:# last text, launch level
		get_tree().change_scene_to_file("res://scenes/castle_level.tscn")
	if self.get_node("narration_text").visible == true and text_index < narration_text_list.size():# checks if narration is shown
		self.get_node("narration_text").text = narration_text_list[text_index]
		text_index += 1
