extends Control

const PLAYER_CARD = preload("res://UI/PlayerLobbyCard.tscn")
onready var team1 = $CenterContainer/VBoxContainer/HBoxContainer/Team1
onready var team2 = $CenterContainer/VBoxContainer/HBoxContainer/Team2
var is_team1 : bool = true

func _ready():
	#get_tree().connect("network_peer_connected", self,"_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self,"_network_peer_disconnected")
	Network.connect("players_updated", self, "_Network_players_updated")
	
	if Network.is_server:
		$CenterContainer3/VBoxContainer/Server.disabled = false
	for player_key in Network.players.keys():
		add_player_card(player_key, false)
		
remotesync func add_player_card(id, is_ready):
	var card = PLAYER_CARD.instance()
	card.id = id
	card.set_name(Network.players[id].name)
	card.set_ready(is_ready)
	if Network.players[id].is_team1:
		team1.add_child(card)
	else:
		team2.add_child(card)
	card.name = str(id)

func remove_player_card(id):
	print(Network.players)
	print(id)
	if Network.players[id].is_team1:
		team1.get_node(str(id)).queue_free()
	else:
		team2.get_node(str(id)).queue_free()
	
#func _network_peer_connected(id):
#	add_player_card(id, Network.players[id].name, false)
#
func _network_peer_disconnected(id):
	remove_player_card(id)
	Network.remove_player(id)
	
func _Network_players_updated(new_players):
	Network.players = new_players
	for player_key in Network.players.keys():
		if Network.players[player_key].is_team1:
			if !team1.has_node(NodePath(str(player_key))):
				add_player_card(player_key, false)
		else:
			if !team2.has_node(NodePath(str(player_key))):
				add_player_card(player_key, false)
	#rpc('add_player_card', id, false)
	print('registered on server')
		
func _on_Server_pressed():
	Global.game_state = Global.ONLINEGAME
	Global.rpc("lobby_to_game")


func _on_Leave_pressed():
	Network.disconnect_self()
