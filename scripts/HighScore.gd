extends Node

const SAVE_PATH := "user://highscore.save"

var value := 0

func _ready() -> void:
	_load()

func try_set(new_score: int) -> bool:
	if new_score > value:
		value = new_score
		_save()
		return true
	return false

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	value = f.get_32()
	f.close()

func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_32(value)
	f.close()
