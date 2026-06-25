extends CanvasLayer

func _ready() -> void:
	visible = false
	$Panel/RestartButton.pressed.connect(_on_restart_pressed)

func show_game_over(final_score: int, high_score: int, is_new_record: bool) -> void:
	$Panel/FinalScoreLabel.text = "Score: %d" % final_score
	if is_new_record:
		$Panel/HighScoreLabel.text = "New High Score!"
	else:
		$Panel/HighScoreLabel.text = "Best: %d" % high_score
	visible = true

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
