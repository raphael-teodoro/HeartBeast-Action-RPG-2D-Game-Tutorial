extends Control

var max_health = 4 setget set_max_health
var health = 4 setget set_health

onready var heart_empty = $HeartEmpty
onready var heart_full = $HeartFull

const PIXELS_PER_HEART = 15

func _ready():
	#heart_empty = $HeartEmpty
	#heart_full = $HeartFull

	var stats = PlayerStats
	self.max_health = stats.max_health
	self.health = stats.health
	
	stats.connect("max_health_changed", self, "set_max_health")
	stats.connect("health_changed", self, "set_health")

func set_max_health(value):
	max_health = max(value, 1)
	heart_empty.rect_size.x = max_health * PIXELS_PER_HEART

func set_health(value):
	health = clamp(value, 0, max_health)
	heart_full.rect_size.x = health * PIXELS_PER_HEART
