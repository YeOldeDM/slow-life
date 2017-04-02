#########################
#		EQUIPPABLE		#
#########################
extends Node

signal put_on()
signal taken_off()

onready var owner = get_parent()

var fits_slot = ["jagon"]

var worn_on = null




func save():
	var data = {}
	
	return data


func restore(data):
	return OK



func equip():
	emit_signal('put_on')


func dequip():
	emit_signal('taken_off')


func is_worn():
	return self.worn_on != null


func can_fit(item):
	if item.equip_slots.empty():
		return false
	for slot in item.equip_slots:
		if slot in item.equipped.keys():
			return false
		if slot in self.fits_slot:
			return true




func _ready():
	owner.equippable = self
