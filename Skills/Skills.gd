extends Node

func get_skill(name):
	var node = find_node(name)
	if node: return node

func get_skill_check(from_skills=[]):
	var result = {}
	
	for skill in from_skills:
		result[skill] = get_skill(skill).get_score()
		var s = get_skill(skill).get_parent_skill()
		var d = 2.0
		while s:
			var sv = s.get_score() / d
			if not s in result or sv > result[s]:
				result[s.get_name()] = sv
			d += 1.0
			s = s.get_parent_skill()

	return result



func _ready():
	Game.skills = self
	var s = get_skill_check(['Foraging', 'Perception'])
	var v = 0
	for i in s:
		v += s[i]
	print(s)
	print("TOTAL: "+str(v))
	
