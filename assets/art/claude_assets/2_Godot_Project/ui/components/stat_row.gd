@tool
class_name StatRow
extends HBoxContainer
## One stat line: icon, label and a segmented bar.
## value   = number of filled segments
## preview = extra segments shown as "next upgrade" (lighter blue)

const SEG_EMPTY := preload("res://assets/shared/ui/statbar_seg_empty_9s.png")
const SEG_FILLED := preload("res://assets/shared/ui/statbar_seg_filled_9s.png")
const SEG_PREVIEW := preload("res://assets/shared/ui/statbar_seg_preview_9s.png")
const SEG_MARGIN := 12

@export var icon: Texture2D:
	set(v):
		icon = v
		_refresh()
@export var label_text := "STAT":
	set(v):
		label_text = v
		_refresh()
@export var label_width := 230.0:
	set(v):
		label_width = v
		_refresh()
@export_range(1, 10) var segments := 4:
	set(v):
		segments = v
		_refresh()
@export_range(0, 10) var value := 1:
	set(v):
		value = v
		_refresh()
@export_range(0, 10) var preview := 0:
	set(v):
		preview = v
		_refresh()


func _ready() -> void:
	_refresh()


func set_stat(new_value: int, new_preview: int = 0) -> void:
	value = new_value
	preview = new_preview


func _refresh() -> void:
	if not is_node_ready():
		return
	%Icon.texture = icon
	%Label.text = label_text
	%Label.custom_minimum_size.x = label_width
	var box: HBoxContainer = %Segments
	while box.get_child_count() < segments:
		var seg := NinePatchRect.new()
		seg.patch_margin_left = SEG_MARGIN
		seg.patch_margin_top = SEG_MARGIN
		seg.patch_margin_right = SEG_MARGIN
		seg.patch_margin_bottom = SEG_MARGIN
		seg.custom_minimum_size = Vector2(60, 46)
		seg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		seg.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		seg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(seg)
	while box.get_child_count() > segments:
		var last := box.get_child(box.get_child_count() - 1)
		box.remove_child(last)
		last.queue_free()
	for i in segments:
		var seg := box.get_child(i) as NinePatchRect
		if i < value:
			seg.texture = SEG_FILLED
		elif i < value + preview:
			seg.texture = SEG_PREVIEW
		else:
			seg.texture = SEG_EMPTY
