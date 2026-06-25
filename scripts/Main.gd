extends Control

func _unhandled_input(event: InputEvent) -> void:
	var start_pressed := false
	if event is InputEventKey and event.pressed:
		start_pressed = true
	elif event is InputEventMouseButton and event.pressed:
		start_pressed = true
	elif event is InputEventScreenTouch and event.pressed:
		start_pressed = true

	if start_pressed:
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
