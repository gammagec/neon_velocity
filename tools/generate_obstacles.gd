extends SceneTree

const SMALL_W := 44
const SMALL_H := 46
const LARGE_W := 80
const LARGE_H := 80

func _init() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/obstacles")
	_build_bush(SMALL_W, SMALL_H).save_png("res://assets/obstacles/bush.png")
	_build_rock(SMALL_W, SMALL_H).save_png("res://assets/obstacles/rock.png")
	_build_bush(LARGE_W, LARGE_H).save_png("res://assets/obstacles/large_bush.png")
	_build_rock(LARGE_W, LARGE_H).save_png("res://assets/obstacles/boulder.png")
	print("Obstacle art generation done")
	quit()

func _fill_ellipse(img: Image, cx: float, cy: float, rx: float, ry: float, color: Color) -> void:
	for y in range(int(cy - ry), int(cy + ry) + 1):
		for x in range(int(cx - rx), int(cx + rx) + 1):
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				var dx := (x - cx) / rx
				var dy := (y - cy) / ry
				if dx * dx + dy * dy <= 1.0:
					img.set_pixel(x, y, color)

func _build_bush(w: int, h: int) -> Image:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var base := Color(0.18, 0.45, 0.20, 1.0)
	var light := Color(0.27, 0.58, 0.28, 1.0)
	var fw := float(w)
	var fh := float(h)
	var cx := fw / 2.0
	var base_y := fh - 4.0

	_fill_ellipse(img, cx, base_y - fh * 0.32, fw * 0.30, fh * 0.30, base)
	_fill_ellipse(img, cx - fw * 0.22, base_y - fh * 0.22, fw * 0.22, fh * 0.22, base)
	_fill_ellipse(img, cx + fw * 0.22, base_y - fh * 0.22, fw * 0.22, fh * 0.22, base)
	_fill_ellipse(img, cx, base_y - fh * 0.45, fw * 0.20, fh * 0.20, light)

	return img

func _build_rock(w: int, h: int) -> Image:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var base := Color(0.55, 0.55, 0.58, 1.0)
	var shadow := Color(0.40, 0.40, 0.44, 1.0)
	var fw := float(w)
	var fh := float(h)
	var cx := fw / 2.0
	var base_y := fh - 4.0

	_fill_ellipse(img, cx, base_y - fh * 0.20, fw * 0.34, fh * 0.24, base)
	_fill_ellipse(img, cx - fw * 0.18, base_y - fh * 0.14, fw * 0.20, fh * 0.16, base)
	_fill_ellipse(img, cx + fw * 0.20, base_y - fh * 0.12, fw * 0.18, fh * 0.15, base)
	_fill_ellipse(img, cx, base_y - fh * 0.05, fw * 0.36, fh * 0.12, shadow)

	return img
