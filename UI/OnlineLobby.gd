extends Control

const PLAYER_CARD = preload("res://UI/PlayerLobbyCard.tscn")
onready var team1 = $CenterContainer/VBoxContainer/HBoxContainer/Team1
onready var team2 = $CenterContainer/VBoxContainer/HBoxContainer/Team2
var is_team1 : bool = true

func _ready():
	#get_tree().connect("network_peer_connected", self,"_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self,"_network_peer_disconnected")
	if Network.is_server:
		Network.connect("player_registered", self, "_Network_player_registered")
		
	if Network.is_server:
		$CenterContainer3/VBoxContainer/Server.disabled = false

func add_player_card(id, _name, is_team1 : bool, is_ready):
	var card = PLAYER_CARD.instance()
	card.id = id
	card.set_name(_name)
	card.set_ready(is_ready)
	if is_team1:
		team1.add_child(card)
	else:
		team2.add_child(card)
	card.name = str(id)

func remove_player_card(id):
	if Network.players[id].is_team1:
		team1.get_node(str(id)).queue_free()
	else:
		team2.get_node(str(id)).queue_free()
	
#func _network_peer_connected(id):
#	add_player_card(id, Network.players[id].name, false)
#
func _network_peer_disconnected(id):
	remove_player_card(id)

func _Network_player_registered(id):
	pass

func _on_Server_pressed():
	Global.game_state = Global.ONLINEGAME
	Global.rpc("lobby_to_game")


func _on_Leave_pressed():
	Network.disconnect_self()
