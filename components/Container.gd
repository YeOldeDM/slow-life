#########################
#		CONTAINER		#
#########################
extends Node

signal contents_changed()

# Owner
onready var owner = get_parent()

# Params
export(float) var max_weight = 10.0
export(int,0,3) var size_limit = 1
export(int,-1,99) var max_items = -1	# -1 = no max

export(bool) var hold_liquids = false

var contents = []


func save():
	var data = {
		'max_weight':	self.max_weight,
		'size_limit':	self.size_limit,
		'max_items':	self.max_items,
		'hold_liquids':	self.hold_liquids,
		}
	
	return data


func restore(data):
	for key in data:
		if key in self:
			set(key, data[key])
	return OK


func get_contents_weight():
	var total = 0
	for itm in self.contents:
		total += itm.get_total_weight()
	return total


func can_fit(item):
	if self.max_weight >= 0:
		var new_weight = get_contents_weight() + item.get_total_weight()
		if new_weight > self.max_weight:
			return false
	if item.size > self.size_limit:
		return false
	if self.max_items >= 0:
		if contents.size()+1 > self.max_items:
			return false
	print(item.get_name()+" can fit!")
	return true

# Designate item's location as our container
func add_item(item):

	self.contents.append(item)
	item.location = owner
	emit_signal('contents_changed')


func remove_item(item):
	var idx = self.contents.find(item)
	if idx == -1:
		return
	var itm = self.contents[idx]
	itm.location = null
	self.contents.remove(idx)
	emit_signal('contents_changed')
	return itm

# Init
func _ready():
	owner.container = self
	connect('contents_changed', self, '_on_contents_changed')

func _on_contents_changed():
	print('\ncontents')
	for i in contents:
		print(i.name)
	print('\n')
	owner.emit_signal('weight_changed',owner.get_total_weight())

