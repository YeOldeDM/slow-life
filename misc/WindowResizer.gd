extends HBoxContainer

var min_size = Vector2(250,100)

onready var window = get_node('../../')

func _process(delta):
	var mpos = get_viewport().get_mouse_pos()
	var rect = get_node('Button').get_rect()
	var pos = mpos + ((rect.end - rect.pos)/2)
	var win_pos = window.get_pos()
	var win_size = pos - win_pos
	win_size.x = max(min_size.x, win_size.x)
	win_size.y = max(min_size.y, win_size.y)
	window.set_size(win_size)


func _on_Button_pressed():
	set_process(true)


func _on_Button_released():
	set_process(false)
