extends WindowDialog

onready var tree = get_node('frame/ContainerTree')

func _ready():
	Game.inventory = tree
