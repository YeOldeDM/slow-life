extends WindowDialog

onready var tree = get_node('frame/Tree')

func _ready():
	tree.set_hide_root(false)
	tree.set_columns(2)
	tree.set_column_titles_visible(true)
	tree.set_column_expand(0,true)
	tree.set_column_expand(1,false)
	tree.set_column_min_width(1,48)
	tree.set_column_title(0, 'Skill')
	tree.set_column_title(1, '#')

func build_tree():
	tree.clear()
	var root_skill = Game.skills.get_node('Level')
	
	var root = tree.create_item()
	root.set_text(0, root_skill.get_name())
	root.set_text(1, str(root_skill.get_score()).pad_decimals(2))
	
	for child in root_skill.get_children():
		add_skill(child, root)

func add_skill(skill, parent):
	var itm = tree.create_item(parent)
	itm.set_collapsed(true)
	itm.set_meta('skill',skill)
	itm.set_text(0, str(skill.get_name()))
	itm.set_text(1, str(skill.get_score()).pad_decimals(2))
	skill.treeitem = itm
	skill.connect('score_changed',self, '_on_skill_score_changed', [itm,1])
	
	for child in skill.get_children():
		add_skill(child, itm)
	
	

func _on_Skills_visibility_changed():
	#if !is_hidden(): display_tree()
	pass

func _on_skill_score_changed(data, item, col):
	item.set_text(col, str(data).pad_decimals(2))
