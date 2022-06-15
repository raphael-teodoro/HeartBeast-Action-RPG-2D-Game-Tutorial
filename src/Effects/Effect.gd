extends AnimatedSprite

func _ready():
	var error_code = connect("animation_finished", self, "_on_animation_finished")
	if error_code != 0:
		print("Error connecting the animation: ", error_code)
	play("Animate")


func _on_animation_finished():
	queue_free()
