extends MenuButton

onready var menu = get_popup()


var name = "WorldItem" setget _set_name
var description = "This object defies description."

var custom_actions = {}

var action_result_items = {}

var tools_needed

var quality = 1.0

func setup(path):
	var file = ConfigFile.new()
	var err = file.load(path)
	if !err == OK:
		return err
	
	for key in file.get_section_keys("Item"):
		if key in self:
			set(key, file.get_value("Item", key))
	
	menu.add_item(self.name, Game.main.ACTION_EXAMINE)
	menu.add_separator()
	menu.add_item("Examine", Game.main.ACTION_EXAMINE)
	
	for key in self.custom_actions:
		var idx = self.custom_actions[key]
		menu.add_item(key, idx)
	menu.add_separator()
	menu.add_item("My notebook entry for "+self.name, Game.main.ACTION_LOOKUP)

	menu.connect("item_pressed", self, "_on_menu_item_pressed")
	return OK




func start():
	var x = setup('res://database/worlditems/trees.cfg')



func _on_menu_item_pressed(idx):
	Game.main.action(self, idx)




func _set_name(what):
	name = what
	set_text(name)