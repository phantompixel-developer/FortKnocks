extends Node2D

signal battle_completed(result: Dictionary)
signal exit_requested
signal rematch_requested

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
const SignalRelayScript := preload("res://game/battle/signal_relay.gd")
const SalvageLoadScript := preload("res://game/battle/salvage_load.gd")
const EncounterCatalogScript := preload("res://game/campaign/encounter_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")
const ProductionUIScript := preload("res://game/presentation/production_ui.gd")

const MAX_DRAG := 340.0
const MIN_FIRE_DRAG := 36.0
const MIN_SPEED := 520.0
const MAX_SPEED := 1380.0
const PENDING_MISSION_META := &"fort_knocks_pending_mission"
const HUD_REFERENCE_SIZE := Vector2(720.0, 1280.0)

@onready var camera_director: BattleCameraDirector = $CameraDirector
@onready var world: Node2D = $World
@onready var battlefield_visual: Node2D = $World/BattlefieldVisual
@onready var near_occlusion: BattlefieldNearOcclusion = $World/NearOcclusion
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

@onready var hud_root: Control = $HUD/Root
@onready var player_status_card: ColorRect = $HUD/Root/PlayerStatusCard
@onready var enemy_status_card: ColorRect = $HUD/Root/EnemyStatusCard
@onready var health_label: Label = $HUD/Root/PlayerStatusCard/HealthLabel
@onready var player_cover_label: Label = $HUD/Root/PlayerStatusCard/CoverLabel
@onready var player_health_bar_back: ColorRect = $HUD/Root/PlayerStatusCard/HealthBarBack
@onready var player_health_bar_fill: ColorRect = $HUD/Root/PlayerStatusCard/HealthBarFill
@onready var player_cover_bar_back: ColorRect = $HUD/Root/PlayerStatusCard/CoverBarBack
@onready var player_cover_bar_fill: ColorRect = $HUD/Root/PlayerStatusCard/CoverBarFill
@onready var enemy_health_label: Label = $HUD/Root/EnemyStatusCard/HealthLabel
@onready var enemy_cover_label: Label = $HUD/Root/EnemyStatusCard/CoverLabel
@onready var enemy_health_bar_back: ColorRect = $HUD/Root/EnemyStatusCard/HealthBarBack
@onready var enemy_health_bar_fill: ColorRect = $HUD/Root/EnemyStatusCard/HealthBarFill
@onready var enemy_cover_bar_back: ColorRect = $HUD/Root/EnemyStatusCard/CoverBarBack
@onready var enemy_cover_bar_fill: ColorRect = $HUD/Root/EnemyStatusCard/CoverBarFill
@onready var turn_label: Label = $HUD/Root/TurnLabel
@onready var feedback_plate: ColorRect = $HUD/Root/FeedbackPlate
@onready var feedback_label: Label = $HUD/Root/FeedbackLabel
@onready var enemy_locator_label: Label = $HUD/Root/EnemyLocatorLabel
@onready var hint_label: Label = $HUD/Root/HintLabel
@onready var inspect_button: Button = $HUD/Root/InspectButton
@onready var weapon_tray: ColorRect = $HUD/Root/WeaponTray
@onready var weapon_info_card: ColorRect = $HUD/Root/WeaponInfoCard
@onready var control_deck: ColorRect = $HUD/Root/ControlDeck
@onready var inspect_banner: ColorRect = $HUD/Root/InspectBanner
@onready var inspect_banner_title: Label = $HUD/Root/InspectBanner/Title
@onready var inspect_banner_subtitle: Label = $HUD/Root/InspectBanner/Subtitle
@onready var target_card: ColorRect = $HUD/Root/TargetCard
@onready var target_title_label: Label = $HUD/Root/TargetCard/Title
@onready var target_objective_label: Label = $HUD/Root/TargetCard/ObjectiveLabel
@onready var target_enemy_label: Label = $HUD/Root/TargetCard/EnemyInfoLabel
@onready var target_enemy_bar_back: ColorRect = $HUD/Root/TargetCard/EnemyHealthBarBack
@onready var target_enemy_bar_fill: ColorRect = $HUD/Root/TargetCard/EnemyHealthBarFill
@onready var target_cover_label: Label = $HUD/Root/TargetCard/CoverInfoLabel
@onready var target_cover_bar_back: ColorRect = $HUD/Root/TargetCard/CoverHealthBarBack
@onready var target_cover_bar_fill: ColorRect = $HUD/Root/TargetCard/CoverHealthBarFill
@onready var target_tactic_label: Label = $HUD/Root/TargetCard/TacticLabel
@onready var target_hazard_label: Label = $HUD/Root/TargetCard/HazardInfoLabel
@onready var weapon_name_label: Label = $HUD/Root/WeaponInfoCard/WeaponNameLabel
@onready var weapon_role_label: Label = $HUD/Root/WeaponInfoCard/WeaponRoleLabel
@onready var power_label: Label = $HUD/Root/ControlDeck/PowerLabel
@onready var angle_label: Label = $HUD/Root/ControlDeck/AngleLabel
@onready var last_shot_label: Label = $HUD/Root/ControlDeck/LastShotLabel
@onready var scrap_bolt_button: Button = $HUD/Root/WeaponTray/ScrapBolt
@onready var heavy_slug_button: Button = $HUD/Root/WeaponTray/HeavySlug
@onready var shock_capsule_button: Button = $HUD/Root/WeaponTray/ShockCapsule
@onready var mission_brief_card: ColorRect = $HUD/Root/MissionBriefCard
@onready var mission_brief_region: Label = $HUD/Root/MissionBriefCard/Region
@onready var mission_brief_title: Label = $HUD/Root/MissionBriefCard/Title
@onready var mission_brief_text: Label = $HUD/Root/MissionBriefCard/Briefing
@onready var mission_brief_objective: Label = $HUD/Root/MissionBriefCard/Objective
@onready var mission_brief_tactic: Label = $HUD/Root/MissionBriefCard/Tactic
@onready var mission_brief_loadout: Label = $HUD/Root/MissionBriefCard/Loadout
@onready var mission_deploy_button: Button = $HUD/Root/MissionBriefCard/DeployButton
@onready var encounter_picker: ColorRect = $HUD/Root/EncounterPicker
@onready var picker_briefing_label: Label = $HUD/Root/EncounterPicker/BriefingLabel
@onready var mission_button_list: VBoxContainer = $HUD/Root/EncounterPicker/MissionButtons
@onready var result_card: ColorRect = $HUD/Root/ResultCard
@onready var result_region_label: Label = $HUD/Root/ResultCard/Region
@onready var result_title_label: Label = $HUD/Root/ResultCard/Title
@onready var result_encounter_label: Label = $HUD/Root/ResultCard/EncounterName
@onready var result_objective_label: Label = $HUD/Root/ResultCard/ObjectiveOutcome
@onready var result_clear_state_label: Label = $HUD/Root/ResultCard/ClearState
@onready var result_reward_label: Label = $HUD/Root/ResultCard/Reward
@onready var result_unlock_label: Label = $HUD/Root/ResultCard/Unlock
@onready var result_summary_label: Label = $HUD/Root/ResultCard/Summary
@onready var restart_button: Button = $HUD/Root/ResultCard/RestartButton
@onready var change_encounter_button: Button = $HUD/Root/ResultCard/ChangeEncounterButton

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
var _signal_relay: SignalRelay
var _salvage_load: SalvageLoad
var _missions: Array[MissionDefinition] = []
var _campaign_managed := false
var _prepared_mission: MissionDefinition
var _player_platform: CombatPlatformDefinition
var _player_module: PlatformModuleDefinition
var _campaign_weapon_ids: Array[String] = []
var _campaign_weapon_levels: Dictionary = {}
var _player_weapon_cache: Dictionary = {}
var _completion_emitted := false
var _progression_reward := 0
var _mission_deploying := false

