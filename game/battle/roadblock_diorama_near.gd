class_name RoadblockDioramaNear
extends Node2D

# Roadblock Trial only: localised world-space contact/occlusion pass in front of
# live actors, rather than repeating an entire wide foreground panorama.
# This node must remain after the combatants / covers in the World draw order.
const WORLD_WIDTH := 2160.0

@onready var player: Node2D = $"../Player"
@onready var enemy: Node2D = $"../Enemy"
@onready var player_cover: Node2D = $"../PlayerCover"
@onready var enemy_cover: Node2D = $"../EnemyCover"

var _last_positions: Array[Vector2] = []


func _ready() -> void:
	queue_redraw()


func _process(_delta: float) -> void:
	if not visible:
		return
	var positions: Array[Vector2] = [
		player.global_position, enemy.global_position,
		player_cover.global_position, enemy_cover.global_position
	]
	if positions != _last_positions:
		_last_positions = positions
		queue_redraw()


func _draw() -> void:
	# Near-road framing belongs to the physical ground. It stays low enough to
	# leave all firing origins, cover targets and the projectile arc unobstructed.
	draw_line(Vector2(0.0, 1187.0), Vector2(WORLD_WIDTH, 1187.0), Color("141c20", 0.32), 11.0)
	draw_line(Vector2(0.0, 1256.0), Vector2(WORLD_WIDTH, 1256.0), Color("10191c", 0.40), 45.0)
	for x in [95.0, 765.0, 1250.0, 2090.0]:
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(x - 60.0, 1280.0), Vector2(x - 16.0, 1205.0),
				Vector2(x + 36.0, 1219.0), Vector2(x + 110.0, 1280.0)
			]),
			Color("172329", 0.76)
		)
		draw_line(Vector2(x - 9.0, 1211.0), Vector2(x + 33.0, 1220.0), Color("a86f4b", 0.28), 4.0)

	# These small overlaps are anchored to the current (potentially knocked-
	# back) body positions. They never impersonate a collision footprint.
	_draw_boot_contact(player.global_position)
	_draw_boot_contact(enemy.global_position)
	_draw_wheel_contact(player_cover.global_position)
	_draw_wheel_contact(enemy_cover.global_position)


func _draw_boot_contact(origin: Vector2) -> void:
	var y := origin.y + 1.0
	draw_line(Vector2(origin.x - 36.0, y), Vector2(origin.x + 32.0, y + 2.0), Color("242c2a", 0.80), 7.0)
	draw_line(Vector2(origin.x - 28.0, y - 2.0), Vector2(origin.x + 22.0, y - 2.0), Color("a77c56", 0.25), 2.0)
	for offset in [-40.0, 41.0]:
		draw_circle(Vector2(origin.x + offset, y + 7.0), 3.2, Color("988269", 0.43))


func _draw_wheel_contact(origin: Vector2) -> void:
	# Vehicles' current transparent showroom art ends ~40 units below its
	# collision center; the ground contact band is kept correspondingly small.
	var y := origin.y + 40.0
	draw_line(Vector2(origin.x - 112.0, y), Vector2(origin.x + 112.0, y), Color("1e2829", 0.70), 9.0)
	draw_line(Vector2(origin.x - 98.0, y - 3.0), Vector2(origin.x + 88.0, y - 2.0), Color("ba8860", 0.19), 3.0)
