extends Node

const DEFAULT_PORT = 28960
var max_clients = 3

var server : NetworkedMultiplayerENet = null
var client : NetworkedMultiplayerENet = null

var username = ""
var ip_address = ""
var upnp : UPNP = null

var is_server : bool = false
var avaliable_colors = ["#E2D136","#36E2AF","#36A4E2","#E2365F"]
var used_colors = avaliable_colors
var players : Dictionary = {
	
}

signal players_updated()

func _ready():
	if Global.is_headless_server:
		max_clients = 4
#	if OS.get_name() == "Windows":
#		ip_address = IP.get_local_addresses()[3]
#
#	for address in IP.get_local_addresses():
#		if address.begins_with("192.168.") and not address.ends_with(".1"):
#			ip_address = address
#			break
	
	ip_address = "127.0.0.1"
	
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_connected", self,"_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self,"_network_peer_disconnected")

func _network_peer_connected(id):
	# called when a new player connects or on each player when a player connects
	if is_server and Global.game_state == Global.ONLINEGAME:
		server.disconnect_peer(id)
		return
	# add self to a newly connected persons game
	if is_server:
		rpc_id(id, 'update_players', players)
	#rpc_id(id, "add_player", get_tree().get_network_unique_id(), username)
	
func _network_peer_disconnected(id):
	pass
		
func create_server() -> bool:
#	if upnp == null:
#		upnp = UPNP.new()
#		upnp.discover()
#		ip_address = upnp.query_external_address()
#	var err = upnp.add_port_mapping(DEFAULT_PORT)
#	if err != upnp.UPNP_RESULT_SUCCESS:
#		push_error("Unable to port forward" + str(err))
#	print(ip_address)
	
	server = NetworkedMultiplayerENet.new()
	var err = server.create_server(DEFAULT_PORT, max_clients)
	if err != OK:
		server = null
		return false
	get_tree().set_network_peer(server)
	print("server created")
	# INSTANCE SERVER'S PLAYER
	if !Global.is_headless_server:
		is_server = true
		Global.game_state = Global.ONLINELOBBY
		# add self to our own game
		add_player(get_tree().get_network_unique_id(), username)
		get_tree().change_scene("res://UI/OnlineLobby.tscn")
		return true
	return false
	
func join_server() -> bool:
	if client:
		disconnect_self()
	client = NetworkedMultiplayerENet.new()
	var err = client.create_client(ip_address, DEFAULT_PORT)
	if err != OK:
		client = null
		return false
	get_tree().set_network_peer(client)
	print("client created")
	return true
	
func _connected_to_server():
	yield(get_tree().create_timer(0.1), "timeout")
	# INSTANCE NEW CLIENT'S PLAYER
	# add self to our own game
	#add_player(get_tree().get_network_unique_id(), username)
	rpc_id(0, 'add_player', get_tree().get_network_unique_id(), username)
	get_tree().change_scene("res://UI/OnlineLobby.tscn")

func disconnect_self():
	if is_server:
		server.close_connection()
		is_server = false
		server = null
	else:
		client.close_connection()
		client = null
	username = ""
	ip_address = ""
	get_tree().change_scene("res://UI/Offline.tscn")
	
func _server_disconnected():
	get_tree().change_scene("res://UI/Offline.tscn")
	
	
remotesync func add_player(id, _name):
	if is_server:
		var t1 = 0
		var t2 = 0
		for player in players.keys():
			if players[player].is_team1:
				t1 += 1
			else:
				t2 += 1
		var tdiff = t1-t2
		var is_team1 = true
		if tdiff > 0:
			is_team1 = false
		players[id] = {
			"name" : _name,
			"is_team1" : is_team1
		}
		rpc('update_players', players)
		print(players)

remotesync func update_players(new_players):
	players = new_players
	emit_signal("players_updated", new_players)
	
func remove_player(id):
	players.erase(id)

func _exit_tree():
	if upnp:
		upnp.delete_port_mapping(DEFAULT_PORT)
	print("exited game")
