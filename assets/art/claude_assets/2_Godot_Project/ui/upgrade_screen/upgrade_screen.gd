class_name UpgradeScreen
extends Control
## Shared logic for the Garage and Workshop screens (and any future
## "pick an item, see it large, upgrade it" screen).
## Presentation only: game code sets `items` + `player_coins` and listens to the signals.

signal back_requested
signal upgrade_requested(item: UpgradeItemData)
signal item_selected(item: UpgradeItemData)

const ItemCardScene := preload("res://ui/components/item_card.tscn")
const LOCKED_TINT := Color(0.42, 0.45, 0.52)
const SWIPE_MIN := 90.0

@export var items: Array[UpgradeItemData] = []
@export var player_coins := 5000:
	set(v):
		player_coins = v
		if is_node_ready():
			_show(selected_index, false)
@export var selected_index := 0

@export_group("Layout")
## Number of bar segments on every stat row. Change this to 5 (etc.) at any time.
@export_range(1, 10) var stat_segments := 4:
	set(v):
		stat_segments = v
		if is_node_ready():
			_apply_segments()
@export var card_size := Vector2(344, 282)
@export var card_separation := 18
@export var show_card_captions := false
## Width of the stat name column (widen for long labels like EXPLOSION).
@export var stat_label_width := 230.0
## If > 0, the display art and its shadow also widen with the showroom height
## (matching how the background scales on tall screens). Set it to the
## showroom height at 1080x1920. 0 = off (fixed-width display).
@export var display_reference_height := 0.0
## Text on the button for locked items.
@export var unlock_label := "UNLOCK"

var _rows: Array[StatRow] = []
var _swipe_start := Vector2.INF
var _display_tween: Tween


func _ready() -> void:
	for c in %Rows.get_children():
		if c is StatRow:
			_rows.append(c)
	_apply_segments()
	%BackButton.pressed.connect(func(): back_requested.emit())
	%PrevButton.pressed.connect(step.bind(-1))
	%NextButton.pressed.connect(step.bind(1))
	%UpgradeButton.pressed.connect(_on_upgrade_pressed)
	%SwipeArea.gui_input.connect(_on_swipe_input)
	%CardRow.add_theme_constant_override("separation", card_separation)
	%Header.item_rect_changed.connect(_sync_showroom)
	resized.connect(_sync_showroom)
	_build_cards()
	_show(selected_index, false)
	_sync_showroom.call_deferred()


## Call after changing `items` (e.g. after an upgrade or unlock).
func refresh() -> void:
	_build_cards()
	_show(selected_index, false)


## Move the selection by `dir` (-1 / +1).
func step(dir: int) -> void:
	if not items.is_empty():
		_show(clampi(selected_index + dir, 0, items.size() - 1))


func _apply_segments() -> void:
	for r in _rows:
		r.segments = stat_segments
		r.label_width = stat_label_width


func _build_cards() -> void:
	for c in %CardRow.get_children():
		c.queue_free()
	for i in items.size():
		var it := items[i]
		var card: ItemCard = ItemCardScene.instantiate()
		card.custom_minimum_size = card_size
		card.thumbnail = it.thumbnail
		card.locked = it.locked
		card.caption = it.caption if show_card_captions else ""
		card.pressed.connect(_show.bind(i))
		%CardRow.add_child(card)


func _show(index: int, animate := true) -> void:
	if items.is_empty():
		return
	var changed := index != selected_index
	selected_index = clampi(index, 0, items.size() - 1)
	var it := items[selected_index]

	%Title.text = it.display_name
	%Level.text = "LOCKED" if it.locked else "LEVEL %d" % it.level
	var disp: TextureRect = %Display
	disp.texture = it.showroom_texture if it.showroom_texture else it.thumbnail
	disp.self_modulate = LOCKED_TINT if it.locked else Color.WHITE
	if animate and changed:
		_animate_display()

	for i in _rows.size():
		var val: int = it.stats[i] if i < it.stats.size() else 0
		var pre: int = it.upgrade_preview[i] if i < it.upgrade_preview.size() else 0
		_rows[i].set_stat(val, 0 if it.locked else pre)

	var up: UpgradeButton = %UpgradeButton
	up.cost = it.upgrade_cost
	up.label_text = unlock_label if it.locked else "UPGRADE"
	up.set_available(player_coins >= it.upgrade_cost)

	%PrevButton.disabled = selected_index == 0
	%NextButton.disabled = selected_index == items.size() - 1

	var cards := %CardRow.get_children()
	for i in cards.size():
		(cards[i] as ItemCard).selected = i == selected_index
	if selected_index < cards.size():
		%CardScroll.ensure_control_visible.call_deferred(cards[selected_index])
	item_selected.emit(it)


func _animate_display() -> void:
	var disp: TextureRect = %Display
	disp.pivot_offset = disp.size * 0.5
	if _display_tween:
		_display_tween.kill()
	disp.modulate.a = 0.0
	disp.scale = Vector2(0.94, 0.94)
	_display_tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_display_tween.tween_property(disp, "modulate:a", 1.0, 0.18)
	_display_tween.tween_property(disp, "scale", Vector2.ONE, 0.22)


func _on_upgrade_pressed() -> void:
	if not items.is_empty():
		upgrade_requested.emit(items[selected_index])


## Horizontal swipe on the showroom steps through items.
## Handles both touch and mouse (whichever the platform delivers; duplicates are ignored).
func _on_swipe_input(e: InputEvent) -> void:
	var pressed: bool
	if e is InputEventScreenTouch:
		pressed = e.pressed
	elif e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		pressed = e.pressed
	else:
		return
	if pressed:
		_swipe_start = e.position
	elif _swipe_start != Vector2.INF:
		var d: Vector2 = e.position - _swipe_start
		_swipe_start = Vector2.INF
		if absf(d.x) > SWIPE_MIN and absf(d.x) > absf(d.y) * 1.5:
			step(-1 if d.x > 0 else 1)


## Keep the showroom art ending just below the title, whatever the screen height.
func _sync_showroom() -> void:
	var bottom: float = %Header.global_position.y - global_position.y + 70.0
	%Showroom.size = Vector2(size.x, maxf(bottom, 200.0))
	if display_reference_height > 0.0:
		var k: float = maxf(%Showroom.size.y / display_reference_height, 1.0)
		for n: Control in [%Display, %Shadow]:
			var w0: float = %Showroom.size.x * (n.anchor_right - n.anchor_left)
			var grow := (w0 * k - w0) * 0.5
			n.offset_left = -grow
			n.offset_right = grow
