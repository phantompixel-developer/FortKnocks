class_name MissionPin
extends Button
## A mission on the board. 140x140 invisible touch area around a 108px pin graphic.

enum State { COMPLETED, CURRENT, LOCKED, AVAILABLE }

const TEX := {
	State.COMPLETED: preload("res://assets/command_board/ui/mission_pin_completed.png"),
	State.CURRENT: preload("res://assets/command_board/ui/mission_pin_current.png"),
	State.LOCKED: preload("res://assets/command_board/ui/mission_pin_locked.png"),
	State.AVAILABLE: preload("res://assets/command_board/ui/mission_pin_available.png"),
}
## Offset from this button's top-left to the visual centre of the pin.
const CENTER := Vector2(70, 67)

var state := State.LOCKED
var mission: MissionData
var context := {}
var _pulse: Tween


func setup(p_mission: MissionData, p_state: int, number: int, p_context: Dictionary) -> void:
	mission = p_mission
	state = p_state
	context = p_context
	%Icon.texture = TEX[state]
	%Number.text = str(number)
	%Glow.visible = state == State.CURRENT
	%Tag.modulate.a = 0.75 if state == State.LOCKED else 1.0
	if state == State.CURRENT:
		_start_pulse.call_deferred()


func shake() -> void:
	var t := create_tween()
	var x0: float = %Icon.position.x
	for dx in [10.0, -8.0, 6.0, -4.0, 0.0]:
		t.tween_property(%Icon, "position:x", x0 + dx, 0.05)


func _start_pulse() -> void:
	var g: TextureRect = %Glow
	g.pivot_offset = g.size * 0.5
	if _pulse:
		_pulse.kill()
	_pulse = create_tween().set_loops()
	_pulse.tween_property(g, "scale", Vector2(1.15, 1.15), 0.7).set_trans(Tween.TRANS_SINE)
	_pulse.parallel().tween_property(g, "modulate:a", 0.55, 0.7).set_trans(Tween.TRANS_SINE)
	_pulse.tween_property(g, "scale", Vector2(0.9, 0.9), 0.7).set_trans(Tween.TRANS_SINE)
	_pulse.parallel().tween_property(g, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE)
