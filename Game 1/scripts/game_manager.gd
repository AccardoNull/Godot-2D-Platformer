extends Node

var score = 0

@onready var coin_label = $CoinLabel

func add_score():
	score += 1
	coin_label.text = "Coins Collected: " + str(score)
