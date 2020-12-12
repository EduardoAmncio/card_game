extends KinematicBody2D


var canChangeScene = false;
var respawnPosition = null;

#Consts for moviment:
const TARGET_FPS = 60
const ACCELERATION = 2
const MAX_SPEED = 50
const FRICTION = 5
const AIR_RESISTANCE = 0
const GRAVITY = 15
const JUMP_FORCE = 500

var motion = Vector2.ZERO
enum DIRECTION {LEFT=-1, RIGHT=1}

#childreans nodes:
#onready var catPlayer = $CatPlayer

onready var label = $Label
onready var player = $CatPlayer
#onready var animationPlayer = $AnimationPlayer


#STATE CONTROLS:
enum STATES {WALK, STOP}
var state_current = null;
var state_next = null;
var state_preview = null;

var x_input = null;

func _ready():
	#set_physics_process(false)
	state_current = -1;
	state_preview = -1;
	state_next = STATES.WALK;
	
	x_input = DIRECTION.RIGHT;
	player.flipRight()
	
	Signals.connect("card_is_stopped", self, "_cardIsStopped")
	



func _physics_process(delta):
	
	if state_current != state_next:
		state_preview = state_current
		state_current = state_next;
	
	match state_current:
		STATES.WALK:
			_run_state_walk(delta);
	
		STATES.STOP:
			_run_state_stop(delta);
	
	
	
	
	#----- will be removed from here to functions.
	#var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	#if x_input != 0:
#		animationPlayer.play("Run")
	#	motion.x += x_input * ACCELERATION * delta * TARGET_FPS
	#	motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
	#	sprite.flip_h = x_input < 0
#	else:
#		animationPlayer.play("Stand")
	
	#motion.y += GRAVITY * delta * TARGET_FPS
	
	#if is_on_floor():
	#	if x_input == 0:
	#		motion.x = lerp(motion.x, 0, FRICTION * delta)
	#		
	#	if Input.is_action_just_pressed("ui_up"):
	#		motion.y = -JUMP_FORCE
	#else:
#	#	animationPlayer.play("Jump")
	#	
	#	if Input.is_action_just_released("ui_up") and motion.y < -JUMP_FORCE/2:
	#		motion.y = -JUMP_FORCE/2
	#	
	#	if x_input == 0:
	#		motion.x = lerp(motion.x, 0, AIR_RESISTANCE * delta)
	
	#motion = move_and_slide(motion, Vector2.UP)


#STATES:
#------------------------state WALK---------------------------------------------
func _initialize_state_stop():
	state_next = STATES.STOP;

func _run_state_stop(delta):
	#muda sprite por exemplo
	pass;



func _initialize_state_walk():
#	$Label.text = "REST";
#	z_index = 50;
	state_next = STATES.WALK;

func _run_state_walk(delta):
	_walk(delta);
	pass;

func _walk(delta):
	
	
	if is_on_wall():
		if not canChangeScene:
			if x_input == DIRECTION.RIGHT:
				x_input = DIRECTION.LEFT;
				player.flipLeft()
			else:
				x_input = DIRECTION.RIGHT;
				player.flipRight()
		elif !!respawnPosition:
			global_position = respawnPosition;
	
	if x_input != 0:
#		animationPlayer.play("Run")
		motion.x += x_input * ACCELERATION * delta * TARGET_FPS
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		
		
		#catPlayer.flip_h = x_input < 0


#	else:
#		animationPlayer.play("Stand")
	
	motion.y += GRAVITY * delta * TARGET_FPS
	
	if is_on_floor():
		if x_input == 0:
			motion.x = lerp(motion.x, 0, FRICTION * delta)
			
	#	if Input.is_action_just_pressed("ui_up"):
	#		motion.y = -JUMP_FORCE
	else:
#		animationPlayer.play("Jump")
		
		if Input.is_action_just_released("ui_up") and motion.y < -JUMP_FORCE/2:
			motion.y = -JUMP_FORCE/2
		
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE * delta)
	
	motion = move_and_slide(motion, Vector2.UP)
	pass;


func _cardIsStopped(card, valueOfState):
	#signal card_is_stopped(card, valueOfState)
	set_physics_process(!!valueOfState);
	pass


func _on_Sensor_area_entered(area):
	canChangeScene = true;
	respawnPosition = area.returnRespawnPosition();
	pass # Replace with function body.


func _on_Sensor_area_exited(area):
	canChangeScene = false;
	respawnPosition = null;
	pass # Replace with function body.
