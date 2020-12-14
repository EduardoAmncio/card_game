extends KinematicBody2D




var canChangeScene = false;
#v#ar respawnPosition = null;

#Consts for moviment:
const TARGET_FPS = 60
const ACCELERATION = 2
const MAX_SPEED = 50
const FRICTION = 5
const AIR_RESISTANCE = 0
const GRAVITY = 15
const JUMP_FORCE = 350

var motion = Vector2.ZERO
enum DIRECTION {LEFT=-1, RIGHT=1}

#childreans nodes:
#onready var catPlayer = $CatPlayer
onready var player = $CatPlayer
onready var particlesTrace = $ParticleTrace
onready var particlesStars = $stars
#onready var animationPlayer = $AnimationPlayer


#STATE CONTROLS:
enum STATES {WALK, STOP, CHANGE_SCENE}
var state_current = null;
var state_next = null;
var state_preview = null;

var x_input = null;
var actualScene = null;
var sceneToGo = null;
var positionToGoUp = null;
var positionToGoHorizon = null;

func _ready():
	#set_physics_process(false)
	state_current = -1;
	state_preview = -1;
	state_next = STATES.WALK;
	particlesTrace.emitting = false
	particlesStars.emitting = false
	
	
	actualScene = get_parent();
	sceneToGo = get_parent();
	
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
		
		STATES.CHANGE_SCENE:
			_run_state_changeScene(delta);
	
	
	
	
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
#------------------------state CHANGE SCENE-------------------------------------
func _initialize_state_changeScene():
	particlesTrace.emitting = true
	particlesStars.emitting = true
	Signals.canMoveCards = false;
	Signals.emit_signal("player_change_world", self, true)
	state_next = STATES.CHANGE_SCENE;
	player.jump()
	
	#get_parent().remove_child(self);
	#actualScene.add_child(self);
	

func _run_state_changeScene(delta):
	#muda sprite por exemplo
#	var actualScene = null;
#var sceneToGo = null;
	if sceneToGo:
		
		canChangeScene = false
		var lastPosition = global_position
		positionToGoUp = Vector2(lastPosition.x, lastPosition.y -100);
		
		
		actualScene.remove_child(self)
		sceneToGo.add_child(self);
		global_position = lastPosition
		positionToGoHorizon = Vector2(sceneToGo.global_position.x, lastPosition.y -100);

		#global_position = sceneToGo.global_position;
		actualScene = sceneToGo
		sceneToGo = null
		
	#var continueMove = goTo(delta, actualScene.global_position)
	var continueMove = false
	var moveHorizon = false
	
	#if positionToGoUp:
		#continueMove = goTo(delta, positionToGoUp)
	#	_jump(delta)
	
#	if !continueMove:
#		positionToGoUp = null;
		#moveHorizon = goTo(delta, positionToGoHorizon)
	_jump(delta)
	
	if is_on_floor():
		yield(get_tree().create_timer(0.8), "timeout")
		_initialize_state_walk()
		Signals.canMoveCards = true
		Signals.emit_signal("player_change_world", self, false)
		particlesTrace.emitting = false
		particlesStars.emitting = false
		pass
		
	#	_initialize_state_walk()
	#	Signals.canMoveCards = true
	#	Signals.emit_signal("player_change_world", self, false)
		
	
		#if !moveHorizon:
	#_initialize_state_walk()
			
	#Signals.canMoveCards = true
	#Signals.emit_signal("player_change_world", self, false)
		
	pass;

#------------------------state STOP---------------------------------------------
func _initialize_state_stop():
	state_next = STATES.STOP;

func _run_state_stop(delta):
	#muda sprite por exemplo
	pass;

#------------------------state WALK---------------------------------------------
func _initialize_state_walk():
	state_next = STATES.WALK;
	player.walkCat()

func _run_state_walk(delta):
	
	_walk(delta);
	if canChangeScene and is_on_wall():
		_initialize_state_changeScene();
	pass;

func _walk(delta):
	
	if is_on_wall():
		
		if x_input == DIRECTION.RIGHT:
			x_input = DIRECTION.LEFT;
			player.flipLeft()
		else:
			x_input = DIRECTION.RIGHT;
			player.flipRight()
	#	if not canChangeScene:
	#		if x_input == DIRECTION.RIGHT:
	#			x_input = DIRECTION.LEFT;
	#			player.flipLeft()
	#		else:
	#			x_input = DIRECTION.RIGHT;
	#			player.flipRight()
	#	elif !!respawnPosition:
	#		global_position = respawnPosition;
	
	if x_input != 0:
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
		
	#	if Input.is_action_just_released("ui_up") and motion.y < -JUMP_FORCE/2:
	#		motion.y = -JUMP_FORCE/2
		
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE * delta)
	
	motion = move_and_slide(motion, Vector2.UP)
	pass;

func _jump(delta):

	if x_input != 0:
		var speedForJump = MAX_SPEED + 80
		motion.x += x_input * ACCELERATION * delta * TARGET_FPS
		motion.x = clamp(motion.x, speedForJump * x_input, speedForJump * x_input)

	motion.y += GRAVITY * delta * TARGET_FPS
	
	if is_on_floor():
		if x_input == 0:
			motion.x = lerp(motion.x, 0, FRICTION * delta)
		motion.y = -JUMP_FORCE
	else:
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE * delta)
	
	motion = move_and_slide(motion, Vector2.UP)
	pass

func goTo(delta, destinyPosition):
	
	var direction_vector = (destinyPosition - global_position)
	if direction_vector.length() < 3:
		return false
			
	var speed = Vector2(120, 120)

#	lerp(global_position, 0, 20)
	
	var velocity = move_and_slide(direction_vector.normalized() * speed)
	
	return true



func _cardIsStopped(card, valueOfState):
	set_physics_process(!!valueOfState);
	pass
	








func _on_Sensor_area_entered(area):
	if state_current == STATES.CHANGE_SCENE:
		return 
	canChangeScene = true;
	
	sceneToGo = area.returnSceneNode();
	#respawnPosition = area.global_position;
	
#	var new_parent = get_node("/root/AnotherParent")
#get_parent().remove_child(self)
#new_parent.add_child(self)
	
	pass # Replace with function body.

func _on_Sensor_area_exited(area):
	if state_current == STATES.CHANGE_SCENE:
		return 
	canChangeScene = false;
	#respawnPosition = null;
	sceneToGo = null;
	pass # Replace with function body.
