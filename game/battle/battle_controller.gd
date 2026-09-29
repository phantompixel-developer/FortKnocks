extends Node2D

enum Phase {
	INTRO,
	PLAYER_AIM,
	PROJECTILE_FLIGHT,
	IMPACT_RESOLUTION,
	SETTLE,
	ENEMY_THINKING,
	GAME_OVER,
}

const ProjectileScene := preload("res://game/battle/projectile.tscn")
const ImpactEffectScript := preload("res://game/battle/impact_effect.gd")
const DamagePopupScript := preload("res://game/battle/damage_popup.gd")
const ScrapBolt := preload("res://game/weapons/scrap_bolt.tres")
const HeavySlug := preload("res://game/weapons/heavy_slug.tres")
const ShockCapsule := preload("res://game/weapons/shock_capsule.tres")
const ArenaPlatformScript := preload("res://game/battle/arena_platform.gd")
const CollapsibleBarrierScript := preload("res://game/battle/collapsible_barrier.gd")
const RoadblockTrial := preload("res://game/campaign/missions/roadblock_trial.tres")
const HighGroundTrial := preload("res://game/campaign/missions/high_ground_trial.tres")
const ScrapGateTrial := preload("res://game/campaign/missions/scrap_gate_trial.tres")

const MAX_DRAG := 340.0
const MIN_FIRE_DRAG := 36.0
const MIN_SPEED := 520.0
const MAX_SPEED := 1380.0

static var _pending_mission_id := ""

@onready var camera_director: BattleCameraDirector = $CameraDirector
@onready var world: Node2D = $World
@onready var battlefield_visual: Node2D = $World/BattlefieldVisual
@onready var roadblock: CentralRoadblock = $World/CentralRoadblock
@onready var encounter_geometry: Node2D = $World/EncounterGeometry
@onready var player: Combatant = $World/Player
@onready var enemy: Combatant = $World/Enemy
@onready var player_cover: DestructibleCover = $World/PlayerCover
@onready var enemy_cover: DestructibleCover = $World/EnemyCover
@onready var power_cell: UnstablePowerCell = $World/UnstablePowerCell
@onready var projectile_layer: Node2D = $ProjectileLayer
@onready var effects_layer: Node2D = $EffectsLayer
@onready var last_impact_marker: LastImpactMarker = $EffectsLayer/LastImpactMarker
@onready var aim_guide: AimGuide = $AimGuide

@onready var turn_label: Label = $HUD/Root/TurnLabel
@onready var health_label: Label = $HUD/Root/HealthLabel
@onready var enemy_health_label: Label = $HUD/Root/EnemyHealthLabel
@onready var feedback_label: Label = $HUD/Root/FeedbackLabel
@onready var enemy_locator_label: Label = $HUD/Root/EnemyLocatorLabel
@onready var hint_label: Label = $HUD/Root/HintLabel
@onready var inspect_button: Button = $HUD/Root/InspectButton
@onready var weapon_tray: ColorRect = $HUD/Root/WeaponTray
@onready var control_deck: ColorRect = $HUD/Root/ControlDeck
@onready var target_card: ColorRect = $HUD/Root/TargetCard
@onready var target_title_label: Label = $HUD/Root/TargetCard/Title
@onready var target_enemy_label: Label = $HUD/Root/TargetCard/EnemyInfoLabel
@onready var target_cover_label: Label = $HUD/Root/TargetCard/CoverInfoLabel
@onready var target_hazard_label: Label = $HUD/Root/TargetCard/HazardInfoLabel
@onready var weapon_name_label: Label = $HUD/Root/ControlDeck/WeaponNameLabel
@onready var weapon_role_label: Label = $HUD/Root/ControlDeck/WeaponRoleLabel
@onready var power_label: Label = $HUD/Root/ControlDeck/PowerLabel
@onready var angle_label: Label = $HUD/Root/ControlDeck/AngleLabel
@onready var last_shot_label: Label = $HUD/Root/ControlDeck/LastShotLabel
@onready var scrap_bolt_button: Button = $HUD/Root/WeaponTray/ScrapBolt
@onready var heavy_slug_button: Button = $HUD/Root/WeaponTray/HeavySlug
@onready var shock_capsule_button: Button = $HUD/Root/WeaponTray/ShockCapsule
@onready var encounter_picker: ColorRect = $HUD/Root/EncounterPicker
@onready var picker_briefing_label: Label = $HUD/Root/EncounterPicker/BriefingLabel
@onready var roadblock_button: Button = $HUD/Root/EncounterPicker/RoadblockButton
@onready var high_ground_button: Button = $HUD/Root/EncounterPicker/HighGroundButton
@onready var scrap_gate_button: Button = $HUD/Root/EncounterPicker/ScrapGateButton
@onready var restart_button: Button = $HUD/Root/RestartButton
@onready var change_encounter_button: Button = $HUD/Root/ChangeEncounterButton