var _player_shots_fired := 0
var _player_direct_hits := 0
var _player_cover_hits := 0
var _player_environment_events := 0
var _weapon_shots := {
	"scrap_bolt": 0,
	"heavy_slug": 0,
	"shock_capsule": 0,
}

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
var _hud_base_offsets: Dictionary = {}

func _style_live_hud() -> void:
	turn_label.add_theme_color_override("font_color", ThemeScript.HAZARD)
	health_label.add_theme_color_override("font_color", ThemeScript.BONE)
	player_cover_label.add_theme_color_override("font_color", ThemeScript.MUTED)
	enemy_health_label.add_theme_color_override("font_color", Color("ef9b84"))
	enemy_cover_label.add_theme_color_override("font_color", ThemeScript.MUTED)
	player_health_bar_fill.color = ThemeScript.HAZARD
	player_cover_bar_fill.color = ThemeScript.OXIDE
	enemy_health_bar_fill.color = ThemeScript.SIGNAL
	enemy_cover_bar_fill.color = ThemeScript.RUST
	enemy_locator_label.add_theme_color_override("font_color", ThemeScript.COLD)
	feedback_label.add_theme_color_override("font_color", ThemeScript.HAZARD)
	var weapon_title := weapon_tray.get_node("Title") as Label
	if weapon_title != null:
		weapon_title.add_theme_color_override("font_color", ThemeScript.MUTED)
	weapon_name_label.add_theme_color_override("font_color", ThemeScript.BONE)
	weapon_role_label.add_theme_color_override("font_color", ThemeScript.MUTED)
	power_label.add_theme_color_override("font_color", ThemeScript.HAZARD)
	angle_label.add_theme_color_override("font_color", ThemeScript.HAZARD)
	last_shot_label.add_theme_color_override("font_color", ThemeScript.MUTED)
	hint_label.add_theme_color_override("font_color", ThemeScript.BONE)
	inspect_banner_title.add_theme_color_override("font_color", ThemeScript.COLD)
	inspect_banner_subtitle.add_theme_color_override("font_color", ThemeScript.MUTED)
	target_title_label.add_theme_color_override("font_color", ThemeScript.COLD)
	target_objective_label.add_theme_color_override("font_color", ThemeScript.MUTED)
	target_enemy_label.add_theme_color_override("font_color", Color("ef9b84"))
	target_cover_label.add_theme_color_override("font_color", ThemeScript.BONE)
	target_tactic_label.add_theme_color_override("font_color", ThemeScript.HAZARD)
	target_hazard_label.add_theme_color_override("font_color", ThemeScript.COLD)
	target_enemy_bar_fill.color = ThemeScript.SIGNAL
	target_cover_bar_fill.color = ThemeScript.RUST
	mission_brief_region.add_theme_color_override("font_color", ThemeScript.HAZARD)
	mission_brief_objective.add_theme_color_override("font_color", ThemeScript.BONE)
	mission_brief_tactic.add_theme_color_override("font_color", ThemeScript.COLD)
	mission_brief_loadout.add_theme_color_override("font_color", ThemeScript.MUTED)
	result_region_label.add_theme_color_override("font_color", ThemeScript.MUTED)
	result_clear_state_label.add_theme_color_override("font_color", ThemeScript.COLD)
	result_reward_label.add_theme_color_override("font_color", ThemeScript.HAZARD)
	result_unlock_label.add_theme_color_override("font_color", ThemeScript.COLD)
	result_summary_label.add_theme_color_override("font_color", ThemeScript.MUTED)
	ThemeScript.mark_active(mission_deploy_button, true)
	inspect_button.add_theme_font_size_override("font_size", 18)

func _capture_hud_layout() -> void:
	_hud_base_offsets.clear()
	for item in [
		player_status_card,
		enemy_status_card,
		turn_label,
		inspect_button,
		enemy_locator_label,
		weapon_tray,
		weapon_info_card,
		inspect_banner,
		feedback_plate,
		feedback_label,
		control_deck,
		target_card,
		mission_brief_card,
		result_card,
		hint_label,
	]:
		var control := item as Control
		if control == null:
			continue
		_hud_base_offsets[control.get_instance_id()] = Vector4(
			control.offset_left,
			control.offset_top,
			control.offset_right,
			control.offset_bottom
		)

func _apply_hud_safe_area() -> void:
	if _hud_base_offsets.is_empty():
		return

	var viewport_size := hud_root.get_viewport_rect().size
	var size_delta := viewport_size - HUD_REFERENCE_SIZE
	var safe := ProductionUIScript.safe_area_insets(hud_root)
	var left_shift := maxf(0.0, safe.x)
	var top_shift := maxf(0.0, safe.y)
	var right_shift := size_delta.x - maxf(0.0, safe.z)
	var center_shift_x := size_delta.x * 0.5
	var bottom_shift := size_delta.y - maxf(0.0, safe.w)

	_set_hud_control_shift(player_status_card, Vector2(left_shift, top_shift))
	_set_hud_control_shift(weapon_tray, Vector2(left_shift, top_shift))

	_set_hud_control_shift(enemy_status_card, Vector2(right_shift, top_shift))
	_set_hud_control_shift(inspect_button, Vector2(right_shift, top_shift))

	_set_hud_control_shift(turn_label, Vector2(center_shift_x, top_shift))
	_set_hud_control_shift(weapon_info_card, Vector2(center_shift_x, top_shift))
	_set_hud_control_shift(inspect_banner, Vector2(center_shift_x, top_shift))
	_set_hud_control_shift(enemy_locator_label, Vector2(center_shift_x, top_shift))
	_set_hud_control_shift(target_card, Vector2(center_shift_x, top_shift))
	_set_hud_control_shift(mission_brief_card, Vector2(center_shift_x, top_shift))
	_set_hud_control_shift(result_card, Vector2(center_shift_x, top_shift))
	_set_hud_control_shift(feedback_plate, Vector2(center_shift_x, size_delta.y * 0.35))
	_set_hud_control_shift(feedback_label, Vector2(center_shift_x, size_delta.y * 0.35))

	_set_hud_control_shift(control_deck, Vector2(center_shift_x, bottom_shift))
	_set_hud_control_shift(hint_label, Vector2(center_shift_x, bottom_shift))

func _set_hud_control_shift(control: Control, shift: Vector2) -> void:
	var base_variant: Variant = _hud_base_offsets.get(control.get_instance_id())
	if base_variant == null:
		return
	var base: Vector4 = base_variant
	control.offset_left = base.x + shift.x
	control.offset_top = base.y + shift.y
	control.offset_right = base.z + shift.x
	control.offset_bottom = base.w + shift.y

func prepare_for_campaign(
	definition: MissionDefinition,
	platform_definition: CombatPlatformDefinition,
	module_definition: PlatformModuleDefinition = null,
	weapon_ids: Array[String] = [],
	weapon_levels: Dictionary = {}
) -> void:
	_campaign_managed = true
	_prepared_mission = definition
	_player_platform = platform_definition
	_player_module = module_definition
	_campaign_weapon_ids = weapon_ids.duplicate()
	_campaign_weapon_levels = weapon_levels.duplicate(true)
	_player_weapon_cache.clear()

