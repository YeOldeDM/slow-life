extends Node

# Signals
signal name_changed(name)
signal quality_changed(val)
signal weight_changed(val)
signal damage_changed(val)

# Params
export(String, MULTILINE) var name = "NoName" setget _set_name
export(String, MULTILINE) var description = "This object defies description."
export(float) var quality = 1.0 setget _set_quality

export(float) var weight = 1.0 setget _set_weight

export(bool) var liquid = false
export(bool) var immovable = false

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
	var data = {}
	
	return data


func restore(data):
	return OK




# Public methods
func get_total_weight():
	var total = self.weight
	if self.container:
		total += self.container.get_contents_weight()
	return total



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