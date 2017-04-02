extends Control

# Common actions
const ACTION_EXAMINE = 0	# Examine an Item
const ACTION_DESTROY = 1	# Destroy (delete) an Item
const ACTION_DROP = 2		# Move an item into the Ground container
const ACTION_NAME = 3		# Give a name to an object

# Uniquer actions
const ACTION_WORLDITEM_HARVEST = 20	# Harvest from a WorldItem
const ACTION_WORLDITEM_FORAGE = 21	# Forage for items from a WorldItem

const ACTION_LOOKUP = 88			# Lookup Item in Notebook

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



func action(data, act_idx):
	# Print examine text for data
	if act_idx == ACTION_EXAMINE:
		return examine(data)
	
	# Harvest from data
	if act_idx == ACTION_WORLDITEM_HARVEST:
		return harvest(data)
	
	# Forage from data
	if act_idx == ACTION_WORLDITEM_FORAGE:
		return forage(data)
	
	# No action found for act_idx
	return ERR_PARAMETER_RANGE_ERROR


# EXAMINE an Item
func examine(data):
	var txt = ''
	if 'description' in data:
		txt = data.description
	if !txt.ends_with('.'): txt += '.'

	if data extends preload('res://Item/Item.gd'):
		if data.container:
			txt += ' This can act as a container for other items. '
		if data.equippable:
			txt += ' This item can be equipped. '
		if data.edible:
			txt += ' This can be eaten. '
		if data.device:
			var uses = "[ "
			var d = data.device.uses
			if d.size() == 1:
				uses = d[0]
			else:
				for i in range(d.size()-1):
					uses += '"' +d[i]+ '" '
			txt += ' This can be activated as a tool to ' +uses+ '].'
	
	Game.observe_board.message("\nYou carefully examine the " +data.name+ "...")
	Game.observe_board.message(txt)
	return OK




func get_random_result_item(data,type):
	print(type)
	# roll result item
	if !type in data.action_result_items:
		return null
	
	var dict = data.action_result_items[type]
	var choices = []
	for key in dict:
		for i in range(dict[key]):
			choices.append(key)
	
	var choice = choices[randi() % choices.size()]
	var item = Game.items.create_item(choice)
	return item


func harvest(data):
	if Game.taskmanager.task_queue_full():
		Game.task_board.message("You're too busy to do that.")
		return ERR_PARAMETER_RANGE_ERROR
	# Roll the result item
	var item = get_random_result_item(data, 'harvest')
	# Create the task object
	var task = preload('res://Task/Task.tscn').instance()
	task.task_action = "Chopping down a tree"
	task.length = 35
	Game.taskmanager.add_task(task)
	
	Game.task_board.message("You begin harvesting...")
	
	yield(task, 'finished')
	
	# Add result item from inventory when Task finishes
	Game.inventory.add_item(item)
	var txt = "You harvest a " +item.name+ " from the "+data.name+ "."
	Game.task_board.message(txt)
	# Return OK
	return OK


func forage(data):
	if Game.taskmanager.task_queue_full():
		Game.task_board.message("You're too busy to do that.")
		return ERR_PARAMETER_RANGE_ERROR
	# Roll the result item
	var item = get_random_result_item(data, 'forage')
	# Create the task object
	var task = preload('res://Task/Task.tscn').instance()
	task.task_action = "Foraging in the " +data.name
	task.length = 25
	Game.taskmanager.add_task(task)
	
	Game.task_board.message("You begin foraging...")
	
	var result = yield(task, 'finished')
	
	# Add result item from inventory when Task finishes
	Game.inventory.add_item(item)
	var txt = "You find a " +item.name+ " while foraging in the " +data.name+ "."
	Game.task_board.message(txt)
	# Return OK
	return OK


func _ready():
	for who in [inventory_window, skills_window, options_window, stats_window, console_window, quit_window]:
		who.connect("item_rect_changed", self, "_on_window_rect_changed", [who])
		who.connect("hide", self, "_on_window_closed", [who])
	Game.main = self
	skills_window.build_tree()
	Game.start()
	
	var world = get_node('World/CircularContainer')
	for e in ["grass", "trees", "rocks", "pond"]:
		var itm = preload('res://WorldItem/WorldItem.tscn').instance()
		world.add_child(itm)
		itm.setup('res://database/worlditems/'+e+'.cfg')
#	for node in get_node('World/CircularContainer').get_children():
#		if node.has_method('start'):
#			node.start()



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






