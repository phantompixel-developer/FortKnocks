class_name WorkshopScreen
extends Control

signal back_requested

@onready var salvage_label: Label = $TopBar/SalvageLabel
@onready var back_button: Button = $BackButton

func _ready() -> void:
	back_button.pressed.connect(func() -> void: back_requested.emit())

func configure(save_snapshot: Dictionary) -> void:
	var inventory := save_snapshot.get("inventory", {}) as Dictionary
	salvage_label.text = "SALVAGE  %d" % int(inventory.get("salvage", 0))
