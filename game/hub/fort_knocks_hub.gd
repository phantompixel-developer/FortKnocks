class_name FortKnocksHub
extends Control

signal command_board_requested
signal garage_requested
signal workshop_requested

const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")

@onready var salvage_label: Label = $TopHUD/SalvagePanel/SalvageLabel
@onready var progress_label: Label = $TopHUD/ProgressPanel/ProgressLabel
@onready var platform_label: Label = $TopHUD/PlatformPanel/PlatformLabel
@onready var notice_panel: TextureRect = $NoticePanel
@onready var notice_label: Label = $NoticePanel/NoticeLabel
@onready var command_board_button: TextureButton = $Navigation/MissionsButton
@onready var garage_button: TextureButton = $Navigation/GarageButton
@onready var workshop_button: TextureButton = $Navigation/WorkshopButton

func _ready() -> void:
	ThemeScript.apply(self)
	command_board_button.pressed.connect(func() -> void: command_board_requested.emit())
	garage_button.pressed.connect(func() -> void: garage_requested.emit())
	workshop_button.pressed.connect(func() -> void: workshop_requested.emit())

func configure(save_snapshot: Dictionary, notice := "") -> void:
	var campaign := save_snapshot.get("campaign", {}) as Dictionary
	var inventory := save_snapshot.get("inventory", {}) as Dictionary
	var completed := campaign.get("completed_missions", []) as Array
	var platform_id := str(inventory.get("platform_id", "run_down_compact"))

	salvage_label.text = "SALVAGE\n%d" % int(inventory.get("salvage", 0))
	if completed.size() > 6:
		progress_label.text = "SUBURBS\n%d/4" % mini(completed.size() - 6, 4)
	else:
		progress_label.text = "OUTSKIRTS\n%d/6" % mini(completed.size(), 6)
	platform_label.text = "ACTIVE\n%s" % _platform_short_name(platform_id)

	notice_label.text = notice
	notice_panel.visible = not notice.is_empty()

func _platform_short_name(platform_id: String) -> String:
	match platform_id:
		"run_down_compact":
			return "COMPACT"
		"old_sedan":
			return "SEDAN"
		"pickup":
			return "PICKUP"
		"improvised_technical":
			return "TECHNICAL"
		_:
			return platform_id.replace("_", " ").to_upper()
