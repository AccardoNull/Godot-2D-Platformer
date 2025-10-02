extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	# Ignore kill zone during rolling animation
	if body.has_method("is_invincible_active") and body.is_invincible_active():
		return
	print("Game Over...")
	if body.has_node("DeathSFX"):
		body.get_node("DeathSFX").play()
	Engine.time_scale = 0.3
	body.get_node("CollisionShape2D").queue_free()
	timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()
