class_name CommandBoardVisual
extends Control

const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const SURFACE_PATH := "res://assets/art/production/campaign/command_board_surface.svg"

var _surface: Texture2D
var _mission_count := 0
var _unlocked_count := 0
var _completed_count := 0

func configure(mission_count: int, unlocked_count: int, completed_count: int) -> void:
	_mission_count = maxi(0, mission_count)
	_unlocked_count = maxi(0, unlocked_count)
	_completed_count = maxi(0, completed_count)
	queue_redraw()

func _draw() -> void:
	if _surface == null:
		_surface = ProductionArtScript.texture_from_svg(SURFACE_PATH)

	if _surface != null:
		draw_texture_rect(_surface, Rect2(Vector2.ZERO, size), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, size), Color("2a211b"))
		draw_rect(Rect2(16, 16, size.x - 32, size.y - 32), Color("a79b7d"))
		draw_rect(Rect2(22, 22, size.x - 44, size.y - 44), Color("c6b994"))

	if _mission_count <= 0:
		return

	var points := _route_points(_mission_count)
	for i in range(points.size() - 1):
		var reached := i + 1 < _unlocked_count
		draw_line(
			points[i],
			points[i + 1],
			Color("d9b866", 0.88) if reached else Color("3f4747", 0.46),
			5.0
		)

	for i in range(points.size()):
		var unlocked := i < _unlocked_count
		var completed := i < _completed_count
		var fill := Color("29343a")
		var edge := Color("5f6764")
		if completed:
			fill = Color("d0a441")
			edge = Color("f2d17b")
		elif unlocked:
			fill = Color("965f3f")
			edge = Color("d9a36a")

		draw_circle(points[i], 16.0, Color("11171a"))
		draw_circle(points[i], 12.0, fill)
		draw_arc(points[i], 12.0, 0.0, TAU, 24, edge, 2.5, true)
		if completed:
			draw_line(points[i] + Vector2(-5, 0), points[i] + Vector2(-1, 5), Color("182026"), 3.0)
			draw_line(points[i] + Vector2(-1, 5), points[i] + Vector2(7, -5), Color("182026"), 3.0)

func _route_points(count: int) -> PackedVector2Array:
	var base := PackedVector2Array([
		Vector2(66, 238),
		Vector2(138, 205),
		Vector2(202, 178),
		Vector2(268, 194),
		Vector2(330, 158),
		Vector2(384, 124),
		Vector2(430, 95),
		Vector2(482, 77),
		Vector2(448, 54),
		Vector2(386, 46),
		Vector2(326, 64),
		Vector2(266, 92),
		Vector2(208, 72),
		Vector2(150, 52),
		Vector2(94, 72),
	])
	var result := PackedVector2Array()
	for i in range(mini(count, base.size())):
		result.append(base[i])
	return result
