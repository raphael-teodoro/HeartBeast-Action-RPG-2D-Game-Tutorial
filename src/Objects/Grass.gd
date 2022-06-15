extends Node2D

const GrassCutEffect = preload("res://src/Effects/GrassCutEffect.tscn")

onready var stats = $Stats

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage

func create_grass_cut_effect():
	var grass_cut_effect = GrassCutEffect.instance()
	get_parent().add_child(grass_cut_effect)
	grass_cut_effect.position = self.position


func _on_Stats_no_health():
	create_grass_cut_effect()
	queue_free()
