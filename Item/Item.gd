extends Node

# Signals
signal name_changed(name)
signal quality_changed(val)
signal weight_changed(val)
signal damage_changed(val)

var _ref		# set by item loader
var _treeitem	# set by treeitem

# Params
export(String, MULTILINE) var name = "NoName" setget _set_name
export(String, MULTILINE) var description = "This object defies description."
export(float) var quality = 1.0 setget _set_quality

export(float) var weight = 1.0 setget _set_weight

export(bool) var liquid = false

export(bool) var can_activate = true
export(bool) var immovable = false
export(bool) var indestructible = false

var damage = 0.0 setget _set_damage

export(int,0,4) var size = 0
#0=fits anywhere, 1=fits in small container, 2=fits in large container, 3=carried only, 4=only fits on ground


# COMPONENTS
var edible		# Edible item
var equippable	# Equippable item
var container	# Container item
var device		# Device (tool) item



var equip_slots = []	# slot names for equippables
var equipped = {}		# Items equipped on slots (1 item per slot)

var location	# Container this item is in, null=="limbo": the item exists, but in no location

# Save/Restore methods

func save():
	var data = {
		'item':	{
		'_ref':				self._ref,
		'name': 			self.name,
		'description': 		self.description,
		'size':				self.size,
		'quality': 			self.quality,
		'weight': 			self.weight,
		'damage': 			self.damage,
		'liquid':			self.liquid,
		'immovable':		self.immovable,
		'indestructible':	self.indestructible,
		
		'equip_slots':		self.equip_slots,
		'location':			self.location,
		}
	}
	
	
	if edible:
		data['edible'] = edible.save()
	if equippable:
		data['equippable'] = equippable.save()
	if container:
		data['container'] = container.save()
	if device:
		data['device'] = device.save()
	
	return data


func restore(data):
	if 'item' in data:
		for key in data.item:
			set(key, data.item[key])
	for key in data:
		if key != 'item':
			var comp = load('res://components/'+key.capitalize()+'.tscn').instance()
			add_child(comp)
			comp.restore(data[key])
	
	return OK




# Public methods
func get_name():
	return self.name

func get_ref():
	return self._ref

func get_total_weight():
	var total = self.weight
	if self.container:
		total += self.container.get_contents_weight()
	return total


func remove_from_location():
	if self.location:
		return self.location.container.remove_item(self)

func add_item(item):
	if self.container:
		self.container.add_item(item)

func get_contents():
	var items = self.equipped.values()
	if self.container:
		for i in self.container.contents:
			items.append(i)
	return items

# Private methods
func _ready():
	add_to_group('items')



# Setter methods
func _set_name(what):
	if what != name:
		emit_signal('name_changed',what)
	name = what


func _set_quality(what):
	if what != quality:
		emit_signal('quality_changed',what)
	quality = max(0.0, what)


func _set_weight(what):
	if what != weight:
		emit_signal('weight_changed',what)
	weight = max(0.0,what)


func _set_damage(what):
	if what != damage:
		emit_signal('damage_changed',what)
	damage = what