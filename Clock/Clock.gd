extends Control

const DAY_NAMES = [
	"Wunday",
	"Twosday",
	"Windsday",
	"Thorsday",
	"Freysday",
	"Satursday",
	"Sunsday"
	]

signal tick()


var age = 21455




func save():
	var data = {'age':	self.age}
	return data

func restore(data):
	if 'age' in data:
		self.age = data.age

func get_time():
	return self.age

func get_date():
	return {
		'year':		get_year(),
		'week':		get_week(),
		'day':		get_day(),
		'hour':		get_hour(),
		'minute':	get_minute(),
		'second':	get_second()
		}

func get_second():
	return int(self.age) % 60

func get_minute():
	return int(self.age/60) % 60

func get_hour():
	return int(self.age/(60*60)) % 24

func get_day():
	return 1 + int(self.age/(60*60*24)) % 7

func get_week():
	return 1 + int(self.age/(60*60*24*7)) % 52

func get_year():
	return Game.ZERO_YEAR + int(self.age/(60*60*24*7*52))

# return time of day expressed as 0-1
func get_day_offset():
	var o = (1.0*get_time_of_day()) / (1.0*Game.DAY_LENGTH)
	prints('offset',o)
	return o

func get_time_of_day():
	return int(self.age) % Game.DAY_LENGTH
	

func _ready():
	Game.clock = self
	set_process(true)
	connect('tick', self, '_on_tick')


func _process( delta ):
	var new_age = self.age + (delta*Game.TIMESCALE)
	if int(new_age) > int(self.age):
		emit_signal('tick')
	self.age = new_age

func _on_tick():
	var date = get_date()
	var time = str(date.hour).pad_zeros(2)+":"+str(date.minute).pad_zeros(2)+ ", day " +str(date.day)
	var date = "week "+str(date.week)+ " of the year " +str(date.year)
	get_node('Label').set_text(time+'\n'+date)


