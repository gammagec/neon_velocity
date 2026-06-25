extends Sprite2D

var speed := 0.0

func _ready() -> void:
	if speed <= 0.0:
		speed = randf_range(15.0, 35.0)

func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -160.0:
		queue_free()
