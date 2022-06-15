extends Camera2D

onready var top_left = $Limits/TopLeft
onready var bottom_right = $Limits/BottomRight

func _ready():
	limit_top    = top_left.position.y
	limit_left   = top_left.position.x
	limit_bottom = bottom_right.position.y
	limit_right  = bottom_right.position.x
