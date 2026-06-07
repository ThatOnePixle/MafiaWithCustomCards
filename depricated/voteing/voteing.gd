extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

@onready var mainRoot = $".."
@onready var roleTitle = $roleTitle
#var playerSelector: PackedScene = preload("res://scenes and scripts/night/player_selector.tscn")
var selectionComplete = false
@onready var playerRole = mainRoot.players["Bot0"]
#var playerSelectorObject = playerSelector.instantiate()

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

#Voteing Setup
func _ready() -> void:
	roleTitle.text = "You Are: " + playerRole["name"]
#	self.add_child(playerSelectorObject)

#Voteing Action
func _selection_complete(botNumber) -> void:
	mainRoot.players["Bot" + str(botNumber)]["voted out"] = true
	mainRoot.players["Bot" + str(botNumber)]["dead"] = true
#	self.remove_child(playerSelectorObject)
	mainRoot._end_vote()
