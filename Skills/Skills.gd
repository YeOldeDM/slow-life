extends Node

func get_skill(name):
	var node = find_node(name)
	if node: return node

func _ready():
	Game.skills = self
	
