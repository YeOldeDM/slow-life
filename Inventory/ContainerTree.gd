extends Tree

const COLOR_INACTIVE = Color(1,1,1)
const COLOR_ACTIVE = Color(0,0.8,0)
	
var columns = ['Name', 'QL', 'Dmg', 'Wt']

var root

var default_container

var active_item setget _set_active_item

func _ready():
	Game.inventory = self
	set_hide_root(true)
	set_allow_rmb_select(true)
	set_columns(columns.size())
	set_column_titles_visible(true)
	set_column_expand(0, true)
	for i in range(columns.size()):
		if i !=0:
			set_column_expand(i,false)
			set_column_min_width(i, 42)
		set_column_title(i, columns[i])

	# Create Container root
	root = create_item()


func get_active_item():
	return self.active_item.get_meta('item')

func set_active_item(itm):
	for i in range(4):
		if active_item:
			active_item.set_custom_color(i,COLOR_INACTIVE)
		itm.set_custom_color(i,COLOR_ACTIVE)
	self.active_item = itm

func add_item(item,parent=null,root_item=false):
	if root_item: parent = root
	elif !parent: 
		if default_container != null:
			parent = default_container
	
	var itm = create_item(parent)
	itm.set_meta('item',item)
	itm.set_selectable(1,false)
	itm.set_selectable(2,false)
	itm.set_selectable(3,false)
	
	var my = item
	# connect item signals
	my.connect('name_changed', self, 'update_item_text', [itm,0])
	my.connect('quality_changed', self, 'update_item_text', [itm,1])
	my.connect('damage_changed', self, 'update_item_text', [itm,2])
	my.connect('weight_changed', self, 'update_item_text', [itm,3])
	
	# set treeitem text
	itm.set_text(0, my.name)
	itm.set_text(1, str(my.quality).pad_decimals(2))
	itm.set_text(2, str(my.damage).pad_decimals(2))
	itm.set_text(3, str(my.get_total_weight()).pad_decimals(2))
	

	# Add Item to parent Item's container
	if parent != root:
		var pitem = parent.get_meta('item')
		if pitem.container:
			pitem.container.add_item(my)
	
	return itm


func update_item_text(data, item, col):
	var text = str(data)
	if typeof(data) == TYPE_REAL:
		text = str(data).pad_decimals(2)
	item.set_text(col, text)



func show_actions_menu(pos):
	var item = get_item_at_pos(pos)
	item.select(0)
	var menu = PopupMenu.new()
	add_child(menu)
	
	# menu title
	menu.add_item(item.get_text(0),-1)
	menu.add_separator()
	# ------- #
	
	# populate menu(s)
	var actions = {
		'Examine': null,
		'Drop':	['Ground'],
		'Destroy':	['Really?'],
		
		}
	menu.add_item("Examine", 0)
	if Game.DEV_MODE:
		var bad = PopupMenu.new()
		bad.add_item("BAD",-1)
		bad.add_item("WRONG",-1)
		bad.add_item("FAKENEWS",-1)
		menu.add_child(bad)
		bad.set_name('bad')
		menu.add_submenu_item("Trump", "bad", -1)
		menu.add_item("Obama", -1)
	
	menu.add_separator()
	# ------- #
	menu.add_item("My notebook entry for "+item.get_text(0), 88)
	
	# draw menu
	menu.popup()
	pos = get_owner().get_pos() + pos
	pos.x -= menu.get_rect().size.x / 2
	pos.y += 20
	menu.set_pos(pos)
	
	menu.connect("item_pressed", self, "_on_item_action_pressed")


func get_drag_data(pos):
	set_drop_mode_flags(DROP_MODE_INBETWEEN + DROP_MODE_ON_ITEM)
	var item = get_item_at_pos(pos)
	var lab = Label.new()
	lab.set_text(item.get_text(0))
	set_drag_preview(lab)
	return item
	#print(item.get_text(0))

func can_drop_data(pos, data):
	if data extends TreeItem:
		return true
	return false

func drop_data(pos,data):
	var item = get_item_at_pos(pos)
	if item != null:
		prints(item.get_text(0),data.get_text(0))
		set_drop_mode_flags(DROP_MODE_DISABLED)

# On right-clicking an inventory item
func _on_ContainerTree_item_rmb_selected( pos ):
	show_actions_menu(pos)


# On double-clicking an inventory item
func _on_ContainerTree_item_activated():
	var itm = get_selected()
	set_active_item(itm)


func _on_item_action_pressed(idx):
	printt(get_selected().get_text(0), idx)
	var item = get_selected().get_meta('item')
	if item:
		var err = Game.main.action(item, idx)



func _set_active_item(what):
	var label = get_node('../Active/box/Item')
	active_item = what
	if active_item == null:
		label.set_text('')
	else:
		label.set_text(get_active_item().name)
