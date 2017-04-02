extends WindowDialog

onready var Out = get_node('box/Out')
onready var In = get_node('box/In')

var cmd_history = ['']
var history_idx = 0 setget _set_history_idx

func message(text):
	Out.newline()
	Out.add_text(text)

func parse_cmd(text):
	message(text)


func _ready():
	Game.console = self
	var name = Globals.get('application/name')
	set_title(name + ' -- v' + Version.get_version())
	Out.set_scroll_follow(true)
	Out.clear()


func _on_In_text_entered( text ):
	parse_cmd(text)
	cmd_history.insert(1,text)
	self.history_idx = 0
	In.clear()


func _input( ev ):
	if ev.type == InputEvent.KEY and ev.pressed:
		if ev.scancode == KEY_UP:
			self.history_idx += 1
		if ev.scancode == KEY_DOWN:
			self.history_idx -= 1

func _set_history_idx(what):
	history_idx = what
	if history_idx < 0:
		history_idx = 0
		In.clear()
	if history_idx < cmd_history.size():
		In.set_text(cmd_history[history_idx])
		In.set_cursor_pos(In.get_text().length())
	else:
		history_idx = cmd_history.size() - 1

func _on_Console_visibility_changed():
	set_process_input(!is_hidden())
