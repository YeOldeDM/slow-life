extends Control

# Factory method to create an Item scene from cfg file @path
func create_item(path):
	var data = ConfigFile.new()
	# load configfile for item
	var opened = data.load(path)
	if !opened==OK:
		# Cfg file not loaded
		print('Couldn\'t find .cfg file at: "'+path+'"')
		return
	# instanciate
	var itm = preload("res://Item/Item.tscn").instance()
	add_child(itm)
	
	# Set Item ref string
	var ref = path.right(path.rfindn('/')+1)
	ref = ref.left(ref.rfind('.'))
	itm._ref = ref
	
	# Assemble object/components from config sections
	for section in data.get_sections():
		var comp
		# Item data goes in base Item
		if section == "Item":
			comp = itm
		else:
			# Instanciate a component of Item
			comp = load("res://components/"+section+".tscn").instance()
			var vname = section.to_lower()
			
			if comp==null: 
				print('Couldn\'t load component: "'+section+'"')
			else:
				if vname in itm:
					itm.set(vname, comp)
					itm.add_child(comp)
				else: print('Item needs component member: "'+vname+'"')
		# Apply data to object/components
		for key in data.get_section_keys(section):
			if comp!=null and key in comp:
				comp.set(key, data.get_value(section,key))
			else: print(itm.name+':'+section+' was given value for "'+key+", but has no such member")
	# return the Item
	return itm



func _ready():
	Game.items = self
	Game.inventory.add_item(create_item('res://database/bodyparts/head.tres'),null,true)
	var torso = Game.inventory.add_item(create_item('res://database/bodyparts/torso.tres'),null,true)
	var hands = Game.inventory.add_item(create_item('res://database/bodyparts/hands.tres'),null,true)
	Game.inventory.add_item(create_item('res://database/bodyparts/legs.tres'),null,true)
	Game.inventory.add_item(create_item('res://database/bodyparts/feet.tres'),null,true)
	
	
	var backpack = create_item('res://database/crafted/backpack.tres')
	var rock = create_item('res://database/natural/rock.tres')
	var bp = Game.inventory.add_item(backpack, torso)
	Game.inventory.default_container = bp
	Game.inventory.add_item(rock,bp)


	
	
	