extends Control

onready var username_input = $CenterContainer/VBoxContainer/Username
onready var ip_input = $CenterContainer/VBoxContainer/IP

func _ready():
	if Global.is_headless_server:
		Network.create_server()
		
func _on_Server_pressed():
	if len(ip_input.text) > 0:
		Network.ip_address = ip_input.text
	if len(username_input.text) <= 0:
		$CenterContainer/VBoxContainer/ClientErr2.show()
		return
	else:
		$CenterContainer/VBoxContainer/ClientErr2.hide()
	Network.username = username_input.text
	var completed = Network.create_server() 
	if !completed:
		$CenterContainer/VBoxContainer/ServerErr.show()
	else:
		$CenterContainer/VBoxContainer/ServerErr.hide()
		
func _on_Client_pressed():
	if len(ip_input.text) > 0:
		Network.ip_address = ip_input.text
	if len(username_input.text) <= 0:
		$CenterContainer/VBoxContainer/ClientErr2.show()
		return
	else:
		$CenterContainer/VBoxContainer/ClientErr2.show()
	Network.username = username_input.text
	var completed = Network.join_server()
	if !completed:
		$CenterContainer/VBoxContainer/ClientErr.show()
	else:
		$CenterContainer/VBoxContainer/ClientErr.hide()
