extends Node2D


onready var animationPlayer = $AnimationPlayer;

func _ready():
	walkCat();
	pass 


func flipLeft():
	animationPlayer.play("flip_left")

func flipRight():
	animationPlayer.play("flip_right")

func walkCat():
	animationPlayer.play("walk")
	
func goTo():
	animationPlayer.play("go_to")

func jump():
	animationPlayer.play("Jump")

func fall():
	animationPlayer.play("fall")
	
func death():
	animationPlayer.play("death")
	
func die():
	animationPlayer.play("die")
