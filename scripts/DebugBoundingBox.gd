extends Node2D

@export var collision_shape_path: NodePath = NodePath("../CollisionShape2D")
@export var box_color: Color = Color(0, 1, 0, 1)

var _collision_shape: CollisionShape2D

func _ready() -> void:
	_collision_shape = get_node(collision_shape_path)
	visible = Debug.enabled
	Debug.toggled.connect(_on_debug_toggled)

func _on_debug_toggled(enabled: bool) -> void:
	visible = enabled
	queue_redraw()

func _draw() -> void:
	if not _collision_shape or not (_collision_shape.shape is RectangleShape2D):
		return
	var rect_shape: RectangleShape2D = _collision_shape.shape
	var rect := Rect2(_collision_shape.position - rect_shape.size / 2.0, rect_shape.size)
	draw_rect(rect, box_color, false, 2.0)
