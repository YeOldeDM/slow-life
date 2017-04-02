#####################
#		EDIBLE		#
#####################
extends Node

onready var owner = get_parent()

export(float) var hunger = 0.0
export(float) var thirst = 0.0




func save():
	var data = {}
	
	return data


func restore(data):
	return OK








func _ready():
	owner.edible = self
