extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

# --- ROLL ADDITIONS (tweak to taste) ---
const ROLL_SPEED = 170.0     # horizontal roll speed
const ROLL_TIME = 0.30      # duration of the roll
const ROLL_COOLDOWN = 0.15      # small buffer before next roll
const IFRAMES_TIME = 0.26

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var jump_sfx = $JumpSFX
@onready var roll_sfx = $RollSFX

# --- ROLL STATE ---
var is_rolling: bool = false
var can_roll: bool = true
var last_facing: int  = 1              # 1 = right, -1 = left
var is_invincible : bool = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# --- If we're currently rolling: lock movement and count down ---
	if is_rolling:
		velocity.x = last_facing * ROLL_SPEED
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()

	# direction value -1, 0 ,1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip sprite
	if direction > 0: 
		animated_sprite_2d.flip_h = false
		last_facing = 1
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		last_facing = -1
	
		# Start roll if key pressed and grounded
	if Input.is_action_just_pressed("roll") and can_roll and is_on_floor(): 
		_start_roll()
		return

		
	# Animations
	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")
			
	# movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
# --- ROLL HELPERS ---
func _start_roll() -> void:
	is_rolling = true
	can_roll = false
	animated_sprite_2d.play("roll")
	roll_sfx.play()
	_set_invincible(true)
	get_tree().create_timer(ROLL_TIME).timeout.connect(func ():
		_end_roll()
	)
	get_tree().create_timer(ROLL_TIME + ROLL_COOLDOWN).timeout.connect(func ():
		can_roll = true
	)
	get_tree().create_timer(IFRAMES_TIME).timeout.connect(func ():
		if is_rolling:
			_set_invincible(false)
	)
func _end_roll() -> void:
	is_rolling = false
	_set_invincible(false)
func _set_invincible(on: bool) -> void:
	is_invincible = on
func is_invincible_active() -> bool:
	return is_invincible
