extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const MATCH_TIME : int = 300
var time : float = MATCH_TIME

# Called when the node enters the scene tree for the first time.
func _ready():
	for player_key in Network.players.keys():
		pass
	if Network.is_server:
		pass

	get_tree().paused = true
	$transition.emitting = true
	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().paused = false

func _process(delta):
	if Network.is_server: 
		time -= delta
		rset_unreliable('time', time)
