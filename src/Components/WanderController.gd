extends Node2D

export(int) var WANDER_RANGE = 32
export(int) var STOP_WANDER_RANGE: = 4
export(float) var MIN_WANDER_INTERVAL: = 1
export(float) var MAX_WANDER_INTERVAL: = 3

onready var start_position = global_position
onready var target_position = global_position
onready var timer = $Timer
onready var done = true


func _ready():
	update_target_position()


func _on_Timer_timeout():
	update_target_position()
	done = true


func start_wander_timer():
	done = false
	timer.start(rand_range(MIN_WANDER_INTERVAL, MAX_WANDER_INTERVAL))


func done_wandering():
	return done # (timer.time_left == 0) # Not working, keeps cycling


func update_target_position():
	var target_vector = Vector2(rand_range(-WANDER_RANGE,WANDER_RANGE), rand_range(-WANDER_RANGE,WANDER_RANGE))
	target_position = start_position + target_vector

func is_within_target_range(global_position):
	return (global_position.distance_to(target_position) <= STOP_WANDER_RANGE)