var phase := Phase.INTRO
var _dragging := false
var _drag_start := Vector2.ZERO
var _aim_velocity := Vector2.ZERO
var _aim_power := 0.0
var _aim_angle_degrees := 0.0
var _is_inspecting := false
var _active_shooter: Combatant
var _selected_weapon: WeaponDefinition
var _feedback_tween: Tween
var _current_mission: MissionDefinition
var _collapsible_barrier: CollapsibleBarrier

var _pending_player_power := 0.0
var _pending_player_angle := 0.0
var _has_last_player_shot := false
var _last_player_power := 0.0
var _last_player_angle := 0.0
var _last_player_result := ""

var _enemy_speed_correction := {
	"scrap_bolt": 1.0,
	"heavy_slug": 1.0,
	"shock_capsule": 1.0,
}
var _enemy_target_x := 0.0

func _ready() -> void:
	_selected_weapon = ScrapBolt as WeaponDefinition
	player.health_changed.connect(_on_health_changed)
	enemy.health_changed.connect(_on_health_changed)
	power_cell.discharged.connect(_on_power_cell_discharged)
	inspect_button.pressed.connect(_inspect_enemy)
	scrap_bolt_button.pressed.connect(func() -> void: _select_weapon(ScrapBolt as WeaponDefinition))
	heavy_slug_button.pressed.connect(func() -> void: _select_weapon(HeavySlug as WeaponDefinition))
	shock_capsule_button.pressed.connect(func() -> void: _select_weapon(ShockCapsule as WeaponDefinition))
	roadblock_button.pressed.connect(func() -> void: _begin_mission(RoadblockTrial as MissionDefinition))
	high_ground_button.pressed.connect(func() -> void: _begin_mission(HighGroundTrial as MissionDefinition))
	scrap_gate_button.pressed.connect(func() -> void: _begin_mission(ScrapGateTrial as MissionDefinition))
	restart_button.pressed.connect(_restart)
	change_encounter_button.pressed.connect(_change_encounter)

	world.visible = false
	health_label.visible = false
	enemy_health_label.visible = false
	inspect_button.visible = false
	enemy_locator_label.visible = false
	weapon_tray.visible = false
	control_deck.visible = false
	target_card.visible = false
	encounter_picker.visible = true
	restart_button.visible = false
	change_encounter_button.visible = false
	feedback_label.visible = false
	last_impact_marker.clear_marker()

	_update_weapon_panel()
	_update_weapon_buttons()
	_set_weapon_buttons_enabled(false)
	_update_last_shot_display()
	_update_hud()
	_show_encounter_picker()
	if not _pending_mission_id.is_empty():
		call_deferred("_resume_pending_mission")

func _show_encounter_picker() -> void:
	phase = Phase.INTRO
	world.visible = false
	encounter_picker.visible = true
	restart_button.visible = false
	change_encounter_button.visible = false
	health_label.visible = false
	enemy_health_label.visible = false
	turn_label.text = "ENCOUNTER PROOF"
	picker_briefing_label.text = "Choose a greybox battle problem. Each uses the same weapons and combat rules."
	hint_label.text = "Select an encounter to begin"

func _resume_pending_mission() -> void:
	var definition := _mission_for_id(_pending_mission_id)
	_pending_mission_id = ""
	if definition != null:
		_begin_mission(definition)

func _mission_for_id(mission_id: String) -> MissionDefinition:
	match mission_id:
		"roadblock_trial":
			return RoadblockTrial as MissionDefinition
		"high_ground_trial":
			return HighGroundTrial as MissionDefinition
		"scrap_gate_trial":
			return ScrapGateTrial as MissionDefinition
		_:
			return null

func _begin_mission(definition: MissionDefinition) -> void:
	if definition == null or not encounter_picker.visible:
		return

	_current_mission = definition
	_configure_mission(definition)
	encounter_picker.visible = false
	restart_button.visible = false
	change_encounter_button.visible = false
	world.visible = true
	health_label.visible = true
	enemy_health_label.visible = true
	turn_label.text = definition.display_name.to_upper()
	hint_label.text = definition.briefing
	_update_hud()

	await get_tree().process_frame
	_start_player_turn(true)

