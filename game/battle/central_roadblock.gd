class_name CentralRoadblock
extends StaticBody2D

const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const ROADBLOCK_TEXTURE_PATH := "res://assets/art/production/battle/shared/roadblock.svg"

var _production_texture: Texture2D

# Only explicitly authored missions can break the central obstruction.
# No terrain deformation and no change to legacy mission collision rules.
@export var max_health := 110

signal breached(world_position: Vector2)

var health := 110
var breakable := false
var is_breached := false

const INTACT_COLLISION_SIZE := Vector2(224.0, 155.0)
const BREACHED_COLLISION_SIZE := Vector2(220.0, 32.0)
const BREACHED_COLLISION_OFFSET := Vector2(0.0, 60.0)


func configure_for_mission(enabled: bool, allow_breach: bool) -> void:
	breakable = enabled and allow_breach
	health = max_health
	is_breached = false
	visible = enabled
	collision_layer = 1 if enabled else 0
	collision_mask = 1 if enabled else 0
	var collision: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision != null:
		var box: RectangleShape2D = collision.shape as RectangleShape2D
		if box != null:
			# Never mutate a collision resource that another instance might share.
			var unique_box: RectangleShape2D = box.duplicate() as RectangleShape2D
			unique_box.size = INTACT_COLLISION_SIZE
			collision.shape = unique_box
		collision.position = Vector2.ZERO
		collision.set_deferred("disabled", not enabled)
	queue_redraw()


func apply_hit(damage: int, _impulse: Vector2, _hit_position: Vector2) -> void:
	if not visible or not breakable or is_breached or damage <= 0:
		return
	health = maxi(0, health - damage)
	if health == 0:
		_breach()
	queue_redraw()


func _breach() -> void:
	if is_breached:
		return
	is_breached = true
	# Keep short tangible rubble rather than making the entire obstruction
	# vanish. The visible debris occupies the SAME lower rectangle.
	var collision: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision != null:
		var box: RectangleShape2D = collision.shape as RectangleShape2D
		if box != null:
			var unique_box: RectangleShape2D = box.duplicate() as RectangleShape2D
			unique_box.size = BREACHED_COLLISION_SIZE
			collision.set_deferred("shape", unique_box)
		collision.set_deferred("position", BREACHED_COLLISION_OFFSET)
	breached.emit(global_position)
	queue_redraw()


func status_text() -> String:
	if is_breached:
		return "ROADBLOCK: BREACHED — LOW RUBBLE"
	if not breakable:
		return "ROADBLOCK: SOLID"
	return "ROADBLOCK: %d/%d" % [health, max_health]


func _draw_contact_shadow() -> void:
	draw_set_transform(Vector2(0.0, 73.0), 0.0, Vector2(1.8, 0.18))
	draw_circle(Vector2.ZERO, 86.0, Color(0.02, 0.03, 0.035, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_damage_marks() -> void:
	if not breakable or health >= max_health:
		return
	var fracture: Color = Color("222d2b", 0.95)
	draw_line(Vector2(-44, -71), Vector2(-18, -21), fracture, 6.0)
	draw_line(Vector2(-18, -21), Vector2(-38, 19), fracture, 4.0)
	draw_line(Vector2(-18, -21), Vector2(20, 6), fracture, 4.0)
	if health * 2 <= max_health:
		draw_line(Vector2(42, -69), Vector2(18, -8), fracture, 7.0)
		draw_line(Vector2(18, -8), Vector2(59, 41), fracture, 5.0)
		draw_line(Vector2(-76, 22), Vector2(-41, 45), Color("ad9477"), 8.0)
		draw_circle(Vector2(13, 11), 15.0, Color("48504a", 0.52))


func _draw_low_rubble() -> void:
	# World-space collision is centered at local (0,60), size (220,32).
	# Stones stay inside that footprint so a low shot hits what it sees.
	var rock: Color = Color("555c56")
	var shadow: Color = Color("242d2b")
	draw_rect(Rect2(-110.0, 45.0, 220.0, 31.0), shadow)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-110, 73), Vector2(-105, 56), Vector2(-84, 47),
		Vector2(-61, 61), Vector2(-35, 46), Vector2(-9, 55),
		Vector2(18, 45), Vector2(49, 61), Vector2(83, 46),
		Vector2(110, 65), Vector2(110, 76), Vector2(-110, 76)
	]), rock)
	draw_line(Vector2(-91, 58), Vector2(-70, 70), Color("959385"), 5.0)
	draw_line(Vector2(-20, 54), Vector2(-2, 72), Color("9b6b4c"), 6.0)
	draw_line(Vector2(41, 60), Vector2(70, 70), Color("929287"), 4.0)
	draw_rect(Rect2(-6, 52, 29, 5), Color("987450"))

func _draw() -> void:
	_draw_contact_shadow()
	if is_breached:
		_draw_low_rubble()
		return
	if _production_texture == null:
		_production_texture = ProductionArtScript.texture_from_svg(ROADBLOCK_TEXTURE_PATH)
	if _production_texture != null:
		draw_texture_rect(_production_texture, Rect2(-120.0, -100.0, 240.0, 176.0), false)
		_draw_damage_marks()
		return

	var outline := Color("171c1b")
	var concrete := Color("69736d")
	var shade := Color("4b5550")
	var chip := Color("3d4742")
	var rust := Color("8f5540")
	var hazard := Color("d4aa55")

	# Poured road barrier with salvaged repair plates and exposed rebar.
	draw_polygon(
		PackedVector2Array([
			Vector2(-114, 76),
			Vector2(-106, -48),
			Vector2(-80, -74),
			Vector2(88, -74),
			Vector2(114, -48),
			Vector2(114, 76),
		]),
		PackedColorArray([outline])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-103, 66),
			Vector2(-96, -42),
			Vector2(-70, -63),
			Vector2(79, -63),
			Vector2(103, -42),
			Vector2(103, 66),
		]),
		PackedColorArray([concrete])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-96, 42),
			Vector2(-72, -50),
			Vector2(-18, -57),
			Vector2(-30, 62),
		]),
		PackedColorArray([shade])
	)

	# Exposed reinforcing steel and authored cracks.
	draw_line(Vector2(-78, -60), Vector2(-90, -88), rust, 5.0)
	draw_line(Vector2(-63, -64), Vector2(-65, -94), rust, 4.0)
	draw_line(Vector2(78, -61), Vector2(91, -87), rust, 5.0)
	draw_line(Vector2(-54, -46), Vector2(-23, 2), chip, 7.0)
	draw_line(Vector2(-24, 2), Vector2(-51, 40), chip, 6.0)
	draw_line(Vector2(43, -55), Vector2(15, 8), chip, 6.0)
	draw_line(Vector2(15, 8), Vector2(55, 46), chip, 6.0)

	# Faded road-maintenance striping ties the blocker to the Outskirts language.
	for x in [-88.0, -48.0, -8.0, 32.0, 72.0]:
		draw_line(Vector2(x, 52), Vector2(x + 24, 26), hazard if int((x + 88.0) / 40.0) % 2 == 0 else rust, 10.0)

	# A bolted repair plate implies repeated reuse rather than clean military equipment.
	draw_rect(Rect2(54, -20, 43, 35), Color("46524c"))
	for p in [Vector2(61, -13), Vector2(89, -13), Vector2(61, 7), Vector2(89, 7)]:
		draw_circle(p, 3.0, outline)

	_draw_damage_marks()
