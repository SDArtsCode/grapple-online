extends Node2D

const GAME_TIME : int = 60

var players : Array = [
	[],
	[]
]

var scores : Array = [0, 0]
onready var t_label = $UI/Control/CenterContainer/VBoxContainer/TimeLabel
onready var s_label = $UI/Control/CenterContainer/VBoxContainer/ScoreLabel

func _ready():
	load_players()
	if Network.is_server:
		#$GameTimer.start(GAME_TIME)
		rpc('update_time', GAME_TIME)
		rpc('update_scores')
		rpc('load_players')
		
remotesync func load_players():
	var self_id = get_tree().get_network_unique_id()
	for player in Network.players:
		pass
	pass

func _process(_delta):
	pass

remotesync func update_time(new_time):
	$GameTimer.start(new_time)

remotesync func update_scores():
	s_label.update_score(scores)
