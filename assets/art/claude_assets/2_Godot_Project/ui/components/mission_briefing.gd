class_name MissionBriefing
extends Control
## Shared compact mission briefing (built from the shared Fort Knocks panel + button).
## Anything that wants to brief a mission calls open(); gameplay is launched by
## whoever listens to `deploy_requested` - never by this component.

signal deploy_requested(mission_id: StringName, mission: Resource, context: Dictionary)
signal closed

var _mission: Resource
var _context := {}
var _tween: Tween


func _ready() -> void:
	visible = false
	%Dim.gui_input.connect(_on_dim_input)
	%CloseButton.pressed.connect(close)
	%DeployButton.pressed.connect(_on_deploy)


## mission: a MissionData (needs id, title, objective, reward_coins).
## context keys (all optional): region_name, chapter_number, mission_number, photo, completed
func open(mission: Resource, context: Dictionary = {}) -> void:
	_mission = mission
	_context = context
	%Title.text = String(mission.title).to_upper()
	var bits: PackedStringArray = []
	if context.has("mission_number"):
		bits.append("MISSION %d" % context.mission_number)
	if context.has("region_name"):
		bits.append(String(context.region_name))
	if context.has("chapter_number"):
		bits.append("CHAPTER %d" % context.chapter_number)
	%Subtitle.text = "  ·  ".join(bits)
	%Status.visible = context.get("completed", false)
	%Photo.texture = context.get("photo", null)
	%PhotoFrame.visible = %Photo.texture != null
	%Objective.text = mission.objective
	%Reward.text = UpgradeButton.format_number(mission.reward_coins)
	%DeployButton.label_text = "DEPLOY"
	visible = true
	_animate_in()


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func is_open() -> bool:
	return visible


func _on_deploy() -> void:
	if _mission:
		deploy_requested.emit(_mission.id, _mission, _context)


func _on_dim_input(e: InputEvent) -> void:
	if (e is InputEventMouseButton and e.pressed) or (e is InputEventScreenTouch and e.pressed):
		close()


func _unhandled_input(e: InputEvent) -> void:
	if visible and e.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _animate_in() -> void:
	var p: Control = %Panel
	p.pivot_offset = p.size * 0.5
	if _tween:
		_tween.kill()
	p.scale = Vector2(0.92, 0.92)
	%Dim.modulate.a = 0.0
	p.modulate.a = 0.0
	_tween = create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(p, "scale", Vector2.ONE, 0.22)
	_tween.tween_property(p, "modulate:a", 1.0, 0.15)
	_tween.tween_property(%Dim, "modulate:a", 1.0, 0.15)
