class_name SignalRelay
extends StaticBody2D

const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const RELAY_TEXTURE_PATH := "res://assets/art/production/battle/suburbs/signal_relay.svg"
const RELAY_DESTROYED_TEXTURE_PATH := "res://assets/art/production/battle/suburbs/signal_relay_destroyed.svg"
const RELAY_PAINTERLY_TEXTURE_PATH := "res://assets/art/production/battle/suburbs/signal_relay_painterly.png"
const RELAY_DESTROYED_PAINTERLY_TEXTURE_PATH := "res://assets/art/production/battle/suburbs/signal_relay_destroyed_painterly.png"

var _production_texture: Texture2D
var _destroyed_texture: Texture2D

signal destroyed(world_position: Vector2)

@export var max_health: int = 120

var health: int = 120
var is_destroyed: bool = false
var _reaction_tween: Tween

func _ready() -> void:
	health = max_health
	if get_node_or_null("CollisionShape2D") == null:
		var collision_shape: CollisionShape2D = CollisionShape2D.new()
		collision_shape.name = "CollisionShape2D"
		collision_shape.position = Vector2(0.0, -74.0)
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(84.0, 152.0)
		collision_shape.shape = shape
		add_child(collision_shape)
	queue_redraw()

func configure(configured_health: int) -> void:
	max_health = maxi(1, configured_health)
	health = max_health
	is_destroyed = false
	collision_layer = 1
	collision_mask = 1
	var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape != null:
		collision_shape.set_deferred("disabled", false)
	queue_redraw()

func apply_hit(damage: int, impulse: Vector2, _hit_position: Vector2) -> void:
	if is_destroyed:
		return

	health = maxi(0, health - damage)
	_play_hit_reaction(impulse)
	if health <= 0:
		is_destroyed = true
		collision_layer = 0
		collision_mask = 0
		var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
		if collision_shape != null:
			collision_shape.set_deferred("disabled", true)
		destroyed.emit(global_position)
	queue_redraw()

func status_text() -> String:
	if is_destroyed:
		return "SIGNAL RELAY: OFFLINE"
	return "SIGNAL RELAY: %d/%d" % [health, max_health]

func _play_hit_reaction(impulse: Vector2) -> void:
	if _reaction_tween != null and _reaction_tween.is_running():
		_reaction_tween.kill()
	var direction: float = signf(impulse.x)
	if is_zero_approx(direction):
		direction = 1.0
	modulate = Color(1.32, 1.18, 0.82, 1.0)
	rotation = deg_to_rad(1.6 * direction)
	_reaction_tween = create_tween()
	_reaction_tween.set_parallel(true)
	_reaction_tween.tween_property(self, "modulate", Color.WHITE, 0.18)
	_reaction_tween.tween_property(self, "rotation", 0.0, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	_draw_ground_treatment()
	if is_destroyed:
		if _destroyed_texture == null and ResourceLoader.exists(RELAY_DESTROYED_PAINTERLY_TEXTURE_PATH):
			_destroyed_texture = load(RELAY_DESTROYED_PAINTERLY_TEXTURE_PATH) as Texture2D
		if _destroyed_texture == null:
			_destroyed_texture = ProductionArtScript.texture_from_svg(RELAY_DESTROYED_TEXTURE_PATH)
		if _destroyed_texture != null:
			draw_texture_rect(_destroyed_texture, Rect2(-150.0, -188.0, 300.0, 198.0), false)
			return
	else:
		if _production_texture == null and ResourceLoader.exists(RELAY_PAINTERLY_TEXTURE_PATH):
			_production_texture = load(RELAY_PAINTERLY_TEXTURE_PATH) as Texture2D
		if _production_texture == null:
			_production_texture = ProductionArtScript.texture_from_svg(RELAY_TEXTURE_PATH)
		if _production_texture != null:
			_draw_production_relay()
			return

	var outline: Color = Color("171c1b")
	var frame: Color = Color("303a35")
	var panel: Color = Color("59645e")
	var cold: Color = Color("77b6bf")
	var hazard: Color = Color("d4aa55")
	var rust: Color = Color("8f5540")

	if is_destroyed:
		draw_line(Vector2(-26, -8), Vector2(36, -54), outline, 13.0)
		draw_line(Vector2(-22, -12), Vector2(32, -52), frame, 8.0)
		draw_rect(Rect2(-45, -20, 76, 20), outline)
		draw_rect(Rect2(-39, -16, 64, 12), panel.darkened(0.25))
		draw_circle(Vector2(35, -55), 18.0, Color("33423d"))
		draw_line(Vector2(23, -67), Vector2(48, -42), rust, 5.0)
		return

	# Salvaged roadside relay: narrow mast, protected electronics box and improvised dish.
	draw_rect(Rect2(-14, -146, 28, 146), outline)
	draw_rect(Rect2(-8, -140, 16, 136), frame)
	draw_rect(Rect2(-44, -84, 88, 60), outline)
	draw_rect(Rect2(-38, -78, 76, 48), panel)
	draw_rect(Rect2(-29, -68, 58, 11), Color("26322e"))
	draw_circle(Vector2(-20, -42), 5.0, cold)
	draw_circle(Vector2(-4, -42), 5.0, hazard)
	draw_line(Vector2(11, -72), Vector2(28, -54), rust, 6.0)

	draw_line(Vector2(0, -142), Vector2(0, -194), outline, 9.0)
	draw_line(Vector2(0, -188), Vector2(35, -214), outline, 7.0)
	draw_arc(Vector2(38, -217), 31.0, 2.1, 5.1, 22, cold, 7.0, true)
	draw_circle(Vector2(38, -217), 6.0, Color("dff5f1"))
	draw_line(Vector2(-29, -16), Vector2(29, -16), hazard, 6.0)
	draw_line(Vector2(-19, -16), Vector2(-4, -31), rust, 6.0)

	var ratio: float = float(health) / float(max_health)
	draw_rect(Rect2(-46, -235, 92, 10), outline)
	draw_rect(Rect2(-42, -232, 84.0 * ratio, 4), cold)


func _draw_ground_treatment() -> void:
	# Actual recovered-tech objective: restrained cold spill plus neutral contact.
	draw_set_transform(Vector2(0.0, 2.0), 0.0, Vector2(1.70, 0.25))
	draw_circle(Vector2.ZERO, 58.0, Color(0.025, 0.035, 0.040, 0.28))
	if not is_destroyed:
		draw_circle(Vector2.ZERO, 72.0, Color(0.32, 0.72, 0.76, 0.065))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if not is_destroyed:
		# Small floor brackets read as objective framing without becoming HUD.
		draw_line(Vector2(-78, 4), Vector2(-54, 4), Color("77b6bf", 0.36), 4.0)
		draw_line(Vector2(54, 4), Vector2(78, 4), Color("77b6bf", 0.36), 4.0)


func _draw_production_relay() -> void:
	draw_texture_rect(
		_production_texture,
		Rect2(-150.0, -452.0, 300.0, 462.0),
		false
	)

	var outline := Color("111719")
	var cold := Color("77b6bf")
	var ratio: float = float(health) / float(max_health)
	draw_rect(Rect2(-46, -469, 92, 10), outline)
	draw_rect(Rect2(-42, -466, 84.0 * ratio, 4), cold)
