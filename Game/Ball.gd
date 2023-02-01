extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player_hooked = null
var hook_weight : Vector2 = Vector2()
var reset_state = false
var reset_position = Vector2()

func _ready():
	if !Network.is_server:
		mode = MODE_KINEMATIC
		
func _integrate_forces(state):
	if Network.is_server:
		if reset_state:
			state.transform = Transform2D(0.0, reset_position)
			state.linear_velocity = Vector2()
			rpc('update_pos', reset_position)
			reset_state = false
			return
		if player_hooked != null:
			hook_weight = (player_hooked.global_position - global_position) * 10.0
			apply_central_impulse(hook_weight * state.step)
		rpc_unreliable('update_pos', global_position)
	

remotesync func set_player_hooked(new_player):
	player_hooked = new_player

remote func update_pos(new_pos):
	global_position = new_pos
