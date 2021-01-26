extends KinematicBody2D




var canChangeScene = false;
var getCrystal = false;

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
onready var player = $CatPlayer
onready var particlesTrace = $ParticleTrace
#onready var particlesStars = $stars

#STATE CONTROLS:
enum STATES {WALK, STOP, CHANGE_SCENE, FINISHI_WORLD}
var state_current = null;
var state_next = null;
var state_preview = null;

var x_input = null;
var actualScene = null;
var sceneToGo = null;
var positionToGoUp = null;
var positionToGoHorizon = null;


var caindo = false;

func _ready():
	state_current = -1;
	state_preview = -1;
	state_next = STATES.WALK;
	particlesTrace.emitting = false
	
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
		
		STATES.FINISHI_WORLD:
			_run_state_finishWorld(delta);


#STATES:
#------------------------state CHANGE FINISH WORLD------------------------------
func _initialize_state_finishWorld():
	state_next = STATES.FINISHI_WORLD
	player.goTo()
	#print(actualScene.returnNextScene())
	print(get_tree().get_root().get_node("World").returnNextScene())
	
	SceneChanger.change_scene(get_tree().get_root().get_node("World").returnNextScene());
	pass

func _run_state_finishWorld(delta):
	motion.x = 0
	motion.y = -(JUMP_FORCE / 16)
	motion = move_and_slide(motion, Vector2.UP)
	pass

#STATES:
#------------------------state CHANGE SCENE-------------------------------------
func _initialize_state_changeScene():
	
	particlesTrace.emitting = true
	Signals.canMoveCards = false;
	Signals.emit_signal("player_change_world", self, true)
	state_next = STATES.CHANGE_SCENE;
	if caindo:
		player.fall()
		pass
	else:
		player.jump()

func _run_state_changeScene(delta):

	if sceneToGo:
		canChangeScene = false
		var lastPosition = global_position
		positionToGoUp = Vector2(lastPosition.x, lastPosition.y -100);
		
		actualScene.remove_child(self)
		sceneToGo.add_child(self);
		global_position = lastPosition
		positionToGoHorizon = Vector2(sceneToGo.global_position.x, lastPosition.y -100);
		actualScene = sceneToGo
		sceneToGo = null

	var continueMove = false
	var moveHorizon = false


	_jump(delta)
	
	if is_on_floor():
		var timer = 0.8;
		if caindo:
			timer = 0.01;
		if !caindo:
			yield(get_tree().create_timer(timer), "timeout")
		_initialize_state_walk()
		caindo = false
		Signals.canMoveCards = true
		Signals.emit_signal("player_change_world", self, false)
		particlesTrace.emitting = false
		#particlesStars.emitting = false
		pass

	pass;

#------------------------state STOP---------------------------------------------
func _initialize_state_stop():
	print("_initialize_state_stop")
	state_next = STATES.STOP;

func _run_state_stop(delta):
	#muda sprite por exemplo
	pass;

#------------------------state WALK---------------------------------------------
func _initialize_state_walk():
	print("_initialize_state_walk")
	state_next = STATES.WALK;
	player.walkCat()

func _run_state_walk(delta):
	
	_walk(delta);
	if canChangeScene and is_on_wall():
		_initialize_state_changeScene();
	elif canChangeScene and not is_on_floor():
		#_initialize_state_changeSceneOnFall();
		caindo = true
		_initialize_state_changeScene();
	elif getCrystal:
		_initialize_state_finishWorld();
	
	pass;

func _walk(delta):
	
	if is_on_wall():
		if x_input == DIRECTION.RIGHT:
			x_input = DIRECTION.LEFT;
			player.flipLeft()
		else:
			x_input = DIRECTION.RIGHT;
			player.flipRight()

	if x_input != 0:
		motion.x += x_input * ACCELERATION * delta * TARGET_FPS
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		
	motion.y += GRAVITY * delta * TARGET_FPS
	
	if is_on_floor():
		if x_input == 0:
			motion.x = lerp(motion.x, 0, FRICTION * delta)
	else:
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE * delta)
	
	motion = move_and_slide(motion, Vector2.UP)
	pass;

func _jump(delta):

	if x_input != 0 and !caindo:
		var speedForJump = MAX_SPEED + 80
		motion.x += x_input * ACCELERATION * delta * TARGET_FPS
		motion.x = clamp(motion.x, speedForJump * x_input, speedForJump * x_input)

	motion.y += GRAVITY * delta * TARGET_FPS
	
	if is_on_floor():
		if x_input == 0:
			motion.x = lerp(motion.x, 0, FRICTION * delta)
		if !caindo:
			motion.y = -JUMP_FORCE
	elif !caindo:
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE * delta)
	
	motion = move_and_slide(motion, Vector2.UP)
	pass

func goTo(delta, destinyPosition):
	
	var direction_vector = (destinyPosition - global_position)
	if direction_vector.length() < 3:
		return false
	var speed = Vector2(120, 120)
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

	pass

func _on_Sensor_area_exited(area):
	if state_current == STATES.CHANGE_SCENE:
		return 
	canChangeScene = false;
	sceneToGo = null;
	pass


func _on_SensorCrystal_area_entered(area):
	getCrystal = true
	pass # Replace with function body.


func _on_SensorCrystal_area_exited(area):
	getCrystal = false
	pass # Replace with function body.
