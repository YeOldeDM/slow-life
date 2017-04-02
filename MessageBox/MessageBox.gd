extends RichTextLabel

func message(text):
	newline()
	append_bbcode(str(text))


func _ready():
	set_scroll_active(false)
	set_scroll_follow(true)


