extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

@onready var mainRoot = $".."
@onready var roleTitle = $roleTitle
var mafiaAction: PackedScene = preload("res://scenes/night/mafiaAction.tscn")

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

func _ready() -> void:
	roleTitle.text = "You Are: " + mainRoot.players[0]
	if mainRoot.players[0] == "Mafia":
		var mafiaActionObject = mafiaAction.instantiate()
		self.add_child(mafiaActionObject)
