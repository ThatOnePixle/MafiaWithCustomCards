extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

@onready var mainRoot = $".."
@onready var roleTitle = $roleTitle
@onready var background = $background
var playerSelector: PackedScene = preload("res://scenes/night/player_selector.tscn")
var selectionComplete = false

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

func _ready() -> void:
	roleTitle.text = "You Are: " + mainRoot.players["Bot0"]
	var playerSelectorObject = playerSelector.instantiate()
	self.add_child(playerSelectorObject)

func _selection_complete() -> void:
	mainRoot._end_vote()
