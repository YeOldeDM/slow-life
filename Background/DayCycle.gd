extends AnimationPlayer

func get_position_from_day():
	var alen = get_current_animation_length()
	return alen * Game.clock.get_day_offset()

func start():
	play('day')
	var pos = get_position_from_day()
	prints('pos',pos)
	seek(pos)
	var alen = get_current_animation_length()
	var spd = Game.TIMESCALE * ((1.0*alen) / (1.0*Game.DAY_LENGTH))
	set_speed(spd)



func _ready():
	Game.daycycle = self