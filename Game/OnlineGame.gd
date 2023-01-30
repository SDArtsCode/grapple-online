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
		
remote func load_players():
	var self_id = get_tree().get_network_unique_id()
	for player_key in Network.players.keys():
		var player_instance = PLAYER_SCENE.instance()
		add_child(player_instance)
		player_instance.name = str(player_key)
		player_instance.is_team1 = Network.players[player_key].is_team1
		print('looped through player')
		if player_key == self_id:
			print('assigned self player')
			player_instance.set_network_master(self_id)
	print(get_children())
func _process(_delta):
	pass

remotesync func update_time(new_time):
	$GameTimer.start(new_time)

remotesync func update_scores():
	s_label.update_score(scores)
