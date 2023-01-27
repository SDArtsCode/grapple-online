extends Control

const PLAYER_CARD = preload("res://UI/PlayerLobbyCard.tscn")

func _ready():
	#get_tree().connect("network_peer_connected", self,"_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self,"_network_peer_disconnected")
	Network.connect("player_registered", self, "_Network_player_registered")
	
	for player_key in Network.players.keys():
		print(Network.players)
		add_player_card(player_key, Network.players[player_key].name, false)
	if Network.is_server:
		$CenterContainer3/VBoxContainer/Server.disabled = false
		
func add_player_card(id, _name, is_ready):
	var card = PLAYER_CARD.instance()
	card.id = id
	card.set_name(_name)
	card.set_ready(is_ready)
	$CenterContainer/VBoxContainer.add_child(card)
	card.name = str(id)

func remove_player_card(id):
	if is_instance_valid($CenterContainer/VBoxContainer.get_node(str(id))):
		$CenterContainer/VBoxContainer.get_node(str(id)).queue_free()
	
#func _network_peer_connected(id):
#	add_player_card(id, Network.players[id].name, false)
#
func _network_peer_disconnected(id):
	remove_player_card(id)

func _Network_player_registered(id):
	add_player_card(id, Network.players[id].name, false)


func _on_Server_pressed():
	Global.game_state = Global.ONLINEGAME
	Global.rpc("lobby_to_game")


func _on_Leave_pressed():
	if Network.is_server:
		Network.server.close_connection()
	else:
		Network.client.close_connection()
	get_tree().change_scene("res://UI/Offline.tscn")
