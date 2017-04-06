extends WindowDialog

onready var tree = get_node('frame/ContainerTree')

var container = null setget _set_container

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass




func _set_container(what):
	container = what
	set_title(container.get_name())
	tree.add_item(container,null,true)





