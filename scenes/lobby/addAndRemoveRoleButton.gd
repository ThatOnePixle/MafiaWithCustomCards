extends Control

@onready var rootNode = $"."
@onready var name_of_role_label = $"background/name of role"
var name_of_role: String

func _ready() -> void:
	name_of_role_label.text = name_of_role
