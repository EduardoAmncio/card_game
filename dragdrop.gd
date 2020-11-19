extends Node2D

var isSelected = false;
var isToucheable = true;
var count = 0;


enum STATES  {REST, FOLLOW, GOINGTO}
var state_current = null
var state_next = null
var state_preview = null

func _ready():
	$Label.text = "Sem Estado";
	state_current = -1;
	state_preview = -1;
	state_next = STATES.REST;
	
	pass # Replace with function body.
	

func _physics_process(delta):
	#if isSelected:
		
		#self._goToNewPosition(get_global_mouse_position(), delta);
		
	if state_current != state_next:
		state_preview = state_current
		state_current = state_next;
		
	match state_current:
		STATES.REST:
			run_state_rest(delta);
			pass
		STATES.FOLLOW:
			run_state_follow(delta);
			pass
		STATES.GOINGTO:
			pass

#REST STATE:
func _initialize_rest():
	print("entrou no init REST");
	$Label.text = "REST";
	state_next = STATES.REST;
	pass

func run_state_rest(delta):
	if isSelected:
		_initialize_follow();
	pass
	
#FOLLOW STATE:
func _initialize_follow():
	print("entrou no init FOLLOW");
	$Label.text = "FOLLOW";
	state_next = STATES.FOLLOW;
	pass

func run_state_follow(delta):
	_follow(delta);
	
	if !isSelected:
		_initialize_rest();
	pass

#GOINGTO STATE:
func _initialize_goingTo():
	$Label.text = "GOING TO";
	state_next = STATES.GOINGTO;
	pass

func run_state_goingTo(delta):
	pass



func _follow(delta):
	self.global_position = lerp(self.global_position ,get_global_mouse_position(), 25.00 * delta);


func _selectCard(): 
	z_index = 100;
	isSelected = true;
	
func _deselectCard(): 
	z_index = 10;
	isSelected = false;






#===============================================================================
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=EVENTOS DE TOUCH=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#===============================================================================
func _on_Area2D_input_event(viewport, event, shape_idx):
	
	if isToucheable and Input.is_action_just_pressed("click"):
		#$Label.text = "Following"
		_selectCard();



func _input(event):
	if event.is_action_released("click"):
		#$Label.text = "Dragged"
		_deselectCard();
