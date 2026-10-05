class_name CommandBoardVisual
extends Control

const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const SURFACE_PATH := "res://assets/art/production/campaign/command_board_surface.svg"

var _surface: Texture2D
var _missions: Array[MissionDefinition] = []
var _unlocked_ids: Array = []
var _completed_ids: Array = []

func configure(
	missions: Array[MissionDefinition],
	unlocked_ids: Array,
	completed_ids: Array
) -> void:
	_missions = missions.duplicate()
	_unlocked_ids = unlocked_ids.duplicate()
	_completed_ids = completed_ids.duplicate()
	queue_redraw()

func _draw() -> void:
	if _surface == null:
		_surface = ProductionArtScript.texture_from_svg(SURFACE_PATH)

	if _surface != null:
		draw_texture_rect(_surface, Rect2(Vector2.ZERO, size), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, size), Color("2a211b"))
		draw_rect(Rect2(16, 16, size.x - 32, size.y - 32), Color("a79b7d"))

	if _missions.is_empty():
		return

	var points := _route_points(_missions.size())
	_draw_region_washes()
	_draw_route_connections(points)
	_draw_route_nodes(points)

func _draw_region_washes() -> void:
	draw_rect(Rect2(28, size.y * 0.50, size.x * 0.53, size.y * 0.42), Color("b65c36", 0.055))
	draw_rect(Rect2(size.x * 0.58, 34, size.x * 0.36, size.y * 0.42), Color("5d918e", 0.07))
	draw_line(
		Vector2(size.x * 0.575, 38),
		Vector2(size.x * 0.575, size.y - 38),
		Color("5d918e", 0.30),
		2.0
	)

func _draw_route_connections(points: PackedVector2Array) -> void:
	for i in range(points.size() - 1):
		var from_mission: MissionDefinition = _missions[i]
		var to_mission: MissionDefinition = _missions[i + 1]
		var reached := _unlocked_ids.has(to_mission.id)
		var region_change := from_mission.region_id != to_mission.region_id
		var color := Color("d9b866", 0.90) if reached else Color("3f4747", 0.48)
		if region_change:
			color = Color("77b6bf", 0.90) if reached else Color("40585a", 0.50)
		draw_line(points[i], points[i + 1], color, 5.0 if not region_change else 7.0)

func _draw_route_nodes(points: PackedVector2Array) -> void:
	var active_index := _current_route_index()
	for i in range(points.size()):
		var mission: MissionDefinition = _missions[i]
		var unlocked := _unlocked_ids.has(mission.id)
		var completed := _completed_ids.has(mission.id)
		var fill := Color("29343a")
		var edge := Color("5f6764")

		if completed:
			fill = Color("d0a441")
			edge = Color("f2d17b")
		elif unlocked:
			fill = Color("965f3f")
			edge = Color("d9a36a")

		draw_circle(points[i], 17.0, Color("11171a"))
		draw_circle(points[i], 12.0, fill)
		draw_arc(points[i], 12.0, 0.0, TAU, 24, edge, 2.5, true)

		var region_color := Color("b65c36") if mission.region_id == "outskirts" else Color("5d918e")
		draw_circle(points[i] + Vector2(11, -11), 4.0, region_color)

		if completed:
			draw_line(points[i] + Vector2(-5, 0), points[i] + Vector2(-1, 5), Color("182026"), 3.0)
			draw_line(points[i] + Vector2(-1, 5), points[i] + Vector2(7, -5), Color("182026"), 3.0)

		if i == active_index:
			draw_arc(points[i], 22.0, 0.0, TAU, 32, Color("f0e6d0", 0.88), 3.0, true)

func _current_route_index() -> int:
	for i in range(_missions.size()):
		var mission: MissionDefinition = _missions[i]
		if _unlocked_ids.has(mission.id) and not _completed_ids.has(mission.id):
			return i
	for i in range(_missions.size() - 1, -1, -1):
		if _completed_ids.has(_missions[i].id):
			return i
	return 0

func _route_points(count: int) -> PackedVector2Array:
	var base := PackedVector2Array([
		Vector2(66, 400),
		Vector2(126, 365),
		Vector2(188, 382),
		Vector2(246, 340),
		Vector2(306, 355),
		Vector2(360, 310),
		Vector2(396, 252),
		Vector2(448, 205),
		Vector2(418, 145),
		Vector2(482, 94),
	])
	var result := PackedVector2Array()
	for i in range(mini(count, base.size())):
		result.append(base[i])
	return result
