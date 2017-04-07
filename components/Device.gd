extends Node

onready var owner = get_parent()

var uses = []



func save():
	var data = {
		'uses':	self.uses,
		}
	
	return data


func restore(data):
	for key in data:
		if key in self:
			set(key, data[key])
	return OK



func has_use(what):
	return what in self.uses

func _ready():
	owner.device = self
