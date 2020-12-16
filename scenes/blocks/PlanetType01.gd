extends Node2D


onready var animarionPlayer = $AnimationPlayer


func _ready():
	animarionPlayer.play("rotation")
	pass # Replace with function body.
