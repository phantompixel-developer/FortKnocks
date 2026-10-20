extends SceneTree

# Run: godot --headless --path . --script res://tests/roadblock_v2_smoke.gd
# Small physics-level contract test; no editor setup or campaign save required.

var _failed := false


func _initialize() -> void:
	call_deferred("_run_tests")


func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		_failed = true
		push_error("FAIL: " + message)


func _run_tests() -> void:
	var obstacle: CentralRoadblock = CentralRoadblock.new()
	obstacle.name = "SmokeRoadblock"
	var collider := CollisionShape2D.new()
	collider.name = "CollisionShape2D"
	var box := RectangleShape2D.new()
	box.size = CentralRoadblock.INTACT_COLLISION_SIZE
	collider.shape = box
	obstacle.add_child(collider)
	root.add_child(obstacle)
	await physics_frame

	var breach_events := [0]
	obstacle.breached.connect(func(_position: Vector2) -> void:
		breach_events[0] += 1
	)

	# The Roadblock Trial opt-in starts as tangible, breakable cover.
	obstacle.configure_for_mission(true, true)
	await physics_frame
	_check(obstacle.breakable and obstacle.visible, "Roadblock Trial enables breaking")
	_check(obstacle.health == obstacle.max_health and not obstacle.is_breached, "Trial begins undamaged")
	_check((collider.shape as RectangleShape2D).size.is_equal_approx(CentralRoadblock.INTACT_COLLISION_SIZE), "Intact collision matches the blocker")

	obstacle.apply_hit(60, Vector2.RIGHT, Vector2.ZERO)
	_check(obstacle.health == obstacle.max_health - 60 and not obstacle.is_breached, "First hit cracks but does not remove cover")
	obstacle.apply_hit(60, Vector2.RIGHT, Vector2.ZERO)
	await physics_frame
	_check(obstacle.is_breached and breach_events[0] == 1, "Breach emits one event")
	_check((collider.shape as RectangleShape2D).size.is_equal_approx(CentralRoadblock.BREACHED_COLLISION_SIZE), "Breach lowers collision to rubble")
	_check(collider.position.is_equal_approx(CentralRoadblock.BREACHED_COLLISION_OFFSET), "Low collision remains aligned with drawn rubble")
	obstacle.apply_hit(999, Vector2.LEFT, Vector2.ZERO)
	_check(breach_events[0] == 1, "Rubble cannot breach again")

	# Legacy mission geometry must remain untouched and invulnerable.
	obstacle.configure_for_mission(true, false)
	await physics_frame
	obstacle.apply_hit(999, Vector2.RIGHT, Vector2.ZERO)
	_check(not obstacle.breakable and not obstacle.is_breached, "Other missions retain solid roadblocks")
	_check(obstacle.health == obstacle.max_health, "Legacy shot does not damage roadblock")
	_check(collider.position.is_equal_approx(Vector2.ZERO), "Mission reconfiguration restores original collider position")
	_check((collider.shape as RectangleShape2D).size.is_equal_approx(CentralRoadblock.INTACT_COLLISION_SIZE), "Mission reconfiguration restores original collision shape")

	obstacle.configure_for_mission(false, false)
	await physics_frame
	_check(not obstacle.visible and collider.disabled, "Absent roadblocks disable visibility and collision")
	obstacle.queue_free()
	if _failed:
		quit(1)
	else:
		print("Roadblock V2 smoke tests passed.")
		quit(0)
