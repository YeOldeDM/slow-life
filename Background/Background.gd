extends CanvasLayer


func set_blur(blurred):
	get_node('Blur').set_hidden(!blurred)


func _ready():
	Game.background = self