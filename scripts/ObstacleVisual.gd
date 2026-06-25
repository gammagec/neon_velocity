extends Sprite2D

@export var textures: Array[Texture2D] = []

func _ready() -> void:
	if textures.size() > 0:
		texture = textures[randi() % textures.size()]