func _player_weapon(weapon_id: String) -> WeaponDefinition:
	if _player_weapon_cache.has(weapon_id):
		return _player_weapon_cache[weapon_id] as WeaponDefinition

	var base: WeaponDefinition
	match weapon_id:
		"scrap_bolt":
			base = ScrapBolt as WeaponDefinition
		"heavy_slug":
			base = HeavySlug as WeaponDefinition
		"shock_capsule":
			base = ShockCapsule as WeaponDefinition
		_:
			return null

	if not _campaign_managed:
		return base

	var level: int = clampi(int(_campaign_weapon_levels.get(weapon_id, 1)), 1, base.max_level)
	var upgraded: WeaponDefinition = base.copy_at_level(level)
	_player_weapon_cache[weapon_id] = upgraded
	return upgraded

func set_progression_reward(amount: int) -> void:
	_progression_reward = maxi(0, amount)
	if result_card != null and result_card.visible:
		_update_result_card()

func _ready() -> void:
	ThemeScript.apply(hud_root)
	for card in [
		player_status_card,
		enemy_status_card,
		weapon_tray,
		weapon_info_card,
		inspect_banner,
		control_deck,
		target_card,
		feedback_plate,
		mission_brief_card,
		encounter_picker,
		result_card,
	]:
		ThemeScript.style_card(card)
	ThemeScript.style_card(control_deck, 1)
	ThemeScript.style_card(target_card, 1)
	ThemeScript.style_card(mission_brief_card, 1)
	ThemeScript.style_card(result_card, 1)
	_style_live_hud()
	if not get_viewport().size_changed.is_connected(_apply_hud_safe_area):
		get_viewport().size_changed.connect(_apply_hud_safe_area)
	_selected_weapon = _player_weapon("scrap_bolt")
	_missions = EncounterCatalogScript.all()
	player.health_changed.connect(_on_health_changed)
	enemy.health_changed.connect(_on_health_changed)
	player_cover.health_changed.connect(_on_health_changed)
	enemy_cover.health_changed.connect(_on_health_changed)
	power_cell.discharged.connect(_on_power_cell_discharged)
	inspect_button.pressed.connect(_inspect_enemy)
	mission_deploy_button.pressed.connect(_deploy_from_brief)
	scrap_bolt_button.pressed.connect(func() -> void: _select_weapon(_player_weapon("scrap_bolt")))
	heavy_slug_button.pressed.connect(func() -> void: _select_weapon(_player_weapon("heavy_slug")))
	shock_capsule_button.pressed.connect(func() -> void: _select_weapon(_player_weapon("shock_capsule")))
	restart_button.pressed.connect(_restart)
	change_encounter_button.pressed.connect(_change_encounter)

	world.visible = false
	player_status_card.visible = false
	enemy_status_card.visible = false
	health_label.visible = false
	enemy_health_label.visible = false
	inspect_button.visible = false
	enemy_locator_label.visible = false
	_set_weapon_choice_ui_visible(false)
	weapon_info_card.visible = false
	control_deck.visible = false
	inspect_banner.visible = false
	target_card.visible = false
	mission_brief_card.visible = false
	encounter_picker.visible = true
	result_card.visible = false
	restart_button.visible = false
	change_encounter_button.visible = false
	feedback_plate.visible = false
	feedback_label.visible = false
	last_impact_marker.clear_marker()

	_build_encounter_picker()
	_update_weapon_panel()
	_update_weapon_buttons()
	_capture_hud_layout()
	call_deferred("_apply_hud_safe_area")
	_set_weapon_buttons_enabled(false)
	_update_last_shot_display()
	_update_hud()

	if _campaign_managed and _prepared_mission != null:
		encounter_picker.visible = false
		restart_button.text = "REMATCH"
		change_encounter_button.text = "FORT KNOCKS"
		call_deferred("_begin_mission", _prepared_mission)
		return

	restart_button.text = "RESTART"
	change_encounter_button.text = "CHOOSE ENCOUNTER"
	_show_encounter_picker()
	if get_tree().root.has_meta(PENDING_MISSION_META):
		var pending_id := str(get_tree().root.get_meta(PENDING_MISSION_META))
		get_tree().root.remove_meta(PENDING_MISSION_META)
		if not pending_id.is_empty():
			call_deferred("_resume_pending_mission", pending_id)

func _show_encounter_picker() -> void:
	phase = Phase.INTRO
	world.visible = false
	encounter_picker.visible = true
	mission_brief_card.visible = false
	result_card.visible = false
	restart_button.visible = false
	change_encounter_button.visible = false
	player_status_card.visible = false
	enemy_status_card.visible = false
	health_label.visible = false
	enemy_health_label.visible = false
	turn_label.text = "FIELD OPERATIONS"
	turn_label.add_theme_color_override("font_color", ThemeScript.HAZARD)
	picker_briefing_label.text = "Choose one of %d field operations. Each mission uses the same core combat rules." % _missions.size()
	hint_label.text = "Select an operation to deploy"

func _resume_pending_mission(mission_id: String) -> void:
	var definition := _mission_for_id(mission_id)
	if definition != null:
		_begin_mission(definition)

func _build_encounter_picker() -> void:
	for child in mission_button_list.get_children():
		child.queue_free()

	for index in range(_missions.size()):
		var mission: MissionDefinition = _missions[index]
		var button := Button.new()
		button.custom_minimum_size = Vector2(0.0, 80.0)
		button.text = "%d  %s\n%s" % [index + 1, mission.display_name.to_upper(), mission.test_focus]
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_begin_mission.bind(mission))
		mission_button_list.add_child(button)

func _mission_for_id(mission_id: String) -> MissionDefinition:
	for mission in _missions:
		if mission.id == mission_id:
			return mission
	return null

func _begin_mission(definition: MissionDefinition) -> void:
	if definition == null:
		return
	if not _campaign_managed and not encounter_picker.visible:
		return

	_current_mission = definition
	_completion_emitted = false
	_progression_reward = 0
	_mission_deploying = false
	_reset_encounter_metrics()
	_configure_mission(definition)
	encounter_picker.visible = false
	result_card.visible = false
	restart_button.visible = false
	change_encounter_button.visible = false
	world.visible = true
	player_status_card.visible = false
	enemy_status_card.visible = false
	inspect_button.visible = false
	enemy_locator_label.visible = false
	_set_weapon_choice_ui_visible(false)
	control_deck.visible = false
	target_card.visible = false
	turn_label.text = "MISSION BRIEF"
	turn_label.add_theme_color_override("font_color", ThemeScript.HAZARD)
	hint_label.text = "Review mission details • deploy when ready"
	_update_hud()
	_show_mission_brief(definition)

