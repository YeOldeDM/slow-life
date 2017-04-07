#####################
#		EDIBLE		#
#####################
extends Node

onready var owner = get_parent()

export(float) var hunger = 0.0
export(float) var thirst = 0.0




func save():
	var data = {
		'hunger':	self.hunger,
		'thirst':	self.thirst,
		}
	
	return data


func restore(data):
	for key in data:
		if key in self:
			set(key, data[key])
	return OK








func _ready():
	owner.edible = self
