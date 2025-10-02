extends Node2D

const speed = 60
const CHASE_SPEED = 180
const LOS_MARGIN = 2.0

var direction = 1
var chasing = false
var player_ref = null

@onready var ray_cast_2d_right = $RayCast2DRight
@onready var ray_cast_2d_left = $RayCast2DLeft
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var vision = $Vision
@onready var vision_left = $VisionLeft
@onready var sight = $Sight

func _ready() -> void:
	vision.body_entered.connect(_on_vision_body_entered)
	vision.body_exited.connect(_on_vision_body_exited)
	vision_left.body_entered.connect(_on_vision_body_entered)
	vision_left.body_exited.connect(_on_vision_body_exited)
#called every frames. 'delta' is elapsed time since the previous frame.
func _process(delta):
	if chasing and player_ref:
		if not _has_line_of_sight_to_rc(player_ref):
			chasing = false
			player_ref = null
		else:
			var dir = sign(player_ref.global_position.x - global_position.x)
			_set_facing(dir)
			position.x += direction * CHASE_SPEED * delta
	else:
		if ray_cast_2d_right.is_colliding(): 
			var collider = ray_cast_2d_right.get_collider()
			if not (collider is CharacterBody2D):
				_set_facing(-1)
		if ray_cast_2d_left.is_colliding():
			var collider = ray_cast_2d_left.get_collider()
			if not (collider is CharacterBody2D):
				_set_facing(1)
	position.x += direction * speed * delta
	
func _on_vision_body_entered(body) -> void:
	if body is CharacterBody2D and _has_line_of_sight_to_rc(body):
		chasing = true
		player_ref = body
func _on_vision_body_exited(body) -> void:
	if body == player_ref:
		chasing = false
		player_ref = null
func _set_facing(dir: int) -> void:
	direction = dir
	animated_sprite_2d.flip_h = (dir < 0)
	vision.monitoring = (dir > 0)
	vision_left.monitoring = (dir < 0)
func _update_sight_to(target: Node2D) -> void:
	if not target: return
	var to = (target.global_position - global_position)
	var lens = max(0.0, to.length() - LOS_MARGIN)
	sight.target_position = to.normalized() * lens
	sight.force_raycast_update()
func _has_line_of_sight_to_rc(target: Node2D) -> bool:
	_update_sight_to(target)
	return not sight.is_colliding()
