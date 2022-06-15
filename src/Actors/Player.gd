extends "res://src/Actors/Actor.gd"

const PlayerHurtSound = preload("res://src/Effects/PlayerHurtSound.tscn")

onready var animation_player = $AnimationPlayer
onready var blink_animation_player = $BlinkAnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var sword_hitbox = $HitboxPivot/SwordHitbox

const ROLL_SPEED: = 120

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var roll_vector = Vector2.DOWN
var stats = PlayerStats

func _ready():
	randomize() # Randomizes the world seed
	stats.connect("no_health", self, "queue_free")
	animation_tree.active = true


func _physics_process(delta):
	var direction: = get_direction()


	match state:
		MOVE:
			move_state(delta, direction)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()


func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()


func move_state(delta: float, direction: Vector2):
	_velocity = calculate_move_velocity(_velocity, delta, direction, ACCELERATION, MAX_SPEED)
	move(_velocity)
	update_animation(direction)


func calculate_move_velocity(
		linear_velocity: Vector2,
		delta: float,
		direction: Vector2,
		acceleration: float,
		max_speed: float
	) -> Vector2:
	var out: = linear_velocity
	
	if direction != Vector2.ZERO:
		out = out.move_toward(direction * max_speed, acceleration * delta)
	else:
		out = out.move_toward(Vector2.ZERO, FRICTION * delta)
	
	return out


func roll_state():
	_velocity = roll_vector * ROLL_SPEED
	move(_velocity)
	animation_state.travel("Roll")


func roll_animation_finished():
	state = MOVE

func move(velocity : Vector2):
	#move_and_collide(velocity * delta) # Sticks on the walls
	velocity = move_and_slide(velocity) # Handles delta by itself


func attack_state():
	_velocity = Vector2.ZERO
	animation_state.travel("Attack")


func attack_animation_finished():
	_velocity = _velocity * 0.3
	state = MOVE


func update_animation(direction: Vector2):
	if direction != Vector2.ZERO:
		roll_vector = direction
		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Run/blend_position", direction)
		animation_tree.set("parameters/Attack/blend_position", direction) # Written here to keep direction
		animation_tree.set("parameters/Roll/blend_position", direction) # Written here to keep direction
		animation_state.travel("Run")
	else:
		animation_state.travel("Idle")
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	elif Input.is_action_just_pressed("roll"):
		state = ROLL

func _on_Hurtbox_hurt(area):
	stats.health -= area.damage
	var player_hurt_sound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(player_hurt_sound)


func _on_Hurtbox_invincibility_started():
	blink_animation_player.play("Start")


func _on_Hurtbox_invincibility_ended():
	blink_animation_player.play("Stop")
