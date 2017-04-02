extends Node

onready var owner = get_parent()

var uses = []

func has_use(what):
	return what in self.uses

func _ready():
	owner.device = self
