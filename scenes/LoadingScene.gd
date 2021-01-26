extends Node2D

func change_scene(path, delay = 0.5):
	yield(get_tree().create_timer(delay), "timeout");
