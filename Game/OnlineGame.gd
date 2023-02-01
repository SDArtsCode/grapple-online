extends Node2D

const GAME_TIME : int = 30

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
onready var ball = $Ball

func _ready():
	if Network.is_server:
		rpc('init_func_calls', GAME_TIME)
		rpc('update_time', GAME_TIME)
		rpc('update_scores')
		rpc('load_players')

#func init_func_calls(new_game_time):
#	load_players()
#	update_scores()
#	update_time(new_game_time)
#	reset_pos()
	
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
	reset_pos()
	
remotesync func update_time(new_time):
	$GameTimer.start(new_time)

remotesync func update_scores():
	s_label.update_score(scores)

remotesync func reset_pos():
	if Network.is_server:
		ball.reset_position = $BallStarter.global_position
		ball.reset_state = true
	for player_key in Network.players.keys():
		var p = get_node(str(player_key))
		if p.is_team1:
			p.global_position = team1_starter.global_position
		else:
			p.global_position = team2_starter.global_position
			
remotesync func end_game():
	get_tree().change_scene("res://UI/OnlineLobby.tscn")

#this function is or if not SHOULD only be called on server
func add_goal(for_team1 : bool):
	if for_team1:
		scores[0] += 1
	else:
		scores[1] += 1
	rpc('update_scores')
	rpc('reset_pos')

func _on_GameTimer_timeout():
	if Network.is_server:
		rpc('end_game')
