extends AudioStreamPlayer

func _ready():
	var error_code = connect("finished", self, "queue_free")
	if error_code != 0:
		print("Error connecting PlayerHurtSound: ", error_code)
