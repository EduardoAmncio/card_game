extends Node2D



#signal card_is_stopped(card, valueOfState)



var isSelected = false;
var isToucheable = true;
var isAnimationFinish = true;
var count = 0;

enum STATES  {REST, FOLLOW, GOING_TO, RETURN_TO}
var state_current = null;
var state_next = null;
var state_preview = null;

var restZone: Node2D;
var arrZoneEntered = [];

func _ready():
	z_index = 50;
	restZone = null;
	$Label.text = "Sem Estado";
	state_current = -1;
	state_preview = -1;
	state_next = STATES.REST;
	#Signals.connect("card_is_stopped", self, )



func _physics_process(delta):
	
	if state_current != state_next:
		state_preview = state_current
		state_current = state_next;
	
	match state_current:
		STATES.REST:
			run_state_rest(delta);
	
		STATES.FOLLOW:
			run_state_follow(delta);
	
		STATES.GOING_TO:
			run_state_GOING_TO(delta);
	
		STATES.RETURN_TO:
			run_state_RETURN_TO(delta);



#===============================================================================
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=STATE FUNCTIONS=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#===============================================================================
#REST STATE:
func _initialize_rest():
	isToucheable = true;
	$Label.text = "REST";
	z_index = 50;
	state_next = STATES.REST;
	
	##emit_signal("card_is_stopped", self, true);
	#Signals.connect("card_is_stopped", self, )
	Signals.emit_signal("card_is_stopped",self, true)

func run_state_rest(delta):
	if isSelected:
	##	emit_signal("card_is_stopped", self, false);
		Signals.emit_signal("card_is_stopped",self, false)
		_initialize_follow();



#FOLLOW STATE:
func _initialize_follow():
	isToucheable = false;
	$Label.text = "FOLLOW";
	state_next = STATES.FOLLOW;

func run_state_follow(delta):
	_follow(delta);
	if !isSelected:
		if arrZoneEntered.empty():
			_initialize_RETURN_TO();
		else:
			_changeRestZone();
			_initialize_GOING_TO();



#GOING_TO STATE:
func _initialize_GOING_TO():
	isToucheable = false;
	$Label.text = "GOING TO";
	state_next = STATES.GOING_TO;

func run_state_GOING_TO(delta):
	if global_position.distance_to(restZone.global_position) > 1:
		global_position = lerp(global_position , restZone.global_position, 25.00 * delta);
	else: 
		_initialize_rest();



#RETURN_TO STATE:
func _initialize_RETURN_TO():
	isToucheable = false;
	$Label.text = "RETURN TO";
	state_next = STATES.RETURN_TO;

func run_state_RETURN_TO(delta):
	if global_position.distance_to(restZone.global_position) > 1:
		global_position = lerp(global_position , restZone.global_position, 25.00 * delta);
	else: 
		_initialize_rest();




#===============================================================================
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=FUNCTIONS=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#===============================================================================
func _follow(delta):
	global_position = lerp(self.global_position ,get_global_mouse_position(), 25.00 * delta);

func _selectCard(): 
	z_index = 300;
	isSelected = true;


func _deselectCard(): 
	isSelected = false;

func setRestZone(rest):
	restZone = rest;

func overlapingRestZone(restZone):
	return $Area2D.overlaps_area(restZone);

func _changeRestZone():
	var nearestZone = null;
	var minimalDistance = 100000;
	var distanceToZone = null;
	
	for restZone in arrZoneEntered:
		distanceToZone = global_position.distance_to(restZone.global_position);
		if distanceToZone < minimalDistance:
			minimalDistance = distanceToZone;
			nearestZone = restZone;
	
	if nearestZone.hasCard():
		nearestZone.cardRestHere.setRestZone(restZone);
		restZone.setCardRestInZone(nearestZone.cardRestHere);
		nearestZone.cardRestHere._initialize_GOING_TO();
		setRestZone(nearestZone);
		nearestZone.setCardRestInZone(self);
	else:
		if self.restZone:
			self.restZone.setCardRestInZone(null)
		setRestZone(nearestZone);
		nearestZone.setCardRestInZone(self);


#===============================================================================
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=TOUCH EVENTS=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#===============================================================================
func _on_Area2D_input_event(viewport, event, shape_idx):
	if isToucheable and Input.is_action_just_pressed("click"):
		_selectCard();

func _input(event):
	if event.is_action_released("click"):
		_deselectCard();

func _on_Area2D_area_entered(area):
	var restZone = area.get_parent();
	
	if !arrZoneEntered.has(restZone):
		arrZoneEntered.append(restZone);

func _on_Area2D_area_exited(area):
	var restZone = area.get_parent();
	
	if arrZoneEntered.has(restZone):
		arrZoneEntered.remove(arrZoneEntered.find(restZone));




func _on_AnimationPlayer_animation_finished(anim_name):
	isAnimationFinish = true;
	pass # Replace with function body.


func _on_AnimationPlayer_animation_started(anim_name):
	isAnimationFinish = false;
	pass # Replace with function body.
