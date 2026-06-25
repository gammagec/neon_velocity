extends CharacterBody2D

signal died

const GRAVITY := 1400.0
const JUMP_VELOCITY := -520.0
const FALL_DEATH_Y := 700.0

var alive := true

func _physics_process(delta: float) -> void:
	if not alive:
		return

	velocity.y += GRAVITY * delta
	move_and_slide()

	var sprite := $Visual/AnimatedSprite2D
	if is_on_floor():
		if sprite.animation != &"run":
			sprite.play("run")
	else:
		if sprite.animation != &"jump":
			sprite.play("jump")

	if global_position.y > FALL_DEATH_Y:
		die()

func _unhandled_input(event: InputEvent) -> void:
	if not alive:
		return

	var jump_pressed := false
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_SPACE:
		jump_pressed = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		jump_pressed = true
	elif event is InputEventScreenTouch and event.pressed:
		jump_pressed = true

	if jump_pressed and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$JumpSound.play()

func die() -> void:
	if not alive:
		return
	alive = false
	$Visual/AnimatedSprite2D.play("dead")
	$DeathSound.play()
	died.emit()
