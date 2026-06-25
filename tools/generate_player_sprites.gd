extends SceneTree

const W := 40
const H := 48

const SKIN := Color(0.95, 0.75, 0.55, 1)
const SHIRT := Color(1.0, 0.1, 0.85, 1)
const PANTS := Color(0.1, 0.95, 1.0, 1)
const EYE := Color(0.1, 0.1, 0.1, 1)
const SHADOW := Color(0.15, 0.15, 0.18, 0.55)

func _init() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/player")
	for i in range(6):
		_build_run_frame(i).save_png("res://assets/player/run_%d.png" % i)
	_build_jump_frame().save_png("res://assets/player/jump_0.png")
	_build_dead_frame().save_png("res://assets/player/dead_0.png")
	print("Sprite generation done")
	quit()

func _new_image() -> Image:
	return Image.create(W, H, false, Image.FORMAT_RGBA8)

func _fill_rect(img: Image, x0: float, y0: float, x1: float, y1: float, color: Color) -> void:
	for y in range(int(round(y0)), int(round(y1))):
		for x in range(int(round(x0)), int(round(x1))):
			if x >= 0 and x < W and y >= 0 and y < H:
				img.set_pixel(x, y, color)

func _fill_circle(img: Image, cx: float, cy: float, r: float, color: Color) -> void:
	for y in range(int(cy - r), int(cy + r) + 1):
		for x in range(int(cx - r), int(cx + r) + 1):
			if x >= 0 and x < W and y >= 0 and y < H:
				var dx := x - cx
				var dy := y - cy
				if dx * dx + dy * dy <= r * r:
					img.set_pixel(x, y, color)

func _build_run_frame(i: int) -> Image:
	var img := _new_image()
	var phase := (float(i) / 6.0) * TAU
	var bob := roundi(sin(phase * 2.0))
	var swing := sin(phase) * 6.0

	_fill_rect(img, 20 - swing - 3, 33 + bob, 20 - swing + 3, 46 + bob, PANTS)
	_fill_rect(img, 20 + swing - 3, 33 + bob, 20 + swing + 3, 46 + bob, PANTS)
	_fill_rect(img, 13, 16 + bob, 27, 34 + bob, SHIRT)
	_fill_rect(img, 20 - swing * 0.7 - 2, 17 + bob, 20 - swing * 0.7 + 2, 28 + bob, PANTS)
	_fill_rect(img, 20 + swing * 0.7 - 2, 17 + bob, 20 + swing * 0.7 + 2, 28 + bob, PANTS)
	_fill_circle(img, 20, 9 + bob, 7, SKIN)
	_fill_rect(img, 23, 7 + bob, 25, 9 + bob, EYE)
	return img

func _build_jump_frame() -> Image:
	var img := _new_image()
	_fill_rect(img, 14, 30, 20, 41, PANTS)
	_fill_rect(img, 20, 30, 26, 41, PANTS)
	_fill_rect(img, 13, 16, 27, 32, SHIRT)
	_fill_rect(img, 8, 14, 12, 24, PANTS)
	_fill_rect(img, 28, 14, 32, 24, PANTS)
	_fill_circle(img, 20, 9, 7, SKIN)
	_fill_rect(img, 23, 7, 25, 9, EYE)
	return img

func _fill_ellipse(img: Image, cx: float, cy: float, rx: float, ry: float, color: Color) -> void:
	for y in range(int(cy - ry), int(cy + ry) + 1):
		for x in range(int(cx - rx), int(cx + rx) + 1):
			if x >= 0 and x < W and y >= 0 and y < H:
				var dx := (x - cx) / rx
				var dy := (y - cy) / ry
				if dx * dx + dy * dy <= 1.0:
					img.set_pixel(x, y, color)

func _build_dead_frame() -> Image:
	var img := _new_image()
	_fill_ellipse(img, 20, 44, 17, 5, SHADOW)
	_fill_ellipse(img, 20, 39, 14, 8, SHIRT)
	_fill_rect(img, 14, 37, 17, 39, EYE)
	_fill_rect(img, 23, 37, 26, 39, EYE)
	return img
