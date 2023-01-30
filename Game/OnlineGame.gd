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
onready var team1_starter = $Team1Starter
onready var team2_starter = $Team2Starter

func _ready():
	if Network.is_server:
		#$GameTimer.start(GAME_TIME)
		rpc('update_time', GAME_TIME)
		rpc('update_scores')
		rpc('load_players')
		add_goal(true)
		
remotesync func load_players():
	var self_id = get_tree().get_network_unique_id()
	for player_key in Network.players.keys():
		var player_instance = preload("res://Game/Player.tscn").instance()
		player_instance.name = str(player_key)
		player_instance.set_network_master(player_key)
		add_child(player_instance)
		player_instance.get_node('Label').text = Network.players[player_key].name
		player_instance.is_team1 = Network.players[player_key].is_team1
		if player_instance.is_team1:
			global_position = team1_starter.global_position
		else:
			global_position = team2_starter.global_position
	print(get_children())

remotesync func update_time(new_time):
	$GameTimer.start(new_time)

remotesync func update_scores():
	s_label.update_score(scores)

func add_goal(for_team1 : bool):
	if for_team1:
		scores[0] += 1
	else:
		scores[1] += 1
	rpc('update_scores')
