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

signal player_registered()

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
	print("peer connected")
	if is_server and Global.game_state == Global.ONLINEGAME:
		server.disconnect_peer(id)
		return
	print('new player connected')
	rpc_id(id, "add_player", get_tree().get_network_unique_id(), username)
	
func _network_peer_disconnected(id):
	print("peer disconnected")
	remove_player(id)
		
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
	var s = server.create_server(DEFAULT_PORT, max_clients)
	if s == ERR_CANT_CREATE:
		return false
	get_tree().set_network_peer(server)
	print("server created")
	# INSTANCE SERVER'S PLAYER
	if !Global.is_headless_server:
		is_server = true
		Global.game_state = Global.ONLINELOBBY
		add_player(get_tree().get_network_unique_id(), username)
		get_tree().change_scene("res://UI/OnlineLobby.tscn")
		return true
	return false
	
func join_server():
	client = NetworkedMultiplayerENet.new()
	print(ip_address)
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	print("client created")
	
func _connected_to_server():
	print("connected")
	yield(get_tree().create_timer(0.1), "timeout")
	# INSTANCE NEW CLIENT'S PLAYER
	add_player(get_tree().get_network_unique_id(), username)
	get_tree().change_scene("res://UI/OnlineLobby.tscn")
	
	
func _server_disconnected():
	print("disconnected")
	get_tree().change_scene("res://UI/Offline.tscn")
	
	
remotesync func add_player(id, _name):
	players[id] = {
		"name" : _name
	}
	emit_signal("player_registered", id)
	
remotesync func add_player_on_all_clients(id, _name):
	add_player(id, _name)
	
func remove_player(id):
	players.erase(id)

remotesync func remove_player_on_all_clients(id):
	remove_player(id)

func _exit_tree():
	if upnp:
		upnp.delete_port_mapping(DEFAULT_PORT)
	print("exited game")
