extends Node

var score = 0

@onready var ui: CanvasLayer = $"../UI"

func add_point():
	score += 1
	print(score)
	ui.get_node("Coins").text = "Coins: " + str(score)