func _configure_mission(definition: MissionDefinition) -> void:
	player.global_position = definition.player_position
	player_cover.global_position = definition.player_cover_position
	enemy.global_position = definition.enemy_position
	enemy_cover.global_position = definition.enemy_cover_position

	roadblock.global_position = definition.roadblock_position
	roadblock.visible = definition.roadblock_enabled
	roadblock.collision_layer = 1 if definition.roadblock_enabled else 0
	roadblock.collision_mask = 1 if definition.roadblock_enabled else 0
	var roadblock_shape := roadblock.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if roadblock_shape != null:
		roadblock_shape.disabled = not definition.roadblock_enabled

	power_cell.global_position = definition.power_cell_position
	power_cell.visible = definition.power_cell_enabled
	power_cell.collision_layer = 1 if definition.power_cell_enabled else 0
	power_cell.collision_mask = 1 if definition.power_cell_enabled else 0
	var power_cell_shape := power_cell.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if power_cell_shape != null:
		power_cell_shape.disabled = not definition.power_cell_enabled

	for child in encounter_geometry.get_children():
		child.queue_free()

	_collapsible_barrier = null
	for rect in definition.platform_rects:
		var platform := ArenaPlatformScript.new() as ArenaPlatform
		if platform == null:
			continue
		platform.configure(rect)
		encounter_geometry.add_child(platform)

	if definition.collapsible_barrier_enabled:
		_collapsible_barrier = CollapsibleBarrierScript.new() as CollapsibleBarrier
		if _collapsible_barrier != null:
			_collapsible_barrier.position = definition.collapsible_barrier_position
			_collapsible_barrier.collapsed.connect(_on_collapsible_barrier_collapsed)
			encounter_geometry.add_child(_collapsible_barrier)

	if battlefield_visual.has_method("configure_variant"):
		battlefield_visual.call("configure_variant", definition.visual_variant)

