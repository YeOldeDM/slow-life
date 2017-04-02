extends Node

signal score_changed(val)

# Skill ID: used in save/restore
# preserve skill data if name changes?
# ID should be snake_case
export(String, MULTILINE) var ID

export var score = 1.0 setget _set_score

var treeitem

func is_base():
	return get_child_count()==0

func get_score():
	# Return my skill if no children exist
	if get_child_count()==0:
		return self.score
 	# Get the average of child skills
	var s = 0.0
	for node in get_children():
		s += node.get_score()
	s /= get_child_count()
	if s != self.score:
		self.score = s
	return s

func _ready():
	get_score()

func _set_score(what):
	score = what
	emit_signal('score_changed', score)