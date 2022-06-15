extends Area2D

const HitEffect = preload("res://src/Effects/HitEffect.tscn")

export(float) var INVINCIBILITY_DURATION = 0.1
export(bool) var HIT_EFFECT = true

var invincible = false setget set_invincible

onready var timer = $Timer

signal hurt(area)
signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if value == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")


func _on_Timer_timeout():
	self.invincible = false


func create_hit_effect():
	var hit_effect = HitEffect.instance()
	owner.add_child(hit_effect)


func _on_Hurtbox_area_entered(area):
	if not self.invincible:
		self.invincible = true
		emit_signal("hurt", area)
		timer.start(INVINCIBILITY_DURATION)
		if HIT_EFFECT:
			create_hit_effect()


func _on_Hurtbox_invincibility_started():
	set_deferred("monitoring", false)


func _on_Hurtbox_invincibility_ended():
	monitoring = true