func _unhandled_input(event: InputEvent) -> void:
	if phase != Phase.PLAYER_AIM or _is_inspecting:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_begin_drag(event.position)
		else:
			_end_drag(event.position)
	elif event is InputEventScreenDrag:
		_update_drag(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_begin_drag(event.position)
		else:
			_end_drag(event.position)
	elif event is InputEventMouseMotion and _dragging and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_update_drag(event.position)

func _begin_drag(screen_position: Vector2) -> void:
	if screen_position.y < 250.0:
		return

	_dragging = true
	_drag_start = screen_position
	weapon_tray.visible = false
	inspect_button.visible = false
	_aim_power = 0.0
	_aim_angle_degrees = 0.0
	power_label.text = "POWER 0%"
	angle_label.text = "ANGLE —"
	hint_label.text = "%s • pull back to aim" % _selected_weapon.display_name

func _update_drag(screen_position: Vector2) -> void:
	if not _dragging:
		return

	var pullback := screen_position - _drag_start
	var length := minf(pullback.length(), MAX_DRAG)
	if length < 1.0:
		_aim_power = 0.0
		_aim_angle_degrees = 0.0
		power_label.text = "POWER 0%"
		angle_label.text = "ANGLE —"
		aim_guide.clear()
		return

	var constrained_pullback := pullback.normalized() * length
	var throw_vector := -constrained_pullback
	var angle := atan2(-throw_vector.y, throw_vector.x)
	angle = clampf(angle, deg_to_rad(10.0), deg_to_rad(80.0))

	_aim_power = clampf(length / MAX_DRAG, 0.0, 1.0)
	_aim_angle_degrees = rad_to_deg(angle)
	var speed := lerpf(MIN_SPEED, MAX_SPEED, _aim_power) * _selected_weapon.speed_multiplier
	_aim_velocity = Vector2(cos(angle), -sin(angle)) * speed

	aim_guide.show_prediction(player.get_launch_origin(), _aim_velocity, constrained_pullback)
	power_label.text = "POWER %d%%" % int(round(_aim_power * 100.0))
	angle_label.text = "ANGLE %d°" % int(round(_aim_angle_degrees))

func _end_drag(screen_position: Vector2) -> void:
	if not _dragging:
		return

	_update_drag(screen_position)
	_dragging = false

	if _aim_power * MAX_DRAG < MIN_FIRE_DRAG:
		aim_guide.clear()
		weapon_tray.visible = true
		inspect_button.visible = true
		power_label.text = "POWER —"
		angle_label.text = "ANGLE —"
		hint_label.text = "Pull back to aim • release to fire"
		return

	_fire_projectile(player, _aim_velocity, _selected_weapon)

func _select_weapon(definition: WeaponDefinition) -> void:
	if phase != Phase.PLAYER_AIM or _dragging or _is_inspecting:
		return

	_selected_weapon = definition
	_aim_power = 0.0
	_aim_angle_degrees = 0.0
	aim_guide.clear()
	power_label.text = "POWER —"
	angle_label.text = "ANGLE —"
	hint_label.text = "%s selected" % definition.display_name
	_update_weapon_panel()
	_update_weapon_buttons()

func _update_weapon_panel() -> void:
	if _selected_weapon == null:
		return

	weapon_name_label.text = _selected_weapon.display_name.to_upper()
	weapon_role_label.text = _weapon_role_text(_selected_weapon)

func _weapon_role_text(definition: WeaponDefinition) -> String:
	match definition.id:
		"scrap_bolt":
			return "BALANCED • 2 ROAD BOUNCES"
		"heavy_slug":
			return "COVER BREAKER • HIGH FORCE"
		"shock_capsule":
			return "RADIAL PULSE • DISPLACEMENT"
		_:
			return definition.description.to_upper()

func _update_weapon_buttons() -> void:
	if _selected_weapon == null:
		return
	scrap_bolt_button.button_pressed = _selected_weapon.id == "scrap_bolt"
	heavy_slug_button.button_pressed = _selected_weapon.id == "heavy_slug"
	shock_capsule_button.button_pressed = _selected_weapon.id == "shock_capsule"

func _set_weapon_buttons_enabled(enabled: bool) -> void:
	scrap_bolt_button.disabled = not enabled
	heavy_slug_button.disabled = not enabled
	shock_capsule_button.disabled = not enabled

func _start_player_turn(show_enemy_preview: bool) -> void:
	if _check_game_over():
		return

	phase = Phase.INTRO
	_is_inspecting = false
	inspect_button.visible = false
	inspect_button.disabled = false
	enemy_locator_label.visible = false
	weapon_tray.visible = false
	control_deck.visible = false
	target_card.visible = false
	_set_weapon_buttons_enabled(false)
	aim_guide.clear()
	last_impact_marker.visible = false
	power_label.text = "POWER —"
	angle_label.text = "ANGLE —"
	turn_label.text = "YOUR TURN"

	if show_enemy_preview:
		hint_label.text = "Enemy position"
		target_card.visible = true
		_update_target_card()
		camera_director.focus_x(enemy.global_position.x, 0.35)
		await get_tree().create_timer(0.70).timeout
		target_card.visible = false
		if phase == Phase.GAME_OVER:
			return

	hint_label.text = "Returning to your position"
	camera_director.focus_x(player.global_position.x, 0.48)
	await get_tree().create_timer(0.52).timeout
	if phase == Phase.GAME_OVER:
		return

	phase = Phase.PLAYER_AIM
	inspect_button.visible = true
	enemy_locator_label.visible = true
	weapon_tray.visible = true
	control_deck.visible = true
	target_card.visible = false
	if last_impact_marker.has_valid_marker:
		last_impact_marker.visible = true

	_set_weapon_buttons_enabled(true)
	_update_weapon_panel()
	_update_weapon_buttons()
	_update_last_shot_display()
	_update_enemy_locator()
	hint_label.text = "Pull back to aim • release to fire"

func _inspect_enemy() -> void:
	if phase != Phase.PLAYER_AIM or _dragging or _is_inspecting:
		return

	_is_inspecting = true
	inspect_button.disabled = true
	enemy_locator_label.visible = false
	weapon_tray.visible = false
	control_deck.visible = false
	target_card.visible = true
	_update_target_card()
	_set_weapon_buttons_enabled(false)
	var previous_hint := hint_label.text

	hint_label.text = "Inspecting enemy position"
	camera_director.focus_x(enemy.global_position.x, 0.30)
	await get_tree().create_timer(0.52).timeout
	if phase != Phase.PLAYER_AIM:
		_is_inspecting = false
		return

	hint_label.text = "Returning to your shooter"
	camera_director.focus_x(player.global_position.x, 0.34)
	await get_tree().create_timer(0.38).timeout
	if phase != Phase.PLAYER_AIM:
		_is_inspecting = false
		return

	hint_label.text = previous_hint
	inspect_button.disabled = false
	enemy_locator_label.visible = true
	weapon_tray.visible = true
	control_deck.visible = true
	target_card.visible = false
	_update_enemy_locator()
	_set_weapon_buttons_enabled(true)
	_is_inspecting = false

func _start_enemy_turn() -> void:
	if _check_game_over():
		return

	phase = Phase.ENEMY_THINKING
	_is_inspecting = false
	inspect_button.visible = false
	enemy_locator_label.visible = false
	weapon_tray.visible = false
	control_deck.visible = false
	target_card.visible = false
	last_impact_marker.visible = false
	_set_weapon_buttons_enabled(false)
	aim_guide.clear()
	turn_label.text = "ENEMY TURN"
	hint_label.text = "Enemy is choosing a shot"
	camera_director.focus_x(enemy.global_position.x, 0.42)

	await get_tree().create_timer(0.72).timeout
	if phase == Phase.GAME_OVER:
		return

	var enemy_weapon := _choose_enemy_weapon()
	var origin := enemy.get_launch_origin()
	var target := _choose_enemy_target(enemy_weapon)
	_enemy_target_x = target.x
	var velocity := _calculate_enemy_velocity(origin, target, enemy_weapon)
	hint_label.text = "Enemy fires %s" % enemy_weapon.display_name
	_fire_projectile(enemy, velocity, enemy_weapon)

func _choose_enemy_weapon() -> WeaponDefinition:
	if not player_cover.is_destroyed and randf() < 0.68:
		return HeavySlug as WeaponDefinition
	if player_cover.is_destroyed and randf() < 0.46:
		return ShockCapsule as WeaponDefinition
	return ScrapBolt as WeaponDefinition

func _choose_enemy_target(weapon: WeaponDefinition) -> Vector2:
	if weapon.id == "heavy_slug" and not player_cover.is_destroyed:
		return player_cover.global_position + Vector2(0.0, -30.0)
	if weapon.id == "shock_capsule":
		return Vector2((player.global_position.x + player_cover.global_position.x) * 0.5, player.global_position.y - 25.0)
	return player.global_position + Vector2(0.0, -70.0)

func _fire_projectile(shooter: Combatant, launch_velocity: Vector2, weapon: WeaponDefinition) -> void:
	if phase == Phase.GAME_OVER:
		return

	if shooter == player:
		_pending_player_power = _aim_power
		_pending_player_angle = _aim_angle_degrees

	phase = Phase.PROJECTILE_FLIGHT
	_is_inspecting = false
	inspect_button.visible = false
	enemy_locator_label.visible = false
	weapon_tray.visible = false
	control_deck.visible = false
	target_card.visible = false
	last_impact_marker.visible = false
	_set_weapon_buttons_enabled(false)
	_active_shooter = shooter
	aim_guide.clear()
	hint_label.text = "%s away" % weapon.display_name

	var projectile := ProjectileScene.instantiate() as BattleProjectile
	if projectile == null:
		push_error("Projectile scene did not instantiate as BattleProjectile.")
		return

	projectile_layer.add_child(projectile)
	projectile.configure(weapon)
	projectile.bounced.connect(_on_projectile_bounced)
	projectile.resolved.connect(_on_projectile_resolved)
	projectile.launch(shooter.get_launch_origin(), launch_velocity, shooter)
	camera_director.follow(projectile)

func _on_projectile_bounced(world_position: Vector2, bounce_number: int, remaining_bounces: int) -> void:
	var strength := 0.64 if bounce_number == 1 else 0.52
	_spawn_impact_effect(world_position, ImpactEffect.Kind.DUST, strength)
	_show_feedback("RICOCHET %d/2" % bounce_number)
	if remaining_bounces > 0:
		hint_label.text = "First rebound — one road bounce remains"
	else:
		hint_label.text = "Second rebound — next ground contact resolves"

func _on_projectile_resolved(
	impact_position: Vector2,
	hit_body: Node,
	impact_velocity: Vector2,
	damage_amount: int,
	weapon: WeaponDefinition
) -> void:
	phase = Phase.IMPACT_RESOLUTION
	camera_director.stop_follow_at(impact_position, 0.10)

	if _active_shooter == player:
		_record_player_shot(impact_position, hit_body)

	var direction := signf(impact_velocity.x)
	var impact_strength := clampf(impact_velocity.length() / 1050.0, 0.45, 1.15)

	if weapon != null and weapon.blast_radius > 0.0 and hit_body != null:
		_apply_weapon_pulse(impact_position, weapon, hit_body)
		_spawn_impact_effect(impact_position, ImpactEffect.Kind.PULSE, 1.15)
		camera_director.impact_impulse(1.0, direction)
		_show_feedback("SHOCK PULSE")
		hint_label.text = "Pressure pulse affected nearby targets"
	elif hit_body is Combatant:
		_spawn_impact_effect(impact_position, ImpactEffect.Kind.CREW, impact_strength)
		_spawn_damage_popup(impact_position + Vector2(0.0, -90.0), "-%d" % damage_amount, Color("ef9b84"))
		_show_feedback("DIRECT HIT")
		camera_director.impact_impulse(1.0, direction)
		hint_label.text = "Direct hit"
	elif hit_body is DestructibleCover:
		var cover := hit_body as DestructibleCover
		_spawn_impact_effect(impact_position, ImpactEffect.Kind.COVER, impact_strength)
		_spawn_damage_popup(impact_position + Vector2(0.0, -70.0), "-%d COVER" % damage_amount, Color("e4bd78"))
		if cover.is_destroyed:
			_show_feedback("COVER DESTROYED")
			hint_label.text = "Cover destroyed — firing line opened"
			camera_director.impact_impulse(1.0, direction)
		else:
			_show_feedback("COVER HIT")
			hint_label.text = "Cover damaged"
			camera_director.impact_impulse(0.72, direction)
	elif hit_body is CollapsibleBarrier:
		var gate := hit_body as CollapsibleBarrier
		_spawn_impact_effect(impact_position, ImpactEffect.Kind.COVER, impact_strength)
		_spawn_damage_popup(impact_position + Vector2(0.0, -80.0), "-%d GATE" % damage_amount, Color("d6b36f"))
		if gate.is_collapsed:
			_show_feedback("SCRAP GATE DOWN")
			hint_label.text = "The firing line changed"
			camera_director.impact_impulse(0.9, direction)
		else:
			_show_feedback("SCRAP GATE HIT")
			hint_label.text = "The gate is still standing"
			camera_director.impact_impulse(0.62, direction)
	elif hit_body is UnstablePowerCell:
		_show_feedback("POWER CELL HIT")
		hint_label.text = "The unstable cell discharged"
	elif hit_body != null:
		_spawn_impact_effect(impact_position, ImpactEffect.Kind.DUST, impact_strength)
		_show_feedback("MISS")
		hint_label.text = "Shot hit the environment"
		camera_director.impact_impulse(0.38, direction)
	else:
		_show_feedback("MISS")
		hint_label.text = "Shot went wide"

	if _active_shooter == enemy:
		_update_enemy_correction(impact_position, hit_body, weapon)

	_update_hud()
	await get_tree().create_timer(0.32).timeout
	if phase == Phase.GAME_OVER:
		return

	phase = Phase.SETTLE
	await get_tree().create_timer(0.56).timeout

	if _check_game_over():
		return

	if _active_shooter == player:
		_start_enemy_turn()
	else:
		_start_player_turn(false)

func _record_player_shot(impact_position: Vector2, hit_body: Node) -> void:
	_has_last_player_shot = true
	_last_player_power = _pending_player_power
	_last_player_angle = _pending_player_angle
	_last_player_result = _shot_result_name(hit_body)

	if hit_body == null:
		last_impact_marker.clear_marker()
	else:
		last_impact_marker.place_marker(impact_position)

func _shot_result_name(hit_body: Node) -> String:
	if hit_body == null:
		return "WIDE"
	if hit_body is Combatant:
		return "DIRECT"
	if hit_body is DestructibleCover:
		return "COVER"
	if hit_body is UnstablePowerCell:
		return "CELL"
	if hit_body is CollapsibleBarrier:
		return "GATE"
	if hit_body is CentralRoadblock:
		return "ROADBLOCK"
	if hit_body.is_in_group("ground_surface"):
		return "GROUND"
	return "IMPACT"

func _update_last_shot_display() -> void:
	if not _has_last_player_shot:
		last_shot_label.text = "LAST SHOT —"
		return

	last_shot_label.text = "LAST  %d%% • %d° • %s" % [
		int(round(_last_player_power * 100.0)),
		int(round(_last_player_angle)),
		_last_player_result,
	]

func _apply_weapon_pulse(impact_position: Vector2, weapon: WeaponDefinition, direct_hit_body: Node) -> void:
	var candidates: Array[Node2D] = []
	candidates.append(player)
	candidates.append(enemy)
	candidates.append(player_cover)
	candidates.append(enemy_cover)
	if _current_mission != null and _current_mission.power_cell_enabled and not power_cell.is_discharged:
		candidates.append(power_cell)
	if _collapsible_barrier != null and is_instance_valid(_collapsible_barrier) and not _collapsible_barrier.is_collapsed:
		candidates.append(_collapsible_barrier)

	for target in candidates:
		if not is_instance_valid(target):
			continue

		var distance := target.global_position.distance_to(impact_position)
		if distance > weapon.blast_radius:
			continue

		var falloff := clampf(1.0 - (distance / weapon.blast_radius) * 0.55, 0.45, 1.0)
		var pulse_damage := maxi(1, int(round(float(weapon.blast_damage) * falloff)))
		if target == direct_hit_body:
			pulse_damage = maxi(1, int(round(float(pulse_damage) * 0.65)))

		var push_direction := target.global_position - impact_position
		if push_direction.length_squared() < 1.0:
			push_direction = Vector2.RIGHT
		var impulse := push_direction.normalized() * weapon.blast_force * falloff
		target.apply_hit(pulse_damage, impulse, impact_position)

		if target is Combatant:
			_spawn_damage_popup(target.global_position + Vector2(0.0, -120.0), "-%d PULSE" % pulse_damage, Color("8fcfe2"))
		elif target is DestructibleCover:
			_spawn_damage_popup(target.global_position + Vector2(0.0, -95.0), "-%d PULSE" % pulse_damage, Color("9dc8d4"))
		elif target is CollapsibleBarrier:
			_spawn_damage_popup(target.global_position + Vector2(0.0, -110.0), "-%d GATE" % pulse_damage, Color("9dc8d4"))

func _on_collapsible_barrier_collapsed(world_position: Vector2) -> void:
	_spawn_impact_effect(world_position, ImpactEffect.Kind.DUST, 1.0)

func _on_power_cell_discharged(world_position: Vector2, radius: float, damage: int, force: float) -> void:
	_spawn_impact_effect(world_position, ImpactEffect.Kind.PULSE, 1.45)
	camera_director.stop_follow_at(world_position, 0.08)
	camera_director.impact_impulse(1.2, 1.0)
	_show_feedback("POWER SURGE")
	hint_label.text = "The unstable power cell discharged"

	var targets: Array[Node2D] = []
	targets.append(player)
	targets.append(enemy)
	targets.append(player_cover)
	targets.append(enemy_cover)
	for target in targets:
		var distance := target.global_position.distance_to(world_position)
		if distance > radius:
			continue

		var falloff := clampf(1.0 - (distance / radius) * 0.5, 0.5, 1.0)
		var applied_damage := maxi(1, int(round(float(damage) * falloff)))
		var push_direction := target.global_position - world_position
		if push_direction.length_squared() < 1.0:
			push_direction = Vector2.RIGHT
		target.apply_hit(applied_damage, push_direction.normalized() * force * falloff, world_position)

		if target is Combatant:
			_spawn_damage_popup(target.global_position + Vector2(0.0, -125.0), "-%d SURGE" % applied_damage, Color("7bc7df"))
		elif target is DestructibleCover:
			_spawn_damage_popup(target.global_position + Vector2(0.0, -95.0), "-%d SURGE" % applied_damage, Color("91bfcd"))

func _update_enemy_correction(impact_position: Vector2, hit_body: Node, weapon: WeaponDefinition) -> void:
	if weapon == null or not _enemy_speed_correction.has(weapon.id):
		return

	var correction := float(_enemy_speed_correction[weapon.id])
	if hit_body == null or hit_body.is_in_group("ground_surface"):
		var travel_direction := signf(_enemy_target_x - enemy.get_launch_origin().x)
		if is_zero_approx(travel_direction):
			travel_direction = -1.0
		var range_error := (impact_position.x - _enemy_target_x) * travel_direction
		if absf(range_error) > 45.0:
			var adjustment := clampf(-range_error / 9000.0, -0.035, 0.035)
			correction = clampf(correction + adjustment, 0.90, 1.12)
	else:
		correction = lerpf(correction, 1.0, 0.18)

	_enemy_speed_correction[weapon.id] = correction

func _spawn_impact_effect(world_position: Vector2, kind: ImpactEffect.Kind, strength: float) -> void:
	var effect := ImpactEffectScript.new() as ImpactEffect
	if effect == null:
		return
	effects_layer.add_child(effect)
	effect.global_position = world_position
	effect.setup(kind, strength)

func _spawn_damage_popup(world_position: Vector2, message: String, color: Color) -> void:
	var popup := DamagePopupScript.new() as DamagePopup
	if popup == null:
		return
	effects_layer.add_child(popup)
	popup.setup(world_position, message, color)

func _show_feedback(message: String) -> void:
	if _feedback_tween != null and _feedback_tween.is_running():
		_feedback_tween.kill()

	feedback_label.text = message
	feedback_label.visible = true
	feedback_label.modulate = Color.WHITE
	feedback_label.scale = Vector2(0.82, 0.82)

	_feedback_tween = create_tween()
	_feedback_tween.set_parallel(true)
	_feedback_tween.tween_property(feedback_label, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_feedback_tween.tween_property(feedback_label, "modulate:a", 0.0, 0.62).set_delay(0.22)
	_feedback_tween.chain().tween_callback(func() -> void: feedback_label.visible = false)

func _calculate_enemy_velocity(origin: Vector2, target: Vector2, weapon: WeaponDefinition) -> Vector2:
	var gravity := float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0))
	var dx := absf(target.x - origin.x)
	var dy_up := origin.y - target.y
	var theta := deg_to_rad(52.0)
	var cos_theta := cos(theta)
	var denominator := 2.0 * cos_theta * cos_theta * (dx * tan(theta) - dy_up)

	var speed := 1080.0
	if denominator > 1.0:
		speed = sqrt((gravity * dx * dx) / denominator)

	var correction := 1.0
	if _enemy_speed_correction.has(weapon.id):
		correction = float(_enemy_speed_correction[weapon.id])

	speed *= weapon.speed_multiplier
	speed *= correction
	speed *= randf_range(0.975, 1.02)

	var direction := signf(target.x - origin.x)
	return Vector2(direction * speed * cos_theta, -speed * sin(theta))

