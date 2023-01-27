extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if Network.is_server:
		$Control/MarginContainer/VBoxContainer/Server.disabled = false
#	else:
#		$Control/MarginContainer/VBoxContainer/Client.disabled = false

func _on_Server_pressed():
	rpc("end_game")

remotesync func end_game():
	if Network.is_server:
		Network.server.close_connection()
	else:
		Network.client.close_connection()

func _on_Client_pressed():
	Network.client.close_connection()
