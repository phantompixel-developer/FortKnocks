@tool
class_name UpgradeButton
extends Button
## Green upgrade button: "<label> [coin] <cost>". Visual states come from the
## UpgradeButton theme variation (normal / pressed / disabled).

@export var label_text := "UPGRADE":
	set(v):
		label_text = v
		_refresh()
@export var cost := 0:
	set(v):
		cost = v
		_refresh()
@export var show_cost := true:
	set(v):
		show_cost = v
		_refresh()


func _ready() -> void:
	_refresh()


## Enable/disable and dim the content to match the disabled skin.
func set_available(available: bool) -> void:
	disabled = not available
	%Content.modulate = Color.WHITE if available else Color(1, 1, 1, 0.55)


func _refresh() -> void:
	if not is_node_ready():
		return
	%Label.text = label_text
	%Cost.text = format_number(cost)
	%Coin.visible = show_cost
	%Cost.visible = show_cost


static func format_number(n: int) -> String:
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if n < 0 else "") + s + out
