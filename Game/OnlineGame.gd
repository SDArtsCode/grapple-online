extends Node2D

const GAME_TIME : int = 60

var players : Array = [
	[],
	[]
]

var scores : Array = [0, 0]
onready var t_label = $UI/Control/CenterContainer/VBoxContainer/TimeLabel
onready var s_label = $UI/Control/CenterContainer/VBoxContainer/ScoreLabel
const PLAYER_SCENE = preload("res://Game/Player.tscn")

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
		var player_instance = PLAYER_SCENE.instance()
		add_child(player_instance)
		player_instance.name = Network.players.keys()[player]
		if Network.players.keys()[player] == self_id:
			player_instance.set_network_master(self_id)

func _process(_delta):
	pass

remotesync func update_time(new_time):
	$GameTimer.start(new_time)

remotesync func update_scores():
	s_label.update_score(scores)
