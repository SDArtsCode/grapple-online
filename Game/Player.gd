extends KinematicBody2D


var is_team1 : bool = true

const max_speed := 200.0
const dash_regen_rate := 2.5
const max_dashes := 3
const dash_speed := 30.0/4.0
const ring_size := 400.0
const PULL_SPEED := 10.0
const MAX_HOOKTIME := 2.5

var dashes := 0
var hooked := false
var dash_timer = 0.0
var hook_timer = 0.0
var velocity := Vector2.ZERO
var color = Color(0,0,0)
var radius := 20.0
var accel := 20.0
var ACCEL := accel

func _ready():
	pass
		
func _physics_process(delta):
	if is_network_master():
		dash_timer += delta
		if dash_timer >= dash_regen_rate:
			if dashes < max_dashes:
				dashes += 1
			dash_timer = 0.0
		
		var dir: Vector2
		dir.x = int(Input.is_action_pressed("right"))-int(Input.is_action_pressed("left"))
		dir.y = int(Input.is_action_pressed("down"))-int(Input.is_action_pressed("up"))
		accel = ACCEL
		if hooked: 
			accel = ACCEL*3
		velocity = lerp(velocity, dir.normalized()*max_speed, delta*accel)
		move_and_slide(velocity)
		rpc_unreliable("update_player_pos", global_position)
	update()
	
remote func update_player_pos(new_pos):
	global_position = new_pos
	
func _input(event):
	if !is_network_master():
		return
	if event.is_action_pressed("dash") and dashes > 0:
		dashes -= 1
		velocity = velocity.normalized()*dash_speed
		if hooked:
			# change max speed of ball x2
			velocity *= 3
		dash_timer = 0.0
		
	if event.is_action_pressed("hook"):
		hooked = true
		
	if event.is_action_released("hook"):
		hooked = false
		
func _draw():
	if hooked:
		draw_line(Vector2.ZERO, Global.ball.global_position-global_position, Color(1,1,1), 5, true)

func change_dash(num = 1):
	if num > 0:
		pass
	elif num < 0:
		pass
	else: 
		return
