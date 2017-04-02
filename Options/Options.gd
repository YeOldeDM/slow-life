extends WindowDialog

onready var display_tab = get_node('frame/Tab/Display')
onready var misc_tab = get_node('frame/Tab/Misc')

onready var devmode_picker = misc_tab.get_node('box/DevMode')
onready var autosave_picker = misc_tab.get_node('box/Autosave')
onready var autosave_time = misc_tab.get_node('box/box/AutoSaveTime')

onready var bg_mode_picker = display_tab.get_node('box/box/BGMode')
onready var bg_blur_picker = display_tab.get_node('box/BGBlur')

onready var gui_tint_picker = display_tab.get_node('box/box 3/GUITint')
onready var gui_lamp_tint_picker = display_tab.get_node('box/box 3/GUILampTint')

func save():
	var data = {}
	data["dev_mode"] = devmode_picker.is_pressed()
	data["autosave"] = autosave_picker.is_pressed()
	data["autosave_time"] = autosave_time.get_value()
	data["bg_mode"] = bg_mode_picker.get_selected()
	data["bg_blur"] = bg_blur_picker.is_pressed()
	var gt = gui_tint_picker.get_color()
	data["gui_tint"] = [gt.r, gt.g, gt.b]
	var glt = gui_lamp_tint_picker.get_color()
	data["gui_lamp_tint"] = [glt.r, glt.g, glt.b]
	return data


func restore(data):
	# Restore DEVMODE
	if 'dev_mode' in data:
		devmode_picker.set_pressed(data.dev_mode)
		Game.DEV_MODE = data.dev_mode
	
	# Restore AUTOSAVE
	if 'autosave' in data:
		autosave_picker.set_pressed(data.autosave)
		Game.AUTO_SAVE = data.autosave
	if 'autosave_time' in data:
		autosave_time.set_value(data.autosave_time)
		Game.AUTO_SAVE_TIME = data.autosave_time
	
	# Restore BG settings
	if 'bg_mode' in data:
		bg_mode_picker.select(data.bg_mode)
		Game.BG_MODE = data.bg_mode
	if 'bg_blur' in data:
		bg_blur_picker.set_pressed(data.bg_blur)
		Game.BG_BLUR = data.bg_blur
	
	if 'gui_tint' in data:
		var d = data.gui_tint
		var tint = Color(1,1,1)
		if typeof(d) == TYPE_ARRAY:
			tint = Color(d[0], d[1], d[2])
		gui_tint_picker.set_color(tint)
		Game.GUI_TINT = d
	if 'gui_lamp_tint' in data:
		var d = data.gui_lamp_tint
		var tint = Color(1,1,1)
		if typeof(d) == TYPE_ARRAY:
			tint = Color(d[0], d[1], d[2])
		gui_lamp_tint_picker.set_color(tint)
		Game.GUI_LAMP_TINT = d
	
	return OK






func _ready():
	Game.options = self

# OPTIONS SIGNALS

# Click on link, opens browser and points to URL
func _on_RichTextLabel_meta_clicked( meta ):
	OS.shell_open(meta)


# Misc/Toggle DEV MODE
func _on_DevMode_toggled( pressed ):
	Game.DEV_MODE = pressed


func _on_Autosave_toggled( pressed ):
	Game.AUTO_SAVE = pressed


func _on_AutoSaveTime_value_changed( value ):
	Game.AUTO_SAVE_TIME = int(value)


func _on_BGStyle_item_selected( ID ):
	Game.BG_MODE = ID


func _on_BGBlur_toggled( pressed ):
	Game.BG_BLUR = pressed


func _on_GUITint_color_changed( color ):
	Game.GUI_TINT = color


func _on_GUILampTint_color_changed( color ):
	Game.GUI_LAMP_TINT = color