func _check_game_over() -> bool:
	if enemy.is_alive() and player.is_alive():
		return false

	phase = Phase.GAME_OVER
	_is_inspecting = false
	inspect_button.visible = false
	enemy_locator_label.visible = false
	weapon_tray.visible = false
	control_deck.visible = false
	target_card.visible = false
	last_impact_marker.visible = false
	_set_weapon_buttons_enabled(false)
	aim_guide.clear()
	restart_button.visible = true
	change_encounter_button.visible = true

	if player.is_alive():
		turn_label.text = "YOU WIN"
		hint_label.text = "Enemy survivor incapacitated"
		camera_director.focus_x(enemy.global_position.x, 0.35)
	else:
		turn_label.text = "DEFEAT"
		hint_label.text = "Your survivor was incapacitated"
		camera_director.focus_x(player.global_position.x, 0.35)

	return true

func _on_health_changed(_current: int, _maximum: int) -> void:
	_update_hud()

func _update_hud() -> void:
	health_label.text = "YOU  %d/100" % player.health
	enemy_health_label.text = "ENEMY  %d/100" % enemy.health
	if enemy_locator_label.visible:
		_update_enemy_locator()
	if target_card.visible:
		_update_target_card()

func _update_target_card() -> void:
	target_title_label.text = _current_mission.objective_text if _current_mission != null else "TARGET STATUS"
	target_enemy_label.text = "ENEMY  %d/%d" % [enemy.health, enemy.max_health]

	var stage := enemy_cover.get_damage_stage()
	match stage:
		0:
			target_cover_label.text = "COVER: INTACT"
		1:
			target_cover_label.text = "COVER: DAMAGED"
		2:
			target_cover_label.text = "COVER: CRITICAL"
		_:
			target_cover_label.text = "COVER: RUBBLE"

	if _current_mission != null and _current_mission.power_cell_enabled:
		target_hazard_label.text = "POWER CELL: SPENT" if power_cell.is_discharged else "POWER CELL: ACTIVE"
	elif _collapsible_barrier != null and is_instance_valid(_collapsible_barrier):
		target_hazard_label.text = _collapsible_barrier.status_text()
	else:
		target_hazard_label.text = "ENVIRONMENT: NO ACTIVE HAZARD"

func _update_enemy_locator() -> void:
	if not enemy.is_alive():
		enemy_locator_label.visible = false
		return

	var delta_x := enemy.global_position.x - player.global_position.x
	var arrow := "→" if delta_x >= 0.0 else "←"
	var approximate_metres := maxi(1, int(round(absf(delta_x) / 40.0)))
	enemy_locator_label.text = "ENEMY %s  ~%dm" % [arrow, approximate_metres]

func _restart() -> void:
	if _current_mission != null:
		_pending_mission_id = _current_mission.id
	get_tree().reload_current_scene()

func _change_encounter() -> void:
	_pending_mission_id = ""
	get_tree().reload_current_scene()
