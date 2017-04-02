extends Control

signal started()
signal finished()

onready var timer = get_node('WorkTime')

# Name of task
var task_action = "Doing a Thing to the Stuff"

# No. of seconds it takes to complete the task
var length = 5 setget _set_length


func get_percent_done():
	return (self.length - timer.get_time_left()) / (self.length*1.0)

func begin_task():
	timer.start()
	emit_signal("started")

func finish_task():
	emit_signal("finished")


func _ready():
	timer.set_wait_time(self.length)
	timer.connect("timeout", self, "finish_task")


func _set_length(what):
	length = what
	get_node('WorkTime').set_wait_time(length)
