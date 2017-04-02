extends Polygon2D

const YELLOW = Color(0.7,0.5,0.2)
const BLUE = Color(0.3,0.4,1)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_HSlider_value_changed( value ):
	var v = value / get_node('HSlider').get_max()
	var colors = get_vertex_colors()
	colors[0] = YELLOW.linear_interpolate(BLUE,v)
	colors[1] = YELLOW.linear_interpolate(BLUE,v)
	set_vertex_colors(colors)
	
