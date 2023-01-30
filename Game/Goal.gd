extends Area2D


export var owned_by_team1 : bool = false

func _ready():
	set_network_master(1)

func _on_Goal_body_entered(body):
	if is_network_master() and body.is_in_group('ball'):
		if owned_by_team1:
			get_parent().add_goal(true)
		else:
			get_parent().add_goal(false)
