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
