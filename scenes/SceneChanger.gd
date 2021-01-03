extends CanvasLayer


signal scene_changed()

onready var animationPlayer = $AnimationPlayer
onready var colorRect = $Control/ColorRect



func change_scene(path, delay = 2.0):
	colorRect.visible = true
	yield(get_tree().create_timer(delay), "timeout")
	animationPlayer.play("fade_in")
	yield(animationPlayer, "animation_finished")
	
	assert(get_tree().change_scene(path) == OK)
	
	animationPlayer.play_backwards("fade_in")
	yield(animationPlayer, "animation_finished")
	colorRect.visible = false
