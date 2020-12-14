extends Node2D


onready var staticBody = $StaticBody2D

func _ready():
	Signals.connect("card_is_stopped", self, "_cardIsStopped")
	Signals.connect("player_change_world", self, "_playerChangeWorld")
	#Signals.emit_signal("card_is_stopped",self, false)
	#	signal player_change_world(player, isInChanger)
	#Signals.emit_signal("player_change_world", self, true)
	pass 


func _playerChangeWorld(player, isInChanger):

	if isInChanger:
		staticBody.set_collision_layer_bit(2, true)
		staticBody.set_collision_layer_bit(1, false)
	else: 
		staticBody.set_collision_layer_bit(2, false)
		staticBody.set_collision_layer_bit(1, true)
	
	pass
	
