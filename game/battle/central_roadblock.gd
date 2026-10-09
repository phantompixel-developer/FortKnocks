class_name CentralRoadblock
extends StaticBody2D

const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const ROADBLOCK_TEXTURE_PATH := "res://assets/art/production/battle/shared/roadblock.svg"
const ROADBLOCK_PAINTERLY_TEXTURE_PATH := "res://assets/art/production/battle/shared/roadblock_painterly.png"

var _production_texture: Texture2D
var _painterly_texture: Texture2D

func _draw() -> void:
	_draw_contact_shadow()
	if _painterly_texture == null and ResourceLoader.exists(ROADBLOCK_PAINTERLY_TEXTURE_PATH):
		_painterly_texture = load(ROADBLOCK_PAINTERLY_TEXTURE_PATH) as Texture2D
	if _painterly_texture != null:
		draw_texture_rect(_painterly_texture, Rect2(-210.0, -198.0, 420.0, 270.0), false)
		return
	if _production_texture == null:
		_production_texture = ProductionArtScript.texture_from_svg(ROADBLOCK_TEXTURE_PATH)
	if _production_texture != null:
		draw_texture_rect(_production_texture, Rect2(-202.0, -212.0, 404.0, 288.0), false)
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

func _draw_contact_shadow() -> void:
	# Extends the authored object's internal shadow so it seats into every road treatment.
	draw_set_transform(Vector2(0.0, 70.0), 0.0, Vector2(2.12, 0.27))
	draw_circle(Vector2.ZERO, 72.0, Color(0.025, 0.035, 0.040, 0.24))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
