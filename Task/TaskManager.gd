extends ProgressBar



onready var queue = get_node('Queue')
onready var taskname = get_node('Label')

var max_tasks = 3

func get_task_count():
	return queue.get_child_count()

func task_queue_full():
	return get_task_count() >= max_tasks

func has_tasks():
	return queue.get_child_count() > 0

func get_current_task():
	return queue.get_child(0)


func clear():
	set_max(1)
	set_value(0)
	taskname.set_text('')


func add_task(task):
	queue.add_child(task)
	if get_current_task()==task:
		begin_task()



func begin_task():
	var task = get_current_task()
	task.connect("finished",self,"finish_task",[],4)
	set_value(0)
	taskname.set_text(task.task_action)
	task.begin_task()
	set_process(true)


func finish_task():
	queue.remove_child(get_current_task())
	
	if has_tasks():
		begin_task()
	else:
		clear()


func _ready():
	Game.taskmanager = self
	set_process(false)
	clear()


func _process(delta):
	if !has_tasks():
		set_process(false)
		return
	var time_left = get_current_task().get_percent_done()
	set_value(time_left)

