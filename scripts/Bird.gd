extends AnimatedSprite2D

var speed := 0.0

func _ready() -> void:
	if speed <= 0.0:
		speed = randf_range(90.0, 140.0)
	play("fly")

func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -40.0:
		queue_free()
