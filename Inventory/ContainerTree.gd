extends Tree

const COLOR_INACTIVE = Color(1,1,1)
const COLOR_ACTIVE = Color(0,0.8,0)

var icondir = 'res://assets/graphics/icons/'
var NO_ICON = preload('res://assets/graphics/icons/MISSING_ICON.png')
	
var columns = ['Name', 'QL', 'Dmg', 'Wt']

var root

var body = {
	'head':		null,
	'torso':	null,
	'hands':	null,
	'legs':		null,
	'feet':		null
	}

var default_container
var ground

var active_item setget _set_active_item




func is_inventory():
	return get_node('../../') extends preload('res://Inventory/Inventory.gd')

func get_active_item():
	return self.active_item.get_meta('item')

func set_active_item(itm):
	if !is_inventory():
		Game.task_board.message("That needs to be in your inventory before you can activate it.")
		return
	for i in range(4):
		if active_item:
			active_item.set_custom_color(i,COLOR_INACTIVE)
		itm.set_custom_color(i,COLOR_ACTIVE)
	self.active_item = itm


func add_item(item,parent=null,root_item=false,equip=false):
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
	if !my.is_connected('name_changed', self, 'update_item_text'):
		my.connect('name_changed', self, 'update_item_text', [itm,0])
	if !my.is_connected('quality_changed', self, 'update_item_text'):
		my.connect('quality_changed', self, 'update_item_text', [itm,1])
	if !my.is_connected('damage_changed', self, 'update_item_text'):
		my.connect('damage_changed', self, 'update_item_text', [itm,2])
	if !my.is_connected('weight_changed', self, 'update_item_text'):
		my.connect('weight_changed', self, 'update_item_text', [itm,3])
	
	# set item icon
	var icon = null
	var ref = my.get_ref()
	if ref:
		# look for and load icon
		var iconpath = icondir+ref+'.png'
		var x = File.new().file_exists(iconpath)
		if x:
			icon = load(icondir+ref+'.png')
	# Use fallback icon if none can be loaded
	if !icon:
		icon = NO_ICON
	itm.set_icon(0, icon)

	# set treeitem text
	itm.set_text(0, my.name)
	itm.set_text(1, str(my.quality).pad_decimals(2))
	itm.set_text(2, str(my.damage).pad_decimals(2))
	itm.set_text(3, str(my.get_total_weight()).pad_decimals(2))
	

	# Add Item to parent Item's container
	if !equip:
		if parent != root:
			var pitem = parent.get_meta('item')
			if pitem.container:
				pitem.container.add_item(my)
	
	if item.container:
		for i in item.container.contents:
			add_item(i,itm)
	
	return itm


# Move data into itm container
func move_item(data, itm):
	if itm != null:
		Game.console.message("Dragging "+data.get_text(0)+" to "+itm.get_text(0))
		var item = itm.get_meta('item')
		if item.container:
			if item.container.can_fit(data.get_meta('item')):
				var moved_itm = add_item(data.get_meta('item'),itm)
				if self.active_item == data:
					set_active_item(moved_itm)
				data.get_parent().remove_child(data)
				Game.task_board.message("You put the "+data.get_text(0)+ " in the " +itm.get_text(0)+ ".")
		else:
			Game.task_board.message("The "+data.get_text(0)+" wont fit in the "+itm.get_text(0)+".")
		#set_drop_mode_flags(DROP_MODE_DISABLED)


func equip_item(itm, wearer):
	var item = itm.get_meta('item').location.container.remove_item(itm.get_meta('item'))
	item.equippable.equip(wearer.get_meta('item'))
	
	itm.get_parent.remove_child(itm)
	add_item(item,wearer,false,true)


# Update item column property from item signals
func update_item_text(data, item, col):
	var text = str(data)
	if typeof(data) == TYPE_REAL:
		text = str(data).pad_decimals(2)
	item.set_text(col, text)


