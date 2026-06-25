extends SceneTree

const WIDTH := 960
const MOUNTAIN_H := 200
const FOREST_H := 160
const BIRD_W := 16
const BIRD_H := 12

func _init() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/background")
	_build_mountains().save_png("res://assets/background/mountains.png")
	_build_forest().save_png("res://assets/background/forest.png")
	_build_bird(true).save_png("res://assets/background/bird_up.png")
	_build_bird(false).save_png("res://assets/background/bird_down.png")
	print("Background generation done")
	quit()

func _set_px(img: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
		img.set_pixel(x, y, color)

func _build_mountains() -> Image:
	var img := Image.create(WIDTH, MOUNTAIN_H, false, Image.FORMAT_RGBA8)
	var color := Color(0.42, 0.47, 0.62, 1.0)
	var snow := Color(0.85, 0.87, 0.92, 1.0)

	for x in range(WIDTH):
		var fx := float(x)
		var ridge := sin(fx / WIDTH * TAU * 3.0) * 40.0
		ridge += sin(fx / WIDTH * TAU * 7.0 + 1.3) * 18.0
		var peak_y := int(110.0 - ridge)
		for y in range(peak_y, MOUNTAIN_H):
			_set_px(img, x, y, color)
		if peak_y >= 0:
			_set_px(img, x, peak_y, snow)
			_set_px(img, x, peak_y + 1, snow)

	return img

func _build_forest() -> Image:
	var img := Image.create(WIDTH, FOREST_H, false, Image.FORMAT_RGBA8)
	var color := Color(0.16, 0.32, 0.18, 1.0)
	var period := 80.0

	for x in range(WIDTH):
		var phase := fmod(float(x), period) / period # 0..1 within this tree's slot
		var tri: float = 1.0 - abs(phase - 0.5) * 2.0 # 0 at edges, 1 at center
		var tree_top := FOREST_H - int(tri * 110.0) - 20
		for y in range(tree_top, FOREST_H):
			_set_px(img, x, y, color)

	return img

func _build_bird(wing_up: bool) -> Image:
	var img := Image.create(BIRD_W, BIRD_H, false, Image.FORMAT_RGBA8)
	var color := Color(0.15, 0.15, 0.18, 1.0)
	var cy := 6
	var slope := -0.55 if wing_up else 0.45

	for dx in range(-6, 7):
		var x := 8 + dx
		var y := cy + int(round(abs(dx) * slope))
		_set_px(img, x, y, color)
		_set_px(img, x, y + 1, color)

	return img
