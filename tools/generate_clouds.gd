extends SceneTree

func _init() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/background")
	_build_cloud(70, 34).save_png("res://assets/background/cloud_small.png")
	_build_cloud(110, 50).save_png("res://assets/background/cloud_large.png")
	print("Cloud generation done")
	quit()

func _fill_ellipse(img: Image, cx: float, cy: float, rx: float, ry: float, color: Color) -> void:
	for y in range(int(cy - ry), int(cy + ry) + 1):
		for x in range(int(cx - rx), int(cx + rx) + 1):
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				var dx := (x - cx) / rx
				var dy := (y - cy) / ry
				if dx * dx + dy * dy <= 1.0:
					img.set_pixel(x, y, color)

func _build_cloud(w: int, h: int) -> Image:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var white := Color(1.0, 1.0, 1.0, 0.92)
	var shadow := Color(0.82, 0.86, 0.92, 0.75)
	var fw := float(w)
	var fh := float(h)
	var cy := fh * 0.60

	_fill_ellipse(img, fw * 0.50, cy - fh * 0.16, fw * 0.26, fh * 0.40, white)
	_fill_ellipse(img, fw * 0.26, cy, fw * 0.20, fh * 0.32, white)
	_fill_ellipse(img, fw * 0.74, cy, fw * 0.22, fh * 0.34, white)
	_fill_ellipse(img, fw * 0.50, cy + fh * 0.12, fw * 0.38, fh * 0.22, white)
	_fill_ellipse(img, fw * 0.50, cy + fh * 0.26, fw * 0.34, fh * 0.12, shadow)

	return img