# Show item options when right-clicked
func show_actions_menu(pos):
	var itm = get_item_at_pos(pos)
	if !itm: return
	itm.select(0)
	var item = itm.get_meta('item')
	var menu = PopupMenu.new()
	add_child(menu)
	
	# menu Header
	menu.add_item(itm.get_text(0),-1)
	menu.add_separator()
	# ------- #
	
	# populate menu(s)
	
	
	# Create the popup menu
	
	# Examine (should be on every item)
	menu.add_item("Examine", Action.ACTION_EXAMINE)
	
	# Drop (unless immovable and not already dropped)
	if !item.immovable && itm.get_parent() != self.ground:
		menu.add_item("Drop", Action.ACTION_DROP)
	
	# Destroy (unless indestructible)
	if !item.indestructible:
		var destroy = PopupMenu.new()
		destroy.add_item("Really?", Action.ACTION_DESTROY)
		menu.add_child(destroy)
		destroy.connect("item_pressed", self, "_on_item_action_pressed")
		destroy.set_name("destroy")
		menu.add_submenu_item("Destroy", "destroy")
	
	# Open container item
#	if item.container:
#		menu.add_item("Open", Action.ACTION_OPEN)
	
	# Activate selected item
	if !item == active_item && item.get_parent() != self.ground:
		menu.add_item("Activate", Action.ACTION_ACTIVATE)
	
	# Equip equippable items
	if item.equippable:
		var parts = []
		for slot in item.equippable.fits_slot:
			for key in self.body:
				if item.equippable.can_fit(self.body[key].get_meta('item')):
					if !self.body[key] in parts:
						parts.append(self.body[key])
		if !parts.empty():
			var partsmenu = PopupMenu.new()
			menu.add_child(partsmenu)
			partsmenu.set_name('partsmenu')
			
			for part in parts:
				part = part.get_meta('item')
				var slotsmenu = PopupMenu.new()
				partsmenu.add_child(slotsmenu)
				slotsmenu.set_name('slotsmenu')
				slotsmenu.connect("item_pressed", self, "_on_item_action_pressed", [slotsmenu])
				for slot in part.equip_slots:
					if slot in item.equippable.fits_slot:
						slotsmenu.add_item(slot, Action.ACTION_EQUIP)
				partsmenu.add_submenu_item(part.name,'slotsmenu')
			menu.add_submenu_item("Equip", 'partsmenu')
		
	# Menu footer
	menu.add_separator()
	# ------- #
	menu.add_item("My notebook entry for "+itm.get_text(0), 88)
	
	# draw menu
	menu.popup()
	pos = get_owner().get_pos() + pos
	pos.x -= menu.get_rect().size.x / 2
	pos.y += 20
	menu.set_pos(pos)
	
	menu.connect("item_pressed", self, "_on_item_action_pressed")





# DRAG-N-DROP METHODS

func get_drag_data(pos):
	set_drop_mode_flags(DROP_MODE_INBETWEEN + DROP_MODE_ON_ITEM)
	var item = get_item_at_pos(pos)
	if !item.get_meta('item').immovable:
		var box = Button.new()
		box.set_flat(true)
		box.set_button_icon(item.get_icon(0))
		box.set_text(item.get_text(0))
		set_drag_preview(box)
		return item
		#print(item.get_text(0))

func can_drop_data(pos, data):
	if data.has_meta('item'):
		return true
	return false

func drop_data(pos,data):
	# data=dragged item
	# itm=drag target TreeItem
	# item=drag target Item
	var itm = get_item_at_pos(pos)
	move_item(data, itm)









# On right-clicking an inventory item
func _on_ContainerTree_item_rmb_selected( pos ):
	show_actions_menu(pos)


# On double-clicking an inventory item
func _on_ContainerTree_item_activated():
	var itm = get_selected()
	if itm.get_parent() == self.ground:
		Game.task_board.message("That must be in your inventory before you can activate it!")
	else:
		if itm && itm != self.ground:
			set_active_item(itm)

# On option clicked from item rmb menu
# idx should correspond to Action.ACTION_*
func _on_item_action_pressed(idx, param=null):
	printt(get_selected().get_text(0), idx)
	var item = get_selected().get_meta('item')
	if item:
		if idx == Action.ACTION_ACTIVATE:
			set_active_item(get_selected())
			return
		elif idx == Action.ACTION_DROP:
			move_item(get_selected(), self.ground)
			return
		
		# Equip - WTF to do...
		elif idx == Action.ACTION_EQUIP:
			var slot = param
		
		var err = Action.Go(item, idx)






func _ready():
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



# SETTERS

func _set_active_item(what):
	var label = get_node('../Active/box/Item')
	active_item = what
	if active_item == null:
		label.set_text('')
	else:
		label.set_text(get_active_item().name)
