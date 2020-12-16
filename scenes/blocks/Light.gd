extends Node2D


onready var animationPlayer = $AnimationPlayer
func _ready():
	var randTyme = randi() % 5 + 1
	
	yield(get_tree().create_timer(randTyme), "timeout")
	animationPlayer.play("change")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
