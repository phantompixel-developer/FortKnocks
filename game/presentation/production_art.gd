class_name ProductionArt
extends RefCounted

# Runtime bridge for repository-authored SVG master art.
# We intentionally do not preload .svg files as Resources because some Godot
# editor/build configurations do not register an SVG ResourceLoader at script
# parse time. Reading the source as text avoids that parse-time dependency.
static var _texture_cache: Dictionary = {}
static var _reported_failures: Dictionary = {}

static func texture_from_svg(path: String, scale := 1.0) -> Texture2D:
	var key := "%s@%s" % [path, scale]
	if _texture_cache.has(key):
		return _texture_cache[key] as Texture2D

	if not FileAccess.file_exists(path):
		_report_once(key, "Production art source is missing: %s" % path)
		_texture_cache[key] = null
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_report_once(key, "Could not open production art source: %s" % path)
		_texture_cache[key] = null
		return null

	var svg_source := file.get_as_text()
	file.close()
	if svg_source.is_empty():
		_report_once(key, "Production art source is empty: %s" % path)
		_texture_cache[key] = null
		return null

	var image := Image.new()
	var error := image.load_svg_from_string(svg_source, scale)
	if error != OK:
		_report_once(
			key,
			"Could not decode production SVG %s (error %d); using procedural fallback." % [path, error]
		)
		_texture_cache[key] = null
		return null

	var texture := ImageTexture.create_from_image(image)
	_texture_cache[key] = texture
	return texture

static func _report_once(key: String, message: String) -> void:
	if _reported_failures.has(key):
		return
	_reported_failures[key] = true
	push_warning(message)
