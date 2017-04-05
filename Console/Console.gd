extends WindowDialog

onready var Out = get_node('box/Out')
onready var In = get_node('box/In')

var cmd_history = ['']
var history_idx = 0 setget _set_history_idx

# Public

# Outputs text to the console on a new line
func message(text):
	Out.newline()
	Out.add_text(text)

# Parses an incoming string and tries any commands typed
func parse_cmd(text):
	if !Game.DEV_MODE:
		message("Only usable in Developer Mode!")
	var args = text.split(' ',false)
	var cmd = args[0]
	args.remove(0)
	var method = "cmd_"+cmd
	if has_method(method):
		var msg = call(method,args)
		if msg: message(msg)
	

# CMD METHODS

# Say some things
func cmd_say(args):
	var txt = ''
	for word in args:
		txt += word+' '
	return "You say: \""+txt+"\""

# Get the current time and date
func cmd_date(args):
	if args.size()==0:
		var date = Game.clock.get_date()
		var tod = str(date.hour)+":"+str(date.minute)+":"+str(date.second)
		
		var txt = "It is " +tod+" on "+Game.clock.DAY_NAMES[date.day]+\
			", the " +str(date.week)+ "th week of "+str(date.year)
		
		return txt	



# Save like a boss
func cmd_save(args):
	if args.size()==0:
		Game.save_game()

# Quit like a h4X0r
func cmd_quit(args):
	if args.size()==0:
		Game.quit()

# Set stuff
func cmd_set(args):
	return "I can't set "+args[0]

# Get stuff
func cmd_get(args):
	var txt = "I can't get "+args[0]
	if args[0] == 'quacks':
		txt = "The ducky has been quacked "+str(Game.quacks)+" times."

	return txt


# SILLY COMMANDS

# Quack!
func cmd_quack(args):
	Game.quacks += 1

# Pity on some things
func cmd_pity(args):
	var txt = ''
	for w in args:
		txt += w+' '
	return "Pity " +txt+ "indeed, Little Girl!"




# Private 

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
