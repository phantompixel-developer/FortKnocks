class_name GarageScreen
extends Control

signal back_requested

@onready var salvage_label: Label = $TopBar/SalvageLabel
@onready var current_label: Label = $CurrentCard/CurrentLabel
@onready var back_button: Button = $BackButton

func _ready() -> void:
	back_button.pressed.connect(func() -> void: back_requested.emit())

func configure(save_snapshot: Dictionary) -> void:
	var inventory := save_snapshot.get("inventory", {}) as Dictionary
	salvage_label.text = "SALVAGE  %d" % int(inventory.get("salvage", 0))
	current_label.text = "ACTIVE\n%s" % _platform_display_name(
		str(inventory.get("platform_id", "run_down_compact"))
	)

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
