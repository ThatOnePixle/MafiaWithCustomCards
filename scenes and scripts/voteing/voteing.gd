extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

@onready var mainRoot = $".."
@onready var roleTitle = $roleTitle
@onready var background = $background
var playerSelector: PackedScene = preload("res://scenes and scripts/night/player_selector.tscn")
var selectionComplete = false
@onready var playerRole = mainRoot.players["Bot0"]

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

func _ready() -> void:
	roleTitle.text = "You Are: " + playerRole["name"]
	var playerSelectorObject = playerSelector.instantiate()
	self.add_child(playerSelectorObject)

func _selection_complete(botNumber) -> void:
	mainRoot.players["Bot" + str(botNumber)]["dead"] = true
	mainRoot._end_vote()
