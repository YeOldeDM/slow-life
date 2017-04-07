extends Node

var quacks = 0 setget _set_quacks

# Signals
signal game_saved()
signal game_loaded()

# Constants
const SAVEPATH = 'user://world.sav'
const ENCRYPT_KEY = "Mro2eVb77iZ"

const TIMESCALE = 1.8
const DAY_LENGTH = 86400

const ZERO_YEAR = 1017

# Shortcuts
var main
var clock
var console
var skills

var items
var inventory
var options

var task_board
var observe_board

var taskmanager

var background
var daycycle

# Members

# real time spent with game running
var play_time = 0

# real time spent since you ended the last play session
var sleep_duration setget _set_sleep_duration
var session_start_time

# OPTIONS
var DEV_MODE = false setget _set_dev_mode			# developer mode enabled?

var AUTO_SAVE = true setget _set_auto_save			# autosave enabled?
var AUTO_SAVE_TIME = 10 setget _set_auto_save_time	# autosave interval in minutes

var BG_MODE = 1 setget _set_bg_mode
var BG_BLUR = true setget _set_bg_blur

var GUI_TINT = Color(1,1,1) setget _set_gui_tint
var GUI_LAMP_TINT = Color(1,1,1) setget _set_gui_lamp_tint

# START THE GAME
func start():
	# Check for save game
	var file = File.new()
	var x = file.file_exists(SAVEPATH)
	
	# Attempt to Restore game if one exists
	if x: restore_game()
	
	# Mark session start time (to measure session length)
	session_start_time = clock.get_time()
	
	# start the daycycle animation
	daycycle.start()


# QUIT THE GAME
# (called on quit request notification)
func quit():
	save_game()
	get_tree().quit()



# SAVE THE GAME
#
# Master save method
# All other save() methods are
# only called from here
func save_game(encrypt=false):
	var file = File.new()
	# Open file
	# take care when switching between encrypting/not-encrypting
	# files. Make backups!!
	if encrypt:
		file.open_encrypted_with_pass(SAVEPATH, File.WRITE, ENCRYPT_KEY)
	else:
		file.open(SAVEPATH, File.WRITE)
	
	# Assemble save data
	var data = {
		'quacks':		self.quacks,
		'version':		Version.version,
		'sleep_time':	OS.get_unix_time(),
		'clock':		clock.save(),
		'options':		options.save(),
		'play_time':	self.play_time + (clock.get_time() - self.session_start_time),

		}
	var save_items = []
	for node in items.get_children():
		save_items.append(node.save())
	data['items'] = save_items
	
	# store as json and close
	file.store_line(data.to_json())
	file.close()
	
	# Announce game saved
	emit_signal('game_saved')




# LOAD THE GAME
# (*Restore)
# Master load method
# All other load() methods are
# only called from here
func restore_game(encrypt=false):
	console.message("Loading saved data...")
	# Open file
	var file = File.new()
	var opened
	if encrypt:
		opened = file.open_encrypted_with_pass(SAVEPATH, File.READ, ENCRYPT_KEY)
	else:
		opened = file.open(SAVEPATH, File.READ)
	if !opened == OK:
		# Couldn't find file
		console.message("Expected a file at " + SAVEPATH)
		return
	# Found file
	console.message("Found save file at " + SAVEPATH)
	
	# Parse from json
	var data = {}
	while !file.eof_reached():
		data.parse_json(file.get_line())

	if 'quacks' in data:
		self.quacks = data.quacks
	
	# Version data: 
	# Comment on console if saved version differs from current
	if 'version' in data:
		var v = data.version
		var filever = str(v.major)+'.'+str(v.minor)+'.'+str(v.baby)
		if data.version != Version.get_version():
			console.message("Save file is from v"+filever+\
					". Welcome to v"+Version.get_version()+"!")
	
	
	# Restore modular data
	
	# Clock data
	if 'clock' in data:
		clock.restore(data.clock)
	
	# Options data
	if 'options' in data:
		options.restore(data.options)
	
	
	
	# Restore Misc. stuff
	
	# Sleep time : seconds since last quit
	if 'sleep_time' in data:
		self.sleep_duration = (OS.get_unix_time()-data.sleep_time) * TIMESCALE
	
	
	# Playtime data
	if 'play_time' in data:
		self.play_time = data.play_time
	
	# Print welcome message to console
	console.message("Welcome back!")
	console.message("+----------------+")
	console.Out.newline()
	
	# Announce game loaded
	emit_signal('game_loaded')
	file.close()




# SETTERS

func _set_quacks(what):
	quacks = what
	if console:
		console.message("QUACK QUACK!")

# Cout sleep duration
func _set_sleep_duration(what):
	sleep_duration = what
	console.message("You slept for " + str(int(sleep_duration)) + " seconds")
	clock.age += sleep_duration

# Cout dev mode toggle
func _set_dev_mode(what):
	if what != DEV_MODE:
		console.message(" -DEV MODE " + ["OFF","ON"][int(what)] + "- ")
	DEV_MODE = what


# Option setters
func _set_auto_save(what):
	if what != AUTO_SAVE:
		console.message(" -AUTOSAVE " + ["OFF","ON"][int(what)] + "- ")
	AUTO_SAVE = what


func _set_auto_save_time(what):
	AUTO_SAVE_TIME = what
	main.get_node('AutosaveTimer').set_wait_time(AUTO_SAVE_TIME*60) # convert to seconds
	main.get_node('AutosaveTimer').start()


func _set_bg_mode(what):
	BG_MODE = what
	# TODO Load the right background


func _set_bg_blur(what):
	BG_BLUR = what
	if background:
		background.set_blur(BG_BLUR)


func _set_gui_tint(what):
	GUI_TINT = what
	if main: 
		var c = GUI_TINT
		c = Color(c[0], c[1], c[2])
		main.get_node('GuiModulate').set_color(c)


func _set_gui_lamp_tint(what):
	GUI_LAMP_TINT = what
	if main: 
		var c = GUI_LAMP_TINT
		c = Color(c[0], c[1], c[2])
		main.get_node('GuiModulate/GuiLight').set_color(c)