func _configure_mission(definition: MissionDefinition) -> void:
	player.global_position = definition.player_position
	var player_knockback_multiplier: float = 1.0
	if _player_module != null:
		player_knockback_multiplier = _player_module.crew_knockback_multiplier
	player.configure_knockback_multiplier(player_knockback_multiplier)
	player_cover.global_position = definition.player_cover_position
	if _player_platform != null:
		player_cover.configure_platform(_player_platform, _player_module)
	var preview_steps := 9
	if _player_module != null:
		preview_steps += _player_module.trajectory_preview_steps_bonus
	aim_guide.set_preview_steps(preview_steps)
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
	_signal_relay = null
	_salvage_load = null
	for rect in definition.platform_rects:
		var platform := ArenaPlatformScript.new() as ArenaPlatform
		if platform == null:
			continue
		var platform_style := "suburbs" if definition.visual_variant == 3 else "outskirts"
		platform.configure(rect, platform_style)
		encounter_geometry.add_child(platform)

	if definition.collapsible_barrier_enabled:
		_collapsible_barrier = CollapsibleBarrierScript.new() as CollapsibleBarrier
		if _collapsible_barrier != null:
			_collapsible_barrier.position = definition.collapsible_barrier_position
			_collapsible_barrier.collapsed.connect(_on_collapsible_barrier_collapsed)
			encounter_geometry.add_child(_collapsible_barrier)

	if definition.signal_relay_enabled:
		_signal_relay = SignalRelayScript.new() as SignalRelay
		if _signal_relay != null:
			_signal_relay.position = definition.signal_relay_position
			_signal_relay.max_health = maxi(1, definition.signal_relay_health)
			_signal_relay.destroyed.connect(_on_signal_relay_destroyed)
			encounter_geometry.add_child(_signal_relay)

	if definition.salvage_load_enabled:
		_salvage_load = SalvageLoadScript.new() as SalvageLoad
		if _salvage_load != null:
			_salvage_load.position = definition.salvage_load_position
			_salvage_load.max_health = maxi(1, definition.salvage_load_health)
			_salvage_load.destroyed.connect(_on_salvage_load_destroyed)
			encounter_geometry.add_child(_salvage_load)

	if battlefield_visual.has_method("configure_variant"):
		battlefield_visual.call("configure_variant", definition.visual_variant)
	if battlefield_visual.has_method("configure_mission"):
		battlefield_visual.call("configure_mission", definition.id)
	near_occlusion.configure_variant(definition.visual_variant)
	near_occlusion.configure_platforms(definition.platform_rects)
	_apply_scene_lighting(definition.visual_variant)

func _apply_scene_lighting(visual_variant: int) -> void:
	# A common ambient grade and sun-side cast shadows make transparent hero art
	# share the backdrop's road-level lighting instead of reading as cutouts.
	var ambient := Color(0.92, 0.91, 0.89, 1.0)
	var shadow_side := 1 if visual_variant == 3 else -1
	player.shadow_direction = shadow_side
	enemy.shadow_direction = shadow_side
	player_cover.shadow_direction = shadow_side
	enemy_cover.shadow_direction = shadow_side
	for item in [player, enemy, player_cover, enemy_cover, roadblock, power_cell, _collapsible_barrier, _signal_relay, _salvage_load]:
		var canvas_item := item as CanvasItem
		if canvas_item == null:
			continue
		canvas_item.self_modulate = ambient
		canvas_item.queue_redraw()

func _focus_player(duration: float) -> void:
	# Keep the enlarged shooter and cover in the same portrait composition.
	camera_director.focus_subject(
		Vector2(lerpf(player.global_position.x, player_cover.global_position.x, 0.45), player.global_position.y),
		duration
	)

func _focus_enemy(duration: float) -> void:
	camera_director.focus_subject(
		Vector2(lerpf(enemy.global_position.x, enemy_cover.global_position.x, 0.45), enemy.global_position.y),
		duration
	)

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
	_set_weapon_choice_ui_visible(false)
	inspect_button.visible = false
	enemy_locator_label.visible = false
	_aim_power = 0.0
	_aim_angle_degrees = 0.0
	power_label.text = "POWER 0%"
	angle_label.text = "ANGLE —"
	hint_label.text = (
		"%s • SPOTTER PRECISION PREVIEW" % _selected_weapon.display_name
		if _spotter_preview_active()
		else "%s • pull back to aim" % _selected_weapon.display_name
	)

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
		_set_weapon_choice_ui_visible(true)
		inspect_button.visible = true
		enemy_locator_label.visible = enemy.is_alive()
		_update_enemy_locator()
		power_label.text = "POWER —"
		angle_label.text = "ANGLE —"
		hint_label.text = "Pull back to aim • release to fire"
		return

	_fire_projectile(player, _aim_velocity, _selected_weapon)

func _select_weapon(definition: WeaponDefinition) -> void:
	if phase != Phase.PLAYER_AIM or _dragging or _is_inspecting:
		return
	if not _is_weapon_allowed(definition):
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
	ThemeScript.mark_active(scrap_bolt_button, scrap_bolt_button.button_pressed)
	ThemeScript.mark_active(heavy_slug_button, heavy_slug_button.button_pressed)
	ThemeScript.mark_active(shock_capsule_button, shock_capsule_button.button_pressed)
	_update_weapon_button_visibility()

func _is_weapon_allowed(definition: WeaponDefinition) -> bool:
	if definition == null:
		return false
	if not _campaign_managed or _campaign_weapon_ids.is_empty():
		return true
	return _campaign_weapon_ids.has(definition.id)

func _update_weapon_button_visibility() -> void:
	scrap_bolt_button.visible = _is_weapon_allowed(ScrapBolt as WeaponDefinition)
	heavy_slug_button.visible = _is_weapon_allowed(HeavySlug as WeaponDefinition)
	shock_capsule_button.visible = _is_weapon_allowed(ShockCapsule as WeaponDefinition)

	if _campaign_managed and not _campaign_weapon_ids.is_empty():
		weapon_tray.offset_bottom = 330.0
		if shock_capsule_button.visible and not heavy_slug_button.visible:
			shock_capsule_button.offset_top = 92.0
			shock_capsule_button.offset_bottom = 134.0
	else:
		weapon_tray.offset_bottom = 378.0
		shock_capsule_button.offset_top = 144.0
		shock_capsule_button.offset_bottom = 186.0

func _set_weapon_choice_ui_visible(is_visible: bool) -> void:
	weapon_tray.visible = is_visible
	weapon_info_card.visible = is_visible

func _set_weapon_buttons_enabled(enabled: bool) -> void:
	_update_weapon_button_visibility()
	scrap_bolt_button.disabled = not enabled or not _is_weapon_allowed(ScrapBolt as WeaponDefinition)
	heavy_slug_button.disabled = not enabled or not _is_weapon_allowed(HeavySlug as WeaponDefinition)
	shock_capsule_button.disabled = not enabled or not _is_weapon_allowed(ShockCapsule as WeaponDefinition)

