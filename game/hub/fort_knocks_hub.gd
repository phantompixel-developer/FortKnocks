class_name FortKnocksHub
extends Control

signal command_board_requested
signal garage_requested
signal workshop_requested

@onready var hub_visual: FortKnocksHubVisual = $Visual
@onready var salvage_label: Label = $TopBar/SalvageLabel
@onready var progress_label: Label = $TopBar/ProgressLabel
@onready var platform_label: Label = $StatusCard/PlatformLabel
@onready var notice_label: Label = $NoticeLabel
@onready var command_board_button: Button = $Actions/CommandBoardButton
@onready var garage_button: Button = $Actions/GarageButton
@onready var workshop_button: Button = $Actions/WorkshopButton

func _ready() -> void:
	command_board_button.pressed.connect(func() -> void: command_board_requested.emit())
	garage_button.pressed.connect(func() -> void: garage_requested.emit())
	workshop_button.pressed.connect(func() -> void: workshop_requested.emit())

func configure(save_snapshot: Dictionary, notice := "") -> void:
	var campaign := save_snapshot.get("campaign", {}) as Dictionary
	var inventory := save_snapshot.get("inventory", {}) as Dictionary
	var completed := campaign.get("completed_missions", []) as Array
	var platform_id := str(inventory.get("platform_id", "run_down_compact"))
	hub_visual.configure(platform_id)

	salvage_label.text = "SALVAGE  %d" % int(inventory.get("salvage", 0))
	progress_label.text = "OUTSKIRTS  %d/3 CLEARED" % mini(completed.size(), 3)
	platform_label.text = "ACTIVE PLATFORM\n%s" % _platform_display_name(
		platform_id
	)
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
		_:
			return platform_id.replace("_", " ").to_upper()
