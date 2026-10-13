extends SceneTree

const BattleScene := preload("res://game/battle/battle.tscn")
const EncounterCatalogScript := preload("res://game/campaign/encounter_catalog.gd")
const ProjectileScene := preload("res://game/battle/projectile.tscn")
const ScrapBolt := preload("res://game/weapons/scrap_bolt.tres")
const HeavySlug := preload("res://game/weapons/heavy_slug.tres")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle := BattleScene.instantiate()
	root.add_child(battle)
	await process_frame

	await _configure(battle, "roadblock_trial")
	await _test_roadblock_trajectories(battle)
	await _test_cover_damage_and_destruction(battle)
	await _test_turn_handoff(battle)

	await _configure(battle, "high_ground_trial")
	_expect(_has_ground_platform(battle), "High Ground did not create its raised ground platform")
	_expect(_enemy_vehicle_id(battle) == "run_down_compact", "High Ground enemy vehicle mapping was not applied")

	await _configure(battle, "suburbs_dead_air")
	_expect(_find_child_of_type(battle.get_node("World/EncounterGeometry"), SignalRelay) != null, "Dead Air did not create its Signal Relay")
	_expect(_enemy_vehicle_id(battle) == "old_sedan", "Dead Air enemy vehicle mapping was not applied")

	if _failures.is_empty():
		print("BATTLEFIELD_V2_SMOKE_TEST: PASS (Roadblock trajectories/rebound/destruction/turn handoff + High Ground + Dead Air)")
		quit(0)
	else:
		for failure in _failures:
			push_error("BATTLEFIELD_V2_SMOKE_TEST: %s" % failure)
		quit(1)


func _configure(battle: Node, mission_id: String) -> void:
	var definition: MissionDefinition = EncounterCatalogScript.by_id(mission_id)
	if definition == null:
		_failures.append("Unknown mission %s" % mission_id)
		return
	battle.call("_configure_mission", definition)
	await process_frame
	await physics_frame


func _test_roadblock_trajectories(battle: Node) -> void:
	var world := battle.get_node("World") as Node2D
	var layer := battle.get_node("ProjectileLayer") as Node2D
	var player := world.get_node("Player") as Combatant
	var roadblock := world.get_node("CentralRoadblock") as CentralRoadblock
	var player_cover := world.get_node("PlayerCover") as DestructibleCover
	var enemy_cover := world.get_node("EnemyCover") as DestructibleCover
	var enemy := world.get_node("Enemy") as Combatant
	var cell := world.get_node("UnstablePowerCell") as UnstablePowerCell

	_set_body_enabled(player_cover, false)
	_set_body_enabled(enemy_cover, false)
	_set_body_enabled(player, false)
	_set_body_enabled(enemy, false)
	_set_body_enabled(cell, false)
	await process_frame

	var low_hit := await _fire(layer, player, Vector2(790.0, 958.0), Vector2(6000.0, 0.0), HeavySlug)
	_expect(low_hit == roadblock, "Low trajectory did not collide with the central roadblock")

	var high_hit := await _fire(layer, player, Vector2(790.0, 790.0), Vector2(3000.0, -260.0), HeavySlug)
	_expect(high_hit != roadblock, "High trajectory incorrectly collided with the central roadblock")

	_set_body_enabled(roadblock, false)
	await process_frame
	var bounce_count := [0]
	var projectile := ProjectileScene.instantiate() as BattleProjectile
	layer.add_child(projectile)
	projectile.configure(ScrapBolt as WeaponDefinition)
	projectile.bounced.connect(func(_position: Vector2, _number: int, _remaining: int) -> void: bounce_count[0] += 1)
	projectile.launch(Vector2(420.0, 870.0), Vector2(760.0, 560.0), player)
	await projectile.resolved
	await process_frame
	_expect(int(bounce_count[0]) >= 1, "Scrap Bolt did not rebound from the raised road shoulder")

	_set_body_enabled(roadblock, true)
	_set_body_enabled(player, true)
	_set_body_enabled(enemy, true)
	_set_body_enabled(cell, true)
	await process_frame


func _test_cover_damage_and_destruction(battle: Node) -> void:
	var world := battle.get_node("World") as Node2D
	var layer := battle.get_node("ProjectileLayer") as Node2D
	var player := world.get_node("Player") as Combatant
	var enemy_cover := world.get_node("EnemyCover") as DestructibleCover
	var enemy := world.get_node("Enemy") as Combatant
	_set_body_enabled(enemy, false)
	_set_body_enabled(enemy_cover, true)
	enemy_cover.health = enemy_cover.max_health
	enemy_cover.is_destroyed = false
	await process_frame

	for shot in range(2):
		# Spawn beyond the central blocker so this case isolates cover damage.
		var origin := enemy_cover.global_position + Vector2(-180.0, -10.0)
		var hit := await _fire(layer, player, origin, Vector2(6000.0, 0.0), HeavySlug)
		_expect(hit == enemy_cover, "Heavy Slug cover shot %d did not hit enemy cover" % (shot + 1))
	await process_frame
	_expect(enemy_cover.is_destroyed, "Two Heavy Slugs did not destroy the baseline enemy cover")
	_expect((enemy_cover.get_node("CollisionShape2D") as CollisionShape2D).disabled, "Destroyed enemy cover collision remained enabled")

	_set_body_enabled(enemy, true)


func _test_turn_handoff(battle: Node) -> void:
	await _configure(battle, "roadblock_trial")
	var world := battle.get_node("World") as Node2D
	var player := world.get_node("Player") as Combatant
	var projectile_layer := battle.get_node("ProjectileLayer") as Node2D
	var projectile_count := [0]
	projectile_layer.child_entered_tree.connect(func(_child: Node) -> void: projectile_count[0] += 1)
	battle.call("_fire_projectile", player, Vector2(-1200.0, -420.0), ScrapBolt as WeaponDefinition)
	await create_timer(6.0).timeout
	_expect(int(projectile_count[0]) >= 2, "Player shot did not hand off to an enemy-fired projectile")


func _fire(layer: Node2D, shooter: Combatant, origin: Vector2, velocity: Vector2, weapon: WeaponDefinition) -> Node:
	var projectile := ProjectileScene.instantiate() as BattleProjectile
	layer.add_child(projectile)
	projectile.configure(weapon)
	projectile.launch(origin, velocity, shooter)
	var result: Array = await projectile.resolved
	var hit_body := result[1] as Node
	await process_frame
	return hit_body


func _set_body_enabled(body: CollisionObject2D, enabled: bool) -> void:
	body.collision_layer = 1 if enabled else 0
	body.collision_mask = 1 if enabled else 0
	for child in body.get_children():
		var shape := child as CollisionShape2D
		if shape != null:
			shape.set_deferred("disabled", not enabled)


func _has_ground_platform(battle: Node) -> bool:
	for child in battle.get_node("World/EncounterGeometry").get_children():
		if child is ArenaPlatform and child.is_in_group("ground_surface"):
			return true
	return false


func _enemy_vehicle_id(battle: Node) -> String:
	var enemy_cover := battle.get_node("World/EnemyCover") as DestructibleCover
	return str(enemy_cover.get("_enemy_vehicle_id"))


func _find_child_of_type(parent: Node, expected_type: Variant) -> Node:
	for child in parent.get_children():
		if is_instance_of(child, expected_type):
			return child
	return null


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