func _start_player_turn(show_enemy_preview: bool) -> void:
	if _check_game_over():
		return

	phase = Phase.INTRO
	_is_inspecting = false
	inspect_button.visible = false
	inspect_button.disabled = false
	inspect_button.text = "INSPECT ENEMY"
	ThemeScript.mark_active(inspect_button, false)
	inspect_banner.visible = false
	enemy_locator_label.visible = false
	_set_weapon_choice_ui_visible(false)
	control_deck.visible = false
	target_card.visible = false
	_set_weapon_buttons_enabled(false)
	aim_guide.clear()
	last_impact_marker.visible = false
	power_label.text = "POWER —"
	angle_label.text = "ANGLE —"
	turn_label.text = "YOUR TURN"
	turn_label.add_theme_color_override("font_color", ThemeScript.HAZARD)

	if show_enemy_preview:
		if _current_mission != null and _current_mission.feature_preview_enabled:
			hint_label.text = _current_mission.feature_preview_text
			camera_director.focus_x(_current_mission.feature_preview_position.x, 0.28)
			await get_tree().create_timer(0.58).timeout
			if phase == Phase.GAME_OVER:
				return

		hint_label.text = "Enemy position"
		target_card.visible = true
		_update_target_card()
		_focus_enemy(0.35)
		await get_tree().create_timer(0.70).timeout
		target_card.visible = false
		if phase == Phase.GAME_OVER:
			return

	hint_label.text = "Returning to your position"
	_focus_player(0.48)
	await get_tree().create_timer(0.52).timeout
	if phase == Phase.GAME_OVER:
		return

	phase = Phase.PLAYER_AIM
	inspect_button.visible = enemy.is_alive()
	enemy_locator_label.visible = enemy.is_alive()
	_set_weapon_choice_ui_visible(true)
	control_deck.visible = true
	target_card.visible = false
	if last_impact_marker.has_valid_marker:
		last_impact_marker.visible = true

	_set_weapon_buttons_enabled(true)
	_update_weapon_panel()
	_update_weapon_buttons()
	_update_last_shot_display()
	_update_enemy_locator()
	if not enemy.is_alive() and _current_mission != null and _current_mission.objective_mode == "disable_relay":
		hint_label.text = "Enemy down • disable the relay to finish"
	else:
		hint_label.text = (
			"SPOTTER ACTIVE • denser trajectory preview"
			if _spotter_preview_active()
			else "Pull back to aim • release to fire"
		)

func _spotter_preview_active() -> bool:
	return (
		_player_module != null
		and _player_module.trajectory_preview_steps_bonus > 0
	)

func _inspect_enemy() -> void:
	if phase != Phase.PLAYER_AIM or _dragging:
		return

	if _is_inspecting:
		_return_from_enemy_inspection()
		return

	_is_inspecting = true
	inspect_button.text = "VIEWING TARGET"
	inspect_button.disabled = true
	ThemeScript.mark_active(inspect_button, true)
	enemy_locator_label.visible = false
	_set_weapon_choice_ui_visible(false)
	control_deck.visible = false
	target_card.visible = false
	inspect_banner_title.text = "TACTICAL INSPECTION"
	inspect_banner_subtitle.text = "ACQUIRING TARGET POSITION"
	inspect_banner.visible = true
	_set_weapon_buttons_enabled(false)

	hint_label.text = "Moving to enemy position"
	_focus_enemy(0.36)
	await get_tree().create_timer(0.38).timeout
	if phase != Phase.PLAYER_AIM or not _is_inspecting:
		return

	_update_target_card()
	target_card.visible = true
	inspect_banner_subtitle.text = "READ POSITION • COVER • HAZARDS"
	inspect_button.text = "RETURN TO SHOOTER"
	inspect_button.disabled = false
	hint_label.text = "Review target • return when ready"

func _return_from_enemy_inspection() -> void:
	if not _is_inspecting or phase != Phase.PLAYER_AIM:
		return

	inspect_button.disabled = true
	inspect_button.text = "RETURNING..."
	target_card.visible = false
	inspect_banner_title.text = "RETURNING TO SHOOTER"
	inspect_banner_subtitle.text = "AIM STATE PRESERVED"
	hint_label.text = "Returning to your shooter"
	_focus_player(0.38)
	await get_tree().create_timer(0.42).timeout
	if phase != Phase.PLAYER_AIM:
		_is_inspecting = false
		inspect_banner.visible = false
		inspect_button.disabled = false
		inspect_button.text = "INSPECT ENEMY"
		ThemeScript.mark_active(inspect_button, false)
		return

	_is_inspecting = false
	inspect_banner.visible = false
	inspect_button.disabled = false
	inspect_button.text = "INSPECT ENEMY"
	ThemeScript.mark_active(inspect_button, false)
	enemy_locator_label.visible = enemy.is_alive()
	_set_weapon_choice_ui_visible(true)
	control_deck.visible = true
	target_card.visible = false
	_update_enemy_locator()
	_set_weapon_buttons_enabled(true)
	hint_label.text = (
		"SPOTTER ACTIVE • denser trajectory preview"
		if _spotter_preview_active()
		else "Pull back to aim • release to fire"
	)

func _start_enemy_turn() -> void:
	if _check_game_over():
		return
	if not enemy.is_alive():
		phase = Phase.SETTLE
		hint_label.text = "Enemy down — finish the mission objective"
		await get_tree().create_timer(0.35).timeout
		_start_player_turn(false)
		return

	phase = Phase.ENEMY_THINKING
	_is_inspecting = false
	inspect_button.visible = false
	inspect_button.text = "INSPECT ENEMY"
	ThemeScript.mark_active(inspect_button, false)
	inspect_banner.visible = false
	enemy_locator_label.visible = false
	_set_weapon_choice_ui_visible(false)
	control_deck.visible = false
	target_card.visible = false
	last_impact_marker.visible = false
	_set_weapon_buttons_enabled(false)
	aim_guide.clear()
	turn_label.text = "ENEMY TURN"
	turn_label.add_theme_color_override("font_color", ThemeScript.SIGNAL)
	hint_label.text = _enemy_tactic_turn_hint()
	_focus_enemy(0.42)

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

func _enemy_tactic_turn_hint() -> String:
	var tactic: String = _current_mission.enemy_tactic if _current_mission != null else "balanced"
	match tactic:
		"breacher":
			return "Breacher crew is pressuring your cover"
		"displacer":
			return "Displacer crew is setting up a pressure shot"
		"raider":
			return "Raider crew is targeting the Salvage load"
		_:
			return "Enemy is choosing a shot"

func _enemy_tactic_brief() -> String:
	var tactic: String = _current_mission.enemy_tactic if _current_mission != null else "balanced"
	match tactic:
		"breacher":
			return "BREACHER • HEAVY COVER PRESSURE"
		"displacer":
			return "DISPLACER • SHOCK / POSITION PRESSURE"
		"raider":
			return "RAIDER • OBJECTIVE PRESSURE"
		_:
			return "BALANCED"

func _choose_enemy_weapon() -> WeaponDefinition:
	var tactic: String = _current_mission.enemy_tactic if _current_mission != null else "balanced"
	match tactic:
		"breacher":
			if not player_cover.is_destroyed and randf() < 0.86:
				return HeavySlug as WeaponDefinition
			if randf() < 0.30:
				return ShockCapsule as WeaponDefinition
			return ScrapBolt as WeaponDefinition
		"displacer":
			if randf() < 0.68:
				return ShockCapsule as WeaponDefinition
			if not player_cover.is_destroyed and randf() < 0.42:
				return HeavySlug as WeaponDefinition
			return ScrapBolt as WeaponDefinition
		"raider":
			if randf() < 0.64:
				return HeavySlug as WeaponDefinition
			if randf() < 0.22:
				return ShockCapsule as WeaponDefinition
			return ScrapBolt as WeaponDefinition
		_:
			if not player_cover.is_destroyed and randf() < 0.68:
				return HeavySlug as WeaponDefinition
			if player_cover.is_destroyed and randf() < 0.46:
				return ShockCapsule as WeaponDefinition
			return ScrapBolt as WeaponDefinition

