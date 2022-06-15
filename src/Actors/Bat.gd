extends "res://src/Actors/Enemy.gd"

const EnemyDeathEffect = preload("res://src/Effects/EnemyDeathEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

var knockback = Vector2.ZERO
var soft_knockback = Vector2.ZERO

var state = IDLE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var player_detection_area = $PlayerDetectionArea
onready var soft_collision = $SoftCollision
onready var wander_controller = $WanderController
onready var blink_animation_player = $BlinkAnimationPlayer

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			idle_state(delta)
			update_state()
		WANDER:
			wander_state(delta)
			update_state()
		CHASE:
			chase_state(delta)

	soft_knockback = soft_collision.get_push_vector()
	if soft_knockback != Vector2.ZERO:
		_velocity += soft_knockback * delta * SOFT_KNOCKBACK_STRENGTH
	_velocity = move_and_slide(_velocity)


func idle_state(delta):
	# Srop movement
	_velocity = _velocity.move_toward(Vector2.ZERO, FRICTION * delta)


func wander_state(delta):
	# Move towards "wander_controller.target_position"
	accelerate_towards_point(wander_controller.target_position, delta)
	
	# Stop if gets close
	if wander_controller.is_within_target_range(global_position):
		state = IDLE


func chase_state(delta):
	var player = player_detection_area.player
	if player:
		accelerate_towards_point(player.global_position, delta)
	else:
		state = IDLE


func update_state():
	if player_detection_area.can_see_player():
		# Chasing player
		state = CHASE
	elif state == CHASE:
		# Done chasing, going back
		state = WANDER
		wander_controller.start_wander_timer()
	elif wander_controller.done_wandering():
		# Idling or wandering
		state = pick_random_state([IDLE, WANDER])
		wander_controller.start_wander_timer()


func accelerate_towards_point(point, delta):
	var distance = global_position.direction_to(point)
	_velocity = _velocity.move_toward(distance * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = _velocity.x < 0


func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()


func _on_Hurtbox_hurt(area):
	stats.health -= area.damage
	knockback = calculate_knockback(area)


func calculate_knockback(area):
	var distance = self.global_position - area.owner.global_position
	return distance.normalized() * area.knockback


func _on_Stats_no_health():
	create_enemy_death_effect()
	queue_free()


func create_enemy_death_effect():
	var enemy_death_effect = EnemyDeathEffect.instance()
	get_parent().add_child(enemy_death_effect)
	enemy_death_effect.position = self.position


func _on_Hurtbox_invincibility_started():
	blink_animation_player.play("Start")


func _on_Hurtbox_invincibility_ended():
	blink_animation_player.play("Stop")
