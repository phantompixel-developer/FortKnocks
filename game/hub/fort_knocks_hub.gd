class_name FortKnocksHub
extends Control

signal command_board_requested
signal garage_requested
signal workshop_requested

const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")

@onready var hub_visual: FortKnocksHubVisual = $Visual
@onready var subtitle_label: Label = $Subtitle
@onready var salvage_label: Label = $TopBar/SalvageLabel
@onready var progress_label: Label = $TopBar/ProgressLabel
@onready var platform_label: Label = $StatusCard/PlatformLabel
@onready var notice_label: Label = $NoticeLabel
@onready var command_board_button: Button = $Actions/CommandBoardButton
@onready var garage_button: Button = $Actions/GarageButton
@onready var workshop_button: Button = $Actions/WorkshopButton

func _ready() -> void:
	ThemeScript.apply(self)
	ThemeScript.style_card($TopBar)
	ThemeScript.style_card($StatusCard, 1)
	$Title.add_theme_color_override("font_color", ThemeScript.HAZARD)
	command_board_button.pressed.connect(func() -> void: command_board_requested.emit())
	garage_button.pressed.connect(func() -> void: garage_requested.emit())
	workshop_button.pressed.connect(func() -> void: workshop_requested.emit())

func configure(save_snapshot: Dictionary, notice := "") -> void:
	var campaign := save_snapshot.get("campaign", {}) as Dictionary
	var inventory := save_snapshot.get("inventory", {}) as Dictionary
	var completed := campaign.get("completed_missions", []) as Array
	var platform_id := str(inventory.get("platform_id", "run_down_compact"))
	var equipped_modules := inventory.get("equipped_module_by_platform", {}) as Dictionary
	var module_id := str(equipped_modules.get(platform_id, ""))
	hub_visual.configure(platform_id, module_id, completed.size())
	subtitle_label.text = _progress_subtitle(completed.size())

	salvage_label.text = "SALVAGE  %d" % int(inventory.get("salvage", 0))
	if completed.size() > 6:
		progress_label.text = "SUBURBS  %d/4 CLEARED" % mini(completed.size() - 6, 4)
	else:
		progress_label.text = "OUTSKIRTS  %d/6 CLEARED" % mini(completed.size(), 6)
	platform_label.text = "ACTIVE PLATFORM\n%s" % _platform_display_name(platform_id)
	notice_label.text = notice
	notice_label.visible = not notice.is_empty()

func _platform_display_name(platform_id: String) -> String:
	match platform_id:
		"run_down_compact":
			return "RUN-DOWN COMPACT"
		"old_sedan":
			return "OLD SEDAN / ESTATE"
		"pickup":
			return "PICKUP"
		"improvised_technical":
			return "IMPROVISED TECHNICAL"
		_:
			return platform_id.replace("_", " ").to_upper()

func _progress_subtitle(completed_count: int) -> String:
	if completed_count >= 10:
		return "SUBURBS SUPPLY LINE • SECURED STORES EXPANDING"
	if completed_count >= 8:
		return "SUBURBS FOOTHOLD • HEAVIER FABRICATION ONLINE"
	if completed_count >= 7:
		return "SUBURBS FOOTHOLD • PUSHING BEYOND THE OUTSKIRTS"
	if completed_count >= 6:
		return "OUTSKIRTS SECURED • FORTIFIED AND OPERATING"
	if completed_count >= 4:
		return "OUTSKIRTS CAMP • POWERED AND ORGANISED"
	if completed_count >= 2:
		return "OUTSKIRTS CAMP • TAKING SHAPE"
	return "OUTSKIRTS CAMP • HOLDING TOGETHER"