func _choose_enemy_target(weapon: WeaponDefinition) -> Vector2:
	var tactic: String = _current_mission.enemy_tactic if _current_mission != null else "balanced"
	if (
		tactic == "raider"
		and _salvage_load != null
		and is_instance_valid(_salvage_load)
		and not _salvage_load.is_destroyed
		and randf() < 0.76
	):
		if weapon.id == "shock_capsule":
			return _salvage_load.global_position + Vector2(-45.0, -20.0)
		return _salvage_load.global_position + Vector2(0.0, -42.0)
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
		_player_shots_fired += 1
		if weapon != null and _weapon_shots.has(weapon.id):
			_weapon_shots[weapon.id] = int(_weapon_shots[weapon.id]) + 1

	phase = Phase.PROJECTILE_FLIGHT
	_is_inspecting = false
	inspect_button.visible = false
	inspect_button.text = "INSPECT ENEMY"
	ThemeScript.mark_active(inspect_button, false)
	inspect_banner.visible = false
	enemy_locator_label.visible = false
	_set_weapon_choice_ui_visible(false)
	control_deck.visible = false
	target_card.visible = false
	last_impact_marker.visible = false
	_set_weapon_buttons_enabled(false)
	_active_shooter = shooter
	aim_guide.clear()
	hint_label.text = "%s away" % weapon.display_name
	_play_audio(_fire_cue(weapon))

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
	_play_audio(&"ricochet")
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
		_play_audio(&"surge")
		_apply_weapon_pulse(impact_position, weapon, hit_body)
		_spawn_impact_effect(impact_position, ImpactEffect.Kind.PULSE, 1.15)
		camera_director.impact_impulse(1.0, direction)
		_show_feedback("SHOCK PULSE")
		hint_label.text = "Pressure pulse affected nearby targets"
	elif hit_body is Combatant:
		_play_audio(&"hit_crew")
		_spawn_impact_effect(impact_position, ImpactEffect.Kind.CREW, impact_strength)
		_spawn_damage_popup(impact_position + Vector2(0.0, -90.0), "-%d" % damage_amount, Color("ef9b84"))
		_show_feedback("DIRECT HIT")
		camera_director.impact_impulse(1.0, direction)
		hint_label.text = "Direct hit"
	elif hit_body is DestructibleCover:
		_play_audio(&"hit_metal")
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
		_play_audio(&"hit_metal")
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
	elif hit_body is SignalRelay:
		_play_audio(&"hit_metal")
		var relay: SignalRelay = hit_body as SignalRelay
		_spawn_impact_effect(impact_position, ImpactEffect.Kind.COVER, impact_strength)
		_spawn_damage_popup(impact_position + Vector2(0.0, -120.0), "-%d RELAY" % damage_amount, Color("8fcfd0"))
		if relay.is_destroyed:
			_show_feedback("RELAY OFFLINE")
			hint_label.text = "Signal relay disabled"
			camera_director.impact_impulse(1.0, direction)
		else:
			_show_feedback("RELAY HIT")
			hint_label.text = relay.status_text()
			camera_director.impact_impulse(0.72, direction)
	elif hit_body is SalvageLoad:
		_play_audio(&"hit_metal")
		var salvage: SalvageLoad = hit_body as SalvageLoad
		_spawn_impact_effect(impact_position, ImpactEffect.Kind.COVER, impact_strength)
		_spawn_damage_popup(impact_position + Vector2(0.0, -95.0), "-%d SALVAGE" % damage_amount, Color("e4bd78"))
		if salvage.is_destroyed:
			_show_feedback("SALVAGE LOST")
			hint_label.text = "Protected Salvage destroyed"
			camera_director.impact_impulse(1.0, direction)
		else:
			_show_feedback("SALVAGE HIT")
			hint_label.text = salvage.status_text()
			camera_director.impact_impulse(0.72, direction)
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

	if hit_body is Combatant:
		_player_direct_hits += 1
	elif hit_body is DestructibleCover:
		_player_cover_hits += 1

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
	if hit_body is SignalRelay:
		return "RELAY"
	if hit_body is SalvageLoad:
		return "SALVAGE"
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
	if _signal_relay != null and is_instance_valid(_signal_relay) and not _signal_relay.is_destroyed:
		candidates.append(_signal_relay)
	if _salvage_load != null and is_instance_valid(_salvage_load) and not _salvage_load.is_destroyed:
		candidates.append(_salvage_load)

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
		elif target is SignalRelay:
			_spawn_damage_popup(target.global_position + Vector2(0.0, -125.0), "-%d RELAY" % pulse_damage, Color("8fcfd0"))
		elif target is SalvageLoad:
			_spawn_damage_popup(target.global_position + Vector2(0.0, -105.0), "-%d SALVAGE" % pulse_damage, Color("e4bd78"))

func _on_collapsible_barrier_collapsed(world_position: Vector2) -> void:
	if _active_shooter == player:
		_player_environment_events += 1
	_spawn_impact_effect(world_position, ImpactEffect.Kind.DUST, 1.0)

func _on_signal_relay_destroyed(world_position: Vector2) -> void:
	if _active_shooter == player:
		_player_environment_events += 1
	_play_audio(&"surge")
	_spawn_impact_effect(world_position + Vector2(0.0, -90.0), ImpactEffect.Kind.PULSE, 1.0)
	camera_director.stop_follow_at(world_position, 0.08)
	_show_feedback("RELAY OFFLINE")
	hint_label.text = "Objective complete — relay disabled"

func _on_salvage_load_destroyed(world_position: Vector2) -> void:
	_play_audio(&"hit_metal")
	_spawn_impact_effect(world_position + Vector2(0.0, -50.0), ImpactEffect.Kind.COVER, 1.15)
	camera_director.stop_follow_at(world_position, 0.08)
	_show_feedback("SALVAGE LOST")
	hint_label.text = "Protected Salvage destroyed"

