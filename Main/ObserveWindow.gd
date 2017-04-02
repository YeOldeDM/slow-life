extends VBoxContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	Game.observe_board = get_node('box/MessageBox')
