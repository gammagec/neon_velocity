extends Node

signal toggled(enabled: bool)

var enabled := false

func set_enabled(value: bool) -> void:
	enabled = value
	toggled.emit(enabled)