func _on_power_cell_discharged(world_position: Vector2, radius: float, damage: int, force: float) -> void:
	_play_audio(&"surge")
	if _active_shooter == player:
		_player_environment_events += 1
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
	if _salvage_load != null and is_instance_valid(_salvage_load) and not _salvage_load.is_destroyed:
		targets.append(_salvage_load)
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
		elif target is SalvageLoad:
			_spawn_damage_popup(target.global_position + Vector2(0.0, -100.0), "-%d SALVAGE" % applied_damage, Color("e4bd78"))

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
	feedback_plate.visible = true
	feedback_label.visible = true
	feedback_plate.modulate = Color.WHITE
	feedback_label.modulate = Color.WHITE
	feedback_plate.scale = Vector2(0.90, 0.90)
	feedback_label.scale = Vector2(0.86, 0.86)

	_feedback_tween = create_tween()
	_feedback_tween.set_parallel(true)
	_feedback_tween.tween_property(feedback_plate, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_feedback_tween.tween_property(feedback_label, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_feedback_tween.tween_property(feedback_plate, "modulate:a", 0.0, 0.66).set_delay(0.24)
	_feedback_tween.tween_property(feedback_label, "modulate:a", 0.0, 0.66).set_delay(0.24)
	_feedback_tween.chain().tween_callback(_hide_feedback)

func _hide_feedback() -> void:
	feedback_plate.visible = false
	feedback_label.visible = false

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

func _objective_completed() -> bool:
	if _current_mission != null:
		match _current_mission.objective_mode:
			"disable_relay":
				return _signal_relay != null and is_instance_valid(_signal_relay) and _signal_relay.is_destroyed
			"protect_salvage":
				return (
					not enemy.is_alive()
					and _salvage_load != null
					and is_instance_valid(_salvage_load)
					and not _salvage_load.is_destroyed
				)
	return not enemy.is_alive()

func _objective_failed() -> bool:
	return (
		_current_mission != null
		and _current_mission.objective_mode == "protect_salvage"
		and _salvage_load != null
		and is_instance_valid(_salvage_load)
		and _salvage_load.is_destroyed
	)

func _check_game_over() -> bool:
	var victory: bool = player.is_alive() and _objective_completed()
	var defeat: bool = not player.is_alive() or _objective_failed()
	if not victory and not defeat:
		return false

	phase = Phase.GAME_OVER
	_is_inspecting = false
	inspect_button.visible = false
	inspect_button.text = "INSPECT ENEMY"
	ThemeScript.mark_active(inspect_button, false)
	inspect_banner.visible = false
	enemy_locator_label.visible = false
	_set_weapon_choice_ui_visible(false)
	control_deck.visible = false
	target_card.visible = false
	last_impact_marker.visible = false
	_set_weapon_buttons_enabled(false)
	aim_guide.clear()
	player_status_card.visible = false
	enemy_status_card.visible = false
	result_card.visible = true
	restart_button.visible = true
	change_encounter_button.visible = true

	if victory:
		turn_label.text = "YOU WIN"
		turn_label.add_theme_color_override("font_color", ThemeScript.HAZARD)
		result_title_label.text = "VICTORY"
		if _current_mission != null and _current_mission.objective_mode == "disable_relay":
			hint_label.text = "Signal relay disabled — route opened"
			if _signal_relay != null and is_instance_valid(_signal_relay):
				camera_director.focus_x(_signal_relay.global_position.x, 0.35)
			else:
				_focus_enemy(0.35)
		elif _current_mission != null and _current_mission.objective_mode == "protect_salvage":
			hint_label.text = "Raiders cleared — Salvage secured"
			if _salvage_load != null and is_instance_valid(_salvage_load):
				camera_director.focus_x(_salvage_load.global_position.x, 0.35)
			else:
				_focus_enemy(0.35)
		else:
			hint_label.text = "Enemy survivor incapacitated"
			_focus_enemy(0.35)
	else:
		turn_label.text = "DEFEAT"
		turn_label.add_theme_color_override("font_color", ThemeScript.SIGNAL)
		result_title_label.text = "DEFEAT"
		if _objective_failed():
			hint_label.text = "Protected Salvage was destroyed"
			if _salvage_load != null and is_instance_valid(_salvage_load):
				camera_director.focus_x(_salvage_load.global_position.x, 0.35)
			else:
				_focus_player(0.35)
		else:
			hint_label.text = "Your survivor was incapacitated"
			_focus_player(0.35)

	if not _completion_emitted:
		_play_audio(&"victory" if victory else &"defeat")
		_completion_emitted = true
		battle_completed.emit({
			"victory": victory,
			"mission_id": _current_mission.id if _current_mission != null else "",
			"shots": _player_shots_fired,
			"direct_hits": _player_direct_hits,
			"cover_hits": _player_cover_hits,
			"environment_events": _player_environment_events,
			"weapon_shots": _weapon_shots.duplicate(true),
		})

	_update_result_card()
	return true

func _reset_encounter_metrics() -> void:
	_player_shots_fired = 0
	_player_direct_hits = 0
	_player_cover_hits = 0
	_player_environment_events = 0
	_weapon_shots["scrap_bolt"] = 0
	_weapon_shots["heavy_slug"] = 0
	_weapon_shots["shock_capsule"] = 0

func _show_mission_brief(definition: MissionDefinition) -> void:
	mission_brief_region.text = "%s • MISSION %02d" % [
		_mission_region_text(definition),
		maxi(1, definition.campaign_order),
	]
	mission_brief_title.text = definition.display_name.to_upper()
	mission_brief_objective.text = definition.objective_text.to_upper()
	mission_brief_text.text = definition.briefing
	if _campaign_managed:
		mission_brief_tactic.text = "ENEMY • %s" % _enemy_tactic_brief()
		mission_brief_loadout.text = _mission_loadout_text()
		mission_deploy_button.text = "DEPLOY"
	else:
		mission_brief_region.text = "ENCOUNTER PROOF"
		mission_brief_tactic.text = "TEST • %s" % definition.test_focus.to_upper()
		mission_brief_loadout.text = "FIELD TEST • BOLT / SLUG / SHOCK"
		mission_deploy_button.text = "BEGIN ENCOUNTER"
	mission_deploy_button.disabled = false
	mission_brief_card.visible = true

func _deploy_from_brief() -> void:
	if phase != Phase.INTRO or not mission_brief_card.visible or _mission_deploying:
		return

	_mission_deploying = true
	mission_deploy_button.disabled = true
	mission_deploy_button.text = "DEPLOYING..."
	mission_brief_card.visible = false
	player_status_card.visible = true
	enemy_status_card.visible = true
	health_label.visible = true
	enemy_health_label.visible = true
	hint_label.text = "Scanning battlefield"
	_start_player_turn(true)

func _mission_region_text(definition: MissionDefinition) -> String:
	if definition != null and definition.id.begins_with("suburbs_"):
		return "SUBURBS"
	return "OUTSKIRTS"

func _mission_loadout_text() -> String:
	if not _campaign_managed:
		return "FIELD TEST • BOLT / SLUG / SHOCK"

	var lines: Array[String] = []
	if _player_platform != null:
		var effective_cover := _player_platform.cover_health
		if _player_module != null:
			effective_cover += _player_module.cover_health_bonus
		lines.append("PLATFORM • %s • %d COVER" % [
			_player_platform.display_name.to_upper(),
			effective_cover,
		])
	if _player_module != null:
		lines.append("MODULE • %s" % _player_module.display_name.to_upper())

	var rack := "BOLT"
	if _campaign_weapon_ids.has("heavy_slug") and _campaign_weapon_ids.has("shock_capsule"):
		rack = "BOLT + SLUG + SHOCK"
	elif _campaign_weapon_ids.has("heavy_slug"):
		rack = "BOLT + SLUG"
	elif _campaign_weapon_ids.has("shock_capsule"):
		rack = "BOLT + SHOCK"
	lines.append("FIELD RACK • %s" % rack)
	return "\n".join(lines)

func _update_result_card() -> void:
	if _current_mission == null:
		return

	var victory := player.is_alive() and _objective_completed()
	var region := _mission_region_text(_current_mission)
	result_region_label.text = "%s • %s" % [
		region,
		"MISSION COMPLETE" if victory else "MISSION FAILED",
	]
	result_title_label.text = "VICTORY" if victory else "DEFEAT"
	result_title_label.add_theme_color_override(
		"font_color",
		ThemeScript.HAZARD if victory else ThemeScript.SIGNAL
	)
	result_encounter_label.text = _current_mission.display_name.to_upper()
	result_objective_label.text = "%s\n%s" % [
		"OBJECTIVE SECURED" if victory else "OBJECTIVE FAILED",
		_current_mission.objective_text.to_upper(),
	]

	if not _campaign_managed:
		result_clear_state_label.text = "ENCOUNTER PROOF"
		result_reward_label.text = "NO CAMPAIGN REWARD"
		result_unlock_label.text = "DEVELOPMENT ENCOUNTER"
		result_summary_label.text = "SHOTS %d • DIRECT %d • COVER %d • ENV %d" % [
			_player_shots_fired,
			_player_direct_hits,
			_player_cover_hits,
			_player_environment_events,
		]
		return

	if not victory:
		result_clear_state_label.text = "RUN FAILED"
		result_reward_label.text = "NO SALVAGE RECOVERED"
		result_unlock_label.text = "ROUTE UNCHANGED"
		result_summary_label.text = _campaign_result_summary(false)
		return

	if _progression_reward > 0:
		result_clear_state_label.text = "FIRST CLEAR"
		result_reward_label.text = "+%d SALVAGE" % _progression_reward
		var next_mission: MissionDefinition = EncounterCatalogScript.by_id(_current_mission.next_mission_id)
		if next_mission != null:
			result_unlock_label.text = "NEW ROUTE • %s" % next_mission.display_name.to_upper()
		else:
			result_unlock_label.text = "%s SECURED" % region
	else:
		result_clear_state_label.text = "REPLAY CLEAR"
		result_reward_label.text = "NO NEW SALVAGE"
		result_unlock_label.text = "ROUTE ALREADY SECURED"

	result_summary_label.text = _campaign_result_summary(true)

func _campaign_result_summary(victory: bool) -> String:
	if not victory:
		if _objective_failed():
			return "The protected Salvage was lost. Regroup at Fort Knocks and try the route again."
		return "Your survivor was incapacitated. Regroup at Fort Knocks or rematch the route."

	if _current_mission != null:
		match _current_mission.objective_mode:
			"disable_relay":
				return "Signal relay disabled. The route is open."
			"protect_salvage":
				return "Raiders cleared. The Salvage load is secure."
	return "Enemy resistance cleared. Fort Knocks can push the route forward."

func _on_health_changed(_current: int, _maximum: int) -> void:
	_update_hud()

func _update_hud() -> void:
	health_label.text = "YOU  %d/%d" % [player.health, player.max_health]
	player_cover_label.text = "COVER  %d/%d" % [player_cover.health, player_cover.max_health]
	enemy_health_label.text = "ENEMY  %d/%d" % [enemy.health, enemy.max_health]
	enemy_cover_label.text = "COVER  %d/%d" % [enemy_cover.health, enemy_cover.max_health]
	_update_status_bar(player_health_bar_back, player_health_bar_fill, player.health, player.max_health, ThemeScript.HAZARD)
	_update_status_bar(player_cover_bar_back, player_cover_bar_fill, player_cover.health, player_cover.max_health, ThemeScript.OXIDE)
	_update_status_bar(enemy_health_bar_back, enemy_health_bar_fill, enemy.health, enemy.max_health, ThemeScript.SIGNAL)
	_update_status_bar(enemy_cover_bar_back, enemy_cover_bar_fill, enemy_cover.health, enemy_cover.max_health, ThemeScript.RUST)
	if enemy_locator_label.visible:
		_update_enemy_locator()
	if target_card.visible:
		_update_target_card()

func _update_status_bar(
	back: ColorRect,
	fill: ColorRect,
	current: int,
	maximum: int,
	normal_color: Color
) -> void:
	if back == null or fill == null:
		return
	var ratio := 0.0
	if maximum > 0:
		ratio = clampf(float(current) / float(maximum), 0.0, 1.0)
	var width := back.offset_right - back.offset_left
	fill.offset_left = back.offset_left
	fill.offset_right = back.offset_left + width * ratio
	fill.color = ThemeScript.SIGNAL if ratio <= 0.30 else normal_color

func _update_target_card() -> void:
	target_title_label.text = "TACTICAL READOUT"
	var objective_text := "INCAPACITATE ENEMY"
	if _current_mission != null:
		objective_text = _current_mission.objective_text
	target_objective_label.text = "OBJECTIVE • %s" % objective_text
	target_enemy_label.text = "ENEMY  %d/%d" % [enemy.health, enemy.max_health]
	_update_status_bar(
		target_enemy_bar_back,
		target_enemy_bar_fill,
		enemy.health,
		enemy.max_health,
		ThemeScript.SIGNAL
	)

	var stage := enemy_cover.get_damage_stage()
	var cover_state := "INTACT"
	match stage:
		1:
			cover_state = "DAMAGED"
		2:
			cover_state = "CRITICAL"
		3:
			cover_state = "RUBBLE"
	target_cover_label.text = "COVER  %d/%d • %s" % [
		enemy_cover.health,
		enemy_cover.max_health,
		cover_state,
	]
	_update_status_bar(
		target_cover_bar_back,
		target_cover_bar_fill,
		enemy_cover.health,
		enemy_cover.max_health,
		ThemeScript.RUST
	)
	target_tactic_label.text = "TACTIC • %s" % _enemy_tactic_brief()

	if _salvage_load != null and is_instance_valid(_salvage_load):
		if _current_mission != null and _current_mission.power_cell_enabled:
			var cell_state: String = "SPENT" if power_cell.is_discharged else "ACTIVE"
			target_hazard_label.text = "ENVIRONMENT • SALVAGE %d/%d • CELL %s" % [
				_salvage_load.health,
				_salvage_load.max_health,
				cell_state,
			]
		else:
			target_hazard_label.text = "ENVIRONMENT • %s" % _salvage_load.status_text()
	elif _signal_relay != null and is_instance_valid(_signal_relay):
		target_hazard_label.text = "ENVIRONMENT • %s" % _signal_relay.status_text()
	elif _current_mission != null and _current_mission.power_cell_enabled:
		target_hazard_label.text = (
			"ENVIRONMENT • POWER CELL SPENT"
			if power_cell.is_discharged
			else "ENVIRONMENT • POWER CELL ACTIVE"
		)
	elif _collapsible_barrier != null and is_instance_valid(_collapsible_barrier):
		target_hazard_label.text = "ENVIRONMENT • %s" % _collapsible_barrier.status_text()
	else:
		target_hazard_label.text = "ENVIRONMENT • NO ACTIVE HAZARD"

func _update_enemy_locator() -> void:
	if not enemy.is_alive():
		enemy_locator_label.visible = false
		return

	var delta_x := enemy.global_position.x - player.global_position.x
	var arrow := "→" if delta_x >= 0.0 else "←"
	var approximate_metres := maxi(1, int(round(absf(delta_x) / 40.0)))
	enemy_locator_label.text = "ENEMY %s  ~%dm" % [arrow, approximate_metres]

func _restart() -> void:
	if _campaign_managed:
		rematch_requested.emit()
		return

	if _current_mission != null:
		get_tree().root.set_meta(PENDING_MISSION_META, _current_mission.id)
	get_tree().reload_current_scene()

func _change_encounter() -> void:
	if _campaign_managed:
		exit_requested.emit()
		return

	if get_tree().root.has_meta(PENDING_MISSION_META):
		get_tree().root.remove_meta(PENDING_MISSION_META)
	get_tree().reload_current_scene()


func _fire_cue(weapon: WeaponDefinition) -> StringName:
	if weapon == null:
		return &"fire"
	match weapon.id:
		"heavy_slug":
			return &"fire_heavy"
		"shock_capsule":
			return &"fire_shock"
		_:
			return &"fire"

func _play_audio(cue: StringName) -> void:
	var audio := get_tree().get_first_node_in_group("fort_knocks_audio")
	if audio != null and audio.has_method("play_cue"):
		audio.call("play_cue", cue)
