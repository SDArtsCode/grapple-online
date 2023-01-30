extends Node

var is_headless_server = false

enum {
	OFFLINE,
	ONLINELOBBY,
	ONLINEGAME
}

var game_state = OFFLINE

remotesync func lobby_to_game():
	game_state = ONLINEGAME
	get_tree().change_scene("res://Game/OnlineGame.tscn")

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	
func _process(_delta):
	if Input.is_action_just_pressed("quick_exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("quick_restart"):
		get_tree().reload_current_scene()
