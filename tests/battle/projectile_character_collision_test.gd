extends SceneTree

const BattleScene := preload("res://game/battle/battle.tscn")
const ProjectileScene := preload("res://game/battle/projectile.tscn")
const ScrapBolt := preload("res://game/weapons/scrap_bolt.tres")
const HeavySlug := preload("res://game/weapons/heavy_slug.tres")
const ShockCapsule := preload("res://game/weapons/shock_capsule.tres")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle := BattleScene.instantiate()
	root.add_child(battle)
	await process_frame
	await physics_frame

	var world := battle.get_node("World") as Node2D
	var projectile_layer := battle.get_node("ProjectileLayer") as Node2D
	var player := world.get_node("Player") as Combatant
	var enemy := world.get_node("Enemy") as Combatant
	var player_cover := world.get_node("PlayerCover") as DestructibleCover
	var enemy_cover := world.get_node("EnemyCover") as DestructibleCover

	await _disable_unrelated_bodies(world, player, enemy, player_cover, enemy_cover)
	player.global_position = Vector2(600.0, 700.0)
	enemy.global_position = Vector2(1500.0, 700.0)
	player_cover.global_position = Vector2(850.0, 650.0)
	enemy_cover.global_position = Vector2(1250.0, 650.0)

	var weapons: Array[WeaponDefinition] = [
		ScrapBolt as WeaponDefinition,
		HeavySlug as WeaponDefinition,
		ShockCapsule as WeaponDefinition,
	]
	for weapon in weapons:
		await _expect_hit(
			"player -> enemy torso (%s)" % weapon.id,
			projectile_layer,
			player,
			enemy,
			enemy.global_position + Vector2(44.0, -140.0),
			weapon
		)
		await _expect_hit(
			"enemy -> player torso (%s)" % weapon.id,
			projectile_layer,
			enemy,
			player,
			player.global_position + Vector2(-89.0, -148.0),
			weapon
		)

	await _expect_hit("player -> enemy head", projectile_layer, player, enemy, enemy.global_position + Vector2(47.0, -197.0), ScrapBolt)
	await _expect_hit("player -> enemy silhouette edge", projectile_layer, player, enemy, enemy.global_position + Vector2(103.0, -26.0), ScrapBolt)
	await _expect_hit("enemy -> player head", projectile_layer, enemy, player, player.global_position + Vector2(-98.0, -207.0), ScrapBolt)
	await _expect_hit("enemy -> player silhouette edge", projectile_layer, enemy, player, player.global_position + Vector2(-174.0, -24.0), ScrapBolt)

	await _expect_miss("enemy empty-space near miss", projectile_layer, player, enemy, enemy.global_position + Vector2(0.0, -265.0), ScrapBolt)
	await _expect_miss("player empty-space near miss", projectile_layer, enemy, player, player.global_position + Vector2(0.0, -270.0), ScrapBolt)

	await _expect_cover_intercept("enemy cover intercept", projectile_layer, player, enemy, enemy_cover, 1.0)
	await _expect_cover_intercept("player cover intercept", projectile_layer, enemy, player, player_cover, -1.0)

	if _failures.is_empty():
		print("PROJECTILE_COLLISION_TEST: PASS (all 12 direct/near-miss cases plus 2 cover interceptions)")
		quit(0)
	else:
		for failure in _failures:
			push_error("PROJECTILE_COLLISION_TEST: %s" % failure)
		quit(1)


func _disable_unrelated_bodies(
	world: Node2D,
	player: Combatant,
	enemy: Combatant,
	player_cover: DestructibleCover,
	enemy_cover: DestructibleCover
) -> void:
	for child in world.get_children():
		var body := child as CollisionObject2D
		if body == null or body in [player, enemy, player_cover, enemy_cover]:
			continue
		body.collision_layer = 0
		body.collision_mask = 0
	player_cover.collision_layer = 0
	enemy_cover.collision_layer = 0
	(player_cover.get_node("CollisionShape2D") as CollisionShape2D).set_deferred("disabled", true)
	(enemy_cover.get_node("CollisionShape2D") as CollisionShape2D).set_deferred("disabled", true)
	await process_frame


func _expect_hit(
	label: String,
	projectile_layer: Node2D,
	shooter: Combatant,
	target: Combatant,
	target_point: Vector2,
	weapon: WeaponDefinition
) -> void:
	_reset_combatant(target)
	var direction := signf(target.global_position.x - shooter.global_position.x)
	var start := target_point - Vector2(direction * 280.0, 0.0)
	var hit_body := await _fire(projectile_layer, shooter, start, Vector2(direction * 6000.0, 0.0), weapon)
	if hit_body != target:
		_failures.append("%s resolved against %s" % [label, _body_name(hit_body)])


func _expect_miss(
	label: String,
	projectile_layer: Node2D,
	shooter: Combatant,
	target: Combatant,
	target_point: Vector2,
	weapon: WeaponDefinition
) -> void:
	_reset_combatant(target)
	var direction := signf(target.global_position.x - shooter.global_position.x)
	var start := target_point - Vector2(direction * 280.0, 0.0)
	var hit_body := await _fire(projectile_layer, shooter, start, Vector2(direction * 6000.0, 0.0), weapon)
	if hit_body != null:
		_failures.append("%s unexpectedly hit %s" % [label, _body_name(hit_body)])


func _expect_cover_intercept(
	label: String,
	projectile_layer: Node2D,
	shooter: Combatant,
	target: Combatant,
	cover: DestructibleCover,
	direction: float
) -> void:
	_reset_combatant(target)
	cover.health = cover.max_health
	cover.is_destroyed = false
	cover.collision_layer = 1
	cover.collision_mask = 1
	var cover_shape := cover.get_node("CollisionShape2D") as CollisionShape2D
	cover_shape.set_deferred("disabled", false)
	if direction > 0.0:
		cover.global_position = Vector2(1250.0, 650.0)
		var unused_player_cover := projectile_layer.get_parent().get_node("World/PlayerCover") as DestructibleCover
		unused_player_cover.global_position = Vector2(250.0, 650.0)
	else:
		cover.global_position = Vector2(850.0, 650.0)
		var unused_enemy_cover := projectile_layer.get_parent().get_node("World/EnemyCover") as DestructibleCover
		unused_enemy_cover.global_position = Vector2(1950.0, 650.0)
	await process_frame
	var target_point := target.global_position + Vector2(0.0, -42.0)
	var start := target_point - Vector2(direction * 720.0, 0.0)
	var hit_body := await _fire(projectile_layer, shooter, start, Vector2(direction * 6000.0, 0.0), HeavySlug)
	if hit_body != cover:
		_failures.append("%s resolved against %s" % [label, _body_name(hit_body)])
	cover.collision_layer = 0
	cover.collision_mask = 0
	cover_shape.set_deferred("disabled", true)
	await process_frame


func _fire(
	projectile_layer: Node2D,
	shooter: Combatant,
	origin: Vector2,
	velocity: Vector2,
	weapon: WeaponDefinition
) -> Node:
	var projectile := ProjectileScene.instantiate() as BattleProjectile
	projectile_layer.add_child(projectile)
	projectile.gravity_scale = 0.0
	projectile.configure(weapon)
	projectile.launch(origin, velocity, shooter)
	var result: Array = await projectile.resolved
	var hit_body := result[1] as Node
	await process_frame
	return hit_body


func _reset_combatant(combatant: Combatant) -> void:
	combatant.health = combatant.max_health
	combatant.rotation = 0.0
	combatant.modulate = Color.WHITE


func _body_name(body: Node) -> String:
	return "nothing" if body == null else str(body.get_path())
