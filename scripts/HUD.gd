extends CanvasLayer

func _ready() -> void:
	$DebugCheckBox.button_pressed = Debug.enabled
	$DebugCheckBox.toggled.connect(_on_debug_check_box_toggled)
	set_best(HighScore.value)

func set_score(value: int) -> void:
	$ScoreLabel.text = "Score: %d" % value

func set_best(value: int) -> void:
	$BestLabel.text = "Best: %d" % value

func _on_debug_check_box_toggled(button_pressed: bool) -> void:
	Debug.set_enabled(button_pressed)
