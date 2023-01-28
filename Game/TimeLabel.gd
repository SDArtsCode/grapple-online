extends Label

export var timer_path : NodePath
var timer : Timer

func _ready():
	timer = get_node(timer_path)
	
func _process(delta):
	text = str(int(timer.time_left))
