extends Control


onready var skills_button = get_node('Top/Skills')
onready var inventory_button = get_node('Top/Inventory')
onready var options_button = get_node('Top/Options')
onready var stats_button = get_node('Top/Stats')
onready var quit_button = get_node('Top/Quit')

onready var inventory_window = get_node('Inventory')
onready var skills_window = get_node('Skills')
onready var options_window = get_node('Options')
onready var stats_window = get_node('Stats')
onready var console_window = get_node('Console')
onready var quit_window = get_node('Quit')




func _ready():
	# Setup universal window stuff
	for who in [inventory_window, skills_window, options_window, stats_window, console_window, quit_window]:
		# Raise on interaction
		who.connect("item_rect_changed", self, "_on_window_rect_changed", [who])
		# Flop button when closed
		who.connect("hide", self, "_on_window_closed", [who])
	
	# Setup game
	Game.main = self
	# Build the Skill tree for GUI
	skills_window.build_tree()
	
	
	# Initial WorldCel?
	var world = get_node('World/CircularContainer')
	for e in ["grass", "trees", "rocks", "pond"]:
		var itm = preload('res://WorldItem/WorldItem.tscn').instance()
		world.add_child(itm)
		itm.setup('res://database/worlditems/'+e+'.cfg')

	# Start the friggin game already
	Game.start()




func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		Game.quit()


func _on_Skills_toggled( pressed ):
	skills_window.set_hidden(!pressed)
	if pressed:	skills_window.raise()


func _on_Inventory_toggled( pressed ):
	inventory_window.set_hidden(!pressed)
	if pressed:	inventory_window.raise()

func _on_Options_toggled( pressed ):
	options_window.set_hidden(!pressed)
	if pressed:	options_window.raise()

func _on_Stats_toggled( pressed ):
	stats_window.set_hidden(!pressed)
	if pressed:	stats_window.raise()


func _on_Console_toggled( pressed ):
	console_window.set_hidden(!pressed)
	if pressed:	console_window.raise()


func _on_Quit_toggled( pressed ):
	quit_window.set_hidden(!pressed)
	if pressed:	quit_window.raise()



func _on_window_rect_changed(window):
	window.raise()

func _on_window_closed(window):
	get_node('Top/'+window.get_name()).set_pressed(false)


func _on_Quit_confirmed():
	Game.quit()


func _on_Autosave_timeout():
	if Game.AUTO_SAVE == true:
		var saved = yield(Game, "game_saved")
		Game.console.message("Auto saved!")






