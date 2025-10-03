extends CanvasLayer

var score = 0

@onready var score_label = $Control/ScoreLabel

func current_score():
	score += 100
	score_label.text = "Current score: " + str(score)
