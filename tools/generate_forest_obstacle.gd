extends SceneTree

const LOG_W := 120
const LOG_H := 24
const THICKET_W := 36
const THICKET_H := 140

func _init() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/obstacles")
	_build_log().save_png("res://assets/obstacles/log_platform.png")
	_build_thicket().save_png("res://assets/obstacles/thicket.png")
	print("Forest obstacle art generation done")
	quit()

func _fill_rect(img: Image, x0: float, y0: float, x1: float, y1: float, color: Color) -> void:
	for y in range(int(round(y0)), int(round(y1))):
		for x in range(int(round(x0)), int(round(x1))):
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				img.set_pixel(x, y, color)

func _fill_ellipse(img: Image, cx: float, cy: float, rx: float, ry: float, color: Color) -> void:
	for y in range(int(cy - ry), int(cy + ry) + 1):
		for x in range(int(cx - rx), int(cx + rx) + 1):
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				var dx := (x - cx) / rx
				var dy := (y - cy) / ry
				if dx * dx + dy * dy <= 1.0:
					img.set_pixel(x, y, color)

func _build_log() -> Image:
	var img := Image.create(LOG_W, LOG_H, false, Image.FORMAT_RGBA8)
	var base := Color(0.42, 0.28, 0.14, 1.0)
	var highlight := Color(0.55, 0.38, 0.20, 1.0)
	var cap := Color(0.30, 0.20, 0.10, 1.0)

	_fill_rect(img, 0, 4, LOG_W, LOG_H - 2, base)
	_fill_rect(img, 4, 5, LOG_W - 4, 9, highlight)
	_fill_ellipse(img, 10, 13, 9, 10, cap)
	_fill_ellipse(img, LOG_W - 10, 13, 9, 10, cap)

	return img

func _build_thicket() -> Image:
	var img := Image.create(THICKET_W, THICKET_H, false, Image.FORMAT_RGBA8)
	var base := Color(0.13, 0.32, 0.15, 1.0)
	var dark := Color(0.09, 0.24, 0.11, 1.0)
	var thorn := Color(0.45, 0.18, 0.12, 1.0)
	var fw := float(THICKET_W)
	var cx := fw / 2.0
	var base_y := float(THICKET_H) - 4.0

	var lumps := 6
	for i in range(lumps):
		var t := float(i) / float(lumps - 1)
		var ly := base_y - t * (float(THICKET_H) - 24.0)
		var lr := fw * 0.32 * (1.0 - t * 0.25)
		var offset := sin(t * 11.0) * fw * 0.12
		_fill_ellipse(img, cx + offset, ly, lr, lr * 0.9, base)

	for i in range(4):
		var t2 := float(i) / 3.0
		var ty := base_y - t2 * (float(THICKET_H) - 30.0) - 14.0
		_fill_ellipse(img, cx - fw * 0.18, ty, 3.0, 3.0, thorn)
		_fill_ellipse(img, cx + fw * 0.20, ty + 6.0, 3.0, 3.0, thorn)

	_fill_ellipse(img, cx, base_y, fw * 0.40, 10.0, dark)

	return img
