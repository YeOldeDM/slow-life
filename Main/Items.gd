extends Control


const DATABASE = 'res://database/'
const DATAEXT = '.cfg'

func create_from_database(partial_path='natural/rock'):
	return create_item(DATABASE + partial_path + DATAEXT)

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


func restore_items(data):
	# Spawn and set items
	for entry in data:
		var item = preload('res://Item/Item.tscn').instance()
		add_child(item)
		item.restore(data)
	
	# Put items in their locations
	for node in get_children():
		if node.location:
			node.location.container.add_item(node)


func spawn_initial_items():
	var path = 'res://database/init_inv.cfg'
	var cfg = ConfigFile.new()
	var opened = cfg.load(path)
	if !opened == OK:
		print("Couldn't open " +path)
		print("Initial Items not spawned!!!")
		return
	var data = {}
	print(cfg.get_section_keys('Items'))
	for key in cfg.get_section_keys('Items'):
		data[key] = create_from_database(cfg.get_value("Items", key))
	var base = {
		'head':		data.head,
		'torso':	data.torso,
		'hands':	data.hands,
		'legs':		data.legs,
		'feet':		data.feet,
		'ground':	data.ground
		}
	Game.inventory.build_tree()


func _ready():
	Game.items = self
	#spawn_initial_items()
#	var head = Game.inventory.add_item(create_from_database('bodyparts/head'),null,true)
#	var torso = Game.inventory.add_item(create_from_database('bodyparts/torso'),null,true)
#	var hands = Game.inventory.add_item(create_from_database('bodyparts/hands'),null,true)
#	var legs = Game.inventory.add_item(create_from_database('bodyparts/legs'),null,true)
#	var feet = Game.inventory.add_item(create_from_database('bodyparts/feet'),null,true)
#	var ground = Game.inventory.add_item(create_from_database('bodyparts/ground'),null,true)
#	Game.inventory.ground = ground
#	Game.inventory.body = {
#		'head':		head,
#		'torso':	torso,
#		'hands':	hands,
#		'legs':		legs,
#		'feet':		feet
#		}
#	
#	var backpack = create_from_database('crafted/backpack')
#	var rock = create_from_database('natural/rock')
#	var bp = Game.inventory.add_item(backpack, ground)
#	Game.inventory.default_container = bp
#	Game.inventory.add_item(rock)
